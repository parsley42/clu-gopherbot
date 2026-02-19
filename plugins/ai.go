package main

import (
	"bufio"
	"bytes"
	"crypto/sha1"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/lnxjedi/gopherbot/robot"
)

const (
	shortTermMemoryPrefix      = "ai-conversation"
	shortTermMemoryDebugPrefix = "ai-debug"
	defaultProfile             = "default"
	maxPendingMessages         = 24
	maxProcessedMessages       = 48
	openAIChatCompletionsURL   = "https://api.openai.com/v1/chat/completions"
	defaultChunkSoftLimit      = 420
	defaultChunkHardLimit      = 620
)

var defaultConfig = []byte(`
---
AllowDirect: true
AllChannels: true
CatchAll: true
Commands:
- Command: "debug"
  Regex: '(?i:d(ebug[ -]ai)?)'
  Keywords: [ "ai", "debug" ]
  Usage: "(bot), debug-ai"
  Summary: "enable debug output during AI interactions"
- Command: "close"
  Regex: '(?i:(?:dismiss|banish|close|stop|deactivate|disengage|dispel|reset)[ -]ai)'
  Keywords: [ "ai", "stop" ]
  Usage: "(bot), stop-ai"
  Summary: "stop an AI conversation"
- Command: "status"
  Regex: '^\?$'
  Keywords: [ "ai", "status" ]
  Usage: "(bot), ?"
  Summary: "show AI conversation status in thread"
- Command: "status"
  Regex: '(?i:ai[ -]status)'
  Keywords: [ "ai", "status" ]
  Usage: "(bot), ai-status"
  Summary: "show AI conversation status in thread"
Config:
  Profiles:
    "default":
      "params":
        "model": "gpt-4"
        "temperature": 0.7
      "system": |
        You are Clu, a multi-user chatbot assistant. Keep answers concise and useful.
      "max_context": 7168
`)

type aiProfile struct {
	Params     map[string]interface{} `json:"params"`
	System     string                 `json:"system"`
	MaxContext int                    `json:"max_context"`
}

type aiConfig struct {
	WaitMessages []string             `json:"WaitMessages"`
	DrawMessages []string             `json:"DrawMessages"`
	Profiles     map[string]aiProfile `json:"Profiles"`
}

type conversationExchange struct {
	Human string `json:"human"`
	AI    string `json:"ai"`
}

type pendingMessage struct {
	MessageID string `json:"message_id"`
	User      string `json:"user"`
	Text      string `json:"text"`
	At        string `json:"at"`
}

type conversationState struct {
	Profile    string                 `json:"profile"`
	Tokens     int                    `json:"tokens"`
	Owner      string                 `json:"owner"`
	Exchanges  []conversationExchange `json:"exchanges"`
	Pending    []pendingMessage       `json:"pending"`
	Processed  []string               `json:"processed"`
	InProgress bool                   `json:"in_progress"`
	UpdatedAt  string                 `json:"updated_at"`
}

type conversationContext struct {
	Direct       bool
	User         string
	Channel      string
	ThreadID     string
	MessageID    string
	Prompt       string
	MemoryKey    string
	DebugKey     string
	ExclusiveTag string
}

func Configure() *[]byte {
	return &defaultConfig
}

func PluginHandler(r robot.Robot, command string, args ...string) robot.TaskRetVal {
	switch command {
	case "init":
		return robot.Normal
	case "debug":
		return handleDebug(r)
	case "close":
		return handleClose(r)
	case "status":
		return handleStatus(r)
	case "image":
		return handleImage(r, args...)
	case "ambient", "catchall", "subscribed":
		return handleConversationEntry(r, command, args...)
	default:
		return robot.Normal
	}
}

func handleConversationEntry(r robot.Robot, command string, args ...string) robot.TaskRetVal {
	cmdMode := strings.TrimSpace(r.GetParameter("GOPHER_CMDMODE"))
	ctx := makeConversationContext(r, args...)
	direct := ctx.Direct
	botAlias := strings.TrimSpace(r.GetBotAttribute("alias").Attribute)
	channel := ctx.Channel

	// Preserve existing behavior where alias catchall routes to fallback/help style responses.
	if command == "catchall" && cmdMode == "alias" {
		if direct {
			r.Say("Command not found; try your command in a channel, or use '%shelp'", botAlias)
		} else {
			r.SayThread("No command matched in channel '%s'; try '%shelp'", channel, botAlias)
		}
		return robot.Normal
	}

	state, _ := loadConversationState(r, ctx.MemoryKey)
	ensureConversationDefaults(&state, ctx)

	if !r.Exclusive(ctx.ExclusiveTag, true) {
		state.Pending = queuePendingMessage(state.Pending, pendingMessage{
			MessageID: ctx.MessageID,
			User:      ctx.User,
			Text:      ctx.Prompt,
			At:        nowString(),
		})
		state.UpdatedAt = nowString()
		saveConversationState(r, ctx.MemoryKey, state)
		r.ReplyThread("(I hear you and queued this while I finish the current reply)")
		return robot.Normal
	}

	state.Pending = removePendingMessage(state.Pending, ctx.MessageID)
	state.Processed = appendProcessed(state.Processed, ctx.MessageID)
	state.InProgress = true
	state.UpdatedAt = nowString()
	saveConversationState(r, ctx.MemoryKey, state)

	tbot := r
	if !ctx.Direct {
		tbot = r.Threaded()
	}
	if !ctx.Direct && ctx.ThreadID != "" && len(state.Exchanges) == 0 {
		r.Subscribe()
	}

	hold := randomWaitMessage(r)
	if hold != "" && len(state.Exchanges) == 0 {
		tbot.Reply("( %s )", hold)
	} else if len(state.Exchanges) > 0 {
		tbot.Say("(%s)", r.RandomString([]string{"pondering", "working", "thinking", "cogitating", "processing", "analyzing"}))
	} else {
		tbot.Reply("(thinking...)")
	}

	reply := ""
	if strings.TrimSpace(ctx.Prompt) != "" {
		var err error
		reply, err = queryOpenAI(tbot, r, ctx, state, loadConfig(r))
		if err != nil {
			tbot.Say("Sorry, there was an error contacting the AI: %s", err)
			state.InProgress = false
			state.UpdatedAt = nowString()
			saveConversationState(r, ctx.MemoryKey, state)
			return robot.Normal
		}
		state.Exchanges = append(state.Exchanges, conversationExchange{
			Human: fmt.Sprintf("%s says: %s", ctx.User, ctx.Prompt),
			AI:    reply,
		})
	}
	state.InProgress = false
	state.UpdatedAt = nowString()
	saveConversationState(r, ctx.MemoryKey, state)
	return robot.Normal
}

func handleStatus(r robot.Robot) robot.TaskRetVal {
	ctx := makeConversationContext(r)
	if !ctx.Direct && ctx.ThreadID == "" {
		r.Reply("I can hear you.")
		return robot.Normal
	}

	state, ok := loadConversationState(r, ctx.MemoryKey)
	if !ok || len(state.Exchanges) == 0 {
		r.Reply("I hear you, but I have no memory of a conversation in this context.")
		return robot.Normal
	}
	if state.InProgress {
		r.Reply("I hear you and remember an AI conversation in progress (%d exchanges, %d queued).", len(state.Exchanges), len(state.Pending))
		return robot.Normal
	}
	r.Reply("I hear you and remember an AI conversation (%d exchanges, %d queued).", len(state.Exchanges), len(state.Pending))
	return robot.Normal
}

func handleClose(r robot.Robot) robot.TaskRetVal {
	ctx := makeConversationContext(r)
	state, ok := loadConversationState(r, ctx.MemoryKey)
	if ok && len(state.Exchanges) > 0 {
		r.Remember(ctx.MemoryKey, "", true)
		if !ctx.Direct {
			r.Unsubscribe()
		}
		if ctx.Direct {
			r.Say("Ok, I'll forget this conversation.")
		} else {
			r.Say("Ok, I'll forget this conversation and unsubscribe this thread.")
		}
		return robot.Normal
	}
	if ctx.Direct || ctx.ThreadID != "" {
		r.Say("I have no memory of a conversation in progress.")
		return robot.Normal
	}
	r.Say("That command doesn't apply in this context.")
	return robot.Normal
}

func handleDebug(r robot.Robot) robot.TaskRetVal {
	ctx := makeConversationContext(r)
	if !ctx.Direct && ctx.ThreadID == "" {
		r.SayThread("You can only initialize debugging in a conversation thread.")
		return robot.Normal
	}
	r.Remember(ctx.DebugKey, "true", true)
	r.SayThread("(ok, debugging output is enabled for this conversation)")
	return robot.Normal
}

func handleImage(r robot.Robot, args ...string) robot.TaskRetVal {
	r.SayThread("Image generation is not wired yet in AI vNext.")
	return robot.Normal
}

func isDirectMessage(r robot.Robot) bool {
	msg := r.GetMessage()
	if msg == nil {
		return strings.TrimSpace(r.GetParameter("GOPHER_CHANNEL")) == ""
	}
	return strings.TrimSpace(msg.Channel) == ""
}

func randomWaitMessage(r robot.Robot) string {
	cfg := loadConfig(r)
	if len(cfg.WaitMessages) == 0 {
		return ""
	}
	return r.RandomString(cfg.WaitMessages)
}

func loadConfig(r robot.Robot) aiConfig {
	cfg := aiConfig{}
	if ret := r.GetTaskConfig(&cfg); ret != robot.Ok {
		return cfg
	}
	return cfg
}

func debugJSON(v interface{}) string {
	buf, err := json.Marshal(v)
	if err != nil {
		return "{}"
	}
	return string(buf)
}

func makeConversationContext(r robot.Robot, args ...string) conversationContext {
	direct := isDirectMessage(r)
	channel := strings.TrimSpace(r.GetParameter("GOPHER_CHANNEL"))
	threadID := strings.TrimSpace(r.GetParameter("GOPHER_THREAD_ID"))
	messageID := strings.TrimSpace(r.GetParameter("GOPHER_MESSAGE_ID"))
	user := strings.TrimSpace(r.GetParameter("GOPHER_USER"))
	protocol := strings.TrimSpace(r.GetParameter("GOPHER_PROTOCOL"))
	if protocol == "" {
		protocol = "unknown"
	}
	if user == "" {
		user = "unknown"
	}
	if channel == "" {
		channel = "default"
	}
	prompt := ""
	if len(args) > 0 {
		prompt = strings.TrimSpace(args[0])
	}
	if threadID == "" {
		threadID = messageID
	}
	if threadID == "" {
		threadID = "root"
	}

	ctx := conversationContext{
		Direct:    direct,
		User:      user,
		Channel:   channel,
		ThreadID:  threadID,
		MessageID: messageID,
		Prompt:    prompt,
	}

	if direct {
		ctx.MemoryKey = fmt.Sprintf("%s:%s:dm:%s", shortTermMemoryPrefix, strings.ToLower(protocol), strings.ToLower(user))
		ctx.DebugKey = fmt.Sprintf("%s:%s:dm:%s", shortTermMemoryDebugPrefix, strings.ToLower(protocol), strings.ToLower(user))
		ctx.ExclusiveTag = fmt.Sprintf("%s:%s:dm:%s", shortTermMemoryPrefix, strings.ToLower(protocol), strings.ToLower(user))
	} else {
		ctx.MemoryKey = fmt.Sprintf("%s:%s:%s:%s", shortTermMemoryPrefix, strings.ToLower(protocol), strings.ToLower(channel), threadID)
		ctx.DebugKey = fmt.Sprintf("%s:%s:%s:%s", shortTermMemoryDebugPrefix, strings.ToLower(protocol), strings.ToLower(channel), threadID)
		ctx.ExclusiveTag = fmt.Sprintf("%s:%s:%s:%s", shortTermMemoryPrefix, strings.ToLower(protocol), strings.ToLower(channel), threadID)
	}

	if ctx.ExclusiveTag == "" {
		ctx.ExclusiveTag = shortTermMemoryPrefix + ":fallback"
	}
	return ctx
}

func loadConversationState(r robot.Robot, key string) (conversationState, bool) {
	encoded := strings.TrimSpace(r.Recall(key, true))
	if encoded == "" {
		return conversationState{}, false
	}
	state, err := decodeConversationState(encoded)
	if err != nil {
		return conversationState{}, false
	}
	return state, true
}

func saveConversationState(r robot.Robot, key string, state conversationState) {
	state.UpdatedAt = nowString()
	r.Remember(key, encodeConversationState(state), true)
}

func decodeConversationState(encoded string) (conversationState, error) {
	state := conversationState{}
	// Support raw JSON state.
	if err := json.Unmarshal([]byte(encoded), &state); err == nil {
		return state, nil
	}
	// Support legacy base64(JSON) state.
	decoded, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return conversationState{}, err
	}
	if err := json.Unmarshal(decoded, &state); err != nil {
		return conversationState{}, err
	}
	return state, nil
}

func encodeConversationState(state conversationState) string {
	buf, err := json.Marshal(state)
	if err != nil {
		return ""
	}
	return base64.StdEncoding.EncodeToString(buf)
}

func ensureConversationDefaults(state *conversationState, ctx conversationContext) {
	if state.Profile == "" {
		state.Profile = defaultProfile
	}
	if state.Owner == "" {
		state.Owner = ctx.User
	}
}

func queuePendingMessage(pending []pendingMessage, msg pendingMessage) []pendingMessage {
	if msg.MessageID != "" {
		for _, existing := range pending {
			if existing.MessageID == msg.MessageID {
				return pending
			}
		}
	}
	pending = append(pending, msg)
	if len(pending) > maxPendingMessages {
		return pending[len(pending)-maxPendingMessages:]
	}
	return pending
}

func removePendingMessage(pending []pendingMessage, messageID string) []pendingMessage {
	if messageID == "" || len(pending) == 0 {
		return pending
	}
	out := make([]pendingMessage, 0, len(pending))
	for _, msg := range pending {
		if msg.MessageID == messageID {
			continue
		}
		out = append(out, msg)
	}
	return out
}

func appendProcessed(processed []string, messageID string) []string {
	if messageID == "" {
		return processed
	}
	processed = append(processed, messageID)
	if len(processed) > maxProcessedMessages {
		return processed[len(processed)-maxProcessedMessages:]
	}
	return processed
}

func nowString() string {
	return time.Now().UTC().Format(time.RFC3339)
}

func queryOpenAI(outBot robot.Robot, r robot.Robot, ctx conversationContext, state conversationState, cfg aiConfig) (string, error) {
	token := strings.TrimSpace(r.GetParameter("OPENAI_KEY"))
	if token == "" {
		return "", fmt.Errorf("no OPENAI_KEY set")
	}

	profile := resolveProfile(state.Profile, cfg)
	messages := buildMessages(profile.System, state.Exchanges, ctx)
	payload := map[string]interface{}{
		"messages": messages,
		"stream":   true,
	}
	for k, v := range profile.Params {
		payload[k] = v
	}
	if _, ok := payload["model"]; !ok {
		payload["model"] = "gpt-4"
	}
	if userID := strings.TrimSpace(r.GetParameter("GOPHER_USER_ID")); userID != "" {
		payload["user"] = sha1String(userID)
	}

	reqBody, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequest(http.MethodPost, openAIChatCompletionsURL, bytes.NewReader(reqBody))
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "text/event-stream")
	if org := strings.TrimSpace(r.GetParameter("OPENAI_ORGANIZATION_ID")); org != "" {
		req.Header.Set("OpenAI-Organization", org)
	}

	client := &http.Client{Timeout: 3 * time.Minute}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("%s (%s)", resp.Status, strings.TrimSpace(string(body)))
	}

	return consumeSSEAndEmit(outBot, resp.Body), nil
}

func resolveProfile(profileName string, cfg aiConfig) aiProfile {
	if cfg.Profiles == nil {
		return aiProfile{
			Params: map[string]interface{}{
				"model":       "gpt-4",
				"temperature": 0.7,
			},
			System: "You are Clu, a helpful chatbot assistant.",
		}
	}
	if profileName != "" {
		if profile, ok := cfg.Profiles[profileName]; ok {
			return profile
		}
	}
	if profile, ok := cfg.Profiles[defaultProfile]; ok {
		return profile
	}
	for _, profile := range cfg.Profiles {
		return profile
	}
	return aiProfile{
		Params: map[string]interface{}{
			"model":       "gpt-4",
			"temperature": 0.7,
		},
		System: "You are Clu, a helpful chatbot assistant.",
	}
}

func buildMessages(system string, exchanges []conversationExchange, ctx conversationContext) []map[string]string {
	if strings.TrimSpace(system) == "" {
		system = "You are Clu, a helpful chatbot assistant."
	}
	messages := []map[string]string{
		{
			"role":    "system",
			"content": system,
		},
	}
	for _, exchange := range exchanges {
		if strings.TrimSpace(exchange.Human) != "" {
			messages = append(messages, map[string]string{
				"role":    "user",
				"content": exchange.Human,
			})
		}
		if strings.TrimSpace(exchange.AI) != "" {
			messages = append(messages, map[string]string{
				"role":    "assistant",
				"content": exchange.AI,
			})
		}
	}
	if strings.TrimSpace(ctx.Prompt) != "" {
		messages = append(messages, map[string]string{
			"role":    "user",
			"content": fmt.Sprintf("%s says: %s", ctx.User, ctx.Prompt),
		})
	}
	return messages
}

func consumeSSEAndEmit(outBot robot.Robot, body io.Reader) string {
	reader := bufio.NewReader(body)
	var pending strings.Builder
	var full strings.Builder

	for {
		line, err := reader.ReadString('\n')
		if err != nil && err != io.EOF {
			break
		}
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "data:") {
			payload := strings.TrimSpace(strings.TrimPrefix(line, "data:"))
			if payload == "[DONE]" {
				break
			}
			chunk := extractDeltaContent(payload)
			if chunk != "" {
				full.WriteString(chunk)
				pending.WriteString(chunk)
				emitAvailableChunks(outBot, &pending)
			}
		}
		if err == io.EOF {
			break
		}
	}

	rest := strings.TrimSpace(normalizeChunkText(pending.String()))
	if rest != "" {
		outBot.Say(rest)
	}
	return strings.TrimSpace(full.String())
}

func extractDeltaContent(payload string) string {
	var parsed map[string]interface{}
	if err := json.Unmarshal([]byte(payload), &parsed); err != nil {
		return ""
	}
	rawChoices, ok := parsed["choices"].([]interface{})
	if !ok || len(rawChoices) == 0 {
		return ""
	}
	choice, ok := rawChoices[0].(map[string]interface{})
	if !ok {
		return ""
	}
	rawDelta, ok := choice["delta"].(map[string]interface{})
	if !ok {
		return ""
	}
	content, _ := rawDelta["content"].(string)
	return content
}

func emitAvailableChunks(outBot robot.Robot, pending *strings.Builder) {
	text := pending.String()
	for {
		cut := chunkBoundary(text)
		if cut < 0 {
			break
		}
		chunk := strings.TrimSpace(normalizeChunkText(text[:cut]))
		if chunk != "" {
			outBot.Say(chunk + " (...)")
		}
		text = text[cut:]
	}
	pending.Reset()
	pending.WriteString(text)
}

func chunkBoundary(text string) int {
	if text == "" {
		return -1
	}
	if idx := strings.Index(text, "\n\n"); idx >= 0 {
		return idx + 2
	}
	if len(text) < defaultChunkSoftLimit {
		return -1
	}
	cutRegion := text
	if len(cutRegion) > defaultChunkHardLimit {
		cutRegion = cutRegion[:defaultChunkHardLimit]
	}
	for i := len(cutRegion) - 1; i >= 0; i-- {
		switch cutRegion[i] {
		case '\n':
			if i >= defaultChunkSoftLimit/2 {
				return i + 1
			}
		case '.', '!', '?':
			if i+1 < len(cutRegion) && cutRegion[i+1] == ' ' {
				if i >= defaultChunkSoftLimit/2 {
					return i + 1
				}
			}
		}
	}
	for i := len(cutRegion) - 1; i >= defaultChunkSoftLimit/2; i-- {
		if cutRegion[i] == ' ' {
			return i + 1
		}
	}
	return -1
}

func normalizeChunkText(text string) string {
	if text == "" {
		return text
	}
	if strings.EqualFold(strings.TrimSpace(text), "```") {
		return ""
	}
	if strings.TrimSpace(text) == "" {
		return ""
	}
	if strings.Contains(text, "```") {
		replaced := text
		for {
			start := strings.Index(replaced, "```")
			if start < 0 {
				break
			}
			endLine := strings.Index(replaced[start:], "\n")
			if endLine < 0 {
				break
			}
			end := start + endLine
			prefix := replaced[:start]
			header := strings.TrimSpace(strings.TrimPrefix(replaced[start:end], "```"))
			suffix := replaced[end+1:]
			if header == "" {
				replaced = prefix + "```\n" + suffix
			} else {
				replaced = prefix + header + ":\n```\n" + suffix
			}
		}
		return replaced
	}
	return text
}

func sha1String(s string) string {
	sum := sha1.Sum([]byte(s))
	return fmt.Sprintf("%x", sum)
}

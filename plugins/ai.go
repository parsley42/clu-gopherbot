package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
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

	if !ctx.Direct && ctx.ThreadID != "" && len(state.Exchanges) == 0 {
		r.Subscribe()
	}

	// Placeholder for slice 3+ implementation.
	hold := randomWaitMessage(r)
	if hold != "" {
		r.ReplyThread("(%s)", hold)
	} else {
		r.ReplyThread("(thinking...)")
	}
	r.SayThread("AI vNext scaffold is active; streaming implementation is in progress.")

	if strings.TrimSpace(ctx.Prompt) != "" {
		state.Exchanges = append(state.Exchanges, conversationExchange{
			Human: fmt.Sprintf("%s says: %s", ctx.User, ctx.Prompt),
			AI:    "(placeholder response)",
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
		ctx.MemoryKey = shortTermMemoryPrefix
		ctx.DebugKey = shortTermMemoryDebugPrefix + ":dm:" + strings.ToLower(user)
		ctx.ExclusiveTag = fmt.Sprintf("%s:%s:dm:%s", shortTermMemoryPrefix, protocol, strings.ToLower(user))
	} else {
		ctx.MemoryKey = shortTermMemoryPrefix + ":" + threadID
		ctx.DebugKey = shortTermMemoryDebugPrefix + ":" + threadID
		ctx.ExclusiveTag = fmt.Sprintf("%s:%s:%s:%s", shortTermMemoryPrefix, protocol, channel, threadID)
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

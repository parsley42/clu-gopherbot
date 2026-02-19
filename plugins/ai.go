package main

import (
	"encoding/json"
	"strings"

	"github.com/lnxjedi/gopherbot/robot"
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
	direct := isDirectMessage(r)
	botAlias := strings.TrimSpace(r.GetBotAttribute("alias").Attribute)
	channel := strings.TrimSpace(r.GetParameter("GOPHER_CHANNEL"))

	// Preserve existing behavior where alias catchall routes to fallback/help style responses.
	if command == "catchall" && cmdMode == "alias" {
		if direct {
			r.Say("Command not found; try your command in a channel, or use '%shelp'", botAlias)
		} else {
			r.SayThread("No command matched in channel '%s'; try '%shelp'", channel, botAlias)
		}
		return robot.Normal
	}

	// Placeholder for slice 2+ implementation.
	hold := randomWaitMessage(r)
	if hold != "" {
		r.ReplyThread("(%s)", hold)
	} else {
		r.ReplyThread("(thinking...)")
	}
	r.SayThread("AI vNext scaffold is active; streaming implementation is in progress.")
	return robot.Normal
}

func handleStatus(r robot.Robot) robot.TaskRetVal {
	r.Reply("AI vNext is loaded and listening.")
	return robot.Normal
}

func handleClose(r robot.Robot) robot.TaskRetVal {
	r.Say("Ok, I'll forget this conversation.")
	return robot.Normal
}

func handleDebug(r robot.Robot) robot.TaskRetVal {
	r.SayThread("(ok, debugging output will be added in the next slice)")
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

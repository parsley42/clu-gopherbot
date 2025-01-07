-- hello.lua
-- Lua plugin "Hello World" and boilerplate

-- By convention, plugins provide their own help and regular expressions
-- for matching commands. Other configuration, like which channel a plugin
-- is active in, is normally configured by the individual robot.
local defaultConfig = [[
---
Help:
- Keywords: [ "lua" ]
  Helptext: [ "(bot), hello lua - trigger lua hello world" ]
- Keywords: [ "lua" ]
  Helptext: [ "(bot), testmsg lua - trigger lua messaging tests" ]
CommandMatchers:
- Regex: (?i:hello lua)
  Command: lua
- Regex: (?i:testmsg lua)
  Command: testmsg
]]

-- Load our gopherbot library module (gopherbot_v1.lua).
local gopherbot = require "gopherbot_v1"
local dump = require "table_string"

local ret, task, log, fmt, proto, Robot =
    gopherbot.ret,   -- returns a table of API return-value constants
    gopherbot.task,  -- returns a table of task return-value constants
    gopherbot.log,   -- log levels
    gopherbot.fmt,   -- message formats
    gopherbot.proto, -- chat protocols
    gopherbot.Robot  -- the Robot class for Robot:new()

local cmd = arg[1] or ""
local bot = Robot:new()
-- Command dispatch table
local commands = {
    lua = function()
        local retVal = bot:Say("Hello, Lua World! User: " .. bot.user .. " UserID: " .. bot.user_id, fmt.Fixed)
        bot:SendUserMessage(bot.user, "Straight to YOU, baby!")
        attr, aret = bot:GetBotAttribute("name")
        bot:Say("My name is " .. attr .. " ret: " .. ret:string(aret))
        attr, aret = bot:GetBotAttribute("boogers")
        bot:Say("My boogers is " .. attr .. " ret: " .. ret:string(aret))
        dbot = bot:Direct()
        dbot:Say(string.format("Also to you, I hope! (using direct) (Channel/id): (%s/%s), type: %s", dbot.channel, dbot.channel_id, dbot.type))
        bot:SendUserChannelMessage(bot.user, bot.channel, "Talking to you in the channel - Hi!")
        local cfg, cret = bot:GetTaskConfig()
        bot:Say("Look what I found! - \n" .. dump(cfg))
        if retVal == ret.Ok then
            return task.Normal
        else
            return task.Fail
        end
    end,
    testmsg = function()
        -- Test cases using different users and channels
        local users = { "alice", "bob", "carol", "david", "erin" }
        local channels = { "general", "random" }

        -- 1. Say to current user
        bot:Say("Say to current user")

        -- 2. SayThread to current user/thread
        bot:SayThread("SayThread to current user/thread")

        -- 3. Reply to current user
        bot:Reply("Reply to current user")

        -- 4. ReplyThread to current user/thread
        bot:ReplyThread("ReplyThread to current user/thread")

        -- 5. SendUserMessage to a specific user
        bot:SendUserMessage(users[1], "SendUserMessage to " .. users[1])

        -- 6. SendChannelMessage to a specific channel
        bot:SendChannelMessage(channels[1], "SendChannelMessage to " .. channels[1])

        -- 7. SendUserChannelMessage to a specific user/channel
        bot:SendUserChannelMessage(users[2], channels[2], "SendUserChannelMessage to " .. users[2] .. "/" .. channels[2])

        -- 8. SendChannelThreadMessage to a specific channel/thread (no thread)
        bot:SendChannelThreadMessage(channels[1], "", "SendChannelThreadMessage to " .. channels[1] .. " (no thread)")

        -- 9. SendUserChannelThreadMessage to specific user/channel/thread (no thread)
        bot:SendUserChannelThreadMessage(users[3], channels[2], "", "SendUserChannelThreadMessage to " .. users[3] .. "/" .. channels[2] .. " (no thread)")

        -- 10. Change channel and Reply
        bot.channel = channels[2]
        bot:Reply("Reply after changing channel to " .. channels[2])

        -- 11. Change user and SendUserMessage
        bot.user = users[4]
        bot:SendUserMessage(bot.user, "SendUserMessage after changing user to " .. users[4])

        -- 12. SendChannelMessage to current channel (changed)
        bot:SendChannelMessage(bot.channel, "SendChannelMessage to current channel (changed to " .. channels[2] .. ")")

        -- 13. Change user and Reply
        bot.user = users[5]
        bot:Reply("Reply after changing user to " .. users[5])

        -- 14. SendUserChannelThreadMessage with specific user/channel/thread
        bot:SendUserChannelThreadMessage(users[1], channels[1], "thread123", "SendUserChannelThreadMessage with specific user/channel/thread")

        return task.Normal
    end,
    -- Add more commands here
}

if cmd == "init" then
    return task.Normal
elseif cmd == "configure" then
    return defaultConfig
else
    local commandFunc = commands[cmd]
    if commandFunc then
        return commandFunc()
    else
        bot:Log(log.Error, "Lua plugin received unknown command: " .. tostring(cmd))
        return task.Fail
    end
end
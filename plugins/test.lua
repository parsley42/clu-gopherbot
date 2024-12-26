-- hello.lua
-- Lua plugin "Hello World" with comprehensive test cases

-- By convention, plugins provide their own help and regular expressions
-- for matching commands. Other configuration, like which channel a plugin
-- is active in, is normally configured by the individual bot.
local defaultConfig = [[
---
Help:
- Keywords: [ "lua" ]
  Helptext: [ "(bot), hello lua - trigger lua hello world and run tests" ]
CommandMatchers:
- Regex: (?i:hello lua)
  Command: lua
]]

-- Require the constants module
ret, task, log, fmt, proto = require "gopherbot_constants" ()

local cmd = ""
if #arg > 0 then cmd = arg[1] end

if cmd == "init" then
    return task.Normal
elseif cmd == "configure" then
    return defaultConfig
end

-- bot isn't available during "configure", so we initialize bot here.
local bot = robot:New()

if cmd == "lua" then
    -- Begin Test Cases

    -- Test 1: Basic Say
    bot:Log(log.Info, "Test 1: Basic Say - Sending 'Hello, Lua World!'")
    local retVal1 = bot:Say("Hello, Lua World!")
    if retVal1 == ret.Ok then
        bot:Log(log.Info, "Test 1 Passed: Say executed successfully.")
    else
        bot:Log(log.Error, "Test 1 Failed: Say returned an error.")
    end

    -- Test 2: Clone Bot
    bot:Log(log.Info, "Test 2: Clone Bot - Creating clonedBot = bot:Clone()")
    local clonedBot = bot:Clone()
    bot:Log(log.Info, "Test 2: ClonedBot user: " .. tostring(clonedBot.user))
    bot:Log(log.Info, "Test 2: ClonedBot channel: " .. tostring(clonedBot.channel))
    clonedBot:Say("Hello from clonedBot!")

    -- Test 3: Fixed Bot
    bot:Log(log.Info, "Test 3: Fixed Bot - Creating fixedBot = bot:Fixed()")
    local fixedBot = bot:Fixed()
    bot:Log(log.Info, "Test 3: FixedBot format: " .. tostring(fixedBot.format))
    fixedBot:Say("Hello from fixedBot with FixedFormat!")

    -- Test 4: Direct Bot
    bot:Log(log.Info, "Test 4: Direct Bot - Creating directBot = bot:Direct()")
    local directBot = bot:Direct()
    bot:Log(log.Info, "Test 4: DirectBot sending direct message to user: " .. tostring(directBot.user))
    directBot:Say("Hello directly from directBot!")

    -- Test 5: Threaded Bot
    bot:Log(log.Info, "Test 5: Threaded Bot - Creating threadedBot = bot:Threaded()")
    local threadedBot = bot:Threaded()
    bot:Log(log.Info, "Test 5: ThreadedBot threaded_message: " .. tostring(threadedBot.threaded_message))
    threadedBot:Say("Hello from threadedBot in a thread!")

    -- Test 6: MessageFormat Change to Fixed
    bot:Log(log.Info, "Test 6: Changing Message Format to 'Fixed' - bot:MessageFormat(fmt.Fixed)")
    fbot = bot:MessageFormat(fmt.Fixed)
    fbot:Log(log.Info, "Test 6: Current Message Format: " .. tostring(fbot.format))
    fbot:Say("Hello with Fixed formatting!")

    -- Test 7: MessageFormat Change to Variable
    bot:Log(log.Info, "Test 7: Changing Message Format to 'Variable' - bot:MessageFormat(fmt.Variable)")
    local vbot = bot:MessageFormat(fmt.Variable)
    vbot:Log(log.Info, "Test 7: Current Message Format: " .. tostring(vbot.format))
    vbot:Say("Hello with Variable formatting!")

    -- Test 8: Setting bot.user to 'alice'
    bot:Log(log.Info, "Test 8: Setting bot.user to 'alice'")
    bot.user = "alice"
    bot:Log(log.Info, "Test 8: Updated bot.user: " .. tostring(bot.user))
    local retVal8 = bot:Reply("Hello, Alice!")
    if retVal8 == ret.Ok then
        bot:Log(log.Info, "Test 8 Passed: Reply to Alice executed successfully.")
    else
        bot:Log(log.Error, "Test 8 Failed: Reply to Alice returned an error.")
    end

    -- Test 9: Setting bot.channel to 'random'
    bot:Log(log.Info, "Test 9: Setting bot.channel to 'random'")
    bot.channel = "random"
    bot:Log(log.Info, "Test 9: Updated bot.channel: " .. tostring(bot.channel))
    local retVal9 = bot:Say("Hello in the random channel!")
    if retVal9 == ret.Ok then
        bot:Log(log.Info, "Test 9 Passed: Say in random channel executed successfully.")
    else
        bot:Log(log.Error, "Test 9 Failed: Say in random channel returned an error.")
    end

    -- Test 10: Setting bot.user to 'bob'
    bot:Log(log.Info, "Test 10: Setting bot.user to 'bob'")
    bot.user = "bob"
    bot:Log(log.Info, "Test 10: Updated bot.user: " .. tostring(bot.user))
    local retVal10 = bot:Reply("Hello, Bob!")
    if retVal10 == ret.Ok then
        bot:Log(log.Info, "Test 10 Passed: Reply to Bob executed successfully.")
    else
        bot:Log(log.Error, "Test 10 Failed: Reply to Bob returned an error.")
    end

    -- Test 11: Setting bot.channel to 'general'
    bot:Log(log.Info, "Test 11: Setting bot.channel to 'general'")
    bot.channel = "general"
    bot:Log(log.Info, "Test 11: Updated bot.channel: " .. tostring(bot.channel))
    local retVal11 = bot:Say("Hello in the general channel!")
    if retVal11 == ret.Ok then
        bot:Log(log.Info, "Test 11 Passed: Say in general channel executed successfully.")
    else
        bot:Log(log.Error, "Test 11 Failed: Say in general channel returned an error.")
    end

    -- Test 12: Setting bot.user to 'carol'
    bot:Log(log.Info, "Test 12: Setting bot.user to 'carol'")
    bot.user = "carol"
    bot:Log(log.Info, "Test 12: Updated bot.user: " .. tostring(bot.user))
    local retVal12 = bot:Reply("Hello, Carol!")
    if retVal12 == ret.Ok then
        bot:Log(log.Info, "Test 12 Passed: Reply to Carol executed successfully.")
    else
        bot:Log(log.Error, "Test 12 Failed: Reply to Carol returned an error.")
    end

    -- Test 13: Setting bot.user to 'david'
    bot:Log(log.Info, "Test 13: Setting bot.user to 'david'")
    bot.user = "david"
    bot:Log(log.Info, "Test 13: Updated bot.user: " .. tostring(bot.user))
    local retVal13 = bot:Reply("Hello, David!")
    if retVal13 == ret.Ok then
        bot:Log(log.Info, "Test 13 Passed: Reply to David executed successfully.")
    else
        bot:Log(log.Error, "Test 13 Failed: Reply to David returned an error.")
    end

    -- Test 14: Setting bot.user to 'erin'
    bot:Log(log.Info, "Test 14: Setting bot.user to 'erin'")
    bot.user = "erin"
    bot:Log(log.Info, "Test 14: Updated bot.user: " .. tostring(bot.user))
    local retVal14 = bot:Reply("Hello, Erin!")
    if retVal14 == ret.Ok then
        bot:Log(log.Info, "Test 14 Passed: Reply to Erin executed successfully.")
    else
        bot:Log(log.Error, "Test 14 Failed: Reply to Erin returned an error.")
    end

    -- Test 15: Setting bot.user to 'jill' (User Not Found)
    bot:Log(log.Info, "Test 15: Setting bot.user to 'jill' (Expecting user not found error)")
    bot.user = "jill"
    bot:Log(log.Info, "Test 15: Updated bot.user: " .. tostring(bot.user))
    local retVal15 = bot:Reply("Hello, Jill!")
    if retVal15 == ret.Ok then
        bot:Log(log.Error, "Test 15 Failed: Reply to Jill should have failed but succeeded")
    else
        bot:Log(log.Info, "Test 15 Passed: Reply to Jill returned an error as expected: " .. ret:string(retVal15))
    end

    -- Test 16: Invalid Field Assignment - Assigning non-string to bot.user
    bot:Log(log.Info, "Test 16: Attempting to set bot.user to a non-string value (123)")
    local status16, err16 = pcall(function()
        bot.user = 123
    end)
    if not status16 then
        bot:Log(log.Info, "Test 16 Passed: Error caught - " .. err16)
    else
        bot:Log(log.Error, "Test 16 Failed: No error on invalid assignment.")
    end
    bot.user = 123

    -- Test 17: Invalid Field Assignment - Assigning non-bool to threaded_message
    bot:Log(log.Info, "Test 17: Attempting to set bot.threaded_message to a non-bool value ('yes')")
    local status17, err17 = pcall(function()
        bot.threaded_message = "yes"
    end)
    if not status17 then
        bot:Log(log.Info, "Test 17 Passed: Error caught - " .. err17)
    else
        bot:Log(log.Error, "Test 17 Failed: No error on invalid assignment.")
    end

    -- Test 18: Assigning to an Unknown Field
    bot:Log(log.Info, "Test 18: Attempting to set an unknown field bot.unknown_field = 'test'")
    local status18, err18 = pcall(function()
        bot.unknown_field = "test"
    end)
    if not status18 then
        bot:Log(log.Info, "Test 18 Passed: Error caught - " .. err18)
    else
        bot:Log(log.Error, "Test 18 Failed: No error on unknown field assignment.")
    end

    -- Test 19: Reverting bot.user and bot.channel to Original Values
    bot:Log(log.Info, "Test 19: Reverting bot.user to 'david' and bot.channel to 'general'")
    bot.user = "david"
    bot.channel = "general"
    bot:Log(log.Info, "Test 19: Reverted bot.user: " .. tostring(bot.user))
    bot:Log(log.Info, "Test 19: Reverted bot.channel: " .. tostring(bot.channel))
    local retVal19 = bot:Reply("Hello again, David!")
    if retVal19 == ret.Ok then
        bot:Log(log.Info, "Test 19 Passed: Reply to David executed successfully.")
    else
        bot:Log(log.Error, "Test 19 Failed: Reply to David returned an error.")
    end

    -- End of Test Cases
    return task.Normal
end

#!/usr/bin/ruby

# boilerplate
require 'gopherbot_v1'

bot = Robot.new()

defaultConfig = <<'DEFCONFIG'
AllowDirect: false
Commands:
- Regex: '(?i:say anything)'
  Command: "sayit"
  Keywords: [ "say", "anything" ]
  Usage: "(alias) say anything"
  Summary: "blurt out some text to verify the ruby library"
  Examples:
  - "(alias) say anything"
  Helptext: [ "(alias) say anything - blurt out some crap to test ruby lib" ]
DEFCONFIG

command = ARGV.shift()

case command
when "configure"
	puts defaultConfig
	exit
when "sayit"
    bot.Say("Hello, World!")
    bot.AddTask("say", ["I can say ANYTHING"])
end

#!/usr/bin/ruby

# boilerplate
require 'gopherbot_v1'

bot = Robot.new()

defaultConfig = <<'DEFCONFIG'
AllowDirect: false
Help:
- Keywords: [ "say", "anything" ]
  Helptext: [ "(bot), say anything - blurt out some crap to test ruby lib" ]
CommandMatchers:
- Regex: '(?i:say anything)'
  Command: "sayit"
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

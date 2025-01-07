// hello.js
// JavaScript plugin "Hello World" and boilerplate

// Define the default configuration as a YAML string
const defaultConfig = `---
Help:
  - Keywords: [ "js" ]
    Helptext: [ "(bot), hello js - trigger JavaScript hello world" ]
CommandMatchers:
  - Regex: (?i:hello js)
    Command: js
`;

// Require the Gopherbot JavaScript library
const { Robot, ret, task, log, fmt, proto } = require('gopherbot_v1')();

function handler(argv) {
  // 0: the path to gopherbot, the js interpreter
  // 1: the path to the *.js source file
  // 2+: arguments
  const cmd = argv.length > 2 ? argv[2] : '';

  switch (cmd) {
    case 'init':
      // Initialization logic if needed (usually not required for simple plugins)
      return task.Normal;

    case 'configure':
      // Return the default configuration
      return defaultConfig;

    case 'js':
      const bot = new Robot;
      bot.Say("Hello, JavaScript New World!");
      const dbot = bot.Direct();
      dbot.Say("Straight to you, man!");
      const botNameAttr = bot.GetBotAttribute("name");
      const femail = dbot.GetUserAttribute("frank", "email")
      dbot.Say("Franks email is " + femail.attribute)
      bot.Say("My name is: " + botNameAttr.attribute + " ret: " + ret.string(botNameAttr.retVal) + " (" + JSON.stringify(botNameAttr) + ")");
      bot.SendUserMessage(bot.user, "Et tu, Brute!");
      return task.Normal;

    default:
      // const botDefault = robot.New();
      // botDefault.Log(log.Error, `JavaScript plugin received unknown command: ${cmd}`);
      return task.Fail;
  }
}

// @ts-ignore - the "process" object is created by goja
handler(process.argv || []); // Call the function with process.argv

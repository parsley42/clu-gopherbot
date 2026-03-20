#!/bin/bash -e

source $GOPHER_INSTALLDIR/lib/gopherbot_v1.sh

COMMAND=$1
shift

configure(){
  cat <<"EOF"
Channels:
- general
Commands:
- Command: "format"
  Regex: '(?i:format world)'
  Keywords: [ "format", "world" ]
  Usage: "(alias) format world"
  Summary: "exercise formatting options"
  Examples:
  - "(alias) format world"
  Helptext: [ "(alias) format world - exercise formatting options" ]
- Command: "fixed"
  Regex: '(?i:format fixed)'
  Keywords: [ "format", "fixed" ]
  Usage: "(alias) format fixed"
  Summary: "send a fixed-format demo message"
  Examples:
  - "(alias) format fixed"
- Command: "variable"
  Regex: '(?i:format variable)'
  Keywords: [ "format", "variable" ]
  Usage: "(alias) format variable"
  Summary: "send a variable-format demo message"
  Examples:
  - "(alias) format variable"
- Command: "raw"
  Regex: '(?i:format raw)'
  Keywords: [ "format", "raw" ]
  Usage: "(alias) format raw"
  Summary: "send a raw-format demo message"
  Examples:
  - "(alias) format raw"
- Command: "longfixed"
  Regex: '(?i:split fixed)'
  Keywords: [ "format", "split", "fixed" ]
  Usage: "(alias) split fixed"
  Summary: "send a long fixed-format message to test splitting"
  Examples:
  - "(alias) split fixed"
- Command: "longraw"
  Regex: '(?i:split raw)'
  Keywords: [ "format", "split", "raw" ]
  Usage: "(alias) split raw"
  Summary: "send a long raw-format message to test splitting"
  Examples:
  - "(alias) split raw"
- Command: "render-basic"
  Regex: '(?i:(?:render|format)[ -]?basic|exercise basic(?:[ -]?markdown)?)'
  Keywords: [ "render", "format", "basicmarkdown", "emoji", "markdown" ]
  Usage: "(alias) render-basic"
  Summary: "render BasicMarkdown samples for v1 elements plus SSH wrap/styling checks"
  Examples:
  - "(alias) render-basic"
  - "(alias) exercise BasicMarkdown"
EOF
}

render_basic(){
  local PREV_FORMAT=${GB_FORMAT:-}

  MessageFormat BasicMarkdown

  Say -r "Paragraph and line-break test:"
  Say $'Hello team,\n\nPrometheus is crashing again.\nInvestigating now.'

  Say -r "Bold and italic test:"
  Say '**Deploy status:** failed; *rollback in progress*'

  Say -r "Bold and italic wrap test:"
  Say 'This line checks wrapping with **bold phrases that should stay visually contained** while *italic guidance also wraps naturally* across a narrow SSH window.'

  Say -r "Mixed formatting stress test:"
  Say 'Mix **bold**, *italic*, `inline code`, [styled runbook](https://example.com/runbook), and plain follow-up text in one longer sentence so SSH rendering has to wrap something realistic.'

  Say -r "Inline code test:"
  Say 'Run `kubectl get pods` and check `CrashLoopBackOff`.'

  Say -r "Code-boundary test:"
  Say 'Formatting should stop at code boundaries: `**not bold** *not italic* :rocket:` and then resume with **real bold** plus *real italic*.'

  Say -r "Fenced code block test:"
  Say $'```yaml\napiVersion: v1\nkind: Pod\nmetadata:\n  name: basicmarkdown-demo\n```'

  Say -r "Block quote test:"
  Say $'> node is NotReady\n> rollout paused pending review'

  Say -r "Unordered list test:"
  Say $'- Service: payments-api\n- Namespace: prod\n- Owner: @parsley'

  Say -r "Link test:"
  Say 'See [runbook](https://example.com/runbook) and https://status.example.com'

  Say -r "Link plus emphasis test:"
  Say 'See [**deployment runbook**](https://example.com/runbook) and [*incident notes*](https://example.com/notes).'

  Say -r "Mention test (resolved + unresolved + email false-positive):"
  Say 'Paging @parsley for review; fallback @no_such_user; contact oncall@example.com'

  Say -r "Emoji test:"
  Say 'Core shortcodes: :white_check_mark: :warning: :x: :rocket: :fire: :joy: :thinking_face: :eyes: :thumbsup: :thumbsdown:'
  Say 'Team shortcode: :priority-high:'
  Say 'Unicode emoji: ✅ 🔥 😂'

  Say -r "Escaping test:"
  Say 'Literals: \*not bold\* \`not code\` \[label\]\(https://example.com\) \@parsley \\'

  if [ -n "$PREV_FORMAT" ]
  then
    MessageFormat "$PREV_FORMAT"
  else
    unset GB_FORMAT
  fi
}

case "$COMMAND" in
  "configure")
    configure
    ;;
  "format")
    # Change default format
    MessageFormat Variable
    PROTO=$(GetBotAttribute protocol)
    Say "Hello, $PROTO World!"
    # Use default format
    Say 'Default _Italics_ <One> :100: *Bold* `Code` @parsley <https://cnn.com|*CNN*>'
    # Raw
    Say -r 'Raw _Italics_ <One> :100: *Bold* `Code` @parsley <https://cnn.com|*CNN*>'
    # Variable
    Say -v 'Variable _Italics_ <One> :100: *Bold* `Code` @parsley <https://cnn.com|*CNN*>'
    # Fixed
    Say -f 'Fixed _Italics_ <One> :100: *Bold* `Code` @parsley <https://cnn.com|*CNN*>'
    ;;
  "fixed")
    Say -f '_Italics_ <One> *Bold* `Code` @parsley <https://cnn.com|*CNN*>'
    ;;
  "variable")
    Say -v '_Italics_ <One> *Bold* `Code` @parsley <https://cnn.com|*CNN*>'
    ;;
  "raw")
    Say -r '_Italics_ <One> *Bold* `Code` @parsley <https://cnn.com|*CNN*>'
    ;;
  "longfixed")
    FTEXT=$(cat <<EOF
2015/10/21 07:28:07 Initialized logging ...
2015/10/21 07:28:07 No private environment loaded from '.env': open : no such file or directory
2015/10/21 07:28:07 Starting up with config dir: custom, and install dir: /opt/gopherbot
2015/10/21 07:28:07 Privilege separation not in use
2015/10/21 07:28:07 Info: Successfully decrypted binary encryption key 'custom/binary-encrypted-key'
2015/10/21 07:28:07 Info: Loading initial pre-connection configuration
2015/10/21 07:28:07 Info: Set timezone: America/New_York
2015/10/21 07:28:07 Info: Initialized file history provider with directory: 'history'; serving on: ':9000'
2015/10/21 07:28:07 Info: Starting fileserver listener for file history provider
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-totp', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-totp' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-history', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-history' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'help', type taskGo
2015/10/21 07:28:07 Info: Plugin 'help' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'memes', type taskGo
2015/10/21 07:28:07 Info: Plugin 'memes' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-jobcmd', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-jobcmd' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'groups', type taskGo
2015/10/21 07:28:07 Info: Plugin 'groups' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Warning: Plugin 'groups' has custom config, but none is configured
2015/10/21 07:28:07 Info: Loading configuration for plugin 'duo', type taskGo
2015/10/21 07:28:07 Info: Plugin 'duo' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'lists', type taskGo
2015/10/21 07:28:07 Info: Plugin 'lists' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-dmadmin', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-dmadmin' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'knock', type taskGo
2015/10/21 07:28:07 Info: Plugin 'knock' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'links', type taskGo
2015/10/21 07:28:07 Info: Plugin 'links' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'ping', type taskGo
2015/10/21 07:28:07 Info: Plugin 'ping' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'slackutil', type taskGo
2015/10/21 07:28:07 Info: Plugin 'slackutil' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-fallback', type taskGo
2015/10/21 07:28:07 Info: Plugin/Job 'builtin-fallback' is disabled by configuration
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-help', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-help' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-admin', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-admin' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-logging', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-logging' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for job 'pause-notifies', type taskGo
EOF
)
    Say -f "$FTEXT"
    ;;
  "longraw")
    FTEXT=$(cat <<"EOF"
```2015/10/21 07:28:07 @parsley @nobody Initialized logging ...
2015/10/21 07:28:07 No private environment loaded from '.env': open : no such file or directory
2015/10/21 07:28:07 Starting up with config dir: custom, and install dir: /opt/gopherbot
2015/10/21 07:28:07 Privilege separation not in use
2015/10/21 07:28:07 Info: Successfully decrypted binary encryption key 'custom/binary-encrypted-key'
```
2015/10/21 07:28:07 Info: @parsley Loading initial pre-connection configuration
2015/10/21 07:28:07 Info: Set timezone: America/New_York
2015/10/21 07:28:07 Info: Initialized file history provider with directory: 'history'; serving on: ':9000'
2015/10/21 07:28:07 Info: Starting fileserver listener for file history provider
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-totp', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-totp' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-history', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-history' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'help', type taskGo
2015/10/21 07:28:07 Info: Plugin 'help' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'memes', type taskGo
2015/10/21 07:28:07 Info: Plugin 'memes' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-jobcmd', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-jobcmd' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'groups', type taskGo
2015/10/21 07:28:07 Info: Plugin 'groups' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Warning: Plugin 'groups' has custom config, but none is configured
2015/10/21 07:28:07 Info: Loading configuration for plugin 'duo', type taskGo
2015/10/21 07:28:07 Info: Plugin 'duo' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'lists', type taskGo
2015/10/21 07:28:07 Info: Plugin 'lists' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-dmadmin', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-dmadmin' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'knock', type taskGo
2015/10/21 07:28:07 Info: Plugin 'knock' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'links', type taskGo
```2015/10/21 07:28:07 Info: Plugin 'links' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'ping', type taskGo
2015/10/21 07:28:07 Info: Plugin 'ping' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'slackutil', type taskGo
2015/10/21 07:28:07 Info: Plugin 'slackutil' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-fallback', type taskGo
2015/10/21 07:28:07 Info: Plugin/Job 'builtin-fallback' is disabled by configuration
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-help', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-help' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-admin', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-admin' has no channel restrictions configured; all channels: true
2015/10/21 07:28:07 Info: Loading configuration for plugin 'builtin-logging', type taskGo
2015/10/21 07:28:07 Info: Plugin 'builtin-logging' will be available in channels ["general" "random" "chat" "botdev" "clu-jobs"]
2015/10/21 07:28:07 Info: Loading configuration for job 'pause-notifies', type taskGo
```
EOF
)
    Say "$FTEXT"
    ;;
  "render-basic")
    render_basic
    ;;
esac

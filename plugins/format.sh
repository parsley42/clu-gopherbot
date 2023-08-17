#!/bin/bash -e

source $GOPHER_INSTALLDIR/lib/gopherbot_v1.sh

COMMAND=$1
shift

configure(){
  cat <<"EOF"
Channels:
- general
Help:
- Keywords: [ "format", "world" ]
  Helptext: [ "(bot), format world - exercise formatting options" ]
CommandMatchers:
- Regex: '(?i:format world)'
  Command: "format"
- Regex: '(?i:format fixed)'
  Command: "fixed"
- Regex: '(?i:format variable)'
  Command: "variable"
- Regex: '(?i:format raw)'
  Command: "raw"
- Regex: '(?i:split fixed)'
  Command: "longfixed"
- Regex: '(?i:split raw)'
  Command: "longraw"
EOF
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
esac

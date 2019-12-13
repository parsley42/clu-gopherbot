# Clu
`Clu` is the development instance of Gopherbot that runs wherever I need him, and tracks development of **Gopherbot**. This repository represents the bulk of Clu's custom configuration; the only other bits:
* [clu-state](https://github.com/parsley42/clu-state) - Clu's memories and other personal belongings; only Clu should be pushing there
* Clu's `private/environment` - an environment file, which should be mode `0600` and closely guarded:

```shell
GOPHER_ENCRYPTION_KEY=<32 chars used to decrypt binary-encrypted-key>
GOPHER_CUSTOM_REPOSITORY=<git remote for this repository>
```

* `Clu`'s custom configuration will form the basis for new robot configuration, the contents of [robot.skel](https://github.com/lnxjedi/gopherbot/tree/master/robot.skel)
* `Clu`'s configuration may be _ahead_ of master, when it represents a development target

## Directory Structure

This is the directory structure created when I run `../gopherbot/fetch-robot.sh clu`:

* `clu/` - Top-level directory, not a git repo
    * `gopherbot` - symlink to `/opt/gopherbot/gopherbot`
    * `terminal.sh` - convenience script for running `clu` with the terminal connector
    * `custom/` - clone of `parsley42/clu-gopherbot`, custom configuration repository
    * `state/` - clone of `parsley42/clu-state`, where clu saves state, e.g. memories
    * `private/` - clone of `parsley42/clu-private`, a private repository containing only `environment`

The environment file is only:
```shell
GOPHER_ENCRYPTION_KEY=<redacted>
GOPHER_CUSTOM_REPOSITORY=git@github.com:parsley42/clu-gopherbot.git
DEPLOY_KEY=-----BEGIN OPENSSH PRIVATE KEY-----:b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn:NhAAAAAwEAAQAAAYEAmfLLya54/6TP1QevDpsXYaUDLc7RO1gvwBFRWxVyYPA83HvSEdAV:bFHYpMZXtRj+rD1jTvLCtV+5ZlKrirxqW1Y/hJqNJhZIvZDXEmlRMvXAEDKHKSR6Vnrp/J:qH8F+B6X5bUTkHS+dQcOlrs0YP4+ZU4QZ9I+VFnQY8xIpGVEq4LtazrGf38gJsCuITr1oD:3RL1yLNRhebjIzntv6YusNHKFZVtppkxgfoiqJokss+vg7+IW4aa04SgXX1+fHQT7Pk3+T:r5BLTONlFnhGpiDt8RfnPoVC1WEdbkg5iO/2t3/L1cgGXlee/YxGchy7DK2Kv3leYw/zse:R7kiB2wgk3DcRWQyBm9ySMTc72dojvBYDmFqE076aAf+S6ZYrpaqv8tlIDvPm8jLRXn2Qb:ShP33NRPwKK/3nboO4nwPtC1HwvdG4AuMiFRA3e0HMlXdlOy9wXo86mQiF0c0JNMHvXxrL:4BhGXlmObcg1oqGKJ1sJ0McG2GtEVLzWQasOpX7lAAAFkP3MJ4f9zCeHAAAAB3NzaC1yc2:EAAAGBAJnyy8mueP+kz9UHrw6bF2GlAy3O0TtYL8ARUVsVcmDwPNx70hHQFWxR2KTGV7UY:/qw9Y07ywrVfuWZSq4q8altWP4SajSYWSL2Q1xJpUTL1wBAyhykkelZ66fyah/Bfgel+W1:E5B0vnUHDpa7NGD+PmVOEGfSPlRZ0GPMSKRlRKuC7Ws6xn9/ICbAriE69aA90S9cizUYXm:4yM57b+mLrDRyhWVbaaZMYH6IqiaJLLPr4O/iFuGmtOEoF19fnx0E+z5N/k6+QS0zjZRZ4:RqYg7fEX5z6FQtVhHW5IOYjv9rd/y9XIBl5Xnv2MRnIcuwytir95XmMP87Hke5IgdsIJNw:3EVkMgZvckjE3O9naI7wWA5hahNO+mgH/kumWK6Wqr/LZSA7z5vIy0V59kG0oT99zUT8Ci:v9526DuJ8D7QtR8L3RuALjIhUQN3tBzJV3ZTsvcF6POpkIhdHNCTTB718ay+AYRl5Zjm3I:NaKhiidbCdDHBthrRFS81kGrDqV+5QAAAAMBAAEAAAGAU6uNLNEhvDe0KWEiuLp8K7rGjo:gAWdOlKCuBXxK59ou7WE4Hr1y7uAKHz45pLuklyTEYH1l7j542IrG9wAqFd5zZqtVg75le:8YCeE8iftCWyvFrp8Od9gjENqRfH2FHgRqpBMVTgbVWL98I1odrrWf7elOq06uR6QEyajG:tmq/tsPTC9uG9NZ//+/q8+6afvv6DFas5i+XaybnvWhrnoWHu87JwpW0mZib4MRjx4w6Jz:DxTzJGN1FI7ZpdZF/5gKQI6fvGDfXg15Hc5ETNbX38EbgyO9GWnACjrYOsS8LyLe2V1FaL:WmGCqdfdrpY1bFkBH5WipCUq39/YQFRxCmO5BwDWcEqZA2C+ki9jPmxFIVhpP/DOWtkoqX:+JkLmFsqO46ro+jYdRhs6ed8J3XK8GQOeZCYZpl9hV4czfxtl2sTa/nDMWVLUUwoLTjkvz:18Ce17Y6muO0ExwQzbcVTGyPniMZtUWAdfLLeArth6E199KuqlerwGoS6Li6xUHffhAAAA:wEyDe5Vp5oDsFweY8CWa+xpJRunrHZxal0Pa2/1qe6BASySJ8jcp+0pK4o8b/eAV6KyESc:gNFiQRRLTfAQ6ju5OT+R9T2fC3Km39cf9Vj7l+FoLGoFI+agepG2to7uGMCmKLH/06iv37:tCPlTB1Zu0joVz0t6mrxmLWqvEZTm9e4j7YJx2b6Y6PHB7PIeBUhl0IT4D9Fryf1X3LLZE:iaBJx5PclBJQ3/BgG7bIizTJxNs8wSpXGaUCja6nNU8ZeykQAAAMEAx22OhllR6qNZfuCt:DbNnXG/aXwhDSV6lTgSEvZVb3timuqpaUVjA7r9RqTl1e39AGVbCfeoAqNJERMS3fY7koM:cabBrzGvBw7gGhmmypQzjiYiPv4yLmGtpDLHxu71CbwphTSWG9OwpjI3FOXn+6O8E9E5Gj:M1vmJZ2hr7wEXCNlY+A2uKo69rDR4x8caAPQAG11GG5z6gfV0vbt2DbxfJ6aH4iEylFN7Q:EfEaqGlxJ+WGGceD5sZFYmK7/iRWE5AAAAwQDFnoTaBS5HXOfaZWEKRgycP20GV7aDXbvM:IYfF3KBhYxZlpIk89x2PIVYmo5k46cHWljDYVpmYGvPCcU1QmsArOKt2PTieqK/AHz4uzV:xGxd79KfstW1TkG64lwu05Dg1F+GgS8pAjt+NPw1BDCnO7IbscQY7JafONFDc0U4/3h8KI:uwZo30CF2aW1ViQy++SUhZXeeV2xnaI+oBWjn13V1LXbLAF2ZPU3fDWTkMUM9mJir15kVT:nDILrWCGIvBw0AAAAYcGFyc2VAaGFrdWluLmxvY2FsZG9tYWluAQID:-----END OPENSSH PRIVATE KEY-----:
```

## Running Clu

Currently I just use `../gopherbot/fetch-robot.sh clu; cd clu; ./gopherbot`; this only works because I have a `parsley42/gopherbot` fork that I use for development; see the `fetch-robot.sh` script.

In an upcoming development target, I will be able to simply create an empty `clu/` directory, place the above environment file in `clu/.env`, then run gopherbot from that directory. This will enable simple containerized deployments that won't require persistent storage, only three environment variables.

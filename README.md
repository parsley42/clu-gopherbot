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

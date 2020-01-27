# Clu
`Clu` is the Gopherbot development robot that runs wherever I need him, and tracks with ongoing development of **Gopherbot**. This repository represents almost everything I need to run Clu; the only other bits:
* clu-private (private repository) - Clu's `private/environment` - an environment file, which should be mode `0600` and closely guarded (see below for example contents)
* robot-state branch - Separate branch of this repository for backing up Clu's memories; should always remain separate from `master`, etc.

`Clu`'s custom configuration will form the basis for new robot configuration, the contents of [robot.skel](https://github.com/lnxjedi/gopherbot/tree/master/robot.skel). At times, `Clu`'s configuration may be _ahead_ of master, when it represents a development target.

## Directory Structure

This is the directory structure of a well-formed robot, created when I run `../gopherbot/fetch-robot.sh clu`:

* `clu/` - Top-level directory, not a git repo
    * `gopherbot` - symlink to `/opt/gopherbot/gopherbot`
    * `terminal.sh` - convenience script for running `clu` with the terminal connector
    * `custom/` - clone of `parsley42/clu-gopherbot`, custom configuration repository
    * `state/` - clone of `parsley42/clu-gopherbot`, `robot-state` branch, where clu saves state, e.g. memories
    * `private/` - clone of `parsley42/clu-private`, a private repository containing only `environment`
    * `Makefile` - a set of targets for running clu in a local container; see [Running Clu](#running-clu)
    * `environment` - a symlink to `private/environment` or `.env` if fetched from a `.env` file; see [Fetching Clu](#fetching-clu)

The environment file is only:
```shell
GOPHER_ENCRYPTION_KEY=<redacted>
#GOPHER_CUSTOM_REPOSITORY=https://github.com/parsley42/clu-gopherbot.git
GOPHER_CUSTOM_REPOSITORY=git@github.com:parsley42/clu-gopherbot.git
DEPLOY_KEY=-----BEGIN_OPENSSH_PRIVATE_KEY-----:b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn:NhAAAAAwEAAQAAAYEA7nXaHD1uZ9cZbI/szT74uOUwDTlihejMKKGPRcTRXbnnFkdLlcg+:fIJ09q8oIt33xvUQmmupnK65dqasQfna0jQeTFiJSdiXOjtH1kFmwiN7VyzrGu3Y8Yk2/i:tJ3By5TqsuqkoRDPxDGE6RnVrYYK3XTiVGPTNskkXctsJ2Ip9/W1rP5MY8oACgh1B8R24+:bXLwU0XzWDlrcVM9/l78AcSUEo6277cbBEwetVO5rR6dZJw+k/9Kfgyv+J4OucEXRMjgyZ:k6gz1P+TePCAntw6y9ce+UBFdXeBavHom3Pc1k5o6ywB53UHmefYiyJ0YteCfnfaQAs+Gt:ra6AW8nGosVJegPapDtT/lAKHCH0JwFp8Xj6ksMTAkWao28U62F0Amtk3a1Fm/u7ZAn5CB:1FdTn5mcwv6dYDIo6NVVeHDZvpEk7kl4q9QV8bEVtYkNMN7dHDXZE12+IFSIbfS1DvuwCf:k2cMaxMFY4tPricejk/2oTg/mPAt+pG+KPh6Gi69AAAFkEMibBpDImwaAAAAB3NzaC1yc2:EAAAGBAO512hw9bmfXGWyP7M0++LjlMA05YoXozCihj0XE0V255xZHS5XIPnyCdPavKCLd:98b1EJprqZyuuXamrEH52tI0HkxYiUnYlzo7R9ZBZsIje1cs6xrt2PGJNv4rSdwcuU6rLq:pKEQz8QxhOkZ1a2GCt104lRj0zbJJF3LbCdiKff1taz+TGPKAAoIdQfEduPm1y8FNF81g5:a3FTPf5e/AHElBKOtu+3GwRMHrVTua0enWScPpP/Sn4Mr/ieDrnBF0TI4MmZOoM9T/k3jw:gJ7cOsvXHvlARXV3gWrx6Jtz3NZOaOssAed1B5nn2IsidGLXgn532kALPhra2ugFvJxqLF:SXoD2qQ7U/5QChwh9CcBafF4+pLDEwJFmqNvFOthdAJrZN2tRZv7u2QJ+QgdRXU5+ZnML+:nWAyKOjVVXhw2b6RJO5JeKvUFfGxFbWJDTDe3Rw12RNdviBUiG30tQ77sAn5NnDGsTBWOL:T64nHo5P9qE4P5jwLfqRvij4ehouvQAAAAMBAAEAAAGBALD0QbO9HoXuSA6YyzgP59CFOu:BFWkhW1dG8+i3i/R7ZSpPsujlfTIdm49b/agBdyXYZ+4UsKcR8oGJdEu0utWRRir5K4S4s:jSSIQynKhK/CVs/9JEZqhBfRJD7+7qNpqVWokEuMBRUmyb9q5oHnnTQ5LNHvtSzLUWFGeK:AitDnDNGYdgLKbLPfrHzTq1B7Jv4fGyHJzMT6h9Yo2JIX0BHxnXR5cS4Kd1W2d8xfKFrpS:QqgbjhCTXLsnPRp4aCMOFoBqogqRFrUL7XhgcYxSim2rpRc5DhtUMN/rMi/iYZ2ECSA8kP:Si3gJEaWutwdAWtPvM5XVEbUMRo6o7/h9XZmeiTODF5aGz24PWelJQB76eZpr/jUubvS8w:94g1xaKKu1ra/9KmPRV2ouIiJy+j7Bql5XorULfT0HtYrTgMRCd9pvBB9VRZPCVJeJ0drX:0pKkc+OG69ptWmNnDB/f31vqapqZNDrm/jeeFUXIMp/aSHDxu58RqNnFr8V7QgC4iT/QAA:AMEArfJ++TXOiQoxJW2ZSTtU7uetPR+aC/enYvm2fVu59cy74UvU8Mwbz5FTwF48llI7u9:bUfEQxYf4S7kvoH9GcQAiiG3rOBDjbBL9jRjWsrxPIAlRygifDiE3KdGxwekfZxuW2kV2O:t2yz3L00XS6yV/+pvIIqo1XiWCuXZj7EaSqEkPTb7l20G7qctkqRNwFxkJd0msF+c/Uodl:I7WfN9AXQ2INUF8MAIAfaTwgfHtd/7pRGTB+96FzR7CcqhOdJFAAAAwQD/niUQ+GWTJrWu:yp46hQ1JHOAgtP1vFLYjXLdTnevPADQrbe5HX8Jmw1RbgAfBociIyTjATvXmtCBhyjGZLE:em6WdUlL8dw+XU6DYUdPiIb957J3wJwmtaecQlknxr8O/emeiMaGn2Orl1b6CNGjUM5O5m:tceOSA5u9MqlxVPGqZFKHc+dEJZkofXoxLOwdhTE8EQmChkmbtQyOLh+IvOfr4bSz18ALY:j00u+YBmf+DogCegDTpzqMxsAGmeSZw2sAAADBAO7RI5fOmviMoKMs9UicJ7w6myvwQo7z:2XA+7bpGCV5b4D0vZ8iYHmlgJwsPqf4Wcnid1nHGSYt0BXjpH0yK9+gD+H28xOo3E+s1Co:ieZXJvYtPyX7ASN2cfe6FZc4nH+2ACYkH2EFiaKc1ZvsPGRcEbrqTPbKGVNTnNpjGWVjBO:vPcoLByZo1BzxvfdNtRxNfH7GNmI7Neo75PufeNQ1tdfr9/b2hmVzrFWzIk/OUudnvhkgx:qsJQRfxLUub88IdwAAABhwYXJzZUBoYWt1aW4ubG9jYWxkb21haW4B:-----END_OPENSSH_PRIVATE_KEY-----:
```

**NOTE:** You can use 'tr' to create the above `DEPLOY_KEY=...`, e.g.:
```shell
$ cat deploy_rsa | tr ' \n' '_:'
-----BEGIN_OPENSSH_PRIVATE_KEY-----:b3Bl...W4B:-----END_OPENSSH_PRIVATE_KEY-----:
```

## Fetching Clu

The `fetch-robot.sh` script will create the above directory structure. There are two ways I can run `gopherbot/fetch-robot.sh` to fetch **Clu**:

### Fetching with `.env`
If I create an empty directory for Clu and stick the above environment in a `.env` file in that directory, I can just:
```shell
$ cd clu
$ /opt/gopherbot/fetch-robot.sh
```
... that will read the `.env` and create the directory structure [above](#directory-structure). This will work for any well-formed robot.

### Fetching during development
Because I do most of my development in a `github.com/parsley42/gopherbot` fork, and Clu's repositories are *also* parented by `github.com/parsley42`, I can fetch **Clu** with the developer shortcut mode of `fetch-robot.sh`:
```shell
$ ./gopherbot/fetch-robot.sh clu
```
This requires not only that it be run from a forked **Gopherbot** repository, but that the development robot has a private repository (e.g. `clu-private`) with it's environment file (containing the required `GOPHER_ENCRYPTION_KEY`). It's definitely the fastest way for me to get up and going, though.

## Running Clu
One of the main goals for **Gopherbot** version 2 was robot portability and first-class container support. Given the new feature set, there are several ways I can start **Clu**.

Worth noting here is how **Gopherbot** get's it's environment. The first and most obvious is from the environment exported from the parent process, as is the case when starting in a container. Second, on startup, **Gopherbot** first looks for `private/environment`, then `.env`, and loads the first one if finds, overwriting the current environment.

### I can start that robot with TWO environment variables
(... for anybody who remembers the old "Name That Tune" game show)

Since Clu's primary configuration repository is publicly available, I can start in a directory with this `.env` file:
```shell
GOPHER_ENCRYPTION_KEY=<redacted>
GOPHER_CUSTOM_REPOSITORY=https://github.com/parsley42/clu-gopherbot.git
```
Note that this is closer to how I would run **Clu** in a production container or vm, without using `fetch-robot.sh`, though I would likely use a deploy key as shown above in production.

**Method 1** Local Install
```shell
$ /opt/gopherbot/gopherbot 
2020/01/06 11:53:02 Initialized logging ...
... (clone, restart, and restore brain) ...
2020/01/06 11:53:07 Info: Robot is initialized and running
```
After which you'll have a basic directory structure with `GOPHER_CUSTOM_REPOSITORY` in `custom/`, and `GOPHER_STATE_REPOSITORY` (defined in `custom/conf/gopherbot.yaml`) restored in to `state/`.

**Method 2** Run in container with Docker
```shell
$ docker run --env-file .env lnxjedi/gopherbot:latest
2020/01/06 11:53:02 Initialized logging ...
... (clone, restart, and restore brain) ...
2020/01/06 11:53:07 Info: Robot is initialized and running
```
This accomplishes the same as above, only `custom/` and `state/` are created in the container's `/home/robot` directory.

### Using `fetch-robot`
Most of the time when I'm doing development, I just use `fetch-robot.sh` like so:
```shell
$ ./gopherbot/fetch-robot.sh clu
$ cd clu
$ ./gopherbot
2020/01/06 11:53:02 Initialized logging ...
... (normal startup, custom/ and state/ already present) ...
2020/01/06 11:53:07 Info: Robot is initialized and running
```

Since `fetch-robot.sh` also copies the sample container `Makefile` from `gopherbot/resources/docker`, I can also use e.g. `make prod`, `make dev` and `make debug` targets to start **Clu** 

# Clu

> Up-to-date with v2.4; Nov. '21

`Clu` is the Gopherbot development robot that runs wherever I need him, and tracks with ongoing development of **Gopherbot**. This repository represents almost everything I need to run Clu; the only other bits:
* Clu's `.env` file with his brain decryption key and other required env vars; this is kept in a password manager
* robot-state branch - Separate branch of this repository for backing up Clu's memories; should always remain separate from `master`, etc.
* Clu's repository has two deploy keys configured:
   * `deploy_rsa.pub` is a read-only deploy key for bootstrapping Clu in to a new running environment, such as a newly built VM or container
   * `manage_rsa.pub` is a dedicated encrypted key that Clu uses for managing his own repository; used, for instance, for backing up long-term memories to the `robot-state` branch

`Clu`'s custom configuration formed the basis for new robot configuration, the contents of [robot.skel](https://github.com/lnxjedi/gopherbot/tree/master/robot.skel).

## Directory Structure

This is the directory structure of a well-formed robot, when run directly on a host:

* `clu/` - Top-level directory, not a git repo
    * `gopherbot` - symlink to `/opt/gopherbot/gopherbot`
    * `custom/` - clone of `parsley42/clu-gopherbot`, custom configuration repository populated during bootstrapping
    * `state/` - clone of `parsley42/clu-gopherbot`, `robot-state` branch, where clu saves state, e.g. memories - also populated during bootstrapping
    * `.env` - environment variables required for Clu to bootstrap and run

The environment file is only:
```shell
GOPHER_ENCRYPTION_KEY=<redacted>
GOPHER_PROTOCOL=slack
#GOPHER_CUSTOM_REPOSITORY=https://github.com/parsley42/clu-gopherbot.git
GOPHER_CUSTOM_REPOSITORY=git@github.com:parsley42/clu-gopherbot.git
GOPHER_DEPLOY_KEY=-----BEGIN_OPENSSH_PRIVATE_KEY-----:b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn:NhAAAAAwEAAQAAAYEA7nXaHD1uZ9cZbI/szT74uOUwDTlihejMKKGPRcTRXbnnFkdLlcg+:fIJ09q8oIt33xvUQmmupnK65dqasQfna0jQeTFiJSdiXOjtH1kFmwiN7VyzrGu3Y8Yk2/i:tJ3By5TqsuqkoRDPxDGE6RnVrYYK3XTiVGPTNskkXctsJ2Ip9/W1rP5MY8oACgh1B8R24+:bXLwU0XzWDlrcVM9/l78AcSUEo6277cbBEwetVO5rR6dZJw+k/9Kfgyv+J4OucEXRMjgyZ:k6gz1P+TePCAntw6y9ce+UBFdXeBavHom3Pc1k5o6ywB53UHmefYiyJ0YteCfnfaQAs+Gt:ra6AW8nGosVJegPapDtT/lAKHCH0JwFp8Xj6ksMTAkWao28U62F0Amtk3a1Fm/u7ZAn5CB:1FdTn5mcwv6dYDIo6NVVeHDZvpEk7kl4q9QV8bEVtYkNMN7dHDXZE12+IFSIbfS1DvuwCf:k2cMaxMFY4tPricejk/2oTg/mPAt+pG+KPh6Gi69AAAFkEMibBpDImwaAAAAB3NzaC1yc2:EAAAGBAO512hw9bmfXGWyP7M0++LjlMA05YoXozCihj0XE0V255xZHS5XIPnyCdPavKCLd:98b1EJprqZyuuXamrEH52tI0HkxYiUnYlzo7R9ZBZsIje1cs6xrt2PGJNv4rSdwcuU6rLq:pKEQz8QxhOkZ1a2GCt104lRj0zbJJF3LbCdiKff1taz+TGPKAAoIdQfEduPm1y8FNF81g5:a3FTPf5e/AHElBKOtu+3GwRMHrVTua0enWScPpP/Sn4Mr/ieDrnBF0TI4MmZOoM9T/k3jw:gJ7cOsvXHvlARXV3gWrx6Jtz3NZOaOssAed1B5nn2IsidGLXgn532kALPhra2ugFvJxqLF:SXoD2qQ7U/5QChwh9CcBafF4+pLDEwJFmqNvFOthdAJrZN2tRZv7u2QJ+QgdRXU5+ZnML+:nWAyKOjVVXhw2b6RJO5JeKvUFfGxFbWJDTDe3Rw12RNdviBUiG30tQ77sAn5NnDGsTBWOL:T64nHo5P9qE4P5jwLfqRvij4ehouvQAAAAMBAAEAAAGBALD0QbO9HoXuSA6YyzgP59CFOu:BFWkhW1dG8+i3i/R7ZSpPsujlfTIdm49b/agBdyXYZ+4UsKcR8oGJdEu0utWRRir5K4S4s:jSSIQynKhK/CVs/9JEZqhBfRJD7+7qNpqVWokEuMBRUmyb9q5oHnnTQ5LNHvtSzLUWFGeK:AitDnDNGYdgLKbLPfrHzTq1B7Jv4fGyHJzMT6h9Yo2JIX0BHxnXR5cS4Kd1W2d8xfKFrpS:QqgbjhCTXLsnPRp4aCMOFoBqogqRFrUL7XhgcYxSim2rpRc5DhtUMN/rMi/iYZ2ECSA8kP:Si3gJEaWutwdAWtPvM5XVEbUMRo6o7/h9XZmeiTODF5aGz24PWelJQB76eZpr/jUubvS8w:94g1xaKKu1ra/9KmPRV2ouIiJy+j7Bql5XorULfT0HtYrTgMRCd9pvBB9VRZPCVJeJ0drX:0pKkc+OG69ptWmNnDB/f31vqapqZNDrm/jeeFUXIMp/aSHDxu58RqNnFr8V7QgC4iT/QAA:AMEArfJ++TXOiQoxJW2ZSTtU7uetPR+aC/enYvm2fVu59cy74UvU8Mwbz5FTwF48llI7u9:bUfEQxYf4S7kvoH9GcQAiiG3rOBDjbBL9jRjWsrxPIAlRygifDiE3KdGxwekfZxuW2kV2O:t2yz3L00XS6yV/+pvIIqo1XiWCuXZj7EaSqEkPTb7l20G7qctkqRNwFxkJd0msF+c/Uodl:I7WfN9AXQ2INUF8MAIAfaTwgfHtd/7pRGTB+96FzR7CcqhOdJFAAAAwQD/niUQ+GWTJrWu:yp46hQ1JHOAgtP1vFLYjXLdTnevPADQrbe5HX8Jmw1RbgAfBociIyTjATvXmtCBhyjGZLE:em6WdUlL8dw+XU6DYUdPiIb957J3wJwmtaecQlknxr8O/emeiMaGn2Orl1b6CNGjUM5O5m:tceOSA5u9MqlxVPGqZFKHc+dEJZkofXoxLOwdhTE8EQmChkmbtQyOLh+IvOfr4bSz18ALY:j00u+YBmf+DogCegDTpzqMxsAGmeSZw2sAAADBAO7RI5fOmviMoKMs9UicJ7w6myvwQo7z:2XA+7bpGCV5b4D0vZ8iYHmlgJwsPqf4Wcnid1nHGSYt0BXjpH0yK9+gD+H28xOo3E+s1Co:ieZXJvYtPyX7ASN2cfe6FZc4nH+2ACYkH2EFiaKc1ZvsPGRcEbrqTPbKGVNTnNpjGWVjBO:vPcoLByZo1BzxvfdNtRxNfH7GNmI7Neo75PufeNQ1tdfr9/b2hmVzrFWzIk/OUudnvhkgx:qsJQRfxLUub88IdwAAABhwYXJzZUBoYWt1aW4ubG9jYWxkb21haW4B:-----END_OPENSSH_PRIVATE_KEY-----:
```

**NOTE:** You can use 'tr' to create the above `GOPHER_DEPLOY_KEY=...`, e.g.:
```shell
$ cat deploy_rsa | tr ' \n' '_:'
-----BEGIN_OPENSSH_PRIVATE_KEY-----:b3Bl...W4B:-----END_OPENSSH_PRIVATE_KEY-----:
```

## Running Clu
One of the main goals for **Gopherbot** version 2 was robot portability and first-class container support. Given the new feature set, there are a couple ways I can start **Clu**.

Worth noting here is how **Gopherbot** get's it's environment. The first and most obvious is from the environment exported from the parent process, as is the case when starting in a container. Second, on startup, **Gopherbot** looks for `.env`, overwriting the current environment.

### Using the `.env` file

This is the most common way I run **Clu** when doing development on **Gopherbot**. I create an empty directory (normally just called 'clu'), and drop a `.env` file in it with the contents from the password manager. Then I symlink the `gopherbot` binary there, and run `./gopherbot`. The **bootstrap** plugin does the rest.

### Using `gb-dev-profile` and `gb-start-dev`

This is how I start **Clu** when I'm actually working on Clu's configuration - the way a **Gopherbot** user would normally configure and write extensions for their robot.

* The `gb-dev-profile` script generates a custom `clu.env` file that includes an encoded version of my local ssh private key
```shell
$ gb-dev-profile clu/.env > clu.env
```
* The `gb-start-dev` script starts the [gopherbot-theia](https://quay.io/repository/lnxjedi/gopherbot-theia) container. Once the robot has started, I tell Clu `!start-theia`, then connect to [localhost:3000](http://localhost:3000).
Hello, world!

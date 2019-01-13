# Clu
`Clu` is the development instance of Gopherbot that runs on my Chromebook. This repository represents the bulk of Clu's custom configuration; the rest is documented in this README.

`Clu` was used to create robot.skel for `makeRobot.sh`.

## Robot Directory structure and Private Environment
**Gopherbot** version 2 can read credentials and secrets from a `.env` file in the working directory. When configured for running setuid (not root; normally 'bin'), the `.env` file should be `bin:root` / `0400`.

Example `.env`:
```env
# .env private environment file - stuff that should never be in a git repo unencrypted
GOPHER_SLACK_TOKEN=xoxb-thisClearlyIsn'tMyToken
GOPHER_ENCRYPTION_KEY=likewise,notEven32chars
# Repository URL defined here so Clu can clone his own custom config when running in a docker container
GOPHER_CUSTOM_REPOSITORY=https://github.com/parsley42/clu-gopherbot.git
# This let's the robot know who it can trust prior to cloning the configuration repository (where a longer list of admins can be provided)
GOPHER_ADMIN=parsley
```

## Secrets stored in the Brain
Once the robot is up and running, the first thing it normally needs is it's own **ssh** keypair; this is required for running in a container. To provide a strong passphrase for the ssh private key, open a private chat with the robot and give this command:
`store task secret ssh-init BOT_SSH_PHRASE=SuperRipeLongTomatoPassHorsePhrase`

## Bootstrapping the Docker Container

1. `make` creates a local `clu` image
2. `make dev` starts the container in the foreground
3. To load configuration from the custom repository, send the robot a DM: `update`

## Upgrading a Dockerized Install
1. Stop and remove the current container, leaving the `home` volume
2. `make` to create the updated `clu` image
3. `make dev` or `make prod` to start a new container from the image

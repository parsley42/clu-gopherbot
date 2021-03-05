#!/bin/bash
# clu-docker-dev.sh - start the clu dev environment; just tell Clu to "!quit" when done.
docker run -p 127.0.0.1:3000:3000 --name clu-dev --env-file .env quay.io/lnxjedi/gopherbot-theia:latest

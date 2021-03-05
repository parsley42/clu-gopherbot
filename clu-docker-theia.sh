#!/bin/bash
# clu-docker-dev.sh - start clu with gopherbot-theia; just tell Clu to "!quit" when done.
docker run -p 127.0.0.1:3000:3000 --name clu-theia --env-file .env quay.io/lnxjedi/gopherbot-theia:latest

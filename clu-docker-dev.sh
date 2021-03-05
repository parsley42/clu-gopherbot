#!/bin/bash
# clu-docker-dev.sh - start clu with gopherbot-dev
docker run -p 127.0.0.1:3000:3000 --name clu-dev --rm --env-file .env quay.io/lnxjedi/gopherbot-dev:latest

# Makefile with examples for running gopherbot

.PHONY: image dev-amazon prod-amazon clean allclean

image:
	docker image build -t clu .

# Example dev containers bind mounts the local install dir for running
# gopherbot in a container.
dev:
	docker container run --name clu \
	  --mount 'source=gopherbot-context,target=/var/lib/gopherbot' \
	  clu

# Example prod container; note that the robot home directory is a
# persistent volume. You might want to use a different log driver for
# your environment, e.g. journald.
prod:
	docker container run --name clu --restart unless-stopped -d \
	  --log-driver journald --log-opt tag="clu" \
	  --mount 'source=gopherbot-context,target=/var/lib/gopherbot' \
	  clu

clean:
	docker container stop clu || :
	docker container rm clu || :

allclean: clean
	docker image rm clu || :

PROJECT-NAME=obelisk-template

HEROKU-PROJECT=${PROJECT-NAME}
HEROKU-IMAGE-NAME=${PROJECT-NAME}-heroku
HEROKU-IMAGE-TAG=latest

DEV-IMAGE-TAG=latest
DEV-IMAGE-NAME=obelisk
DEV-PORT=8000

NIX-IMAGE=jafonso/nix:2.3.7


# ---- aux rules -----


# Shell aux rules

obelisk-template/ids/:
	mkdir obelisk-template/ids

obelisk-template/ids/nix-volume: obelisk-template/ids/
	# creates a volume to share the nix store accross nix containers avoiding having to redownload packages
	if ! (docker volume ls | grep -q " nix$$"); \
	then \
		docker run --rm --mount source=nix,target=/nix-target ${NIX-IMAGE} /bin/bash -c "cp -r /nix/* /nix-target"; \
	fi
	touch obelisk-template/ids/nix-volume


remove-nix-volume:
	if docker volume ls | grep -q " nix$$"; \
	then \
		docker volume rm nix; \
	fi; \
	rm -f obelisk-template/ids/nix-volume;

obelisk-template/ids/dev-image: obelisk-template/ids/
	if ! (docker images | grep -q "^${DEV-IMAGE-NAME}\b"); \
	then \
		docker build -t ${DEV-IMAGE-NAME}:${DEV-IMAGE-TAG} -f obelisk-template/DevDockerfile obelisk-template/; \
	fi
	touch obelisk-template/ids/dev-image

remove-dev-image:
	docker image rm ${DEV-IMAGE-NAME}:${DEV-IMAGE-TAG};
	rm -f obelisk-template/ids/dev-image;

obelisk-template/ids/dev-container-id: obelisk-template/ids/ obelisk-template/ids/nix-volume obelisk-template/ids/dev-image
	docker create \
		-v nix:/nix \
		-v $$(pwd):/app \
		-w=/app \
		-ti \
		-p ${DEV-PORT}:${DEV-PORT} \
		${DEV-IMAGE-NAME}:${DEV-IMAGE-TAG} \
		/bin/bash -c \
			"nix-shell obelisk-template/obeliskShell.nix" \
	> obelisk-template/ids/dev-container-id;


remove-dev-container:
	docker container rm $(shell cat obelisk-template/ids/dev-container-id);
	rm obelisk-template/ids/dev-container-id;

# Heroku aux rules

obelisk-template/ids/heroku-image.tar.gz: obelisk-template/ids/ obelisk-template/ids/nix-volume
	docker run --rm -ti -v nix:/nix -v $(shell pwd):/app -w=/app ${NIX-IMAGE} /bin/bash -c \
	 "rm -f obelisk-template/ids/heroku-image.tar.gz && \
	  nix-build \
			--arg heroku-image-name '\"${HEROKU-IMAGE-NAME}\"' \
			--arg heroku-image-tag '\"${HEROKU-IMAGE-TAG}\"' \
			-o obelisk-template/ids/prod-image \
			-A heroku-image \
			obelisk-template/main.nix && \
		cp obelisk-template/ids/prod-image obelisk-template/ids/heroku-image.tar.gz && \
		rm obelisk-template/ids/prod-image"


deploy-local-heroku: obelisk-template/ids/heroku-image.tar.gz
	docker load -i obelisk-template/ids/heroku-image.tar.gz
	docker run --rm -ti -p ${DEV-PORT}:${DEV-PORT} ${PROJECT-NAME}-heroku:latest

remove-heroku-image:
	docker image rm ${HEROKU-IMAGE-NAME}:${HEROKU-IMAGE-TAG}


# TODO: make this work
clean-all: remove-dev-image remove-nix-volume remove-heroku-image

remove-obelisk-files:
	rm -rf .obelisk backend common config frontend static .gitignore cabal.project default.nix result

obelisk-template/ids/exe:
	docker run --rm -ti -v nix:/nix -v $(shell pwd):/app -w=/app ${NIX-IMAGE} /bin/bash -c \
		"nix-build -A exe -o obelisk-template/ids/exe"

# ---- Main rules ----

# Start the development shell
shell: obelisk-template/ids/dev-container-id
	docker start -ai $(shell cat obelisk-template/ids/dev-container-id);

heroku-deploy: obelisk-template/ids/exe obelisk-template/ids/heroku-image.tar.gz
	docker load -i obelisk-template/ids/heroku-image.tar.gz
	docker image remove --force registry.heroku.com/${HEROKU-PROJECT}/web
	docker tag ${HEROKU-IMAGE-NAME}:${HEROKU-IMAGE-TAG} registry.heroku.com/${HEROKU-PROJECT}/web
	docker push registry.heroku.com/${HEROKU-PROJECT}/web:latest
	heroku container:release web -a ${HEROKU-PROJECT}



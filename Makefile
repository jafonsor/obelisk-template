DEV-IMAGE-TAG=latest
DEV-IMAGE-NAME=obelisk
DEV-PORT=8000

setup/ids/nix-volume:
	# creates a volume to share the nix store accross nix containers avoiding having to redownload packages
	if ! (docker volume ls | grep -q " nix$$"); \
	then \
		docker run --rm --mount source=nix,target=/nix-target jafonso/nix:2.3.7 /bin/bash -c "cp -r /nix/* /nix-target"; \
	fi
	touch setup/ids/nix-volume


remove-nix-volume:
	if docker volume ls | grep -q " nix$$"; \
	then \
		docker volume rm nix; \
	fi; \
	rm obelisk-template/ids/nix-volume;

obelisk-template/ids/dev-image:
	if ! (docker images | grep -q "^${DEV-IMAGE-NAME}\b"); \
	then \
		docker build -t ${DEV-IMAGE-NAME}:${DEV-IMAGE-TAG} -f obelisk-template/DevDockerfile obelisk-template/; \
	fi
	touch obelisk-template/ids/dev-image

remove-dev-image:
	docker images rm ${DEV-IMAGE-NAME}:${DEV-IMAGE-TAG};
	rm obelisk-template/ids/dev-image;

obelisk-template/ids/dev-container-id: obelisk-template/ids/nix-volume obelisk-template/ids/dev-image
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

shell: obelisk-template/ids/dev-container-id
	docker start -ai $(shell cat obelisk-template/ids/dev-container-id);


test-shell: remove-dev-container shell
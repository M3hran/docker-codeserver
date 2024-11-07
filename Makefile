export IMG_VERSION = 0.2.1
export IMG_VENDOR = m3hran
export IMG_AUTHORS = m3hran@gmail.com
export IMG_URL = https://github.com/m3hran/docker-codeserver
export IMG_TITLE = m3hran/code-server
export IMG_DESC = vscode development container
export CONTAINER_NAME = code-server

.PHONY: all build test tag_latest release install clean

all: clean build install

build: 
	envsubst < Dockerfile | docker build --build-arg BUILD_DATE="$$(date --utc +%FT%TZ)" -t $(IMG_TITLE):$(IMG_VERSION) . -f -

clean: 
	docker rm -vf $(CONTAINER_NAME) && docker image rm $(IMG_TITLE):$(IMG_VERSION) 
	
install:
	docker run -d \
		--name $(CONTAINER_NAME) \
  		-e PUID=1000 \
		-e PGID=1000 \
		-e TZ=America\New_York \
		-e PASSWORD=password `#optional` \
		-e HASHED_PASSWORD= `#optional` \
		-e SUDO_PASSWORD=password `#optional` \
		-e SUDO_PASSWORD_HASH= `#optional` \
		-e PROXY_DOMAIN= `#optional` \
		-e DEFAULT_WORKSPACE=/config/workspace `#optional` \
		-p 8443:8443 \
		-v ./code-server/config:/config \
		--restart unless-stopped \
		$(IMG_TITLE):$(IMG_VERSION)

tag_latest:
	docker tag $(IMG_TITLE):$(IMG_VERSION) $(IMG_TITLE):latest

release: tag_latest
	@if ! docker images $(IMG_TITLE) | awk '{ print $$2 }' | grep -q -F $(IMG_VERSION); then echo "$(IMG_TITLE) version $(IMG_VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(IMG_TITLE)
	@echo "*** Don't forget to create a tag. git tag rel-$(IMG_VERSION) && git push origin rel-$(IMG_VERSION)"

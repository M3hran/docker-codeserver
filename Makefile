include build.env

.PHONY: all build test tag_latest release install clean

all: clean build install

build: 
	envsubst < Dockerfile | docker build --build-arg BUILD_DATE="$$(date --utc +%FT%TZ)" -t $(IMG_TITLE):$(IMG_VERSION) . -f -

clean: 
	rm -rf $(CONTAINER_NAME) && docker rm -vf $(CONTAINER_NAME) && docker image rm $(IMG_TITLE):$(IMG_VERSION) 
	
install:
	docker compose up -d

tag_latest:
	docker tag $(IMG_TITLE):$(IMG_VERSION) $(IMG_TITLE):latest

release: tag_latest
	@if ! docker images $(IMG_TITLE) | awk '{ print $$2 }' | grep -q -F $(IMG_VERSION); then echo "$(IMG_TITLE) version $(IMG_VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(IMG_TITLE)
	@echo "*** Don't forget to create a tag. git tag rel-$(IMG_VERSION) && git push origin rel-$(IMG_VERSION)"

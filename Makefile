
include build.env

# Version format: YY.MM.DD.BUILD
# Example: 26.10.20.0

BUILD_DATE_VERSION := $(shell date -u +%y.%-m.%-d)

CURRENT_VERSION := $(IMG_VERSION)
CURRENT_DATE := $(shell echo "$(CURRENT_VERSION)" | cut -d. -f1-3)
CURRENT_BUILD := $(shell echo "$(CURRENT_VERSION)" | cut -d. -f4)

ifeq ($(CURRENT_DATE),$(BUILD_DATE_VERSION))
    NEXT_BUILD := $(shell expr $(CURRENT_BUILD) + 1)
else
    NEXT_BUILD := 0
endif

NEW_DOCKER_TAG := $(BUILD_DATE_VERSION).$(NEXT_BUILD)

SOURCE_IMAGE ?= linuxserver/code-server:latest
DOCKER_PLATFORM ?= linux/amd64

.PHONY: all build test tag_latest release install clean

all: clean build install

build:
	@set -eu; \
	echo "Building $(IMG_TITLE):$(NEW_DOCKER_TAG)"; \
	SOURCE_IMAGE="$(SOURCE_IMAGE)" envsubst < Dockerfile | \
	docker build \
		--pull \
		--platform $(DOCKER_PLATFORM) \
		--build-arg BUILD_DATE="$$(date -u +%FT%TZ)" \
		-t $(IMG_TITLE):$(NEW_DOCKER_TAG) \
		-f - .; \
	sed -i 's/^export IMG_VERSION=.*/export IMG_VERSION=$(NEW_DOCKER_TAG)/' build.env; \
	echo "Build successful: $(IMG_TITLE):$(NEW_DOCKER_TAG)"

test:
	@docker image inspect $(IMG_TITLE):$(IMG_VERSION) > /dev/null
	@echo "Image exists: $(IMG_TITLE):$(IMG_VERSION)"

tag_latest: test
	docker tag $(IMG_TITLE):$(IMG_VERSION) $(IMG_TITLE):latest

release: tag_latest
	@set -eu; \
	docker push $(IMG_TITLE):$(IMG_VERSION); \
	docker push $(IMG_TITLE):latest; \
	echo "Published $(IMG_TITLE):$(IMG_VERSION)"

install:
	docker compose up -d

clean:
	@if docker ps -a --format '{{.Names}}' | \
		grep -Fxq '$(CONTAINER_NAME)'; then \
		docker rm -f $(CONTAINER_NAME); \
	fi

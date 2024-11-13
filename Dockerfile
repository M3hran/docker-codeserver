FROM linuxserver/code-server

RUN apt update && \
    apt install -y --no-install-recommends \
	git \
	golang \
	ca-certificates \ 
	curl \
	make \
    gettext 

RUN curl -fsSL https://get.docker.com | sh > /dev/null 2>&1 

ARG BUILD_DATE
LABEL org.opencontainers.image.created="${${no_value}BUILD_DATE}"
LABEL org.opencontainers.image.version="$IMG_VERSION"
LABEL org.opencontainers.image.title="$IMG_TITLE"
LABEL org.opencontainers.image.description="$IMG_DESC"
LABEL org.opencontainers.image.authors="$IMG_AUTHORS"
LABEL org.opencontainers.image.vendor="$IMG_VENDOR"
LABEL org.opencontainers.image.url="$IMG_URL"


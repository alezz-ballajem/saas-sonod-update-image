FROM alpine:latest

# Install dependencies
RUN set -x \
  && apk add --no-cache \
    ansible \
    openssh-client \
    rsync \
    git \
    curl \
    jq \
    bash

# Set up SSH directory and permissions
RUN mkdir -p /root/.ssh \
    && touch /root/.ssh/known_hosts \
    && chmod 700 /root/.ssh \
    && chmod 600 /root/.ssh/known_hosts

# Set working directory
WORKDIR /app

# Copy SSH configuration
COPY --chmod=644 ssh_config /root/.ssh/config

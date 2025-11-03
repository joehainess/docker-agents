FROM ubuntu:noble

LABEL name=docker-builder
LABEL version=0.0.1

SHELL [ "/bin/bash", "-c" ]

RUN apt-get update \
  && apt-get -y install curl git jq

ARG NODE_VERSION=22

# Remove default user with uid:gid 1000
RUN deluser --remove-home ubuntu

# Create build user with uid:gid 1000
RUN mkdir build \
  && groupadd -g 1000 build \
  && useradd -m -d /build -u 1000 -g 1000 build \
  && chown -R build:build /build \
  && chmod -R 0755 /build

USER build:build
WORKDIR /build

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV .bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> .bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install $NODE_VERSION

ENTRYPOINT [ "/bin/bash" ]
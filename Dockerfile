ARG ARCH=linux/amd64
FROM --platform=${ARCH} ubuntu:noble

SHELL [ "/bin/bash", "-c" ]

LABEL name=npm-builder
LABEL version=0.0.1

# Install required packages
RUN apt-get update \
  && apt-get -y install curl git jq

# Remove user ubuntu
RUN userdel ubuntu
# Create build user
RUN mkdir -p /build \
    && chown -R 1000:1000 /build \
    && useradd -u 1000 -d /build build

USER build
WORKDIR /build

# Setup NVM & put node bin on PATH
ARG NODE_VERSION=v22.21.1
ENV HOME=/build
ENV NVM_DIR=${HOME}/.nvm
ENV NVM_BIN=${NVM_DIR}/versions/node/${NODE_VERSION}/bin
ENV PATH=${PATH}:${NVM_BIN}

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV .bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> .bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install $NODE_VERSION

CMD [ "/bin/bash" ]
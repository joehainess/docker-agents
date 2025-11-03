ARG ARCH=linux/amd64
FROM --platform=${ARCH} ubuntu:noble

SHELL [ "/bin/bash", "-c" ]

LABEL name=docker-builder
LABEL version=1.0.1

# Install required packages
RUN apt-get update \
  && apt-get -y install curl git jq

# Add Docker's official GPG key:
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc
# Add the Docker repository to Apt sources:
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
# Install Docker
RUN apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Set docker gid to 500
RUN sed -i 's/^docker:x:.*:/docker:x:500:/' /etc/group

# Remove user ubuntu
RUN userdel ubuntu
# Create build user
RUN mkdir -p /build \
    && chown -R 1000:1000 /build \
    && useradd -u 1000 -d /build build

# Add user to docker group
RUN usermod -a -G docker build

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
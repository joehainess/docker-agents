ARG ARCH=linux/amd64
FROM --platform=${ARCH} debian:trixie

SHELL [ "/bin/bash", "-c" ]

LABEL name=ansible-control-node
LABEL version=0.0.2

# Install required packages
RUN apt update \
  && apt -y install openssh-client python3 pipx \
  && apt clean

# Install ansible globally via pipx
RUN pipx install --global ansible-core ansible-runner

# Create ansible user
RUN mkdir -p /ansible \
    && chown -R 1000:1000 /ansible \
    && useradd -u 1000 -d /ansible ansible

USER ansible
WORKDIR /ansible

CMD [ "/bin/bash" ]
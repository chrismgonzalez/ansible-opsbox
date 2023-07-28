FROM --platform=$BUILDPLATFORM python:3.11-bookworm as base

LABEL maintainer="@cmgonza89"
ENV DEBIAN_FRONTEND noninteractive
ENV TF_VERSION 1.5.0
ENV PACKER_VERSION 1.9.2

ARG TARGETOS
ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apt-transport-https \
    build-essential \
    libnss3-dev \
    curl \
    git \
    wget \
    jq \
    openssh-client \
    sshpass \
    unzip \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

COPY requirements.txt /tmp/pip-tmp/

RUN pip3 install --upgrade pip \
    && pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
    && ansible-galaxy collection install community.general \
    && rm -rf /tmp/pip-tmp

RUN curl -O https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
    && unzip terraform_${TF_VERSION}_${TARGETOS}_${TARGETARCH} -d /usr/bin \
    && rm -f terraform_${TF_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
    && chmod +x /usr/bin/terraform \
    && curl -O https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
    && unzip packer_${PACKER_VERSION}_${TARGETOS}_${TARGETARCH}.zip -d /usr/bin \
    && rm -f packer_${PACKER_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
    && chmod +x /usr/bin/packer

CMD    ["/bin/bash"]
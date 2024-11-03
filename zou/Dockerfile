ARG PY_V=3.12

FROM python:${PY_V}-slim
#FROM ubuntu:jammy

#ENV DEBIAN_FRONTEND=noninteractive

ARG PY_V
# https://github.com/cgwire/zou/tags
ARG ZOU_VERSION=0.19.62
ARG PREVIEW_FOLDER=/opt/zou/previews
ARG TMP_DIR=/opt/zou/tmp

USER root

# Dependencies
# install third-party software - Install Python 3
RUN apt-get update && \
    apt-get install --no-install-recommends -q -y \
    build-essential \
    ffmpeg \ 
    bzip2 \
    gcc \
    xmlsec1 \
    software-properties-common \
    postgresql-client && \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Get sources
# Install Zou and its dependencies
RUN python3 -m venv /opt/zou/env && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir zou==${ZOU_VERSION}

# Zou job queue
RUN /opt/zou/zouenv/bin/python -m pip install boto3 \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/*

# Create a folder to store the previews
RUN mkdir ${PREVIEW_FOLDER} && \
    chown -R zou:www-data ${PREVIEW_FOLDER}

# Create a folder to store the temp files
RUN mkdir ${TMP_DIR} && \
    chown -R zou:www-data ${TMP_DIR}

WORKDIR /opt/zou

COPY --chmod=0755 ./init_zou.sh /opt/zou/
COPY --chmod=0755 ./upgrade_zou.sh /opt/zou/
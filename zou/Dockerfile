ARG PY_V=3.11

FROM python:${PY_V}-slim as builder

ARG PY_V
# https://github.com/cgwire/zou/tags
ARG ZOU_VERSION=0.19.62

USER root

# Dependencies
RUN apt update &&\
    apt install -y --no-install-recommends \
    make \
    python3-dev \
    gcc \
    g++ \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/*

# Install Zou and its dependencies
RUN pip install --no-cache-dir --upgrade pip wheel setuptools \
    && pip install --no-cache-dir zou==${ZOU_VERSION}

FROM python:${PY_V}-slim

ARG PY_V

USER root

# Dependencies
RUN apt update &&\
    apt install -y --no-install-recommends \
    ffmpeg \
    bzip2 \
    postgresql-client \
    xmlsec1 \
    && apt autoclean \
    && rm -rf /var/lib/apt/lists/*

# Copy dependencies from builder
COPY --from=builder /usr/local/lib/python${PY_V} /usr/local/lib/python${PY_V}
COPY --from=builder /usr/local/bin /usr/local/bin

# Set workdir zou_folder
ENV ZOU_FOLDER=/usr/local/lib/python${PY_V}/site-packages/zou
WORKDIR ${ZOU_FOLDER}

# Copy init_zou and upgrade_zou .sh to zou_folder
COPY init_zou.sh /init_zou.sh
RUN chmod +x /init_zou.sh
COPY upgrade_zou.sh /upgrade_zou.sh
RUN chmod +x /upgrade_zou.sh
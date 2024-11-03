FROM nginx:alpine

# https://github.com/cgwire/kitsu/tags
ARG KITSU_VERSION=0.19.71

USER root

RUN apk add --no-cache --virtual .build-deps git

RUN mkdir -p /opt/kitsu/dist && \
    wget -q -O /tmp/kitsu.tgz https://github.com/cgwire/kitsu/releases/download/v${KITSU_VERSION}/kitsu-${KITSU_VERSION}.tgz && \
    tar xvzf /tmp/kitsu.tgz -C /opt/zou/kitsu && \
    rm /tmp/kitsu.tgz

WORKDIR /opt/zou

COPY ./nginx.conf /etc/nginx/nginx.conf

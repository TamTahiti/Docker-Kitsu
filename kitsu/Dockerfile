
FROM nginx:alpine as buildstage

# https://github.com/cgwire/kitsu/tags
ARG KITSU_VERSION=0.19.71

USER root

# Set workdir
WORKDIR /opt/kitsu

RUN apk add --no-cache --virtual .build-deps git

# Retrieving kitsu built version
RUN git clone -b "${KITSU_VERSION}-build" --single-branch --depth 1 https://github.com/cgwire/kitsu \
    && apk --purge del .build-deps


FROM nginx:alpine as squashstage

# Copy dependencies from builder
COPY --from=buildstage / /

# Copy Nginx configuration
COPY ./nginx.conf /etc/nginx/nginx.conf
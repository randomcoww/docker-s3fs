## based on haproxy dockerfile
## https://github.com/docker-library/haproxy/blob/master/1.8/alpine/Dockerfile

FROM alpine:edge

ENV S3FS_VERSION 1.84

RUN set -x \
  \
  && apk add --no-cache --virtual .build-deps \
    alpine-sdk \
    automake \
    autoconf \
    libxml2-dev \
    fuse-dev \
    curl-dev \
  \
## build
  && cd / \
  && wget -O s3fs.tar.gz https://github.com/s3fs-fuse/s3fs-fuse/archive/v${S3FS_VERSION}.tar.gz \
  && mkdir -p /usr/src/s3fs \
  && tar xf s3fs.tar.gz --strip-components=1 -C /usr/src/s3fs \
  && rm s3fs.tar.gz \
  && cd /usr/src/s3fs \
  \
  && autoreconf --install \
  && CXXFLAGS='-Os' ./configure \
    --prefix=/usr/local \
  && make -j "$(getconf _NPROCESSORS_ONLN)" \
  && make install \
  \
## cleanup
  && cd / \
  && rm -rf /usr/src \
  \
  && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )" \
  && apk add --virtual .s3fs-rundeps $runDeps \
  && apk del .build-deps


ENTRYPOINT ["s3fs", "-f"]

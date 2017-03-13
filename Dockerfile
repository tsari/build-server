# create a container as "deploy" replacement
# it's a container to build the web app without changing the host
# "containerize all the things"

FROM tsari/jessie-php-fpm
MAINTAINER Tibor Sári <tiborsari@gmx.de>

# php
ENV DEBIAN_FRONTEND noninteractive
ENV NODE_VERSION 6.9.4
ENV NPM_VERSION 3.10.10
ENV COMPOSER_VERSION 1.3.0

RUN \
    apt-get update -qqy && \
    apt-get install --no-install-recommends -qqy --force-yes \
        apt-transport-https \
        apt-utils \
        autoconf \
        automake \
        bzip2 \
        file \
        g++ \
        gcc \
        imagemagick \
        libbz2-dev \
        libc6-dev \
        libcurl4-openssl-dev \
        libevent-dev \
        libffi-dev \
        libgeoip-dev \
        libglib2.0-dev \
        libjpeg-dev \
        liblzma-dev \
        libmagickcore-dev \
        libmagickwand-dev \
        libmysqlclient-dev \
        libncurses-dev \
        libpng-dev \
        libpq-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libwebp-dev \
        libxml2-dev \
        libxslt-dev \
        libyaml-dev \
        make \
        patch \
        xz-utils \
        zlib1g-dev \
        openssh-client \
        postgresql-client \
        git \
        rsync \
        subversion \
        sudo \
        unzip

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

# install specified node, npm and node-gyp
RUN rm -rf /usr/local/bin/npm
RUN rm -rf /usr/local/lib/node_modules
RUN rm -rf ~/.npm

RUN curl -sSLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -sSLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc

# install yarn
RUN curl -sS "https://dl.yarnpkg.com/debian/pubkey.gpg" | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN \
    apt-get update -qqy && \
    apt-get install --no-install-recommends -qqy --force-yes \
        yarn \
    && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g node-gyp npm@$NPM_VERSION

# fix broken npm installation after npm installation (missing /usr/local/lib/node_modules/npm/node_modules) ...
RUN cd /usr/local/lib/node_modules/npm \
    && yarn install

# install composer
RUN curl -sS --insecure -o /usr/local/bin/composer https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar
RUN chmod +x /usr/local/bin/composer

# copy build script
COPY build.sh /usr/local/bin/build-application
RUN chmod +x /usr/local/bin/build-application

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set up the application directory
VOLUME ["/app"]
WORKDIR /app

# Set up the command arguments
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD build-application
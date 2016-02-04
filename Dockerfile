# create a container as "deploy" replacement
# it's a container to build the web app without changing the host
# "containerize all the things"

FROM tsari/wheezy-apache-php-xdebug:1.5.0
MAINTAINER Tibor Sári <tiborsari@gmx.de>

# php
ENV DEBIAN_FRONTEND noninteractive

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

RUN \
    apt-get update -qqy && \
    apt-get install --no-install-recommends -qqy \
        openssh-client \
        mysql-client \
        git \
        nodejs \
    && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g npm@latest

# add user
RUN useradd -ms /bin/bash build
RUN mkdir /home/build/bin

# install composer
RUN curl -sS --insecure https://getcomposer.org/installer | php -- --install-dir=/home/build/bin --filename=composer

# copy build script
COPY build.sh /home/build/bin/build-application
RUN chmod +x /home/build/bin/build-application

# change user to prevent file creation from "root" on the host file system
RUN chmod -R 777 /home/build && chown -R build.build /home/build
USER build
ENV HOME /home/build

ENV PATH=/home/build/bin/:$PATH

# Set up the application directory
VOLUME ["/app"]
WORKDIR /app

CMD build-application
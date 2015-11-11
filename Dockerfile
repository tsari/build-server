# create a container as "deploy" replacement
# it's a container to build the web app without changing the host
# "containerize all the things"

FROM node:4.1.1
MAINTAINER Tibor Sári <tiborsari@gmx.de>

# node stuff
RUN npm install -g bower
RUN npm install -g grunt-cli
RUN npm install -g gulp

# php
ENV DEBIAN_FRONTEND noninteractive
RUN \
    apt-get update -qqy && \
    apt-get install --no-install-recommends -qqy \
        openssh-client \
        php5-cli \
        php5-mysql \
        php5-curl \
        php5-mcrypt \
        libssh2-php \
        mysql-client \
    && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add user
RUN useradd -ms /bin/bash build
RUN mkdir /home/build/bin

# install composer
RUN curl -sS --insecure https://getcomposer.org/installer | php -- --install-dir=/home/build/bin --filename=composer

# change user to prevent file creation from "root" on the host file system
RUN chown -R build.build /home/build
USER build
ENV HOME /home/build

ENV PATH=/home/build/bin/:$PATH

# Set up the application directory
VOLUME ["/app"]
WORKDIR /app

CMD [ "cd build/ && composer update -o && vendor/bin/robo install" ]
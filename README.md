## build-server
Docker container for building our web app without the need of modifying the host.

#### Usage
Run the container from your project root directory.

    docker run -it --rm --env="USER" --env="UID=$(id -u)" --env="GID=$(id -g)" -v $PWD:/app tsari/build-server

This runs the container with the common settings. It requires a ```build/``` directory in your project root.
From the build dir it runs a ```robo install```.

You can run different build commands by providing an alternative command on startup.
php, node, npm and composer are available.

    #!/bin/bash
    docker run -it --rm \
        --env="USER" \
        --env="UID=$(id -u)" \
        --env="GID=$(id -g)" \
        -v $PWD:/app \
    tsari/php YOUR_COMMAND "$@"

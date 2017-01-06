## build-server
Docker container for building our web app without the need of modifying the host.

#### Usage
Run the container from your project root directory.

    #!/bin/bash
    docker run -it --rm \
        -e "USER" \
        -e "UID=$(id -u)" \
        -e "GID=$(id -g)" \
        -e "HOME" \
        -v /home/$USER:/home/$USER \
        -v /etc/machine-id:/etc-machine-id:ro \
        -v /etc/localtime:/etc/localtime:ro \
        -v $PWD:/app \
    tsari/build-server


This runs the container with the common settings. It requires a ```build/``` directory in your project root.
From the build dir it runs a ```robo install```.

You can run different build commands by providing an alternative command on startup.

    #!/bin/bash
        docker run -it --rm \
            -e "USER" \
            -e "UID=$(id -u)" \
            -e "GID=$(id -g)" \
            -e "HOME" \
            -v /home/$USER:/home/$USER \
            -v /etc/machine-id:/etc-machine-id:ro \
            -v /etc/localtime:/etc/localtime:ro \
            -v $PWD:/app \
        tsari/build-server YOUR_COMMAND
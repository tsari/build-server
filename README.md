## build-server
Docker container for building our web app without the need of modifying the host.

#### Usage
Run the container from your project root directory.

    docker run -rm -v $PWD:/app tsari/build-server

This runs the container with the common settings. It requires a ```build/``` directory in your project root.
From the build dir it runs a ```robo install```.

You can run diffenrent build commands by providing an alternative command on startup.

    docker run -rm -v $PWD:/app tsari/build-server YOUR_COMMAND

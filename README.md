# socat

Tiny image containing only socat and it's libraries. Quoting from the projects
[README](http://www.dest-unreach.org/socat/doc/README):

> socat is a relay for bidirectional data transfer between two independent data
> channels. Each of these data channels may be a file, pipe, device (serial line
> etc. or a pseudo terminal), a socket (UNIX, IP4, IP6 - raw, UDP, TCP), an
> SSL socket, proxy CONNECT connection, a file descriptor (stdin etc.), the GNU
> line editor (readline), a program, or a combination of two of these. 
> These modes include generation of "listening" sockets, named pipes, and pseudo
> terminals.

## Security

This image was built to run as user ID 255. To support binding to ports below
1024, the binary had it's extended attributes (xattr) set to allow it to use the
`CAP_NET_BIND_SERVICE` capability, otherwise only the root user could do this.

If your filesystem doesn't support extended attributes, you can include the flag
`--cap-add NET_BIND_SERVICE` in your the `docker run` command, if you intend to
expose a port below 1024.

If your container environment doesn't let you use capabilities, you will have
to stick to exposing ports above 1024.

Please consider running the image as read-only for an additional layer of
protection.

## Use cases for socat in a container

### Expose a tcp socket for accessing docker API on MacOS

The Docker for Mac application does not provide the same docker daemon
configuration options as other versions of docker-engine. Use socat to establish
a tcp socket bound to localhost which makes available the Docker API on the Mac.

To publish the unix-socket (/var/run/docker.sock) of the Docker daemon as port 
2375 on the local loopback interface (127.0.0.1), use:

```
$ docker run -d --init --read-only --restart=always \
    -p 127.0.0.1:2375:2375 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    simonrupf/socat \
    tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock
```

***WARNING***: The Docker API is unsecure by default. Please remember to bind
the TCP socket to the localhost interface otherwise the Docker API will be
bound to all interfaces.

### Expose a service offering only IPv4 on an IPv6 interface

While IPv6 has been around for a few decades, even some modern appliances or
technology stacks (*cough* Kubernetes) don't support it (well). You can use
socat to expose an IPv4 service to the IPv6 world.

```
$ docker run -d --init --read-only--restart=always \
    -p "[2001:dB8::1234]:80:80" \
    simonrupf/socat \
    tcp6-listen:80,fork,reuseaddr tcp4:192.0.2.123:30080
```

*NOTE*: From the perspective of the service behind socat, all IPv6 connections
will originate from the IPv4 address of the socat host. This may limit the
usefulness of IP logs or IP based load balancing for that service.

## Usage

```shell
make help
```

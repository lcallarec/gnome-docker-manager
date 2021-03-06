# Dockery

[![Build Status](https://travis-ci.org/lcallarec/dockery.svg?branch=master)](https://travis-ci.org/lcallarec/dockery)
[![codecov](https://codecov.io/gh/lcallarec/dockery/branch/master/graph/badge.svg)](https://codecov.io/gh/lcallarec/dockery)

**Dockery** is a _Docker_ GUI client written in *Vala*.

## Features

![Main SC](docs/resources/screenshots/main.png)

* Connect to a local docker deamon via Unix Socket or TCP
 (autodiscover socket location)

* List all containers and execute some basic actions
  - update status (kill, pause, stop, start, restart)
  - rename 
  - inspect
  - destroy

* List all images, with basic informations

* List all created volumes

* Create a container from an image (with command overriding)

* Watch live Docker event stream

* Search & download images from Docker Hub

* Connect to a running container through a terminal

## Run with flatpak

* Install [flatpak](https://flatpak.org/)
* Build with `make flatpak-build`
* Run with `flatpak-builder --run flatpak/build org.lcallarec.Dockery.json ./dockery`

## Compile and install instructions

### Dependencies

| dependency | supported version range |
|---------|--------------------|
| valac   | *                  |
| libgtk-3-dev   | 3.14 - 3.32                |
| libgee-0.8-dev   | *                  |
| libjson-glib-dev   | 1.2 / 1.4                   |
| libsoup2.4-dev   | *                  |
| libvte-2.9[0-1]-dev   | *                  |

### Install on debian-based environment

```bash
$ sudo apt-get valac install build-essential libgtk-3-dev libgee-0.8-dev libjson-glib-dev libsoup2.4-dev
```

Depending of your system, you must also install libvte version 2.90 or 2.91, **Dockery** can be compiled against both of them :

```bash
$ sudo apt-get install libvte-2.90-dev
$ # OR
$ sudo apt-get install libvte-2.91-dev
$ # (the later, the better)
```

### Compile and install :
```bash
$ meson build
$ ninja -C build
```

## Execute

```
./build/src/dockery
```

You can run Dockery using the dark theme variant :

```
./build/src/dockery --dark-theme
```

Or run Dockery with experimental features :

```
./build/src/dockery --experimental
```


# Contribute

Feel free to contribute quicker and better than I can :p Any contributions are welcome, don't be shy !

# More features ?

Feel free to ask any feature you'd like to have !

# More screenshots

| ![Main SC](docs/resources/screenshots/hub.png) |
|:---:|
| *Search and download image to docker public registry* |


| ![Main SC](docs/resources/screenshots/live-events.png) |
|:---:|
| *Watch live docker daemon event stream* |


| ![Main SC](docs/resources/screenshots/container-inspect.png) |
|:---:|
| *Container inspection* |

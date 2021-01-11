# Fedora image with GUI (VNC and remote desktop)

## Quick Start

Note: You'll need more than 20GB of disk space and configure Docker with 4GB or more of RAM. For detailed instructions, see the Lab PDF above.

1. `docker run --cap-add SYS_PTRACE --ulimit core=-1 --ulimit memlock=-1 --ulimit stack=-1 --shm-size="256m" --rm -p 5901:5901 -p 5902:5902 -p 22:22 -p 3390:3389 -it kgibm/fedoradebug`
1. The container is fully started after about 10 seconds.
1. Remote into the docker image with password `websphere`:
    1. Linux: `vncviewer localhost:5902`
    1. Mac: `open vnc://localhost:5902`
    1. Windows: Remote desktop (see [lab instructions](https://raw.githubusercontent.com/kgibm/dockerdebug/master/fedorawasdebug/WebSphere_Application_Server_Troubleshooting_and_Performance_Lab_on_Docker.pdf)), or use a third party VNC client.

Tip: To share files with your host machine, add the following to the `docker run` command above (before `-it kgibm/fedoradebug`):

* Linux/macOS: `-v /:/host/`
* Windows: `-v //c/:/host/`

## Screenshots

![Fedora Desktop Screenshot](https://raw.githubusercontent.com/kgibm/dockerdebug/master/fedoradebug/screenshots/screenshot1.png)

## Installation Highlights

* Fedora
* OpenLDAP
* NMONVisualizer
* Firefox
* LibreOffice
* Wireshark
* Apache JMeter
* OpenJDK

## Notes

* Docker Hub page: https://hub.docker.com/r/kgibm/fedoradebug

## Known Limitations

* Audio is not configured. In theory, it should be possible by configuring the host and `docker run` commands for audio passthrough and starting pulseaudio in the container with `pulseaudio -D`.

# WebSphere Application Server Troubleshooting and Performance Lab on Docker

* Full lab instructions: https://raw.githubusercontent.com/kgibm/dockerdebug/master/fedorawasdebug/WebSphere_Application_Server_Troubleshooting_and_Performance_Lab_on_Docker.pdf
* Preparation instructions only: https://raw.githubusercontent.com/kgibm/dockerdebug/master/fedorawasdebug/Supplemental/WebSphere_Application_Server_Troubleshooting_and_Performance_Lab_on_Docker-Prep.pdf

## Quick Start

Watch a Quick Start video: https://www.youtube.com/watch?v=X57kGMsM8RA

Note: You'll need more than 20GB of disk space and configure Docker with 4GB or more of RAM. For detailed instructions, see the Lab PDF above.

1. `docker run --cap-add SYS_PTRACE --ulimit core=-1 --ulimit memlock=-1 --ulimit stack=-1 --shm-size="256m" --rm -p 9080:9080 -p 9443:9443 -p 9043:9043 -p 9081:9081 -p 9444:9444 -p 5901:5901 -p 5902:5902 -p 3390:3389 -p 22:22 -p 9082:9082 -p 9083:9083 -p 9445:9445 -p 8080:8080 -p 8081:8081 -p 8082:8082 -p 12000:12000 -p 12005:12005 -it kgibm/fedorawasdebug`
1. The container is fully started after about 2 minutes when the output shows:
   ```
   =========
   = READY =
   =========
   ```
1. Remote into the docker image with password `websphere`:
    1. Linux: `vncviewer localhost:5902`
    1. Mac: `open vnc://localhost:5902`
    1. Windows: Remote desktop (see lab instructions), or use a free VNC client.

Tip: To share files with your host machine, add the following to the `docker run` command above (before `-it kgibm/fedorawasdebug`): Linux/macOS: `-v /:/host/` or Windows: `-v //c/:/host/`

## Screenshots

![Fedora Desktop Screenshot](https://raw.githubusercontent.com/kgibm/dockerdebug/master/fedorawasdebug/supplemental/screenshots/screenshot1.png)

![Screenshot showing browsers to the major apps installed](https://raw.githubusercontent.com/kgibm/dockerdebug/master/fedorawasdebug/supplemental/screenshots/screenshot2b.png)

## Lab Highlights

* Using Apache JMeter to run a stress test on WebSphere Liberty or Traditional WAS
* Basic Linux CPU and memory analysis
* IBM Java thread dump analysis
* IBM Java garbage collection analysis
* Java heap analysis
* IBM Java CPU sampling profiler analysis
* Native crash analysis
* Native memory leak analysis
* WebSphere Liberty Admin Center
* WebSphere Liberty Request Timing
* WebSphere Liberty HTTP access log
* WebSphere Liberty MXBean monitoring
* WebSphere Liberty Server dumps
* WebSphere Liberty Event Logging
* WebSphere Liberty Diagnostic Trace
* WebSphere Liberty Binary Logging

## Installation Highlights

* Fedora 31 x64
* WAS Liberty 19.0.0.10
* Traditional WAS Base 9.0.5.1
* IBM Java 8
* IBM HTTP Server 9.0.5.0
* OpenLDAP
* DayTrader7 on WAS Liberty connected to OpenLDAP
* DayTrader7 on Traditional WAS connected to OpenLDAP
* IBM Garbage Collection Memory Visualizer (GCMV)
* Memory Analyzer Tool (MAT) with the IBM Extensions for Memory Analyzer (IEMA)
* IBM Java Health Center (HC)
* NMONVisualizer
* IBM Runtime Diagnostic Code Injection (Java Surgery)
* Request Metrics Analyzer
* IBM Interactive Diagnostic Data Explorer (IDDE)
* IBM Thread and Monitor Dump Analyzer (TMDA)
* IBM HeapAnalyzer (HA)
* IBM Pattern Modeling and Analysis Tool for Java Garbage Collector (PMAT)
* IBM Trace and Request Analyzer for WAS (TRA)
* IBM ClassLoader Analyzer
* Eclipse 2019-06
  * IBM Liberty Developer Tools
* Firefox
* LibreOffice
* Wireshark
* Apache JMeter
* OpenJDK 8
* AdoptOpenJDK OpenJ9 and HotSpot (V8, V11, V13)
* Liberty Bikes
* TrapIt.ear
* swat.ear
* WebSphere Application Server Configuration Comparison Tool
* WAS Data Mining
* WebSphere Performance Cookbook
* MariaDB
* Derby
* Open Liberty Source
* OpenJ9 Source

## Notes

* Docker Hub page: https://hub.docker.com/r/kgibm/fedorawasdebug
* This lab is based on a Java Dockerfile (https://github.com/kgibm/dockerdebug/blob/master/fedorajavadebug/Dockerfile) which is based on a Fedora Dockerfile (https://github.com/kgibm/dockerdebug/blob/master/fedoradebug/Dockerfile).

## Known Limitations

* Audio does not work. You can start start pulseaudio in the container with `pulseaudio -D`, but you'll need to configure your host, potentially configure `docker run`, and potentially configure the container for audio passthrough depending on your host operating system.

# WebSphere Application Server Troubleshooting and Performance Lab on Docker

A lab on Troubleshooting and Performance Tuning WebSphere Liberty and WAS traditional covering various topics like CPU usage, thread dumps, garbage collection, memory analysis, profiling, and more. The Docker container provides a full Linux VM with GUI (see screenshots below) which runs on Windows, Mac, and Linux hosts.

Full lab instructions: https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#websphere-application-server-troubleshooting-and-performance-lab-on-docker

## Quick Start

Watch a Quick Start video: https://www.youtube.com/watch?v=7o25Sq_-T44

Note: You'll need more than 40GB of disk space and configure Docker/podman with 4GB or more of RAM. For details on how to install and configure, see the [lab instructions](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#lab).

1. `docker run --cap-add SYS_PTRACE --ulimit core=-1 --ulimit memlock=-1 --ulimit stack=-1 --shm-size="256m" --rm -p 9080:9080 -p 9443:9443 -p 9043:9043 -p 9081:9081 -p 9444:9444 -p 5901:5901 -p 5902:5902 -p 3390:3389 -p 9082:9082 -p 9083:9083 -p 9445:9445 -p 8080:8080 -p 8081:8081 -p 8082:8082 -p 12000:12000 -p 12005:12005 -it quay.io/kgibm/fedorawasdebug`
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
1. Perform the lab: <https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#websphere-application-server-troubleshooting-and-performance-lab-on-docker>

Tip: To share files with your host machine, add the following to the `docker run` command above (before `-it kgibm/fedoradebug`):

* Linux: `-v /:/host/`
* Windows: `-v //c/:/host/`
* macOS: `-v /tmp/:/hosttmp/`
    * Enable non-standard folders with [File Sharing](https://docs.docker.com/docker-for-mac/#preferences)

## Screenshots

![Fedora Desktop Screenshot](https://raw.githubusercontent.com/kgibm/dockerdebug/master/fedorawasdebug/supplemental/screenshots/screenshot1.png)

![Screenshot showing browsers to the major apps installed](https://raw.githubusercontent.com/kgibm/dockerdebug/master/fedorawasdebug/supplemental/screenshots/screenshot2b.png)

## Lab Highlights

* [Using Apache JMeter to run a stress test on WebSphere Liberty or WAS traditional](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#apache-jmeter)
* [Basic Linux CPU and memory analysis](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#linux-cpu-and-memory-usage)
* [IBM Java thread dump analysis](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#ibm-java-and-openj9-thread-dumps)
* [IBM Java garbage collection analysis](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#garbage-collection)
* [Java heap analysis](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#heap-dumps)
* [IBM Java CPU sampling profiler analysis](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#health-center)
* [Native crash analysis](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#crashes)
* [Native memory leak analysis](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#native-memory-leaks)
* WebSphere Liberty
    * [Admin Center](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#admin-center)
    * [Request Timing](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#request-timing)
    * [HTTP access log](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#http-ncsa-access-log)
    * [MXBean monitoring](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#mxbean-monitoring)
    * [Server dumps](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#server-dumps)
    * [Event Logging](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#event-logging)
    * [Diagnostic Trace](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#diagnostic-trace)
    * [Binary Logging](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#binary-logging)
* WAS traditional
    * [Diagnostic Plans](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#diagnostic-plans)

## Installation Highlights

* [Fedora x64](https://hub.docker.com/_/fedora/)
* [WebSphere Liberty](https://hub.docker.com/_/websphere-liberty)
* [WAS traditional Base](https://hub.docker.com/r/ibmcom/websphere-traditional)
* [IBM Java 8](https://hub.docker.com/_/ibmjava)
* [IBM HTTP Server](https://www.ibm.com/docs/en/ibm-http-server/9.0.5)
* [OpenLDAP](https://www.openldap.org/)
* [DayTrader7 on WebSphere Liberty connected to OpenLDAP](https://github.com/WASdev/sample.daytrader7)
* [DayTrader7 on WAS traditional connected to OpenLDAP](https://github.com/WASdev/sample.daytrader7)
* [IBM Garbage Collection Memory Visualizer (GCMV)](https://www.ibm.com/support/pages/garbage-collection-and-memory-visualizer)
* [Eclipse Memory Analyzer Tool (MAT)](https://www.ibm.com/support/pages/eclipse-memory-analyzer-tool-dtfj-and-ibm-extensions)
* [IBM Java Health Center (HC)](https://www.ibm.com/support/pages/health-center-client)
* [NMONVisualizer](https://nmonvisualizer.github.io/nmonvisualizer/)
* [IBM Runtime Diagnostic Code Injection (Java Surgery)](https://www.ibm.com/support/pages/ibm-runtime-diagnostic-code-injection-java-platform-java-surgery)
* [Request Metrics Analyzer Next](https://github.com/kgibm/request-metrics-analyzer-next)
* [IBM Thread and Monitor Dump Analyzer (TMDA)](https://www.ibm.com/support/pages/ibm-thread-and-monitor-dump-analyzer-java-tmda)
* [IBM HeapAnalyzer (HA)](https://www.ibm.com/support/pages/ibm-heapanalyzer)
* [IBM Pattern Modeling and Analysis Tool for Java Garbage Collector (PMAT)](https://www.ibm.com/support/pages/ibm-pattern-modeling-and-analysis-tool-java-garbage-collector-pmat)
* [IBM Trace and Request Analyzer for WAS (TRA)](https://www.ibm.com/support/pages/ibm-trace-and-request-analyzer-websphere-application-server)
* [IBM ClassLoader Analyzer](https://www.ibm.com/support/pages/ibm-classloader-analyzer)
* [Eclipse IDE for Enterprise Java and Web Developers](https://www.eclipse.org/downloads/)
  * [IBM Liberty Developer Tools](https://marketplace.eclipse.org/content/ibm-liberty-developer-tools)
* [Firefox](https://www.mozilla.org/en-US/firefox/)
* [LibreOffice](https://www.libreoffice.org/)
* [Wireshark](https://www.wireshark.org/)
* [Apache JMeter](https://jmeter.apache.org/)
* [OpenJDK 8](https://openjdk.java.net/)
* [Eclipse Mission Control](https://adoptium.net/jmc)
* [IBM Semeru (V8, V11, V17)](https://developer.ibm.com/languages/java/semeru-runtimes/downloads)
* [Eclipse Temurin (V8, V11, V17)](https://adoptium.net/)
* [Liberty Bikes](https://github.com/OpenLiberty/liberty-bikes)
* [TrapIt.ear](https://www.ibm.com/support/pages/websphere-application-server-log-watcher-using-trapitear-watch-websphere-application-server-events)
* [swat.ear](https://github.com/kgibm/problemdetermination)
* [WebSphere Application Server Configuration Comparison Tool](https://www.ibm.com/support/pages/websphere-application-server-configuration-comparison-tool)
* [WAS Data Mining](https://github.com/kgibm/was_data_mining/)
* [WebSphere Performance Cookbook](https://publib.boulder.ibm.com/httpserv/cookbook/)
* [MariaDB](https://mariadb.org/)
* [Apache Derby](https://db.apache.org/derby/)
* [IBM Channel Framework Analyzer](https://www.ibm.com/support/pages/ibm-channel-framework-analyzer)
* [IBM Web Server Plug-in Analyzer for WebSphere Application Server (WSPA)](https://www.ibm.com/support/pages/ibm-web-server-plug-analyzer-websphere-application-server-wspa)
* [Connection and Configuration Verification Tool for SSL/TLS](https://www.ibm.com/support/pages/connection-and-configuration-verification-tool-ssltls)
* [WebSphere Application Server Configuration Visualizer](https://www.ibm.com/support/pages/websphere-application-server-configuration-visualizer)
* [Problem Diagnostics Lab Toolkit](https://www.ibm.com/support/pages/problem-diagnostics-lab-toolkit)
* [Performance Tuning Toolkit](https://www.ibm.com/support/pages/websphere-application-server-performance-tuning-toolkit)
* [SIB Explorer](https://www.ibm.com/support/pages/service-integration-bus-explorer)
* [SIB Performance](https://www.ibm.com/support/pages/service-integration-bus-performance)
* [IBM Database Connection Pool Analyzer for IBM WebSphere Application Server](https://www.ibm.com/support/pages/ibm-database-connection-pool-analyzer-ibm-websphere-application-server)
* [Eclipse MAT Source](https://wiki.eclipse.org/MemoryAnalyzer/Contributor_Reference)
* [IBM Service Integration Bus Destination Handler](https://www.ibm.com/support/pages/ibm-service-integration-bus-destination-handler-version-11)

## Notes

* Docker Hub page: https://hub.docker.com/r/kgibm/fedorawasdebug
* This lab is based on a Java Dockerfile (https://github.com/kgibm/dockerdebug/blob/master/fedorajavadebug/Dockerfile) which is based on a Fedora Dockerfile (https://github.com/kgibm/dockerdebug/blob/master/fedoradebug/Dockerfile).

## Known Limitations

* Audio is not configured. In theory, it should be possible by configuring the host and `docker run` commands for audio passthrough and starting pulseaudio in the container with `pulseaudio -D`.

## Development

### Rebuilding the WebSphere Application Server Troubleshooting and Performance Lab on Docker

1. Prepare:
    1. macOS: Install the following and then open a new terminal window.
       ```
       brew install pandoc
       brew install --cask mactex
       ```
1. Delete existing images:
   ```
   podman stop --all
   podman system prune --all --force
   podman rmi --all
   ```
1. Update version number, date and revision history in `WAS_Troubleshooting_Perf_Lab.md`
1. Update version numbers in the `echo`s at the bottom of `fedorawasdebug/Containerfile`
1. `cd fedoradebug`
1. `podman build -t kgibm/fedoradebug .`
1. `cd ../fedorajavadebug`
1. `podman build -t kgibm/fedorajavadebug .`
1. `cd ../fedorawasdebug`
1. Remove any previous IHS zips
1. Download the latest "IBM HTTP Server archive file for 64-bit Linux, x86" from <https://www.ibm.com/support/pages/fix-list-ibm-http-server-version-90>
1. Generate lab PDF (yes, this is before building the final image):
   ```
   sed 's/<img src="\(.*\)" width.*\/>/![](\1)/g' WAS_Troubleshooting_Perf_Lab.md > WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   pandoc --pdf-engine=xelatex -V geometry:margin=1in -s -o WAS_Troubleshooting_Perf_Lab.pdf --metadata title="WebSphere Application Server Troubleshooting and Performance Lab on Docker" WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   rm WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   ```
1. `git` add, commit, and push the `WAS_Troubleshooting_Perf_Lab.*` files.
1. `podman pull websphere-liberty`
1. `podman pull ibmcom/websphere-traditional`
1. If needed, update Liberty build in `MAVEN_LIBERTY_VERSION` in `fedorawasdebug/Containerfile`
1. `podman build -t kgibm/fedorawasdebug .`
1. Run and test the image.
1. `podman build -t kgibm/fedorawasdebugejb -f Containerfile.ejb .`
1. `git commit -am "VXX: New version with ..."`
1. `git push`
1. `podman login quay.io`
1. `podman images`
1. For each of the above images: `podman tag $IMAGEID $NAME:VXX` (Example `$NAME`=`quay.io/kgibm/fedoradebug`)
1. Do the same for the `latest` tag
1. Push all the VXX images: `podman push quay.io/kgibm/fedoradebug:VXX && podman push quay.io/kgibm/fedorajavadebug:VXX && podman push quay.io/kgibm/fedorawasdebug:VXX && podman push quay.io/kgibm/fedorawasdebugejb:VXX`
1. After all VXX versions are pushed, push the latest tags: `podman push quay.io/kgibm/fedoradebug:latest && podman push quay.io/kgibm/fedorajavadebug:latest && podman push quay.io/kgibm/fedorawasdebug:latest && podman push quay.io/kgibm/fedorawasdebugejb:latest`
1. `git tag VXX`
1. `git push --tags`
1. Delete old images from:
    1. <https://quay.io/repository/kgibm/fedoradebug?tab=tags>
    1. <https://quay.io/repository/kgibm/fedorajavadebug?tab=tags>
    1. <https://quay.io/repository/kgibm/fedorawasdebug?tab=tags>
    1. <https://quay.io/repository/kgibm/fedorawasdebugejb?tab=tags>

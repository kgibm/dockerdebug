# WebSphere Application Server Troubleshooting and Performance Lab on Docker

A lab on Troubleshooting and Performance Tuning WAS Liberty and Traditional WAS covering various topics like CPU usage, thread dumps, garbage collection, memory analysis, profiling, and more. The Docker container provides a full Linux VM with GUI (see screenshots below) which runs on Windows, Mac, and Linux hosts.

Full lab instructions: https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#websphere-application-server-troubleshooting-and-performance-lab-on-docker

## Quick Start

Watch a Quick Start video: https://www.youtube.com/watch?v=7o25Sq_-T44

Note: You'll need more than 40GB of disk space and configure Docker with 4GB or more of RAM. For detailed instructions, see the Lab PDF above.

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

* [Using Apache JMeter to run a stress test on WebSphere Liberty or Traditional WAS](https://github.com/kgibm/dockerdebug/blob/master/fedorawasdebug/WAS_Troubleshooting_Perf_Lab.md#apache-jmeter)
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

## Installation Highlights

* [Fedora 31 x64](https://hub.docker.com/_/fedora/)
* [WAS Liberty 19.0.0.10](https://hub.docker.com/_/websphere-liberty)
* [Traditional WAS Base 9.0.5.1](https://hub.docker.com/r/ibmcom/websphere-traditional)
* [IBM Java 8](https://hub.docker.com/_/ibmjava)
* [IBM HTTP Server 9.0.5.0](https://hub.docker.com/r/ibmcom/ibm-http-server)
* [OpenLDAP](https://www.openldap.org/)
* [DayTrader7 on WAS Liberty connected to OpenLDAP](https://github.com/WASdev/sample.daytrader7)
* [DayTrader7 on Traditional WAS connected to OpenLDAP](https://github.com/WASdev/sample.daytrader7)
* [IBM Garbage Collection Memory Visualizer (GCMV)](https://marketplace.eclipse.org/content/ibm-monitoring-and-diagnostic-tools-garbage-collection-and-memory-visualizer-gcmv)
* [Memory Analyzer Tool (MAT)](https://www.eclipse.org/mat/)
* [IBM Extensions for Memory Analyzer (IEMA)](https://developer.ibm.com/javasdk/tools/)
* [IBM Java Health Center (HC)](https://marketplace.eclipse.org/content/ibm-monitoring-and-diagnostic-tools-health-center)
* [NMONVisualizer](https://nmonvisualizer.github.io/nmonvisualizer/)
* [IBM Runtime Diagnostic Code Injection (Java Surgery)](https://www.ibm.com/support/pages/ibm-runtime-diagnostic-code-injection-java-platform-java-surgery)
* [Request Metrics Analyzer](https://github.com/kgibm/request-metrics-analyzer-next)
* [IBM Interactive Diagnostic Data Explorer (IDDE)](https://marketplace.eclipse.org/content/ibm-monitoring-and-diagnostic-tools-interactive-diagnostic-data-explorer-idde)
* [IBM Thread and Monitor Dump Analyzer (TMDA)](https://www.ibm.com/support/pages/ibm-thread-and-monitor-dump-analyzer-java-tmda)
* [IBM HeapAnalyzer (HA)](https://www.ibm.com/support/pages/ibm-heapanalyzer)
* [IBM Pattern Modeling and Analysis Tool for Java Garbage Collector (PMAT)](https://www.ibm.com/support/pages/ibm-pattern-modeling-and-analysis-tool-java-garbage-collector-pmat)
* [IBM Trace and Request Analyzer for WAS (TRA)](https://www.ibm.com/support/pages/ibm-trace-and-request-analyzer-websphere-application-server)
* [IBM ClassLoader Analyzer](https://www.ibm.com/support/pages/ibm-classloader-analyzer)
* [Eclipse 2019-06](https://www.eclipse.org/downloads/)
  * [IBM Liberty Developer Tools](https://marketplace.eclipse.org/content/ibm-liberty-developer-tools)
* [Firefox](https://www.mozilla.org/en-US/firefox/)
* [LibreOffice](https://www.libreoffice.org/)
* [Wireshark](https://www.wireshark.org/)
* [Apache JMeter](https://jmeter.apache.org/)
* [OpenJDK 8](https://openjdk.java.net/)
* [AdoptOpenJDK OpenJ9 and HotSpot (V8, V11, V13)](https://adoptopenjdk.net/)
* [Liberty Bikes](https://github.com/OpenLiberty/liberty-bikes)
* [TrapIt.ear](https://www.ibm.com/support/pages/websphere-application-server-log-watcher-using-trapitear-watch-websphere-application-server-events)
* [swat.ear](https://github.com/kgibm/problemdetermination)
* [WebSphere Application Server Configuration Comparison Tool](https://www.ibm.com/support/pages/websphere-application-server-configuration-comparison-tool)
* [WAS Data Mining](https://github.com/kgibm/was_data_mining/)
* [WebSphere Performance Cookbook](https://publib.boulder.ibm.com/httpserv/cookbook/)
* [MariaDB](https://mariadb.org/)
* [Apache Derby](https://db.apache.org/derby/)
* [Open Liberty Source](https://github.com/OpenLiberty/open-liberty/)
* [OpenJ9 Source](https://github.com/eclipse/openj9)
* [IBM Channel Framework Analyzer](https://www.ibm.com/support/pages/ibm-channel-framework-analyzer)
* [IBM Web Server Plug-in Analyzer for WebSphere Application Server (WSPA)](https://www.ibm.com/support/pages/ibm-web-server-plug-analyzer-websphere-application-server-wspa)
* [Connection and Configuration Verification Tool for SSL/TLS](https://www.ibm.com/support/pages/connection-and-configuration-verification-tool-ssltls)
* [WebSphere Application Server Configuration Visualizer](https://www.ibm.com/support/pages/websphere-application-server-configuration-visualizer)
* [Problem Diagnostics Lab Toolkit](https://www.ibm.com/support/pages/problem-diagnostics-lab-toolkit)
* [Performance Tuning Toolkit](https://public.dhe.ibm.com/software/websphere/appserv/support/tools/ptt/)
* [SIB Explorer](https://www.ibm.com/support/pages/service-integration-bus-explorer)
* [SIB Performance](https://www.ibm.com/support/pages/service-integration-bus-performance)
* [IBM Database Connection Pool Analyzer for IBM WebSphere Application Server](https://www.ibm.com/support/pages/ibm-database-connection-pool-analyzer-ibm-websphere-application-server)
* [Eclipse MAT Source](https://wiki.eclipse.org/MemoryAnalyzer/Contributor_Reference)

## Notes

* Docker Hub page: https://hub.docker.com/r/kgibm/fedorawasdebug
* This lab is based on a Java Dockerfile (https://github.com/kgibm/dockerdebug/blob/master/fedorajavadebug/Dockerfile) which is based on a Fedora Dockerfile (https://github.com/kgibm/dockerdebug/blob/master/fedoradebug/Dockerfile).

## Known Limitations

* Audio is not configured. In theory, it should be possible by configuring the host and `docker run` commands for audio passthrough and starting pulseaudio in the container with `pulseaudio -D`.

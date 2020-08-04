#!/bin/sh
set -e
bunzip2 core.20191106.195108.1845.0001.dmp.bz2
7z x core.20200804.025942.3576.0001.dmp.7z
7z x heapdump.20200804.025944.3576.0002.phd.7z
7z x verbosegc.001.log.7z


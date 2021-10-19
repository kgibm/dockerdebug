# docker build -t containerdiagsmall .
# docker run --rm -it containerdiagsmall
#
# Notes:
#   * As of writing this note, this image is about 440MB
#   * Base fedora:latest is about 175MB
#   * Tried ubi-minimal which is about 100MB but microdnf is missing many useful packages like fatrace and others 
#   * gdb adds about 68MB but considered worth it for gdb and gcore
#   * runc adds about 14MB but considered worth it for use with oc debug on a node
#   * git adds about 41MB so instead we just use wget https://github.com/$GROUP/$REPO/archive/master.zip
#   * perf adds about 40MB but considered worth it since it's commonly needed
#   * Therefore, the rest of the utilities are about 100MB
#   * Deleting files in the parent (e.g. /usr/lib64/python*/__pycache__) isn't useful because it's still in that layer

FROM redhat/ubi8
LABEL maintainer="kevin.grigorenko@us.ibm.com"

RUN dnf install -y \
        binutils \
        curl \
        fatrace \
        gawk \
        gdb \
        iproute \
        iputils \
        less \
        lsof \
        ltrace \
        ncdu \
        net-tools \
        nmon \
        p7zip \
        perf \
        procps-ng \
        psmisc \
        runc \
        sysstat \
        strace \
        tcpdump \
        telnet \
        traceroute \
        unzip \
        util-linux \
        vim \
        wget \
        zip \
      && \
    dnf clean all && \
    rm -rf \
            /usr/share/vim/*/doc/ \
            /usr/share/vim/*/spell/ \
            /usr/share/vim/*/tutor/

RUN get_git() { \
      wget -q -O /tmp/$1_$2_master.zip https://github.com/$1/$2/archive/master.zip; \
      unzip -q /tmp/$1_$2_master.zip -d /opt/; \
      mv /opt/$2-master /opt/$1_$2/; \
      rm /tmp/$1_$2_master.zip; \
    } && \
    get_git kgibm problemdetermination && \
    ln -s /opt/kgibm_problemdetermination/scripts/java/j9/j9javacores.awk /usr/local/bin/ && \
    ln -s /opt/kgibm_problemdetermination/scripts/ihs/ihs_mpmstats.awk /usr/local/bin/ && \
    ln -s /opt/kgibm_problemdetermination/scripts/was/twas_pmi_threadpool.awk /usr/local/bin/ && \
    wget -q -O /opt/linperf.sh https://www.ibm.com/support/pages/system/files/inline-files/linperf_1.sh && \
    chmod a+x /opt/linperf.sh && \
    ln -s /opt/linperf.sh /usr/local/bin/ && \
    sed -i 's/-eq 0/-eq -1/g' /opt/linperf.sh

# Defer to the ENTRYPOINT/CMD of Fedora which is bash

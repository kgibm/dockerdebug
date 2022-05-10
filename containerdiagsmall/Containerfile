# /*******************************************************************************
#  * (c) Copyright IBM Corporation 2022.
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *    http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  *******************************************************************************/
# Building:
#   podman build -t containerdiagsmall .
#   podman tag $(podman images | grep localhost/containerdiagsmall | awk '{print $3}') quay.io/kgibm/containerdiagsmall
#   podman login quay.io
#   podman push quay.io/kgibm/containerdiagsmall
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

FROM fedora
LABEL maintainer="kevin.grigorenko@us.ibm.com"

RUN dnf install -y \
        binutils \
        curl \
        fatrace \
        gawk \
        gdb \
        hostname \
        iproute \
        iputils \
        jq \
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
        tree \
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

RUN mkdir -p /opt/java/11/ && \
    wget -q -O - https://www.ibm.com/semeru-runtimes/api/v3/binary/latest/11/ga/linux/x64/jdk/openj9/normal/ibm | tar -xzf - --directory /opt/ && \
    mv /opt/jdk* /opt/java/11/semeru && \
    ln -s /opt/java/11/semeru/bin/java /usr/local/bin/

COPY *.sh *.awk /opt/

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
    chmod a+x /opt/debugpodinfo.awk && ln -s /opt/debugpodinfo.awk /usr/local/bin/ && \
    chmod a+x /opt/libertyperf.sh && ln -s /opt/libertyperf.sh /usr/local/bin/ && \
    chmod a+x /opt/linperf.sh && ln -s /opt/linperf.sh /usr/local/bin/ && \
    chmod a+x /opt/podfscp.sh && ln -s /opt/podfscp.sh /usr/local/bin/ && \
    chmod a+x /opt/podfspath.sh && ln -s /opt/podfspath.sh /usr/local/bin/ && \
    chmod a+x /opt/podfsrm.sh && ln -s /opt/podfsrm.sh /usr/local/bin/ && \
    chmod a+x /opt/podinfo.sh && ln -s /opt/podinfo.sh /usr/local/bin/ && \
    chmod a+x /opt/run.sh && ln -s /opt/run.sh /usr/local/bin/

# Defer to the ENTRYPOINT/CMD of Fedora which is bash

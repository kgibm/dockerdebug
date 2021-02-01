# docker build -t containerdiagsmall .
# docker run -it containerdiagsmall
#
# Notes:
#   * Base fedora:latest is about 175MB
#   * Tried ubi-minimal which is about 100MB but microdnf is missing many useful packages like fatrace and others 
#   * As of writing this note, this image is about 317MB
#   * gdb adds about 68MB but considered worth it for gcore, etc.; therefore, the rest of the utilities are about 75MB
#   * Deleting files in the parent (e.g. /usr/lib64/python*/__pycache__) isn't useful because it's still in that layer

FROM fedora:latest
LABEL maintainer="kevin.grigorenko@us.ibm.com"

RUN dnf install -y \
        curl \
        fatrace \
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
        procps-ng \
        psmisc \
        sysstat \
        strace \
        tcpdump \
        telnet \
        traceroute \
        util-linux \
        vim \
        wget \
      && \
    dnf clean all && \
    rm -rf \
            /usr/share/vim/*/doc/ \
            /usr/share/vim/*/spell/ \
            /usr/share/vim/*/tutor/

# Defer to the ENTRYPOINT/CMD of Fedora which is bash

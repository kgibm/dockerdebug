# syntax=docker/dockerfile:1.0.0-experimental

# usage:
# 
# Requires Docker >= 18.09
# Step 1: Create remotepassword.txt in the directory with this Dockerfile with the VNC/root password
# Step 2: Build the Docker image:
#   DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt -t fedoradebug:20190311 .
# Step 3: Run the Docker image:
#   docker run -p 3389:3389 -p 5901:5901 -it fedoradebug:20190311
# 
# Linux: vncviewer -AutoSelect 0 -QualityLevel 9 -CompressLevel 0 localhost:5901
# Mac: open vnc://localhost:5901

FROM fedora:latest

LABEL maintainer="kevin.grigorenko@us.ibm.com"

RUN dnf install -y \
      at \
      atop \
      autoconf \
      bc \
      bind-utils \
      bindfs \
      bison \
      bison-devel \
      cmake \
      collectl \
      e2fsprogs \
      file-devel \
      firefox \
      ftp \
      gcc \
      gcc-c++ \
      gdb \
      git \
      gnupg \
      gnuplot \
      hostname \
      htop \
      iftop \
      iotop \
      iperf \
      iputils \
      java-1.8.0-openjdk \
      java-1.8.0-openjdk-devel \
      kernel-devel \
      kexec-tools \
      less \
      lsof \
      lzo \
      lzo-devel \
      lzo-minilzo \
      mailx \
      make \
      man \
      mtr \
      multitail \
      ncurses \
      ncurses-devel \
      net-tools \
      nethogs \
      nfs-utils \
      nmap-ncat \
      nmon \
      ntp \
      patch \
      perf \
      perl \
      python3 \
      python3-devel \
      python3-matplotlib \
      python3-numpy \
      python3-pandas \
      python3-pip \
      python3-scipy \
      python3-statsmodels \
      R \
      R-devel \
      ruby \
      sendmail \
      speedtest-cli \
      sysstat \
      strace \
      sudo \
      supervisor \
      systemtap \
      tc \
      tcpdump \
      telnet \
      tigervnc-server \
      traceroute \
      util-linux \
      vim \
      wget \
      @xfce \
      xrdp \
    && dnf debuginfo-install -y \
      glibc \
      kernel

RUN --mount=type=secret,id=remotepassword,required \
    mkdir /root/.vnc && \
    cat /run/secrets/remotepassword | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo "startxfce4" > /root/.Xclients && \
    chmod +x /root/.Xclients && \
    echo "root:$(cat /run/secrets/remotepassword)" | chpasswd && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini

RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec xfce4-session\n'\
>> /root/.vnc/xstartup

RUN chmod a+x /root/.vnc/xstartup

RUN printf '\n\
[unix_http_server]\n\
file=/tmp/supervisor.sock\n\
\n\
[supervisord]\n\
logfile=/dev/stdout\n\
logfile_maxbytes=0\n\
loglevel=info\n\
pidfile=/tmp/supervisord.pid\n\
minfds=1024\n\
minprocs=200\n\
\n\
[rpcinterface:supervisor]\n\
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface\n\
\n\
[supervisorctl]\n\
serverurl=unix:///tmp/supervisor.sock\n\
\n\
[include]\n\
files=*.supervisord.conf\n\
\n'\
>> supervisord.conf

RUN printf '\n\
[program:vncserver]\n\
command=/usr/bin/vncserver -fg\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
\n'\
>> vncserver.supervisord.conf

RUN printf '\n\
[program:xrdp-sesman]\n\
command=/usr/sbin/xrdp-sesman --nodaemon\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
\n'\
>> xrdp-sesman.supervisord.conf

RUN printf '\n\
[program:xrdp]\n\
command=/usr/sbin/xrdp -nodaemon\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
\n'\
>> xrdp.supervisord.conf

# polkit crashes on login. There is a discussion on the Fedora mailing list with
# the only workaround being to start vncserver through SSH. Removing it
# from startup doesn't seem to hurt.
RUN mv /etc/xdg/autostart/xfce-polkit.desktop /etc/xdg/autostart/xfce-polkit.desktop.disabled

EXPOSE 3389 5901

# https://docs.docker.com/config/containers/multi-service_container/
CMD ["/usr/bin/supervisord", "-n", "-c", "supervisord.conf"]

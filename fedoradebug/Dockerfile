# syntax=docker/dockerfile:1.0.0-experimental
# Purpose: This is not designed for production usage but instead as a debugging and learning container.
# usage (Requires Docker >= 18.09):
# ======
# Step 1: Create remotepassword.txt in the directory with this Dockerfile and set the contents of the file to the password used for VNC/RDP/root
# Step 2: Build the Docker image:
#   DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt -t fedoradebug .
# Step 3: Run the Docker image:
#   docker run -p 3389:3389 -p 5901:5901 -p 5902:5902 -p 22:22 -it fedoradebug
# Step 4: Remote into the docker image
#   Linux:
#     root: vncviewer localhost:5901
#     user1: vncviewer localhost:5902
#     Use the password from remotepassword.txt
#   Mac:
#     root: open vnc://localhost:5901
#     user1: open vnc://localhost:5902
#     Use the password from remotepassword.txt
#   Windows: Remote desktop to localhost and use the username of root or user1 and the password from remotepassword.txt
#

FROM fedora:latest

LABEL maintainer="kevin.grigorenko@us.ibm.com"

####################
# Install programs #
####################

# By default, the Fedora cloud image doesn't install man pages so we disable that and reinstall
# http://docs.projectatomic.io/container-best-practices/#_removing_documentation
RUN sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf && dnf reinstall -y "*"

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
      dnf-plugins-core \
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
      man-pages \
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
      openssh-server \
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
      rsyslog \
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
      tigervnc \
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

######################################
# Configure VNC, XRDP, and the users #
######################################

RUN --mount=type=secret,id=remotepassword,required \
    mkdir /root/.vnc && \
    echo -n "$(head -n 1 /run/secrets/remotepassword)" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo "startxfce4" > /root/.Xclients && \
    chmod +x /root/.Xclients && \
    echo "root:$(echo -n "$(head -n 1 /run/secrets/remotepassword)")" | chpasswd && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini && \
    adduser -m user1 && \
    usermod -a -G wheel user1 && \
    mkdir /home/user1/.vnc && \
    echo -n "$(head -n 1 /run/secrets/remotepassword)" | vncpasswd -f > /home/user1/.vnc/passwd && \
    chmod -R go-rwx /home/user1/.vnc && \
    echo "startxfce4" > /home/user1/.Xclients && \
    chmod +x /home/user1/.Xclients && \
    chown -R user1:user1 /home/user1/ && \
    sed -i 's/^%wheel.*/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    echo -n "$(head -n 1 /run/secrets/remotepassword)" | passwd --stdin user1

RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec xfce4-session\n'\
>> /root/.vnc/xstartup && \
   chmod a+x /root/.vnc/xstartup && \
   cp /root/.vnc/xstartup /home/user1/.vnc/xstartup && \
   chown user1:user1 /home/user1/.vnc/xstartup

#####################
# Configure rsyslog #
#####################

RUN sed -i 's/\(.*imjournal.*\)/#\1/g' /etc/rsyslog.conf && \
    sed -i 's/\(.*SysSock.Use.*\)/#\1/g' /etc/rsyslog.conf && \
    sed -i 's/imuxsock"/imuxsock")/g' /etc/rsyslog.conf

#########################
# Configure supervisord #
#########################

# https://docs.docker.com/config/containers/multi-service_container/

RUN --mount=type=secret,id=remotepassword,required \
    printf '\n\
[supervisord]\n\
user=root\n\
logfile=/dev/stdout\n\
logfile_maxbytes=0\n\
loglevel=info\n\
pidfile=/var/run/supervisor/supervisord.pid\n\
minfds=1024\n\
minprocs=200\n\
\n\
[unix_http_server]\n\
file=/var/run/supervisor/supervisor.sock\n\
username=root\n\
password={SHA}%s\n\
\n\
[rpcinterface:supervisor]\n\
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface\n\
\n\
[supervisorctl]\n\
serverurl=unix:///var/run/supervisor/supervisor.sock\n\
\n\
[include]\n\
files=*.supervisord.conf\n\
\n' "$(echo -n "$(head -n 1 /run/secrets/remotepassword)" | sha1sum | awk '{print $1}')" \
>> supervisord.conf

RUN printf '\n\
[program:rsyslog]\n\
command=/usr/sbin/rsyslogd -n\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=1\n\
\n'\
>> rsyslog.supervisord.conf

RUN printf '\n\
[program:xrdp]\n\
command=/usr/sbin/xrdp -nodaemon\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=20\n\
\n'\
>> xrdp.supervisord.conf

RUN printf '\n\
[program:xrdp-sesman]\n\
command=/usr/sbin/xrdp-sesman --nodaemon\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=25\n\
\n'\
>> xrdp-sesman.supervisord.conf

RUN printf '\n\
[program:ssh]\n\
command=/usr/sbin/sshd -D\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=30\n\
\n'\
>> ssh.supervisord.conf

RUN printf '\n\
[program:vncserver1]\n\
command=/usr/bin/vncserver :1 -fg\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=50\n\
\n'\
>> vncserver1.supervisord.conf

RUN printf '\n\
[program:vncserver2]\n\
command=/usr/sbin/runuser -l user1 -c "/usr/bin/vncserver :2 -fg"\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=50\n\
\n'\
>> vncserver2.supervisord.conf

# If a CMD is specified or a program through `docker run`,
# then dynamically generate a supervisord config for it

RUN printf '#!/bin/sh\n\
ssh-keygen -A\n\
if [ "$#" -gt 0 ]; then\n\
  printf "[program:cmd]\\ncommand=$@\\nstdout_logfile=/dev/stdout\\nstdout_logfile_maxbytes=0\\nredirect_stderr=true\\n" > cmd.supervisord.conf\n\
fi\n\
/usr/bin/supervisord -n -c supervisord.conf\n\
\n'\
>> /entrypoint.sh && chmod +x /entrypoint.sh

######################
# XFCE configuration #
######################

# polkit crashes on login. There is a discussion on the Fedora mailing list with
# the only workaround being to start vncserver through SSH. Removing it
# from startup doesn't seem to hurt.
RUN mv /etc/xdg/autostart/xfce-polkit.desktop /etc/xdg/autostart/xfce-polkit.desktop.disabled

###########
# General #
###########

EXPOSE 22 3389 5901 5902

ENTRYPOINT ["/entrypoint.sh"]

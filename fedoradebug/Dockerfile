# syntax=docker/dockerfile:1.0.0-experimental
#
# Purpose: This is not designed for production usage but instead as a debugging and learning container.
#
# usage (Requires Docker >= 18.09):
# ======
# Step 1: Optionally, create remotepassword.txt in the directory with this Dockerfile and set the contents of the
#         file to the password used for VNC/RDP/root
# Step 2: Build the Docker image:
#   Without remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build -t fedoradebug .
#   With remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt -t fedoradebug .
# Step 3: Run the Docker image:
#   docker run --cap-add SYS_PTRACE --rm -p 3389:3389 -p 5901:5901 -p 5902:5902 -p 22:22 -it fedoradebug
# Step 4: Remote into the docker image
#   Linux:
#     root: vncviewer localhost:5901
#     was: vncviewer localhost:5902
#     Use the password from remotepassword.txt
#   Mac:
#     root: open vnc://localhost:5901
#     was: open vnc://localhost:5902
#     Use the password from remotepassword.txt
#   Windows: Remote desktop to localhost and use the username of root or was
#            and the password from remotepassword.txt
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
      bcc-tools \
      bind-utils \
      bindfs \
      bison \
      bison-devel \
      cmake \
      collectl \
      dnf-plugins-core \
      e2fsprogs \
      eclipse \
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
      maven \
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
      tuned \
      util-linux \
      vim \
      wget \
      wireshark \
      @xfce \
      xrdp \
    && dnf debuginfo-install -y \
      glibc \
      kernel

###############################################
# Create the script that can update passwords #
###############################################

RUN printf '#!/bin/sh\n\
read password\n\
echo "${password}" | sudo tee /root/password.txt\n\
if [ "${password}" = "" ]; then\n\
  password=$(cat /dev/urandom | tr -dc "a-z0-9" | fold -w 8 | head -n 1)\n\
fi\n\
echo -n "${password}" | sudo sh -c "vncpasswd -f > /root/.vnc/passwd" || exit 1\n\
echo "root:$(echo -n "${password}")" | sudo sh -c "chpasswd" || exit 1\n\
echo -n "${password}" | sudo sh -c "vncpasswd -f > /home/was/.vnc/passwd" || exit 1\n\
echo -n "${password}" | sudo sh -c "passwd --stdin was" || exit 1\n\
sudo sed -i "s/password={SHA}.*/password={SHA}$(echo -n "${password}" | sha1sum | awk "{print \\$1}")/g" /supervisord.conf || exit 1\n\
sudo chmod 600 /root/.vnc/passwd || exit 1\n\
sudo chmod -R go-rwx /home/was/.vnc || exit 1\n\
sudo chown -R was:root /home/was/ || exit 1\n\
\n' > /setpassword.sh && chmod +x /setpassword.sh

######################################
# Configure VNC, XRDP, and the users #
######################################

RUN mkdir /root/.vnc && \
    echo "startxfce4" > /root/.Xclients && \
    chmod +x /root/.Xclients && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini && \
    adduser -u 1001 -r -g 0 -m was && \
    usermod -a -G wheel was && \
    mkdir /home/was/.vnc && \
    echo "startxfce4" > /home/was/.Xclients && \
    chmod +x /home/was/.Xclients && \
    sed -i 's/^%wheel.*/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec xfce4-session\n'\
>> /root/.vnc/xstartup && \
   chmod a+x /root/.vnc/xstartup && \
   cp /root/.vnc/xstartup /home/was/.vnc/xstartup && \
   chown was:root /home/was/.vnc/xstartup

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

RUN printf '\n\
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
password={SHA}REPLACEPASSWORD\n\
\n\
[rpcinterface:supervisor]\n\
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface\n\
\n\
[supervisorctl]\n\
serverurl=unix:///var/run/supervisor/supervisor.sock\n\
\n\
[include]\n\
files=*.supervisord.conf\n\
\n' \
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
command=/usr/sbin/runuser -l was -c "/usr/bin/vncserver :2 -fg"\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=50\n\
\n'\
>> vncserver2.supervisord.conf

# If a CMD is specified or a program through `docker run`,
# then start supervisord in the background and run the CMD.
# Otherwise (the default), run supervisord in the foreground.

RUN printf '#!/bin/sh\n\
sudo ssh-keygen -A || exit 1\n\
\n\
if [ -e /extended_entrypoint.sh ]; then\n\
  sudo chmod a+x /extended_entrypoint.sh\n\
  /extended_entrypoint.sh || exit 1\n\
fi\n\
\n\
if [ "$#" -gt 0 ]; then\n\
  sudo sh -c "/usr/bin/supervisord -c supervisord.conf &> /supervisord.log" || exit 1 &\n\
  exec "$@" || exit 1\n\
else\n\
  sh -c "sudo /usr/bin/supervisord -n -c supervisord.conf" || exit 1\n\
fi\n\
\n\
#Old code when CMD was added as a supervised program\n\
#if [ "$#" -gt 0 ]; then\n\
#  printf "[program:cmd]\\ncommand=$@\\nstdout_logfile=/dev/stdout\\nstdout_logfile_maxbytes=0\\nredirect_stderr=true\\n" | sudo tee cmd.supervisord.conf > /dev/null\n\
#fi\n\
#sudo sh -c "/usr/bin/supervisord -n -c supervisord.conf" || exit 1\n\
\n'\
>> /entrypoint.sh && chmod a+rx /entrypoint.sh

######################
# XFCE configuration #
######################

# polkit crashes on login. There is a discussion on the Fedora mailing list with
# the only workaround being to start vncserver through SSH. Removing it
# from startup doesn't seem to hurt too much.
RUN mv /etc/xdg/autostart/xfce-polkit.desktop /etc/xdg/autostart/xfce-polkit.desktop.disabled

#############
# Utilities #
#############

# https://ant.apache.org/
RUN ( \
      cd /opt/ && \
      sudo wget -q https://www.apache.org/dist/ant/binaries/apache-ant-1.10.5-bin.zip && \
      sudo unzip -q apache-ant*.zip && \
      sudo rm -f apache-ant*.zip && \
      sudo mv apache-ant* apache-ant \
    )

# https://github.com/brendangregg/FlameGraph
RUN ( \
      cd /opt/ && \
      sudo git clone https://github.com/brendangregg/FlameGraph \
    )

# https://github.com/nmonvisualizer/nmonvisualizer
RUN ( \
      cd /opt/ && \
      sudo git clone https://github.com/nmonvisualizer/nmonvisualizer && \
      cd /opt/nmonvisualizer/ && \
      sudo ANT_OPTS=-Dfile.encoding=iso-8859-1 /opt/apache-ant/bin/ant && \
      sudo mv NMONVisualizer*.jar NMONVisualizer.jar \
    )

# http://www-01.ibm.com/support/docview.wss?uid=swg21115785
RUN ( \
      sudo mkdir /opt/linperf/ && \
      cd /opt/linperf/ && \
      sudo wget -q -O linperf.sh "http://www-01.ibm.com/support/docview.wss?uid=swg21115785&aid=1" && \
      sudo chmod a+x linperf.sh \
    )

# https://jmeter.apache.org/
RUN ( \
      cd /opt/ && \
      sudo wget -q https://www.apache.org/dist/jmeter/binaries/apache-jmeter-5.1.1.zip && \
      sudo unzip -q apache-jmeter*.zip && \
      sudo rm -f apache-jmeter*.zip && \
      sudo mv apache-jmeter* apache-jmeter \
    )

####################
# Update passwords #
####################

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /setpassword.sh

###########
# General #
###########

EXPOSE 22 3389 5901 5902

ENTRYPOINT ["/entrypoint.sh"]

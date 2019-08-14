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
#     DOCKER_BUILDKIT=1 docker build -t kgibm/fedoradebug .
#   With remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt -t kgibm/fedoradebug .
# Step 3: Run the Docker image:
#   docker run --cap-add SYS_PTRACE --ulimit core=-1 --ulimit memlock=-1 --ulimit stack=-1 --shm-size="256m" --rm -p 5901:5901 -p 5902:5902 -p 22:22 -p 3390:3389 -it kgibm/fedoradebug
# Step 4: Remote into the docker image
#   Linux:
#     root: vncviewer localhost:5901
#     was: vncviewer localhost:5902
#     Use the password from remotepassword.txt
#   Mac:
#     root: open vnc://localhost:5901
#     was: open vnc://localhost:5902
#     Use the password from remotepassword.txt
#   Windows: Remote desktop requires detailed instructions. Consider using a free VNC client.
# Tips:
#   * To access the host filesystem from the container (and vice versa), add the following to docker run:
#     Linux/macOS: -v /:/host/
#     Windows: -v //c/:/host/

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
      emacs \
      file-devel \
      firefox \
      ftp \
      galculator \
      gcc \
      gcc-c++ \
      gdb \
      git \
      gnupg \
      gnuplot \
      golang \
      gradle \
      hostname \
      htop \
      httpd \
      iftop \
      iotop \
      iperf \
      iputils \
      java-1.8.0-openjdk \
      java-1.8.0-openjdk-devel \
      kernel-devel \
      kernel-headers \
      kexec-tools \
      less \
      libreoffice \
      libxcrypt-compat \
      llvm \
      lsof \
      lzo \
      lzo-devel \
      lzo-minilzo \
      mailx \
      make \
      man \
      man-pages \
      maven \
      mousepad \
      mtr \
      multitail \
      ncurses \
      ncurses-devel \
      net-tools \
      nethogs \
      nfs-utils \
      nmap-ncat \
      nmon \
      npm \
      ntp \
      openldap-clients \
      openssh-server \
      patch \
      perf \
      perl \
      php \
      python3 \
      python3-devel \
      python3-matplotlib \
      python3-numpy \
      python3-pandas \
      python3-pip \
      python3-scipy \
      python3-statsmodels \
      qt5 \
      R \
      R-devel \
      rsyslog \
      ruby \
      ruby-devel \
      rubygem-mysql2 \
      rubygem-rails \
      rust \
      scala \
      sendmail \
      speedtest-cli \
      sysstat \
      strace \
      sudo \
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
      xreader \
    && dnf debuginfo-install -y \
      glibc \
      kernel

# Notes on the packages above:
# * Firefox crashes switching tabs with SIGBUS errors unless we use docker run --shm-size=...
#    https://bugzilla.mozilla.org/show_bug.cgi?id=1338771
# * libxcrypt-compat provides /lib64/libcrypt.so.1 needed for things like tWAS; otherwise: "java.lang.UnsatisfiedLinkError: Ws60ProcessManagement (Not found in java.library.path)"
#    https://fedoraproject.org/wiki/Changes/FullyRemoveDeprecatedAndUnsafeFunctionsFromLibcrypt

# Explicitly install a newer version supervisor because of https://github.com/Supervisor/supervisor/issues/1224
RUN sudo pip3 install supervisor==4.0.1

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

# For Remote Desktop issues with Java Swing rendering, use xserverbpp=24:
# https://stackoverflow.com/a/37428300/1293660

# Change the default of sudo to use -E and pass all environment variables
RUN mkdir /root/.vnc && \
    mkdir /root/Desktop && \
    echo "startxfce4" > /root/.Xclients && \
    chmod +x /root/.Xclients && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini && \
    adduser -u 1001 -r -g 0 -m was && \
    usermod -a -G wheel was && \
    mkdir /home/was/.vnc && \
    mkdir /home/was/Desktop && \
    echo "startxfce4" > /home/was/.Xclients && \
    chmod +x /home/was/.Xclients && \
    sed -i 's/^%wheel.*/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    sed -i 's/^\(Defaults.*env_reset\)/#\1/g' /etc/sudoers && \
    mkdir /opt/programs/ && \
    sed -i 's/#xserverbpp=24/xserverbpp=24/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/code=20/code=20\nxserverbpp=24/g' /etc/xrdp/xrdp.ini

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

# Print environment variables inherited by supervisord-spawned programs
RUN printf '\n\
[program:debugsupervisord]\n\
command=/usr/bin/env\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
autorestart=false\n\
startretries=0\n\
startsecs=0\n\
priority=1\n\
user=was\n\
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
\n' | sudo tee debugsupervisord.supervisord.conf

RUN sudo mkdir -p /var/run/supervisor/

# If a CMD is specified or a program through `docker run`,
# then start supervisord in the background and run the CMD.
# Otherwise (the default), run supervisord in the foreground.
# This is required to run as root to properly inherit core
# dump ulimits, so child containers must always go back to
# `USER root` before ENTRYPOINT/CMD is run. Attempted
# with sudo but ulimits don't pass through.
RUN printf '#!/bin/sh\n\
ssh-keygen -A || exit 1\n\
\n\
if [ -e /extended_entrypoint.sh ]; then\n\
  chmod a+x /extended_entrypoint.sh\n\
  /extended_entrypoint.sh || exit 1\n\
fi\n\
\n\
if [ "$#" -gt 0 ]; then\n\
  /usr/local/bin/supervisord -c supervisord.conf &> /supervisord.log || exit 1 &\n\
  exec "$@" || exit 1\n\
else\n\
  /usr/local/bin/supervisord -n -c supervisord.conf || exit 1\n\
fi\n\
\n\
#Old code when CMD was added as a supervised program\n\
#if [ "$#" -gt 0 ]; then\n\
#  printf "[program:cmd]\\ncommand=$@\\nstdout_logfile=/dev/stdout\\nstdout_logfile_maxbytes=0\\nredirect_stderr=true\\n" | tee cmd.supervisord.conf > /dev/null\n\
#fi\n\
#/usr/local/bin/supervisord -n -c supervisord.conf || exit 1\n\
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
      sudo mv NMONVisualizer*.jar NMONVisualizer.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=NMON Visualizer\nExec=java -jar /opt/nmonvisualizer/NMONVisualizer.jar\nPath=~/\nTerminal=false\n' >> nmonvisualizer.desktop && \
      sudo chmod a+x nmonvisualizer.desktop && \
      sudo ln -s /opt/nmonvisualizer/nmonvisualizer.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/nmonvisualizer.desktop /home/was/Desktop/ \
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
      sudo mv apache-jmeter* apache-jmeter && \
      cd /opt/apache-jmeter/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=JMeter\nExec=/opt/apache-jmeter/bin/jmeter\nPath=~/\nTerminal=false\n' >> jmeter.desktop && \
      sudo chmod a+x jmeter.desktop && \
      sudo ln -s /opt/apache-jmeter/jmeter.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/jmeter.desktop /home/was/Desktop/ && \
      cd /opt/apache-jmeter/lib/ext && \
      sudo wget -q https://bitbucket.org/pjtr/jmeter-websocket-samplers/downloads/JMeterWebSocketSamplers-1.2.1.jar \
    )

# https://github.com/iovisor/bcc
# https://github.com/iovisor/bcc/issues/281
# https://github.com/iovisor/bcc/pull/279/commits/c48f9d9c3d438e839eb2bfe0a2ed1a321b4e946d
# Some kernels don't have CONFIG_TRACING=y CONFIG_EVENT_TRACING=y, so memleak.py won't work:
# https://github.com/iovisor/bcc/issues/1530
RUN ( \
      cd /opt/ && \
      sudo git clone https://github.com/iovisor/bcc \
    )

# Install some Node basics
RUN sudo npm install express --save

# Some Docker hosts run a different kernel than what gets installed above. The following hack
# won't always work but it might for some cases (e.g. bcc).
# Useless anyway without CONFIG_TRACING, so don't bother with the hack.
# See https://github.com/iovisor/bcc/issues/1000
#RUN [ ! -d "/lib/modules/$(uname -r)" ] && sudo ln -s /lib/modules/* "/lib/modules/$(uname -r)"

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /setpassword.sh

############################
# Final user configuration #
############################

# root's Desktop cannot take links (it doesn't work in this image seemingly because of some D-Bus/XFCE issue)
RUN sudo chmod a+x /usr/share/applications/firefox.desktop && \
    sudo ln -s /usr/share/applications/firefox.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/mousepad.desktop && \
    sudo ln -s /usr/share/applications/mousepad.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/wireshark.desktop && \
    sudo ln -s /usr/share/applications/wireshark.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/galculator.desktop && \
    sudo ln -s /usr/share/applications/galculator.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/libreoffice-calc.desktop && \
    sudo ln -s /usr/share/applications/libreoffice-calc.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/libreoffice-writer.desktop && \
    sudo ln -s /usr/share/applications/libreoffice-writer.desktop /home/was/Desktop/

# Strange error trying to launch Wireshark:
# error while loading shared libraries: libQt5Core.so.5: cannot open shared object file: No such file or directory
# https://superuser.com/questions/1347723/
RUN sudo strip --remove-section=.note.ABI-tag /usr/lib64/libQt5Core.so.5

# Allow the was user to perform Wireshark captures:
# This doesn't seem to actually work; instead, use command line tcpdump. Leaving here for completeness.
RUN sudo usermod -a -G wireshark was

# Set the default PDF reader to xreader; otherwise, the default
# becomes LibreOffice Draw which isn't a great PDF viewer.

USER was
RUN xdg-mime default xreader.desktop application/pdf

USER root
RUN xdg-mime default xreader.desktop application/pdf

# Cannot set background before logging in
#RUN xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/image-style -s 0
RUN printf '#!/bin/sh\n\
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/image-style -s 0\n\
\n' > /home/was/Desktop/reset_desktop_background.sh && chmod +x /home/was/Desktop/reset_desktop_background.sh

# Set the default browser
RUN sudo mkdir -p /root/.config/xfce4/ && \
    printf 'WebBrowser=firefox' | sudo tee /root/.config/xfce4/helpers.rc && \
    sudo mkdir -p /home/was/.config/xfce4/ && \
    printf 'WebBrowser=firefox' | sudo tee /home/was/.config/xfce4/helpers.rc && \
    sudo chown -R was:root /home/was/.config

################
# Finalization #
################

EXPOSE 22 3389 5901 5902

# Last statement must be switching to root for supervisord
USER root

ENTRYPOINT ["/entrypoint.sh"]

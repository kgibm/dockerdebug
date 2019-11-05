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
# Notes:
#   * Because of a maximum of 125 layers (https://github.com/docker/for-linux/issues/414), minimize the number of RUN
#     commands when finalizing a new version.

FROM fedora:latest

LABEL maintainer="kevin.grigorenko@us.ibm.com"

# By default, the Fedora cloud image doesn't install man pages so we disable that and reinstall
# http://docs.projectatomic.io/container-best-practices/#_removing_documentation
RUN sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf && dnf reinstall -y "*"

# Notes on the packages:
# * Firefox crashes switching tabs with SIGBUS errors unless we use docker run --shm-size=...
#    https://bugzilla.mozilla.org/show_bug.cgi?id=1338771
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
      libnsl \
      libreoffice \
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
      meld \
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
      nss-pam-ldapd \
      ntp \
      openldap \
      openldap-clients \
      openldap-devel \
      openldap-servers \
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
      supervisor \
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
      xfce4-calculator-plugin \
      xfce4-cpufreq-plugin \
      xfce4-cpugraph-plugin \
      xfce4-diskperf-plugin \
      xfce4-netload-plugin \
      xfce4-notes-plugin \
      xfce4-sensors-plugin \
      xfce4-systemload-plugin \
      xrdp \
      xreader \
    && dnf debuginfo-install -y \
      glibc \
      kernel

RUN dbus-uuidgen > /var/lib/dbus/machine-id && \
    groupadd nogroup && \
    echo "###############################################" && \
    echo "# Create the script that can update passwords #" && \
    echo "###############################################" && \
    printf '#!/bin/sh\n\
read password\n\
echo "${password}" | sudo tee /root/password.txt\n\
if [ "${password}" = "" ]; then\n\
  password=$(cat /dev/urandom | tr -dc "a-z0-9" | fold -w 8 | head -n 1)\n\
fi\n\
echo -n "${password}" | sudo sh -c "vncpasswd -f > /root/.vnc/passwd" || exit 1\n\
echo "root:$(echo -n "${password}")" | sudo sh -c "chpasswd" || exit 1\n\
echo -n "${password}" | sudo sh -c "vncpasswd -f > /home/was/.vnc/passwd"\n\
echo -n "${password}" | sudo sh -c "passwd --stdin was"\n\
sudo sed -i "s/password={SHA}.*/password={SHA}$(echo -n "${password}" | sha1sum | awk "{print \\$1}")/g" /etc/supervisord.conf || exit 1\n\
sudo chmod 600 /root/.vnc/passwd || exit 1\n\
sudo chmod -R go-rwx /home/was/.vnc || exit 1\n\
sudo chown -R was:root /home/was/ || exit 1\n\
\n' | sudo tee /usr/local/bin/setpassword.sh && chmod +x /usr/local/bin/setpassword.sh && \
    echo "######################################" && \
    echo "# Configure VNC, XRDP, and the users #" && \
    echo "######################################" && \
    echo "# For Remote Desktop issues with Java Swing rendering, use xserverbpp=24:" && \
    echo "# https://stackoverflow.com/a/37428300/1293660" && \
    echo "# Change the default of sudo to use -E and pass all environment variables" && \
    mkdir /root/.vnc && \
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
    sed -i 's/code=20/code=20\nxserverbpp=24/g' /etc/xrdp/xrdp.ini && \
    printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec xfce4-session\n' | sudo tee -a /root/.vnc/xstartup && \
    chmod a+x /root/.vnc/xstartup && \
    cp /root/.vnc/xstartup /home/was/.vnc/xstartup && \
    chown was:root /home/was/.vnc/xstartup && \
    echo "#####################" && \
    echo "# Configure rsyslog #" && \
    echo "#####################" && \
    sed -i 's/\(.*imjournal.*\)/#\1/g' /etc/rsyslog.conf && \
    sed -i 's/\(.*SysSock.Use.*\)/#\1/g' /etc/rsyslog.conf && \
    sed -i 's/imuxsock"/imuxsock")/g' /etc/rsyslog.conf && \
    echo "#########################" && \
    echo "# Configure supervisord #" && \
    echo "#########################" && \
    echo "# https://docs.docker.com/config/containers/multi-service_container/" && \
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
password={SHA}REPLACEPASSWORD\n\
\n\
[rpcinterface:supervisor]\n\
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface\n\
\n\
[supervisorctl]\n\
serverurl=unix:///var/run/supervisor/supervisor.sock\n\
\n\
[include]\n\
files=/etc/supervisord.d/*.supervisord.conf\n\
\n' | sudo tee /etc/supervisord.conf && \
    printf '\n\
[program:rsyslog]\n\
command=/usr/sbin/rsyslogd -n\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=1\n\
\n' | sudo tee /etc/supervisord.d/rsyslog.supervisord.conf && \
    printf '\n\
[program:xrdp]\n\
command=/usr/sbin/xrdp -nodaemon\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=20\n\
\n' | sudo tee /etc/supervisord.d/xrdp.supervisord.conf && \
    printf '\n\
[program:xrdp-sesman]\n\
command=/usr/sbin/xrdp-sesman --nodaemon\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=25\n\
\n' | sudo tee /etc/supervisord.d/xrdp-sesman.supervisord.conf && \
    printf '\n\
[program:ssh]\n\
command=/usr/sbin/sshd -D\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=30\n\
\n' | sudo tee /etc/supervisord.d/ssh.supervisord.conf && \
    printf '\n\
[program:vncserver1]\n\
command=/usr/bin/vncserver :1 -fg\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=50\n\
\n' | sudo tee /etc/supervisord.d/vncserver1.supervisord.conf && \
    printf '\n\
[program:vncserver2]\n\
command=/usr/sbin/runuser -l was -c "/usr/bin/vncserver :2 -fg"\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=50\n\
\n' | sudo tee /etc/supervisord.d/vncserver2.supervisord.conf && \
    printf '\n\
[program:slapd]\n\
command=/usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://"\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
priority=60\n\
startsecs=0\n\
\n' | sudo tee /etc/supervisord.d/slapd.supervisord.conf && \
    echo "# Print environment variables inherited by supervisord-spawned programs" && \
    printf '\n\
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
\n' | sudo tee /etc/supervisord.d/debugsupervisord.supervisord.conf && \
    sudo mkdir -p /var/run/supervisor/ && \
    echo "# If a CMD is specified or a program through docker run," && \
    echo "# then start supervisord in the background and run the CMD." && \
    echo "# Otherwise (the default), run supervisord in the foreground." && \
    echo "# This is required to run as root to properly inherit core" && \
    echo "# dump ulimits, so child containers must always go back to" && \
    echo "# USER root before ENTRYPOINT/CMD is run. Attempted" && \
    echo "# with sudo but ulimits don't pass through." && \
    printf '#!/bin/sh\n\
ssh-keygen -A || exit 1\n\
\n\
if [ -e /usr/local/bin/extended_entrypoint.sh ]; then\n\
  chmod a+x /usr/local/bin/extended_entrypoint.sh\n\
  /usr/local/bin/extended_entrypoint.sh || exit 1\n\
fi\n\
\n\
if [ "$#" -gt 0 ]; then\n\
  supervisord -c /etc/supervisord.conf &> /var/log/supervisord.log || exit 1 &\n\
  exec "$@" || exit 1\n\
else\n\
  supervisord -n -c /etc/supervisord.conf || exit 1\n\
fi\n\
\n\
#Old code when CMD was added as a supervised program\n\
#if [ "$#" -gt 0 ]; then\n\
#  printf "[program:cmd]\\ncommand=$@\\nstdout_logfile=/dev/stdout\\nstdout_logfile_maxbytes=0\\nredirect_stderr=true\\n" | tee /etc/supervisord.d/cmd.supervisord.conf > /dev/null\n\
#fi\n\
#supervisord -n -c /etc/supervisord.conf || exit 1\n\
\n' | sudo tee -a /usr/local/bin/entrypoint.sh && chmod a+rx /usr/local/bin/entrypoint.sh && \
    echo "######################" && \
    echo "# XFCE configuration #" && \
    echo "######################" && \
    echo "# polkit crashes on login. There is a discussion on the Fedora mailing list with" && \
    echo "# the only workaround being to start vncserver through SSH. Removing it" && \
    echo "# from startup doesn't seem to hurt too much." && \
    mv /etc/xdg/autostart/xfce-polkit.desktop /etc/xdg/autostart/xfce-polkit.desktop.disabled && \
    echo "#############" && \
    echo "# Utilities #" && \
    echo "#############" && \
    echo "# https://ant.apache.org/" && \
    ( \
      cd /opt/ && \
      sudo wget -q https://www.apache.org/dist/ant/binaries/apache-ant-1.10.7-bin.zip && \
      sudo unzip -q apache-ant*.zip && \
      sudo rm -f apache-ant*.zip && \
      sudo mv apache-ant* apache-ant \
    ) && \
    echo "# https://github.com/brendangregg/FlameGraph" && \
    sudo git clone https://github.com/brendangregg/FlameGraph /opt/FlameGraph && \
    echo "# https://github.com/nmonvisualizer/nmonvisualizer" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/nmonvisualizer/nmonvisualizer && \
      cd /opt/nmonvisualizer/ && \
      sudo ANT_OPTS=-Dfile.encoding=iso-8859-1 /opt/apache-ant/bin/ant && \
      sudo mv NMONVisualizer*.jar NMONVisualizer.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=NMON Visualizer\nExec=java -jar /opt/nmonvisualizer/NMONVisualizer.jar\nPath=~/\nTerminal=false\n' >> nmonvisualizer.desktop && \
      sudo chmod a+x nmonvisualizer.desktop && \
      sudo ln -s /opt/nmonvisualizer/nmonvisualizer.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/nmonvisualizer.desktop /home/was/Desktop/ \
    ) && \
    echo "# http://www-01.ibm.com/support/docview.wss?uid=swg21115785" && \
    ( \
      sudo mkdir /opt/linperf/ && \
      cd /opt/linperf/ && \
      sudo wget -q -O linperf.sh "https://www.ibm.com/support/pages/sites/default/files/inline-files/\$FILE/linperf.sh" && \
      sudo chmod a+x linperf.sh \
    ) && \
    echo "# https://jmeter.apache.org/" && \
    ( \
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
    ) && \
    echo "# https://github.com/iovisor/bcc" && \
    echo "# https://github.com/iovisor/bcc/issues/281" && \
    echo "# https://github.com/iovisor/bcc/pull/279/commits/c48f9d9c3d438e839eb2bfe0a2ed1a321b4e946d" && \
    echo "# Some kernels don't have CONFIG_TRACING=y CONFIG_EVENT_TRACING=y, so memleak.py won't work:" && \
    echo "# https://github.com/iovisor/bcc/issues/1530" && \
    sudo git clone https://github.com/iovisor/bcc /opt/bcc && \
    echo "# Install some Node basics" && \
    ( \
      cd /opt/ && \
      sudo npm install express --save \
    ) && \
    echo "# Some Docker hosts run a different kernel than what gets installed above. The following hack" && \
    echo "# won't always work but it might for some cases (e.g. bcc)." && \
    echo "# Useless anyway without CONFIG_TRACING, so don't bother with the hack." && \
    echo "# See https://github.com/iovisor/bcc/issues/1000" && \
    echo "# Install VS Code: https://code.visualstudio.com/docs/setup/linux" && \
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    printf '[code]\n\
name=Visual Studio Code\n\
baseurl=https://packages.microsoft.com/yumrepos/vscode\n\
enabled=1\n\
gpgcheck=1\n\
gpgkey=https://packages.microsoft.com/keys/microsoft.asc\n\
\n' | sudo tee /etc/yum.repos.d/vscode.repo && \
    sudo dnf install -y code && \
    echo "# We have to stay below Gradle V5 for deprecated/removed Gradle features used by older projects" && \
    ( \
      cd /opt/ && \
      sudo wget -q -O gradle.zip https://services.gradle.org/distributions/gradle-4.10.2-bin.zip && \
      sudo unzip -q gradle.zip && \
      sudo rm -f gradle.zip \
    ) && \
    sudo ln -s /opt/gradle-4.10.2/bin/gradle /usr/local/bin/gradle

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /usr/local/bin/setpassword.sh

RUN echo "############################" && \
    echo "# Final user configuration #" && \
    echo "############################" && \
    echo "# root's Desktop cannot take links (it doesn't work in this image seemingly because of some D-Bus/XFCE issue)" && \
    sudo chmod a+x /usr/share/applications/firefox.desktop && \
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
    sudo ln -s /usr/share/applications/libreoffice-writer.desktop /home/was/Desktop/ && \
    sudo chmod a+x /usr/share/applications/code.desktop && \
    sudo ln -s /usr/share/applications/code.desktop /home/was/Desktop/ && \
    echo "# Strange error trying to launch Wireshark:" && \
    echo "# error while loading shared libraries: libQt5Core.so.5: cannot open shared object file: No such file or directory" && \
    echo "# https://superuser.com/questions/1347723/" && \
    sudo strip --remove-section=.note.ABI-tag /usr/lib64/libQt5Core.so.5 && \
    echo "# Allow the was user to perform Wireshark captures:" && \
    echo "# This doesn't seem to actually work; instead, use command line tcpdump. Leaving here for completeness." && \
    sudo usermod -a -G wireshark was && \
    echo "# Cannot set background before logging in" && \
    printf '#!/bin/sh\n\
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/image-style -s 0\n\
\n' > /home/was/Desktop/reset_desktop_background.sh && chmod a+x /home/was/Desktop/reset_desktop_background.sh && \
    echo "# Set the default browser" && \
    sudo mkdir -p /root/.config/xfce4/ && \
    printf 'WebBrowser=firefox' | sudo tee /root/.config/xfce4/helpers.rc && \
    sudo mkdir -p /home/was/.config/xfce4/ && \
    printf 'WebBrowser=firefox' | sudo tee /home/was/.config/xfce4/helpers.rc && \
    sudo chown -R was:root /home/was/.config && \
    echo "################" && \
    echo "# Finalization #" && \
    echo "################" && \
    echo "# Set the default PDF reader to xreader; otherwise, the default" && \
    echo "# becomes LibreOffice Draw which isn't a great PDF viewer." && \
    xdg-mime default xreader.desktop application/pdf

# cn=Manager,dc=example,dc=com
RUN --mount=type=secret,id=remotepassword \
    sed -i 's/my-domain/example/g' /usr/share/openldap-servers/slapd.ldif && \
    mkdir -p /var/lib/ldap && \
    rm -rf /etc/openldap/slapd.d/* && \
    slapadd -n 0 -F /etc/openldap/slapd.d -l /usr/share/openldap-servers/slapd.ldif && \
    chown -R ldap:ldap /var/lib/ldap && \
    echo "olcAllows: bind_v2 update_anon" >> '/etc/openldap/slapd.d/cn=config.ldif' && \
    echo "olcLogFile: /var/log/slapd.log" >> '/etc/openldap/slapd.d/cn=config.ldif' && \
    printf 'dn: olcDatabase={2}mdb,cn=config\n\
changetype: modify\n\
replace: olcRootPW\n\
olcRootPW: %s\n\
\n' "$(slappasswd -s "$(echo -n "$(sudo head -n 1 /root/password.txt)")")" | sudo tee /root/openldapadminpwd.ldif && \
    printf 'dn: dc=example,dc=com\n\
objectclass: dcObject\n\
objectclass: organization\n\
o: Example Company\n\
dc: example\n\
\n\
dn: cn=Manager,dc=example,dc=com\n\
objectclass: organizationalRole\n\
cn: Manager\n\
\n' | sudo tee /root/openldapmanager.ldif && \
    sudo /usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://" && \
    sudo ldapmodify -H ldapi:// -Y EXTERNAL -f /root/openldapadminpwd.ldif && \
    sudo ldapadd -x -D "cn=Manager,dc=example,dc=com" -w "$(echo -n "$(sudo head -n 1 /root/password.txt)")" -f /root/openldapmanager.ldif && \
    sudo ldapadd -Y EXTERNAL -H ldapi:// -f /etc/openldap/schema/cosine.ldif && \
    sudo ldapadd -Y EXTERNAL -H ldapi:// -f /etc/openldap/schema/nis.ldif && \
    sudo ldapadd -Y EXTERNAL -H ldapi:// -f /etc/openldap/schema/inetorgperson.ldif && \
    printf 'dn: ou=Users,dc=example,dc=com\n\
objectClass: organizationalUnit\n\
ou: Users\n\
\n\
dn: cn=Admin1,ou=Users,dc=example,dc=com\n\
cn: Admin1\n\
sn: Admin1\n\
objectClass: inetOrgPerson\n\
userPassword: %s\n\
uid: Admin1\n\
\n\
dn: cn=User2,ou=Users,dc=example,dc=com\n\
cn: User2\n\
sn: User2\n\
objectClass: inetOrgPerson\n\
userPassword: %s\n\
uid: User2\n\
\n\
dn: cn=User3,ou=Users,dc=example,dc=com\n\
cn: User3\n\
sn: User3\n\
objectClass: inetOrgPerson\n\
userPassword: %s\n\
uid: User3\n\
\n\
dn: ou=Groups,dc=example,dc=com\n\
objectClass: organizationalUnit\n\
ou: Groups\n\
\n\
dn: cn=Administrators,ou=Users,dc=example,dc=com\n\
cn: Administrators\n\
objectClass: groupOfNames\n\
member: cn=Admin1,ou=Users,dc=example,dc=com\n\
\n\
dn: cn=Group1,ou=Users,dc=example,dc=com\n\
cn: Group1\n\
objectClass: groupOfNames\n\
member: cn=User2,ou=Users,dc=example,dc=com\n\
member: cn=User3,ou=Users,dc=example,dc=com\n\
\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" | sudo tee /root/basicorg.ldif && \
    sudo ldapadd -x -D "cn=Manager,dc=example,dc=com" -w "$(echo -n "$(sudo head -n 1 /root/password.txt)")" -f /root/basicorg.ldif && \
    echo "# Configure logging: https://www.openldap.org/doc/admin24/slapdconfig.html#loglevel%20%3Clevel%3E" && \
    printf 'dn: cn=config\n\
changetype: modify\n\
replace: olcLogLevel\n\
olcLogLevel: stats stats2\n\
\n\
dn: olcDatabase={2}mdb,cn=config\n\
changetype: modify\n\
add: olcDbMaxSize\n\
olcDbMaxSize: 1073741824\n\
\n' | sudo tee /root/openldaploggingdb.ldif && \
    sudo ldapmodify -H ldapi:// -Y EXTERNAL -f /root/openldaploggingdb.ldif && \
    echo "local4.* /var/log/slapd.log" | sudo tee -a /etc/rsyslog.conf

USER was
RUN xdg-mime default xreader.desktop application/pdf

EXPOSE 22 3389 5901 5902

# Last statement must be switching to root for supervisord
USER root

# Random tips:
# * List all available Gnome settings: gsettings list-recursively
# * Available vncserver options: vncserver --help; Xvnc --help

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

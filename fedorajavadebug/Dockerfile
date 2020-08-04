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
#     DOCKER_BUILDKIT=1 docker build --progress=plain -t kgibm/fedorajavadebug .
#   With remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt --progress=plain -t kgibm/fedorajavadebug .
# Step 3: Run the Docker image:
#   docker run --cap-add SYS_PTRACE --cap-add NET_ADMIN --ulimit core=-1 --ulimit memlock=-1 --ulimit stack=-1 --shm-size="256m" --rm -p 5901:5901 -p 5902:5902 -p 22:22 -p 3390:3389 -it kgibm/fedorajavadebug
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

# Based on https://github.com/kgibm/dockerdebug/blob/master/fedoradebug/Dockerfile
FROM kgibm/fedoradebug

LABEL maintainer="kevin.grigorenko@us.ibm.com"

####################
# Install IBM Java #
####################

# https://github.com/ibmruntimes/ci.docker/blob/master/ibmjava/8/sdk/ubuntu/Dockerfile
COPY --from=ibmjava:8-sdk /opt/ibm/java /opt/ibm/java

########################
# Put IBM Java on PATH #
########################

RUN echo "# https://fedoraproject.org/wiki/Alternatives_system" && \
    sudo alternatives --install \
         /usr/bin/java java /opt/ibm/java/bin/java 99999999 \
         --slave /usr/bin/javac javac /opt/ibm/java/bin/javac \
         --slave /usr/bin/jar jar /opt/ibm/java/bin/jar \
         --slave /usr/bin/javah javah /opt/ibm/java/bin/javah \
         --slave /usr/bin/javap javap /opt/ibm/java/bin/javap \
         --slave /usr/bin/javadoc javadoc /opt/ibm/java/bin/javadoc \
         --slave /usr/bin/javaws javaws /opt/ibm/java/bin/javaws \
         --slave /usr/bin/jconsole jconsole /opt/ibm/java/bin/jconsole \
         --slave /usr/bin/jdmpview jdmpview /opt/ibm/java/bin/jdmpview \
         --slave /usr/bin/keytool keytool /opt/ibm/java/bin/keytool \
         --slave /usr/bin/jdb jdb /opt/ibm/java/bin/jdb \
         --slave /usr/bin/ControlPanel ControlPanel /opt/ibm/java/bin/ControlPanel \
         --family ibmjava && \
    sudo alternatives --auto java && \
    echo "###############" && \
    echo "# Install MAT #" && \
    echo "###############" && \
    echo "# Eclipse Memory Analyzer Tool (MAT)" && \
    echo "# https://www.eclipse.org/mat/" && \
    sudo mkdir /opt/mat/ && \
    sudo wget -q -O /opt/MemoryAnalyzer.zip "$(curl -s https://www.eclipse.org/mat/downloads.php | grep "Linux (x86_64/GTK+) RCP" | sed 's/.*href="//g' | sed 's/".*//g' | sed 's/^http:/https:/g' | sed 's/$/\&r=1/g')" && \
    ( \
      cd /opt/ && \
      sudo unzip -q MemoryAnalyzer.zip && \
      sudo rm -f /opt/MemoryAnalyzer.zip && \
      cd /opt/mat && \
      sudo mkdir /home/was/mat/ && \
      sudo chown -R was:root /home/was/mat/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=MAT\nExec=/opt/mat/MemoryAnalyzer\nPath=mat/\nTerminal=false\n' >> mat.desktop && \
      sudo chmod a+x mat.desktop && \
      sudo ln -s /opt/mat/mat.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/mat.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM Diagnostic Tool Framework for Java (DTFJ)" && \
    echo "# https://www.ibm.com/support/knowledgecenter/en/SSYKE2_8.0.0/com.ibm.java.vm.80.doc/docs/dtfj.html" && \
    echo "# https://developer.ibm.com/javasdk/tools/" && \
    sudo /opt/mat/MemoryAnalyzer -nosplash -application org.eclipse.equinox.p2.director \
                                 -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/dtfj/ \
                                 -installIU com.ibm.dtfj.feature.feature.group && \
    echo "# IBM Monitoring and Diagnostic Tools - Extensions for Memory Analyzer (IEMA)" && \
    echo "# https://developer.ibm.com/javasdk/tools/" && \
    sudo /opt/mat/MemoryAnalyzer -nosplash -application org.eclipse.equinox.p2.director \
                                 -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.cognosbi.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.ctg.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.jse.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.util.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.was.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.wesb.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.wps.feature.feature.group && \
    echo "# IBM Java >= 8.0.5.35 and < 8.0.6.0 creates dumps that the public MAT DTFJ can't read, so override it in MAT with a recent JDK's DTFJ." && \
    echo "# https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/" && \
    sudo cp -f /opt/ibm/java/jre/lib/ddr/j9ddr.jar /opt/mat/configuration/org.eclipse.osgi/*/data/*/plugins/com.ibm.dtfj.j9_*/lib/j9ddr.jar && \
    sudo cp -f /opt/ibm/java/jre/lib/ext/dtfj.jar /opt/mat/configuration/org.eclipse.osgi/*/data/*/plugins/com.ibm.dtfj.j9_*/lib/dtfj.jar && \
    sudo mkdir -p /home/was/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    sudo chown -R was /home/was/workspace/ && \
    sudo mkdir -p /root/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    echo "# Increase the default max heap size" && \
    sudo sed -i 's/-Xmx1024m/-Xmx2g/g' /opt/mat/MemoryAnalyzer.ini && \
    printf 'bytes_display=Smart\n\
eclipse.preferences.version=1\n\
hideGettingStartedWizard=false\n\
hide_welcome_screen=true\n\
' > /home/was/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs && \
    sudo cp /home/was/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs /root/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    sudo chown root /home/was/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs && \
    echo "# IBM Runtime Diagnostic Code Injection for the Java Platform (RDCI or Java Surgery)" && \
    echo "# https://www.ibm.com/support/pages/ibm-runtime-diagnostic-code-injection-java-platform-java-surgery" && \
    ( \
      sudo mkdir /opt/surgery/ && \
      cd /opt/surgery/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/surgery/surgery.jar \
    ) && \
    echo "# IBM Thread and Monitor Dump Analyzer (TMDA)" && \
    echo "# https://www.ibm.com/support/pages/ibm-thread-and-monitor-dump-analyzer-java-tmda" && \
    ( \
      sudo mkdir /opt/tmda/ && \
      cd /opt/tmda/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/jca/jca467.jar && \
      sudo mkdir /home/was/tmda/ && \
      sudo chown -R was:root /home/was/tmda/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=TMDA\nExec=java -jar /opt/tmda/jca467.jar\nPath=tmda/\nTerminal=false\n' >> tmda.desktop && \
      sudo chmod a+x tmda.desktop && \
      sudo ln -s /opt/tmda/tmda.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/tmda.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM ClassLoader Analyzer" && \
    echo "# https://www.ibm.com/support/pages/ibm-classloader-analyzer" && \
    ( \
      sudo mkdir /opt/classloaderanalyzer/ && \
      cd /opt/classloaderanalyzer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/ica/ica107.jar && \
      sudo mkdir /home/was/cla/ && \
      sudo chown -R was:root /home/was/cla/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Classloader Analyzer\nExec=java -jar /opt/classloaderanalyzer/ica107.jar\nPath=cla/\nTerminal=false\n' >> cla.desktop && \
      sudo chmod a+x cla.desktop && \
      sudo ln -s /opt/classloaderanalyzer/cla.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/cla.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM HeapAnalyzer" && \
    echo "# https://www.ibm.com/support/pages/ibm-heapanalyzer" && \
    ( \
      sudo mkdir /opt/heapanalyzer/ && \
      cd /opt/heapanalyzer/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/HeapAnalyzer/ha457.jar && \
      sudo mkdir /home/was/ha/ && \
      sudo chown -R was:root /home/was/ha/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Heap Analyzer\nExec=java -jar /opt/heapanalyzer/ha457.jar\nPath=ha/\nTerminal=false\n' >> ha.desktop && \
      sudo chmod a+x ha.desktop && \
      sudo ln -s /opt/heapanalyzer/ha.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/ha.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM Pattern Modeling and Analysis Tool for Java Garbage Collector (PMAT)" && \
    echo "# https://www.ibm.com/support/pages/ibm-pattern-modeling-and-analysis-tool-java-garbage-collector-pmat" && \
    ( \
      sudo mkdir /opt/pmat/ && \
      cd /opt/pmat/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/pmat/ga458.jar && \
      sudo mkdir /home/was/pmat/ && \
      sudo chown -R was:root /home/was/pmat/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=PMAT\nExec=java -jar /opt/pmat/ga458.jar\nPath=pmat/\nTerminal=false\n' >> pmat.desktop && \
      sudo chmod a+x pmat.desktop && \
      sudo ln -s /opt/pmat/pmat.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/pmat.desktop /home/was/Desktop/ \
    ) && \
    echo "#########################" && \
    echo "# Install Health Center #" && \
    echo "#########################" && \
    echo "# Eclipse > Luna has some strange StackOverflowErrors with Health Center, so we install an old Eclipse for HC separately." && \
    echo "# https://www.eclipse.org/downloads/packages/release/photon/r/eclipse-ide-java-ee-developers" && \
    echo "# https://www.eclipse.org/downloads/packages/release" && \
    sudo wget -q -O /opt/eclipse_old.tar.gz "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/luna/SR2/eclipse-jee-luna-SR2-linux-gtk-x86_64.tar.gz&r=1" && \
    ( \
      cd /opt/ && \
      sudo tar xzf eclipse_old.tar.gz && \
      sudo rm -f /opt/eclipse_old.tar.gz && \
      sudo mv /opt/eclipse /opt/eclipse_old \
    ) && \
    sudo sed -i 's/-Xmx512m/-Xmx2048m/g' /opt/eclipse_old/eclipse.ini && \
    echo "# IBM Monitoring and Diagnostic Tools - Health Center" && \
    echo "# https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.healthcenter.doc/homepage/plugin-homepage-hc.html" && \
    echo "# https://developer.ibm.com/javasdk/tools/" && \
    sudo /opt/eclipse_old/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                                  -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/healthcenter/ \
                                  -installIU com.ibm.java.diagnostics.healthcenter.core.feature.feature.group \
                                  -installIU com.ibm.java.diagnostics.healthcenter.gui.feature.feature.group && \
    sudo mkdir /home/was/hc/ && \
    sudo chown -R was:root /home/was/hc/ && \
    sudo printf '[Desktop Entry]\nType=Application\nName=Health Center\nExec=/opt/eclipse_old/eclipse -data workspace_hc -perspective com.ibm.java.diagnostics.healthcenter.gui.perspective.status\nPath=hc/\nTerminal=false\n' >> /opt/eclipse_old/hc.desktop && \
    sudo chmod a+x /opt/eclipse_old/hc.desktop && \
    sudo ln -s /opt/eclipse_old/hc.desktop /opt/programs/ && \
    sudo ln -s /opt/programs/hc.desktop /home/was/Desktop/ && \
    echo "# Required after installing anything into Eclipse" && \
    sudo chmod -R a+w /opt/eclipse_old/configuration && \
    echo "#########################" && \
    echo "# Install GCMV and IDDE #" && \
    echo "#########################" && \
    echo "# Eclipse 2020-03" && \
    echo "# https://www.eclipse.org/downloads/packages/release/2020-03/r/eclipse-ide-enterprise-java-developers" && \
    echo "# https://help.eclipse.org/2020-03/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fmisc%2Fruntime-options.html" && \
    sudo wget -q -O /opt/eclipse-jee-2020-03-R-incubation-linux-gtk-x86_64.tar.gz "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2020-03/R/eclipse-jee-2020-03-R-incubation-linux-gtk-x86_64.tar.gz&r=1" && \
    ( \
      cd /opt/ && \
      sudo tar xzf eclipse-jee-2020-03-R-incubation-linux-gtk-x86_64.tar.gz && \
      sudo rm -f /opt/eclipse-jee-2020-03-R-incubation-linux-gtk-x86_64.tar.gz && \
      cd /opt/eclipse && \
      sudo mkdir /home/was/eclipse/ && \
      sudo chown -R was:root /home/was/eclipse/ && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Eclipse\nExec=/opt/eclipse/eclipse -data workspace\nPath=eclipse/\nTerminal=false\n' >> eclipse.desktop && \
      sudo chmod a+x eclipse.desktop && \
      sudo ln -s /opt/eclipse/eclipse.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/eclipse.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM Monitoring and Diagnostic Tools - Garbage Collection and Memory Visualizer (GCMV)" && \
    echo "# https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.visualizer.doc/homepage/plugin-homepage-gcmv.html" && \
    echo "# https://developer.ibm.com/javasdk/tools/" && \
    sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/gcmv/ \
                              -installIU com.ibm.java.diagnostics.visualizer.feature.feature.group && \
    sudo mkdir /home/was/gcmv/ && \
    sudo chown -R was:root /home/was/gcmv/ && \
    sudo printf '[Desktop Entry]\nType=Application\nName=GCMV\nExec=/opt/eclipse/eclipse -data workspace_gcmv -perspective com.ibm.java.diagnostics.visualizer.gui.perspective\nPath=gcmv/\nTerminal=false\n' >> /opt/eclipse/gcmv.desktop && \
    sudo chmod a+x /opt/eclipse/gcmv.desktop && \
    sudo ln -s /opt/eclipse/gcmv.desktop /opt/programs/ && \
    sudo ln -s /opt/programs/gcmv.desktop /home/was/Desktop/ && \
    echo "# IBM Monitoring and Diagnostic Tools - Interactive Diagnostic Data Explorer (IDDE)" && \
    echo "# https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.idde.doc/homepage/plugin-homepage-idde.html" && \
    echo "# https://developer.ibm.com/javasdk/tools/" && \
    sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/idde/ \
                              -installIU com.ibm.java.diagnostics.idde.feature.feature.group \
                              -installIU com.ibm.java.diagnostics.idde.extensions.feature.feature.group && \
    sudo mkdir /home/was/idde/ && \
    sudo chown -R was:root /home/was/idde/ && \
    sudo printf '[Desktop Entry]\nType=Application\nName=IDDE\nExec=/opt/eclipse/eclipse -data workspace_idde -perspective com.ibm.java.diagnostics.idde.perspective\nPath=idde/\nTerminal=false\n' >> /opt/eclipse/idde.desktop && \
    sudo chmod a+x /opt/eclipse/idde.desktop && \
    sudo ln -s /opt/eclipse/idde.desktop /opt/programs/ && \
    sudo ln -s /opt/programs/idde.desktop /home/was/Desktop/ && \
    echo "# Required after installing anything into Eclipse" && \
    sudo chmod -R a+w /opt/eclipse/configuration && \
    echo "# https://github.com/kgibm/java_miscellaneous" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/java_miscellaneous \
    ) && \
    echo "# https://github.com/kgibm/SimulateJavaOOM" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/SimulateJavaOOM \
    ) && \
    sudo git clone https://github.com/eclipse/openj9 /usr/local/src/openj9 && \
    sudo git clone https://github.com/eclipse/openj9-omr /usr/local/src/openj9-omr && \
    sudo chmod -R a+w /usr/local/src/openj9 && \
    sudo chmod -R a+w /usr/local/src/openj9-omr && \
    echo "# Install MAT Source (still requires configuration in Eclipse): https://wiki.eclipse.org/MemoryAnalyzer/Contributor_Reference" && \
    sudo git clone git://git.eclipse.org/gitroot/mat/org.eclipse.mat.git /usr/local/src/mat && \
    sudo chmod -R a+w /usr/local/src/mat && \
    sudo mkdir /opt/mat/dev/ && \
    ( \
      cd /opt/mat/dev/ && \
      sudo wget -q http://www.eclipse.org/mat/dev/mat_code_formatter.xml && \
      sudo wget -q https://wiki.eclipse.org/MemoryAnalyzer/Contributor_Reference && \
      sudo wget -O updatesite.zip -q $(curl -s https://www.eclipse.org/mat/downloads.php | grep "Archived Update Site" | sed 's/.*href="//g' | sed 's/".*/\&r=1/g') && \
      sudo unzip -q updatesite.zip && \
      sudo rm -f updatesite.zip \
    )

RUN echo "############################" && \
    echo "# OpenJDK + HotSpot/OpenJ9 #" && \
    echo "############################" && \
    echo "# https://adoptopenjdk.net/" && \
    for v in 8 11 14; do \
        for j in openj9 hotspot; do \
          ( \
            sudo mkdir /opt/openjdk${v}_${j}/ && \
            echo "# Downloading OpenJDK ${v}_${j}" && \
            sudo wget -q -O /opt/openjdk${v}_${j}/adoptopenjdk.tar.gz \
              $(curl --silent "https://api.adoptopenjdk.net/v2/latestAssets/releases/openjdk${v}?release=latest&openjdk_impl=${j}&os=linux&arch=x64&type=jdk&heap_size=normal" | grep binary_link | sed 's/.*https/https/g' | sed 's/".*//g') && \
            cd /opt/openjdk${v}_${j}/ && \
            sudo tar xzf /opt/openjdk${v}_${j}/adoptopenjdk.tar.gz && \
            sudo mv jdk* jdk && \
            sudo alternatives --install \
                /usr/bin/java java /opt/openjdk${v}_${j}/jdk/bin/java 89999999 \
                --slave /usr/bin/javac javac /opt/openjdk${v}_${j}/jdk/bin/javac \
                --slave /usr/bin/jar jar /opt/openjdk${v}_${j}/jdk/bin/jar \
                --slave /usr/bin/javah javah /opt/openjdk${v}_${j}/jdk/bin/javah \
                --slave /usr/bin/javap javap /opt/openjdk${v}_${j}/jdk/javap \
                --slave /usr/bin/javadoc javadoc /opt/openjdk${v}_${j}/jdk/bin/javadoc \
                --slave /usr/bin/javaws javaws /opt/openjdk${v}_${j}/jdk/bin/javaws \
                --slave /usr/bin/jconsole jconsole /opt/openjdk${v}_${j}/jdk/bin/jconsole \
                --slave /usr/bin/jdmpview jdmpview /opt/openjdk${v}_${j}/jdk/bin/jdmpview \
                --slave /usr/bin/keytool keytool /opt/openjdk${v}_${j}/jdk/bin/keytool \
                --slave /usr/bin/jdb jdb /opt/openjdk${v}_${j}/jdk/bin/jdb \
                --slave /usr/bin/ControlPanel ControlPanel /opt/openjdk${v}_${j}/jdk/bin/ControlPanel \
                --family openjdk && \
            sudo alternatives --auto java \
          ) \
        done \
      done

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /usr/local/bin/setpassword.sh

# Last statement must be switching to root for supervisord
USER root

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
#     DOCKER_BUILDKIT=1 docker build -t kgibm/fedorajavadebug .
#   With remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt -t kgibm/fedorajavadebug .
# Step 3: Run the Docker image:
#   docker run --cap-add SYS_PTRACE --ulimit core=-1 --ulimit memlock=-1 --ulimit stack=-1 --shm-size="256m" --rm -p 5901:5901 -p 5902:5902 -p 22:22 -p 3390:3389 -it kgibm/fedorajavadebug
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

# https://fedoraproject.org/wiki/Alternatives_system
RUN for i in java javac jar javah javap javadoc javaws jconsole jdmpview keytool jdb ControlPanel; do \
      alternatives --install /usr/bin/$i $i /opt/ibm/java/bin/$i 99999999 --family ibmjava && \
      alternatives --auto $i; \
    done && \
    echo "###############" && \
    echo "# Install MAT #" && \
    echo "###############" && \
    echo "# Eclipse Memory Analyzer Tool (MAT)" && \
    echo "# https://www.eclipse.org/mat/" && \
    sudo mkdir /opt/mat/ && \
    sudo wget -q -O /opt/MemoryAnalyzer.zip $(curl -s https://www.eclipse.org/mat/downloads.php | grep "Linux (x86_64/GTK+) RCP" | sed 's/.*href="//g' | sed 's/".*//g' | sed 's/^http:/https:/g' | sed 's/$/\&r=1/g') && \
    ( \
      cd /opt/ && \
      sudo unzip -q MemoryAnalyzer.zip && \
      sudo rm -f /opt/MemoryAnalyzer.zip && \
      cd /opt/mat && \
      sudo printf '[Desktop Entry]\nType=Application\nName=MAT\nExec=/opt/mat/MemoryAnalyzer\nPath=~/\nTerminal=false\n' >> mat.desktop && \
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
    echo "# IBM Java >= 8.0.5.35 creates dumps that the public MAT DTFJ can't read yet, so use the JDK's DTFJ until that's fixed (TS002204896)." && \
    echo "# For some reason, using 8.0.5.37 JARs doesn't work, so we use 8.0.5.35." && \
    echo "# This has been fixed with https://github.com/eclipse/openj9/pull/6317 but isn't in a public release of IBM Java yet." && \
    printf 'INSTALLER_UI=silent\n\
USER_INSTALL_DIR=/opt/ibm/olderjava/8.0.5.35/\n\
LICENSE_ACCEPTED=TRUE' > /tmp/ibm-java.properties && \
    wget -q -O /tmp/ibm-java-sdk-archive.bin http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.5.35/linux/x86_64/ibm-java-sdk-8.0-5.35-x86_64-archive.bin && \
    chmod a+x /tmp/ibm-java-sdk-archive.bin && \
    /tmp/ibm-java-sdk-archive.bin -f /tmp/ibm-java.properties && \
    rm -f /tmp/ibm-java-sdk-archive.bin /tmp/ibm-java.properties && \
    sudo cp -f /opt/ibm/olderjava/8.0.5.35/jre/lib/ddr/j9ddr.jar /opt/mat/configuration/org.eclipse.osgi/*/data/*/plugins/com.ibm.dtfj.j9_*/lib/j9ddr.jar && \
    sudo cp -f /opt/ibm/olderjava/8.0.5.35/jre/lib/ext/dtfj.jar /opt/mat/configuration/org.eclipse.osgi/*/data/*/plugins/com.ibm.dtfj.j9_*/lib/dtfj.jar && \
    sudo sed -i 's/-vmargs/-vm\n\/opt\/ibm\/olderjava\/8.0.5.35\/bin\/\n-vmargs\n-Dosgi.clean=true/g' /opt/mat/MemoryAnalyzer.ini && \
    echo "# Disable MAT welcome screen" && \
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
    echo "# IBM HeapAnalyzer" && \
    echo "# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=4544bafe-c7a2-455f-9d43-eb866ea60091" && \
    ( \
      sudo mkdir /opt/heapanalyzer/ && \
      cd /opt/heapanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/HeapAnalyzer/ha456.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Heap Analyzer\nExec=java -jar /opt/heapanalyzer/ha456.jar\nPath=~/\nTerminal=false\n' >> ha.desktop && \
      sudo chmod a+x ha.desktop && \
      sudo ln -s /opt/heapanalyzer/ha.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/ha.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM Thread and Monitor Dump Analyzer (TMDA)" && \
    echo "# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=2245aa39-fa5c-4475-b891-14c205f7333c" && \
    ( \
      sudo mkdir /opt/tmda/ && \
      cd /opt/tmda/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/jca/jca463.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=TMDA\nExec=java -jar /opt/tmda/jca463.jar\nPath=~/\nTerminal=false\n' >> tmda.desktop && \
      sudo chmod a+x tmda.desktop && \
      sudo ln -s /opt/tmda/tmda.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/tmda.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM ClassLoader Analyzer" && \
    echo "# https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=a0a94b0d-38fe-4f4e-b2e6-4504b9d3f596" && \
    ( \
      sudo mkdir /opt/classloaderanalyzer/ && \
      cd /opt/classloaderanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/ica/ica107.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Classloader Analyzer\nExec=java -jar /opt/classloaderanalyzer/ica107.jar\nPath=~/\nTerminal=false\n' >> cla.desktop && \
      sudo chmod a+x cla.desktop && \
      sudo ln -s /opt/classloaderanalyzer/cla.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/cla.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM Pattern Modeling and Analysis Tool for Java Garbage Collector (PMAT)" && \
    echo "# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=22d56091-3a7b-4497-b36e-634b51838e11" && \
    ( \
      sudo mkdir /opt/pmat/ && \
      cd /opt/pmat/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/pmat/ga458.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=PMAT\nExec=java -jar /opt/pmat/ga458.jar\nPath=~/\nTerminal=false\n' >> pmat.desktop && \
      sudo chmod a+x pmat.desktop && \
      sudo ln -s /opt/pmat/pmat.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/pmat.desktop /home/was/Desktop/ \
    ) && \
    echo "# IBM Runtime Diagnostic Code Injection for the Java Platform (RDCI or Java Surgery)" && \
    echo "# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=7d3dc078-131f-404c-8b4d-68b3b9ddd07a" && \
    ( \
      sudo mkdir /opt/surgery/ && \
      cd /opt/surgery/ && \
      sudo wget -q https://public.dhe.ibm.com/software/websphere/appserv/support/tools/surgery/surgery.jar \
    ) && \
    echo "# IBM Trace and Request Analyzer for WebSphere Application Server" && \
    echo "# https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=39153aad-6203-40ef-b239-e41243e27792" && \
    ( \
      sudo mkdir /opt/tracerequestanalyzer/ && \
      cd /opt/tracerequestanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/tra/tra303.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Trace and Request Analyzer\nExec=java -jar /opt/tracerequestanalyzer/tra303.jar\nPath=~/\nTerminal=false\n' >> tra.desktop && \
      sudo chmod a+x tra.desktop && \
      sudo ln -s /opt/tracerequestanalyzer/tra.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/tra.desktop /home/was/Desktop/ \
    ) && \
    echo "#########################" && \
    echo "# Install Health Center #" && \
    echo "#########################" && \
    echo "# Eclipse > Luna has some strange StackOverflowErrors with Health Center, so we install an old Eclipse" && \
    echo "# for HC separately." && \
    echo "# https://www.eclipse.org/downloads/packages/release/photon/r/eclipse-ide-java-ee-developers" && \
    echo "# https://www.eclipse.org/downloads/packages/release" && \
    sudo wget -q -O /opt/eclipse_old.tar.gz "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/luna/SR2/eclipse-jee-luna-SR2-linux-gtk-x86_64.tar.gz&r=1" && \
    ( \
      cd /opt/ && \
      sudo tar xzf eclipse_old.tar.gz && \
      sudo rm -f /opt/eclipse_old.tar.gz && \
      sudo mv /opt/eclipse /opt/eclipse_old \
    ) && \
    echo "# IBM Monitoring and Diagnostic Tools - Health Center" && \
    echo "# https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.healthcenter.doc/homepage/plugin-homepage-hc.html" && \
    echo "# https://developer.ibm.com/javasdk/tools/" && \
    sudo /opt/eclipse_old/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                                  -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/healthcenter/ \
                                  -installIU com.ibm.java.diagnostics.healthcenter.core.feature.feature.group \
                                  -installIU com.ibm.java.diagnostics.healthcenter.gui.feature.feature.group && \
    sudo printf '[Desktop Entry]\nType=Application\nName=Health Center\nExec=/opt/eclipse_old/eclipse -data workspace_hc -perspective com.ibm.java.diagnostics.healthcenter.gui.perspective.status\nPath=~/\nTerminal=false\n' >> /opt/eclipse_old/hc.desktop && \
    sudo chmod a+x /opt/eclipse_old/hc.desktop && \
    sudo ln -s /opt/eclipse_old/hc.desktop /opt/programs/ && \
    sudo ln -s /opt/programs/hc.desktop /home/was/Desktop/ && \
    echo "# Remove the welcome screen. No obvious way to do this less dramatically." && \
    sudo rm -rf /opt/eclipse_old/plugins/org.eclipse.ui.intro* && \
    echo "# Required after installing anything into Eclipse" && \
    sudo chmod -R a+w /opt/eclipse_old/configuration && \
    echo "#########################" && \
    echo "# Install GCMV and IDDE #" && \
    echo "#########################" && \
    echo "# Eclipse 2019-03" && \
    echo "# https://www.eclipse.org/downloads/packages/release/2019-03/r/eclipse-ide-enterprise-java-developers" && \
    echo "# https://help.eclipse.org/2019-03/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fmisc%2Fruntime-options.html" && \
    sudo wget -q -O /opt/eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2019-03/R/eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz&r=1" && \
    ( \
      cd /opt/ && \
      sudo tar xzf eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz && \
      sudo rm -f /opt/eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz && \
      cd /opt/eclipse && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Eclipse\nExec=/opt/eclipse/eclipse -data workspace\nPath=~/\nTerminal=false\n' >> eclipse.desktop && \
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
    sudo printf '[Desktop Entry]\nType=Application\nName=GCMV\nExec=/opt/eclipse/eclipse -data workspace_gcmv -perspective com.ibm.java.diagnostics.visualizer.gui.perspective\nPath=~/\nTerminal=false\n' >> /opt/eclipse/gcmv.desktop && \
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
    sudo printf '[Desktop Entry]\nType=Application\nName=IDDE\nExec=/opt/eclipse/eclipse -data workspace_idde -perspective com.ibm.java.diagnostics.idde.perspective\nPath=~/\nTerminal=false\n' >> /opt/eclipse/idde.desktop && \
    sudo chmod a+x /opt/eclipse/idde.desktop && \
    sudo ln -s /opt/eclipse/idde.desktop /opt/programs/ && \
    sudo ln -s /opt/programs/idde.desktop /home/was/Desktop/ && \
    echo "# Remove the welcome screen. No obvious way to do this less dramatically." && \
    sudo rm /opt/eclipse/plugins/org.eclipse.ui.intro* && \
    echo "# Required after installing anything into Eclipse" && \
    sudo chmod -R a+w /opt/eclipse/configuration && \
    echo "############################" && \
    echo "# OpenJDK + HotSpot/OpenJ9 #" && \
    echo "############################" && \
    echo "# https://adoptopenjdk.net/" && \
    echo "# There is no "latest" link for the following builds, so we have to check each page and update" && \
    echo "# with the latest links." && \
    echo "# Last updated: 2019-07-29" && \
    echo "# https://adoptopenjdk.net/releases.html?variant=openjdk8&jvmVariant=openj9#x64_linux" && \
    ( \
      sudo mkdir /opt/openjdk8_openj9/ && \
      sudo wget -q -O /opt/openjdk8_openj9/openj9.tar.gz https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u222-b10_openj9-0.15.1/OpenJDK8U-jdk_x64_linux_openj9_8u222b10_openj9-0.15.1.tar.gz && \
      cd /opt/openjdk8_openj9/ && \
      sudo tar xzf /opt/openjdk8_openj9/openj9.tar.gz && \
      sudo mv jdk* jdk \
    ) && \
    echo "# https://adoptopenjdk.net/releases.html?variant=openjdk8&jvmVariant=hotspot#x64_linux" && \
    ( \
      sudo mkdir /opt/openjdk8_hotspot/ && \
      sudo wget -q -O /opt/openjdk8_hotspot/hotspot.tar.gz https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u222-b10/OpenJDK8U-jdk_x64_linux_hotspot_8u222b10.tar.gz && \
      cd /opt/openjdk8_hotspot/ && \
      sudo tar xzf /opt/openjdk8_hotspot/hotspot.tar.gz && \
      sudo mv jdk* jdk \
    ) && \
    echo "# https://adoptopenjdk.net/releases.html?variant=openjdk11&jvmVariant=openj9#x64_linux" && \
    ( \
      sudo mkdir /opt/openjdk11_openj9/ && \
      sudo wget -q -O /opt/openjdk11_openj9/openj9.tar.gz https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.4%2B11_openj9-0.15.1/OpenJDK11U-jdk_x64_linux_openj9_11.0.4_11_openj9-0.15.1.tar.gz && \
      cd /opt/openjdk11_openj9/ && \
      sudo tar xzf /opt/openjdk11_openj9/openj9.tar.gz && \
      sudo mv jdk* jdk \
    ) && \
    echo "# https://adoptopenjdk.net/releases.html?variant=openjdk11&jvmVariant=hotspot#x64_linux" && \
    ( \
      sudo mkdir /opt/openjdk11_hotspot/ && \
      sudo wget -q -O /opt/openjdk11_hotspot/hotspot.tar.gz https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.4%2B11/OpenJDK11U-jdk_x64_linux_hotspot_11.0.4_11.tar.gz && \
      cd /opt/openjdk11_hotspot/ && \
      sudo tar xzf /opt/openjdk11_hotspot/hotspot.tar.gz && \
      sudo mv jdk* jdk \
    ) && \
    echo "# https://adoptopenjdk.net/releases.html?variant=openjdk12&jvmVariant=openj9#x64_linux" && \
    ( \
      sudo mkdir /opt/openjdk12_openj9/ && \
      sudo wget -q -O /opt/openjdk12_openj9/openj9.tar.gz https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10_openj9-0.15.1/OpenJDK12U-jdk_x64_linux_openj9_12.0.2_10_openj9-0.15.1.tar.gz && \
      cd /opt/openjdk12_openj9/ && \
      sudo tar xzf /opt/openjdk12_openj9/openj9.tar.gz && \
      sudo mv jdk* jdk \
    ) && \
    echo "# https://adoptopenjdk.net/releases.html?variant=openjdk12&jvmVariant=hotspot#x64_linux" && \
    ( \
      sudo mkdir /opt/openjdk12_hotspot/ && \
      sudo wget -q -O /opt/openjdk12_hotspot/hotspot.tar.gz https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10/OpenJDK12U-jdk_x64_linux_hotspot_12.0.2_10.tar.gz && \
      cd /opt/openjdk12_hotspot/ && \
      sudo tar xzf /opt/openjdk12_hotspot/hotspot.tar.gz && \
      sudo mv jdk* jdk \
    ) && \
    echo "# https://github.com/kgibm/java_miscellaneous" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/java_miscellaneous \
    ) && \
    echo "# https://github.com/kgibm/SimulateJavaOOM" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/SimulateJavaOOM \
    )

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /setpassword.sh

# Last statement must be switching to root for supervisord
USER root

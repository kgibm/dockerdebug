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
#   docker run --cap-add SYS_PTRACE --ulimit core=-1 --rm -p 5901:5901 -p 5902:5902 -p 22:22 -p 3390:3389 -it kgibm/fedorajavadebug
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
#

FROM kgibm/fedoradebug

LABEL maintainer="kevin.grigorenko@us.ibm.com"

####################
# Install IBM Java #
####################

# 8.0.5.35 creates dumps that MAT DTFJ can't read, so use 8.0.5.31 until that's fixed (TS002204896).
#COPY --from=ibmjava:8-sdk /opt/ibm/java /opt/ibm/java

RUN printf 'INSTALLER_UI=silent\n\
USER_INSTALL_DIR=/opt/ibm/java/\n\
LICENSE_ACCEPTED=TRUE' > /tmp/ibm-java.properties

RUN wget -q -O /tmp/ibm-java-sdk-archive.bin http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.5.31/linux/x86_64/ibm-java-sdk-8.0-5.31-x86_64-archive.bin && \
    chmod a+x /tmp/ibm-java-sdk-archive.bin && \
    /tmp/ibm-java-sdk-archive.bin -f /tmp/ibm-java.properties && \
    rm -f /tmp/ibm-java-sdk-archive.bin /tmp/ibm-java.properties

########################
# Put IBM Java on PATH #
########################

# https://fedoraproject.org/wiki/Alternatives_system
RUN for i in java javac jar javah javap javadoc javaws jconsole jdmpview keytool jdb ControlPanel; do \
      alternatives --install /usr/bin/$i $i /opt/ibm/java/bin/$i 99999999 --family ibmjava && \
      alternatives --auto $i; \
    done

###############
# Install MAT #
###############

# Eclipse Memory Analyzer Tool (MAT)
# https://www.eclipse.org/mat/
RUN sudo mkdir /opt/mat/ && \
    sudo wget -q -O /opt/MemoryAnalyzer.zip $(curl -s https://www.eclipse.org/mat/downloads.php | grep "Linux (x86_64/GTK+) RCP" | sed 's/.*href="//g' | sed 's/".*//g' | sed 's/^http:/https:/g' | sed 's/$/\&r=1/g') && \
    ( \
      cd /opt/ && \
      sudo unzip -q MemoryAnalyzer.zip && \
      sudo rm -f /opt/MemoryAnalyzer.zip && \
      cd /opt/mat && \
      sudo printf '[Desktop Entry]\nType=Application\nName=MAT\nExec=/opt/mat/MemoryAnalyzer\nPath=~/\nTerminal=false\n' >> mat.desktop && \
      sudo chmod a+x mat.desktop && \
      sudo ln -s /opt/mat/mat.desktop /opt/programs/ \
    )

# IBM Diagnostic Tool Framework for Java (DTFJ)
# https://www.ibm.com/support/knowledgecenter/en/SSYKE2_8.0.0/com.ibm.java.vm.80.doc/docs/dtfj.html
# https://developer.ibm.com/javasdk/tools/
RUN sudo /opt/mat/MemoryAnalyzer -nosplash -application org.eclipse.equinox.p2.director \
                                 -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/dtfj/ \
                                 -installIU com.ibm.dtfj.feature.feature.group

# IBM Monitoring and Diagnostic Tools - Extensions for Memory Analyzer (IEMA)
# https://developer.ibm.com/javasdk/tools/
RUN sudo /opt/mat/MemoryAnalyzer -nosplash -application org.eclipse.equinox.p2.director \
                                 -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.cognosbi.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.ctg.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.jse.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.util.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.was.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.wesb.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.wps.feature.feature.group

# Disable MAT welcome screen
RUN sudo mkdir -p /home/was/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    sudo chown -R was /home/was/workspace/ && \
    sudo mkdir -p /root/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/

# Increase the default max heap size
RUN sudo sed -i 's/-Xmx1024m/-Xmx4g/g' /opt/mat/MemoryAnalyzer.ini

RUN printf 'bytes_display=Smart\n\
eclipse.preferences.version=1\n\
hideGettingStartedWizard=false\n\
hide_welcome_screen=true\n\
' > /home/was/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs

RUN sudo cp /home/was/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs /root/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/ && \
    sudo chown root /home/was/workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.mat.ui.prefs

#################
# Various Tools #
#################

# IBM HeapAnalyzer
# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=4544bafe-c7a2-455f-9d43-eb866ea60091
RUN ( \
      sudo mkdir /opt/heapanalyzer/ && \
      cd /opt/heapanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/HeapAnalyzer/ha456.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Heap Analyzer\nExec=java -jar /opt/heapanalyzer/ha456.jar\nPath=~/\nTerminal=false\n' >> ha.desktop && \
      sudo chmod a+x ha.desktop && \
      sudo ln -s /opt/heapanalyzer/ha.desktop /opt/programs/ \
    )

# IBM Thread and Monitor Dump Analyzer (TMDA)
# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=2245aa39-fa5c-4475-b891-14c205f7333c
RUN ( \
      sudo mkdir /opt/tmda/ && \
      cd /opt/tmda/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/jca/jca463.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=TMDA\nExec=java -jar /opt/tmda/jca463.jar\nPath=~/\nTerminal=false\n' >> tmda.desktop && \
      sudo chmod a+x tmda.desktop && \
      sudo ln -s /opt/tmda/tmda.desktop /opt/programs/ \
    )

# IBM ClassLoader Analyzer
# https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=a0a94b0d-38fe-4f4e-b2e6-4504b9d3f596
RUN ( \
      sudo mkdir /opt/classloaderanalyzer/ && \
      cd /opt/classloaderanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/ica/ica107.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Classloader Analyzer\nExec=java -jar /opt/classloaderanalyzer/ica107.jar\nPath=~/\nTerminal=false\n' >> cla.desktop && \
      sudo chmod a+x cla.desktop && \
      sudo ln -s /opt/classloaderanalyzer/cla.desktop /opt/programs/ \
    )

# IBM Pattern Modeling and Analysis Tool for Java Garbage Collector (PMAT)
# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=22d56091-3a7b-4497-b36e-634b51838e11
RUN ( \
      sudo mkdir /opt/pmat/ && \
      cd /opt/pmat/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/pmat/ga458.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=PMAT\nExec=java -jar /opt/pmat/ga458.jar\nPath=~/\nTerminal=false\n' >> pmat.desktop && \
      sudo chmod a+x pmat.desktop && \
      sudo ln -s /opt/pmat/pmat.desktop /opt/programs/ \
    )

# IBM Runtime Diagnostic Code Injection for the Java Platform (RDCI or Java Surgery)
# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=7d3dc078-131f-404c-8b4d-68b3b9ddd07a
RUN ( \
      sudo mkdir /opt/surgery/ && \
      cd /opt/surgery/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/surgery/surgery.jar \
    )

# IBM Trace and Request Analyzer for WebSphere Application Server
# https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=39153aad-6203-40ef-b239-e41243e27792
RUN ( \
      sudo mkdir /opt/tracerequestanalyzer/ && \
      cd /opt/tracerequestanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/tra/tra303.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Trace and Request Analyzer\nExec=java -jar /opt/tracerequestanalyzer/tra303.jar\nPath=~/\nTerminal=false\n' >> tra.desktop && \
      sudo chmod a+x tra.desktop && \
      sudo ln -s /opt/tracerequestanalyzer/tra.desktop /opt/programs/ \
    )

#########################
# Install Health Center #
#########################

# Eclipse > Luna has some strange StackOverflowErrors with Health Center, so we install an old Eclipse
# for HC separately.
# https://www.eclipse.org/downloads/packages/release/photon/r/eclipse-ide-java-ee-developers
# https://www.eclipse.org/downloads/packages/release
RUN sudo wget -q -O /opt/eclipse_old.tar.gz "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/luna/SR2/eclipse-java-luna-SR2-linux-gtk-x86_64.tar.gz&r=1" && \
    ( \
      cd /opt/ && \
      sudo tar xzf eclipse_old.tar.gz && \
      sudo rm -f /opt/eclipse_old.tar.gz && \
      sudo mv /opt/eclipse /opt/eclipse_old \
    )

# IBM Monitoring and Diagnostic Tools - Health Center
# https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.healthcenter.doc/homepage/plugin-homepage-hc.html
# https://developer.ibm.com/javasdk/tools/
RUN sudo /opt/eclipse_old/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                                  -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/healthcenter/ \
                                  -installIU com.ibm.java.diagnostics.healthcenter.core.feature.feature.group \
                                  -installIU com.ibm.java.diagnostics.healthcenter.gui.feature.feature.group && \
    sudo printf '[Desktop Entry]\nType=Application\nName=Health Center\nExec=/opt/eclipse_old/eclipse -data workspace_hc -perspective com.ibm.java.diagnostics.healthcenter.gui.perspective.status\nPath=~/\nTerminal=false\n' >> /opt/eclipse_old/hc.desktop && \
    sudo chmod a+x /opt/eclipse_old/hc.desktop && \
    sudo ln -s /opt/eclipse_old/hc.desktop /opt/programs/

# Remove the welcome screen. No obvious way to do this less dramatically.
RUN sudo rm -rf /opt/eclipse_old/plugins/org.eclipse.ui.intro*

# Required after installing anything into Eclipse
RUN sudo chmod -R a+w /opt/eclipse_old/configuration

#########################
# Install GCMV and IDDE #
#########################

# Eclipse 2019-03
# https://www.eclipse.org/downloads/packages/release/2019-03/r/eclipse-ide-enterprise-java-developers
# https://help.eclipse.org/2019-03/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fmisc%2Fruntime-options.html
RUN sudo wget -q -O /opt/eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz "https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2019-03/R/eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz&r=1" && \
    ( \
      cd /opt/ && \
      sudo tar xzf eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz && \
      sudo rm -f /opt/eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz && \
      cd /opt/eclipse && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Eclipse\nExec=/opt/eclipse/eclipse -data workspace\nPath=~/\nTerminal=false\n' >> eclipse.desktop && \
      sudo chmod a+x eclipse.desktop && \
      sudo ln -s /opt/eclipse/eclipse.desktop /opt/programs/ \
    )

# IBM Monitoring and Diagnostic Tools - Garbage Collection and Memory Visualizer (GCMV)
# https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.visualizer.doc/homepage/plugin-homepage-gcmv.html
# https://developer.ibm.com/javasdk/tools/
RUN sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/gcmv/ \
                              -installIU com.ibm.java.diagnostics.visualizer.feature.feature.group && \
    sudo printf '[Desktop Entry]\nType=Application\nName=GCMV\nExec=/opt/eclipse/eclipse -data workspace_gcmv -perspective com.ibm.java.diagnostics.visualizer.gui.perspective\nPath=~/\nTerminal=false\n' >> /opt/eclipse/gcmv.desktop && \
    sudo chmod a+x /opt/eclipse/gcmv.desktop && \
    sudo ln -s /opt/eclipse/gcmv.desktop /opt/programs/

# IBM Monitoring and Diagnostic Tools - Interactive Diagnostic Data Explorer (IDDE)
# https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.idde.doc/homepage/plugin-homepage-idde.html
# https://developer.ibm.com/javasdk/tools/
RUN sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/idde/ \
                              -installIU com.ibm.java.diagnostics.idde.feature.feature.group \
                              -installIU com.ibm.java.diagnostics.idde.extensions.feature.feature.group && \
    sudo printf '[Desktop Entry]\nType=Application\nName=IDDE\nExec=/opt/eclipse/eclipse -data workspace_idde -perspective com.ibm.java.diagnostics.idde.perspective\nPath=~/\nTerminal=false\n' >> /opt/eclipse/idde.desktop && \
    sudo chmod a+x /opt/eclipse/idde.desktop && \
    sudo ln -s /opt/eclipse/idde.desktop /opt/programs/

# Remove the welcome screen. No obvious way to do this less dramatically.
RUN sudo rm /opt/eclipse/plugins/org.eclipse.ui.intro*

# Required after installing anything into Eclipse
RUN sudo chmod -R a+w /opt/eclipse/configuration

############
# Finalize #
############

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /setpassword.sh

# syntax=docker/dockerfile:1.0.0-experimental
#
# Purpose: This is not designed for production usage but instead as a debugging and learning container.
#
# usage:
# ======
# Step 1: Optionally, create remotepassword.txt in the directory with this Dockerfile and set the contents of the
#         file to the password used for VNC/RDP/root
# Step 2: Build the Docker image:
#   Without remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build -t kgibm/fedorajavadebug .
#   With remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt -t kgibm/fedorajavadebug .
# Step 3: Run the Docker image:
#   docker run --cap-add SYS_PTRACE --ulimit core=-1 --rm -p 3389:3389 -p 5901:5901 -p 5902:5902 -p 22:22 -it kgibm/fedorajavadebug
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

FROM kgibm/fedoradebug

LABEL maintainer="kevin.grigorenko@us.ibm.com"

COPY --from=ibmjava:8-sdk /opt/ibm/java /opt/ibm/java

# https://fedoraproject.org/wiki/Alternatives_system
RUN for i in java javac jar javah javap javadoc javaws jconsole jdmpview keytool jdb ControlPanel; do \
      alternatives --install /usr/bin/$i $i /opt/ibm/java/bin/$i 99999999 --family ibmjava && \
      alternatives --auto $i; \
    done

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

# Install DTFJ
RUN sudo /opt/mat/MemoryAnalyzer -nosplash -application org.eclipse.equinox.p2.director \
                                 -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/dtfj/ \
                                 -installIU com.ibm.dtfj.feature.feature.group

# Install IEMA
RUN sudo /opt/mat/MemoryAnalyzer -nosplash -application org.eclipse.equinox.p2.director \
                                 -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/iema/ \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.cognosbi.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.ctg.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.jse.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.util.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.was.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.wesb.feature.feature.group \
                                 -installIU com.ibm.java.diagnostics.memory.analyzer.wps.feature.feature.group

# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=4544bafe-c7a2-455f-9d43-eb866ea60091
RUN ( \
      sudo mkdir /opt/heapanalyzer/ && \
      cd /opt/heapanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/HeapAnalyzer/ha456.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Heap Analyzer\nExec=java -jar /opt/heapanalyzer/ha456.jar\nPath=~/\nTerminal=false\n' >> ha.desktop && \
      sudo chmod a+x ha.desktop && \
      sudo ln -s /opt/heapanalyzer/ha.desktop /opt/programs/ \
    )

# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=2245aa39-fa5c-4475-b891-14c205f7333c
RUN ( \
      sudo mkdir /opt/tmda/ && \
      cd /opt/tmda/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/jca/jca463.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=TMDA\nExec=java -jar /opt/tmda/jca463.jar\nPath=~/\nTerminal=false\n' >> tmda.desktop && \
      sudo chmod a+x tmda.desktop && \
      sudo ln -s /opt/tmda/tmda.desktop /opt/programs/ \
    )

# https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=a0a94b0d-38fe-4f4e-b2e6-4504b9d3f596
RUN ( \
      sudo mkdir /opt/classloaderanalyzer/ && \
      cd /opt/classloaderanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/ica/ica107.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Classloader Analyzer\nExec=java -jar /opt/classloaderanalyzer/ica107.jar\nPath=~/\nTerminal=false\n' >> cla.desktop && \
      sudo chmod a+x cla.desktop && \
      sudo ln -s /opt/classloaderanalyzer/cla.desktop /opt/programs/ \
    )

# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=22d56091-3a7b-4497-b36e-634b51838e11
RUN ( \
      sudo mkdir /opt/pmat/ && \
      cd /opt/pmat/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/pmat/ga458.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=PMAT\nExec=java -jar /opt/pmat/ga458.jar\nPath=~/\nTerminal=false\n' >> pmat.desktop && \
      sudo chmod a+x pmat.desktop && \
      sudo ln -s /opt/pmat/pmat.desktop /opt/programs/ \
    )

# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=7d3dc078-131f-404c-8b4d-68b3b9ddd07a
RUN ( \
      sudo mkdir /opt/surgery/ && \
      cd /opt/surgery/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/surgery/surgery.jar \
    )
# https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=39153aad-6203-40ef-b239-e41243e27792
RUN ( \
      sudo mkdir /opt/tracerequestanalyzer/ && \
      cd /opt/tracerequestanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/tra/tra303.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Trace and Request Analyzer\nExec=java -jar /opt/tracerequestanalyzer/tra303.jar\nPath=~/\nTerminal=false\n' >> tra.desktop && \
      sudo chmod a+x tra.desktop && \
      sudo ln -s /opt/tracerequestanalyzer/tra.desktop /opt/programs/ \
    )

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

# Install GCMV
RUN sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/gcmv/ \
                              -installIU com.ibm.java.diagnostics.visualizer.feature.feature.group && \
    sudo printf '[Desktop Entry]\nType=Application\nName=GCMV\nExec=/opt/eclipse/eclipse -data workspace_gcmv -perspective com.ibm.java.diagnostics.visualizer.gui.perspective\nPath=~/\nTerminal=false\n' >> /opt/eclipse/gcmv.desktop && \
    sudo chmod a+x /opt/eclipse/gcmv.desktop && \
    sudo ln -s /opt/eclipse/gcmv.desktop /opt/programs/

# Install Health Center
RUN sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/healthcenter/ \
                              -installIU com.ibm.java.diagnostics.healthcenter.core.feature.feature.group \
                              -installIU com.ibm.java.diagnostics.healthcenter.gui.feature.feature.group && \
    sudo printf '[Desktop Entry]\nType=Application\nName=Health Center\nExec=/opt/eclipse/eclipse -data workspace_hc -perspective com.ibm.java.diagnostics.healthcenter.gui.perspective.status\nPath=~/\nTerminal=false\n' >> /opt/eclipse/hc.desktop && \
    sudo chmod a+x /opt/eclipse/hc.desktop && \
    sudo ln -s /opt/eclipse/hc.desktop /opt/programs/

# Install IDDE
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

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /setpassword.sh

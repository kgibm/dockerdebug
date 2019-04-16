# usage:
# ======
# Step 1: Build the Docker image:
#   docker build -t kgibm/fedorajavadebug .
# Step 2: Run the Docker image:
#   docker run --cap-add SYS_PTRACE --ulimit core=-1 --rm -p 3389:3389 -p 5901:5901 -p 5902:5902 -p 22:22 -it kgibm/fedorajavadebug java -version

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
      sudo unzip -q MemoryAnalyzer.zip && sudo rm -f /opt/MemoryAnalyzer.zip && \
      cd /opt/mat && \
      sudo printf '[Desktop Entry]\nType=Application\nName=MAT\nExec=/opt/mat/MemoryAnalyzer\nPath=~/\nTerminal=false\n' >> mat.desktop && \
      sudo chmod a+x mat.desktop \
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

# Allow running Eclipse from root
RUN sudo sed -i '/^-protect$/d' /etc/eclipse.ini && \
    sudo sed -i '/^-protect$/d' /usr/lib/eclipse/eclipse.ini && \
    sudo sed -i '/^root$/d' /etc/eclipse.ini && \
    sudo sed -i '/^root$/d' /usr/lib/eclipse/eclipse.ini

# Install GCMV
RUN sudo /usr/bin/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/gcmv/ \
                          -installIU com.ibm.java.diagnostics.visualizer.feature.feature.group \
                            2>&1 | grep -v "Fragment directory should be read only"

# Install Health Center
RUN sudo /usr/bin/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/healthcenter/ \
                          -installIU com.ibm.java.diagnostics.healthcenter.core.feature.feature.group \
                          -installIU com.ibm.java.diagnostics.healthcenter.gui.feature.feature.group \
                            2>&1 | grep -v "Fragment directory should be read only"

# Install IDDE
RUN sudo /usr/bin/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/runtimes/tools/idde/ \
                          -installIU com.ibm.java.diagnostics.idde.feature.feature.group \
                          -installIU com.ibm.java.diagnostics.idde.extensions.feature.feature.group \
                            2>&1 | grep -v "Fragment directory should be read only"

# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=4544bafe-c7a2-455f-9d43-eb866ea60091
RUN ( \
      sudo mkdir /opt/heapanalyzer/ && \
      cd /opt/heapanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/HeapAnalyzer/ha456.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Heap Analyzer\nExec=java -jar /opt/heapanalyzer/ha456.jar\nPath=~/\nTerminal=false\n' >> ha.desktop && \
      sudo chmod a+x ha.desktop \
    )

# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=2245aa39-fa5c-4475-b891-14c205f7333c
RUN ( \
      sudo mkdir /opt/tmda/ && \
      cd /opt/tmda/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/jca/jca463.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=TMDA\nExec=java -jar /opt/tmda/jca463.jar\nPath=~/\nTerminal=false\n' >> tmda.desktop && \
      sudo chmod a+x tmda.desktop \
    )

# https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=a0a94b0d-38fe-4f4e-b2e6-4504b9d3f596
RUN ( \
      sudo mkdir /opt/classloaderanalyzer/ && \
      cd /opt/classloaderanalyzer/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/ica/ica107.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=Classloader Analyzer\nExec=java -jar /opt/classloaderanalyzer/ica107.jar\nPath=~/\nTerminal=false\n' >> cla.desktop && \
      sudo chmod a+x cla.desktop \
    )

# https://www.ibm.com/developerworks/community/groups/service/html/communityview?communityUuid=22d56091-3a7b-4497-b36e-634b51838e11
RUN ( \
      sudo mkdir /opt/pmat/ && \
      cd /opt/pmat/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/pmat/ga458.jar && \
      sudo printf '[Desktop Entry]\nType=Application\nName=PMAT\nExec=java -jar /opt/pmat/ga458.jar\nPath=~/\nTerminal=false\n' >> pmat.desktop && \
      sudo chmod a+x pmat.desktop \
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
      sudo chmod a+x tra.desktop \
    )

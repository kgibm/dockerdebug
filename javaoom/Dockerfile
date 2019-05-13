# docker build -t javaoom .
# docker run --rm -it javaoom bash
# docker run -v /:/host --rm -it javaoom java -Xmx256m -Xdump:directory=/host/tmp/ -Xdump:heap:none -cp /tmp -Dsize=10485760 SimulateJavaOOM

FROM fedora
RUN dnf install -y wget hostname
RUN wget -q -O /tmp/SimulateJavaOOM.class https://github.com/kgibm/SimulateJavaOOM/raw/master/SimulateJavaOOM.class
RUN printf 'INSTALLER_UI=silent\n\
USER_INSTALL_DIR=/opt/ibm/java/\n\
LICENSE_ACCEPTED=TRUE' > /tmp/ibm-java.properties
RUN wget -q -O /tmp/ibm-java-sdk-archive.bin http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.5.31/linux/x86_64/ibm-java-sdk-8.0-5.31-x86_64-archive.bin && \
    chmod a+x /tmp/ibm-java-sdk-archive.bin && \
    /tmp/ibm-java-sdk-archive.bin -f /tmp/ibm-java.properties

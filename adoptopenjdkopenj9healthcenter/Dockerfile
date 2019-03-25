# usage:
# 1. Download agent using instructions at https://www.ibm.com/support/knowledgecenter/en/SS3KLZ/com.ibm.java.diagnostics.healthcenter.doc/topics/installingagent.html
# 2. Rename agent zip file as healthcenter.zip in the same directory as this Dockerfile
# 3. Build the Dockerfile
# 4. Run the Dockerfile and specify -Xhealthcenter* options

FROM adoptopenjdk/openjdk12-openj9:latest

LABEL maintainer="kevin.grigorenko@us.ibm.com"

COPY healthcenter.zip /opt/java/healthcenter/

RUN cd /opt/java/healthcenter/ && \
    jar xvf healthcenter.zip && \
    cp jre/lib/*/*.so /opt/java/openjdk/lib/ && \
    cp jre/lib/healthcenter.properties /opt/java/openjdk/lib/healthcenter.properties

ENV OPENJ9_JAVA_OPTIONS="-Xbootclasspath/a:/opt/java/healthcenter/jre/lib/ext/healthcenter.jar"

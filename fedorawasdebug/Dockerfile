# syntax=docker/dockerfile:1.0.0-experimental
#
# usage:
# ======
# Step 1: Optionally, create remotepassword.txt in the directory with this Dockerfile and set the contents of the
#         file to the password used for VNC/RDP/root
# Step 2: Build the Docker image:
#   Without remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build -t fedorawasdebug .
#   With remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt -t fedorawasdebug .
# Step 3: Run the Docker image:
#   docker run --cap-add SYS_PTRACE --rm -p 80:9080 -p 443:9443 -p 9043:9043 -p 9081:9081 -p 9444:9444 -p 3389:3389 -p 5901:5901 -p 5902:5902 -p 22:22 -it fedorawasdebug
#
#   Optional:
#     For Traditional WAS, to specify the wsadmin password, create a PASSWORD file and use: -v $(pwd)/PASSWORD:/tmp/PASSWORD

FROM kgibm/fedorajavadebug

LABEL maintainer="kevin.grigorenko@us.ibm.com"

COPY --from=websphere-liberty:latest --chown=was:root /opt/ibm/helpers /opt/ibm/helpers
COPY --from=websphere-liberty:latest --chown=was:root /opt/ibm/wlp /opt/ibm/wlp
COPY --from=websphere-liberty:latest --chown=was:root /logs /logs
COPY --from=websphere-liberty:latest --chown=was:root /licenses /licenses
COPY --from=websphere-liberty:latest --chown=was:root /etc/wlp /etc/wlp
COPY --from=websphere-liberty:latest --chown=was:root /output /output
COPY --from=websphere-liberty:latest --chown=was:root /config /config

COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /work /work
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /licenses/* /licenses/
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /opt/IBM /opt/IBM
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /etc/websphere /etc/websphere

EXPOSE 9080 9443

RUN printf '#!/bin/sh\n\
/opt/ibm/helpers/runtime/docker-server.sh\n\
\n' > /extended_entrypoint.sh

USER 1001

ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output \
    KEYSTORE_REQUIRED=true \
    RANDFILE=/tmp/.rnd \
    JVM_ARGS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/" \
    PATH=/opt/ibm/wlp/bin:/opt/ibm/helpers/build:/opt/IBM/WebSphere/AppServer/bin:$PATH \
    WAS_CELL=DefaultCell01 \
    NODE_NAME=DefaultNode01 \
    SERVER_NAME=server1 \
    HOST_NAME=localhost \
    PROFILE_NAME=AppSrv01 \
    ADMIN_USER_NAME=wsadmin \
    EXTRACT_PORT_FROM_HOST_HEADER=true \
    ENABLE_BASIC_LOGGING=true

RUN sed -i 's/"9443"/"9444"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"7276"/"7277"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"7286"/"7287"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"9080"/"9081"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"2809"/"2810"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"9402"/"9404"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/9080/9081/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/virtualhosts.xml && \
    sed -i 's/9443/9444/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/virtualhosts.xml && \
    sed -i "s/ps -C .*/pgrep -f 'WsServer ')/g" /work/start_server.sh

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /setpassword.sh

# https://www-01.ibm.com/support/docview.wss?uid=swg21644180
RUN ( \
      sudo mkdir /opt/trapit/ && \
      cd /opt/trapit/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/trapit/trapit.ear \
    )

# https://github.com/kgibm/java_web_hello_world
RUN ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/java_web_hello_world && \
      cd /opt/java_web_hello_world && \
      sudo mvn -q clean install \
    )

# https://github.com/kgibm/problemdetermination
RUN ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/problemdetermination \
    )

# https://github.com/skliche/request-metrics-analyzer-next
RUN ( \
      cd /opt/ && \
      sudo git clone https://github.com/skliche/request-metrics-analyzer-next && \
      cd /opt/request-metrics-analyzer-next && \
      sudo mvn -q clean install \
    )

# https://www-01.ibm.com/support/docview.wss?uid=swg22010928
RUN ( \
      sudo mkdir /opt/wasconfigcomparison/ && \
      sudo wget -q -O /opt/wasconfigcomparison/cct-20190325.tar.gz "https://www-01.ibm.com/support/docview.wss?uid=swg22010928&aid=1" && \
      cd /opt/wasconfigcomparison/ && \
      sudo tar xzf cct-20190325.tar.gz \
    )

# https://www-01.ibm.com/support/docview.wss?uid=swg21442487
RUN ( \
      sudo mkdir /opt/manageprofilesinteractive/ && \
      sudo wget -q -O /opt/manageprofilesinteractive/manageprofilesInteractive.zip "https://www-01.ibm.com/support/docview.wss?uid=swg21442487&aid=3" && \
      cd /opt/manageprofilesinteractive/ && \
      sudo unzip -q manageprofilesInteractive.zip \
    )

RUN printf '\n\
[program:liberty]\n\
command=/opt/ibm/wlp/bin/server run defaultServer\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startretries=0\n\
autorestart=false\n\
startsecs=5\n\
priority=50\n\
user=was\n\
autostart=true\n\
\n' | sudo tee liberty.supervisord.conf

# https://localhost:9043/ibm/console
# User = wsadmin
# Password = /tmp/PASSWORD
#
# Deployed applications at http://localhost:9081/ and https://localhost:9444/
RUN printf '\n\
[program:twas]\n\
command=/work/start_server.sh\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startsecs=120\n\
startretries=0\n\
autorestart=false\n\
priority=50\n\
user=was\n\
autostart=true\n\
environment=ENABLE_BASIC_LOGGING=true\n\
\n' | sudo tee twas.supervisord.conf

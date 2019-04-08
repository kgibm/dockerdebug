# usage:
# ======
# Step 1: Build the Docker image:
#   docker build -t fedorawasdebug .
# Step 2: Run the Docker image:
#   docker run -p 80:9080 -p 443:9443 -p 3389:3389 -p 5901:5901 -p 5902:5902 -p 22:22 -it fedorawasdebug

FROM kgibm/fedorajavadebug

LABEL maintainer="kevin.grigorenko@us.ibm.com"

COPY --from=websphere-liberty:latest --chown=default:root /opt/ibm/helpers /opt/ibm/helpers
COPY --from=websphere-liberty:latest --chown=default:root /opt/ibm/wlp /opt/ibm/wlp
COPY --from=websphere-liberty:latest --chown=default:root /logs /logs
COPY --from=websphere-liberty:latest --chown=default:root /licenses /licenses
COPY --from=websphere-liberty:latest --chown=default:root /etc/wlp /etc/wlp
COPY --from=websphere-liberty:latest --chown=default:root /output /output
COPY --from=websphere-liberty:latest --chown=default:root /config /config

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
    PATH=/opt/ibm/wlp/bin:/opt/ibm/helpers/build:$PATH

CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]

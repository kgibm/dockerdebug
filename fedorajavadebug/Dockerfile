# usage:
# ======
# Step 1: Build the Docker image:
#   docker build -t fedorajavadebug .
# Step 2: Run the Docker image:
#   docker run -it fedorajavadebug java -version

FROM kgibm/fedoradebug
COPY --from=ibmjava:8-sdk /opt/ibm/java /opt/ibm/java

RUN for i in java javac jar javah javap javadoc javaws jconsole jdmpview keytool jdb ControlPanel; do \
        alternatives --install /usr/bin/$i $i /opt/ibm/java/bin/$i 99999999 --family ibmjava && \
        alternatives --auto $i; \
    done || exit 1

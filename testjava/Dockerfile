# docker build -t testjava .
# docker run --rm -it testjava
FROM amd64/adoptopenjdk:8-jdk-openj9
COPY Hang.class /opt/
CMD ["/opt/java/openjdk/bin/java", "-cp", "/opt/", "Hang"]

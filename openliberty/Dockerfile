# docker build -t oltest .
# docker run --rm -p 9080:9080 -p 9443:9443 -it oltest
FROM open-liberty:latest
USER root
RUN apt-get update && \
    apt-get install -y wget iproute2
USER default
RUN wget -q -O /config/dropins/swat.ear https://raw.githubusercontent.com/kgibm/problemdetermination/master/swat.ear

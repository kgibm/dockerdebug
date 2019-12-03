# docker build -t oltest .
# docker run --rm -p 9080:9080 -p 9443:9443 -it oltest
FROM websphere-liberty:javaee7
USER root
RUN apt-get update && \
    apt-get install -y wget iproute2
USER default
RUN wget -q -O /config/dropins/swat.ear https://raw.githubusercontent.com/kgibm/problemdetermination/master/swat.ear && \
    echo '\n\
      <server>\n\
        <httpEndpoint id="defaultHttpEndpoint" httpPort="9080" httpsPort="9443">\n\
          <accessLogging filepath="${server.output.dir}/logs/access.log" maxFileSize="250" maxFiles="4" logFormat="%h %i %u %t &quot;%r&quot; %s %b %D %{R}W" />\n\
        </httpEndpoint>\n\
      </server>\n\
    ' > /config/configDropins/overrides/http.xml

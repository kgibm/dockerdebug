# docker build -t play .
# docker run --rm -p 9080:9080 -p 9443:9443 -it play
FROM open-liberty:latest
COPY webapp_slowstart.war /config/apps/webapp_slowstart1.war
COPY webapp_slowstart.war /config/apps/webapp_slowstart2.war
RUN printf '<server>\n\
  <featureManager>\n\
    <feature>microProfile-3.3</feature>\n\
  </featureManager>\n\
  <variable name="com.example.startDelayMilliseconds" value="5000" />\n\
  <webApplication id="slowstart1" location="/config/apps/webapp_slowstart1.war" contextRoot="/slowstart1" startAfter="slowstart2" />\n\
  <webApplication id="slowstart2" location="/config/apps/webapp_slowstart2.war" contextRoot="/slowstart2" />\n\
</server>\n' > /config/configDropins/overrides/server.xml
ENV WLP_LOGGING_CONSOLE_FORMAT=simple

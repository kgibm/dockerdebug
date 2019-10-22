# syntax=docker/dockerfile:1.0.0-experimental
#
# Purpose: This is not designed for production usage but instead as a debugging and learning container.
#
# usage (Requires Docker >= 18.09):
# ======
# Step 1: Optionally, create remotepassword.txt in the directory with this Dockerfile and set the contents of the
#         file to the password used for VNC/RDP/root
# Step 2: Build the Docker image:
#   Without remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build -t kgibm/fedorawasdebug .
#   With remotepassword.txt:
#     DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt -t kgibm/fedorawasdebug .
# Step 3: Run the Docker image:
#   docker run --cap-add SYS_PTRACE --ulimit core=-1 --ulimit memlock=-1 --ulimit stack=-1 --shm-size="256m" --rm -p 9080:9080 -p 9443:9443 -p 9043:9043 -p 9081:9081 -p 9444:9444 -p 5901:5901 -p 5902:5902 -p 3390:3389 -p 22:22 -p 9082:9082 -p 9445:9445 -p 8080:8080 -p 8081:8081 -p 8082:8082 -p 12000:12000 -p 12005:12005 -it kgibm/fedorawasdebug
# Step 4: Remote into the docker image
#   Linux:
#     root: vncviewer localhost:5901
#     was: vncviewer localhost:5902
#     Use the password from remotepassword.txt
#   Mac:
#     root: open vnc://localhost:5901
#     was: open vnc://localhost:5902
#     Use the password from remotepassword.txt
#   Windows: Remote desktop requires detailed instructions. Consider using a free VNC client.
# Tips:
#   * To access the host filesystem from the container (and vice versa), add the following to docker run:
#     Linux/macOS: -v /:/host/
#     Windows: -v //c/:/host/
# Notes:
#   * Because of a maximum of 125 layers (https://github.com/docker/for-linux/issues/414), minimize the number of RUN
#     commands when finalizing a new version.

# Based on https://github.com/kgibm/dockerdebug/blob/master/fedorajavadebug/Dockerfile
FROM kgibm/fedorajavadebug

LABEL maintainer="kevin.grigorenko@us.ibm.com"

# Find the latest version here:
# https://search.maven.org/search?q=g:com.ibm.websphere.appserver.runtime%20AND%20a:wlp-javaee8&core=gav
ARG MAVEN_LIBERTY_VERSION="19.0.0.10"

ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output \
    KEYSTORE_REQUIRED=true \
    RANDFILE=/tmp/.rnd \
    JVM_ARGS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/ -XX:+UseContainerSupport" \
    PATH=/opt/ibm/wlp/bin:/opt/ibm/helpers/build:/opt/IBM/WebSphere/AppServer/bin:$PATH \
    WAS_CELL=DefaultCell01 \
    NODE_NAME=DefaultNode01 \
    SERVER_NAME=server1 \
    HOST_NAME=localhost \
    PROFILE_NAME=AppSrv01 \
    ADMIN_USER_NAME=wsadmin \
    EXTRACT_PORT_FROM_HOST_HEADER=true \
    ENABLE_BASIC_LOGGING=true

USER was

#####################
# "Install" Liberty #
#####################

# WebSphere Liberty:
#   https://hub.docker.com/_/websphere-liberty
#   https://github.com/WASdev/ci.docker/blob/master/ga/latest/kernel/Dockerfile.centos
#   https://github.com/WASdev/ci.docker/blob/master/ga/latest/javaee8/Dockerfile
# OpenLiberty:
#   https://hub.docker.com/_/open-liberty
#   https://github.com/OpenLiberty/ci.docker/blob/master/official/latest/javaee8/java8/ibmjava/Dockerfile

# When updating the Liberty version, also update the version used in a build.gradle
# line replacement below (search for the Liberty version number).
COPY --from=websphere-liberty:javaee8 --chown=was:root /opt/ibm/helpers /opt/ibm/helpers
COPY --from=websphere-liberty:javaee8 --chown=was:root /opt/ibm/wlp /opt/ibm/wlp
COPY --from=websphere-liberty:javaee8 --chown=was:root /logs /logs
COPY --from=websphere-liberty:javaee8 --chown=was:root /licenses /licenses
COPY --from=websphere-liberty:javaee8 --chown=was:root /etc/wlp /etc/wlp

RUN sudo ln -s $WLP_OUTPUT_DIR/defaultServer /output && \
    sudo chown was:root /output && \
    sudo ln -s /opt/ibm/wlp/usr/servers/defaultServer /config && \
    sudo chown was:root /config && \
    sudo ln -s /opt/ibm /liberty && \
    sudo chown was:root /liberty && \
    sudo ln -s /opt/ibm/wlp/usr/shared/resources/lib.index.cache /lib.index.cache && \
    sudo chown was:root /lib.index.cache && \
    echo "# In case the user restarts Liberty from the command line instead of supervisord, we need" && \
    echo "# to set the right envars" && \
    printf '\n\
LOG_DIR=/logs\n\
WLP_OUTPUT_DIR=/opt/ibm/wlp/output\n\
KEYSTORE_REQUIRED=true\n\
RANDFILE=/tmp/.rnd\n\
JVM_ARGS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/"\n\
\n' >> /config/server.env && \
    echo "# Run Liberty initialization script at startup:" && \
    printf '#!/bin/sh\n\
if [ -e /opt/ibm/helpers/runtime/docker-server.sh ]; then\n\
    /opt/ibm/helpers/runtime/docker-server.sh\n\
fi\n\
\n' | sudo tee /extended_entrypoint.sh

#############################
# "Install" Traditional WAS #
#############################

# https://hub.docker.com/r/ibmcom/websphere-traditional

COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /work /work
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /licenses/* /licenses/
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /opt/IBM /opt/IBM
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /etc/websphere /etc/websphere

RUN sed -i 's/"9443"/"9444"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"7276"/"7277"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"7286"/"7287"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"9080"/"9081"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"2809"/"2810"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"9402"/"9404"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/9080/9081/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/virtualhosts.xml && \
    sed -i 's/9443/9444/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/virtualhosts.xml && \
    sed -i "s/ps -C .*/pgrep -f 'WsServer ')/g" /work/start_server.sh && \
    echo "# https://www-01.ibm.com/support/docview.wss?uid=swg21644180" && \
    ( \
      sudo mkdir /opt/trapit/ && \
      cd /opt/trapit/ && \
      sudo wget -q ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/trapit/trapit.ear \
    ) && \
    echo "# https://github.com/kgibm/java_web_hello_world" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/java_web_hello_world && \
      cd /opt/java_web_hello_world && \
      sudo mvn -q clean install \
    ) && \
    echo "# https://github.com/kgibm/problemdetermination" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/problemdetermination \
    ) && \
    echo "# https://github.com/skliche/request-metrics-analyzer-next" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/skliche/request-metrics-analyzer-next && \
      cd /opt/request-metrics-analyzer-next && \
      sudo mvn -q clean install && \
      printf '[Desktop Entry]\nType=Application\nName=Request Metrics Analyzer\nExec=java -jar /opt/request-metrics-analyzer-next/target/analyzer-next-0.0.1-SNAPSHOT-jar-with-dependencies.jar\nPath=~/\nTerminal=false\n' | sudo tee rma.desktop && \
      sudo chmod a+x rma.desktop && \
      sudo ln -s /opt/request-metrics-analyzer-next/rma.desktop /opt/programs/ && \
      sudo ln -s /opt/programs/rma.desktop /home/was/Desktop/ \
    ) && \
    echo "# https://www-01.ibm.com/support/docview.wss?uid=swg22010928" && \
    ( \
      sudo mkdir /opt/wasconfigcomparison/ && \
      sudo wget -q -O /opt/wasconfigcomparison/cct.tar.gz "https://www.ibm.com/support/pages/sites/default/files/inline-files/%24FILE/cct-20190822.tar.gz" && \
      cd /opt/wasconfigcomparison/ && \
      sudo tar xzf cct.tar.gz \
    ) && \
    echo "# https://www-01.ibm.com/support/docview.wss?uid=swg21442487" && \
    ( \
      sudo mkdir /opt/manageprofilesinteractive/ && \
      sudo wget -q -O /opt/manageprofilesinteractive/manageprofilesInteractive.zip "https://www.ibm.com/support/pages/sites/default/files/support/swg/swgtech.nsf/0/d6ca5180f6619c868525776f0069b7b7/%24FILE/ATTQDXZT.zip/manageprofilesInteractive.zip" && \
      cd /opt/manageprofilesinteractive/ && \
      sudo unzip -q manageprofilesInteractive.zip \
    ) && \
    echo "# https://github.com/kgibm/was_data_mining/" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/was_data_mining/ \
    ) && \
    echo "###############" && \
    echo "# Install WDT #" && \
    echo "###############" && \
    echo "# https://marketplace.eclipse.org/content/ibm-liberty-developer-tools" && \
    echo "# https://marketplace.eclipse.org/node/1778478/api/p" && \
    echo "# http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/updates/wdt/" && \
    sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/updates/wdt/2019-06_comp/,http://download.eclipse.org/releases/2019-06,http://download.eclipse.org/eclipse/updates/4.12,http://download.eclipse.org/webtools/repository/latest \
                              -installIU com.ibm.wdt.ast.ws.tools.feature.feature.group \
                              -installIU com.ibm.osgi.wdt.feature.feature.group \
                              -installIU com.ibm.websphere.wdt.server.tools.main.feature.group \
                              -installIU com.ibm.wdt.migration.tools.feature.feature.group \
                              -installIU com.ibm.wdt.webtools.top.feature.feature.group && \
    echo "# Required after installing anything into Eclipse" && \
    sudo chmod -R a+w /opt/eclipse/configuration && \
    echo "##################" && \
    echo "# Configure tWAS #" && \
    echo "##################" && \
    printf 'nodeName = AdminControl.getNode()\n\
serverName = AdminServerManagement.listServers()[0]\n\
serverName = serverName[:serverName.find("(")]\n\
#AdminApplication.uninstallApplication("DefaultApplication")\n\
# https://www.ibm.com/support/knowledgecenter/en/SSAW57_9.0.0/com.ibm.websphere.nd.multiplatform.doc/ae/rxml_taskoptions.html\n\
AdminApp.install("/opt/problemdetermination/swat.ear", ["-appname", "swat", "-node", nodeName, "-server", serverName, "-usedefaultbindings"])\n\
AdminConfig.save()\n' > /work/config/install_app.py

RUN --mount=type=secret,id=remotepassword if [ "$(sudo head -n 1 /run/secrets/remotepassword)" != "" ]; then echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" > /tmp/PASSWORD; fi

RUN /work/configure.sh

RUN cp /opt/problemdetermination/swat.ear /config/dropins/ && chown was:root /config/dropins/swat.ear && \
    echo "############################" && \
    echo "# Add supervisord programs #" && \
    echo "############################" && \
    echo "# Deployed applications at http://localhost:9080/ and https://localhost:9443/" && \
    printf '\n\
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
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
\n' | sudo tee liberty.supervisord.conf && \
    echo "# https://localhost:9043/ibm/console" && \
    echo "# User = wsadmin" && \
    echo "# Password = /tmp/PASSWORD" && \
    echo "# Deployed applications at http://localhost:9081/ and https://localhost:9444/" && \
    printf '\n\
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
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
\n' | sudo tee twas.supervisord.conf

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /setpassword.sh

RUN echo "# https://github.com/WASdev/sample.daytrader7" && \
    echo "# https://svn.apache.org/repos/infra/websites/staging/openjpa/trunk/content/artifacts/" && \
    ( \
      cd /opt/ && \
      sudo git clone https://github.com/WASdev/sample.daytrader7 daytrader7 && \
      cd /opt/daytrader7 && \
      sudo gradle build \
    ) && \
    echo "# Tried to fix the NoSuchEJBException but this didn't help. Instead, we just ignore the warnings in daytrader7logging.xml below." && \
    mkdir -p /config/configDropins/overrides/ && \
    cp /opt/daytrader7/daytrader-ee7/build/libs/daytrader-ee7.ear /config/dropins/ && \
    echo "# https://publib.boulder.ibm.com/httpserv/cookbook/" && \
    sudo mkdir /opt/cookbook && \
    sudo wget -q -O /opt/cookbook/WAS_Performance_Cookbook.pdf https://publib.boulder.ibm.com/httpserv/cookbook/WAS_Performance_Cookbook.pdf && \
    sudo ln -s /opt/cookbook/WAS_Performance_Cookbook.pdf /home/was/Desktop/ && \
    sudo dnf install -y mariadb-server mariadb-java-client && \
    sudo mysql_install_db --skip-test-db --user=mysql && \
    printf '\n\
UPDATE mysql.user SET Password = PASSWORD("%s") WHERE User = "root";\n\
FLUSH PRIVILEGES;\n\
CREATE DATABASE TradeDB;\n\
\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" | sudo tee /var/lib/mysql/init.sql && \
    echo "# https://mariadb.com/kb/en/library/mysqld-options/" && \
    printf '\n\
[program:mysql]\n\
command=/usr/bin/mysqld_safe --init-file=/var/lib/mysql/init.sql\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startsecs=5\n\
startretries=0\n\
autorestart=false\n\
priority=25\n\
user=mysql\n\
autostart=true\n\
stopsignal=KILL\n\
environment=\n\
    HOME="/var/lib/mysql",\n\
    USER="mysql",\n\
\n' | sudo tee mysqld.supervisord.conf && \
    echo "# The webProfile feature pulls in the appSecurity feature and we don't want to enable that for DayTrader7" && \
    echo "# (it does support it but requires a lot of extra configuration)." && \
    sed -i '/.*webProfile.*/d' /config/server.xml && \
    sed -i '/.*javaee.*/d' /config/server.xml && \
    echo "# https://github.com/WASdev/sample.daytrader7/blob/master/daytrader-ee7-wlpcfg/servers/daytrader7Sample/server.xml" && \
    printf '\n\
<server>\n\
    <featureManager>\n\
        <feature>ejb-3.2</feature>\n\
        <feature>servlet-3.1</feature>\n\
        <feature>jsf-2.2</feature>\n\
        <feature>jpa-2.1</feature>\n\
        <feature>mdb-3.2</feature>\n\
        <feature>wasJmsServer-1.0</feature>\n\
        <feature>wasJmsClient-2.0</feature>\n\
        <feature>cdi-1.2</feature>\n\
        <feature>websocket-1.1</feature>\n\
        <feature>concurrent-1.0</feature>\n\
        <feature>jsonp-1.0</feature>\n\
        <feature>beanValidation-1.1</feature>\n\
        <feature>localConnector-1.0</feature>\n\
    </featureManager>\n\
    <connectionManager agedTimeout="-1" connectionTimeout="0" id="conMgr1" maxIdleTime="-1" maxPoolSize="100" minPoolSize="100" purgePolicy="FailingConnectionOnly" reapTime="-1"/>\n\
    <authData id="TradeDataSourceAuthData" user="root" password="%s" />\n\
    <authData id="TradeAdminAuthData" user="root" password="%s" />\n\
    <connectionManager agedTimeout="-1" connectionTimeout="0" id="conMgr1" maxIdleTime="-1" maxPoolSize="100" minPoolSize="100" purgePolicy="FailingConnectionOnly" reapTime="-1" />\n\
    <jdbcDriver id="DerbyEmbedded" libraryRef="DerbyLib" />\n\
    <library filesetRef="DerbyFileset" id="DerbyLib" />\n\
    <fileset dir="/opt/derby/lib/" id="DerbyFileset" includes="derby.jar" />\n\
    <dataSource connectionManagerRef="conMgr1" id="DefaultDataSource" isolationLevel="TRANSACTION_READ_COMMITTED" jdbcDriverRef="DerbyEmbedded" jndiName="jdbc/TradeDataSource" statementCacheSize="60">\n\
        <properties.derby.embedded createDatabase="create" databaseName="${shared.resource.dir}/data/tradedb" user="root" password="%s" />\n\
    </dataSource>\n\
    \n\
    <!--<library id="MariaDBLib">\n\
        <file name="/usr/lib/java/mariadb-java-client.jar" />\n\
    </library>\n\
    <dataSource id="DefaultDataSource" jndiName="jdbc/TradeDataSource">\n\
        <jdbcDriver libraryRef="MariaDBLib" />\n\
        <properties databaseName="TradeDB" serverName="localhost" user="root" password="%s" portNumber="3306" />\n\
    </dataSource>-->\n\
    \n\
	<messagingEngine id="defaultME">\n\
		<queue id="TradeBrokerQueue"/>\n\
		<topicSpace id="TradeTopicSpace"/>\n\
	</messagingEngine>\n\
	<jmsQueueConnectionFactory connectionManagerRef="ConMgr3" jndiName="jms/TradeBrokerQCF">\n\
		<properties.wasJms/>\n\
	</jmsQueueConnectionFactory>\n\
	<connectionManager id="ConMgr3" maxPoolSize="20"/>\n\
	<jmsTopicConnectionFactory connectionManagerRef="ConMgr4" jndiName="jms/TradeStreamerTCF">\n\
		<properties.wasJms/>\n\
	</jmsTopicConnectionFactory>\n\
	<connectionManager id="ConMgr4" maxPoolSize="20"/>\n\
	<jmsQueue id="jms/TradeBrokerQueue" jndiName="jms/TradeBrokerQueue">\n\
		<properties.wasJms deliveryMode="NonPersistent" queueName="TradeBrokerQueue"/>\n\
	</jmsQueue>\n\
	<jmsTopic id="TradeStreamerTopic" jndiName="jms/TradeStreamerTopic">\n\
		<properties.wasJms deliveryMode="NonPersistent" topicSpace="TradeTopicSpace"/>\n\
	</jmsTopic>\n\
	<jmsActivationSpec id="eis/TradeBrokerMDB">\n\
		<properties.wasJms destinationRef="jms/TradeBrokerQueue"/>\n\
	</jmsActivationSpec>\n\
	<jmsActivationSpec id="eis/TradeStreamerMDB">\n\
		<properties.wasJms destinationRef="TradeStreamerTopic" destinationType="javax.jms.Topic"/>\n\
    </jmsActivationSpec>\n\
</server>\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" > /config/configDropins/overrides/daytrader.xml && \
    echo "# https://openliberty.io/docs/ref/config/#logging.html" && \
    printf '\n\
<server>\n\
    <logging traceSpecification="*=info" maxFileSize="250" maxFiles="4" hideMessage="CNTR0333W,CNTR0019E,CWWJP9991W" />\n\
</server>\n' > /config/configDropins/overrides/daytrader7logging.xml && \
    /opt/ibm/wlp/bin/installUtility install --acceptLicense defaultServer && \
    echo "# https://mariadb.com/kb/en/library/identifier-case-sensitivity/" && \
    sudo sed -i 's/\[mysqld\]/[mysqld]\nlower_case_table_names=1/g' /etc/my.cnf.d/mariadb-server.cnf && \
    echo "# https://db.apache.org/derby/" && \
    ( \
      cd /opt/ && \
      sudo wget -q -O /opt/derby.zip https://www.apache.org/dist//db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-bin.zip && \
      sudo unzip derby.zip && \
      sudo rm derby.zip && \
      sudo mv *derby* derby \
    ) && \
    echo "# https://github.com/kgibm/jni_web_hello_world" && \
    ( \
      echo "Version 9" && \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/jni_web_hello_world && \
      cd /opt/jni_web_hello_world && \
      sudo mvn -q clean install && \
      cd src/main/c/ && \
      sudo gcc -g -shared -fPIC -o ../../../target/libNativeWrapper.so -I/opt/ibm/java/include/ -I/opt/ibm/java/include/linux/ com_example_NativeWrapper.c && \
      /opt/ibm/wlp/bin/server create test && \
      cp /opt/jni_web_hello_world/target/jni_web_hello_world.war /opt/ibm/wlp/usr/servers/test/dropins/ && \
      cp /opt/problemdetermination/swat.ear /opt/ibm/wlp/usr/servers/test/dropins/ && \
      printf '--' '-Xmx2g\n-Djava.library.path=/opt/jni_web_hello_world/target/\n-DSUPPRESS_INVOKE_MESSAGES=true\n-DJAVA_SURGERY_JAR_FILE=/opt/surgery/surgery.jar\n-DLEAK_TO_LIST=true\n' > /opt/ibm/wlp/usr/servers/test/jvm.options && \
      printf '<?xml version="1.0"?><server><featureManager><feature>webProfile-8.0</feature></featureManager><httpEndpoint id="defaultHttpEndpoint" host="*" httpPort="9082" httpsPort="9445" /></server>' > /opt/ibm/wlp/usr/servers/test/server.xml \
    ) && \
    printf '\n\
[program:liberty2]\n\
command=/opt/ibm/wlp/bin/server start test\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
startretries=0\n\
autorestart=false\n\
priority=60\n\
user=was\n\
autostart=true\n\
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
    LOG_DIR="/opt/ibm/wlp/usr/servers/test/logs/",\n\
    WLP_OUTPUT_DIR="/opt/ibm/wlp/usr/servers/",\n\
\n' | sudo tee liberty2.supervisord.conf && \
    sudo mkdir /opt/docs/ && \
    mkdir -p /home/was/Desktop && \
    chown was /home/was/Desktop && \
    ln -s "/opt/docs/WebSphere_Application_Server_Troubleshooting_and_Performance_Lab_on_Docker.pdf" "/home/was/Desktop/" && \
    echo "# https://github.com/OpenLiberty/open-liberty" && \
    sudo git clone https://github.com/OpenLiberty/open-liberty /usr/local/src/open-liberty && \
    echo "# https://github.com/OpenLiberty/liberty-bikes" && \
    echo "# We want WebSphere Liberty features like adminCenter so we replace libertyRuntime" && \
    echo "# https://mvnrepository.com/artifact/com.ibm.websphere.appserver.runtime" && \
    ( \
      cd /home/was/ && \
      git clone https://github.com/OpenLiberty/liberty-bikes && \
      cd liberty-bikes && \
      sed -i "s/libertyRuntime.*/libertyRuntime group: 'com.ibm.websphere.appserver.runtime', name: 'wlp-javaee8', version: '${MAVEN_LIBERTY_VERSION}'/g" build.gradle && \
      sudo chmod -R 777 /tmp/wlp-cache/ && \
      ./gradlew libertyPackage game-service:compileTestJava && \
      sudo chmod -R 777 /tmp/wlp-cache/ && \
      ./build/wlp/bin/installUtility install --acceptLicense adminCenter-1.0 && \
      mkdir -p build/wlp/usr/servers/frontendServer/configDropins/overrides/ && \
      printf '<server><featureManager><feature>ssl-1.0</feature></featureManager></server>' > build/wlp/usr/servers/frontendServer/configDropins/overrides/ssl.xml \
    ) && \
    ( \
      cp /opt/problemdetermination/swat.ear /home/was/liberty-bikes/build/wlp/usr/servers/frontendServer/dropins/ \
    ) && \
    echo "# Start Liberty which creates the DB, then build the DB tables, restart Liberty, and then populate the DB." && \
    echo "# A benign FFDC is created initially which we can just destroy later." && \
    sudo mkdir -p /opt/ibm/wlp/usr/shared/resources/data/ && \
    sudo chown -R was:root /opt/ibm/wlp/usr/shared/resources/ && \
    /opt/ibm/wlp/bin/server start defaultServer && \
    sleep 30 && \
    curl "http://localhost:9080/daytrader/config?action=buildDBTables" && \
    /opt/ibm/wlp/bin/server stop defaultServer && \
    /opt/ibm/wlp/bin/server start defaultServer && \
    sleep 30 && \
    curl "http://localhost:9080/daytrader/config?action=buildDB" && \
    /opt/ibm/wlp/bin/server stop defaultServer && \
    rm -rf /logs/ffdc/* && \
    sudo rm /opt/daytrader7/jmeter_files/daytrader7_mojarra.jmx && \
    sudo chmod a+rw /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    printf '#!/bin/sh\n\
sleep 130\n\
echo -e "\\n\\n=========\\n= READY =\\n=========\\n"\n\
\n' | sudo tee /finished.sh && sudo chmod +x /finished.sh && \
    printf '\n\
[program:finished]\n\
command=/finished.sh\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
\n' | sudo tee finished.supervisord.conf && \
    echo "# Configure DayTrader7 on tWAS" && \
    sudo sed -i 's/9082/9080/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo sed -i 's/THREADS,50/THREADS,4/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo chmod -R a+w /opt/daytrader7/jmeter_files && \
    sudo sed -i 's/\(ResultCollector.*StatVisualizer.*enabled="\)false/\1true/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo sed -i 's/ThreadGroup.scheduler">true/ThreadGroup.scheduler">false/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo sed -i 's/AdminUserID/wsadmin/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i "s/\"password\"/\"$(cat /tmp/PASSWORD)\"/g" /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/SecurityEnabled = ".*/SecurityEnabled = "true"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultProviderType =   .*/DefaultProviderType = "Derby"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultPathName =       .*/DefaultPathName = "\/opt\/derby\/lib\/derby.jar"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultEJBDeployType = ".*/DefaultEJBDeployType = "DERBY_V10"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultTradeAppName = ".*/DefaultTradeAppName = "DayTrader7"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultEarFile =      ".*/DefaultEarFile = "\/opt\/daytrader7\/daytrader-ee7\/build\/libs\/daytrader-ee7.ear"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DerbyPath =             ".*/DerbyPath = "\/opt\/derby\/lib\/derby.jar"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/#\(scope = .*Server.*\)/\1/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i '/.*scope = .*NodeName+"\/".*/d' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultUseMetadata =  "true"/DefaultUseMetadata =  "false"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultRunWSDeploy =  "false"/DefaultRunWSDeploy =  "true"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i 's/DefaultXA = "false"/DefaultXA = "true"/g' /opt/daytrader7/scripts/daytrader_SILENT_singleServer.py && \
    sudo sed -i '/import sre/d' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/providerId = AdminConfig.createUsingTemplate.*/providerId = AdminTask.createJDBCProvider(["-scope", "Node=DefaultNode01,Server=server1", "-databaseType", "Derby", "-providerType", "Derby JDBC Provider", "-implementationType", "Connection pool data source", "-name", "Derby JDBC Provider", "-classpath", "\/opt\/derby\/lib\/derby.jar", "-nativePath", ""])/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/\(Derby.*\) Only":/\1":/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/\(Derby.*\) Only (XA)":/\1 (XA)":/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/dsId = AdminConfig.createUsingTemplate.*/dsId = AdminTask.createDatasource(providerId, ["-name", datasourceName, "-jndiName", jndiName, "-dataStoreHelperClassName", "com.ibm.websphere.rsadapter.DerbyDataStoreHelper", "-containerManagedPersistence", "true", "-componentManagedAuthenticationAlias", "TradeDataSourceAuthData", "-configureResourceProperties", "[[databaseName java.lang.String TradeDB]]"])/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/parms += " -usedefaultbindings"/parms += " -usedefaultbindings -defaultbinding.ee.defaults"/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/, "-subscriptio.*/]/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/parms += " -nodeployejb"/parms += ""/g' /opt/daytrader7/scripts/resource_scripts.py && \
    sudo sed -i 's/parms += " -nodeployws"/parms += ""/g' /opt/daytrader7/scripts/resource_scripts.py && \
    echo "# For some reason, Derby doesn't like the default locale so we override it." && \
    echo "# Also increase System*.log and trace*log rotation: https://www.ibm.com/support/knowledgecenter/en/SSEQTP_9.0.5/com.ibm.websphere.base.doc/ae/txml_logrotation.html" && \
    printf '\n\
server = AdminConfig.getid("/Cell:DefaultCell01/Node:DefaultNode01/Server:server1/")\n\
jvm = AdminConfig.list("JavaVirtualMachine", server)\n\
AdminConfig.modify(jvm, [["genericJvmArguments", "-Duser.country=US -Duser.language=en"]])\n\
\n\
log = AdminConfig.showAttribute(server, "outputStreamRedirect")\n\
AdminConfig.modify(log, [["rolloverSize", 100]])\n\
\n\
log = AdminConfig.showAttribute(server, "errorStreamRedirect")\n\
AdminConfig.modify(log, [["rolloverSize", 100]])\n\
\n\
trace = AdminConfig.list("TraceService", server)\n\
log = AdminConfig.showAttribute(trace, "traceLog")\n\
AdminConfig.modify(log, [["rolloverSize", 100]])\n\
\n\
AdminConfig.save()\n\
\n' > /home/was/twas.jy && \
    echo "# wsadmin script after the base DayTrader7 script is run:" && \
    echo "# * Set createDatabase=true custom property" && \
    printf '\n\
for dsName in ["TradeDataSource", "NoTxTradeDataSource"]:\n\
  ds = AdminConfig.getid("/Cell:DefaultCell01/Node:DefaultNode01/Server:server1/JDBCProvider:Derby JDBC Provider/DataSource:" + dsName + "/")\n\
  ps = AdminConfig.showAttribute(ds, "propertySet")\n\
  props = AdminConfig.list("J2EEResourceProperty", ps).splitlines()\n\
  for prop in props:\n\
    propName = AdminConfig.showAttribute(prop, "name")\n\
    if propName == "createDatabase":\n\
      AdminConfig.modify(prop, "[[value create]]")\n\
\n\
AdminConfig.save()\n\
\n' > /home/was/twas_daytrader_finalize.jy && \
    echo "# Initialize tWAS DayTrader" && \
    ( \
      cd /opt/daytrader7/scripts/ && \
      /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
      /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f /home/was/twas.jy -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f daytrader_SILENT_singleServer.py -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f /home/was/twas_daytrader_finalize.jy -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
      curl "http://localhost:9081/daytrader/config?action=buildDBTables" && \
      /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
      curl "http://localhost:9081/daytrader/config?action=buildDB" && \
      /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)" \
    ) && \
    sudo mv /opt/daytrader7/jmeter_files/daytrader7.jmx /opt/daytrader7/jmeter_files/daytrader7_liberty.jmx && \
    sudo cp /opt/daytrader7/jmeter_files/daytrader7_liberty.jmx /opt/daytrader7/jmeter_files/daytrader7_twas.jmx && \
    sudo sed -i 's/9080/9081/g' /opt/daytrader7/jmeter_files/daytrader7_twas.jmx && \
    sudo chmod a+rw /opt/daytrader7/jmeter_files/daytrader7_twas.jmx

RUN --mount=type=secret,id=remotepassword \
    sudo /usr/sbin/slapd -F /etc/openldap/slapd.d -h "ldapi:// ldap://" && \
    printf 'dn: cn=wsadminldap,ou=Users,dc=example,dc=com\n\
cn: wsadminldap LastNameWsadminldap\n\
sn: LastNameWsadminldap\n\
objectClass: inetOrgPerson\n\
userPassword: %s\n\
uid: wsadminldap\n\
\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" | sudo tee /root/wsadmin.ldif && \
    sudo ldapadd -x -D "cn=Manager,dc=example,dc=com" -w "$(echo -n "$(sudo head -n 1 /root/password.txt)")" -f /root/wsadmin.ldif && \
    printf '\n\
AdminTask.createIdMgrLDAPRepository("[-default true -id LDAP1 -adapterClassName com.ibm.ws.wim.adapter.ldap.LdapAdapter -ldapServerType CUSTOM -sslConfiguration -certificateMapMode exactdn -supportChangeLog none -certificateFilter -loginProperties uid]")\n\
AdminTask.addIdMgrLDAPServer("[-id LDAP1 -host localhost -bindDN cn=Manager,dc=example,dc=com -bindPassword %s -referal ignore -sslEnabled false -ldapServerType CUSTOM -sslConfiguration -certificateMapMode exactdn -certificateFilter -authentication simple -port 389]")\n\
AdminTask.addIdMgrRepositoryBaseEntry("[-id LDAP1 -name dc=example,dc=com -nameInRepository dc=example,dc=com]")\n\
AdminTask.addIdMgrRealmBaseEntry("[-name defaultWIMFileBasedRealm -baseEntry dc=example,dc=com]")\n\
AdminTask.configureAdminWIMUserRegistry("[-realmName defaultWIMFileBasedRealm -verifyRegistry false ]")\n\
AdminTask.configureAdminWIMUserRegistry("[-autoGenerateServerId true -primaryAdminId wsadmin -ignoreCase true -customProperties -verifyRegistry false ]")\n\
AdminTask.mapUsersToAdminRole("[-accessids [user:defaultWIMFileBasedRealm/cn=Admin1,ou=Users,dc=example,dc=com] -userids [Admin1] -roleName administrator]")\n\
AdminTask.mapUsersToAdminRole("[-accessids [user:defaultWIMFileBasedRealm/cn=wsadminldap,ou=Users,dc=example,dc=com] -userids [wsadminldap] -roleName administrator]")\n\
\n\
AdminConfig.save()\n\
\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" > /home/was/twas_config_ldap.jy && \
      /opt/IBM/WebSphere/AppServer/bin/startServer.sh server1 && \
      /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -f /home/was/twas_config_ldap.jy -username wsadmin -password "$(cat /tmp/PASSWORD)" && \
      /opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1 -username wsadmin -password "$(cat /tmp/PASSWORD)"

# This should be the last real command because it's the most likely file to get a minor update.
COPY ["WebSphere_Application_Server_Troubleshooting_and_Performance_Lab_on_Docker.pdf", "/opt/docs/"]

EXPOSE 8080 8081 8082 9080 9081 9082 9443 9444 9445 12000 12005

# Last statement must be switching to root for supervisord
USER root

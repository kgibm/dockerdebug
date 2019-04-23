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
#   docker run --cap-add SYS_PTRACE --ulimit core=-1 --rm -p 9080:9080 -p 9443:9443 -p 9043:9043 -p 9081:9081 -p 9444:9444 -p 3389:3389 -p 5901:5901 -p 5902:5902 -p 22:22 -it kgibm/fedorawasdebug
# Step 4: Remote into the docker image
#   Linux:
#     root: vncviewer localhost:5901
#     was: vncviewer localhost:5902
#     Use the password from remotepassword.txt
#   Mac:
#     root: open vnc://localhost:5901
#     was: open vnc://localhost:5902
#     Use the password from remotepassword.txt
#   Windows: Remote desktop to localhost and use the username of root or was
#            and the password from remotepassword.txt
#

FROM kgibm/fedorajavadebug

LABEL maintainer="kevin.grigorenko@us.ibm.com"

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

#####################
# "Install" Liberty #
#####################

# https://hub.docker.com/_/websphere-liberty
# https://hub.docker.com/_/open-liberty

# 19.0.0.3 has a bug installing adminCenter-1.0 so we use the latest beta
#COPY --from=websphere-liberty:latest --chown=was:root /opt/ibm/helpers /opt/ibm/helpers
COPY --from=websphere-liberty:beta --chown=was:root /opt/ibm/wlp /opt/ibm/wlp
COPY --from=websphere-liberty:beta --chown=was:root /logs /logs
#COPY --from=websphere-liberty:latest --chown=was:root /licenses /licenses
COPY --from=websphere-liberty:beta --chown=was:root /etc/wlp /etc/wlp

RUN ln -s $WLP_OUTPUT_DIR/defaultServer /output && \
    ln -s /opt/ibm/wlp/usr/servers/defaultServer /config && \
    ln -s /opt/ibm /liberty && \
    ln -s /opt/ibm/wlp/usr/shared/resources/lib.index.cache /lib.index.cache

# In case the user restarts Liberty from the command line instead of supervisord, we need
# to set the right envars
RUN printf '\n\
LOG_DIR=/logs\n\
WLP_OUTPUT_DIR=/opt/ibm/wlp/output\n\
KEYSTORE_REQUIRED=true\n\
RANDFILE=/tmp/.rnd\n\
JVM_ARGS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/"\n\
\n' >> /config/server.env

#############################
# "Install" Traditional WAS #
#############################

# https://hub.docker.com/r/ibmcom/websphere-traditional

COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /work /work
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /licenses/* /licenses/
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /opt/IBM /opt/IBM
COPY --from=ibmcom/websphere-traditional:latest --chown=was:root /etc/websphere /etc/websphere

# Run Liberty initialization script at startup:
RUN printf '#!/bin/sh\n\
if [ -e /opt/ibm/helpers/runtime/docker-server.sh ]; then\n\
    /opt/ibm/helpers/runtime/docker-server.sh\n\
fi\n\
\n' > /extended_entrypoint.sh

USER was

RUN sed -i 's/"9443"/"9444"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"7276"/"7277"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"7286"/"7287"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"9080"/"9081"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"2809"/"2810"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/"9402"/"9404"/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/nodes/${NODE_NAME}/serverindex.xml && \
    sed -i 's/9080/9081/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/virtualhosts.xml && \
    sed -i 's/9443/9444/g' /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/config/cells/${WAS_CELL}/virtualhosts.xml && \
    sed -i "s/ps -C .*/pgrep -f 'WsServer ')/g" /work/start_server.sh

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

# https://github.com/kgibm/was_data_mining/
RUN ( \
      cd /opt/ && \
      sudo git clone https://github.com/kgibm/was_data_mining/ \
    )

###############
# Install WDT #
###############

# https://marketplace.eclipse.org/content/ibm-liberty-developer-tools
# https://marketplace.eclipse.org/node/1778478/api/p
# http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/updates/wdt/
RUN sudo /opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director \
                              -repository http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/updates/wdt/2019-03_comp/,http://download.eclipse.org/releases/2019-03,http://download.eclipse.org/eclipse/updates/4.11,http://download.eclipse.org/webtools/repository/latest \
                              -installIU com.ibm.wdt.ast.ws.tools.feature.feature.group \
                              -installIU com.ibm.osgi.wdt.feature.feature.group \
                              -installIU com.ibm.websphere.wdt.server.tools.main.feature.group \
                              -installIU com.ibm.wdt.migration.tools.feature.feature.group \
                              -installIU com.ibm.wdt.webtools.top.feature.feature.group

# Required after installing anything into Eclipse
RUN sudo chmod -R a+w /opt/eclipse/configuration

##################
# Configure tWAS #
##################

RUN printf 'nodeName = AdminControl.getNode()\n\
serverName = AdminServerManagement.listServers()[0]\n\
serverName = serverName[:serverName.find("(")]\n\
#AdminApplication.uninstallApplication("DefaultApplication")\n\
# https://www.ibm.com/support/knowledgecenter/en/SSAW57_9.0.0/com.ibm.websphere.nd.multiplatform.doc/ae/rxml_taskoptions.html\n\
AdminApp.install("/opt/problemdetermination/swat.ear", ["-appname", "swat", "-node", nodeName, "-server", serverName, "-usedefaultbindings"])\n\
AdminConfig.save()\n' > /work/config/install_app.py

RUN --mount=type=secret,id=remotepassword if [ "$(sudo head -n 1 /run/secrets/remotepassword)" != "" ]; then echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" > /tmp/PASSWORD; fi

RUN /work/configure.sh

#####################
# Configure Liberty #
#####################

RUN cp /opt/problemdetermination/swat.ear /config/dropins/ && chown was:root /config/dropins/swat.ear

############################
# Add supervisord programs #
############################

# Deployed applications at http://localhost:9080/ and https://localhost:9443/
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
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
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
environment=\n\
    HOME="/home/was",\n\
    USER="was",\n\
\n' | sudo tee twas.supervisord.conf

RUN --mount=type=secret,id=remotepassword echo -n "$(sudo head -n 1 /run/secrets/remotepassword)" | /setpassword.sh

# https://github.com/WASdev/sample.daytrader7
RUN ( \
      cd /opt/ && \
      sudo git clone https://github.com/WASdev/sample.daytrader7 daytrader7 && \
      cd /opt/daytrader7 && \
      sudo gradle build \
    )

# https://publib.boulder.ibm.com/httpserv/cookbook/
RUN sudo mkdir /opt/cookbook && \
    sudo wget -q -O /opt/cookbook/WAS_Performance_Cookbook.pdf https://publib.boulder.ibm.com/httpserv/cookbook/WAS_Performance_Cookbook.pdf

# DayTrader7 is JEE7, but install JEE8 in case another server is created that needs it
RUN /opt/ibm/wlp/bin/installUtility install --acceptLicense javaee-8.0 && \
    mkdir -p /config/configDropins/overrides/

RUN cp /opt/daytrader7/daytrader-ee7/build/libs/daytrader-ee7.ear /config/dropins/

RUN sudo dnf install -y mariadb-server mariadb-java-client && \
    sudo mysql_install_db --skip-test-db --user=mysql

RUN printf '\n\
UPDATE mysql.user SET Password = PASSWORD("%s") WHERE User = "root";\n\
FLUSH PRIVILEGES;\n\
CREATE DATABASE TradeDB;\n\
\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" | sudo tee /var/lib/mysql/init.sql

# https://mariadb.com/kb/en/library/mysqld-options/
RUN printf '\n\
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
\n' | sudo tee mysqld.supervisord.conf

RUN sed -i '/.*webProfile.*/d' /config/server.xml

# https://github.com/WASdev/sample.daytrader7/blob/master/daytrader-ee7-wlpcfg/servers/daytrader7Sample/server.xml
RUN printf '\n\
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
</server>\n' "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" "$(echo -n "$(sudo head -n 1 /root/password.txt)")" > /config/configDropins/overrides/daytrader.xml

RUN /opt/ibm/wlp/bin/installUtility install --acceptLicense defaultServer

# https://mariadb.com/kb/en/library/identifier-case-sensitivity/
RUN sudo sed -i 's/\[mysqld\]/[mysqld]\nlower_case_table_names=1/g' /etc/my.cnf.d/mariadb-server.cnf

RUN sudo sed -i 's/9082/9080/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo sed -i 's/THREADS,50/THREADS,4/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo chmod -R a+w /opt/daytrader7/jmeter_files && \
    sudo sed -i 's/\(ResultCollector.*StatVisualizer.*enabled="\)false/\1true/g' /opt/daytrader7/jmeter_files/daytrader7.jmx && \
    sudo sed -i 's/ThreadGroup.scheduler">true/ThreadGroup.scheduler">false/g' /opt/daytrader7/jmeter_files/daytrader7.jmx

# https://db.apache.org/derby/
RUN ( \
      cd /opt/ && \
      sudo wget -q -O /opt/derby.zip https://www.apache.org/dist//db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-bin.zip && \
      sudo unzip derby.zip && \
      sudo rm derby.zip && \
      sudo mv *derby* derby \
    )

EXPOSE 9080 9081 9443 9444

# Required for supervisord
USER root

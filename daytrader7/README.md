# DayTrader7 Dockerfiles

DayTrader7 on WAS Liberty 19.0.0.9:

* `docker build -f Dockerfile.19009 -t dt7_19009 .`
* Terminal 1: `docker run --rm -it dt7_19009`
* Terminal 2: `docker exec -it $(docker ps -f "ancestor=dt7_19009" --format "{{.ID}}") /opt/apache-jmeter-5.1.1/bin/jmeter -n -t /home/default/sample.daytrader7/jmeter_files/daytrader7.jmx -JHOST=localhost -JPORT=9080 -JPROTOCOL=http -JMAXTHINKTIME=100 -JDURATION=300`

DayTrader7 on WAS Liberty 19.0.0.10:

* `docker build -f Dockerfile.190010 -t dt7_190010 .`
* Terminal 1: `docker run --rm -it dt7_190010`
* Terminal 2: `docker exec -it $(docker ps -f "ancestor=dt7_190010" --format "{{.ID}}") /opt/apache-jmeter-5.1.1/bin/jmeter -n -t /home/default/sample.daytrader7/jmeter_files/daytrader7.jmx -JHOST=localhost -JPORT=9080 -JPROTOCOL=http -JMAXTHINKTIME=100 -JDURATION=300`

FROM tomcat:7-jre8

MAINTAINER Lee Evans - www.ltscomputingllc.com

# OHDSI WebAPI and web applications running in a Tomcat 7 server on Java JRE 8

# the WEBAPI_WAR argument is defaulted here to the WEBAPI war file for the required WebAPI release
# optionally override the war file url when building this container using: --build-arg WEBAPI_WAR=<webapi war file name>
ARG WEBAPI_WAR=WebAPI-1.0.0.war
ENV WEBAPI_RELEASE=1.5.0

# add a Tomcat server management web UI 'admin' user with default 'abc123' password!
COPY tomcat-users.xml /usr/local/tomcat/conf/

# install linux utilities and supervisor daemon
RUN apt-get update && apt-get install -y --no-install-recommends \
		wget \
		unzip \
		supervisor \
	&& rm -rf /var/lib/apt/lists/*

# deploy the OHDSI WEBAPI and OHDSI web applications to the Tomcat server

# set working directory to the Tomcat server webapps directory
WORKDIR /usr/local/tomcat/webapps

# deploy the OHDSI WebAPI war file from the OHDSI CI Nexus repository
ENV WEBAPI_WAR_URL=http://repo.ohdsi.org:8085/nexus/service/local/repositories/releases/content/org/ohdsi/WebAPI/1.0.0/$WEBAPI_WAR

RUN wget $WEBAPI_WAR_URL \
	&& mv /usr/local/tomcat/webapps/WebAPI*.war /usr/local/tomcat/webapps/WebAPI.war

# deploy latest released OHDSI Atlas web application
RUN wget https://github.com/OHDSI/Atlas/archive/released.zip \
        && unzip /usr/local/tomcat/webapps/released.zip \
	&& mv /usr/local/tomcat/webapps/Atlas-released /usr/local/tomcat/webapps/atlas \
	&& rm -f released.zip

# deploy latest released OHDSI Penelope web application
RUN wget https://github.com/OHDSI/Penelope/archive/master.zip \
        && unzip /usr/local/tomcat/webapps/master.zip \
	&& mv /usr/local/tomcat/webapps/Penelope-master /usr/local/tomcat/webapps/penelope \
	&& rm -f master.zip

# deploy demo SynPUF 1k simulated patients Achilles report data as an Atlas data source
RUN mkdir -p /usr/local/tomcat/webapps/atlas/data
COPY datasources.json /usr/local/tomcat/webapps/atlas/data/
COPY achilles-synpuf-1k.zip /usr/local/tomcat/webapps/atlas/data/
RUN unzip /usr/local/tomcat/webapps/atlas/data/achilles-synpuf-1k.zip -d /usr/local/tomcat/webapps/atlas/data/ \
	&& rm -f /usr/local/tomcat/webapps/atlas/data/achilles-synpuf-1k.zip

# create directories for optional jdbc drivers, achilles data source reports and log files
RUN mkdir -p /tmp/drivers /tmp/achilles-data-reports /var/log/supervisor

# install supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# install the bash shell deploy script that supervisord will run whenever the container is started
COPY deploy-script.sh /usr/local/tomcat/bin/
RUN chmod +x /usr/local/tomcat/bin/deploy-script.sh

# run supervisord to execute the deploy script (which also starts the tomcat server)
CMD ["/usr/bin/supervisord"]

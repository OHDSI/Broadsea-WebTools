FROM tomcat:9.0.46-jdk8-openjdk-buster

MAINTAINER Lee Evans - www.ltscomputingllc.com

# OHDSI WebAPI and ATLAS web application running in Tomcat

# set the WEBAPI_RELEASE environment variable within the Docker container
ENV WEBAPI_RELEASE=2.9.0

# optionally override the war file url when building this container using: --build-arg WEBAPI_WAR=<webapi war file name>
ARG WEBAPI_WAR=WebAPI-2.9.0.war

# install linux utilities and supervisor daemon
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    supervisor \
    build-essential \
    nodejs \
    curl \
    git-core \
    && rm -rf /var/lib/apt/lists/*

# install specific npm version for this build
WORKDIR ~
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh \
    && chmod +x nodesource_setup.sh \
    && bash nodesource_setup.sh
RUN apt-get update && apt-get install -y --no-install-recommends \
    npm \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g npm@6.1.0

# deploy the OHDSI WEBAPI and OHDSI ATLAS web application to the Tomcat server

# set working directory to the Tomcat server webapps directory
WORKDIR /usr/local/tomcat/webapps

# deploy the released OHDSI WebAPI war file from the OHDSI CI Nexus repository
ENV WEBAPI_WAR_URL=https://repo.ohdsi.org/nexus/repository/releases/org/ohdsi/WebAPI/$WEBAPI_RELEASE/$WEBAPI_WAR
RUN wget $WEBAPI_WAR_URL \
    && mv /usr/local/tomcat/webapps/WebAPI*.war /usr/local/tomcat/webapps/WebAPI.war

# deploy the released OHDSI Atlas web application
RUN wget https://github.com/OHDSI/Atlas/archive/v$WEBAPI_RELEASE.zip \
    && unzip /usr/local/tomcat/webapps/v$WEBAPI_RELEASE.zip \
    && mv /usr/local/tomcat/webapps/Atlas-$WEBAPI_RELEASE /usr/local/tomcat/webapps/atlas \
    && rm -f v$WEBAPI_RELEASE.zip

# bundle the OHDSI Atlas code modules
WORKDIR /usr/local/tomcat/webapps/atlas
RUN npm run build

# create directories for optional jdbc drivers and the log files
RUN mkdir -p /tmp/drivers /var/log/supervisor

# install supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# install Atlas local configuration file
COPY config-local.js /usr/local/tomcat/webapps/atlas/js/

# install Atlas GIS local configuration file
COPY config-gis.js /usr/local/tomcat/webapps/atlas/js/

# install the bash shell deploy script that supervisord will run whenever the container is started
COPY deploy-script.sh /usr/local/tomcat/bin/
RUN chmod +x /usr/local/tomcat/bin/deploy-script.sh

# run supervisord to execute the deploy script (which also starts the tomcat server)
CMD ["/usr/bin/supervisord"]

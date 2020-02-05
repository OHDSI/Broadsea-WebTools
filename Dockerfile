FROM tomcat:7-jre8

MAINTAINER Lee Evans - www.ltscomputingllc.com

# OHDSI WebAPI and ATLAS web application running in a Tomcat 7 server on Java JRE 8

# set the WEBAPI_RELEASE environment variable within the Docker container
ENV WEBAPI_RELEASE=2.7.2

# optionally override the war file url when building this container using: --build-arg WEBAPI_WAR=<webapi war file name>
ARG WEBAPI_WAR=WebAPI-1.0.0.war

# add a Tomcat server management web UI 'admin' user with default 'abc123' password!
COPY tomcat-users.xml /usr/local/tomcat/conf/

# install linux utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    build-essential \
    nodejs \
    curl \
    git-core \
    && rm -rf /var/lib/apt/lists/*

# install npm and upgrade it to the latest version
WORKDIR ~
RUN curl -sL https://deb.nodesource.com/setup_11.x -o nodesource_setup.sh \
    && chmod +x nodesource_setup.sh \
    && bash nodesource_setup.sh
RUN apt-get update && apt-get install -y --no-install-recommends \
    npm \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g npm

# deploy the OHDSI WEBAPI and OHDSI ATLAS web application to the Tomcat server

# set working directory to the Tomcat server webapps directory
WORKDIR /usr/local/tomcat/webapps

# deploy the latest OHDSI WebAPI war file from the OHDSI CI Nexus repository (built from GitHub OHDSI WebAPI released branch)
ENV WEBAPI_WAR_URL=http://repo.ohdsi.org:8085/nexus/service/local/repositories/releases/content/org/ohdsi/WebAPI/1.0.0/$WEBAPI_WAR
RUN wget $WEBAPI_WAR_URL \
    && mv /usr/local/tomcat/webapps/WebAPI*.war /usr/local/tomcat/webapps/WebAPI.war

# deploy the latest released OHDSI Atlas web application
RUN wget https://github.com/OHDSI/Atlas/archive/released.zip \
    && unzip /usr/local/tomcat/webapps/released.zip \
    && mv /usr/local/tomcat/webapps/Atlas-released /usr/local/tomcat/webapps/atlas \
    && rm -f released.zip

# bundle the OHDSI Atlas code modules
WORKDIR /usr/local/tomcat/webapps/atlas
RUN npm run build

# create directories for optional jdbc drivers and the log files
RUN mkdir -p /tmp/drivers

# install Atlas local configuration file
COPY config-local.js /usr/local/tomcat/webapps/atlas/js/

# install the bash shell deploy script will run when the container is started
COPY deploy-script.sh /usr/local/tomcat/bin/
RUN chmod +x /usr/local/tomcat/bin/deploy-script.sh

# call the deploy-script.sh (which copies in jdbc drivers also starts the tomcat server)
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]

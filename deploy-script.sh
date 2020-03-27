#!/bin/bash

# make sure the WebAPI URL ends with a slash
if [[ "$WEBAPI_URL" != */ ]]; then
    WEBAPI_URL="$WEBAPI_URL/"
fi

# if set, replace the webapi URL in the config file with the one in the WEBAPI_URL env var
if [ -v WEBAPI_URL ]; then
    sed -i "s,http://localhost:8080/WebAPI/,$WEBAPI_URL,g" /usr/local/tomcat/webapps/atlas/js/config-local.js
fi

# load any jdbc drivers in the docker host volume mapped directory into the tomcat library
cp /tmp/drivers/*.jar /usr/local/tomcat/lib

# start tomcat
/usr/local/tomcat/bin/catalina.sh run

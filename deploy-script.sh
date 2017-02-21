# update the Atlas configuration URL of the OHDSI cloud WebAPI
perl -i -pe "BEGIN{undef $/;} s|{\n.*name: 'Local',\n.*url: 'http://localhost:8080/WebAPI/'\n.*}|{\n name: 'OHDSI Public',\n url: 'http://api.ohdsi.org/WebAPI/'\n }|g" /usr/local/tomcat/webapps/atlas/js/app.js

# update the Atlas configuration data sources path to the Achilles report data
perl -i -pe "BEGIN{undef $/;} s|/achilles/data|data|g" /usr/local/tomcat/webapps/atlas/js/config.js

# update the Atlas configuration URL of the WebAPI
perl -i -pe "BEGIN{undef $/;} s|http://localhost:8080|"$WEBAPI_URL"|g" /usr/local/tomcat/webapps/atlas/js/config.js

# update the Penelope configuration URL of the WebAPI
perl -i -pe "BEGIN{undef $/;} s|http://localhost:8080|"$WEBAPI_URL"|g" /usr/local/tomcat/webapps/penelope/web/js/app.js

# load any jdbc drivers in the docker host volume mapped directory into the tomcat library
cp /tmp/drivers/*.jar /usr/local/tomcat/lib

# if datasources.json exists in docker host volume mapped directory load it
# and the Achilles reports zip files, replacing the demo synpuf1k achilles reports
if [ -f "/tmp/achilles-data-reports/datasources.json" ]
then
  rm -rf /usr/local/tomcat/webapps/atlas/data/*
  cp /tmp/achilles-data-reports/datasources.json /usr/local/tomcat/webapps/atlas/data/
  cp /tmp/achilles-data-reports/*.zip /usr/local/tomcat/webapps/atlas/data/
  cd /usr/local/tomcat/webapps/atlas/data/
  unzip *.zip
fi

# start tomcat
/usr/local/tomcat/bin/catalina.sh run

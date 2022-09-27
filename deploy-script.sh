# load any jdbc drivers in the docker host volume mapped directory into the tomcat library
cp /tmp/drivers/*.jar /usr/local/tomcat/lib

# start tomcat
/usr/local/tomcat/bin/catalina.sh run

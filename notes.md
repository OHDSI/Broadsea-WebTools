# Prerequisites

* Docker Engine
* Docker Compose

# How to build the container

It's not necessary to build the container, if you just want to run it.  
If you decide to build the container:

* The Dockerfile WEBAPI_WAR argument should be set to the WebAPI WAR file name for the required WebAPI release.
* The Dockerfile WEBAPI_RELEASE environment variable should be set to the required WebAPI release number.

```
docker-compose build broadsea-webtools
```

# How to run the container

Edit the docker-compose.yml file to specify the database connection info and Docker host IP/port.  
The docker pull command will pull the container image from Docker Hub. (Skip it if you have built the container on your own machine).

```
docker pull ohdsi/broadsea-webtools
docker-compose up -d
```

Insert the OMOP CDM database connection data for your database(s) in the database **SOURCE** & **SOURCE_DAIMON** tables using a SQL editor.  
Stop the container and start it again (so it will use the database connection data that was just loaded).

# How to view the container status

```
docker-compose ps
```

# How to stop and remove the container

```
docker-compose down
```

See <https://github.com/OHDSI/Broadsea> for more information.

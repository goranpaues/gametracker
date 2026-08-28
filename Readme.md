# Gametracker application demo

The main purpose of this demo is showing how you can create a simple application with Spring Boot, Flyway and Oracle.

## Special Thanks

I used Michael Simons excellent project as a starting point for creating this demo:

[http://github.com/michael-simons/DOAG2016/](http://github.com/michael-simons/DOAG2016/)

Make sure that you look at the commits, as they are very thorough and educational! If you want to learn more about Spring Boot, JOOQ and Oracle Jet I strongly suggest that you explore it. Also read the accompanying blog posts:

1. [Database centric applications with Spring Boot and jOOQ](http://info.michael-simons.eu/2016/10/28/database-centric-applications-with-spring-boot-and-jooq/)
2. [Create a Oracle Database Docker container for your Spring Boot + jOOQ application](http://info.michael-simons.eu/2016/10/30/create-a-oracle-database-docker-container-for-your-spring-boot-jooq-application/)
3. [Take control of your development databases evolution](http://info.michael-simons.eu/2016/10/31/take-control-of-your-development-databases-evolution/)
4. [An HTTP api for analytic queries](http://info.michael-simons.eu/2016/11/02/an-http-api-for-analytic-queries/)
5. [Oracle JET: JavaScript components for mere mortals?](http://info.michael-simons.eu/2016/11/14/oracle-jet-javascript-components-for-mere-mortals/)
 
## Creating and running the demo database

Oracle 26i is used to explore the JSON to Relational duality feature for importing games!

1. Go to [docker.com](http://www.docker.com/products/docker) and install docker on your machine
2. Download [Oracle Database 12c Release 2 Standard Edition 2 for Linux](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html). You will need an Oracle account to download the database and you also need to accept the licensing agreement.
3. Go to [Oracles docker images repository](https://github.com/oracle/docker-images/tree/master/OracleDatabase), download the _OracleDatabase_ scripts and follow the instructions. Remember to add the two files from step 2 to "dockerfiles/12.2.0.1". I used the following command: `./buildDockerImage.sh -v 12.2.0.1 -s`
4. Then, inside this repository, create a running container of this image with `mvn docker:start`. The first start will take a while. The reason behind this is that the Oracle database files are created during the first start and not during image creation. The files are storted inside `${project.basedir}/var`.  There's a timeout of an hour. You may have to change this if you are on a very slow machine
5. The container exposes the following ports to localhost: 1521, 5500 and 5501. The first for SQL*Plus, the later ones for the Oracle Enterprise Manager

You can access the Enterprise manager express for the root container at [https://localhost:5500/em](https://localhost:5500/em) and the container ORCLPDB1 at [https://localhost:5501/em](https://localhost:5501/em). The admin password is a password generated during first startup and you can find it inside the container logs.

Log in with your favourite client using the following details:
```
Username: gametracker
Password: gametracker
Hostname: localhost
Port: 1521
Service name: FREEPDB1
```
You can also use SQLcl to interact with the database, [download it here](http://www.oracle.com/technetwork/developer-tools/sqlcl/overview/)
(you need Java on your machine).
Once you've downloaded and unzipped it, make sure that the directory is in you path variable.
You can then access the _gametracker_ account with 

`sql gametracker/gametracker@//localhost:1521/ORCLPDB1`.

## Configuring the Oracle Maven Repository

This demo uses the Oracle JDBC driver from the official [Oracle Maven Repository](http://www.oracle.com/webfolder/application/maven/index.html) under these coordinates:

```
<dependency>
	<groupId>com.oracle.jdbc</groupId>
	<artifactId>ojdbc8</artifactId>
</dependency>
<dependency>
	<groupId>com.oracle.jdbc</groupId>
	<artifactId>orai18n</artifactId>
</dependency>
```

Please follow these [instructions from Oracle](http://docs.oracle.com/middleware/1213/core/MAVEN/config_maven_repo.htm#MAVEN9010) to make this work for your Maven installation.

## Resources
* [Flyway by Boxfuse](https://flywaydb.org)
* [Database centric applications with Spring Boot and jOOQ](http://info.michael-simons.eu/2016/10/28/database-centric-applications-with-spring-boot-and-jooq/)
* [Spring Initializr](http://start.spring.io)
* [Accessing Relational Data using JDBC with Spring](https://spring.io/guides/gs/relational-data-access/)

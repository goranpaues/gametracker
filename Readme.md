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
 
## Creating and running the demo database locally

Oracle 26i is used to explore the latest functionalities, like the JSON to Relational duality views!

1. Install a Java JDK of your choice if not already installed.
2. Download Docker Desktop on your machine from [docker.com](http://www.docker.com/products/docker) ann install.
3. Go to directory src/main and run ./start.sh. The latest slim image of oracle will be pulled and started. Users utplsql and gametracker will be created in the PDB.
4. Open a new terminal window (to avoid having to shut down db). Go to src/main and install sqlcl and utPLSQL:
```
./install_sqlcl_and_utplsql.sh
```

Log in with your favourite client using the following details:
```
Username: gametracker
Password: gametracker
Hostname: localhost
Port: 1523
Service name: FREEPDB1
```
For example qith sqlcl from the terminal (which should now be installed): 

`sql gametracker/gametracker@//localhost:1523/ORCLPDB1`.

## Resources
* [Flyway by Redgate](https://flywaydb.org)
* [Database centric applications with Spring Boot and jOOQ](http://info.michael-simons.eu/2016/10/28/database-centric-applications-with-spring-boot-and-jooq/)
* [Spring Initializr](http://start.spring.io)
* [Accessing Relational Data using JDBC with Spring](https://spring.io/guides/gs/relational-data-access/)

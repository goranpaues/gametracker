# Gametracker application demo

The main purpose of this demo is to show how AI agents can create code that works using test-driven design.

The example uses a GameTracker application, Spring Boot, Flyway and Oracle to make the result concrete. The agents take a source export, design a normalized Oracle model, generate the Flyway changes and import procedure, create utPLSQL tests, and validate the result against a running Oracle database. The goal is a working, testable change rather than generated code that only looks plausible.

## Agent workflow

The normalized-import demo runs as a closed loop:

1. The analyst turns the source JSON into a candidate schema and import design.
2. The test designer creates the utPLSQL package and test matrix.
3. The validator checks the generated database objects, migrations, annotations and tests.
4. The loop agent repairs failures and reruns the checks until the design passes or the retry limit is reached.

The workflow is defined in `.github/agents/` and `.github/prompts/`. Its acceptance checks include valid Oracle objects, deterministic and idempotent imports, explicit reporting of excluded domains, Flyway's one-statement-per-changeset rule, annotation coverage and passing utPLSQL tests.

## Creating and running the demo database locally

Oracle 26i is used to explore the latest functionalities, like the JSON to Relational duality views!

1. Install a Java JDK of your choice if not already installed.
2. Download Docker Desktop on your machine from [docker.com](http://www.docker.com/products/docker) and install. Alternatively Podman can be used.
3. Go to directory src/main and run 
```
./start.sh. 
```
The latest slim image of oracle will be pulled and started. Users utplsql and gametracker will be created in the PDB.
4. Open a new terminal window. Go to src/main folder and run the following script to install SQLcl, skills and utPLSQL as well as copying grouvee_export.json to the Oracle directory:
```
./initialize_environment.sh
```

## Example prompt to start the Oracle design loop (focused on getting working code for the game import)

1. Open a new chat session in VS Code
2. Ensure that prompt file .github/prompts/start-design-normalized-import.prompt.md is added to the context by selecting it from the Explorer view.
3. Prompt away. Example:
```
Run the Oracle design loop provided in the attached prompt until all acceptance criteria are met.
```
You can create a connection for the gametracker user with the following details:
```
Username: gametracker
Password: gametracker
Hostname: localhost
Port: 1523
Service name: FREEPDB1
```

## Resources

### AI assisted coding
* [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html)
* [Mitchell Hashimoto - My AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey)
* [Relocating Rigor](https://aicoding.leaflet.pub/3mbrvhyye4k2e)

### Flyway and Spring Boot
* [Flyway by Redgate](https://flywaydb.org)
* [Database centric applications with Spring Boot and jOOQ](http://info.michael-simons.eu/2016/10/28/database-centric-applications-with-spring-boot-and-jooq/)
* [Spring Initializr](http://start.spring.io)
* [Accessing Relational Data using JDBC with Spring](https://spring.io/guides/gs/relational-data-access/)

## Special Thanks

This was once a demo on how Flyway can be used. Back then, I used Michael Simons excellent project as a starting point for creating the demo code:

[http://github.com/michael-simons/DOAG2016/](http://github.com/michael-simons/DOAG2016/)

Make sure that you look at the commits, as they are very thorough and educational! If you want to learn more about Spring Boot, JOOQ and Oracle Jet I strongly suggest that you explore it. Also read the accompanying blog posts:

1. [Database centric applications with Spring Boot and jOOQ](http://info.michael-simons.eu/2016/10/28/database-centric-applications-with-spring-boot-and-jooq/)
2. [Create a Oracle Database Docker container for your Spring Boot + jOOQ application](http://info.michael-simons.eu/2016/10/30/create-a-oracle-database-docker-container-for-your-spring-boot-jooq-application/)
3. [Take control of your development databases evolution](http://info.michael-simons.eu/2016/10/31/take-control-of-your-development-databases-evolution/)
4. [An HTTP api for analytic queries](http://info.michael-simons.eu/2016/11/02/an-http-api-for-analytic-queries/)
 

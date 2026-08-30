package com.guran.gametracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import java.util.Optional;
import java.util.Properties;

@SpringBootApplication
public class GametrackerApplication {

	// Get PORT and HOST from Environment or set default
	public static final Optional host;
	public static final Optional port;
	public static final Properties myProps = new Properties();

	static {
		host = Optional.ofNullable(System.getenv("HOSTNAME"));
		port = Optional.ofNullable(System.getenv("PORT"));
	}

	public static void main(String[] args) {
		// Set properties

		myProps.setProperty("server.address", (String) host.orElse("localhost"));
		myProps.setProperty("server.port", (String) port.orElse("8080"));

		SpringApplication app = new SpringApplication(GametrackerApplication.class);
		app.setDefaultProperties(myProps);
		app.run(args);

	}
}

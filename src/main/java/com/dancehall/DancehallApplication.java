package com.dancehall;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Starts the dancehall backend application. */
@SpringBootApplication
public class DancehallApplication {

  /** Starts the embedded web server. */
  public static void main(String[] args) {
    SpringApplication.run(DancehallApplication.class, args);
  }
}

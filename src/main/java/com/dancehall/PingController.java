package com.dancehall;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** Exposes a basic application availability endpoint. */
@RestController
public class PingController {

  /** Returns the application availability response. */
  @GetMapping(value = "/ping", produces = MediaType.TEXT_PLAIN_VALUE)
  public String ping() {
    return "pong";
  }
}

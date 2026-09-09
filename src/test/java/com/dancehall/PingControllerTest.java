package com.dancehall;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class PingControllerTest {

  @LocalServerPort private int port;

  @Test
  void pingReturnsPlainTextPong() throws Exception {
    try (HttpClient client =
        HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build()) {
      HttpRequest request =
          HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/ping"))
              .timeout(Duration.ofSeconds(5))
              .GET()
              .build();

      HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

      assertEquals(200, response.statusCode());
      String contentType = response.headers().firstValue("Content-Type").orElseThrow();
      assertEquals("text/plain", contentType.split(";", 2)[0].trim());
      assertEquals("pong", response.body());
    }
  }
}

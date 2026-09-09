# back-dancehall

Бекенд-сервис для проекта dancehall на Spring Boot 4.1.1 и Spring Web MVC.

Требования: JDK 25 и Maven 3.6.3 или новее.

## Сборка

```bash
mvn package
```

## Запуск

```bash
mvn spring-boot:run
```

Или после сборки:

```bash
java -jar target/back-dancehall-0.0.1-SNAPSHOT.jar
```

По умолчанию приложение слушает порт `8080`.

## Проверка

```bash
curl -i http://localhost:8080/ping
```

`GET /ping` возвращает `200 OK`, `Content-Type: text/plain` и тело `pong`.

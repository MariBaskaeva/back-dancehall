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

## Проверки и CI

Все проверки запускаются одной командой (JDK 25):

```bash
mvn --batch-mode --no-transfer-progress verify
```

Сначала Checkstyle проверяет основной Java-код и тесты, затем Maven компилирует
проект, запускает HTTP-тест `/ping` с настоящим сервером на случайном порту и
собирает исполняемый JAR. Отсутствие тестов и нарушения стиля, включая
предупреждения, считаются ошибками.

Используем [Google Java Style](https://google.github.io/styleguide/javaguide.html)
и встроенный `google_checks.xml` Checkstyle: отступы в два пробела, правила
импортов, именования и Javadoc. Версии плагина и Checkstyle закреплены в `pom.xml`.
CI проверяет код, но не форматирует его. Для настройки IDE используйте Google Java
Style; окончательная проверка — команда `mvn verify`.

GitHub Actions запускает задачу `build-and-test` при pull request в `main`, push в
`main` и вручную через вкладку Actions после появления workflow в основной ветке.
CI использует Ubuntu 24.04, Java 25 Temurin и кеш Maven. Устаревший запуск того же
PR или ветки отменяется при новом коммите. Лимит запуска — 15 минут.

В артефактах запуска доступны отчёты тестов и Checkstyle, включая отчёты
неуспешных проверок, если они успели сформироваться. Исполняемый JAR публикуется
только при успешной проверке. Имена артефактов содержат SHA проверяемого коммита;
срок хранения — 7 дней.

Для `main` используется защита ветки: изменения через PR, обязательная успешная
проверка `build-and-test`, актуальность относительно `main` и одно одобрение
другого участника. Обход правил администраторами, force push и удаление ветки
запрещены. Эти правила настраиваются в GitHub отдельно от workflow.

## Production

Production работает на одном VPS `87.242.119.237` через Docker Compose. nginx
публикует порты 80 и 443, PostgreSQL и backend доступны только внутри Docker-сетей.
Frontend доступен по адресу `https://87.242.119.237/`, публичный backend endpoint —
`https://87.242.119.237/api/ping`.

После успешной проверки push в `main` задача `deploy-production` передаёт
проверенный Docker-образ на VPS по SSH. Сервер проверяет SHA-256 архива и идентификатор
образа, обновляет только backend и ожидает успешный внутренний healthcheck и внешний
`/api/ping`. При ошибке автоматически возвращается предыдущий образ. Production-
деплои выполняются последовательно и не прерываются новым push.

Статические frontend-релизы хранятся в `/opt/dancehall/frontend/releases`; nginx
читает активную версию через атомарно переключаемую ссылку `current`. Frontend CD
проверяет checksum и SHA релиза, `/` и `/api/ping`, хранит предыдущую успешную
версию и автоматически откатывается при ошибке. Общий lock последовательно
выполняет backend- и frontend-деплои.

На уже работающем VPS поддержку frontend нужно включить один раз из проверенного
checkout командой `sudo deploy/enable-frontend.sh`. Скрипт обновляет только общую
Compose/nginx-конфигурацию и устанавливает frontend deploy command.

Первичная настройка сервера описана в `deploy/bootstrap.sh`. Она устанавливает
Docker Engine и Compose, включает firewall для SSH/HTTP/HTTPS, создаёт отдельного
пользователя CD, PostgreSQL 18, nginx и сертификат Let's Encrypt для IP. Сертификат
проверяется на продление каждые шесть часов. В firewall или security group панели
VPS также должны быть разрешены входящие TCP-порты 80 и 443 для `0.0.0.0/0`.

Ежедневный дамп PostgreSQL создаётся в `/opt/dancehall/backups`, локально хранятся
последние семь дней. Восстановление проверяется командой:

```bash
sudo /usr/local/sbin/dancehall-restore-check \
  /opt/dancehall/backups/dancehall-YYYYmmddTHHMMSSZ.dump
```

Локальные дампы не защищают от потери VPS. До хранения важных пользовательских
данных необходимо подключить внешнее резервное хранилище.

FROM eclipse-temurin:25-jre-jammy@sha256:3ffcdc93d49d7111e9a82d6f215d66ee518cb01821e957ec2a866ca59e2561d2

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --chown=10001:10001 target/back-dancehall-*.jar /app/app.jar
ARG VCS_REF
LABEL org.opencontainers.image.source="https://github.com/MariBaskaeva/back-dancehall" \
      org.opencontainers.image.revision="${VCS_REF}"
USER 10001:10001
EXPOSE 8080
HEALTHCHECK --interval=5s --timeout=3s --start-period=20s --retries=12 \
    CMD curl --fail --silent http://127.0.0.1:8080/ping | grep -qx pong
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

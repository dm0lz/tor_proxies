FROM alpine:latest AS base

RUN apk add --no-cache tor bash python3 py3-pip

FROM base AS build
COPY tor.sh /app/tor.sh
RUN chmod +x /app/tor.sh

FROM base AS final

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Setup /app as a writable working directory
RUN mkdir /app && chown appuser:appuser /app
WORKDIR /app
USER appuser

COPY --from=build /app/tor.sh /app/

EXPOSE 9050-9150
EXPOSE 8080

ENTRYPOINT [ "/app/tor.sh" ]
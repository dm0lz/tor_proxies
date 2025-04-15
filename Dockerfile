FROM alpine:latest AS base

RUN apk add --no-cache tor bash nodejs npm curl

FROM base AS build
WORKDIR /app
COPY tor.sh /app/tor.sh
COPY package*.json /app/
COPY index.js /app/
RUN chmod +x /app/tor.sh
RUN npm ci --only=production

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

COPY --from=build /app/ /app/

EXPOSE 9150-9250
EXPOSE 8080

ENTRYPOINT [ "/app/tor.sh" ]
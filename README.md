# Tor Proxy

A lightweight Tor proxy service.

## Requirements

- Docker
- Python 3.7+

## Installation

### Using Docker

```bash
docker build -t tor_proxy .
docker run -p 8080:8080 -p 9150-9250:9150-9250 tor_proxy
```

Generate HashedControlPassword :

```bash
tor --hash-password passwd
```

To build and push :

```bash
docker build --platform=linux/amd64,linux/arm64 -t registry-username/tor_proxy:latest --push .
```

### Testing the Connection

```bash
curl --socks5 localhost:9150 https://check.torproject.org/api/ip
```

Access the proxy mappings at: http://localhost:8080/proxies.json

Request a new identity :

```bash
curl -X POST http://localhost:8080/newnym/fr
```

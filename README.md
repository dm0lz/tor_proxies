# Tor Proxy

A service that runs multiple Tor instances, each configured with a specific country exit node, providing a pool of country-specific SOCKS5 proxies.

## Features

- Automatically spawns multiple Tor instances with country-specific exit nodes
- Provides SOCKS5 proxies for different countries
- REST API to:
  - Get proxy mappings (country -> SOCKS5 port)
  - Request new identity for a specific country
- Dynamic proxy port allocation (9150-9250 range)
- Lightweight Docker container

## Requirements

- Docker
- Python 3.7+

## Installation

### Using Docker

```bash
docker build -t tor_proxies .
docker run -p 8090:8090 -p 9150-9250:9150-9250 tor_proxies
```

Generate HashedControlPassword :

```bash
tor --hash-password passwd
```

To build and push :

```bash
docker build --platform=linux/amd64,linux/arm64 -t registry-username/tor_proxies:latest --push .
```

### Testing the Connection

```bash
curl --socks5 localhost:9150 https://check.torproject.org/api/ip
```

Access the proxy mappings at: http://localhost:8090/proxies.json

Request a new identity :

```bash
curl -X POST http://localhost:8090/newnym/fr
```

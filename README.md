# Tor Proxy

A lightweight Tor proxy service.

## Requirements

- Docker
- Python 3.7+

## Installation

### Using Docker

```bash
docker build -t tor-proxy .
docker run -p 8080:8080 -p 9050-9100:9050-9100 tor-proxy
```

### Testing the Connection

```bash
curl --socks5 localhost:9050 https://check.torproject.org/api/ip
```

Access the proxy mappings at: http://localhost:8080/proxies.json

## License

MIT License

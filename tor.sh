#!/bin/bash

# COUNTRIES=("fr" "us")
COUNTRIES=("us" "fr" "de" "es" "it")
BASE_SOCKS_PORT=9150
BASE_CONTROL_PORT=15000
MAPPING_FILE="./proxies.json"

# Convert to absolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "{" > "$MAPPING_FILE"

for i in "${!COUNTRIES[@]}"; do
  COUNTRY="${COUNTRIES[$i]}"
  SOCKS_PORT=$((BASE_SOCKS_PORT + i))
  CONTROL_PORT=$((BASE_CONTROL_PORT + i))
  DATA_DIR="$SCRIPT_DIR/tor_data_$COUNTRY"
  LOG_FILE="$DATA_DIR/tor_$COUNTRY.log"

  mkdir -p "$DATA_DIR"

  echo "Starting Tor for $COUNTRY on SOCKS port $SOCKS_PORT..."

  tor \
    --RunAsDaemon 1 \
    --SocksPort "0.0.0.0:$SOCKS_PORT" \
    --ControlPort "0.0.0.0:$CONTROL_PORT" \
    --CookieAuthentication 0 \
    --HashedControlPassword "16:6359B2674A47D83060B5020A5EC000FA0182D5CE9B52E73F7DD1187B8F" \
    --DataDirectory "$DATA_DIR" \
    --ExitNodes "{$COUNTRY}" \
    --StrictNodes 1 \
    --MaxCircuitDirtiness 600 \
    --Log "notice file $LOG_FILE"

  # Write JSON mapping entry
  echo "\"$COUNTRY\": {\"socks_port\": $SOCKS_PORT, \"control_port\": $CONTROL_PORT}," >> "$MAPPING_FILE"

  sleep 1
done

echo "}" >> "$MAPPING_FILE"

# Remove trailing comma from the last line
if sed --version >/dev/null 2>&1; then
  sed -i "$(($(wc -l < proxies.json)-1))s/,\s*$/ /" "$MAPPING_FILE"
else
  sed -i '' '$!N;/,\n}/s/,\n}/\n}/' "$MAPPING_FILE"
fi

echo "Tor proxies launched and mapping written to $MAPPING_FILE"

echo "Tor proxies are running. You can access the mapping at http://localhost:8080/proxies.json"

npm start

#!/bin/bash

COUNTRIES=("us" "fr" "de" "es")
# COUNTRIES=("us" "ca" "gb" "de" "fr" "it" "es" "au" "in" "jp" "cn" "br" "ru" "mx" "kr" "sa" "za" "nl" "se" "no" "fi" "dk" "at" "ch" "be" "pl" "gr" "pt" "tr" "ng" "kr" "id" "my" "sg" "ph" "th" "pk" "ua" "cz" "sk" "ro" "hu" "il" "ie" "hr" "cl" "co" "pe" "eg")
BASE_SOCKS_PORT=9050
BASE_CONTROL_PORT=10000
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
    --ControlPort "$CONTROL_PORT" \
    --DataDirectory "$DATA_DIR" \
    --ExitNodes "{$COUNTRY}" \
    --StrictNodes 1 \
    --Log "notice file $LOG_FILE"

  # Write JSON mapping entry
  echo "\"$COUNTRY\": $SOCKS_PORT," >> "$MAPPING_FILE"

  sleep 3
done

# Remove trailing comma from the last line
sed -i '$ s/,$//' "$MAPPING_FILE"

echo "}" >> "$MAPPING_FILE"

echo "Tor proxies launched and mapping written to $MAPPING_FILE"

python3 -m http.server 8080 --bind 0.0.0.0

echo "Tor proxies are running. You can access the mapping at http://localhost:8080/proxies.json"
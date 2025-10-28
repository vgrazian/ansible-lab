#!/bin/bash

# Get the inventory file path (in the same directory as this script's parent)
INVENTORY_FILE="$(dirname "$(dirname "$0")")/inventory"

echo "Testing web servers..."
while read -r line; do
    # Skip empty lines and section headers
    [[ -z "$line" || "$line" =~ ^[[:space:]]*\[ ]] && continue
    
    node=$(echo "$line" | xargs)  # Trim whitespace
    echo -n "$node: "
    curl -s --connect-timeout 2 "http://$node" 2>/dev/null | grep -o "<h1>.*</h1>" || echo "No response or no web server"
done < "$INVENTORY_FILE"

echo -e "\nTesting databases..."
while read -r line; do
    # Skip empty lines and section headers
    [[ -z "$line" || "$line" =~ ^[[:space:]]*\[ ]] && continue
    
    node=$(echo "$line" | xargs)  # Trim whitespace
    echo -n "$node: "
    mysql -h "$node" -u testuser -ptestpass testdb -e "SELECT VERSION();" 2>/dev/null || echo "Failed to connect"
done < "$INVENTORY_FILE"
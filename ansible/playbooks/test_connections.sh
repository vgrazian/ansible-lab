#!/bin/bash

echo "Testing web servers..."
for i in $(seq 1 4); do
    echo -n "lab_node$i: "
    curl -s http://lab_node$i | grep "<h1>"
done

echo -e "\nTesting databases..."
for i in $(seq 1 4); do
    echo -n "lab_node$i: "
    mysql -h "lab_node$i" -u testuser -ptestpass testdb -e "SELECT VERSION();" 2>/dev/null || echo "Failed to connect"
done
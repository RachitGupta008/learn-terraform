#!/bin/bash

sudo apt update && sudo apt -y install apache2

cd /var/www/html
cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB address:${db_address}</p>
<p>DB port</p>
EOF
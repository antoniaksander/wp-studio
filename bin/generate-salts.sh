#!/bin/bash
# Generate WordPress salts in .env format

echo "# Security Keys (Generated: $(date))" > /tmp/salts.tmp

curl -s https://api.wordpress.org/secret-key/1.1/salt/ | \
  sed "s/define('\([^']*\)',\s*'\([^']*\)');/\1='\2'/" >> /tmp/salts.tmp

cat /tmp/salts.tmp
echo ""
echo "Copy the above lines to your .env file (replace existing AUTH_KEY section)"
rm /tmp/salts.tmp
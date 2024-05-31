#!/bin/bash

# Checking vulnarabilities with wordfence
echo "Checking vulnarabilities with wordfence..."
wordfence vuln-scan -l $WORDFENCE_API_KEY \
          --plugin-directory=/var/www/html/wp-content/plugins \
          --theme-directory=/var/www/html/wp-content/themes \
          --wordpress-path=/var/www/html \
          --quiet --output-path /var/www/log/wordfence-vuln-scan.log

# Checking wordpress core checksums
echo "Checking wordpress core checksums..."
wp core verify-checksums --skip-plugins --skip-themes

# Checking plugins checksums
echo "Checking plugins checksums..."
PLUGINS=$(wp plugin list --field=name --skip-themes --skip-plugins --status=active)
for PLUGIN in $PLUGINS; do
	# Store the stderr output of the last command in a variable
	ERROR_OUTPUT=$(wp plugin verify-checksums $PLUGIN 2>&1 >/dev/null)
	# Check if the last command has failed
    wp plugin verify-checksums $PLUGIN --skip-plugins --skip-themes > /dev/null 2>&1
    
    # Check the return value of the last command
    if [ $? -eq 0 ]; then
		if echo $ERROR_OUTPUT | grep -q "Warning"; then
            echo "$PLUGIN: UNAVAILABLE"
        else
			echo "$PLUGIN: PASSED"
		fi
    else
		echo "$PLUGIN: FAILED"
    fi
done

# Scan malware with wordfence-cli
echo "Scanning malware with wordfence-cli..."
wordfence malware-scan /var/www/html/ --quiet --output-path /var/www/log/worfence-malware-scan.csv -w 14 -l $WORDFENCE_API_KEY

# Scan database with clamscan
echo "Scanning malware in database with clamscan..."
wp db export /var/www/backups/security-scan.sql
clamscan --infected --log=/var/www/log/clamscan-database.log /var/www/backups/security-scan.sql
rm /var/www/backups/security-scan.sql

# Scan wp-content with clamscan
echo "Scanning malware in 'wp-content' folder with clamscan..."
clamscan --infected --recursive --log=/var/www/log/clamscan-wp-content.log /var/www/html/wp-content
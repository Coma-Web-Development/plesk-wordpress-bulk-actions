# plesk-wordpress-bulk-actions
Bulk actions under wordress config files / database

# how to execute
1. Enter in the directory plesk-wordpress-bulk-actions/bash_scripts
2. Create or edit the dirs.txt file and add every directory that you want to lookup, one per line
3. Edit the file config_to_be_added.txt and add the configuration that you want
4. Execute: ./add_config_wp-config.php.sh

Notes:
- is recommended to execute with specific linux (ssh) user; use root just for admin purposes
- before change wp-config.php file, one backup will be created in the same dir, with less permissions (closed to others) and the name of the file will be: wp-config.php_linuxtimestamp.zip

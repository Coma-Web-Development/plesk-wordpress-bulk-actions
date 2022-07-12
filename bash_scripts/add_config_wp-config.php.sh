#!/bin/bash

# source library
source library.sh

# global vars
file_name="wp-config.php"
base_dir_directory_to_lookup="/var/www/vhosts" # separated by space
lookup_max_depth=3 # 2 is the minimum
config_file_list=$(mktemp /tmp/XXXXXXXXXXXXXXX)
config_to_be_added=config_to_be_added.txt

main

# unknown error
exit 255

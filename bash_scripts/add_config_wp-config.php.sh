#!/bin/bash

# source library
source library.sh

# global vars
file_name="wp-config.php"
directories_file_name="dirs.txt"
base_dir_directories_to_lookup=""
lookup_max_depth=3 # 2 is the minimum
config_file_list=$(mktemp /tmp/XXXXXXXXXXXXXXX)
config_to_be_added=config_to_be_added.txt

main

# unknown error
exit 255

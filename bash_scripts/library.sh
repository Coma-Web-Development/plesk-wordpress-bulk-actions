#!/bin/bash

createWpConfigFileList()
{
	find $base_dir_directory_to_lookup -maxdepth $lookup_max_depth -type f -iname "wp-config.php" >> $config_file_list 2> /dev/null
}

backupWpConfigFile()
{
	while read local_wp_config_file
	do
		if [ -f $local_wp_config_file ]
		then
			local_timesteamp=$(date "+%s")
			local_basedir=$(dirname $local_wp_config_file)
			zip ${local_basedir}/${local_wp_config_file}_${local_timesteamp}.zip ${local_basedir}/$local_wp_config_file
			chmod 640 ${local_basedir}/${local_wp_config_file}.zip
		fi
	done < $config_file_list
}


addWpConfig()
{
	local_list_wp_config_file=$(mktemp /tmp/XXXXXXXXXXX)
	# loop over wp-config.php files found
	while read local_wp_config_file
	do
		# get all define lines and remove spaces and carriage return
		cat $local_wp_config_file | egrep -i "^define" | tr -d " " | tr -d '\r'  > $local_list_wp_config_file
				
		# loop over all local configs to be added
		while read local_config_to_be_added
		do
			# remove spaces, remove carriage return
			local_config_to_be_added=$(echo $local_config_to_be_added | tr -d ' ' | tr -d '\r')
			# get the md5sum of the config
			local_config_to_be_added_md5sum=$(echo $local_config_to_be_added | md5sum | head -c 32)

			# loop over all define lines
			while read local_wp_config
			do
			# check if it already exist. if yes, does not touch!
				if ! echo $local_wp_config | md5sum | egrep -iq $local_config_to_be_added_md5sum
				then
					echo $local_config_to_be_added >> $local_wp_config_file
				fi
			done < $local_list_wp_config_file
		
		done < $config_to_be_added

		# remove the define temp file
		rm -f $local_list_wp_config_file

    done < $config_file_list
}

main()
{
	createWpConfigFileList
	backupWpConfigFile
	addWpConfig

	# remove temp files
	rm -f $config_file_list
	exit 0
}


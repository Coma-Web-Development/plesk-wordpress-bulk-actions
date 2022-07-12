#!/bin/bash

createWpConfigFileList()
{
	find $base_dir_directories_to_lookup -maxdepth $lookup_max_depth -type f -iname "wp-config.php" >> $config_file_list 2> /dev/null
}

backupWpConfigFile()
{
	while read local_wp_config_file
	do
		if [ -f $local_wp_config_file ]
		then
			local_timesteamp=$(date "+%s")
			local_file_owner=$(stat -c "%U" $local_wp_config_file)
			local_file_group=$(stat -c "%G" $local_wp_config_file)
			zip ${local_wp_config_file}_${local_timesteamp}.zip $local_wp_config_file
			chmod 640 ${local_wp_config_file}_${local_timesteamp}.zip
			chown ${local_file_owner}:${local_file_group} ${local_wp_config_file}_${local_timesteamp}.zip
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
				
		# loop over all define lines
		while read local_wp_config
		do
			# save the md5sum
			echo $local_wp_config | md5sum | head -c 32 >> $local_list_wp_config_file
		done < $local_list_wp_config_file

		# loop over all local configs to be added
		while read local_config_to_be_added
		do
			# remove spaces, remove carriage return
			local_config_to_be_added=$(echo $local_config_to_be_added | tr -d ' ' | tr -d '\r')
			# get the md5sum of the config
			local_config_to_be_added_md5sum=$(echo $local_config_to_be_added | md5sum | head -c 32)

			# check if it already exist. if yes, does not touch!
			if ! cat $local_list_wp_config_file | egrep -iq $local_config_to_be_added_md5sum
			then
				echo -e "\n$local_config_to_be_added" >> $local_wp_config_file
			fi
		
		done < $config_to_be_added

		# remove the define temp file
		rm -f $local_list_wp_config_file

    done < $config_file_list
}

getDirectoriesToLookup()
{
	if [ ! -f $directories_file_name ]
	then
		echo "there is no >>> $directories_file_name <<< file"
		exit 1
	else
		base_dir_directories_to_lookup=$(cat $directories_file_name)		
	fi
}

validateDirectoriesToLookup()
{
	for base_dir_directory_to_lookup in $base_dir_directories_to_lookup
	do
		if [ ! -d $base_dir_directory_to_lookup ]
		then
			echo "the directory >>> $base_dir_directory_to_lookup <<<  is not valid. Double check the >>> $directories_file_name <<< file."
		exit 1
		fi		
	done
}

main()
{
	getDirectoriesToLookup
	validateDirectoriesToLookup
	createWpConfigFileList
	backupWpConfigFile
	addWpConfig

	# remove temp files
	rm -f $config_file_list
	exit 0
}


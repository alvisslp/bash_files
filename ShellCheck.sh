#!/bin/bash

IFS=';'
read -r -a lookup_array <<< "${lookup_files:?}"
error_code=0

mkdir -p "${WORKSPACE}/checkStyleResults"

exec_shell_check () {
	if [[ "$1" != /* ]]
	then
		f_file="${WORKSPACE}/$1"
	else
		f_file=$1
	fi
	shellcheck "$f_file" > /dev/null
	exit_code=$?
	if [ $exit_code -eq 2 ] || [ $exit_code -eq 3 ] || [ $exit_code -eq 4  ]
	then
		error_code=1
	else
		shellcheck "$f_file" -f checkstyle > "${WORKSPACE}/checkStyleResults/$(basename "$f_file").xml"
	fi
}

function launch_files_check {
	for lookup_item in "${lookup_array[@]}"
	do
		if [ -d "$lookup_item" ]
		then
			while IFS= read -r -d '' file
			do
				exec_shell_check "$file"
			done < <(find "$lookup_item" -name "*.sh" -print0)
		elif [ "${lookup_item: -3}" == ".sh" ]
		then
			exec_shell_check "$lookup_item"
		fi
	done
}

launch_files_check

exit $error_code

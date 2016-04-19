#!/bin/bash

function init {
	if [[ -z "${WORKSPACE}" ]]
	then
		WORKSPACE=$PWD
	fi

	error_code=0
	files_list=("${WORKSPACE}")

	mkdir -p "${WORKSPACE}/checkStyleResults"
}

function f_usage {
	printf "Script utilisation :\n"
	printf "\t -h | --help  : show help message"
	printf "\t -d 		: select the source directory (\".\" by default)\n"
	printf "\t -o 		: use only your own files / dir ( you can type : \"ShellCheck -o file1 file2 dir1 file3 dir2)\"\n"
	printf "\t -a 		: add your own files / dir ( you can type : \"ShellCheck -a file1 file2 dir1 file3 dir2)\"\n"
}

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
		if [ $error_code -ne 1 ]
		then
			if (grep -q "severity='error'"  "${WORKSPACE}/checkStyleResults/$(basename "$f_file").xml")
			then
				error_code=1
			fi
		fi
	fi
}

function launch_files_check {
	for lookup_item in "${files_list[@]}"
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

function main {
	init
	launch_files_check
}

while [ $# != 0 ]
do
	case $1 in
		-h|--help) f_usage;
		    exit 0;;
		-d) WORKSPACE=($2);
		    shift 2;;
	    	-o) shift; files_list=("$@");
		    break;;
	    	-a) shift; files_list=("${WORKSPACE[@]}" "$@");
		    break;;
		*) f_usage;
		   exit 0;;
	esac
done

main

exit $error_code

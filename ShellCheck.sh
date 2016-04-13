#!/bin/bash

tmp_IFS=$IFS
IFS=';'
read -r -a lookup_array <<< "$lookup_files"
IFS=$tmp_IFS

mkdir -p ${WORKSPACE}/checkStyleResults

function do_shell_check {
	for lookup_item in ${lookup_array[@]}
	do
		if [ -d $lookup_item ]
		then
			for file in $(find ${lookup_item}  -name "*.sh"); do 
				shellcheck ${file} -f checkstyle > ${WORKSPACE}/checkStyleResults/$(basename ${file}).xml
			done
		elif [ ${lookup_item: -3} == ".sh" ]
		then
			shellcheck $lookup_item -f checkstyle > ${WORKSPACE}/checkStyleResults/$(basename $lookup_item).xml
		fi
	done
}

do_shell_check

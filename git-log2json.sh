#!/bin/bash

# Use this one-liner to produce a JSON literal from the Git log:

iterator=0
echo "{"
for file in "$@"
do      
	if [ $iterator != 0 ]; then
		echo ","
	fi      
	git log -1 --pretty=format:"\"$file\":{%n  \"commit\": \"%H\",%n  \"author\": \"%an <%ae>\",%n  \"date\": \"%ad\",%n  \"message\": \"%f\"%n}" -- "$file"
	iterator=$((iterator+1))
done
echo "}"                                                                                                                                                                                                                                                  

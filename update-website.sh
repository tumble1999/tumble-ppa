#!/bin/bash


function create_docs { # $1:Packages  $2:folder $3:name key $4:start
	FILE=
	if [ ! -f $1 ]; then
		echo "$1 does not exist"
		exit
	fi
	if [ ! -d $2 ]; then mkdir $2; fi
	while read line
	do
		if [ "$line" == "" ]
		then
			if [ "$FILE"!="" ]
			then
				echo --- >> $FILE
				echo Created $FILE
			fi
			continue
		fi
		line=$(echo $line|sed 's/.\///g')
		#echo $line
		kv=($line)
		kv[0]=${kv[0]// /.}
		kv[0]=${kv[0],,}
		#echo ${kv[0]} =\> ${kv[1]}
		if [ ${kv[0]} == $3 ]
		then
			FILE=./$2/${kv[$4]}.md
			echo Creating $FILE...
			echo --- > $FILE
		fi
		echo ${kv[0]} ${kv[@]:1:99} >> $FILE

	done < $1
}

create_docs debian/Packages _apt package: 1
create_docs arch/Packages _pacman name 2

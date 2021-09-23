#!/bin/bash

NAME=PPA_NAME
PPA=.db.tar.gz
EXT=.pkg.tar.zst

if [ "$(cat /etc/os-release | grep ^ID | sed 's/ID=//g')" != "arch" ]
then
	echo "Please run this file in Arch Linux"
	exit
fi

if [ -f Packages ]
then
	rm Packages
fi
touch Packages

if [ -n $(ls *$EXT -l 2>/dev/null) ]
then
	for a in $(ls *$EXT 2>/dev/null)
	do
		pacman -Qip $a >>Packages
	done
fi
repo-add ./$NAME$PPA $(ls *$EXT 2>/dev/null)

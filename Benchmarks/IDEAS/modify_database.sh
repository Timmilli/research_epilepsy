#!/usr/bin/bash

dirs=$(ls -l ./ | grep FCD | cut -d' ' -f10)
todelete=DELETED.md

echo $dirs

read -r -p "Rename, remove or delete? [rename|remove|delete]: " answer

if [ "$answer" = "rename" ];
then
	echo "Rename all files."
	for dir in $dirs;
	do
		printf "\rSubject $dir                          "

		raw_id=${dir:4:4}
		id=$(printf "%04d" "$raw_id")

		filename=$dir
		filename+="_T1w.nii.gz"
		mv $dir/anat/$filename $dir/T1.nii.gz
		filename=$dir
		filename+="_FLAIR.nii.gz"
		mv $dir/anat/$filename $dir/FLAIR.nii.gz

		mv $dir FCD_$id
	done
	echo
	exit
fi

if [ "$answer" = "remove" ];
then
	echo "Removing all files."
	for dir in $dirs
	do
		printf "\rSubject $dir                          "

		rm -rf $dir/anat/
	done
	echo
	exit
fi

if [ "$answer" = "delete" ];
then
	echo "Deleting files."
	while IFS="\n" read -r raw_id;
	do
		id=$(printf "%04s" "$raw_id")
		printf "\rSubject $id   "

		rm -rf FCD_$id
	done < "$todelete"
	echo
	exit
fi

echo "Wrong option name. Leaving."

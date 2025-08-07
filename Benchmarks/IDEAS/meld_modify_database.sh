#!/usr/bin/bash

subjects=./ds005602-1.0.0
dirs=$(ls -l $subjects | grep sub- | cut -d' ' -f10)
todelete=DELETED.md

echo $dirs

read -r -p "[rename|remove|delete|demographic]: " answer

if [ "$answer" = "rename" ]
then
	echo "Renaming all files."
	for dir in $dirs
	do
		printf "\rSubject $dir                          "

		raw_id=${dir:4:4}
		id=$(printf "%04d" "$raw_id")

		filename=$dir
		filename+="_T1w.nii.gz"
		dirname="MELD_H45_3T_FCD_$id/T1"
		mkdir -p $dirname
		mv $subjects/$dir/anat/$filename $dirname/T1.nii.gz

		filename=$dir
		filename+="_FLAIR.nii.gz"
		dirname="MELD_H45_3T_FCD_$id/FLAIR"
		mkdir -p $dirname
		mv $subjects/$dir/anat/$filename $dirname/FLAIR.nii.gz
	done
	echo
	exit
fi

if [ "$answer" = "remove" ]
then
	echo "Removing all files."
	for dir in $dirs
	do
		printf "\rSubject $dir                          "

		rm -rf $subjects/$dir/
	done
	echo
	exit
fi

if [ "$answer" = "delete" ]
then
	echo "Deleting files."
	while IFS="\n" read -r filename
	do
		printf "\rSubject $filename   "

		rm -rf $filename
	done < "$todelete"
	echo
	exit
fi

if [ "$answer" = "demographic" ]
then
	echo "Making the demogrphics_file.csv."
	demofile="demographics_file.csv"
	echo "ID,Age at preoperative,Sex" > $demofile
	{
		read
		while IFS=$',' read -r raw_id group sex age_epi hemisphere lobe type pathology op_memo age_scan age_surg ilae_year1 ilae_year2 ilae_year3 ilae_year4 ilae_year5
		do
			id=$(printf "%04d" "$raw_id")
			filename=MELD_H45_3T_FCD_$id
			if [ -d $filename ]
			then
				printf "\r$filename                 "
				if [ "$sex" = "M" ]
				then
					sex_idx="1"
				else
					sex_idx="0"
				fi
				echo "$filename,$age_scan,$sex_idx" >> $demofile
			fi
		done 
	} < "participants.csv"
	echo
	exit

fi

echo "Wrong option name. Leaving."

#!/usr/bin/bash

mkdir -p input
mkdir -p models
mkdir -p output

subjectdir=../../Benchmarks/OpenNeuro/subjects
participants=participants.tsv
demographicfile=demographics_file.csv
subjectlist=list_subjects.txt

echo "Scanning: $subjectdir" 
nb=$(( $(tree -d -L 1 $subjectdir | wc -l) - 3 ))
echo "$nb directories found"

echo "Continue? [y|n]"
read var1
if [ "$var1" = "n" ]; then
	echo "Giving up."
	exit
fi

echo "ID,Age at preoperative,Sex" > $demographicfile
rm -f $subjectlist
touch $subjectlist

nbdone=0
t1copied=0
flaircopied=0

while IFS=$'\t' read -r file type sex_letter age_epi age_scan rest;
do
	id=${file:5:4}

	if [ -d $subjectdir/$file ];
	then
		nbdone=$(( $nbdone + 1 ))
		printf "\rSubject (%03d/%03d): %s" $nbdone $nb "$id"

		inputdir=input/MELD_H16_3T_FCD_$id/FLAIR
		if [ ! -f $inputdir/FLAIR.nii.gz ]; then
			mkdir -p $inputdir
			cp -r $subjectdir/$file/anat/*FLAIR.nii.gz $inputdir/FLAIR.nii.gz
			flaircopied=$(( $flaircopied + 1 ))
		fi
		inputdir=input/MELD_H16_3T_FCD_$id/T1
		if [ ! -f $inputdir/T1.nii.gz ]; then
			mkdir -p $inputdir
			cp -r $subjectdir/$file/anat/*T1w.nii.gz $inputdir/T1.nii.gz
			t1copied=$(( $t1copied + 1 ))
		fi

		age=$(( $age_scan * 5 - 2 ))
		if [ "$sex_letter" = "M" ]; then
			sex=1
		else 
			sex=0
		fi
		echo -ne ": $age, $type"
		echo "MELD_H16_3T_FCD_$id,$age,$sex" >> $demographicfile

		echo "MELD_H16_3T_FCD_$id" >> $subjectlist
	fi
done < $subjectdir/$participants

echo
echo "$t1copied T1 copied and $flaircopied FLAIR copied."

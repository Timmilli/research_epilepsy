#!/usr/bin/bash

mkdir -p raw
mkdir -p models
mkdir -p output

subjectdir=~/git/Stage/research_epilepsy/Benchmarks/OpenNeuro/subjects
participants=participants.tsv

echo "Scanning: $subjectdir" 
nb=$(( $(tree -d -L 1 $subjectdir | wc -l) - 3 ))
echo "$nb directories found"

echo "Continue? [y|n]"
read var1
if [ "$var1" = "n" ]; then
	echo "Giving up."
	exit
fi

nbdone=0
t1copied=0
flaircopied=0
roicopied=0

while IFS=$'\t' read -r file type sex_letter age_epi age_scan rest;
do
	id=${file:5:4}

	if [ -d $subjectdir/$file ];
	then
		nbdone=$(( $nbdone + 1 ))
		printf "\rSubject (%03d/%03d): %s" $nbdone $nb "$id"

		inputdir=raw/FCD_$id
		if [ ! -f $inputdir/flair.nii.gz ]; then
			mkdir -p $inputdir
			cp $subjectdir/$file/anat/*FLAIR.nii.gz $inputdir/flair.nii.gz
			flaircopied=$(( $flaircopied + 1 ))
		fi
		if [ ! -f $inputdir/t1.nii.gz ]; then
			mkdir -p $inputdir
			cp $subjectdir/$file/anat/*T1w.nii.gz $inputdir/t1.nii.gz
			t1copied=$(( $t1copied + 1 ))
		fi

		if [ "$type" = "fcd" ];
		then
			if [ ! -f $inputdir/flair_roi.nii.gz ]; then
				mkdir -p $inputdir
				cp $subjectdir/$file/anat/*FLAIR_roi.nii.gz $inputdir/flair_roi.nii.gz
				roicopied=$(( $roicopied + 1 ))
			fi
		fi

		age=$(( $age_scan * 5 - 2 ))
		if [ "$sex_letter" = "M" ]; then
			sex="male"
		else 
			sex="female"
		fi
		echo -ne ": $age, $sex, $type                  "
	fi
done < $subjectdir/$participants

echo
echo "$t1copied T1 copied, $flaircopied FLAIR copied and $roicopied ROI copied."

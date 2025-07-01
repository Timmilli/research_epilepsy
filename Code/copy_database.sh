#!/usr/bin/bash

subjectdir=/home/guenael/git/Stage/research_epilepsy/Benchmarks/OpenNeuro/subjects
participants=participants.tsv

echo "Scanning: $subjectdir" 
nb=$(( $(tree -d -L 1 $subjectdir | wc -l) - 3 ))
echo "$nb directories found"

t1copied=0
flaircopied=0
nbdone=0

while IFS=$'\t' read -a values || [[ ${#values[@]} -gt 0 ]];
do
	file=${values[0]}
	id=${file:5:4}

	if [ -d $subjectdir/$file ];
	then
		printf "\rSubject (%03d/%03d): %s" $nbdone $nb "$id"
		nbdone=$(( $nbdone + 1 ))

		inputdir=io/sub-$id
		if [ ! -f $inputdir/flair.nii.gz ]; then
			mkdir -p $inputdir
			cp -r $subjectdir/$file/anat/*FLAIR.nii.gz $inputdir/FLAIR.nii.gz
			flaircopied=$(( $flaircopied + 1 ))
		fi
		if [ ! -f $inputdir/t1.nii.gz ]; then
			mkdir -p $inputdir
			cp -r $subjectdir/$file/anat/*T1w.nii.gz $inputdir/T1.nii.gz
			t1copied=$(( $t1copied + 1 ))
		fi

		age=$(( ${values[4]} * 5 - 2 ))
		if [ "${values[2]}" = "M" ]; then
			sex=1
		else 
			sex=0
		fi
		echo -ne ": $age, ${values[2]}, ${values[1]}            "

	fi
done < $subjectdir/$participants

echo
echo "$t1copied T1 copied and $flaircopied FLAIR copied."

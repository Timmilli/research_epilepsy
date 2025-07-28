#!/usr/bin/bash

benchmarkdir=/home/guenael/git/Stage/research_epilepsy/Benchmarks

subjectdir=$benchmarkdir/IDEAS/ds005602-1.0.0
patients=Metadata_Release_Anon.csv
controls=Metadata_Controls_Release.csv

demographicfile=demographic_file.csv
use_demo=false

echo "Scanning: $subjectdir" 
nb=$(tree -d $subjectdir | grep sub- | wc -l)
echo "$nb directories found"

echo "Continue? [y|n]"
read var1
if [ "$var1" = "n" ]; then
	echo "Giving up."
	exit
fi

echo "Create a demographic file? [y|n]"
read var1
if [ "$var1" = "y" ]; then
	echo "Creating demographic file."
	touch $demographicfile
	echo "ID,Age at preoperative,Sex" > $demographicfile
	use_demo=true
fi

nbdone=0
t1copied=0
flaircopied=0
roicopied=0


while IFS=$',' read -r id sex age_epi fus fqfus fbtcs fqfbtcs se hemisphere lobe pathology op_memo number_asms age_scan age_surg ilae_year1 ilae_year2 ilae_year3 ilae_year4 ilae_year5;
do
	file="sub-$id"

	if [ -d $subjectdir/$file ];
	then
		nbdone=$(( $nbdone + 1 ))
		printf "\rSubject (%04/%04d): %s" $nbdone $nb "$id"

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

		if [ $use_demo ]; then
			IFS=" " read -r -a ages <<< "$age_surg"
			age_preop=${ages[-1]}
			sex_idx="0"
			if [ "$sex" = "M" ]; then
				sex_idx="1"
			fi
			echo "$file,$age_preop,$sex_idx" >> $demographicfile
		fi
	fi
done < $subjectdir/$patients

exit

while IFS=$'\t' read -r id sex age_scan;
do
	id=${file:4:4}

	if [ -d $subjectdir/$file ];
	then
		nbdone=$(( $nbdone + 1 ))
		printf "\rSubject (%04d/%04d): %s" $nbdone $nb "$id"

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
	fi
done < $subjectdir/$controls

echo
echo "$t1copied T1 copied, $flaircopied FLAIR copied and $roicopied ROI copied."

#!/bin/bash

#===== Config =====#
RENAMED_DIR=''
MOVED_DIR=''
OUTPUT_DIR=''


#===== Setting the right directory =====#
cd "$RENAMED_DIR"


#===== Changing for separator from space to line break =====#
SAVEIFS=$IFS
IFS=$(echo -en '\n\b')


#===== Constants =====#
INDENT='    '
BULLET_POINT1='>'
BULLET_POINT2="$INDENT*"
CYAN="\033[36m"
RED="\033[31m"
BLUE="\033[34m"
PURPLE="\033[35m"
YELLOW="\033[33m"
GREEN="\033[32m"
NO_COLOR="\033[0m"


#===== Beginning program =====#
echo
echo -e $PURPLE"============= STARTING =============" $NO_COLOR
echo

# Verifying if the moved folder exists, if not, creating it
if [ ! -e "$MOVED_DIR" ]; then
	echo -e "$BULLET_POINT1$YELLOW The folder \"$MOVED_DIR\" doesn't exist, creating it !$NO_COLOR"
	echo
	mkdir "$MOVED_DIR"
fi

# Getting number of files
FILES=$(ls)
if [[ `echo -e "$FILES" | wc -w | tr -d " "` -eq 0 ]]; then
	NB_FILES=0
else
	NB_FILES=$(echo -e "$FILES" | wc -l | tr -d " ")
fi

echo -e "$BULLET_POINT1 $CYAN$NB_FILES file(s)$NO_COLOR to take care of"
echo -e

# Initialiazing useful variables
NB_PROBLEMS=0
i=0

# Moving the files
for FILE in $FILES; do
	let "i+=1"
	echo -e "$BULLET_POINT1 Taking care of $CYAN\"$FILE\"$NO_COLOR ($i/$NB_FILES)..."

	SEASON=$(echo "$FILE" | sed -e "s/ `echo "$FILE" | awk '{print $NF}'`//g")
	SERIE=$(echo "$SEASON" | sed -e "s/ `echo "$SEASON" | awk '{print $NF}'`//g")

	if [ ! -e "$OUTPUT_DIR/$SERIE" ]; then
		echo -e "$BULLET_POINT2$RED The folder "$YELLOW"\"$OUTPUT_DIR/$SERIE\"$RED doesn't exist, creating it !"$NO_COLOR

		mkdir "$OUTPUT_DIR/$SERIE"
	fi

	if [ ! -e "$OUTPUT_DIR/$SERIE/$SEASON" ]; then
		echo -e "$BULLET_POINT2$RED The folder "$YELLOW"\"$OUTPUT_DIR/$SERIE/$SEASON\"$RED doesn't exist, creating it !"$NO_COLOR

		mkdir "$OUTPUT_DIR/$SERIE/$SEASON"
	fi

	if [ -e "$OUTPUT_DIR/$SERIE/$SEASON/$FILE" ]; then
		echo -e "$BULLET_POINT2$RED The folder "$YELLOW"\"$OUTPUT_DIR/$SERIE/$SEASON/$FILE\"$RED already exists, continuing to the next video !"$NO_COLOR

		let "NB_PROBLEMS+=1"
		continue
	else
		echo -ne "$BULLET_POINT2 Moving $YELLOW\"$FILE\"$NO_COLOR to $YELLOW\"$OUTPUT_DIR/$SERIE/$SEASON\"$NO_COLOR..."

		cp -R "$FILE" "$OUTPUT_DIR/$SERIE/$SEASON"

		echo -e $GREEN" done !"$NO_COLOR

		if [ ! -e "$MOVED_DIR/$FILE" ]; then
			# echo -e "$BULLET_POINT2 Moving $YELLOW\"$FILE\"$NO_COLOR to the moved folder"

			mv "$FILE" "$MOVED_DIR"
		else
			echo -e "$BULLET_POINT2$RED The folder $YELLOW\"$MOVED_DIR/$FILE\"$RED already exists, leaving $YELLOW\"$FILE\"$RED where it is"$NO_COLOR

			let "NB_PROBLEMS+=1"
		fi
	fi
done

echo
echo -e "$BULLET_POINT1 $GREEN$(($NB_FILES-$NB_PROBLEMS)) file(s)"$NO_COLOR" moved, $RED$NB_PROBLEMS problem(s)" $NO_COLOR

echo
echo -e $PURPLE"================ DONE ================" $NO_COLOR
echo

#Restoring default for separator
IFS=$SAVEIFS

exit 0

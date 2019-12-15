#!/bin/bash


#===== Config =====#
SEEN_DIR=''
RENAMED_DIR=''


#===== Setting the right directory =====#
cd "$SEEN_DIR"


#===== Changing separator from space to line break =====#
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


#===== Declaring TV series =====#
declare -a SERIES=(
	''
);


#===== Functions =====#
function get_series_name {
	i=0
	for SERIE in ${SERIES[@]}; do
		SERIE_GREP=$(echo -e "$SERIE" | sed "s/\./\\\./g" | sed "s/ /.*/g")
		if [[ `echo -e "$1" | grep -i "$SERIE_GREP" | wc -l` -eq 1 ]]; then
			return $i
		fi
		let "i+=1"
	done
	return 255
}


#===== Beginning program =====#
echo
echo -e $PURPLE"============= STARTING =============" $NO_COLOR
echo

# Verifying if the renamed folder exists, if not, creating it
if [ ! -e $RENAMED_DIR ]; then
	echo -e "$BULLET_POINT1$YELLOW The folder \"$RENAMED_DIR\" doesn't exist, creating it !$NO_COLOR"
	echo
	mkdir "$RENAMED_DIR"
fi

# Getting number of videos
VIDEOS=$(ls | grep -Ewi "mkv$|mp4$|m4v$")
if [[ `echo -e "$VIDEOS" | wc -w | tr -d " "` -eq 0 ]]; then
	NB_VIDEOS=0
else
	NB_VIDEOS=$(echo -e "$VIDEOS" | wc -l | tr -d " ")
fi

echo -e "$BULLET_POINT1 $CYAN$NB_VIDEOS video(s)$NO_COLOR to take care of"
echo -e

# Initialiazing useful variables
NB_PROBLEMS=0

# Taking care of the videos
for VIDEO in $VIDEOS; do
	echo -e "$BULLET_POINT1 Taking care of $CYAN\"$VIDEO\"$NO_COLOR..."

	get_series_name "$VIDEO"
	SERIE=$?
	if [[ $SERIE -eq 255 ]]; then
		echo -e "$BULLET_POINT2$RED Series name not found, continuing to the next video !" $NO_COLOR

		let "NB_PROBLEMS+=1"
		continue
	# else
	# 	echo -e "$BULLET_POINT2 Series name: ${SERIES[$SERIE]}"
	fi

	SEASON=$(echo -e "$VIDEO" | grep -io "S[0-9][0-9]" | grep -o "[0-9][0-9]") # Getting the season number
	if [[ "$SEASON" = "" ]]; then
		echo -e "$BULLET_POINT2$RED Series season not found, continuing to the next video !" $NO_COLOR

		let "NB_PROBLEMS+=1"
		continue
	# else
	# 	echo -e "$BULLET_POINT2 Series season: $SEASON"
	fi

	EPISODE=$(echo -e "$VIDEO" | grep -io "E[0-9][0-9]" | grep -o "[0-9][0-9]") # Getting the episode number
	if [[ "$EPISODE" = "" ]]; then
		echo -e "$BULLET_POINT2$RED Series episode not found, continuing to the next video !" $NO_COLOR

		let "NB_PROBLEMS+=1"
		continue
	# else
	# 	echo -e "$BULLET_POINT2 Series episode: $EPISODE"
	fi

	NEW_NAME="${SERIES[$SERIE]} S$SEASON E$EPISODE"

	# Looking for subtitles
	SERIE_GREP=$(echo -e "${SERIES[$SERIE]}" | sed "s/\./\\\./g" | sed "s/ /.*/g")
	SUBTITLES=$(ls | grep -i "$SERIE_GREP.*$SEASON.*$EPISODE.*srt")
	if [[ `echo -e "$SUBTITLES" | wc -w | tr -d " "` -eq 0 ]]; then
		NB_SUBTITLES=0
		# echo -e "$BULLET_POINT2$YELLOW $NB_SUBTITLES subtitle found" $NO_COLOR
	else
		NB_SUBTITLES=$(echo -e "$SUBTITLES" | wc -l | tr -d " ")
		echo -e "$BULLET_POINT2$GREEN $NB_SUBTITLES subtitle(s) found" $NO_COLOR
	fi

	# Creating the new folder
	if [ ! -e "$NEW_NAME" ]; then
		# echo -e "$BULLET_POINT2 Creating the folder $YELLOW\"$NEW_NAME\"$NO_COLOR"
		mkdir "$NEW_NAME"
	# else
	# 	echo -e "$BULLET_POINT2 The folder $YELLOW\"$NEW_NAME\"$NO_COLOR already exists"
	fi

	# Moving the video
	VIDEO_EXTENSION=$(echo -e "$VIDEO" | tr "." " " | awk '{print $NF}')
	FINAL_NAME="$NEW_NAME/$NEW_NAME.$VIDEO_EXTENSION"
	if [ ! -e "$FINAL_NAME" ]; then
		echo -e "$BULLET_POINT2$GREEN Moving the video into $YELLOW\"$NEW_NAME\"" $NO_COLOR
		mv "$VIDEO" "$FINAL_NAME"
	else
		echo -e "$BULLET_POINT2$RED The file $YELLOW\"$FINAL_NAME\"$RED already exists, continuing to the next video !" $NO_COLOR

		let "NB_PROBLEMS+=1"
		continue
	fi

	# Moving the subtitles
	i=1
	for SUBTITLE in $SUBTITLES; do
		SUBTITLE_EXTENSION=$(echo -e "$SUBTITLE" | tr "." " " | awk '{print $NF}')
		FINAL_NAME="$NEW_NAME/$NEW_NAME $i.$SUBTITLE_EXTENSION"
		if [ ! -e "$FINAL_NAME" ]; then
			echo -e "$BULLET_POINT2$GREEN Moving the subtitle n°$i into $YELLOW\"$NEW_NAME\"" $NO_COLOR
			mv "$SUBTITLE" "$FINAL_NAME"
		else
			echo -e "$BULLET_POINT2$GREEN The file $YELLOW\"$FINAL_NAME\"$RED already exists, continuing to the next video !" $NO_COLOR

			let "NB_PROBLEMS+=1"
			continue
		fi
		let "i+=1"
	done

	# Moving the new folder into the renamed folder
	if [ ! -e "$RENAMED_DIR/$NEW_NAME" ]; then
		# echo -e "$BULLET_POINT2$GREEN Moving the new folder into $CYAN\"$RENAMED_DIR\"" $NO_COLOR
		mv "$NEW_NAME" "$RENAMED_DIR/$NEW_NAME"
	else
		echo -e "$BULLET_POINT2$RED The folder $YELLOW\"$RENAMED_DIR/$NEW_NAME\"$RED already exists, continuing to the next video !" $NO_COLOR

		let "NB_PROBLEMS+=1"
		continue
	fi
done

echo

echo -e "$BULLET_POINT1 $GREEN$(($NB_VIDEOS-$NB_PROBLEMS)) video(s)"$NO_COLOR" renamed, $RED$NB_PROBLEMS problem(s)" $NO_COLOR

echo
echo -e $PURPLE"================ DONE ================" $NO_COLOR
echo

#Restoring default for separator
IFS=$SAVEIFS

exit 0

#! /bin/bash

# Config
SCRIPT_PATH="`dirname \"$0\"`"
CONFIG_FILE="$SCRIPT_PATH/photos_backup.config"
PHOTOS_DIR="`cat "$CONFIG_FILE" | grep "PHOTOS_DIR" | cut -d "=" -f 2`"
declare -a TARGETS="`cat "$CONFIG_FILE" | grep "TARGETS" | cut -d "=" -f 2`"

# Setting the right directory
cd "$PHOTOS_DIR"

# Changing separator from space to comma
SAVEIFS=$IFS
IFS=$(echo -en ',')

# Constants
CYAN="\033[36m"
RED="\033[31m"
BLUE="\033[34m"
PURPLE="\033[35m"
YELLOW="\033[33m"
GREEN="\033[32m"
NO_COLOR="\033[0m"

for TARGET in $TARGETS; do
	if [ ! -d "$TARGET" ]
	then
		echo -e $RED"$TARGET is not plugged!"$NO_COLOR
	else
		declare -a FOLDERS=$(ls -d */)

		# Changing separator from space to line break
		IFS=$(echo -en '\n\b')

		# Syncing
		for FOLDER in $FOLDERS; do
			echo -e $CYAN"Backing up '$FOLDER'..."$NO_COLOR
			rsync -avh --progress --delete --exclude=".DS_Store" --exclude=".Spotlight-V100" "$PHOTOS_DIR/$FOLDER" "$TARGET/$FOLDER"
			echo -e $GREEN"Done!"$NO_COLOR
			echo -e
		done
	fi
done

# Restoring default separator
IFS=$SAVEIFS

exit 0

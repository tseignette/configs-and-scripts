#! /bin/bash

# Config
PHOTOS_DIR=''
BACKUP_DIR=''

# Constants
CYAN="\033[36m"
RED="\033[31m"
BLUE="\033[34m"
PURPLE="\033[35m"
YELLOW="\033[33m"
GREEN="\033[32m"
NO_COLOR="\033[0m"

# Checking if HDD are plugged
if [ ! -d "$PHOTOS_DIR" ]
then
	echo -e $RED"HDD is not plugged!"$NO_COLOR
	exit 1
fi

if [ ! -d "$BACKUP_DIR" ]
then
	echo -e $RED"Backup HDD is not plugged!"$NO_COLOR
	exit 1
fi

function sync_folder {
	# Syncing
	echo -e $CYAN"Backing up '$1'..."$NO_COLOR
	rsync -avh --progress --delete --exclude=".DS_Store" "$PHOTOS_DIR/$1" "$BACKUP_DIR"
	echo -e $GREEN"Done!"$NO_COLOR
	echo -e
}

# Backing up
# e.g. sync_folder "subfolder of $PHOTOS_DIR"

exit 0

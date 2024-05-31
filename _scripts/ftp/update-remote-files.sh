#!/bin/bash
set -e
source "`dirname $0`/common.sh"
#=================================================
# SYNOPSYS
#=================================================
# This script is used to mirror local to remote using lftp.
#
# usage: ./update-remote-files.sh [dry-run]
#=================================================

# Validate the protocol
echo "Is it FTP or SFTP? (1: ftp, 2: sftp)"
read protocol
if [ "$protocol" == "1" ]; then
  REMOTE_HOST="ftp://$REMOTE_HOST"
elif [ "$protocol" == "2" ]; then
  REMOTE_HOST="sftp://$REMOTE_HOST"
else
  echo -e "\033[31mError: Invalid protocol. Please specify 'ftp' or 'sftp'.\033[0m"
  exit 1
fi

# Check if we wanna verify the certificate or not, default to no
echo "Wanna verify the certificate? (yY/nN)"
read verify_cert
if [[ "$verify_cert" == "y" || "$verify_cert" == "Y" ]]; then
  verify_cert="yes"
else
  verify_cert="no"
fi

# Validate the argument dry-run
if [[ "$1" != "" && "$1" != "dry-run" ]]; then
  echo -e "\033[31mError: Invalid third argument. Please specify 'dry-run'.\033[0m"
  exit 1
fi

# Check if the lengths of LOCAL_DIRS and REMOTE_DIRS are the same
if [ "${#LOCAL_DIRS[@]}" -ne "${#REMOTE_DIRS[@]}" ]; then
  echo -e "\033[31mError: LOCAL_DIRS and REMOTE_DIRS arrays are not of equal length.\033[0m"
  exit 1
fi

# Build the project
if [ "$BUILD_PATH" != "" ]; then
  yarn --cwd $BUILD_PATH build
fi

# Iterate over each directory pair
for index in "${!LOCAL_DIRS[@]}"; do

  # Remove preceding and trailing slashes
  LOCAL_DIR="${LOCAL_DIRS[$index]#/}"
  LOCAL_DIR="${LOCAL_DIR%/}"
  REMOTE_DIR="${REMOTE_DIRS[$index]#/}"
  REMOTE_DIR="${REMOTE_DIR%/}"

  # Add preceding and trailing slashes
  LOCAL_DIR="/$LOCAL_DIR/"
  REMOTE_DIR="/$REMOTE_DIR/"

  # Ask to continue
  echo "Updating from local path:$LOCAL_DIR to remote path:$REMOTE_DIR ..."
  echo "Continue? (yY/nN)"
  read continue
  if [[ "$continue" != "y" && "$continue" != "Y" ]]; then
    echo "Skipping..."
    continue
  fi

  # Mirror the directories
  if [ "$1" == "dry-run" ]; then
    echo "Dry run mode is enabled"
    lftp -u "$REMOTE_USER,$REMOTE_PASS" -p $REMOTE_PORT $REMOTE_HOST -e "set ssl:verify-certificate $verify_cert sftp:auto-confirm yes; mirror --dry-run -R --delete --only-newer --exclude='$EXCLUDE_FILES' $LOCAL_DIR $REMOTE_DIR; quit" > $DRY_RUN_LOG_PATH
  else
    echo "Dry run mode is disabled"
    lftp -u "$REMOTE_USER,$REMOTE_PASS" -p $REMOTE_PORT $REMOTE_HOST -e "set ssl:verify-certificate $verify_cert sftp:auto-confirm yes; mirror -R --delete --only-newer --exclude='$EXCLUDE_FILES' $LOCAL_DIR $REMOTE_DIR; quit"
  fi

done
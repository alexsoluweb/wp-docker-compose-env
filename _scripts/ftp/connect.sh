#!/bin/bash
set -e
source "`dirname $0`/common.sh"

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

# Test the connection
lftp -e "set ssl:verify-certificate $verify_cert sftp:auto-confirm yes" -p $REMOTE_PORT -u "$REMOTE_USER,$REMOTE_PASS" $REMOTE_HOST
exit 0
#!/usr/bin/env bash
set -e
source "$(dirname $0)/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# Connect to the remote server.
# Usage: ./test-connection.sh
#================================================================

INFO "Begin connection..."
if [ -n "$REMOTE_PASS" ]; then
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST
else
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST
fi

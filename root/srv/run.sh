#! /bin/sh
#
# Start SRT Live Server instance
#
# Author:       Thomas Bendler <code@thbe.org>
# Date:         Sat Nov 28 23:40:19 UTC 2020
#
# Release:      v1.0
#
# Prerequisite: This release needs a shell which could handle functions.
#               If shell is not able to handle functions, remove the
#               error section.
#
# ChangeLog:    v1.0 - Initial release
#

### Enable debug if debug flag is true ###
if [ -n "${SLS_ENV_DEBUG}" ]; then
  set -ex
fi

### Error handling ###
error_handling() {
  if [ "${RETURN}" -eq 0 ]; then
    echo "${SCRIPT} successfull!"
  else
    echo "${SCRIPT} aborted, reason: ${REASON}"
  fi
  exit "${RETURN}"
}
trap "error_handling" EXIT HUP INT QUIT TERM
RETURN=0
REASON="Finished!"

### Default values ###
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export LC_ALL=C
export LANG=C
SCRIPT=$(basename ${0})

### SLS parameter ###
export SLS_BIN=/srv/sls/bin/sls
export SLS_CONF=/srv/sls/etc/sls.conf
export SLS_LIB=/srv/sls/lib64

### Display SLS connection parameter ###
cat <<EOF

===========================================================

The dockerized SRT Live Server instance is now ready for use!

Binary:               ${SLS_BIN}
Configuration:        ${SLS_CONF}
Libraries:            ${SLS_LIB}

===========================================================

EOF

### Start the SLS instance ###
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${SLS_LIB}
${SLS_BIN} -c ${SLS_CONF}

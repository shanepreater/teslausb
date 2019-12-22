#!/bin/bash -eu

VERS_OPT=
SEC_OPT=

function log_progress () {
  if typeset -f setup_progress > /dev/null; then
    setup_progress "verify-and-configure-archive: $@"
  fi
  echo "verify-and-configure-archive: $1"
}

function check_archive_server_reachable () {
  log_progress "Verifying that the archive server $archiveserver is reachable..."
  local serverunreachable=false
  hping3 -c 1 -S -p 445 "$archiveserver" 1>/dev/null 2>&1 || serverunreachable=true

  if [ "$serverunreachable" = true ]
  then
    log_progress "STOP: The archive server $archiveserver is unreachable. Try specifying its IP address instead."
    exit 1
  fi

  log_progress "The archive server is reachable."
}

function install_required_packages () {
  log_progress "Installing/updating required packages if needed"
  apt-get -y --force-yes install hping3
  pushd /root/bin/ > /dev/null
  curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o dropbox_uploader.sh
  popd > /dev/null
  log_progress "Done"
}

install_required_packages

check_archive_server_reachable

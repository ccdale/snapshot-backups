#!/bin/bash

function msg()
{
  dt=$(date|cut -d" " -f1-4)
  echo "$dt $@"
}
function moveDirsUp()
{
  when=$1
  stub=snapshots/$when
  srcn=$(( maxnum - 1 ))
  destn=$maxnum
  nsrc=${stub}.${srcn}
  ndest=${stub}.${destn}
  if [[ "$when" = "hourly" ]]; then
    fstop=0
  else
    fstop=-1
  fi
  if $RNET ls ${ndest} >/dev/null 2>&1; then
    msg "removing ${ndest}"
    $RNET rm -rf ${ndest}
  fi
  while [[ $srcn -gt $fstop ]]; do
    if $RNET ls ${nsrc} >/dev/null 2>&1; then
      msg "moving ${nsrc} -> ${ndest}"
      $RNET mv ${nsrc} ${ndest}
    fi
    destn=$srcn
    srcn=$(( srcn - 1 ))
    nsrc=${stub}.${srcn}
    ndest=${stub}.${destn}
  done
  nsrc=snapshots/hourly.0
  case $when in
    hourly) ndest=snapshots/hourly.1;;
    *) ndest=snapshots/${when}.0;;
  esac
  msg "Copying ${nsrc} to ${ndest}"
  $RNET cp -al ${nsrc} ${ndest}
}

ME=${0##*/}
maxnum=6
xtype=hourly
RNET="ssh rnet"
excludefn=${HOME}/.rnet-exclude

while getopts "e:hn:t:" opt; do
  case $opt in
    e) excludefn=$OPTARG;;
    h) echo "$ME [ehtn]
      Snapshot style backups to rsync.net
      requires that the key 'rnet' is set in .ssh/config

      Options:
        -e path to exclude file (default: ${HOME}/.rnet-exclude)
        -h this help
        -n number of backups to keep (default: 6)
        -t type of backup, one of hourly, daily, weekly, monthly (default: hourly)
        "
        exit 0;;
    n) maxnum=$OPTARG;;
    t) xtype=$OPTARG;;
  esac
done
shift $((OPTIND-1))

msg "$xtype backup starting"
rsyncexc="--exclude-from $excludefn --delete-excluded"
rsyncopts="-ave ssh"

dest=rnet:snapshots/${xtype}.0
src=${HOME}/

moveDirsUp ${xtype}

if [[ "$xtype" == "hourly" ]]; then
  msg "starting rsync: $src $dest"
  rsync $rsyncopts $rsyncexc $src $dest
fi

msg "$xtype backup completed"

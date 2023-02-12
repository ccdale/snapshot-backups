#!/bin/bash

function msg()
{
  dt=$(date|cut -d" " -f1-4)
  echo "$dt $@"
}
function moveDirsUp()
{
  when=$1
  stub=${broot}/$when
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
  nsrc=${broot}/hourly.0
  case $when in
    hourly) ndest=${broot}/${when}.1;;
    *) ndest=${broot}/${when}.0;;
  esac
  msg "Copying ${nsrc} to ${ndest}"
  $RNET cp -al ${nsrc} ${ndest}
}

ME=${0##*/}
ME=${ME%%.sh}

cfgfn=${HOME}/.config/${ME}.cfg
if [ ! -r $cfgfn ]; then
    echo "Cannot find config file $cfgfn"
    exit 1
fi

source $cfgfn

# maxnum=6
# xtype=hourly
# RNET="ssh rnet"
# excludefn=${HOME}/.rnet-exclude

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

msg "$ME $xtype backup starting"
msg "exlude from file $excludefn"
msg "$maxnum backups to keep"

rsyncexc="--exclude-from $excludefn --delete-excluded"
rsyncopts="-ave ssh"

# broot=seagate4/snapshots/$(hostname)/$USER
# dest=rnet:${broot}/${xtype}.0
# src=${HOME}/

moveDirsUp ${xtype}

if [[ "$xtype" == "hourly" ]]; then
  msg "starting rsync: $src $dest"
  rsync $rsyncopts $rsyncexc $src $dest
fi

msg "$xtype backup completed"

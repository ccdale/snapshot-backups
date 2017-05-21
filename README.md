# snapshot-backups
Snapshot style backups to rsync.net

Based on Mike Rubel's excellent work [Easy Automated Snapshot-Style Backups
with Linux and Rsync](http://www.mikerubel.org/computers/rsync_snapshots/)
this script uses rsync to backup to [rsync.net](rsync.net).

The script is designed to be run from cron.  The output should be sent to
$HOME/logs/snapshot-backups.log 

```
PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
1 0 1 * * $HOME/bin/snapshot-backups.sh -n 12 -t monthly >>$HOME/logs/snapshot-backups.log 2>&1
11 0 * * 0 $HOME/bin/snapshot-backups.sh -n 4 -t weekly >>$HOME/logs/snapshot-backups.log 2>&1
21 0 * * * $HOME/bin/snapshot-backups.sh -n 7 -t daily >>$HOME/logs/snapshot-backups.log 2>&1
36 0,9,12,15,18,21 * * * $HOME/bin/snapshot-backups.sh -n 6 -t hourly >>$HOME/logs/snapshot-backups.log 2>&1
```
## Options
The script can take 3 optional options.

```

snapshot-backups.sh [ehtn]
      Snapshot style backups to rsync.net
      requires that the key 'rnet' is set in .ssh/config

      Options:
        -e path to exclude file (default: $HOME/.rnet-exclude)
        -h this help
        -n number of backups to keep (default: 6)
        -t type of backup, one of hourly, daily, weekly, monthly (default: hourly)
        
```

## Setting it up
* Create an ssh config entry for your rsync.net account calling it 'rnet'.
* Create a directory in your rsync.net account called 'snapshots'.
* Copy this script into your home bin directory.
* Create a logs directory in your home directory.
* Copy the logrotate file to /etc/logrotate.d/snapshot-backups, chown
  root:root.


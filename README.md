# snapshot-backups
Snapshot style backups to rsync.net

Based on Mike Rubel's excellent work [Easy Automated Snapshot-Style Backups
with Linux and Rsync](http://www.mikerubel.org/computers/rsync_snapshots/)
this script uses rsync to backup to [rsync.net](rsync.net) (or any other
SSH-able destination.

The script is designed to be run from cron.  The output will be sent to
$HOME/logs/snapshot-backups.log

```
mkdir -p $HOME/logs
```

There are some variables that are set from your machine in the config file.

```
cp snapshot-backups.cfg snapshot-backups.logrotate $HOME/.config/
```

Create an SSH configuration called `rnet` that uses a public/private key pair
to connect to the destination.

Ensure the destination snapshot directory exists

```
source $HOME/.config/snapshot-backups.cfg
$RNET mkdir -p $broot
```

crontab

```
PATH=/home/centrica/bin:/home/centrica/src/opsbag/.bin:/home/centrica/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/var/lib/snapd/snap/bin
36 10 1 * * $HOME/bin/snapshot-backups.sh -n 12 -t monthly >>$HOME/logs/snapshot-backups.log 2>&1
48 10 * * 0 $HOME/bin/snapshot-backups.sh -n 4 -t weekly >>$HOME/logs/snapshot-backups.log 2>&1
57 10 * * * $HOME/bin/snapshot-backups.sh -n 7 -t daily >>$HOME/logs/snapshot-backups.log 2>&1
5 8-18 * * * $HOME/bin/snapshot-backups.sh -n 12 -t hourly >>$HOME/logs/snapshot-backups.log 2>&1
2 2 * * * /usr/bin/logrotate $HOME/.config/snapshot-backups.logrotate
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
* Ensure you have an SSH config for the destination called `rnet`
* Ensure the destination snapshot directory exists
* Copy this script into your home bin directory `ln -s
  $(pwd)/snapshot-backups.sh $HOME/bin/`
* Copy the cfg and logrotate files to your .config directory.
* Create a logs directory in your home directory.


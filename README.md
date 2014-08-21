Clean-fstab
===========

Small script to properly align /etc/fstab in a more readable manner.


Most fstab files look like the following:

```
/dev/VolGroup00/LogVol00 /                       ext3    defaults,usrquota        1 1
LABEL=/boot             /boot                   ext3    defaults        1 2
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
/dev/VolGroup00/LogVol01 swap                    swap    defaults        0 0
/usr/tmpDSK             /tmp                    ext3    defaults,noauto        0 0
/tmp             /var/tmp                    ext3    defaults,usrquota,bind,noauto        0 0
/dev/xvdb1              /home                   ext3    defaults        0 0
```

This is a mess, and makes it hard to read.  This script automatically adds spaces (or tabs) to the file to ensure data is properly aligned.

```
/dev/VolGroup00/LogVol00  /         ext3    defaults,usrquota              1 1
LABEL=/boot               /boot     ext3    defaults                       1 2
tmpfs                     /dev/shm  tmpfs   defaults                       0 0
devpts                    /dev/pts  devpts  gid=5,mode=620                 0 0
sysfs                     /sys      sysfs   defaults                       0 0
proc                      /proc     proc    defaults                       0 0
/dev/VolGroup00/LogVol01  swap      swap    defaults                       0 0
/usr/tmpDSK               /tmp      ext3    defaults,noauto                0 0
/tmp                      /var/tmp  ext3    defaults,usrquota,bind,noauto  0 0
/dev/xvdb1                /home     ext3    defaults                       0 0
```

Comments inbetween and at the end of entries will be automatically perserved and not formatted.

Usage
===========
```
/root/bin/cleanfstab [--tabs] [--display[-only]] [--write]

Description: Fixes the /etc/fstab file to properly align each column using spaces or tabs.
	The default action is to adjust the fstab using spaces and save it as /etc/fstab.new.

	--tabs
		Use tabs instead of spaces when aligning the columns

	--display
		Display the contents of the adjusted fstab file.
		If write is not supplied save the temporary file as /etc/fstab.new
		
	--display-only
		Display the contents of the adjusted fstab file.
		If write is not supplied, delete the temporary file.

	--write
		Move the current /etc/fstab to /etc/fstab.old and save the adjusted fstab as /etc/fstab
```

Quick automatic rewrite of /etc/fstab
===========
wget:
```
wget -q -O - https://raw.githubusercontent.com/JamesDooley/Clean-fstab/master/cleanfstab.sh --no-check-certificate  | bash /dev/stdin --write
```
curl:
```
curl -s https://raw.githubusercontent.com/JamesDooley/Clean-fstab/master/cleanfstab.sh | bash /dev/stdin --write
```

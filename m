From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: 2.6.28.9: EXT3/NFS inodes corruption
Date: Wed, 22 Apr 2009 14:24:24 -0700
Message-ID: <20090422142424.b4105f4c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Wed__22_Apr_2009_14_24_24_-0700_VAeI8SlL=iAj2OQE"
Cc: Sylvain Rochet <gradator@gradator.net>
To: linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-ext4-owner@vger.kernel.org>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.

--Multipart=_Wed__22_Apr_2009_14_24_24_-0700_VAeI8SlL=iAj2OQE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


Is it nfsd, or is it htree?


Begin forwarded message:

Date: Mon, 20 Apr 2009 18:20:18 +0200
From: Sylvain Rochet <gradator@gradator.net>
To: linux-kernel@vger.kernel.org
Subject: 2.6.28.9: EXT3/NFS inodes corruption


Hi,


We(TuxFamily) are having some inodes corruptions on a NFS server.


So, let's start with the facts.


==== NFS Server

Linux bazooka 2.6.28.9 #1 SMP Mon Mar 30 12:58:22 CEST 2009 x86_64 GNU/Linux

root@bazooka:/usr/src# grep EXT3 /boot/config-2.6.28.9 
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y

root@bazooka:/usr/src# grep NFS /boot/config-2.6.28.9 
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
# CONFIG_NFS_V4 is not set
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
# CONFIG_NFSD_V4 is not set
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y

  ==> We upgraded from 2.6.26.5 to 2.6.28.9, problem's still here


/dev/md10 on /data type ext3 (rw,noatime,nodiratime,grpquota,commit=5,data=ordered)

  ==> We used data=writeback, we fallback to data=ordered,
      problem's still here


# /etc/exports
/data                   *(rw,no_root_squash,async,no_subtree_check)
... and lots of exports of subdirs of /data, exported the same way


Process about NFS, on the NFS server.

root@bazooka:~# ps aux | grep -E '(nfsd]|lockd]|statd|mountd|idmapd|rquotad|portmap)$'
daemon    1226  0.0  0.0   4824   452 ?        Ss   Apr11   0:06 /sbin/portmap
root      1703  0.0  0.0      0     0 ?        S<   01:29   0:09 [lockd]
root      1704  0.3  0.0      0     0 ?        D<   01:29   3:29 [nfsd]
root      1705  0.3  0.0      0     0 ?        S<   01:29   3:34 [nfsd]
root      1706  0.3  0.0      0     0 ?        S<   01:29   3:32 [nfsd]
root      1707  0.3  0.0      0     0 ?        S<   01:29   3:30 [nfsd]
root      1708  0.3  0.0      0     0 ?        D<   01:29   3:43 [nfsd]
root      1709  0.3  0.0      0     0 ?        D<   01:29   3:43 [nfsd]
root      1710  0.3  0.0      0     0 ?        D<   01:29   3:39 [nfsd]
root      1711  0.3  0.0      0     0 ?        D<   01:29   3:42 [nfsd]
root      1715  0.0  0.0   5980   576 ?        Ss   01:29   0:00 /usr/sbin/rpc.mountd
statd     1770  0.0  0.0   8072   648 ?        Ss   Apr11   0:00 /sbin/rpc.statd
root      1776  0.0  0.0  23180   536 ?        Ss   Apr11   0:00 /usr/sbin/rpc.idmapd
root      1785  0.0  0.0   6148   552 ?        Ss   Apr11   0:00 /usr/sbin/rpc.rquotad

  ==> We used to run tenths of nfsd daemons, we fallback to 8,
      the default, problem's still here
  ==> There are some 'D' processes because of a running data-check


Block device health:

Apr  3 00:28:20 bazooka kernel: md: data-check of RAID array md10
Apr  3 05:11:59 bazooka kernel: md: md10: data-check done.

Apr  5 01:06:01 bazooka kernel: md: data-check of RAID array md10
Apr  5 05:49:42 bazooka kernel: md: md10: data-check done.

Apr 20 16:27:33 bazooka kernel: md: data-check of RAID array md10

md10 : active raid6 sda[0] sdl[11] sdk[10] sdj[9] sdi[8] sdh[7] sdg[6] sdf[5] sde[4] sdd[3] sdc[2] sdb[1]
      1433738880 blocks level 6, 64k chunk, algorithm 2 [12/12] [UUUUUUUUUUUU]
      [======>..............]  check = 30.1% (43176832/143373888) finish=208.1min speed=8020K/sec

  ==> Everything seems fine


# df -m
/dev/md10              1378166     87170   1290997   7% /data

# df -i
/dev/md10            179224576 3454822 175769754    2% /data



==== NFS Clients

6x Linux cognac 2.6.28.9-grsec #1 SMP Sun Apr 12 13:06:49 CEST 2009 i686 GNU/Linux
5x Linux martini 2.6.28.9-grsec #1 SMP Tue Apr 14 00:01:30 UTC 2009 i686 GNU/Linux
2x Linux armagnac 2.6.28.9 #1 SMP Tue Apr 14 08:59:12 CEST 2009 i686 GNU/Linux

grad@armagnac:~$ grep NFS /boot/config-2.6.28.9 
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
# CONFIG_NFS_V4 is not set
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
# CONFIG_NFSD_V4 is not set
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y

  ==> We upgraded from 2.6.23.16 and 2.6.24.2 (yeah, vmsplice upgrade 
;-) to 2.6.28.9, problem's still here


x.x.x.x:/data/... on /data/... type nfs (rw,noexec,nosuid,nodev,async,hard,nfsvers=3,udp,intr,rsize=32768,wsize=32768,timeo=20,addr=x.x.x.x)

  ==> All NFS exports are mounted this way, sometimes with the 'sync' 
      option, like web sessions.
  ==> Those are often mounted from outside of chroots into chroots, 
      useless detail I think


Process about NFS, on the NFS clients.

root@cognac:~# ps aux | grep -E '(nfsd]|lockd]|statd|mountd|idmapd|rquotad|portmap)$'
daemon     349  0.0  0.0   1904   536 ?        Ss   Apr12   0:00 /sbin/portmap
statd      360  0.0  0.1   3452  1152 ?        Ss   Apr12   0:00 /sbin/rpc.statd
root      1190  0.0  0.0      0     0 ?        S<   Apr12   0:00 [lockd]



==== So, now, going into the problem

The kernel log is not really nice with us, here on the NFS Server:

Mar 22 06:47:14 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Unrecognised inode hash code 52
Mar 22 06:47:14 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Corrupt dir inode 40420228, running e2fsck is recommended.
Mar 22 06:47:16 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Unrecognised inode hash code 52
Mar 22 06:47:16 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Corrupt dir inode 40420228, running e2fsck is recommended.
Mar 22 06:47:19 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Unrecognised inode hash code 52
Mar 22 06:47:19 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Corrupt dir inode 40420228, running e2fsck is recommended.
Mar 22 06:47:19 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Unrecognised inode hash code 52
Mar 22 06:47:19 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Corrupt dir inode 40420228, running e2fsck is recommended.
Mar 22 06:47:19 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Unrecognised inode hash code 52
And so on...

And more recently...
Apr  2 22:19:01 bazooka kernel: EXT3-fs warning (device md10): ext3_unlink: Deleting nonexistent file (40780223), 0
Apr  2 22:19:02 bazooka kernel: EXT3-fs warning (device md10): ext3_unlink: Deleting nonexistent file (40491685), 0
Apr 11 07:23:02 bazooka kernel: EXT3-fs warning (device md10): ext3_unlink: Deleting nonexistent file (174301379), 0
Apr 20 08:13:32 bazooka kernel: EXT3-fs warning (device md10): ext3_unlink: Deleting nonexistent file (54942021), 0


Not much stuff in the kernel log of NFS clients, history is quite lost, 
but we got some of them:

....................: NFS: Buggy server - nlink == 0!


== Going deeper into the problem

Something like that is quite common:

root@bazooka:/data/...# ls -la
total xxx
drwxrwx--- 2 xx    xx        4096 2009-04-20 03:48 .
drwxr-xr-x 7 root  root      4096 2007-01-21 13:15 ..
-rw-r--r-- 1 root  root         0 2009-04-20 03:48 access.log
-rw-r--r-- 1 root  root  70784145 2009-04-20 00:11 access.log.0
-rw-r--r-- 1 root  root   6347007 2009-04-10 00:07 access.log.10.gz
-rw-r--r-- 1 root  root   6866097 2009-04-09 00:08 access.log.11.gz
-rw-r--r-- 1 root  root   6410119 2009-04-08 00:07 access.log.12.gz
-rw-r--r-- 1 root  root   6488274 2009-04-07 00:08 access.log.13.gz
?--------- ?    ?     ?         ?                ? access.log.14.gz
?--------- ?    ?     ?         ?                ? access.log.15.gz
?--------- ?    ?     ?         ?                ? access.log.16.gz
?--------- ?    ?     ?         ?                ? access.log.17.gz
-rw-r--r-- 1 root  root   6950626 2009-04-02 00:07 access.log.18.gz
?--------- ?    ?     ?         ?                ? access.log.19.gz
-rw-r--r-- 1 root  root   6635884 2009-04-19 00:11 access.log.1.gz
?--------- ?    ?     ?         ?                ? access.log.20.gz
?--------- ?    ?     ?         ?                ? access.log.21.gz
?--------- ?    ?     ?         ?                ? access.log.22.gz
?--------- ?    ?     ?         ?                ? access.log.23.gz
?--------- ?    ?     ?         ?                ? access.log.24.gz
?--------- ?    ?     ?         ?                ? access.log.25.gz
?--------- ?    ?     ?         ?                ? access.log.26.gz
-rw-r--r-- 1 root  root   6616546 2009-03-24 00:07 access.log.27.gz
?--------- ?    ?     ?         ?                ? access.log.28.gz
?--------- ?    ?     ?         ?                ? access.log.29.gz
-rw-r--r-- 1 root  root   6671875 2009-04-18 00:12 access.log.2.gz
?--------- ?    ?     ?         ?                ? access.log.30.gz
-rw-r--r-- 1 root  root   6347518 2009-04-17 00:10 access.log.3.gz
-rw-r--r-- 1 root  root   6569714 2009-04-16 00:12 access.log.4.gz
-rw-r--r-- 1 root  root   7170750 2009-04-15 00:11 access.log.5.gz
-rw-r--r-- 1 root  root   6676518 2009-04-14 00:12 access.log.6.gz
-rw-r--r-- 1 root  root   6167458 2009-04-13 00:11 access.log.7.gz
-rw-r--r-- 1 root  root   5856576 2009-04-12 00:10 access.log.8.gz
-rw-r--r-- 1 root  root   6644142 2009-04-11 00:07 access.log.9.gz


root@bazooka:/data/...# cat *      # output filtered, only errors
cat: access.log.14.gz: Stale NFS file handle
cat: access.log.15.gz: Stale NFS file handle
cat: access.log.16.gz: Stale NFS file handle
cat: access.log.17.gz: Stale NFS file handle
cat: access.log.19.gz: Stale NFS file handle
cat: access.log.20.gz: Stale NFS file handle
cat: access.log.21.gz: Stale NFS file handle
cat: access.log.22.gz: Stale NFS file handle
cat: access.log.23.gz: Stale NFS file handle
cat: access.log.24.gz: Stale NFS file handle
cat: access.log.25.gz: Stale NFS file handle
cat: access.log.26.gz: Stale NFS file handle
cat: access.log.28.gz: Stale NFS file handle
cat: access.log.29.gz: Stale NFS file handle
cat: access.log.30.gz: Stale NFS file handle


"Stale NFS file handle"... on the NFS Server... hummm...


== Other facts

fsck.ext3 fixed the filesystem but didn't fix the problem.

mkfs.ext3 didn't fix the problem either.

It only concerns files which have been recently modified, logs, awstats 
hashfiles, websites caches, sessions, locks, and such.

It mainly happens to files which are created on the NFS server itself, 
but it's not a hard rule.

Keeping inodes into servers' cache seems to prevent the problem to happen.
( yeah, # while true ; do ionice -c3 find /data -size +0 > /dev/null ; done )


Hummm, it seems to concern files which are quite near to each others, 
let's check that:

Let's build up an inode "database"

# find /data -printf '%i %p\n' > /root/inodesnumbers


Let's check how inodes numbers are distributed:

# cat /root/inodesnumbers | perl -e 'use Data::Dumper; my @pof; while(<>){my ( $inode ) = ( $_ =~ /^(\d+)/ ); my $hop = int($inode/1000000); $pof[$hop]++; }; for (0 .. $#pof) { print $_." = ".($pof[$_]/10000)."%\n" }'
[... lot of quite unused inodes groups]
53 = 3.0371%
54 = 26.679%     <= mailboxes
55 = 2.7026%
[... lot of quite unused inodes groups]
58 = 1.3262%
59 = 27.3211%    <= mailing lists archives
60 = 5.5159%
[... lot of quite unused inodes groups]
171 = 0.0631%
172 = 0.1063%
173 = 27.2895%   <=
174 = 44.0623%   <=
175 = 45.6783%   <= websites files
176 = 45.8247%   <=
177 = 36.9376%   <=
178 = 6.3294%
179 = 0.0442%

Hummm, all the files are using the same inodes "groups".
  (groups of a million of inodes)

We use to fix broken folders by moving them to a quarantine folder and 
by restoring disappeared files from the backup.

So, let's check corrupted inodes number from the quarantine folder:

root@bazooka:/data/path/to/rep/of/quarantine/folders# find . -mindepth 1 -maxdepth 1 -printf '%i\n' | sort -n
174293418
174506030
174506056
174506073
174506081
174506733
174507694
174507708
174507888
174507985
174508077
174508083
176473056
176473062
176473064

Humm... those are quite near to each other 17450... 17647... and are of 
course in the most used inodes "groups"...


Open question: are NFS clients can steal inodes numbers from each others ?


I am not sure whether my bug report is good, feel free to ask questions ;)

Best regards,
Sylvain


--Multipart=_Wed__22_Apr_2009_14_24_24_-0700_VAeI8SlL=iAj2OQE
Content-Type: application/pgp-signature;
 name="signature.asc"
Content-Disposition: attachment;
 filename="signature.asc"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuNC42IChHTlUv
TGludXgpCgppRDhEQlFGSjdLREJERnViM3F0RXNTOFJBbW9qQUtDR0lUbWc4Z1BFVVVqWFhPS2Vq
WDU3b0drdGJBQ2ZkcE1EClpwUVZIYnVPM3hpUkNRNVZDNGNMdnBNPQo9V0VWTQotLS0tLUVORCBQ
R1AgU0lHTkFUVVJFLS0tLS0KCg==

--Multipart=_Wed__22_Apr_2009_14_24_24_-0700_VAeI8SlL=iAj2OQE--

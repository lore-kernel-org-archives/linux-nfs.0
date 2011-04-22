Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60548 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341Ab1DVCiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2011 22:38:00 -0400
Received: by bwz15 with SMTP id 15so223707bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2011 19:37:59 -0700 (PDT)
Date: Thu, 21 Apr 2011 21:37:59 -0500
Message-ID: <BANLkTimhNLcNMxd6DgA6rqpBU8=n_2cxPg@mail.gmail.com>
Subject: performance for large file count environment
From: Terry <td3201@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

First, I see this list is largely used for development dialog.  If
this isn't the right place for end user help, please direct me to a
better place.  There are a lot of articles out there about NFS
performance.  I have read a lot of them and still have questions about
how to tune NFS given my environment.  I have some tuning to do
through the SAN as well but need to ensure my NFS layer is tuned
appropriately.  My environment consists of:

-3 NFS servers (Centos - active/active/active)
-3 NFS clients  (RHEL5)
-5 ext3 volumes  (4T, 4T, 4T, 6T, and 6T)  -  I will be splitting
these up into 2T volumes as time permits to achieve a higher head
count ratio due to the way the SAN splits up volumes.
-60 million files
-MTU 9000 across all clients/servers
-2 slave bond nics on clients (may move this to 3)
-3 slave bond nics on servers


The I/O looks like this during peak times:
840          - IOPS
18.54 KB  - Avg. I/O Size
85%         - Reads

Here's a dump of nfsstats from one of the clients (i think the retrans
are from me failing volumes to/from cluster nodes):
Client rpc stats:
calls      retrans    authrefrsh
106981459   19         0

Client nfs v3:
null         getattr      setattr      lookup       access       readlink
0         0% 11065979 10% 43708     0% 11220182 10% 5746076   5% 0         0%
read         write        create       mkdir        symlink      mknod
69328935 64% 8464646   7% 105054    0% 3573      0% 0         0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
89994     0% 227       0% 52230     0% 0         0% 344309    0% 477567    0%
fsstat       fsinfo       pathconf     commit
1464      0% 12        0% 0         0% 37496     0%

I am mounting the NFS volumes like this:
[root@omadvdss01c ~]# cat /proc/mounts  | grep dv
omadvnfs01-nfs-a:/data01a /data01a nfs
rw,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=omadvnfs01-nfs-a
0 0

I am mounting the ext3 volumes on the servers like this (see bottom of
email for a tune2fs dump):
[root@omadvnfs01a ~]# cat /proc/mounts | grep data01
/dev/vg_data01b/lv_data01b /data01b ext3
rw,noatime,nodiratime,data=writeback 0 0

I have considered changing the mount option to data=journal given my
high read %.  Also, I don't see it in /proc/mounts but I am mounting
all ext3 volumes with commit=30.  Considering increasing that too but
not sure yet.


Can anyone see any major gotchas with regard to how I am using NFS as
it relates to my environment?  I need to achieve as fast reads as
possible, even if it affects writes.



[root@omadvnfs01a ~]# tune2fs -l /dev/mapper/vg_data01b-lv_data01b
tune2fs 1.39 (29-May-2006)
Filesystem volume name:   <none>
Last mounted on:          <not available>
Filesystem UUID:          11795964-faa8-40a2-bc00-b923a2de0935
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal ext_attr resize_inode dir_index
filetype needs_recovery sparse_super large_file
Default mount options:    (none)
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              536870912
Block count:              1073735680
Reserved block count:     10737356
Free blocks:              158495792
Free inodes:              528861221
First block:              0
Block size:               4096
Fragment size:            4096
Reserved GDT blocks:      768
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         16384
Inode blocks per group:   512
Filesystem created:       Tue Jul  1 09:53:21 2008
Last mount time:          Wed Apr 20 21:35:41 2011
Last write time:          Wed Apr 20 21:35:41 2011
Mount count:              138
Maximum mount count:      -1
Last checked:             Tue Jul  1 09:53:21 2008
Check interval:           0 (<none>)
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               128
Journal inode:            8
Default directory hash:   tea
Directory Hash Seed:      51d6249c-8deb-47dd-936d-80c49e3beeed
Journal backup:           inode blocks

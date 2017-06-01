Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751125AbdFATki (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Jun 2017 15:40:38 -0400
Date: Thu, 1 Jun 2017 15:40:36 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [PATCH] security/selinux: allow security_sb_clone_mnt_opts to
 enable/disable native labeling behavior
Message-ID: <20170601194036.mjgqvj3an5hc4euf@tonberry.usersys.redhat.com>
References: <1495813358.4586.1.camel@tycho.nsa.gov>
 <20170601144628.26535-1-smayhew@redhat.com>
 <20170601145508.crubttulnnfm2hd5@tonberry.usersys.redhat.com>
 <1496340481.27759.12.camel@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1496340481.27759.12.camel@tycho.nsa.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 01 Jun 2017, Stephen Smalley wrote:

> On Thu, 2017-06-01 at 10:55 -0400, Scott Mayhew wrote:
> > On Thu, 01 Jun 2017, Scott Mayhew wrote:
> > 
> > > When an NFSv4 client performs a mount operation, it first mounts
> > > the
> > > NFSv4 root and then does path walk to the exported path and
> > > performs a
> > > submount on that, cloning the security mount options from the
> > > root's
> > > superblock to the submount's superblock in the process.
> > > 
> > > Unless the NFS server has an explicit fsid=0 export with the
> > > "security_label" option, the NFSv4 root superblock will not have
> > > SBLABEL_MNT set, and neither will the submount superblock after
> > > cloning
> > > the security mount options.  As a result, setxattr's of security
> > > labels
> > > over NFSv4.2 will fail.  In a similar fashion, NFSv4.2 mounts
> > > mounted
> > > with the context= mount option will not show the correct labels
> > > because
> > > the nfs_server->caps flags of the cloned superblock will still have
> > > NFS_CAP_SECURITY_LABEL set.
> > > 
> > > Allowing the NFSv4 client to enable or disable
> > > SECURITY_LSM_NATIVE_LABELS
> > > behavior will ensure that the SBLABEL_MNT flag has the correct
> > > value
> > > when the client traverses from an exported path without the
> > > "security_label" option to one with the "security_label" option and
> > > vice versa.  Similarly, checking to see if
> > > SECURITY_LSM_NATIVE_LABELS is
> > > set upon return from security_sb_clone_mnt_opts() and clearing
> > > NFS_CAP_SECURITY_LABEL if necessary will allow the correct labels
> > > to
> > > be displayed for NFSv4.2 mounts mounted with the context= mount
> > > option.
> > > 
> > > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > > ---
> > >  fs/nfs/super.c            | 18 +++++++++++++++++-
> > >  include/linux/lsm_hooks.h |  4 +++-
> > >  include/linux/security.h  |  8 ++++++--
> > >  security/security.c       |  7 +++++--
> > >  security/selinux/hooks.c  | 43
> > > ++++++++++++++++++++++++++++++++++++++-----
> > >  5 files changed, 69 insertions(+), 11 deletions(-)
> > 
> > With this patch, the behavior and flags fields of the
> > superblock_security_struct
> > and the nfs_server->caps all have the correct values when crossing
> > from an
> > export without the "security_label" option to one with the
> > "security_label"
> > option and vice versa.
> > 
> > Here /export/export1 and /export/export1/export2/export3 have the
> > "security_label" option; /export and /export/export1/export2 do not:
> > 
> > [root@rhel7u4 ~]# exportfs -v
> > /export       	<world>(rw,sync,wdelay,hide,no_subtree_check,se
> > c=sys,secure,no_root_squash,no_all_squash)
> > /export/export1
> > 		<world>(rw,sync,wdelay,hide,no_subtree_check,security_l
> > abel,sec=sys,secure,no_root_squash,no_all_squash)
> > /export/export1/export2
> > 		<world>(rw,sync,wdelay,hide,no_subtree_check,sec=sys,se
> > cure,no_root_squash,no_all_squash)
> > /export/export1/export2/export3
> > 		<world>(rw,sync,wdelay,hide,no_subtree_check,security_l
> > abel,sec=sys,secure,no_root_squash,no_all_squash)
> > 
> > 
> > [root@fedora25 ~]# mount -o v4.2 rhel7u4:/export /mnt/t
> > [root@fedora25 ~]# ls -lZ /mnt/t
> > total 8
> > drwxr-xr-x. 4 root root system_u:object_r:nfs_t:s0 4096 May 30 14:09
> > export1
> 
> Shouldn't this be the label of export1 from the server, since export1
> is exported with security_label?
> 
<snip/>

That's my fault, I actually didn't have labels on all the directories on
the server.

[root@rhel7u4 ~]# ls -laZ /export/export1
drwxr-xr-x. root root system_u:object_r:unlabeled_t:s0 .
drwxrwxrwx. root root unconfined_u:object_r:usr_t:s0   ..
drwxr-xr-x. root root system_u:object_r:unlabeled_t:s0 export2
-rw-r--r--. root root system_u:object_r:etc_t:s0       file1
-rw-r--r--. root root system_u:object_r:bin_t:s0       file2
-rw-r--r--. root root system_u:object_r:usr_t:s0       file3
drwx------. root root system_u:object_r:unlabeled_t:s0 lost+found
[root@rhel7u4 ~]# ls -laZ /export/export1/export2
drwxr-xr-x. root root system_u:object_r:unlabeled_t:s0 .
drwxr-xr-x. root root system_u:object_r:unlabeled_t:s0 ..
drwxr-xr-x. root root system_u:object_r:unlabeled_t:s0 export3
-rw-r--r--. root root system_u:object_r:etc_t:s0       file1
-rw-r--r--. root root system_u:object_r:bin_t:s0       file2
-rw-r--r--. root root system_u:object_r:usr_t:s0       file3
drwx------. root root system_u:object_r:unlabeled_t:s0 lost+found
[root@rhel7u4 ~]# ls -laZ /export/export1/export2/export3
drwxr-xr-x. root root system_u:object_r:unlabeled_t:s0 .
drwxr-xr-x. root root system_u:object_r:unlabeled_t:s0 ..
-rw-r--r--. root root system_u:object_r:etc_t:s0       file1
-rw-r--r--. root root system_u:object_r:bin_t:s0       file2
-rw-r--r--. root root system_u:object_r:usr_t:s0       file3
drwx------. root root system_u:object_r:unlabeled_t:s0 lost+found

Setting the missing labels...

[root@rhel7u4 ~]# chcon -t usr_t /export/export1
[root@rhel7u4 ~]# chcon -t usr_t /export/export1/export2
[root@rhel7u4 ~]# chcon -t usr_t /export/export1/export2/export3
[root@rhel7u4 ~]# chcon -t lost_found_t /export/export1/lost+found
[root@rhel7u4 ~]# chcon -t lost_found_t /export/export1/export2/lost+found
[root@rhel7u4 ~]# chcon -t lost_found_t /export/export1/export2/export3/lost+found

[root@rhel7u4 ~]# ls -laZ /export/export1
drwxr-xr-x. root root system_u:object_r:usr_t:s0       .
drwxrwxrwx. root root unconfined_u:object_r:usr_t:s0   ..
drwxr-xr-x. root root system_u:object_r:usr_t:s0       export2
-rw-r--r--. root root system_u:object_r:etc_t:s0       file1
-rw-r--r--. root root system_u:object_r:bin_t:s0       file2
-rw-r--r--. root root system_u:object_r:usr_t:s0       file3
drwx------. root root system_u:object_r:lost_found_t:s0 lost+found
[root@rhel7u4 ~]# ls -laZ /export/export1/export2
drwxr-xr-x. root root system_u:object_r:usr_t:s0       .
drwxr-xr-x. root root system_u:object_r:usr_t:s0       ..
drwxr-xr-x. root root system_u:object_r:usr_t:s0       export3
-rw-r--r--. root root system_u:object_r:etc_t:s0       file1
-rw-r--r--. root root system_u:object_r:bin_t:s0       file2
-rw-r--r--. root root system_u:object_r:usr_t:s0       file3
drwx------. root root system_u:object_r:lost_found_t:s0 lost+found
[root@rhel7u4 ~]# ls -laZ /export/export1/export2/export3
drwxr-xr-x. root root system_u:object_r:usr_t:s0       .
drwxr-xr-x. root root system_u:object_r:usr_t:s0       ..
-rw-r--r--. root root system_u:object_r:etc_t:s0       file1
-rw-r--r--. root root system_u:object_r:bin_t:s0       file2
-rw-r--r--. root root system_u:object_r:usr_t:s0       file3
drwx------. root root system_u:object_r:lost_found_t:s0 lost+found

Even after setting the labels on the NFS server, the behavior on the client
appears strange until you remember that the client doesn't actually know about
label support on the export until it steps on the mountpoint and triggers the
submount.  I don't know if I'd call it a bug or not... more of a peculiarity :)

Here we're doing READDIR with the NFS filehandle of /export.  Since /export is
not exported with the security_label option, the attrmask in the READDIR is not
requesting security labels... so export1 shows nfs_t even though
/export/export1 is exported with the security_label option:

[root@fedora25 ~]# ls -laZ /mnt/t
total 8
drwxrwxrwx. 5 root root system_u:object_r:nfs_t:s0   87 Jun  1 09:10 .
drwxr-xr-x. 5 root root system_u:object_r:mnt_t:s0   42 May 22 08:45 ..
drwxr-xr-x. 4 root root system_u:object_r:nfs_t:s0 4096 May 30 14:09 export1
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0    0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0    0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0    0 May 30 14:09 file3
drwxrwxrwx. 3 root root system_u:object_r:nfs_t:s0   22 Apr 21 12:58 scratch
drwxrwxrwx. 7 root root system_u:object_r:nfs_t:s0 4096 Apr 21 12:55 test

Here we're doing a READDIR with the NFS filehandle of /export/export1, which
triggers the mount of /export/export1.  Since /export/export1 is exported with
the security_label option, the attrmask in the READDIR is requesting security
labels.  Note that '.' now shows usr_t instead of nfs_t.  However, since
/export/export1/export2 is not exported with the security_label option, the NFS
server does not return a security label in the attributes for export2 in the
READDIR reply... so it's displayed as unlabeled_t:

[root@fedora25 ~]# ls -laZ /mnt/t/export1
total 24
drwxr-xr-x. 4 root root system_u:object_r:usr_t:s0         4096 May 30 14:09 .
drwxrwxrwx. 5 root root system_u:object_r:nfs_t:s0           87 Jun  1 09:10 ..
drwxr-xr-x. 4 root root system_u:object_r:unlabeled_t:s0   4096 May 30 14:09 export2
-rw-r--r--. 1 root root system_u:object_r:etc_t:s0            0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:bin_t:s0            0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:usr_t:s0            0 May 30 14:09 file3
drwx------. 2 root root system_u:object_r:lost_found_t:s0 16384 May 30 14:02 lost+found

Here we're doing doing a READDIR with the NFS filehandle of /export/export1/export2,
which triggers the mount of /export/export1/export2.  Since /export/export1/export2
is not exported with the security_label option, the attrmask in the READDIR is not
requesting security labels, and everything (including both '.' and 'export3') is
displayed as nfs_t:

[root@fedora25 ~]# ls -laZ /mnt/t/export1/export2
total 28
drwxr-xr-x. 4 root root system_u:object_r:nfs_t:s0  4096 May 30 14:09 .
drwxr-xr-x. 4 root root system_u:object_r:usr_t:s0  4096 May 30 14:09 ..
drwxr-xr-x. 3 root root system_u:object_r:nfs_t:s0  4096 May 30 14:08 export3
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0     0 May 30 14:09 file1
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0     0 May 30 14:09 file2
-rw-r--r--. 1 root root system_u:object_r:nfs_t:s0     0 May 30 14:09 file3
drwx------. 2 root root system_u:object_r:nfs_t:s0 16384 May 30 14:02 lost+found

Here we're doing a READDIR with the NFS filehandle of /export1/export2/export3,
which triggers the mount of /export1/export2/export3.  Since /export1/export2/export3
is exported with the security_label option, the attrmask in the READDIR is
requesting security labels, and '.' now shows as usr_t:

[root@fedora25 ~]# ls -laZ /mnt/t/export1/export2/export3
total 24
drwxr-xr-x. 3 root root system_u:object_r:usr_t:s0         4096 May 30 14:08 .
drwxr-xr-x. 4 root root system_u:object_r:nfs_t:s0         4096 May 30 14:09 ..
-rw-r--r--. 1 root root system_u:object_r:etc_t:s0            0 May 30 14:08 file1
-rw-r--r--. 1 root root system_u:object_r:bin_t:s0            0 May 30 14:08 file2
-rw-r--r--. 1 root root system_u:object_r:usr_t:s0            0 May 30 14:08 file3
drwx------. 2 root root system_u:object_r:lost_found_t:s0 16384 May 30 14:02 lost+found

After triggering all those mounts, the labels for export1 and export3 match
what I set on the server:

[root@fedora25 ~]# ls -ldZ /mnt/t
drwxrwxrwx. 5 root root system_u:object_r:nfs_t:s0 87 Jun  1 09:10 /mnt/t
[root@fedora25 ~]# ls -ldZ /mnt/t/export1
drwxr-xr-x. 4 root root system_u:object_r:usr_t:s0 4096 May 30 14:09 /mnt/t/export1
[root@fedora25 ~]# ls -ldZ /mnt/t/export1/export2
drwxr-xr-x. 4 root root system_u:object_r:nfs_t:s0 4096 May 30 14:09 /mnt/t/export1/export2
[root@fedora25 ~]# ls -ldZ /mnt/t/export1/export2/export3
drwxr-xr-x. 3 root root system_u:object_r:usr_t:s0 4096 May 30 14:08 /mnt/t/export1/export2/export3
[root@fedora25 ~]# 

-Scott

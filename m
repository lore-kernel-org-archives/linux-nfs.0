Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:48201 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbaLPWfF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2014 17:35:05 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Y10hr-0006lN-B5
	for linux-nfs@vger.kernel.org; Tue, 16 Dec 2014 23:35:03 +0100
Received: from p4ff58697.dip0.t-ipconnect.de ([79.245.134.151])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 23:35:03 +0100
Received: from holger.hoffstaette by p4ff58697.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 23:35:03 +0100
To: linux-nfs@vger.kernel.org
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: 3.18.1: broken directory with one file too many
Date: Tue, 16 Dec 2014 22:19:18 +0000 (UTC)
Message-ID: <pan.2014.12.16.22.19.18@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

g
(please CC: for followups)

I just spent two hours trying to untangle a *weird* bug that I have not
seen before. It might be new to 3.18.x but I don't know for sure.
Apologies in advance for the long prelude but I figured I need to
describe the problem scenario as precisely as possible.

All this is on freshly baked 3.18.1 with Gentoo userland; the exported
filesystem is ext4.

On my NFS server I work with a git repo:

holger>git clone ../work/kernel-patches.git
Cloning into 'kernel-patches'...
done.
holger>cd kernel-patches 
holger>git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean
holger>ll
total 92K
drwxr-xr-x 2 holger users  72K Dec 16 22:41 3.14/
drwxr-xr-x 2 holger users  16K Dec 16 22:41 3.18/
-rw-r--r-- 1 holger users 2.4K Dec 16 22:41 README.md
holger>

Looking fine!

On my NFS client this directory is automounted via NFS:

holger>mount | grep home
tux:/home/holger on /mnt/tux/holger type nfs (rw,noatime,tcp,sloppy,vers=4,addr=192.168.100.222,clientaddr=192.168.100.128)

This has worked for ages and never caused any problems.

Let's see how my git repo is doing:
 
holger>cd /mnt/tux/holger/Projects/kernel-patches 
holger>ll
total 92K
drwxr-xr-x 2 holger users  72K Dec 16 22:41 3.14/
drwxr-xr-x 2 holger users  16K Dec 16 22:41 3.18/
-rw-r--r-- 1 holger users 2.4K Dec 16 22:41 README.md
holger>git status
On branch master
Your branch is up-to-date with 'origin/master'.
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	3.14/btrfs-20

nothing added to commit but untracked files present (use "git add" to track)

..wait, what? There is no such file "btrfs-20" !

holger>ll 3.14 | head
ls: cannot access 3.14/btrfs-20: No such file or directory
total 4.5M
-rw-r--r-- 1 holger users 3.3K Dec 16 22:41 bfq-v7r6-001-block-cgroups-kconfig-build-bits-for-BFQ-v7r6-3.14.patch
-rw-r--r-- 1 holger users 219K Dec 16 22:41 bfq-v7r6-002-block-introduce-the-BFQ-v7r6-I-O-sched-for-3.14.patch
-rw-r--r-- 1 holger users  41K Dec 16 22:41 bfq-v7r6-003-block-bfq-add-Early-Queue-Merge-EQM-to-BFQ-v7r6-for-3.14.0.patch
-rw-r--r-- 1 holger users 237K Dec 16 22:41 bfs-454-001-sched-bfs.patch
-rw-r--r-- 1 holger users 5.2K Dec 16 22:41 bfs-454-002-cpu-topology.patch
-rw-r--r-- 1 holger users  13K Dec 16 22:41 bfs-454-003-smtnice-v6.patch
-????????? ? ?      ?        ?            ? btrfs-20
-rw-r--r-- 1 holger users 7.8K Dec 16 22:41 btrfs-20140114-don't-mix-the-ordered-extents-of-all-files-together-during-logging-the-inodes.patch
-rw-r--r-- 1 holger users 1.2K Dec 16 22:41 btrfs-20140130-add-missing-error-check-in-incremental-send.patch
holger>

There is a "rogue" file messing up the directory?!

This used to work until I added a specific file, so..

holger>ll 3.14/btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch 
-rw-r--r-- 1 holger users 2.3K Dec 16 22:41 3.14/btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch

holger>stat 3.14/btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch
  File: ‘3.14/btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch’
  Size: 2306      	Blocks: 8          IO Block: 1048576 regular file
Device: 18h/24d	Inode: 22544856    Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/  holger)   Gid: (  100/   users)
Access: 2014-12-16 22:41:36.515665610 +0100
Modify: 2014-12-16 22:41:36.515665610 +0100
Change: 2014-12-16 22:41:36.515665610 +0100
 Birth: -

Looks fine..maybe try moving it to the parent?

holger>mv 3.14/btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch .
holger>ll
total 96K
drwxr-xr-x 2 holger users  72K Dec 16 22:44 3.14/
drwxr-xr-x 2 holger users  16K Dec 16 22:41 3.18/
-rw-r--r-- 1 holger users 2.4K Dec 16 22:41 README.md
-rw-r--r-- 1 holger users 2.3K Dec 16 22:41 btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch

holger>git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	deleted:    3.14/btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch

no changes added to commit (use "git add" and/or "git commit -a")

holger>ll 3.14 | head                                                                  
total 4.5M
-rw-r--r-- 1 holger users 3.3K Dec 16 22:41 bfq-v7r6-001-block-cgroups-kconfig-build-bits-for-BFQ-v7r6-3.14.patch
-rw-r--r-- 1 holger users 219K Dec 16 22:41 bfq-v7r6-002-block-introduce-the-BFQ-v7r6-I-O-sched-for-3.14.patch
-rw-r--r-- 1 holger users  41K Dec 16 22:41 bfq-v7r6-003-block-bfq-add-Early-Queue-Merge-EQM-to-BFQ-v7r6-for-3.14.0.patch
-rw-r--r-- 1 holger users 237K Dec 16 22:41 bfs-454-001-sched-bfs.patch
-rw-r--r-- 1 holger users 5.2K Dec 16 22:41 bfs-454-002-cpu-topology.patch
-rw-r--r-- 1 holger users  13K Dec 16 22:41 bfs-454-003-smtnice-v6.patch
-rw-r--r-- 1 holger users 7.8K Dec 16 22:41 btrfs-20140114-don't-mix-the-ordered-extents-of-all-files-together-during-logging-the-inodes.patch
-rw-r--r-- 1 holger users 1.2K Dec 16 22:41 btrfs-20140130-add-missing-error-check-in-incremental-send.patch
-rw-r--r-- 1 holger users 5.2K Dec 16 22:41 btrfs-20140130-fix-32-64-bit-problem-with-BTRFS_SET_RECEIVED_SUBVOL-ioctl.patch

I can move it back into 3.14/ and the directory is messed up again.
All this is reproducible, in different export directories.

Any ideas what this might be? A direntry hash collision maybe?
There is a large number of files starting with btrfs-2014xxyy-.. but with
the typical kernel patch names (some quite long), so that would be pretty
bad. Also everything works locally on ext4 without problems, so I suspect
it's an isolated NFS problem.

Things that did not work - same results every time:
- dropping caches on client & server
- restarting NFS on client & server

Any suggestions welcome; I'll gladly test patches.

thanks
Holger


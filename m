Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab2C3TCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 15:02:47 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 00/10] Clean up mount functions
Date: Fri, 30 Mar 2012 15:02:27 -0400
Message-Id: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I noticed that we had 5 almost identical mount functions in super.c.  I
collapsed them all into one common function to make everything easier to
maintain and work with.  The first few patches are basic cleanups, the last
four drop us down to one common mount path.

I also hope these patches will simplify my modules changes, but I won't
know for sure until I update everything.

Comments or suggestions are appreciated!

- Bryan

Bryan Schumaker (10):
  NFS: Create a single nfs_fill_super() function
  NFS: Create a single nfs_clone_super() function
  NFS: Fix whitespace errors
  NFS: Consistent arguments to nfs_fscache_get_super_cookie()
  NFS: Rename nfs4_proc_get_root()
  NFS: Create a single nfs_get_root()
  NFS: Create a common fs_mount() function
  NFS: Create a common xdev_mount() function
  NFS: Use nfs_fs_mount_common() for xdev mounts
  NFS: Use nfs_fs_mount_common() for remote referral mounts

 fs/nfs/fscache.c  |   13 +-
 fs/nfs/fscache.h  |    2 +-
 fs/nfs/getroot.c  |   85 +------
 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |   30 ++-
 fs/nfs/super.c    |  664 +++++++++++++----------------------------------------
 6 files changed, 196 insertions(+), 599 deletions(-)

-- 
1.7.9.5


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30827 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757382Ab2EGSmw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 May 2012 14:42:52 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 0/8] Clean up mount functions
Date: Mon,  7 May 2012 14:42:38 -0400
Message-Id: <1336416166-20533-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I noticed that we had 5 almost identical mount functions in super.c.  I
collapsed them all into one common function to make everything easier to
maintain and work with.  The first few patches are basic cleanups, the last
four drop us down to one common mount path.

These patches also help simplify my modules changes since I no longer have
to split these functions out of the generic code.

Changes in v2
-------------
- Reword commit message on patch 2: Create a single nfs_get_root()
- Change arguments to nfs_fscache_get_super_cookie() in patch 3
- Introduce a new patch 4 to remove the NFS4_MOUNT_UNSHARED flag

Comments or suggestions are appreciated!

- Bryan

Bryan Schumaker (8):
  NFS: Rename nfs4_proc_get_root()
  NFS: Create a single nfs_get_root()
  NFS: Don't pass mount data to nfs_fscache_get_super_cookie()
  NFS: Remove NFS4_MOUNT_UNSHARED
  NFS: Create a common fs_mount() function
  NFS: Create a common xdev_mount() function
  NFS: Use nfs_fs_mount_common() for xdev mounts
  NFS: Use nfs_fs_mount_common() for remote referral mounts

 fs/nfs/fscache.c           |   15 +-
 fs/nfs/fscache.h           |    4 +-
 fs/nfs/getroot.c           |   85 +-----
 fs/nfs/nfs4_fs.h           |    1 +
 fs/nfs/nfs4proc.c          |   30 ++-
 fs/nfs/super.c             |  635 ++++++++++++--------------------------------
 include/linux/nfs4_mount.h |    1 -
 7 files changed, 199 insertions(+), 572 deletions(-)

-- 
1.7.10.1


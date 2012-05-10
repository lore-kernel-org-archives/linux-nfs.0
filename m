Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18254 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760304Ab2EJTHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 15:07:50 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 00/14] Clean up mount functions
Date: Thu, 10 May 2012 15:07:29 -0400
Message-Id: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I noticed that we had 5 almost identical mount functions in super.c.  I
collapsed them all into one common function to make everything easier to
maintain and work with.  Patches 1 - 4 are cleanups, 5 - 8 drop us down to
one common mount path, and 9 - 14 are cleanups to remove the nfs4_mount()
function.

These patches also help simplify my modules changes since I no longer have
to split these functions out of the generic code.

Changes in v4
-------------
- Fix up the commit message on patch 6
- Don't delete the dprintks saying that the nfs_xdev_mount() function is exiting

Changes in v3
-------------
- Remove the NFS4_MOUNT_UNSHARED flag
- nfs_validate_mount_data() selects between the v2/3 function and the v4 function
- Created a generic function for parsing text mount data

Comments or suggestions are appreciated!

- Bryan

Bryan Schumaker (14):
  NFS: Rename nfs4_proc_get_root()
  NFS: Create a single nfs_get_root()
  NFS: Don't pass mount data to nfs_fscache_get_super_cookie()
  NFS: Remove NFS4_MOUNT_UNSHARED
  NFS: Create a common fs_mount() function
  NFS: Create a common xdev_mount() function
  NFS: Use nfs_fs_mount_common() for xdev mounts
  NFS: Use nfs_fs_mount_common() for remote referral mounts
  NFS: Let mount data parsing set the NFS version
  NFS: Create a new nfs_try_mount()
  NFS: Create a single function for text mount data
  NFS: Create a single nfs_validate_mount_data() function
  NFS: Allocate parsed mount data directly to the nfs_mount_info
    structure
  NFS: Pass mntfh as part of the nfs_mount_info structure

 fs/nfs/fscache.c  |   15 +-
 fs/nfs/fscache.h  |    4 +-
 fs/nfs/getroot.c  |   85 +-----
 fs/nfs/internal.h |    1 +
 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |   30 ++-
 fs/nfs/super.c    |  748 ++++++++++++++++++++---------------------------------
 7 files changed, 309 insertions(+), 575 deletions(-)

-- 
1.7.10.1


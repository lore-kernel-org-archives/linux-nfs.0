Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:30084 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754467Ab3JRTPf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Oct 2013 15:15:35 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 0/5] NFS: Add support for multiple sec= mount options
Date: Fri, 18 Oct 2013 15:15:14 -0400
Message-ID: <1382123719-25194-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I split up this patchset into multiple patches as Trond requested.

This also has a few changes:
 - stop using NFS_MOUNT_SECFLAVOUR server flag
     - This flag was now redundant (auth_info stored on nfs_server).

 - more consistent use of selected_flavor
     - It didn't need to be set in nfs_parse_security_flavors
     - NFSv4 wasn't setting is as it just picked the first flavor in
       nfs4_init_server then depends on SECINFO.  nfs4_init_server
       now sets it for consistency. The reason we need selected_flavor
       is for the mount client to be able to save it's selection
       (for nfs < 4.0).

Again, I created a script to test mount options which has been posted to the
list as a patch to nfs-ordeal.

 -dros

Weston Andros Adamson (5):
  NFSv4: make nfs_find_best_sec static
  NFS: separate passed security flavs from selected
  NFS: cache parsed auth_info in nfs_server
  NFS: stop using NFS_MOUNT_SECFLAVOUR server flag
  NFS: add support for multiple sec= mount options

 fs/nfs/client.c                |   5 +-
 fs/nfs/internal.h              |   5 +-
 fs/nfs/nfs4_fs.h               |   1 -
 fs/nfs/nfs4client.c            |  26 ++++--
 fs/nfs/nfs4namespace.c         |  17 +++-
 fs/nfs/nfs4proc.c              |  32 ++++---
 fs/nfs/super.c                 | 189 +++++++++++++++++++++++++----------------
 include/linux/nfs_fs_sb.h      |   1 +
 include/linux/nfs_xdr.h        |   7 ++
 include/uapi/linux/nfs_mount.h |   2 +-
 10 files changed, 184 insertions(+), 101 deletions(-)

-- 
1.7.12.4 (Apple Git-37)


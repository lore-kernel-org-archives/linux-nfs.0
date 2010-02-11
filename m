From: Ben Myers <bpm@sgi.com>
Subject: [PATCH 2/2] xfs_export_operations.commit_metadata
Date: Thu, 11 Feb 2010 13:26:22 -0600
Message-ID: <20100211192622.12949.93762.stgit@case>
References: <20100211192611.12949.65493.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: xfs@oss.sgi.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:54766 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756714Ab0BKT0Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 14:26:24 -0500
In-Reply-To: <20100211192611.12949.65493.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the commit_metadata export operation for XFS, including the changes
suggested by hch and dgc:

- Takes two two inodes instead of dentries and can assume the parent is
  always set.

- Uses xfs_lock_two_inodes for the ilock.

- Forces the log up to the larger lsn of parent and child.

- Uses XFS_LSN_CMP for lsn comparison.

- Doesn't force the log if nobody had a pincount.

Signed-off-by: Ben Myers <bpm@sgi.com>
---
 fs/xfs/linux-2.6/xfs_export.c |   43 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_export.c b/fs/xfs/linux-2.6/xfs_export.c
index 87b8cbd..d37ced1 100644
--- a/fs/xfs/linux-2.6/xfs_export.c
+++ b/fs/xfs/linux-2.6/xfs_export.c
@@ -29,6 +29,7 @@
 #include "xfs_vnodeops.h"
 #include "xfs_bmap_btree.h"
 #include "xfs_inode.h"
+#include "xfs_inode_item.h"
 
 /*
  * Note that we only accept fileids which are long enough rather than allow
@@ -215,9 +216,51 @@ xfs_fs_get_parent(
 	return d_obtain_alias(VFS_I(cip));
 }
 
+STATIC int
+xfs_fs_nfs_commit_metadata(
+	struct inode		*parent,
+	struct inode		*child)
+{
+	struct xfs_inode	*dp = XFS_I(parent);
+	struct xfs_inode	*ip = NULL;
+	struct xfs_mount	*mp = dp->i_mount;
+	xfs_lsn_t		force_lsn = NULLCOMMITLSN;
+	int			error = 0;
+
+	if (child) {
+		ip = XFS_I(child);
+		xfs_lock_two_inodes(dp, ip, XFS_ILOCK_SHARED);
+	} else {
+		xfs_ilock(dp, XFS_ILOCK_SHARED);
+	}
+
+	if (xfs_ipincount(dp)) {
+		force_lsn = dp->i_itemp->ili_last_lsn;
+		if (ip && xfs_ipincount(ip) &&
+		    XFS_LSN_CMP(force_lsn, ip->i_itemp->ili_last_lsn) < 0) {
+			force_lsn = ip->i_itemp->ili_last_lsn;
+		}
+	} else if (ip && xfs_ipincount(ip)) {
+		force_lsn = ip->i_itemp->ili_last_lsn;
+	}
+
+	if (force_lsn != NULLCOMMITLSN) {
+		error = _xfs_log_force(mp, force_lsn,
+				XFS_LOG_FORCE | XFS_LOG_SYNC, NULL);
+	}
+
+	if (child)
+		xfs_iunlock(ip, XFS_ILOCK_SHARED);
+	if (parent)
+		xfs_iunlock(dp, XFS_ILOCK_SHARED);
+
+	return error;
+}
+
 const struct export_operations xfs_export_operations = {
 	.encode_fh		= xfs_fs_encode_fh,
 	.fh_to_dentry		= xfs_fs_fh_to_dentry,
 	.fh_to_parent		= xfs_fs_fh_to_parent,
 	.get_parent		= xfs_fs_get_parent,
+	.commit_metadata	= xfs_fs_nfs_commit_metadata,
 };


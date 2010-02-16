From: Ben Myers <bpm@sgi.com>
Subject: [PATCH 2/2] xfs_export_operations.commit_metadata
Date: Tue, 16 Feb 2010 15:04:18 -0600
Message-ID: <20100216210418.5694.48417.stgit@case>
References: <20100216210026.5694.14423.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:33726 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933309Ab0BPVET (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Feb 2010 16:04:19 -0500
In-Reply-To: <20100216210026.5694.14423.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the commit_metadata export operation for XFS.

- Takes one inode to be committed.

- Forces the log up to the lsn of the inode.

- Doesn't force the log if the inode doesn't have a pincount.

Signed-off-by: Ben Myers <bpm@sgi.com>
---
 fs/xfs/linux-2.6/xfs_export.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_export.c b/fs/xfs/linux-2.6/xfs_export.c
index 87b8cbd..47a8d1f 100644
--- a/fs/xfs/linux-2.6/xfs_export.c
+++ b/fs/xfs/linux-2.6/xfs_export.c
@@ -29,6 +29,7 @@
 #include "xfs_vnodeops.h"
 #include "xfs_bmap_btree.h"
 #include "xfs_inode.h"
+#include "xfs_inode_item.h"
 
 /*
  * Note that we only accept fileids which are long enough rather than allow
@@ -215,9 +216,32 @@ xfs_fs_get_parent(
 	return d_obtain_alias(VFS_I(cip));
 }
 
+STATIC int
+xfs_fs_nfs_commit_metadata(
+	struct inode		*inode)
+{
+	struct xfs_inode	*ip = XFS_I(inode);
+	struct xfs_mount	*mp = ip->i_mount;
+	xfs_lsn_t		force_lsn = NULLCOMMITLSN;
+	int			error = 0;
+
+	xfs_ilock(ip, XFS_ILOCK_SHARED);
+	if (xfs_ipincount(ip)) {
+		force_lsn = ip->i_itemp->ili_last_lsn;
+	}
+	if (force_lsn != NULLCOMMITLSN) {
+		error = _xfs_log_force(mp, force_lsn,
+				XFS_LOG_FORCE | XFS_LOG_SYNC, NULL);
+	}
+	xfs_iunlock(ip, XFS_ILOCK_SHARED);
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


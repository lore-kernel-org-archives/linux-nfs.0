From: Ben Myers <bpm@sgi.com>
Subject: [RFC PATCH 2/2] xfs_export_operations.commit_metadata
Date: Tue, 09 Feb 2010 18:33:37 -0600
Message-ID: <20100210003337.6021.10942.stgit@case>
References: <20100210003220.6021.74943.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:57227 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672Ab0BJAdi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 19:33:38 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay1.corp.sgi.com (Postfix) with ESMTP id A51F98F8052
	for <linux-nfs@vger.kernel.org>; Tue,  9 Feb 2010 16:33:37 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id 17A9048F3C1A
	for <linux-nfs@vger.kernel.org>; Tue,  9 Feb 2010 18:33:37 -0600 (CST)
In-Reply-To: <20100210003220.6021.74943.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is the commit_metadata export_operation for xfs.  We take two dentries and
force the log up to the larger lsn.  It looks to me that in nfsd the child is
always modified after the parent so generally we expect the child's lsn to be
larger.  If that's not the case we'll just force the entire thing.

The basic form of this is based upon one of Christoph's suggestions.  I'm an
xfs newbie so I'm not very comfortable with it yet.  My understanding is that I
need to verify that all of the necessary changes make it into the transations
we're forcing into the log here.  I am still looking into that and hopefully
the XFS gurus can continue to provide guidance.
---
 fs/xfs/linux-2.6/xfs_export.c |   64 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_export.c b/fs/xfs/linux-2.6/xfs_export.c
index 87b8cbd..af4a214 100644
--- a/fs/xfs/linux-2.6/xfs_export.c
+++ b/fs/xfs/linux-2.6/xfs_export.c
@@ -29,6 +29,7 @@
 #include "xfs_vnodeops.h"
 #include "xfs_bmap_btree.h"
 #include "xfs_inode.h"
+#include "xfs_inode_item.h"
 
 /*
  * Note that we only accept fileids which are long enough rather than allow
@@ -215,9 +216,72 @@ xfs_fs_get_parent(
 	return d_obtain_alias(VFS_I(cip));
 }
 
+STATIC int
+xfs_fs_nfs_commit_metadata(
+	struct dentry		*parent,
+	struct dentry		*child)
+{
+	struct xfs_inode	*p_xip = NULL, *c_xip = NULL;
+	struct xfs_mount	*i_mount = NULL;	
+	xfs_lsn_t		force_lsn = 0;
+	int 			error = 0;
+
+	if (parent && !child) {
+		p_xip = XFS_I(parent->d_inode);
+		xfs_ilock(p_xip, XFS_ILOCK_SHARED);
+		if (xfs_ipincount(p_xip)) {
+			force_lsn = p_xip->i_itemp->ili_last_lsn;
+			i_mount = p_xip->i_mount;
+		}
+	} else if (child && !parent) {
+		c_xip = XFS_I(child->d_inode);
+		xfs_ilock(c_xip, XFS_ILOCK_SHARED);
+		if (xfs_ipincount(c_xip)) {
+			force_lsn = c_xip->i_itemp->ili_last_lsn;
+			i_mount = c_xip->i_mount;
+		}
+	} else if (parent && child) {
+		p_xip = XFS_I(parent->d_inode);
+		c_xip = XFS_I(child->d_inode);
+		xfs_ilock(p_xip, XFS_ILOCK_SHARED);
+		xfs_ilock(c_xip, XFS_ILOCK_SHARED);
+		if (xfs_ipincount(p_xip)) {
+			force_lsn = p_xip->i_itemp->ili_last_lsn;
+			i_mount = p_xip->i_mount;
+		}
+		if (xfs_ipincount(c_xip)) {
+			/*
+			 * AFAICS the child is always modified after the parent
+			 * in nfsd so should always have a larger lsn.
+			 */
+			if (c_xip->i_itemp->ili_last_lsn > force_lsn) {
+				force_lsn = c_xip->i_itemp->ili_last_lsn;
+			} else {
+				force_lsn = 0; /* whole thing */
+			}
+			i_mount = c_xip->i_mount;
+		}
+	} else {
+		return -EINVAL;
+	}
+
+	if (i_mount) {
+		error = _xfs_log_force(i_mount, force_lsn,
+				XFS_LOG_FORCE | XFS_LOG_SYNC, NULL);
+	}
+
+	if (child)
+		xfs_iunlock(c_xip, XFS_ILOCK_SHARED);
+	if (parent)
+		xfs_iunlock(p_xip, XFS_ILOCK_SHARED);
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


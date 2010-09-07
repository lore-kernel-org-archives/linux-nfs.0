Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932481Ab0IGUDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:03:52 -0400
Received: from [10.58.61.36] (panchal1-lxp.hq.netapp.com [10.58.61.36] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o87K3p8g027405
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 13:03:52 -0700 (PDT)
Message-ID: <4C869AA7.2030000@netapp.com>
Date: Tue, 07 Sep 2010 16:03:51 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/6] NFS: remove readdir plus limit
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS remove readdir plus limit

We will now use readdir plus even on directories that are very large.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7d2d6c7..b2e12bc 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -234,9 +234,6 @@ nfs_init_locked(struct inode *inode, void *opaque)
 	return 0;
 }
 
-/* Don't use READDIRPLUS on directories that we believe are too large */
-#define NFS_LIMIT_READDIRPLUS (8*PAGE_SIZE)
-
 /*
  * This is our front-end to iget that looks up inodes by file handle
  * instead of inode number.
@@ -291,8 +288,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		} else if (S_ISDIR(inode->i_mode)) {
 			inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops;
 			inode->i_fop = &nfs_dir_operations;
-			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
-			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
+			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			/* Deal with crossing mountpoints */
 			if ((fattr->valid & NFS_ATTR_FATTR_FSID)

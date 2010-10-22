Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6970 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757168Ab0JVOOk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:40 -0400
Message-ID: <4CC19C44.1060907@netapp.com>
Date: Fri, 22 Oct 2010 10:14:28 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/10] NFS: remove readdir plus limit
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We will now use readdir plus even on directories that are very large.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f2d2c80..6eec286 100644
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

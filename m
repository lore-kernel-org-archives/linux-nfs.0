Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50297 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755922Ab2E3U2g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 16:28:36 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4 do not send an empty SETATTR compound
Date: Wed, 30 May 2012 16:12:24 -0400
Message-Id: <1338408744-2226-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Commit 536e43d12b9517bbbf6114cd1a12be27857a4d7a ATTR_OPEN check can result in
an ia_valid with only ATTR_FILE set, and no NFS_VALID_ATTRS attributes to
request from the server.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5a87beb..65e1df8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2524,6 +2524,14 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 
 	nfs_fattr_init(fattr);
 	
+	/* Deal with open(O_TRUNC) */
+	if (sattr->ia_valid & ATTR_OPEN)
+		sattr->ia_valid &= ~(ATTR_MTIME|ATTR_CTIME|ATTR_OPEN);
+
+	/* Optimization: if the end result is no change, don't RPC */
+	if ((sattr->ia_valid & ~(ATTR_FILE)) == 0)
+		return 0;
+
 	/* Search for an existing open(O_WRITE) file */
 	if (sattr->ia_valid & ATTR_FILE) {
 		struct nfs_open_context *ctx;
@@ -2535,10 +2543,6 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		}
 	}
 
-	/* Deal with open(O_TRUNC) */
-	if (sattr->ia_valid & ATTR_OPEN)
-		sattr->ia_valid &= ~(ATTR_MTIME|ATTR_CTIME|ATTR_OPEN);
-
 	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
 	if (status == 0)
 		nfs_setattr_update_inode(inode, sattr);
-- 
1.7.6.4


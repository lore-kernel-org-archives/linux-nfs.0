From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 5/5] SQUASHME: spnfs: use only RETURN_* constants
Date: Wed,  9 Dec 2009 12:27:59 +0200
Message-ID: <1260354479-12251-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45329 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754423AbZLIK1y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:27:54 -0500
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/spnfs_ops.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/spnfs_ops.c b/fs/nfsd/spnfs_ops.c
index 322fc12..2838a85 100644
--- a/fs/nfsd/spnfs_ops.c
+++ b/fs/nfsd/spnfs_ops.c
@@ -199,17 +199,17 @@ spnfs_layoutrecall(struct inode *inode, int type, u64 offset, u64 len)
 	struct nfsd4_pnfs_cb_layout lr;
 
 	switch (type) {
-	case RECALL_FILE:
+	case RETURN_FILE:
 		sb = inode->i_sb;
 		dprintk("%s: recalling layout for ino = %lu\n",
 			__func__, inode->i_ino);
 		break;
-	case RECALL_FSID:
+	case RETURN_FSID:
 		sb = inode->i_sb;
 		dprintk("%s: recalling layout for fsid x (unimplemented)\n",
 			__func__);
 		return 0;
-	case RECALL_ALL:
+	case RETURN_ALL:
 		/* XXX figure out how to get a sb since there's no inode ptr */
 		dprintk("%s: recalling all layouts (unimplemented)\n",
 			__func__);
@@ -244,19 +244,19 @@ spnfs_test_layoutrecall(char *path, u64 offset, u64 len)
 
 	if (strcmp(path, "all") == 0) {
 		inode = NULL;
-		type = RECALL_ALL;
+		type = RETURN_ALL;
 	} else {
 		rc = path_lookup(path, 0, &nd);
 		if (rc != 0)
 			return -ENOENT;
 
 		/*
-		 * XXX todo: add a RECALL_FSID scenario here...maybe if
+		 * XXX todo: add a RETURN_FSID scenario here...maybe if
 		 * inode is a dir...
 		 */
 
 		inode = nd.path.dentry->d_inode;
-		type = RECALL_FILE;
+		type = RETURN_FILE;
 	}
 
 	if (len == 0)
@@ -264,7 +264,7 @@ spnfs_test_layoutrecall(char *path, u64 offset, u64 len)
 
 	rc = spnfs_layoutrecall(inode, type, offset, len);
 
-	if (type != RECALL_ALL)
+	if (type != RETURN_ALL)
 		path_put(&nd.path);
 	return rc;
 }
-- 
1.6.5.1


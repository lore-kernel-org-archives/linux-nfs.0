Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933958Ab1CXT1b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2011 15:27:31 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] NFSv4.1 pnfs_layoutcommit_inode fixes
Date: Sat, 12 Mar 2011 02:58:09 -0500
Message-Id: <1299916690-2595-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Test NFS_INO_LAYOUTCOMMIT before kzalloc
Mark inode dirty to retry LAYOUTCOMMIT on kzalloc failure.
Add comments.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   30 +++++++++++++++++++-----------
 1 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2a08ca0..ac71125 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -982,6 +982,14 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 }
 EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
 
+/*
+ * For the LAYOUT4_NFSV4_1_FILES layout type, NFS_DATA_SYNC WRITEs and
+ * NFS_UNSTABLE WRITEs with a COMMIT to data servers must store enough
+ * data to disk to allow the server to recover the data if it crashes.
+ * LAYOUTCOMMIT is only needed when the NFL4_UFLG_COMMIT_THRU_MDS flag
+ * is off, and a COMMIT is sent to a data server, or
+ * if WRITEs to a data server return NFS_DATA_SYNC.
+ */
 int
 pnfs_layoutcommit_inode(struct inode *inode, int sync)
 {
@@ -994,10 +1002,18 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 
 	dprintk("--> %s inode %lu\n", __func__, inode->i_ino);
 
+	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
+		return 0;
+
 	/* Note kzalloc ensures data->res.seq_res.sr_slot == NULL */
 	data = kzalloc(sizeof(*data), GFP_NOFS);
-	spin_lock(&inode->i_lock);
+	if (!data) {
+		mark_inode_dirty_sync(inode);
+		status = -ENOMEM;
+		goto out;
+	}
 
+	spin_lock(&inode->i_lock);
 	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		spin_unlock(&inode->i_lock);
 		kfree(data);
@@ -1014,16 +1030,8 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	lseg->pls_end_pos = 0;
 	lseg->pls_lc_cred = NULL;
 
-	if (!data) {
-		put_lseg(lseg);
-		spin_unlock(&inode->i_lock);
-		put_rpccred(cred);
-		status = -ENOMEM;
-		goto out;
-	} else {
-		memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
-			sizeof(nfsi->layout->plh_stateid.data));
-	}
+	memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
+		sizeof(nfsi->layout->plh_stateid.data));
 	spin_unlock(&inode->i_lock);
 
 	data->args.inode = inode;
-- 
1.6.6


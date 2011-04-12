From: Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] Don't mark_inode_dirty_sync() while holding lock
Date: Tue, 12 Apr 2011 17:17:08 -0400
Message-ID: <1302643028-76672-1-git-send-email-dros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
To: andros@netapp.com, trond@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.netapp.com ([216.240.18.38]:47200 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932568Ab1DLV1h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2011 17:27:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mark_inode_dirty_sync() grabs the same inode lock!

race conditions between holding the lock in pnfs_set_layoutcommit() and in
mark_inode_dirty_sync() can result in a second call to pnfs_layoutcommit_inode(), but
this will be a noop as NFS_INO_LAYOUTCOMMIT won't be set in the second call
---
 fs/nfs/pnfs.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d9ab972..d71997e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1004,6 +1004,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 {
 	struct nfs_inode *nfsi = NFS_I(wdata->inode);
 	loff_t end_pos = wdata->args.offset + wdata->res.count;
+	int mark_as_dirty = false;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
@@ -1011,13 +1012,18 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 		get_lseg(wdata->lseg);
 		wdata->lseg->pls_lc_cred =
 			get_rpccred(wdata->args.context->state->owner->so_cred);
-		mark_inode_dirty_sync(wdata->inode);
+		mark_as_dirty = true;
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
 	if (end_pos > wdata->lseg->pls_end_pos)
 		wdata->lseg->pls_end_pos = end_pos;
 	spin_unlock(&nfsi->vfs_inode.i_lock);
+
+	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
+	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
+	if (mark_as_dirty)
+		mark_inode_dirty_sync(wdata->inode);
 }
 EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
 
-- 
1.7.4.2


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15947 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757078Ab1FQUUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2011 16:20:54 -0400
Message-ID: <4DFBB71F.3050703@panasas.com>
Date: Fri, 17 Jun 2011 16:20:47 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] FIXME: pnfs: BUG in layout_commit logic
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


When segments are used with the pnfs-objects driver (which supports them)
I get a crash in layout commit do to unbalanced lseg reference counting.
(under reference)

With this patch taken from the blocks layout part of the patchset this
problem goes away. But looking at the code it looks scary to me
(I just don't understand it fully).

Fred please review this code, to see if you like what it does.

I will need a fix for the v3.0 Kernel

SOB: Boaz
---
 fs/nfs/pnfs.c |   21 ++++++++++++++++++---
 fs/nfs/pnfs.h |    1 +
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5fc2e5d..cf048c0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1246,10 +1246,19 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
 {
 	struct pnfs_layout_segment *lseg, *rv = NULL;
+	loff_t max_pos = 0;
+
+	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
+		if (lseg->pls_range.iomode == IOMODE_RW) {
+			if (max_pos < lseg->pls_end_pos)
+				max_pos = lseg->pls_end_pos;
+			if (test_and_clear_bit
+			    (NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
+				rv = lseg;
+		}
+	}
+	rv->pls_end_pos = max_pos;
 
-	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
-		if (lseg->pls_range.iomode == IOMODE_RW)
-			rv = lseg;
 	return rv;
 }
 
@@ -1258,21 +1267,27 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 {
 	struct nfs_inode *nfsi = NFS_I(wdata->inode);
 	loff_t end_pos = wdata->mds_offset + wdata->res.count;
+	loff_t isize = i_size_read(wdata->inode);
 	bool mark_as_dirty = false;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		/* references matched in nfs4_layoutcommit_release */
 		get_lseg(wdata->lseg);
+		set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags);
 		wdata->lseg->pls_lc_cred =
 			get_rpccred(wdata->args.context->state->owner->so_cred);
 		mark_as_dirty = true;
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
+	if (end_pos > isize)
+		end_pos = isize;
 	if (end_pos > wdata->lseg->pls_end_pos)
 		wdata->lseg->pls_end_pos = end_pos;
 	spin_unlock(&nfsi->vfs_inode.i_lock);
+	dprintk("%s: lseg %p end_pos %llu\n",
+		__func__, wdata->lseg, wdata->lseg->pls_end_pos);
 
 	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
 	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e46edac..4a30e81 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -36,6 +36,7 @@
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
 	NFS_LSEG_ROC,		/* roc bit received from server */
+	NFS_LSEG_LAYOUTCOMMIT,	/* layoutcommit bit set for layoutcommit */
 };
 
 struct pnfs_layout_segment {
-- 
1.7.3.4


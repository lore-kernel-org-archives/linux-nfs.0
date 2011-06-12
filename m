Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60566 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246Ab1FLXnz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:43:55 -0400
Message-Id: <9f228c643de1f0378835d6ec9a493c1320bf001d.1307921137.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:43:52 -0400
Subject: [PATCH 03/34] pnfs: let layoutcommit code handle multiple segments
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Some layout driver like block will have multiple segments.
Generic code should be able to handle it.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |   17 +++++++++++++----
 fs/nfs/pnfs.h |    1 +
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e3d618b..f03a5e0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -892,7 +892,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Begin\n", __func__);
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
-	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
+	list_for_each_entry_reverse(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(&lseg->pls_range, range)) {
 			ret = get_lseg(lseg);
@@ -1193,10 +1193,18 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
 {
 	struct pnfs_layout_segment *lseg, *rv = NULL;
+	loff_t max_pos = 0;
+
+	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
+		if (lseg->pls_range.iomode == IOMODE_RW) {
+			if (max_pos < lseg->pls_end_pos)
+				max_pos = lseg->pls_end_pos;
+			if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
+				rv = lseg;
+		}
+	}
+	rv->pls_end_pos = max_pos;
 
-	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
-		if (lseg->pls_range.iomode == IOMODE_RW)
-			rv = lseg;
 	return rv;
 }
 
@@ -1211,6 +1219,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		/* references matched in nfs4_layoutcommit_release */
 		get_lseg(wdata->lseg);
+		set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags);
 		wdata->lseg->pls_lc_cred =
 			get_rpccred(wdata->args.context->state->owner->so_cred);
 		mark_as_dirty = true;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b071b56..a3fc0f2 100644
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
1.7.4.1


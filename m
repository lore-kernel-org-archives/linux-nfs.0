Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:51944 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab1FNCcJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:09 -0400
Message-Id: <127e82691f1eae9352d2aaf2af361fcfe397e0e0.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 03/33] pnfs: let layoutcommit code handle multiple segments
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:32:06 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Some layout driver like block will have multiple segments.
Generic code should be able to handle it.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |   18 ++++++++++++++----
 fs/nfs/pnfs.h |    1 +
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 593a9aa..e252af1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -893,7 +893,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Begin\n", __func__);
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
-	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
+	list_for_each_entry_reverse(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(&lseg->pls_range, range)) {
 			ret = get_lseg(lseg);
@@ -1243,10 +1243,19 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
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
 
@@ -1261,6 +1270,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		/* references matched in nfs4_layoutcommit_release */
 		get_lseg(wdata->lseg);
+		set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags);
 		wdata->lseg->pls_lc_cred =
 			get_rpccred(wdata->args.context->state->owner->so_cred);
 		mark_as_dirty = true;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f984598..0ac820f 100644
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


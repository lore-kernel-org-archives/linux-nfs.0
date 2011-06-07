Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52469 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521Ab1FGR0J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:26:09 -0400
Date: Tue, 7 Jun 2011 13:26:07 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 02/88] pnfs: let layoutcommit code handle multiple segments
Message-ID: <6780b1db4de61a8acb9596df53f339da29d9e246.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Some layout driver like block will have multiple segments.
Generic code should be able to handle it.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |   15 ++++++++++++---
 fs/nfs/pnfs.h |    1 +
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3b182cc..12b228a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1206,10 +1206,18 @@ void pnfs_cleanup_layoutcommit(struct inode *inode,
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
 
@@ -1224,6 +1232,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		/* references matched in nfs4_layoutcommit_release */
 		get_lseg(wdata->lseg);
+		set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags);
 		wdata->lseg->pls_lc_cred =
 			get_rpccred(wdata->args.context->state->owner->so_cred);
 		mark_as_dirty = true;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b8548d8..b3481e5 100644
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


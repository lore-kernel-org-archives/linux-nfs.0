Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50818 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108Ab1FGRar (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:30:47 -0400
Date: Tue, 7 Jun 2011 13:30:44 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 40/88] SQAUSHME: blocklayoutdriver: NULL pointer reference
 when committing too many extents
Message-ID: <b645b267ac464fba8b8dccf6f0389e2e2767d6d8.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Zhang Jingwang <yyalone@gmail.com>

If there are too many extents to commit, xdr buffer will be used up.

So we check the return value and encode as many extents as possible to xdr buffer, leaving the rest in the bl_commit list.

Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/extents.c |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 98452ca..09a7c5c 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -745,7 +745,7 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 {
 	sector_t start, end;
 	struct pnfs_block_short_extent *lce, *save;
-	unsigned int count;
+	unsigned int count = 0;
 	struct bl_layoutupdate_data *bld = arg->layoutdriver_data;
 	struct list_head *ranges = &bld->ranges;
 	__be32 *p, *xdr_start;
@@ -760,29 +760,32 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 	 * entire block to be marked WRITTEN before it can be added.
 	 */
 	spin_lock(&bl->bl_ext_lock);
-	list_splice_init(&bl->bl_commit, ranges);
-	count = bl->bl_count;
-	bl->bl_count = 0;
 	/* Want to adjust for possible truncate */
 	/* We now want to adjust argument range */
-	spin_unlock(&bl->bl_ext_lock);
 
-	dprintk("%s found %i ranges\n", __func__, count);
 	/* XDR encode the ranges found */
-	xdr_start = p = xdr_reserve_space(xdr, 8);
-	p++;
-	WRITE32(count);
-	list_for_each_entry_safe(lce, save, ranges, bse_node) {
+	xdr_start = xdr_reserve_space(xdr, 8);
+	if (!xdr_start)
+		goto out;
+	list_for_each_entry_safe(lce, save, &bl->bl_commit, bse_node) {
 		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
-
+		if (!p)
+			break;
 		WRITE_DEVID(&lce->bse_devid);
 		WRITE64(lce->bse_f_offset << 9);
 		WRITE64(lce->bse_length << 9);
 		WRITE64(0LL);
 		WRITE32(PNFS_BLOCK_READWRITE_DATA);
+		list_del(&lce->bse_node);
+		list_add_tail(&lce->bse_node, ranges);
+		bl->bl_count--;
+		count++;
 	}
-
-	*xdr_start = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
+	xdr_start[0] = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
+	xdr_start[1] = cpu_to_be32(count);
+out:
+	spin_unlock(&bl->bl_ext_lock);
+	dprintk("%s found %i ranges\n", __func__, count);
 	return 0;
 }
 
-- 
1.7.4.1


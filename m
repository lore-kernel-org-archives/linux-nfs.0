Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51203 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbaHUQH6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:58 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUu5-0000B2-Np
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:57 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 17/19] pnfs/blocklayout: implement the return_range method
Date: Thu, 21 Aug 2014 11:09:33 -0500
Message-Id: <1408637375-11343-18-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This allows removing extents from the extent tree especially on truncate
operations, and thus fixing reads from truncated and re-extended that
previously returned stale data.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 42b6f9c..a7524c4 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -470,6 +470,35 @@ static struct pnfs_layout_segment *bl_alloc_lseg(struct pnfs_layout_hdr *lo,
 }
 
 static void
+bl_return_range(struct pnfs_layout_hdr *lo,
+		struct pnfs_layout_range *range)
+{
+	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
+	sector_t offset = range->offset >> SECTOR_SHIFT, end;
+	int err;
+
+	if (range->offset % 8) {
+		dprintk("%s: offset %lld not block size aligned\n",
+			__func__, range->offset);
+		return;
+	}
+
+	if (range->length != NFS4_MAX_UINT64) {
+		if (range->length % 8) {
+			dprintk("%s: length %lld not block size aligned\n",
+				__func__, range->length);
+			return;
+		}
+
+		end = offset + (range->length >> SECTOR_SHIFT);
+	} else {
+		end = round_down(NFS4_MAX_UINT64, PAGE_SIZE);
+	}
+
+	err = ext_tree_remove(bl, range->iomode & IOMODE_RW, offset, end);
+}
+
+static void
 bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
 		       const struct nfs4_layoutcommit_args *arg)
 {
@@ -777,6 +806,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.free_layout_hdr		= bl_free_layout_hdr,
 	.alloc_lseg			= bl_alloc_lseg,
 	.free_lseg			= bl_free_lseg,
+	.return_range			= bl_return_range,
 	.encode_layoutcommit		= bl_encode_layoutcommit,
 	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
 	.set_layoutdriver		= bl_set_layoutdriver,
-- 
1.9.1


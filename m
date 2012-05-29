Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56796 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab2E2EjW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 00:39:22 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so5401164pbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 21:39:22 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v2 1/3] pnfsblock: bail out partial block direct write
Date: Tue, 29 May 2012 12:38:52 +0800
Message-Id: <1338266334-11490-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1338266334-11490-1-git-send-email-bergwolf@gmail.com>
References: <1338266334-11490-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index dd392ed..bab432f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -572,10 +572,13 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	u64 temp;
 	int npg_per_block =
 	    NFS_SERVER(header->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
+	unsigned long blkmask = PAGE_CACHE_MASK;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
 	/* Check for alignment first */
-	if (!bl_check_alignment(offset, count, PAGE_CACHE_MASK))
+	if (header->dreq)
+		blkmask = NFS_SERVER(header->inode)->pnfs_blksize - 1;
+	if (!bl_check_alignment(offset, count, blkmask))
 		goto out_mds;
 
 	/* At this point, wdata->pages is a (sequential) list of nfs_pages.
@@ -1023,7 +1026,15 @@ bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 static void
 bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
-	if (!bl_check_alignment(req->wb_offset, req->wb_bytes, PAGE_CACHE_MASK))
+	if (pgio->pg_dreq) {
+		/* Direct write should be blksize aligned */
+		unsigned blkmask = NFS_SERVER(pgio->pg_inode)->pnfs_blksize - 1;
+		u64 pos = (req->wb_index << PAGE_CACHE_SHIFT) + req->wb_bytes;
+		if (!bl_check_alignment(pos, 0, blkmask) ||
+		    req->wb_bytes != PAGE_CACHE_SIZE)
+			nfs_pageio_reset_write_mds(pgio);
+	} else if (!bl_check_alignment(req->wb_offset, req->wb_bytes,
+				       PAGE_CACHE_MASK))
 		nfs_pageio_reset_write_mds(pgio);
 	else
 		pnfs_generic_pg_init_write(pgio, req);
-- 
1.7.1.262.g5ef3d


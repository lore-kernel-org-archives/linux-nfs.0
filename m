Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:43629 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab2HWQ2v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2012 12:28:51 -0400
Received: by mail-pz0-f46.google.com with SMTP id y13so493174dad.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2012 09:28:50 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH-resend 6/6] pnfsblock: fix non-aligned DIO write
Date: Fri, 24 Aug 2012 00:27:53 +0800
Message-Id: <1345739273-2241-7-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1345739273-2241-1-git-send-email-bergwolf@gmail.com>
References: <1345739273-2241-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For DIO writes, if it is not blocksize aligned, we need to do
internal serialization. It may slow down writers anyway. So we
just bail them out and resend to MDS.

Cc: stable <stable@vger.kernel.org> [since v3.4]
Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   34 +++++++++++++++++++++++++++++++---
 1 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e5dfef5..1093968 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -685,7 +685,7 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	struct bio *bio = NULL;
 	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
 	sector_t isect, last_isect = 0, extent_length = 0;
-	struct parallel_io *par;
+	struct parallel_io *par = NULL;
 	loff_t offset = wdata->args.offset;
 	size_t count = wdata->args.count;
 	unsigned int pg_offset, pg_len, saved_len;
@@ -697,6 +697,13 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	    NFS_SERVER(header->inode)->pnfs_blksize >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
+
+	if (header->dreq != NULL &&
+	    (!IS_ALIGNED(offset, NFS_SERVER(header->inode)->pnfs_blksize) ||
+	     !IS_ALIGNED(count, NFS_SERVER(header->inode)->pnfs_blksize))) {
+		dprintk("pnfsblock nonblock aligned DIO writes. Resend MDS\n");
+		goto out_mds;
+	}
 	/* At this point, wdata->pages is a (sequential) list of nfs_pages.
 	 * We want to write each, and if there is an error set pnfs_error
 	 * to have it redone using nfs.
@@ -1197,6 +1204,27 @@ bl_pg_test_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
 
+void
+bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	if (pgio->pg_dreq != NULL &&
+	    !is_aligned_req(req, PAGE_CACHE_SIZE))
+		nfs_pageio_reset_write_mds(pgio);
+	else
+		pnfs_generic_pg_init_write(pgio, req);
+}
+
+static bool
+bl_pg_test_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
+		 struct nfs_page *req)
+{
+	if (pgio->pg_dreq != NULL &&
+	    !is_aligned_req(req, PAGE_CACHE_SIZE))
+		return false;
+
+	return pnfs_generic_pg_test(pgio, prev, req);
+}
+
 static const struct nfs_pageio_ops bl_pg_read_ops = {
 	.pg_init = bl_pg_init_read,
 	.pg_test = bl_pg_test_read,
@@ -1204,8 +1232,8 @@ static const struct nfs_pageio_ops bl_pg_read_ops = {
 };
 
 static const struct nfs_pageio_ops bl_pg_write_ops = {
-	.pg_init = pnfs_generic_pg_init_write,
-	.pg_test = pnfs_generic_pg_test,
+	.pg_init = bl_pg_init_write,
+	.pg_test = bl_pg_test_write,
 	.pg_doio = pnfs_generic_pg_writepages,
 };
 
-- 
1.7.1.262.g5ef3d


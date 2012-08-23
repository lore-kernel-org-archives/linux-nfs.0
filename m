Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:43629 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910Ab2HWQ2r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2012 12:28:47 -0400
Received: by mail-pz0-f46.google.com with SMTP id y13so493174dad.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2012 09:28:46 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH-resend 5/6] pnfsblock: fix non-aligned DIO read
Date: Fri, 24 Aug 2012 00:27:52 +0800
Message-Id: <1345739273-2241-6-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1345739273-2241-1-git-send-email-bergwolf@gmail.com>
References: <1345739273-2241-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For DIO read, if it is not sector aligned, we should reject it
and resend via MDS. Otherwise there might be data corruption.
Also teach bl_read_pagelist to handle partial page reads for DIO.

Cc: stable <stable@vger.kernel.org> [since v3.4]
Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   64 +++++++++++++++++++++++++++++++++-----
 1 files changed, 56 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 39fa002..e5dfef5 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -252,8 +252,11 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 	sector_t isect, extent_length = 0;
 	struct parallel_io *par;
 	loff_t f_offset = rdata->args.offset;
+	size_t bytes_left = rdata->args.count;
+	unsigned int pg_offset, pg_len;
 	struct page **pages = rdata->args.pages;
 	int pg_index = rdata->args.pgbase >> PAGE_CACHE_SHIFT;
+	const bool is_dio = (header->dreq != NULL);
 
 	dprintk("%s enter nr_pages %u offset %lld count %u\n", __func__,
 	       rdata->pages.npages, f_offset, (unsigned int)rdata->args.count);
@@ -287,36 +290,53 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 				extent_length = min(extent_length, cow_length);
 			}
 		}
+
+		if (is_dio) {
+			pg_offset = f_offset & ~PAGE_CACHE_MASK;
+			if (pg_offset + bytes_left > PAGE_CACHE_SIZE)
+				pg_len = PAGE_CACHE_SIZE - pg_offset;
+			else
+				pg_len = bytes_left;
+
+			f_offset += pg_len;
+			bytes_left -= pg_len;
+			isect += (pg_offset >> SECTOR_SHIFT);
+		} else {
+			pg_offset = 0;
+			pg_len = PAGE_CACHE_SIZE;
+		}
+
 		hole = is_hole(be, isect);
 		if (hole && !cow_read) {
 			bio = bl_submit_bio(READ, bio);
 			/* Fill hole w/ zeroes w/o accessing device */
 			dprintk("%s Zeroing page for hole\n", __func__);
-			zero_user_segment(pages[i], 0, PAGE_CACHE_SIZE);
+			zero_user_segment(pages[i], pg_offset, pg_len);
 			print_page(pages[i]);
 			SetPageUptodate(pages[i]);
 		} else {
 			struct pnfs_block_extent *be_read;
 
 			be_read = (hole && cow_read) ? cow_read : be;
-			bio = bl_add_page_to_bio(bio, rdata->pages.npages - i,
+			bio = do_add_page_to_bio(bio, rdata->pages.npages - i,
 						 READ,
 						 isect, pages[i], be_read,
-						 bl_end_io_read, par);
+						 bl_end_io_read, par,
+						 pg_offset, pg_len);
 			if (IS_ERR(bio)) {
 				header->pnfs_error = PTR_ERR(bio);
 				bio = NULL;
 				goto out;
 			}
 		}
-		isect += PAGE_CACHE_SECTORS;
+		isect += (pg_len >> SECTOR_SHIFT);
 		extent_length -= PAGE_CACHE_SECTORS;
 	}
 	if ((isect << SECTOR_SHIFT) >= header->inode->i_size) {
 		rdata->res.eof = 1;
-		rdata->res.count = header->inode->i_size - f_offset;
+		rdata->res.count = header->inode->i_size - rdata->args.offset;
 	} else {
-		rdata->res.count = (isect << SECTOR_SHIFT) - f_offset;
+		rdata->res.count = (isect << SECTOR_SHIFT) - rdata->args.offset;
 	}
 out:
 	bl_put_extent(be);
@@ -1149,9 +1169,37 @@ bl_clear_layoutdriver(struct nfs_server *server)
 	return 0;
 }
 
+static bool
+is_aligned_req(struct nfs_page *req, unsigned int alignment)
+{
+	return IS_ALIGNED(req->wb_offset, alignment) &&
+	       IS_ALIGNED(req->wb_bytes, alignment);
+}
+
+static void
+bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	if (pgio->pg_dreq != NULL &&
+	    !is_aligned_req(req, SECTOR_SIZE))
+		nfs_pageio_reset_read_mds(pgio);
+	else
+		pnfs_generic_pg_init_read(pgio, req);
+}
+
+static bool
+bl_pg_test_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
+		struct nfs_page *req)
+{
+	if (pgio->pg_dreq != NULL &&
+	    !is_aligned_req(req, SECTOR_SIZE))
+		return false;
+
+	return pnfs_generic_pg_test(pgio, prev, req);
+}
+
 static const struct nfs_pageio_ops bl_pg_read_ops = {
-	.pg_init = pnfs_generic_pg_init_read,
-	.pg_test = pnfs_generic_pg_test,
+	.pg_init = bl_pg_init_read,
+	.pg_test = bl_pg_test_read,
 	.pg_doio = pnfs_generic_pg_readpages,
 };
 
-- 
1.7.1.262.g5ef3d


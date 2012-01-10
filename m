Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44137 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756314Ab2AJOcW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jan 2012 09:32:22 -0500
Received: by mail-iy0-f174.google.com with SMTP id z25so965522iab.19
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2012 06:32:22 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <peng_tao@emc.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH RESEND 3/9] pnfsblock: move find lock page logic out of bl_write_pagelist
Date: Tue, 10 Jan 2012 22:30:29 +0800
Message-Id: <1326205835-2011-4-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
References: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also avoid unnecessary lock_page if page is handled by others.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |   78 ++++++++++++++++++++++++++------------
 1 files changed, 54 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 4ced0b0..c83ad70 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -484,6 +484,55 @@ cleanup:
 	return ret;
 }
 
+/* Find or create a zeroing page marked being writeback.
+ * Return ERR_PTR on error, NULL to indicate skip this page and page itself
+ * to indicate write out.
+ */
+static struct page *
+bl_find_get_zeroing_page(struct inode *inode, pgoff_t index,
+			struct pnfs_block_extent *cow_read)
+{
+	struct page *page;
+	int locked = 0;
+	page = find_get_page(inode->i_mapping, index);
+	if (page)
+		goto check_page;
+
+	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
+	if (unlikely(!page)) {
+		dprintk("%s oom\n", __func__);
+		return ERR_PTR(-ENOMEM);
+	}
+	locked = 1;
+
+check_page:
+	/* PageDirty: Other will write this out
+	 * PageWriteback: Other is writing this out
+	 * PageUptodate: It was read before
+	 */
+	if (PageDirty(page) || PageWriteback(page)) {
+		print_page(page);
+		if (locked)
+			unlock_page(page);
+		page_cache_release(page);
+		return NULL;
+	}
+
+	if (!locked) {
+		lock_page(page);
+		locked = 1;
+		goto check_page;
+	}
+	if (!PageUptodate(page)) {
+		/* New page, readin or zero it */
+		init_page_for_write(page, cow_read);
+	}
+	set_page_writeback(page);
+	unlock_page(page);
+
+	return page;
+}
+
 static enum pnfs_try_status
 bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 {
@@ -543,32 +592,13 @@ fill_invalid_ext:
 			dprintk("%s zero %dth page: index %lu isect %llu\n",
 				__func__, npg_zero, index,
 				(unsigned long long)isect);
-			page =
-			    find_or_create_page(wdata->inode->i_mapping, index,
-						GFP_NOFS);
-			if (!page) {
-				dprintk("%s oom\n", __func__);
-				wdata->pnfs_error = -ENOMEM;
+			page = bl_find_get_zeroing_page(wdata->inode, index,
+							cow_read);
+			if (unlikely(IS_ERR(page))) {
+				wdata->pnfs_error = PTR_ERR(page);
 				goto out;
-			}
-
-			/* PageDirty: Other will write this out
-			 * PageWriteback: Other is writing this out
-			 * PageUptodate: It was read before
-			 * sector_initialized: already written out
-			 */
-			if (PageDirty(page) || PageWriteback(page)) {
-				print_page(page);
-				unlock_page(page);
-				page_cache_release(page);
+			} else if (page == NULL)
 				goto next_page;
-			}
-			if (!PageUptodate(page)) {
-				/* New page, readin or zero it */
-				init_page_for_write(page, cow_read);
-			}
-			set_page_writeback(page);
-			unlock_page(page);
 
 			ret = bl_mark_sectors_init(be->be_inval, isect,
 						       PAGE_CACHE_SECTORS);
-- 
1.7.1.262.g5ef3d


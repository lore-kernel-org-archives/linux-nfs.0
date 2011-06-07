Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53745 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab1FGR3b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:29:31 -0400
Date: Tue, 7 Jun 2011 13:29:29 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 31/88] pnfsblock: write_end_cleanup
Message-ID: <c229ed79ddc16ccff286f77018c5912bf30c83ed.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Ensure all pages in block are marked for initialization if needed.

[pnfsblock: Update to 2.6.29]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   59 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index f4851c1..af26bcc 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -835,6 +835,64 @@ bl_write_end(struct inode *inode, struct page *page, loff_t pos,
 	return 0;
 }
 
+/* Return any memory allocated to fsdata->private, and take advantage
+ * of no page locks to mark pages noted in write_begin as needing
+ * initialization.
+ */
+static void
+bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
+{
+	struct page *page;
+	pgoff_t index;
+	sector_t *pos;
+	struct address_space *mapping = filp->f_mapping;
+	struct pnfs_fsdata *fake_data;
+
+	if (!fsdata)
+		return;
+	pos = fsdata->private;
+	if (!pos)
+		return;
+	dprintk("%s enter with pos=%llu\n", __func__, (u64)(*pos));
+	for (; *pos != ~0; pos++) {
+		index = *pos >> (PAGE_CACHE_SHIFT - 9);
+		/* XXX How do we properly deal with failures here??? */
+		page = grab_cache_page_write_begin(mapping, index, 0);
+		if (!page) {
+			printk(KERN_ERR "%s BUG BUG BUG NoMem\n", __func__);
+			continue;
+		}
+		dprintk("%s: Examining block page\n", __func__);
+		print_page(page);
+		if (!PageMappedToDisk(page)) {
+			/* XXX How do we properly deal with failures here??? */
+			dprintk("%s Marking block page\n", __func__);
+			init_page_for_write(BLK_LSEG2EXT(fsdata->lseg), page,
+					    PAGE_CACHE_SIZE, PAGE_CACHE_SIZE,
+					    NULL);
+			print_page(page);
+			fake_data = kzalloc(sizeof(*fake_data), GFP_KERNEL);
+			if (!fake_data) {
+				printk(KERN_ERR "%s BUG BUG BUG NoMem\n",
+				       __func__);
+				unlock_page(page);
+				continue;
+			}
+			fake_data->ok_to_use_pnfs = 1;
+			fake_data->bypass_eof = 1;
+			mapping->a_ops->write_end(filp, mapping,
+						  index << PAGE_CACHE_SHIFT,
+						  PAGE_CACHE_SIZE,
+						  PAGE_CACHE_SIZE,
+						  page, fake_data);
+			/* Note fake_data is freed by nfs_write_end */
+		} else
+			unlock_page(page);
+	}
+	kfree(fsdata->private);
+	fsdata->private = NULL;
+}
+
 static ssize_t
 bl_get_stripesize(struct pnfs_layout_type *lo)
 {
@@ -880,6 +938,7 @@ static struct layoutdriver_io_operations blocklayout_io_operations = {
 	.write_pagelist			= bl_write_pagelist,
 	.write_begin			= bl_write_begin,
 	.write_end			= bl_write_end,
+	.write_end_cleanup		= bl_write_end_cleanup,
 	.alloc_layout			= bl_alloc_layout,
 	.free_layout			= bl_free_layout,
 	.alloc_lseg			= bl_alloc_lseg,
-- 
1.7.4.1


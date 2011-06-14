Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:52079 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab1FNCdN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:33:13 -0400
Message-Id: <6aae9ba685f74c3715543b84f647142d53c87c07.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 28/33] pnfsblock: write_end_cleanup
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:33:11 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Ensure all pages in block are marked for initialization if needed.

[pnfsblock: Update to 2.6.29]
[pnfsblock: write_end_cleanup adjust for removed ok_to_use_pnfs]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   54 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index dff5e69..cbf74d8 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -791,6 +791,60 @@ bl_write_end(struct inode *inode, struct page *page, loff_t pos,
 static void
 bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
 {
+	struct page *page;
+	pgoff_t index;
+	sector_t *pos;
+	struct address_space *mapping = filp->f_mapping;
+	struct pnfs_fsdata *fake_data;
+	struct pnfs_layout_segment *lseg;
+
+	if (!fsdata)
+		return;
+	lseg = fsdata->lseg;
+	if (!lseg)
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
+			get_lseg(lseg);
+			fake_data->lseg = lseg;
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
 }
 
 static struct pnfs_layoutdriver_type blocklayout_type = {
-- 
1.7.4.1


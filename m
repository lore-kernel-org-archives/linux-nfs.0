Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:65416 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab2HHCDd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Aug 2012 22:03:33 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr13so617318pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Aug 2012 19:03:33 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: bharrosh@panasas.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH RFC 2/3] NFS41: send real write size in layoutget
Date: Wed,  8 Aug 2012 10:03:11 +0800
Message-Id: <1344391392-1948-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@emc.com>

For bufferred write, scan dirty pages to find out longest continuous
dirty pages. In this case, also allow layout driver to specify a
maximum layoutget size which is useful to avoid busy scanning dirty pages
for block layout client.

For direct write, just use dreq->bytes_left.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/direct.c   |    7 ++++++
 fs/nfs/internal.h |    1 +
 fs/nfs/pnfs.c     |   58 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index c39f775..c1899dd 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -46,6 +46,7 @@
 #include <linux/kref.h>
 #include <linux/slab.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/module.h>
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
@@ -191,6 +192,12 @@ static void nfs_direct_req_release(struct nfs_direct_req *dreq)
 	kref_put(&dreq->kref, nfs_direct_req_free);
 }
 
+ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq)
+{
+	return dreq->bytes_left;
+}
+EXPORT_SYMBOL_GPL(nfs_dreq_bytes_left);
+
 /*
  * Collects and returns the final error value/byte-count.
  */
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31fdb03..e68d329 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -464,6 +464,7 @@ static inline void nfs_inode_dio_wait(struct inode *inode)
 {
 	inode_dio_wait(inode);
 }
+extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
 
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2e00fea..e61a373 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -29,6 +29,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/pagevec.h>
 #include <linux/module.h>
 #include "internal.h"
 #include "pnfs.h"
@@ -1172,19 +1173,72 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
 
+/*
+ * Return the number of contiguous bytes in dirty pages for a given inode
+ * starting at page frame idx.
+ */
+static u64 pnfs_num_dirty_bytes(struct inode *inode, pgoff_t idx)
+{
+	struct address_space *mapping = inode->i_mapping;
+	pgoff_t	index;
+	struct pagevec pvec;
+	pgoff_t num = 1; /* self */
+	int i, done = 0;
+
+	pagevec_init(&pvec, 0);
+	idx++; /* self */
+	while (!done) {
+		index = idx;
+		pagevec_lookup_tag(&pvec, mapping, &index,
+				   PAGECACHE_TAG_DIRTY, (pgoff_t)PAGEVEC_SIZE);
+		if (pagevec_count(&pvec) == 0)
+			break;
+
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+
+			lock_page(page);
+			if (unlikely(page->mapping != mapping) ||
+			    !PageDirty(page) ||
+			    PageWriteback(page) ||
+			    page->index != idx) {
+				done = 1;
+				unlock_page(page);
+				break;
+			}
+			unlock_page(page);
+			if (done)
+				break;
+			idx++;
+			num++;
+		}
+		pagevec_release(&pvec);
+	}
+	return num << PAGE_CACHE_SHIFT;
+}
+
 void
-pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
+			   struct nfs_page *req)
 {
+	u64 wb_size;
+
 	BUG_ON(pgio->pg_lseg != NULL);
 
 	if (req->wb_offset != req->wb_pgbase) {
 		nfs_pageio_reset_write_mds(pgio);
 		return;
 	}
+
+	if (pgio->pg_dreq == NULL)
+		wb_size = pnfs_num_dirty_bytes(pgio->pg_inode, req->wb_index);
+	else
+		wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
+
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   req_offset(req),
-					   req->wb_bytes,
+					   wb_size?:req->wb_bytes,
 					   IOMODE_RW,
 					   GFP_NOFS);
 	/* If no lseg, fall back to write through mds */
-- 
1.7.1.262.g5ef3d


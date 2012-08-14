Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:38384 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab2HNNyN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 09:54:13 -0400
Received: by ghrr11 with SMTP id r11so450057ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Aug 2012 06:54:13 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: bharrosh@panasas.com, linux-nfs@vger.kernel.org,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v3 2/3] NFS41: send real write size in layoutget
Date: Tue, 14 Aug 2012 21:52:23 +0800
Message-Id: <1344952344-1435-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344952344-1435-1-git-send-email-bergwolf@gmail.com>
References: <1344952344-1435-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For buffer write, block layout client scan inode mapping to find
next hole and use offset-to-hole as layoutget length. Object
layout client uses offset-to-isize as layoutget length.

For direct write, both block layout and object layout use dreq->bytes_left.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   38 +++++++++++++++++++++++++++++++++++---
 fs/nfs/direct.c                  |    7 +++++++
 fs/nfs/internal.h                |    1 +
 fs/nfs/objlayout/objio_osd.c     |    9 ++++++++-
 fs/nfs/pnfs.c                    |    6 ++++--
 fs/nfs/pnfs.h                    |    3 ++-
 6 files changed, 57 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 1093968..2023651 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -37,6 +37,7 @@
 #include <linux/bio.h>		/* struct bio */
 #include <linux/buffer_head.h>	/* various write calls */
 #include <linux/prefetch.h>
+#include <linux/pagevec.h>
 
 #include "../pnfs.h"
 #include "../internal.h"
@@ -1204,14 +1205,45 @@ bl_pg_test_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
 
+/*
+ * Return the number of contiguous bytes for a given inode
+ * starting at page frame idx.
+ */
+static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
+{
+	struct address_space *mapping = inode->i_mapping;
+	pgoff_t end;
+
+	/* Optimize common case that writes from 0 to end of file */
+	end = DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE);
+	if (end != NFS_I(inode)->npages) {
+		rcu_read_lock();
+		end = radix_tree_next_hole(&mapping->page_tree, idx + 1, ULONG_MAX);
+		rcu_read_unlock();
+	}
+
+	if (!end)
+		return i_size_read(inode) - (idx << PAGE_CACHE_SHIFT);
+	else
+		return (end - idx) << PAGE_CACHE_SHIFT;
+}
+
 void
 bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
 	if (pgio->pg_dreq != NULL &&
-	    !is_aligned_req(req, PAGE_CACHE_SIZE))
+	    !is_aligned_req(req, PAGE_CACHE_SIZE)) {
 		nfs_pageio_reset_write_mds(pgio);
-	else
-		pnfs_generic_pg_init_write(pgio, req);
+	} else {
+		u64 wb_size;
+		if (pgio->pg_dreq == NULL)
+			wb_size = pnfs_num_cont_bytes(pgio->pg_inode,
+						      req->wb_index);
+		else
+			wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
+
+		pnfs_generic_pg_init_write(pgio, req, wb_size);
+	}
 }
 
 static bool
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
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index ea6d111..be731e6 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -41,6 +41,7 @@
 #include <scsi/osd_ore.h>
 
 #include "objlayout.h"
+#include "../internal.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
@@ -606,8 +607,14 @@ static bool aligned_on_raid_stripe(u64 offset, struct ore_layout *layout,
 void objio_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
 	unsigned long stripe_end = 0;
+	u64 wb_size;
 
-	pnfs_generic_pg_init_write(pgio, req);
+	if (pgio->pg_dreq == NULL)
+		wb_size = i_size_read(pgio->pg_inode) - req_offset(req);
+	else
+		wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
+
+	pnfs_generic_pg_init_write(pgio, req, wb_size);
 	if (unlikely(pgio->pg_lseg == NULL))
 		return; /* Not pNFS */
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2e00fea..9ff45d1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1173,7 +1173,8 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
 
 void
-pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
+			   struct nfs_page *req, u64 wb_size)
 {
 	BUG_ON(pgio->pg_lseg != NULL);
 
@@ -1181,10 +1182,11 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *
 		nfs_pageio_reset_write_mds(pgio);
 		return;
 	}
+
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   req_offset(req),
-					   req->wb_bytes,
+					   wb_size,
 					   IOMODE_RW,
 					   GFP_NOFS);
 	/* If no lseg, fall back to write through mds */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 745aa1b..5994d48 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -188,7 +188,8 @@ void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
-void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *, struct nfs_page *);
+void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
+			        struct nfs_page *req, u64 wb_size);
 int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
 void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg);
-- 
1.7.1.262.g5ef3d


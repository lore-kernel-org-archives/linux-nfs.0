Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:52880 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586Ab2HMOk1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 10:40:27 -0400
Received: by ghrr11 with SMTP id r11so3057336ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 07:40:27 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v2 2/3] NFS41: send real write size in layoutget
Date: Mon, 13 Aug 2012 22:39:35 +0800
Message-Id: <1344868776-1739-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344868776-1739-1-git-send-email-bergwolf@gmail.com>
References: <1344868776-1739-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For buffer write, use policy based mechanism to determine layoutget size.
Currently files use whole file layout, objects use offset-to-isize, and
blocks search next hole in inode mapping and use offset-to-hole.

For direct write, just use dreq->bytes_left.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |    1 +
 fs/nfs/direct.c                  |    7 +++++
 fs/nfs/internal.h                |    1 +
 fs/nfs/nfs4filelayout.c          |    1 +
 fs/nfs/objlayout/objio_osd.c     |    3 +-
 fs/nfs/pnfs.c                    |   51 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                    |   13 +++++++++
 7 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 1093968..c4215cf 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1240,6 +1240,7 @@ static const struct nfs_pageio_ops bl_pg_write_ops = {
 static struct pnfs_layoutdriver_type blocklayout_type = {
 	.id				= LAYOUT_BLOCK_VOLUME,
 	.name				= "LAYOUT_BLOCK_VOLUME",
+	.flags				= PNFS_LAYOUTGET_SEARCH_HOLE,
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
 	.alloc_layout_hdr		= bl_alloc_layout_hdr,
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
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 53f94d9..f81edd7 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -1289,6 +1289,7 @@ filelayout_get_ds_info(struct inode *inode)
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id			= LAYOUT_NFSV4_1_FILES,
 	.name			= "LAYOUT_NFSV4_1_FILES",
+	.flags			= PNFS_LAYOUTGET_ALL_FILE,
 	.owner			= THIS_MODULE,
 	.alloc_layout_hdr	= filelayout_alloc_layout_hdr,
 	.free_layout_hdr	= filelayout_free_layout_hdr,
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index ea6d111..e487fb8 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -638,7 +638,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
 	.flags                   = PNFS_LAYOUTRET_ON_SETATTR |
-				   PNFS_LAYOUTRET_ON_ERROR,
+				   PNFS_LAYOUTRET_ON_ERROR |
+				   PNFS_LAYOUTGET_ISIZE,
 
 	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
 	.free_layout_hdr         = objlayout_free_layout_hdr,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2e00fea..d1da23a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -29,6 +29,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/pagevec.h>
 #include <linux/module.h>
 #include "internal.h"
 #include "pnfs.h"
@@ -1172,19 +1173,67 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
 
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
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
+	u64 wb_size;
+	unsigned policy = NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->flags &
+						PNFS_LAYOUTGET_POLICY_MASK;
+
 	BUG_ON(pgio->pg_lseg != NULL);
 
 	if (req->wb_offset != req->wb_pgbase) {
 		nfs_pageio_reset_write_mds(pgio);
 		return;
 	}
+
+	if (pgio->pg_dreq == NULL) {
+		switch(policy) {
+		case PNFS_LAYOUTGET_ISIZE:
+			wb_size = i_size_read(pgio->pg_inode) - req_offset(req);
+			break;
+		case PNFS_LAYOUTGET_SEARCH_HOLE:
+			wb_size = pnfs_num_cont_bytes(pgio->pg_inode, req->wb_index);
+			break;
+		case PNFS_LAYOUTGET_ALL_FILE:
+			wb_size = NFS4_MAX_UINT64;
+			break;
+		default:
+			WARN_ONCE(1, "invalid layoutget policy %u", policy);
+			wb_size = PAGE_CACHE_SIZE;
+			break;
+		}
+	} else {
+		wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
+	}
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
index 745aa1b..ce86894 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -71,8 +71,21 @@ enum layoutdriver_policy_flags {
 	/* Should the pNFS client commit and return the layout upon a setattr */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
 	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
+
+	/* Layoutget(write) length policy:
+	 * PNFS_LAYOUTGET_ISIZE, use offset-to-isize
+	 * PNFS_LAYOUTGET_SEARCH_HOLE, use offset-to-hole
+	 * PNFS_LAYOUTGET_ALL_FILE, use NFS4_MAX_UINT64
+	 */
+	PNFS_LAYOUTGET_ISIZE		= 1 << 2,
+	PNFS_LAYOUTGET_SEARCH_HOLE	= 1 << 3,
+	PNFS_LAYOUTGET_ALL_FILE		= 1 << 4,
 };
 
+#define PNFS_LAYOUTGET_POLICY_MASK	(PNFS_LAYOUTGET_ISIZE |		\
+					 PNFS_LAYOUTGET_SEARCH_HOLE |	\
+					 PNFS_LAYOUTGET_ALL_FILE)
+
 struct nfs4_deviceid_node;
 
 /* Per-layout driver specific registration structure */
-- 
1.7.1.262.g5ef3d


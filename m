From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 7/8] pnfs_post_submit: Restore "pnfs: pnfs_modify_new_request"
Date: Sun,  2 May 2010 21:00:48 -0400
Message-ID: <1272848449-19170-8-git-send-email-iisaman@netapp.com>
References: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
 <1272848449-19170-2-git-send-email-iisaman@netapp.com>
 <1272848449-19170-3-git-send-email-iisaman@netapp.com>
 <1272848449-19170-4-git-send-email-iisaman@netapp.com>
 <1272848449-19170-5-git-send-email-iisaman@netapp.com>
 <1272848449-19170-6-git-send-email-iisaman@netapp.com>
 <1272848449-19170-7-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27481 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759143Ab0EEDH7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 23:07:59 -0400
Received: from localhost.localdomain (makada1-lxp.hq.netapp.com [10.58.60.192] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4537cgd024006
	for <linux-nfs@vger.kernel.org>; Tue, 4 May 2010 20:07:44 -0700 (PDT)
In-Reply-To: <1272848449-19170-7-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

pnfs: pnfs_modify_new_request

Add hook into nfs_page initialization to allow for setting of
PG_USE_PNFS.

[pnfs: pass lseg from write_begin to write_end]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c         |    2 ++
 fs/nfs/pnfs.c             |   19 +++++++++++++++++++
 fs/nfs/pnfs.h             |   15 +++++++++++++++
 include/linux/nfs4_pnfs.h |    3 +++
 4 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 3584b6a..3a1d673 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -20,6 +20,7 @@
 #include <linux/nfs_mount.h>
 
 #include "internal.h"
+#include "pnfs.h"
 
 static struct kmem_cache *nfs_page_cachep;
 
@@ -86,6 +87,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
+	pnfs_modify_new_request(req, fsdata);
 	return req;
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ce6ca4b..46fe088 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2245,6 +2245,25 @@ out_unlock:
 	goto out;
 }
 
+/* Note that fsdata != NULL */
+void _pnfs_modify_new_write_request(struct nfs_page *req,
+				    struct pnfs_fsdata *fsdata)
+{
+	struct inode *inode = req->wb_page->mapping->host;
+	struct pnfs_layout_segment *lseg = NULL;
+	loff_t pos;
+	unsigned count;
+
+	pos = ((loff_t)req->wb_index << PAGE_CACHE_SHIFT) + req->wb_offset;
+	count = req->wb_bytes;
+	lseg = pnfs_find_get_lseg(inode, pos, count, IOMODE_RW);
+	if (lseg) {
+		if (fsdata->ok_to_use_pnfs)
+			set_bit(PG_USE_PNFS, &req->wb_flags);
+		put_lseg(lseg);
+	}
+}
+
 void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
 {
 	if (fsdata) {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8d37dfb..1c94984 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -78,6 +78,8 @@ int _pnfs_write_begin(struct inode *inode, struct page *page,
 		      struct pnfs_fsdata **fsdata);
 int _pnfs_do_flush(struct inode *inode, struct nfs_page *req,
 		   struct pnfs_fsdata *fsdata);
+void _pnfs_modify_new_write_request(struct nfs_page *req,
+				    struct pnfs_fsdata *fsdata);
 void _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
 			  size_t count, loff_t loff, int iswrite,
 			  size_t *rwsize, size_t *remaining);
@@ -205,6 +207,14 @@ static inline void pnfs_redirty_request(struct nfs_page *req)
 	clear_bit(PG_USE_PNFS, &req->wb_flags);
 }
 
+static inline void pnfs_modify_new_request(struct nfs_page *req,
+					   void *fsdata)
+{
+	if (fsdata)
+		_pnfs_modify_new_write_request(req, fsdata);
+	/* Should we do something (like set PG_USE_PNFS) if !fsdata ? */
+}
+
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct nfs4_pnfs_layout_segment *lseg,
 				     const nfs4_stateid *stateid, /* optional */
@@ -294,6 +304,11 @@ static inline void pnfs_redirty_request(struct nfs_page *req)
 {
 }
 
+static inline void pnfs_modify_new_request(struct nfs_page *req,
+					   void *fsdata)
+{
+}
+
 static inline int pnfs_get_write_status(struct nfs_write_data *data)
 {
 	return 0;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 1ba0590..e01a065 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -142,6 +142,9 @@ struct layoutdriver_io_operations {
 	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
 			    loff_t pos, unsigned count,
 			    struct pnfs_fsdata *fsdata);
+	void (*new_request)(struct pnfs_layout_segment *lseg,
+			    struct nfs_page *req, loff_t pos, unsigned count,
+			    struct pnfs_fsdata *fsdata);
 
 	/* Consistency ops */
 	/* 2 problems:
-- 
1.6.6.1


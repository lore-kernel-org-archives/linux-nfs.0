From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/8] SQUASHME: pnfs_submit: Revert "pnfs: pnfs_modify_new_request"
Date: Sun,  2 May 2010 21:00:43 -0400
Message-ID: <1272848449-19170-3-git-send-email-iisaman@netapp.com>
References: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
 <1272848449-19170-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755086Ab0EEDH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 23:07:58 -0400
Received: from localhost.localdomain (makada1-lxp.hq.netapp.com [10.58.60.192] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4537cgY024006
	for <linux-nfs@vger.kernel.org>; Tue, 4 May 2010 20:07:40 -0700 (PDT)
In-Reply-To: <1272848449-19170-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 0b10c9be0ad8e2da1f21dafc5e4526b50710c977.

This is not used by the file layout driver.

Conflicts:

	fs/nfs/pnfs.h

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c         |    2 --
 fs/nfs/pnfs.c             |   19 -------------------
 fs/nfs/pnfs.h             |   15 ---------------
 include/linux/nfs4_pnfs.h |    3 ---
 4 files changed, 0 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 3a1d673..3584b6a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -20,7 +20,6 @@
 #include <linux/nfs_mount.h>
 
 #include "internal.h"
-#include "pnfs.h"
 
 static struct kmem_cache *nfs_page_cachep;
 
@@ -87,7 +86,6 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
-	pnfs_modify_new_request(req, fsdata);
 	return req;
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 46fe088..ce6ca4b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2245,25 +2245,6 @@ out_unlock:
 	goto out;
 }
 
-/* Note that fsdata != NULL */
-void _pnfs_modify_new_write_request(struct nfs_page *req,
-				    struct pnfs_fsdata *fsdata)
-{
-	struct inode *inode = req->wb_page->mapping->host;
-	struct pnfs_layout_segment *lseg = NULL;
-	loff_t pos;
-	unsigned count;
-
-	pos = ((loff_t)req->wb_index << PAGE_CACHE_SHIFT) + req->wb_offset;
-	count = req->wb_bytes;
-	lseg = pnfs_find_get_lseg(inode, pos, count, IOMODE_RW);
-	if (lseg) {
-		if (fsdata->ok_to_use_pnfs)
-			set_bit(PG_USE_PNFS, &req->wb_flags);
-		put_lseg(lseg);
-	}
-}
-
 void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
 {
 	if (fsdata) {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1c94984..8d37dfb 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -78,8 +78,6 @@ int _pnfs_write_begin(struct inode *inode, struct page *page,
 		      struct pnfs_fsdata **fsdata);
 int _pnfs_do_flush(struct inode *inode, struct nfs_page *req,
 		   struct pnfs_fsdata *fsdata);
-void _pnfs_modify_new_write_request(struct nfs_page *req,
-				    struct pnfs_fsdata *fsdata);
 void _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
 			  size_t count, loff_t loff, int iswrite,
 			  size_t *rwsize, size_t *remaining);
@@ -207,14 +205,6 @@ static inline void pnfs_redirty_request(struct nfs_page *req)
 	clear_bit(PG_USE_PNFS, &req->wb_flags);
 }
 
-static inline void pnfs_modify_new_request(struct nfs_page *req,
-					   void *fsdata)
-{
-	if (fsdata)
-		_pnfs_modify_new_write_request(req, fsdata);
-	/* Should we do something (like set PG_USE_PNFS) if !fsdata ? */
-}
-
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct nfs4_pnfs_layout_segment *lseg,
 				     const nfs4_stateid *stateid, /* optional */
@@ -304,11 +294,6 @@ static inline void pnfs_redirty_request(struct nfs_page *req)
 {
 }
 
-static inline void pnfs_modify_new_request(struct nfs_page *req,
-					   void *fsdata)
-{
-}
-
 static inline int pnfs_get_write_status(struct nfs_write_data *data)
 {
 	return 0;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index e01a065..1ba0590 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -142,9 +142,6 @@ struct layoutdriver_io_operations {
 	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
 			    loff_t pos, unsigned count,
 			    struct pnfs_fsdata *fsdata);
-	void (*new_request)(struct pnfs_layout_segment *lseg,
-			    struct nfs_page *req, loff_t pos, unsigned count,
-			    struct pnfs_fsdata *fsdata);
 
 	/* Consistency ops */
 	/* 2 problems:
-- 
1.6.6.1


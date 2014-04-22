Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:43052 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758793AbaDVV3C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:29:02 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so68252iec.32
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:29:01 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 03/17] nfs: modify pg_test interface to return size_t
Date: Tue, 22 Apr 2014 17:29:11 -0400
Message-Id: <1398202165-78897-4-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-1-git-send-email-dros@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a step toward allowing pg_test to inform the the
coalescing code to reduce the size of requests so they may fit in
whatever scheme the pg_test callback wants to define.

For now, just return the size of the request if there is space, or 0
if there is not.  This shouldn't change any behavior as it acts
the same as when the pg_test functions returned bool.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/blocklayout/blocklayout.c | 16 ++++++++++++----
 fs/nfs/nfs4filelayout.c          | 12 +++++++-----
 fs/nfs/objlayout/objio_osd.c     | 14 ++++++++++----
 fs/nfs/pagelist.c                | 22 +++++++++++++++++++---
 fs/nfs/pnfs.c                    | 12 +++++++++---
 fs/nfs/pnfs.h                    |  3 ++-
 include/linux/nfs_page.h         |  5 +++--
 7 files changed, 62 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 65d849b..3867976 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1189,13 +1189,17 @@ bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 		pnfs_generic_pg_init_read(pgio, req);
 }
 
-static bool
+/*
+ * Return 0 if @req cannot be coalesced into @pgio, otherwise return the number
+ * of bytes (maximum @req->wb_bytes) that can be coalesced.
+ */
+static size_t
 bl_pg_test_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		struct nfs_page *req)
 {
 	if (pgio->pg_dreq != NULL &&
 	    !is_aligned_req(req, SECTOR_SIZE))
-		return false;
+		return 0;
 
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
@@ -1241,13 +1245,17 @@ bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 	}
 }
 
-static bool
+/*
+ * Return 0 if @req cannot be coalesced into @pgio, otherwise return the number
+ * of bytes (maximum @req->wb_bytes) that can be coalesced.
+ */
+static size_t
 bl_pg_test_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		 struct nfs_page *req)
 {
 	if (pgio->pg_dreq != NULL &&
 	    !is_aligned_req(req, PAGE_CACHE_SIZE))
-		return false;
+		return 0;
 
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b6fc8c1..dfc7282 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -915,10 +915,10 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 /*
  * filelayout_pg_test(). Called by nfs_can_coalesce_requests()
  *
- * return true  : coalesce page
- * return false : don't coalesce page
+ * Return 0 if @req cannot be coalesced into @pgio, otherwise return the number
+ * of bytes (maximum @req->wb_bytes) that can be coalesced.
  */
-static bool
+static size_t
 filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		   struct nfs_page *req)
 {
@@ -927,7 +927,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 
 	if (!pnfs_generic_pg_test(pgio, prev, req) ||
 	    !nfs_generic_pg_test(pgio, prev, req))
-		return false;
+		return 0;
 
 	p_stripe = (u64)req_offset(prev);
 	r_stripe = (u64)req_offset(req);
@@ -936,7 +936,9 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	do_div(p_stripe, stripe_unit);
 	do_div(r_stripe, stripe_unit);
 
-	return (p_stripe == r_stripe);
+	if (p_stripe == r_stripe)
+		return req->wb_bytes;
+	return 0;
 }
 
 static void
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 5457745..c20352a 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -564,14 +564,20 @@ int objio_write_pagelist(struct nfs_write_data *wdata, int how)
 	return 0;
 }
 
-static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
+/*
+ * Return 0 if @req cannot be coalesced into @pgio, otherwise return the number
+ * of bytes (maximum @req->wb_bytes) that can be coalesced.
+ */
+static size_t objio_pg_test(struct nfs_pageio_descriptor *pgio,
 			  struct nfs_page *prev, struct nfs_page *req)
 {
 	if (!pnfs_generic_pg_test(pgio, prev, req))
-		return false;
+		return 0;
 
-	return pgio->pg_count + req->wb_bytes <=
-			(unsigned long)pgio->pg_layout_private;
+	if (pgio->pg_count + req->wb_bytes <=
+	    (unsigned long)pgio->pg_layout_private)
+		return req->wb_bytes;
+	return 0;
 }
 
 static void objio_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ecd34b7..3c35b9e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -277,7 +277,17 @@ nfs_wait_on_request(struct nfs_page *req)
 			TASK_UNINTERRUPTIBLE);
 }
 
-bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
+/*
+ * nfs_generic_pg_test - determine if requests can be coalesced
+ * @desc: pointer to descriptor
+ * @prev: previous request in desc, or NULL
+ * @req: this request
+ *
+ * Returns zero if @req can be coalesced into @desc, otherwise it returns
+ * the size of the request.
+ */
+size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
+			   struct nfs_page *prev, struct nfs_page *req)
 {
 	/*
 	 * FIXME: ideally we should be able to coalesce all requests
@@ -289,7 +299,9 @@ bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *pr
 	if (desc->pg_bsize < PAGE_SIZE)
 		return 0;
 
-	return desc->pg_count + req->wb_bytes <= desc->pg_bsize;
+	if (desc->pg_count + req->wb_bytes <= desc->pg_bsize)
+		return req->wb_bytes;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pg_test);
 
@@ -354,6 +366,8 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 				      struct nfs_page *req,
 				      struct nfs_pageio_descriptor *pgio)
 {
+	size_t size;
+
 	if (!nfs_match_open_context(req->wb_context, prev->wb_context))
 		return false;
 	if (req->wb_context->dentry->d_inode->i_flock != NULL &&
@@ -365,7 +379,9 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 		return false;
 	if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
 		return false;
-	return pgio->pg_ops->pg_test(pgio, prev, req);
+	size = pgio->pg_ops->pg_test(pgio, prev, req);
+	WARN_ON_ONCE(size && size != req->wb_bytes);
+	return size > 0;
 }
 
 /**
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cb53d45..6201bf6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1461,7 +1461,11 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 		nfs_pageio_init(pgio, inode, ld->pg_write_ops, compl_ops, server->wsize, ioflags);
 }
 
-bool
+/*
+ * Return 0 if @req cannot be coalesced into @pgio, otherwise return the number
+ * of bytes (maximum @req->wb_bytes) that can be coalesced.
+ */
+size_t
 pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		     struct nfs_page *req)
 {
@@ -1482,8 +1486,10 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	 * first byte that lies outside the pnfs_layout_range. FIXME?
 	 *
 	 */
-	return req_offset(req) < end_offset(pgio->pg_lseg->pls_range.offset,
-					 pgio->pg_lseg->pls_range.length);
+	if (req_offset(req) < end_offset(pgio->pg_lseg->pls_range.offset,
+					 pgio->pg_lseg->pls_range.length))
+		return req->wb_bytes;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0237939..0386d7c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -192,7 +192,8 @@ int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
 void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			        struct nfs_page *req, u64 wb_size);
 int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
-bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
+size_t pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
+			    struct nfs_page *prev, struct nfs_page *req);
 void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 905809d..214e098 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -46,7 +46,8 @@ struct nfs_page {
 struct nfs_pageio_descriptor;
 struct nfs_pageio_ops {
 	void	(*pg_init)(struct nfs_pageio_descriptor *, struct nfs_page *);
-	bool	(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
+	size_t	(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *,
+			   struct nfs_page *);
 	int	(*pg_doio)(struct nfs_pageio_descriptor *);
 };
 
@@ -89,7 +90,7 @@ extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
 				   struct nfs_page *);
 extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
 extern	void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *, pgoff_t);
-extern bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
+extern size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 				struct nfs_page *prev,
 				struct nfs_page *req);
 extern  int nfs_wait_on_request(struct nfs_page *);
-- 
1.8.5.2 (Apple Git-48)


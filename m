Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51027 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766Ab1E2S2c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:28:32 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 29/32] NFSv4.1: change pg_test return type to bool
Date: Sun, 29 May 2011 21:28:21 +0300
Message-Id: <1306693701-8522-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c      |    6 +++---
 fs/nfs/objlayout/objio_osd.c |    7 +++----
 fs/nfs/pagelist.c            |   22 +++++++++++-----------
 fs/nfs/pnfs.c                |    4 ++--
 fs/nfs/pnfs.h                |    4 ++--
 include/linux/nfs_page.h     |    2 +-
 6 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 33bda24..24f0572 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -651,10 +651,10 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 /*
  * filelayout_pg_test(). Called by nfs_can_coalesce_requests()
  *
- * return 1 :  coalesce page
- * return 0 :  don't coalesce page
+ * return true  : coalesce page
+ * return false : don't coalesce page
  */
-int
+bool
 filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		   struct nfs_page *req)
 {
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 3be1241..8c2bd3e 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -991,14 +991,13 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
 /*
  * objlayout_pg_test(). Called by nfs_can_coalesce_requests()
  *
- * return 1 :  coalesce page
- * return 0 :  don't coalesce page
+ * return true iff coalesce page
  */
-int
+bool
 objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		   struct nfs_page *req)
 {
-	return 1;
+	return true;
 }
 
 static struct pnfs_layoutdriver_type objlayout_type = {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b8704fe..5344371 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -244,29 +244,29 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
  *
  * Return 'true' if this is the case, else return 'false'.
  */
-static int nfs_can_coalesce_requests(struct nfs_page *prev,
-				     struct nfs_page *req,
-				     struct nfs_pageio_descriptor *pgio)
+static bool nfs_can_coalesce_requests(struct nfs_page *prev,
+				      struct nfs_page *req,
+				      struct nfs_pageio_descriptor *pgio)
 {
 	if (req->wb_context->cred != prev->wb_context->cred)
-		return 0;
+		return false;
 	if (req->wb_lock_context->lockowner != prev->wb_lock_context->lockowner)
-		return 0;
+		return false;
 	if (req->wb_context->state != prev->wb_context->state)
-		return 0;
+		return false;
 	if (req->wb_index != (prev->wb_index + 1))
-		return 0;
+		return false;
 	if (req->wb_pgbase != 0)
-		return 0;
+		return false;
 	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
-		return 0;
+		return false;
 	/*
 	 * Non-whole file layouts need to check that req is inside of
 	 * pgio->pg_lseg.
 	 */
 	if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
-		return 0;
-	return 1;
+		return false;
+	return true;
 }
 
 /**
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 568ab0e..212fc29 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1043,7 +1043,7 @@ out_forget_reply:
 	goto out;
 }
 
-int
+bool
 pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		     struct nfs_page *req)
 {
@@ -1070,7 +1070,7 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	} else if (pgio->pg_lseg &&
 		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
 						pgio->pg_lseg->pls_range.length))
-		return 0;
+		return false;
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c056688..65daae5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -87,7 +87,7 @@ struct pnfs_layoutdriver_type {
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
 	/* test for nfs page cache coalescing */
-	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
+	bool (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 
 	/* Returns true if layoutdriver wants to divert this request to
 	 * driver's commit routine.
@@ -158,7 +158,7 @@ enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
-int pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
+bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 91af2e4..3a34e80 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -68,7 +68,7 @@ struct nfs_pageio_descriptor {
 	int 			pg_ioflags;
 	int			pg_error;
 	struct pnfs_layout_segment *pg_lseg;
-	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
+	bool			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
-- 
1.7.2.3


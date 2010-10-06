Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24019 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595Ab0JGPeU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 11:34:20 -0400
Received: from localhost.localdomain (laino1-lxp.hq.netapp.com [10.58.48.170])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o97FYJ4G028863
	for <linux-nfs@vger.kernel.org>; Thu, 7 Oct 2010 08:34:19 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] pnfs_submit: Remove the get_stripesize function
Date: Wed,  6 Oct 2010 18:59:02 -0400
Message-Id: <1286405942-17704-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The primary motivation was to remove the file driver's
"horrible hack".  In the process, it was realized that no one
actually uses the function.  (In the all branch, the object driver
implements it, but never uses the result.)

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c  |   37 +++++++------------------------------
 fs/nfs/pnfs.c            |   31 ++++---------------------------
 fs/nfs/pnfs.h            |    3 ---
 include/linux/nfs_page.h |    1 -
 4 files changed, 11 insertions(+), 61 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2b6e3c9..5f52e6f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -612,50 +612,28 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 }
 
 /*
- * Return the stripesize for the specified file
- * Called with inode i_lock held.
- */
-ssize_t
-filelayout_get_stripesize(struct pnfs_layout_hdr *lo)
-{
-	struct pnfs_layout_range range = {
-		.iomode = IOMODE_READ,
-		.offset = 0,
-		.length = NFS4_MAX_UINT64,
-	};
-	struct pnfs_layout_segment *lseg;
-	struct nfs4_filelayout_segment *fl;
-	ssize_t size;
-
-	/* Horrible hack...ideally upper layer would send lseg */
-	lseg = pnfs_has_layout(lo, &range);
-	if (!lseg)
-		return 0;
-	fl = FILELAYOUT_LSEG(lseg);
-	size = fl->stripe_unit;
-	put_lseg_locked(lseg);
-	return size;
-}
-
-/*
  * filelayout_pg_test(). Called by nfs_can_coalesce_requests()
  *
  * return 1 :  coalesce page
  * return 0 :  don't coalesce page
+ *
+ * By the time this is called, we know req->wb_lseg == prev->wb_lseg
  */
 int
 filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		   struct nfs_page *req)
 {
 	u64 p_stripe, r_stripe;
+	u32 stripe_unit;
 
-	if (pgio->pg_boundary == 0)
+	if (!req->wb_lseg)
 		return 1;
 	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
 	r_stripe = (u64)req->wb_index << PAGE_CACHE_SHIFT;
+	stripe_unit = FILELAYOUT_LSEG(req->wb_lseg)->stripe_unit;
 
-	do_div(p_stripe, pgio->pg_boundary);
-	do_div(r_stripe, pgio->pg_boundary);
+	do_div(p_stripe, stripe_unit);
+	do_div(r_stripe, stripe_unit);
 
 	return (p_stripe == r_stripe);
 }
@@ -668,7 +646,6 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
 	.alloc_lseg              = filelayout_alloc_lseg,
 	.free_lseg               = filelayout_free_lseg,
-	.get_stripesize          = filelayout_get_stripesize,
 	.pg_test                 = filelayout_pg_test,
 	.read_pagelist           = filelayout_read_pagelist,
 	.write_pagelist          = filelayout_write_pagelist,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 555955b..362b26c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -988,23 +988,6 @@ pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
 	pgio->pg_test = ld->pg_test;
 }
 
-static u32
-pnfs_getboundary(struct inode *inode)
-{
-	u32 stripe_size = 0;
-	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
-
-	if (!ld || !ld->get_stripesize)
-		goto out;
-
-	spin_lock(&inode->i_lock);
-	if (NFS_I(inode)->layout)
-		stripe_size = ld->get_stripesize(NFS_I(inode)->layout);
-	spin_unlock(&inode->i_lock);
-out:
-	return stripe_size;
-}
-
 /*
  * rsize is already set by caller to MDS rsize.
  */
@@ -1017,7 +1000,6 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	pgio->pg_iswrite = 0;
-	pgio->pg_boundary = 0;
 	pgio->pg_test = NULL;
 	pgio->pg_lseg = NULL;
 
@@ -1028,9 +1010,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	if (!pgio->pg_lseg)
 		return;
 
-	pgio->pg_boundary = pnfs_getboundary(inode);
-	if (pgio->pg_boundary)
-		pnfs_set_pg_test(inode, pgio);
+	pnfs_set_pg_test(inode, pgio);
 }
 
 void
@@ -1039,13 +1019,10 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	struct nfs_server *server = NFS_SERVER(inode);
 
 	pgio->pg_iswrite = 1;
-	if (!pnfs_enabled_sb(server)) {
-		pgio->pg_boundary = 0;
+	if (!pnfs_enabled_sb(server))
 		pgio->pg_test = NULL;
-		return;
-	}
-	pgio->pg_boundary = pnfs_getboundary(inode);
-	pnfs_set_pg_test(inode, pgio);
+	else
+		pnfs_set_pg_test(inode, pgio);
 }
 
 static void _pnfs_clear_lseg_from_pages(struct list_head *head)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 4ea3ae0..5ac931b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -67,9 +67,6 @@ struct pnfs_layoutdriver_type {
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-	/* The stripe size of the file system */
-	ssize_t (*get_stripesize) (struct pnfs_layout_hdr *layoutid);
-
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 287ee81..6fa43c7 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -65,7 +65,6 @@ struct nfs_pageio_descriptor {
 	struct pnfs_layout_segment *pg_lseg;
 #ifdef CONFIG_NFS_V4_1
 	int			pg_iswrite;
-	int			pg_boundary;
 	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 #endif /* CONFIG_NFS_V4_1 */
 };
-- 
1.7.2.1


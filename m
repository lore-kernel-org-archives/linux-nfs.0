Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507Ab1BNTSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:18:52 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamon <andros@netapp.com>, Andy Adamon <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
Subject: [PATCH 10/16] pnfs: wave 3: coelesce across layout stripes
Date: Mon, 14 Feb 2011 14:18:30 -0500
Message-Id: <1297711116-3139-11-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-1-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Add a pg_test layout driver hook which is used to avoid coelescing I/O across
layout stripes.

Signed-off-by: Andy Adamon <andros@netapp.com>
Signed-off-by: Andy Adamon <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
---
 fs/nfs/nfs4filelayout.c  |   26 ++++++++++++++++++++++++++
 fs/nfs/pagelist.c        |   18 +++++++++++++-----
 fs/nfs/pnfs.c            |   19 +++++++++++++++++++
 fs/nfs/pnfs.h            |   12 ++++++++++++
 fs/nfs/read.c            |    1 +
 fs/nfs/write.c           |    3 +++
 include/linux/nfs_page.h |    1 +
 7 files changed, 75 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 23f930c..98e26e0 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -252,6 +252,31 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 	_filelayout_free_lseg(fl);
 }
 
+/*
+ * filelayout_pg_test(). Called by nfs_can_coalesce_requests()
+ *
+ * return 1 :  coalesce page
+ * return 0 :  don't coalesce page
+ */
+int
+filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
+		   struct nfs_page *req)
+{
+	u64 p_stripe, r_stripe;
+	u32 stripe_unit;
+
+	if (!pgio->pg_lseg)
+		return 1;
+	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
+	r_stripe = (u64)req->wb_index << PAGE_CACHE_SHIFT;
+	stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
+
+	do_div(p_stripe, stripe_unit);
+	do_div(r_stripe, stripe_unit);
+
+	return (p_stripe == r_stripe);
+}
+
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id = LAYOUT_NFSV4_1_FILES,
 	.name = "LAYOUT_NFSV4_1_FILES",
@@ -260,6 +285,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.clear_layoutdriver = filelayout_clear_layoutdriver,
 	.alloc_lseg              = filelayout_alloc_lseg,
 	.free_lseg               = filelayout_free_lseg,
+	.pg_test                 = filelayout_pg_test,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e0a0cb4..2c793a7 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -242,7 +242,8 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
  * Return 'true' if this is the case, else return 'false'.
  */
 static int nfs_can_coalesce_requests(struct nfs_page *prev,
-				     struct nfs_page *req)
+				     struct nfs_page *req,
+				     struct nfs_pageio_descriptor *pgio)
 {
 	if (req->wb_context->cred != prev->wb_context->cred)
 		return 0;
@@ -256,6 +257,12 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
 		return 0;
 	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
 		return 0;
+	/*
+	 * Non-whole file layouts need to check that req is inside of
+	 * pgio->pg_lseg.
+	 */
+	if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
+		return 0;
 	return 1;
 }
 
@@ -288,14 +295,15 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 		if (newlen > desc->pg_bsize)
 			return 0;
 		prev = nfs_list_entry(desc->pg_list.prev);
-		if (!nfs_can_coalesce_requests(prev, req))
+		if (!nfs_can_coalesce_requests(prev, req, desc))
 			return 0;
 	} else {
 		put_lseg(desc->pg_lseg);
 		desc->pg_base = req->wb_pgbase;
-		desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
-						   req->wb_context,
-						   IOMODE_READ);
+		if (desc->pg_test)
+			desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
+							   req->wb_context,
+							   IOMODE_READ);
 	}
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &desc->pg_list);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dcd4356..f200e34 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -871,6 +871,25 @@ out_forget_reply:
 	goto out;
 }
 
+static void
+pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
+{
+	struct pnfs_layoutdriver_type *ld;
+
+	ld = NFS_SERVER(inode)->pnfs_curr_ld;
+	pgio->pg_test = (ld ? ld->pg_test : NULL);
+}
+
+/*
+ * rsize is already set by caller to MDS rsize.
+ */
+void
+pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
+		  struct inode *inode)
+{
+	pnfs_set_pg_test(inode, pgio);
+}
+
 /*
  * Device ID cache. Currently supports one layout type per struct nfs_client.
  * Add layout type to the lookup key to expand to support multiple types.
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 121d6a3..5107d14 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -30,6 +30,8 @@
 #ifndef FS_NFS_PNFS_H
 #define FS_NFS_PNFS_H
 
+#include <linux/nfs_page.h>
+
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
 	NFS_LSEG_ROC,		/* roc bit received from server */
@@ -65,6 +67,9 @@ struct pnfs_layoutdriver_type {
 	int (*clear_layoutdriver) (struct nfs_server *);
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
+
+	/* test for nfs page cache coalescing */
+	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
 struct pnfs_layout_hdr {
@@ -152,6 +157,7 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -251,6 +257,12 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
+static inline void
+pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino)
+{
+	pgio->pg_test = NULL;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c453164..20cc936 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -630,6 +630,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
+	pnfs_pageio_init_read(&pgio, inode);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 004c28b..aca0268 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -28,6 +28,7 @@
 #include "iostat.h"
 #include "nfs4_fs.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -982,6 +983,8 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
+	pgio->pg_test = NULL;
+
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
 	else
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 2db0372..ba88ff4 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -63,6 +63,7 @@ struct nfs_pageio_descriptor {
 	int 			pg_ioflags;
 	int			pg_error;
 	struct pnfs_layout_segment *pg_lseg;
+	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
-- 
1.7.2.3


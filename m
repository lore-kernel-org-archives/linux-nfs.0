Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757111Ab1CAR3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 12:29:47 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamson <andros@netapp.com>, Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
Subject: [PATCH pNFS wave 3 Version 3 09/18] NFSv4.1: coelesce across layout stripes
Date: Mon, 28 Feb 2011 20:34:14 -0500
Message-Id: <1298943263-2886-10-git-send-email-andros@netapp.com>
In-Reply-To: <1298943263-2886-9-git-send-email-andros@netapp.com>
References: <1298943263-2886-1-git-send-email-andros@netapp.com>
 <1298943263-2886-2-git-send-email-andros@netapp.com>
 <1298943263-2886-3-git-send-email-andros@netapp.com>
 <1298943263-2886-4-git-send-email-andros@netapp.com>
 <1298943263-2886-5-git-send-email-andros@netapp.com>
 <1298943263-2886-6-git-send-email-andros@netapp.com>
 <1298943263-2886-7-git-send-email-andros@netapp.com>
 <1298943263-2886-8-git-send-email-andros@netapp.com>
 <1298943263-2886-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Add a pg_test layout driver hook which is used to avoid coelescing I/O across
layout stripes.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
---
 fs/nfs/nfs4filelayout.c  |   26 ++++++++++++++++++++++++++
 fs/nfs/pagelist.c        |   12 ++++++++++--
 fs/nfs/pnfs.c            |   16 ++++++++++++++++
 fs/nfs/pnfs.h            |   12 ++++++++++++
 fs/nfs/read.c            |    1 +
 fs/nfs/write.c           |    3 +++
 include/linux/nfs_page.h |    2 ++
 7 files changed, 70 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 23f930c..0efe8cb 100644
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
+	.pg_test		= filelayout_pg_test,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e1164e3..9b9a65c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -226,6 +226,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_doio = doio;
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
+	desc->pg_lseg = NULL;
 }
 
 /**
@@ -240,7 +241,8 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
  * Return 'true' if this is the case, else return 'false'.
  */
 static int nfs_can_coalesce_requests(struct nfs_page *prev,
-				     struct nfs_page *req)
+				     struct nfs_page *req,
+				     struct nfs_pageio_descriptor *pgio)
 {
 	if (req->wb_context->cred != prev->wb_context->cred)
 		return 0;
@@ -254,6 +256,12 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
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
 
@@ -286,7 +294,7 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 		if (newlen > desc->pg_bsize)
 			return 0;
 		prev = nfs_list_entry(desc->pg_list.prev);
-		if (!nfs_can_coalesce_requests(prev, req))
+		if (!nfs_can_coalesce_requests(prev, req, desc))
 			return 0;
 	} else
 		desc->pg_base = req->wb_pgbase;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3afa82e..330cee1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -858,6 +858,22 @@ out_forget_reply:
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
index 9a994bc..db52d96 100644
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
@@ -151,6 +156,7 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -250,6 +256,12 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
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
index aedcaa7..2a27659 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -626,6 +626,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 		goto read_complete; /* all pages were read */
 
 	pnfs_update_layout(inode, desc.ctx, IOMODE_READ);
+	pnfs_pageio_init_read(&pgio, inode);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c8278f4..6e90cdf 100644
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
index d55cee7..4eaf27a 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -62,6 +62,8 @@ struct nfs_pageio_descriptor {
 	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
 	int 			pg_ioflags;
 	int			pg_error;
+	struct pnfs_layout_segment *pg_lseg;
+	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
-- 
1.6.6


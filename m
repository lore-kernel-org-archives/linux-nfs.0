Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006Ab1BDVeT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:19 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 05/40] pnfs_submit: wave3 pageio-helpers
Date: Fri,  4 Feb 2011 16:33:27 -0500
Message-Id: <1296855242-2592-6-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-5-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamon <andros@netapp.com>
Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
[pnfs-submit: init pg_lseg to NULL when !CONFIG_NFS_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pagelist.c        |   11 +++++++++--
 fs/nfs/pnfs.c            |   40 ++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h            |   14 ++++++++++++++
 fs/nfs/read.c            |    4 ++--
 include/linux/nfs_page.h |    5 +++++
 5 files changed, 70 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e1164e3..0e8dece 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -240,7 +240,8 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
  * Return 'true' if this is the case, else return 'false'.
  */
 static int nfs_can_coalesce_requests(struct nfs_page *prev,
-				     struct nfs_page *req)
+				     struct nfs_page *req,
+				     struct nfs_pageio_descriptor *pgio)
 {
 	if (req->wb_context->cred != prev->wb_context->cred)
 		return 0;
@@ -254,6 +255,12 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
 		return 0;
 	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
 		return 0;
+	if (req->wb_lseg != prev->wb_lseg)
+		return 0;
+#ifdef CONFIG_NFS_V4_1
+	if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
+		return 0;
+#endif /* CONFIG_NFS_V4_1 */
 	return 1;
 }
 
@@ -286,7 +293,7 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 		if (newlen > desc->pg_bsize)
 			return 0;
 		prev = nfs_list_entry(desc->pg_list.prev);
-		if (!nfs_can_coalesce_requests(prev, req))
+		if (!nfs_can_coalesce_requests(prev, req, desc))
 			return 0;
 	} else
 		desc->pg_base = req->wb_pgbase;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 32ad768..c7199db 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -870,6 +870,46 @@ out_forget_reply:
 	goto out;
 }
 
+void
+pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
+{
+	struct pnfs_layout_hdr *lo;
+	struct pnfs_layoutdriver_type *ld;
+
+	pgio->pg_test = NULL;
+
+	lo = NFS_I(inode)->layout;
+	ld = NFS_SERVER(inode)->pnfs_curr_ld;
+	if (!ld || !lo)
+		return;
+
+	pgio->pg_test = ld->pg_test;
+}
+
+/*
+ * rsize is already set by caller to MDS rsize.
+ */
+void
+pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
+		  struct inode *inode,
+		  struct nfs_open_context *ctx,
+		  struct list_head *pages)
+{
+	struct nfs_server *nfss = NFS_SERVER(inode);
+
+	pgio->pg_test = NULL;
+	pgio->pg_lseg = NULL;
+
+	if (!pnfs_enabled_sb(nfss))
+		return;
+
+	pgio->pg_lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
+	if (!pgio->pg_lseg)
+		return;
+
+	pnfs_set_pg_test(inode, pgio);
+}
+
 /*
  * Device ID cache. Currently supports one layout type per struct nfs_client.
  * Add layout type to the lookup key to expand to support multiple types.
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index fe50faa..7a75a0c 100644
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
@@ -151,6 +156,8 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
+			   struct nfs_open_context *, struct list_head *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -240,6 +247,13 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
+static inline void
+pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino,
+		      struct nfs_open_context *ctx, struct list_head *pages)
+{
+	pgio->pg_lseg = NULL;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 6c224e8..11e7d6e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -20,12 +20,12 @@
 #include <linux/nfs_page.h>
 
 #include <asm/system.h>
+#include "pnfs.h"
 
 #include "nfs4_fs.h"
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
-#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -625,7 +625,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	pnfs_update_layout(inode, desc.ctx, IOMODE_READ);
+	pnfs_pageio_init_read(&pgio, inode, desc.ctx, pages);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d55cee7..ec9fd30 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -49,6 +49,7 @@ struct nfs_page {
 	struct kref		wb_kref;	/* reference count */
 	unsigned long		wb_flags;
 	struct nfs_writeverf	wb_verf;	/* Commit cookie */
+	struct pnfs_layout_segment *wb_lseg;	/* Pnfs layout info */
 };
 
 struct nfs_pageio_descriptor {
@@ -62,6 +63,10 @@ struct nfs_pageio_descriptor {
 	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
 	int 			pg_ioflags;
 	int			pg_error;
+	struct pnfs_layout_segment *pg_lseg;
+#ifdef CONFIG_NFS_V4_1
+	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
-- 
1.6.6


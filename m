Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52094 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293Ab0HMVcc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:32 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 32/50] pnfs_submit-pageio-helpers.patch
Date: Fri, 13 Aug 2010 17:31:44 -0400
Message-Id: <1281735122-1496-33-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-32-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-of-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pagelist.c         |   11 +++++-
 fs/nfs/pnfs.c             |   82 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |    3 ++
 fs/nfs/read.c             |    4 ++
 fs/nfs/write.c            |    4 ++
 include/linux/nfs4_pnfs.h |    6 +++
 include/linux/nfs_page.h  |    7 ++++
 7 files changed, 115 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9194902..41b3966 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -237,7 +237,8 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
  * Return 'true' if this is the case, else return 'false'.
  */
 static int nfs_can_coalesce_requests(struct nfs_page *prev,
-				     struct nfs_page *req)
+				     struct nfs_page *req,
+				     struct nfs_pageio_descriptor *pgio)
 {
 	if (req->wb_context->cred != prev->wb_context->cred)
 		return 0;
@@ -251,6 +252,12 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
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
 
@@ -283,7 +290,7 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 		if (newlen > desc->pg_bsize)
 			return 0;
 		prev = nfs_list_entry(desc->pg_list.prev);
-		if (!nfs_can_coalesce_requests(prev, req))
+		if (!nfs_can_coalesce_requests(prev, req, desc))
 			return 0;
 	} else
 		desc->pg_base = req->wb_pgbase;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9f17ef5..e25e5d9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1152,6 +1152,88 @@ out:
 	return status;
 }
 
+void
+pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
+{
+	struct pnfs_layout_type *laytype;
+	struct pnfs_layoutdriver_type *ld;
+
+	pgio->pg_test = NULL;
+
+	laytype = NFS_I(inode)->layout;
+	ld = NFS_SERVER(inode)->pnfs_curr_ld;
+	if (!pnfs_enabled_sb(NFS_SERVER(inode)) || !laytype)
+		return;
+
+	if (ld->ld_policy_ops)
+		pgio->pg_test = ld->ld_policy_ops->pg_test;
+}
+
+static u32
+pnfs_getboundary(struct inode *inode)
+{
+	u32 stripe_size = 0;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	struct layoutdriver_policy_operations *policy_ops;
+
+	if (!nfss->pnfs_curr_ld)
+		goto out;
+
+	policy_ops = nfss->pnfs_curr_ld->ld_policy_ops;
+	if (!policy_ops || !policy_ops->get_stripesize)
+		goto out;
+
+	spin_lock(&inode->i_lock);
+	if (NFS_I(inode)->layout)
+		stripe_size = policy_ops->get_stripesize(NFS_I(inode)->layout);
+	spin_unlock(&inode->i_lock);
+out:
+	return stripe_size;
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
+	pgio->pg_iswrite = 0;
+	pgio->pg_boundary = 0;
+	pgio->pg_test = NULL;
+	pgio->pg_lseg = NULL;
+
+	if (!pnfs_enabled_sb(nfss))
+		return;
+
+	_pnfs_update_layout(inode, ctx, IOMODE_READ, &pgio->pg_lseg);
+	if (!pgio->pg_lseg)
+		return;
+
+	pgio->pg_boundary = pnfs_getboundary(inode);
+	if (pgio->pg_boundary)
+		pnfs_set_pg_test(inode, pgio);
+}
+
+void
+pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	pgio->pg_iswrite = 1;
+	if (!pnfs_enabled_sb(server)) {
+		pgio->pg_boundary = 0;
+		pgio->pg_test = NULL;
+		return;
+	}
+	pgio->pg_boundary = pnfs_getboundary(inode);
+	pnfs_set_pg_test(inode, pgio);
+}
+
 /*
  * Set up the argument/result storage required for the RPC call.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 74b9a70..5cd00fd 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -46,6 +46,9 @@ void pnfs_layoutcommit_free(struct pnfs_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, int sync);
 void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent);
 void pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx);
+void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
+			   struct nfs_open_context *, struct list_head *);
+void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
 void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 8f3a894..99d95ec 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -20,6 +20,7 @@
 #include <linux/nfs_page.h>
 
 #include <asm/system.h>
+#include "pnfs.h"
 
 #include "nfs4_fs.h"
 #include "internal.h"
@@ -625,6 +626,9 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
+#ifdef CONFIG_NFS_V4_1
+	pnfs_pageio_init_read(&pgio, inode, desc.ctx, pages);
+#endif /* CONFIG_NFS_V4_1 */
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5937247..0667eda 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -986,6 +986,10 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
+#ifdef CONFIG_NFS_V4_1
+	pnfs_pageio_init_write(pgio, inode);
+#endif /* CONFIG_NFS_V4_1 */
+
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
 	else
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 52f7a21..9e3fff4 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -13,6 +13,7 @@
 #define LINUX_NFS4_PNFS_H
 
 #include <linux/pnfs_xdr.h>
+#include <linux/nfs_page.h>
 
 /* Per-layout driver specific registration structure */
 struct pnfs_layoutdriver_type {
@@ -118,6 +119,11 @@ struct layoutdriver_io_operations {
 };
 
 struct layoutdriver_policy_operations {
+	/* The stripe size of the file system */
+	ssize_t (*get_stripesize) (struct pnfs_layout_type *layoutid);
+
+	/* test for nfs page cache coalescing */
+	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
 struct pnfs_device {
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index f8b60e7..d7deec9 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -48,6 +48,7 @@ struct nfs_page {
 	struct kref		wb_kref;	/* reference count */
 	unsigned long		wb_flags;
 	struct nfs_writeverf	wb_verf;	/* Commit cookie */
+	struct pnfs_layout_segment *wb_lseg;	/* Pnfs layout info */
 };
 
 struct nfs_pageio_descriptor {
@@ -61,6 +62,12 @@ struct nfs_pageio_descriptor {
 	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
 	int 			pg_ioflags;
 	int			pg_error;
+	struct pnfs_layout_segment *pg_lseg;
+#ifdef CONFIG_NFS_V4_1
+	int			pg_iswrite;
+	int			pg_boundary;
+	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
-- 
1.6.2.5


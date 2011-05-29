Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51012 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766Ab1E2S16 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:27:58 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 28/32] NFSv4.1: unify pnfs_pageio_init functions
Date: Sun, 29 May 2011 21:27:46 +0300
Message-Id: <1306693666-8493-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Use common code for pnfs_pageio_init_{read,write} and use
a common generic pg_test function.

Note that this function always assumes the the layout driver's
pg_test method is implemented.

[Fix BUG]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pagelist.c |    2 +
 fs/nfs/pnfs.c     |   55 ++++++++++++++--------------------------------------
 fs/nfs/pnfs.h     |   21 +++++++++----------
 fs/nfs/read.c     |    1 -
 fs/nfs/write.c    |    2 -
 5 files changed, 27 insertions(+), 54 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index c80add6..b8704fe 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -229,6 +229,8 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
+	desc->pg_test = NULL;
+	pnfs_pageio_init(desc, inode);
 }
 
 /**
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 00b1282..568ab0e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1043,46 +1043,30 @@ out_forget_reply:
 	goto out;
 }
 
-static int pnfs_read_pg_test(struct nfs_pageio_descriptor *pgio,
-			     struct nfs_page *prev,
-			     struct nfs_page *req)
-{
-	if (pgio->pg_count == prev->wb_bytes) {
-		/* This is first coelesce call for a series of nfs_pages */
-		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-						   prev->wb_context,
-						   req_offset(req),
-						   pgio->pg_count,
-						   IOMODE_READ,
-						   GFP_KERNEL);
-	} else if (pgio->pg_lseg &&
-		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
-						pgio->pg_lseg->pls_range.length))
-		return 0;
-	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
-}
-
-void
-pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+int
+pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
+		     struct nfs_page *req)
 {
-	struct pnfs_layoutdriver_type *ld;
+	enum pnfs_iomode access_type;
+	gfp_t gfp_flags;
 
-	ld = NFS_SERVER(inode)->pnfs_curr_ld;
-	pgio->pg_test = (ld && ld->pg_test) ? pnfs_read_pg_test : NULL;
-}
+	/* We assume that pg_ioflags == 0 iff we're reading a page */
+	if (pgio->pg_ioflags == 0) {
+		access_type = IOMODE_READ;
+		gfp_flags = GFP_KERNEL;
+	} else {
+		access_type = IOMODE_RW;
+		gfp_flags = GFP_NOFS;
+	}
 
-static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
-			      struct nfs_page *prev,
-			      struct nfs_page *req)
-{
 	if (pgio->pg_count == prev->wb_bytes) {
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   prev->wb_context,
 						   req_offset(req),
 						   pgio->pg_count,
-						   IOMODE_RW,
-						   GFP_NOFS);
+						   access_type,
+						   gfp_flags);
 	} else if (pgio->pg_lseg &&
 		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
 						pgio->pg_lseg->pls_range.length))
@@ -1090,15 +1074,6 @@ static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
 
-void
-pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
-{
-	struct pnfs_layoutdriver_type *ld;
-
-	ld = NFS_SERVER(inode)->pnfs_curr_ld;
-	pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
-}
-
 /*
  * Called by non rpc-based layout drivers
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3fda971..c056688 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -158,8 +158,7 @@ enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
-void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
-void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
+int pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -293,6 +292,13 @@ static inline int pnfs_return_layout(struct inode *ino)
 	return 0;
 }
 
+static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio,
+				    struct inode *inode)
+{
+	if (NFS_SERVER(inode)->pnfs_curr_ld)
+		pgio->pg_test = pnfs_generic_pg_test;
+}
+
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
@@ -376,16 +382,9 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
-static inline void
-pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino)
-{
-	pgio->pg_test = NULL;
-}
-
-static inline void
-pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *ino)
+static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio,
+				    struct inode *inode)
 {
-	pgio->pg_test = NULL;
 }
 
 static inline void
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 540c8bc..20a7f95 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -664,7 +664,6 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	pnfs_pageio_init_read(&pgio, inode);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7edb72f..e268e3b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1036,8 +1036,6 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
-	pnfs_pageio_init_write(pgio, inode);
-
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
 	else
-- 
1.7.2.3


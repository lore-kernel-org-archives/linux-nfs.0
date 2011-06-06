Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757473Ab1FFWcz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jun 2011 18:32:55 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4.1: Add an initialisation callback for pNFS
Date: Mon,  6 Jun 2011 18:32:31 -0400
Message-Id: <1307399551-17489-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>
 <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Ensure that we always get a layout before setting up the i/o request.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c      |    2 +
 fs/nfs/objlayout/objio_osd.c |    2 +
 fs/nfs/pagelist.c            |    2 +
 fs/nfs/pnfs.c                |   57 ++++++++++++++++++++++-------------------
 fs/nfs/pnfs.h                |   14 +---------
 fs/nfs/read.c                |   16 +++---------
 fs/nfs/write.c               |   12 ++------
 include/linux/nfs_page.h     |    1 +
 8 files changed, 47 insertions(+), 59 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e9b9b82..93c5bae1f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -677,11 +677,13 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 
 static const struct nfs_pageio_ops filelayout_pg_read_ops = {
+	.pg_init = pnfs_generic_pg_init_read,
 	.pg_test = filelayout_pg_test,
 	.pg_doio = nfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops filelayout_pg_write_ops = {
+	.pg_init = pnfs_generic_pg_init_write,
 	.pg_test = filelayout_pg_test,
 	.pg_doio = nfs_generic_pg_writepages,
 };
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 31088f3..84b5fb7 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1009,11 +1009,13 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
 }
 
 static const struct nfs_pageio_ops objio_pg_read_ops = {
+	.pg_init = pnfs_generic_pg_init_read,
 	.pg_test = objio_pg_test,
 	.pg_doio = nfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops objio_pg_write_ops = {
+	.pg_init = pnfs_generic_pg_init_write,
 	.pg_test = objio_pg_test,
 	.pg_doio = nfs_generic_pg_writepages,
 };
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 2b71ad0..ed68d78 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -295,6 +295,8 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 			return 0;
 	} else {
 		desc->pg_base = req->wb_pgbase;
+		if (desc->pg_ops->pg_init)
+			desc->pg_ops->pg_init(desc, req);
 	}
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &desc->pg_list);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 12b53ef..dec4533 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -900,7 +900,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
  */
-struct pnfs_layout_segment *
+static struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
 		   loff_t pos,
@@ -1043,35 +1043,40 @@ out_forget_reply:
 	goto out;
 }
 
+void
+pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	BUG_ON(pgio->pg_lseg != NULL);
+
+	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+					   req->wb_context,
+					   req_offset(req),
+					   req->wb_bytes,
+					   IOMODE_READ,
+					   GFP_KERNEL);
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
+
+void
+pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	BUG_ON(pgio->pg_lseg != NULL);
+
+	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+					   req->wb_context,
+					   req_offset(req),
+					   req->wb_bytes,
+					   IOMODE_RW,
+					   GFP_NOFS);
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
+
 bool
 pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		     struct nfs_page *req)
 {
-	enum pnfs_iomode access_type;
-	gfp_t gfp_flags;
-
-	/* We assume that pg_ioflags == 0 iff we're reading a page */
-	if (pgio->pg_ioflags == 0) {
-		access_type = IOMODE_READ;
-		gfp_flags = GFP_KERNEL;
-	} else {
-		access_type = IOMODE_RW;
-		gfp_flags = GFP_NOFS;
-	}
-
-	if (pgio->pg_lseg == NULL) {
-		if (pgio->pg_count != prev->wb_bytes)
-			return true;
-		/* This is first coelesce call for a series of nfs_pages */
-		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-						   prev->wb_context,
-						   req_offset(prev),
-						   pgio->pg_count,
-						   access_type,
-						   gfp_flags);
-		if (pgio->pg_lseg == NULL)
-			return true;
-	}
+	if (pgio->pg_lseg == NULL)
+		return nfs_generic_pg_test(pgio, prev, req);
 
 	if (req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
 					 pgio->pg_lseg->pls_range.length))
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8d063c0..b1babde 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -149,16 +149,14 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
-struct pnfs_layout_segment *
-pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   loff_t pos, u64 count, enum pnfs_iomode access_type,
-		   gfp_t gfp_flags);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
+void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
+void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *, struct nfs_page *);
 bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
@@ -331,14 +329,6 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 {
 }
 
-static inline struct pnfs_layout_segment *
-pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   loff_t pos, u64 count, enum pnfs_iomode access_type,
-		   gfp_t gfp_flags)
-{
-	return NULL;
-}
-
 static inline enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index b0f5c19..5b65338 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -146,9 +146,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 
 	nfs_pageio_init_read(&pgio, inode);
-	nfs_list_add_request(new, &pgio.pg_list);
-	pgio.pg_count = len;
-
+	nfs_pageio_add_request(&pgio, new);
 	nfs_pageio_complete(&pgio);
 	return 0;
 }
@@ -280,7 +278,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 	unsigned int offset;
 	int requests = 0;
 	int ret = 0;
-	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	LIST_HEAD(list);
 
 	nfs_list_remove_request(req);
@@ -298,10 +296,6 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 	} while(nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
 
-	BUG_ON(desc->pg_lseg != NULL);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
-				  req_offset(req), desc->pg_count,
-				  IOMODE_READ, GFP_KERNEL);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
@@ -335,6 +329,8 @@ out_bad:
 	}
 	SetPageError(page);
 	nfs_readpage_release(req);
+	put_lseg(lseg);
+	desc->pg_lseg = NULL;
 	return -ENOMEM;
 }
 
@@ -363,10 +359,6 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
 		*pages++ = req->wb_page;
 	}
 	req = nfs_list_entry(data->pages.next);
-	if ((!lseg) && list_is_singular(&data->pages))
-		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
-					  req_offset(req), desc->pg_count,
-					  IOMODE_READ, GFP_KERNEL);
 
 	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, desc->pg_count,
 				0, lseg);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c379c86..eb56829 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -914,7 +914,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	unsigned int offset;
 	int requests = 0;
 	int ret = 0;
-	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	LIST_HEAD(list);
 
 	nfs_list_remove_request(req);
@@ -938,10 +938,6 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	} while (nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
 
-	BUG_ON(desc->pg_lseg);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
-				  req_offset(req), desc->pg_count,
-				  IOMODE_RW, GFP_NOFS);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
@@ -974,6 +970,8 @@ out_bad:
 		nfs_writedata_free(data);
 	}
 	nfs_redirty_request(req);
+	put_lseg(lseg);
+	desc->pg_lseg = NULL;
 	return -ENOMEM;
 }
 
@@ -1019,10 +1017,6 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 		*pages++ = req->wb_page;
 	}
 	req = nfs_list_entry(data->pages.next);
-	if ((!lseg) && list_is_singular(&data->pages))
-		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
-					  req_offset(req), desc->pg_count,
-					  IOMODE_RW, GFP_NOFS);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit))
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index b0e26c0..2927ecd 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -57,6 +57,7 @@ struct nfs_page {
 
 struct nfs_pageio_descriptor;
 struct nfs_pageio_ops {
+	void	(*pg_init)(struct nfs_pageio_descriptor *, struct nfs_page *);
 	bool	(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 	int	(*pg_doio)(struct nfs_pageio_descriptor *);
 };
-- 
1.7.5.2


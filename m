Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:42948 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbaESPPW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 11:15:22 -0400
Received: by mail-ig0-f174.google.com with SMTP id h3so3609676igd.1
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 08:15:21 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 5/8] nfs: remove pgio_header refcount, related cleanup
Date: Mon, 19 May 2014 11:15:05 -0400
Message-Id: <1400512508-7530-6-git-send-email-dros@primarydata.com>
In-Reply-To: <1400512508-7530-1-git-send-email-dros@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The refcounting on nfs_pgio_header was related to there being (possibly)
more than one nfs_pgio_data. Now that nfs_pgio_data has been merged into
nfs_pgio_header, there is no reason to do this ref counting.  Just call
the completion callback on nfs_pgio_release/nfs_pgio_error.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/internal.h       |  2 +-
 fs/nfs/pagelist.c       | 61 +++++++++++++++++++------------------------------
 fs/nfs/pnfs.c           | 10 ++------
 include/linux/nfs_xdr.h |  1 -
 4 files changed, 27 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f3b672b..e0e2b6d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -240,8 +240,8 @@ int nfs_iocounter_wait(struct nfs_io_counter *c);
 extern const struct nfs_pageio_ops nfs_pgio_rw_ops;
 struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *);
 void nfs_pgio_header_free(struct nfs_pgio_header *);
-void nfs_pgio_data_destroy(struct nfs_pgio_header *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
+void nfs_generic_pgio_reset(struct nfs_pgio_header *);
 int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_header *,
 		      const struct rpc_call_ops *, int, int);
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f2280eb..8f029ed 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -460,7 +460,6 @@ struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *ops)
 	if (hdr) {
 		INIT_LIST_HEAD(&hdr->pages);
 		spin_lock_init(&hdr->lock);
-		atomic_set(&hdr->refcnt, 0);
 		hdr->rw_ops = ops;
 	}
 	return hdr;
@@ -478,35 +477,6 @@ void nfs_pgio_header_free(struct nfs_pgio_header *hdr)
 EXPORT_SYMBOL_GPL(nfs_pgio_header_free);
 
 /**
- * nfs_pgio_data_alloc - Allocate pageio data
- * @hdr: The header making a request
- * @pagecount: Number of pages to create
- */
-static bool nfs_pgio_data_init(struct nfs_pgio_header *hdr,
-			       unsigned int pagecount)
-{
-	if (nfs_pgarray_set(&hdr->page_array, pagecount)) {
-		atomic_inc(&hdr->refcnt);
-		return true;
-	}
-	return false;
-}
-
-/**
- * nfs_pgio_data_destroy - Properly release pageio data
- * @hdr: The header with data to destroy
- */
-void nfs_pgio_data_destroy(struct nfs_pgio_header *hdr)
-{
-	put_nfs_open_context(hdr->args.context);
-	if (hdr->page_array.pagevec != hdr->page_array.page_array)
-		kfree(hdr->page_array.pagevec);
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
-}
-EXPORT_SYMBOL_GPL(nfs_pgio_data_destroy);
-
-/**
  * nfs_pgio_rpcsetup - Set up arguments for a pageio call
  * @hdr: The pageio hdr
  * @count: Number of bytes to read
@@ -620,7 +590,8 @@ static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
 			  struct nfs_pgio_header *hdr)
 {
 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	nfs_pgio_data_destroy(hdr);
+	nfs_generic_pgio_reset(hdr);
+	hdr->completion_ops->completion(hdr);
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 	return -ENOMEM;
 }
@@ -634,7 +605,8 @@ static void nfs_pgio_release(void *calldata)
 	struct nfs_pgio_header *hdr = calldata;
 	if (hdr->rw_ops->rw_release)
 		hdr->rw_ops->rw_release(hdr);
-	nfs_pgio_data_destroy(hdr);
+	nfs_generic_pgio_reset(hdr);
+	hdr->completion_ops->completion(hdr);
 }
 
 /**
@@ -708,9 +680,10 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 	struct page		**pages;
 	struct list_head *head = &desc->pg_list;
 	struct nfs_commit_info cinfo;
+	unsigned int pagecount;
 
-	if (!nfs_pgio_data_init(hdr, nfs_page_array_len(desc->pg_base,
-			   desc->pg_count)))
+	pagecount = nfs_page_array_len(desc->pg_base, desc->pg_count);
+	if (!nfs_pgarray_set(&hdr->page_array, pagecount))
 		return nfs_pgio_error(desc, hdr);
 
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
@@ -733,6 +706,23 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pgio);
 
+/**
+ * nfs_generic_pgio_reset - make @hdr suitable for reuse
+ *
+ * Frees memory and releases refs from nfs_generic_pgio, so that it may
+ * be called again.
+ *
+ * @hdr: A header that has had nfs_generic_pgio called
+ */
+void nfs_generic_pgio_reset(struct nfs_pgio_header *hdr)
+{
+	put_nfs_open_context(hdr->args.context);
+	if (hdr->page_array.pagevec != hdr->page_array.page_array)
+		kfree(hdr->page_array.pagevec);
+}
+EXPORT_SYMBOL_GPL(nfs_generic_pgio_reset);
+
+
 static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 {
 	struct nfs_pgio_header *hdr;
@@ -744,14 +734,11 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 		return -ENOMEM;
 	}
 	nfs_pgheader_init(desc, hdr, nfs_pgio_header_free);
-	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret == 0)
 		ret = nfs_initiate_pgio(NFS_CLIENT(hdr->inode),
 					hdr, desc->pg_rpc_callops,
 					desc->pg_ioflags, 0);
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
 	return ret;
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1b7da44..902783ab 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1537,7 +1537,7 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_pageio_reset_write_mds(desc);
 		desc->pg_recoalesce = 1;
 	}
-	nfs_pgio_data_destroy(hdr);
+	nfs_generic_pgio_reset(hdr);
 }
 
 static enum pnfs_try_status
@@ -1598,15 +1598,12 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	}
 	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
-	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret != 0) {
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
 		pnfs_do_write(desc, hdr, desc->pg_ioflags);
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
@@ -1677,7 +1674,7 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_pageio_reset_read_mds(desc);
 		desc->pg_recoalesce = 1;
 	}
-	nfs_pgio_data_destroy(hdr);
+	nfs_generic_pgio_reset(hdr);
 }
 
 /*
@@ -1741,15 +1738,12 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	}
 	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
-	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret != 0) {
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
 		pnfs_do_read(desc, hdr);
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index e1b7b3b..81cbbf31 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1259,7 +1259,6 @@ struct nfs_pgio_header {
 	struct inode		*inode;
 	struct rpc_cred		*cred;
 	struct list_head	pages;
-	atomic_t		refcnt;
 	struct nfs_page		*req;
 	struct nfs_writeverf	verf;		/* Used for writes */
 	struct pnfs_layout_segment *lseg;
-- 
1.8.5.2 (Apple Git-48)


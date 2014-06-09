Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:48103 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933254AbaFIPsp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 11:48:45 -0400
Received: by mail-ie0-f173.google.com with SMTP id y20so3473627ier.4
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jun 2014 08:48:44 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 5/7] nfs: remove pgio_header refcount, related cleanup
Date: Mon,  9 Jun 2014 11:48:37 -0400
Message-Id: <1402328919-5065-6-git-send-email-dros@primarydata.com>
In-Reply-To: <1402328919-5065-1-git-send-email-dros@primarydata.com>
References: <1402328919-5065-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The refcounting on nfs_pgio_header was related to there being (possibly)
more than one nfs_pgio_data. Now that nfs_pgio_data has been merged into
nfs_pgio_header, there is no reason to do this ref counting.  Just call
the completion callback on nfs_pgio_release/nfs_pgio_error.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c       | 36 +++++++++++-------------------------
 fs/nfs/pnfs.c           |  6 ------
 include/linux/nfs_xdr.h |  1 -
 3 files changed, 11 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6ff7797..b4dbcfb 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -459,7 +459,6 @@ struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *ops)
 	if (hdr) {
 		INIT_LIST_HEAD(&hdr->pages);
 		spin_lock_init(&hdr->lock);
-		atomic_set(&hdr->refcnt, 0);
 		hdr->rw_ops = ops;
 	}
 	return hdr;
@@ -477,31 +476,18 @@ void nfs_pgio_header_free(struct nfs_pgio_header *hdr)
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
+ * nfs_pgio_data_destroy - make @hdr suitable for reuse
+ *
+ * Frees memory and releases refs from nfs_generic_pgio, so that it may
+ * be called again.
+ *
+ * @hdr: A header that has had nfs_generic_pgio called
  */
 void nfs_pgio_data_destroy(struct nfs_pgio_header *hdr)
 {
 	put_nfs_open_context(hdr->args.context);
 	if (hdr->page_array.pagevec != hdr->page_array.page_array)
 		kfree(hdr->page_array.pagevec);
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
 }
 EXPORT_SYMBOL_GPL(nfs_pgio_data_destroy);
 
@@ -620,6 +606,7 @@ static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
 {
 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
 	nfs_pgio_data_destroy(hdr);
+	hdr->completion_ops->completion(hdr);
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 	return -ENOMEM;
 }
@@ -634,6 +621,7 @@ static void nfs_pgio_release(void *calldata)
 	if (hdr->rw_ops->rw_release)
 		hdr->rw_ops->rw_release(hdr);
 	nfs_pgio_data_destroy(hdr);
+	hdr->completion_ops->completion(hdr);
 }
 
 /**
@@ -707,9 +695,10 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
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
@@ -743,14 +732,11 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
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
index 1b7da44..2585933 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
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


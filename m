Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52150 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646Ab2ISBgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Sep 2012 21:36:03 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFSv4.1: Cleanup; add "pnfs_" prefix to put_lseg() and get_lseg()
Date: Tue, 18 Sep 2012 21:35:50 -0400
Message-Id: <1348018554-63137-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348018554-63137-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1348018554-63137-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348018554-63137-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348018554-63137-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 16 ++++++++--------
 fs/nfs/nfs4proc.c       |  2 +-
 fs/nfs/pnfs.c           | 36 ++++++++++++++++++------------------
 fs/nfs/pnfs.h           |  8 ++++----
 4 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 53f94d9..77cd115 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -453,7 +453,7 @@ static void filelayout_commit_release(void *calldata)
 	struct nfs_commit_data *data = calldata;
 
 	data->completion_ops->completion(data);
-	put_lseg(data->lseg);
+	pnfs_put_lseg(data->lseg);
 	nfs_put_client(data->ds_clp);
 	nfs_commitdata_release(data);
 }
@@ -931,7 +931,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	nfs_init_cinfo(&cinfo, pgio->pg_inode, pgio->pg_dreq);
 	status = filelayout_alloc_commit_info(pgio->pg_lseg, &cinfo, GFP_NOFS);
 	if (status < 0) {
-		put_lseg(pgio->pg_lseg);
+		pnfs_put_lseg(pgio->pg_lseg);
 		pgio->pg_lseg = NULL;
 		goto out_mds;
 	}
@@ -985,7 +985,7 @@ filelayout_clear_request_commit(struct nfs_page *req,
 out:
 	nfs_request_remove_commit_list(req, cinfo);
 	spin_unlock(cinfo->lock);
-	put_lseg(freeme);
+	pnfs_put_lseg(freeme);
 }
 
 static struct list_head *
@@ -1018,7 +1018,7 @@ filelayout_choose_commit_list(struct nfs_page *req,
 		 * off due to a rewrite, in which case it will be done in
 		 * filelayout_clear_request_commit
 		 */
-		buckets[i].wlseg = get_lseg(lseg);
+		buckets[i].wlseg = pnfs_get_lseg(lseg);
 	}
 	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 	cinfo->ds->nwritten++;
@@ -1128,7 +1128,7 @@ filelayout_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 		if (list_empty(src))
 			bucket->wlseg = NULL;
 		else
-			get_lseg(bucket->clseg);
+			pnfs_get_lseg(bucket->clseg);
 	}
 	return ret;
 }
@@ -1159,12 +1159,12 @@ static void filelayout_recover_commit_reqs(struct list_head *dst,
 
 	/* NOTE cinfo->lock is NOT held, relying on fact that this is
 	 * only called on single thread per dreq.
-	 * Can't take the lock because need to do put_lseg
+	 * Can't take the lock because need to do pnfs_put_lseg
 	 */
 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
 		if (transfer_commit_list(&b->written, dst, cinfo, 0)) {
 			BUG_ON(!list_empty(&b->written));
-			put_lseg(b->wlseg);
+			pnfs_put_lseg(b->wlseg);
 			b->wlseg = NULL;
 		}
 	}
@@ -1200,7 +1200,7 @@ alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
 		if (list_empty(&bucket->committing))
 			continue;
 		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
-		put_lseg(bucket->clseg);
+		pnfs_put_lseg(bucket->clseg);
 		bucket->clseg = NULL;
 	}
 	/* Caller will clean up entries put on list */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 20f1229..87702a0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6549,7 +6549,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 		list_del_init(&lseg->pls_lc_list);
 		if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT,
 				       &lseg->pls_flags))
-			put_lseg(lseg);
+			pnfs_put_lseg(lseg);
 	}
 
 	clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 58b06c1..44c2c85 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -259,7 +259,7 @@ static void free_lseg(struct pnfs_layout_segment *lseg)
 }
 
 static void
-put_lseg_common(struct pnfs_layout_segment *lseg)
+pnfs_put_lseg_common(struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = lseg->pls_layout->plh_inode;
 
@@ -274,7 +274,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
 }
 
 void
-put_lseg(struct pnfs_layout_segment *lseg)
+pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode;
 
@@ -288,13 +288,13 @@ put_lseg(struct pnfs_layout_segment *lseg)
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
 		LIST_HEAD(free_me);
 
-		put_lseg_common(lseg);
+		pnfs_put_lseg_common(lseg);
 		list_add(&lseg->pls_list, &free_me);
 		spin_unlock(&inode->i_lock);
 		pnfs_free_lseg_list(&free_me);
 	}
 }
-EXPORT_SYMBOL_GPL(put_lseg);
+EXPORT_SYMBOL_GPL(pnfs_put_lseg);
 
 static inline u64
 end_offset(u64 start, u64 len)
@@ -378,7 +378,7 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 		dprintk("%s: lseg %p ref %d\n", __func__, lseg,
 			atomic_read(&lseg->pls_refcount));
 		if (atomic_dec_and_test(&lseg->pls_refcount)) {
-			put_lseg_common(lseg);
+			pnfs_put_lseg_common(lseg);
 			list_add(&lseg->pls_list, tmp_list);
 			rv = 1;
 		}
@@ -914,7 +914,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(&lseg->pls_range, range)) {
-			ret = get_lseg(lseg);
+			ret = pnfs_get_lseg(lseg);
 			break;
 		}
 		if (lseg->pls_range.offset > range->offset)
@@ -1135,7 +1135,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
-	get_lseg(lseg);
+	pnfs_get_lseg(lseg);
 	pnfs_insert_layout(lo, lseg);
 
 	if (res->return_on_close) {
@@ -1369,12 +1369,12 @@ pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *he
 		if (trypnfs == PNFS_NOT_ATTEMPTED)
 			pnfs_write_through_mds(desc, data);
 	}
-	put_lseg(lseg);
+	pnfs_put_lseg(lseg);
 }
 
 static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
-	put_lseg(hdr->lseg);
+	pnfs_put_lseg(hdr->lseg);
 	nfs_writehdr_free(hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
@@ -1389,17 +1389,17 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	whdr = nfs_writehdr_alloc();
 	if (!whdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-		put_lseg(desc->pg_lseg);
+		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 		return -ENOMEM;
 	}
 	hdr = &whdr->header;
 	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
-	hdr->lseg = get_lseg(desc->pg_lseg);
+	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_flush(desc, hdr);
 	if (ret != 0) {
-		put_lseg(desc->pg_lseg);
+		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
 		pnfs_do_multiple_writes(desc, &hdr->rpc_list, desc->pg_ioflags);
@@ -1524,12 +1524,12 @@ pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *hea
 		if (trypnfs == PNFS_NOT_ATTEMPTED)
 			pnfs_read_through_mds(desc, data);
 	}
-	put_lseg(lseg);
+	pnfs_put_lseg(lseg);
 }
 
 static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
 {
-	put_lseg(hdr->lseg);
+	pnfs_put_lseg(hdr->lseg);
 	nfs_readhdr_free(hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_readhdr_free);
@@ -1545,17 +1545,17 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	if (!rhdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		ret = -ENOMEM;
-		put_lseg(desc->pg_lseg);
+		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 		return ret;
 	}
 	hdr = &rhdr->header;
 	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
-	hdr->lseg = get_lseg(desc->pg_lseg);
+	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pagein(desc, hdr);
 	if (ret != 0) {
-		put_lseg(desc->pg_lseg);
+		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
 		pnfs_do_multiple_reads(desc, &hdr->rpc_list);
@@ -1608,7 +1608,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 	}
 	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &hdr->lseg->pls_flags)) {
 		/* references matched in nfs4_layoutcommit_release */
-		get_lseg(hdr->lseg);
+		pnfs_get_lseg(hdr->lseg);
 	}
 	if (end_pos > nfsi->layout->plh_lwb)
 		nfsi->layout->plh_lwb = end_pos;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2af681f..0495879 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -177,7 +177,7 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
 /* pnfs.c */
 void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
-void put_lseg(struct pnfs_layout_segment *lseg);
+void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
 
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   const struct nfs_pgio_completion_ops *);
@@ -281,7 +281,7 @@ static inline int lo_fail_bit(u32 iomode)
 }
 
 static inline struct pnfs_layout_segment *
-get_lseg(struct pnfs_layout_segment *lseg)
+pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
 	if (lseg) {
 		atomic_inc(&lseg->pls_refcount);
@@ -406,12 +406,12 @@ static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
 }
 
 static inline struct pnfs_layout_segment *
-get_lseg(struct pnfs_layout_segment *lseg)
+pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
 	return NULL;
 }
 
-static inline void put_lseg(struct pnfs_layout_segment *lseg)
+static inline void pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 {
 }
 
-- 
1.7.11.4


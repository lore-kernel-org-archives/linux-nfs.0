Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52146 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622Ab2ISBgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Sep 2012 21:36:03 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] NFSv4.1: Cleanup; add "pnfs_" prefix to get_layout_hdr() and put_layout_hdr()
Date: Tue, 18 Sep 2012 21:35:49 -0400
Message-Id: <1348018554-63137-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348018554-63137-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1348018554-63137-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348018554-63137-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |  8 ++++----
 fs/nfs/nfs4proc.c      |  2 +-
 fs/nfs/pnfs.c          | 26 +++++++++++++-------------
 fs/nfs/pnfs.h          |  4 ++--
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 57b8bda..24252fe 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -122,7 +122,7 @@ static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
 			ino = igrab(lo->plh_inode);
 			if (!ino)
 				continue;
-			get_layout_hdr(lo);
+			pnfs_get_layout_hdr(lo);
 			return lo;
 		}
 	}
@@ -166,7 +166,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
-	put_layout_hdr(lo);
+	pnfs_put_layout_hdr(lo);
 	iput(ino);
 	return rv;
 }
@@ -198,7 +198,7 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 		list_for_each_entry(lo, &server->layouts, plh_layouts) {
 			if (!igrab(lo->plh_inode))
 				continue;
-			get_layout_hdr(lo);
+			pnfs_get_layout_hdr(lo);
 			BUG_ON(!list_empty(&lo->plh_bulk_recall));
 			list_add(&lo->plh_bulk_recall, &recall_list);
 		}
@@ -216,7 +216,7 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 		list_del_init(&lo->plh_bulk_recall);
 		spin_unlock(&ino->i_lock);
 		pnfs_free_lseg_list(&free_me_list);
-		put_layout_hdr(lo);
+		pnfs_put_layout_hdr(lo);
 		iput(ino);
 	}
 	return rv;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b738577..20f1229 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6375,7 +6375,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 	struct nfs4_layoutreturn *lrp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	put_layout_hdr(lrp->args.layout);
+	pnfs_put_layout_hdr(lrp->args.layout);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index aea2e52..58b06c1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -221,7 +221,7 @@ destroy_layout_hdr(struct pnfs_layout_hdr *lo)
 }
 
 static void
-put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
+pnfs_put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 {
 	if (atomic_dec_and_test(&lo->plh_refcount))
 		destroy_layout_hdr(lo);
@@ -254,8 +254,8 @@ static void free_lseg(struct pnfs_layout_segment *lseg)
 	struct inode *ino = lseg->pls_layout->plh_inode;
 
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	/* Matched by get_layout_hdr in pnfs_insert_layout */
-	put_layout_hdr(NFS_I(ino)->layout);
+	/* Matched by pnfs_get_layout_hdr in pnfs_insert_layout */
+	pnfs_put_layout_hdr(NFS_I(ino)->layout);
 }
 
 static void
@@ -268,7 +268,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
 	if (list_empty(&lseg->pls_layout->plh_segs)) {
 		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
 		/* Matched by initial refcount set in alloc_init_layout_hdr */
-		put_layout_hdr_locked(lseg->pls_layout);
+		pnfs_put_layout_hdr_locked(lseg->pls_layout);
 	}
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
@@ -404,7 +404,7 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 		NFS_I(lo->plh_inode)->write_io = 0;
 		NFS_I(lo->plh_inode)->read_io = 0;
 		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
-			put_layout_hdr_locked(lo);
+			pnfs_put_layout_hdr_locked(lo);
 		return 0;
 	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
@@ -649,13 +649,13 @@ _pnfs_return_layout(struct inode *ino)
 	}
 	stateid = nfsi->layout->plh_stateid;
 	/* Reference matched in nfs4_layoutreturn_release */
-	get_layout_hdr(lo);
+	pnfs_get_layout_hdr(lo);
 	empty = list_empty(&lo->plh_segs);
 	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
 	/* Don't send a LAYOUTRETURN if list was initially empty */
 	if (empty) {
 		spin_unlock(&ino->i_lock);
-		put_layout_hdr(lo);
+		pnfs_put_layout_hdr(lo);
 		dprintk("NFS: %s no layout segments to return\n", __func__);
 		goto out;
 	}
@@ -672,7 +672,7 @@ _pnfs_return_layout(struct inode *ino)
 		set_bit(NFS_LAYOUT_RW_FAILED, &lo->plh_flags);
 		set_bit(NFS_LAYOUT_RO_FAILED, &lo->plh_flags);
 		pnfs_clear_layout_returned(lo);
-		put_layout_hdr(lo);
+		pnfs_put_layout_hdr(lo);
 		goto out;
 	}
 
@@ -709,7 +709,7 @@ bool pnfs_roc(struct inode *ino)
 	if (!found)
 		goto out_nolayout;
 	lo->plh_block_lgets++;
-	get_layout_hdr(lo); /* matched in pnfs_roc_release */
+	pnfs_get_layout_hdr(lo); /* matched in pnfs_roc_release */
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 	return true;
@@ -726,7 +726,7 @@ void pnfs_roc_release(struct inode *ino)
 	spin_lock(&ino->i_lock);
 	lo = NFS_I(ino)->layout;
 	lo->plh_block_lgets--;
-	put_layout_hdr_locked(lo);
+	pnfs_put_layout_hdr_locked(lo);
 	spin_unlock(&ino->i_lock);
 }
 
@@ -819,7 +819,7 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 		__func__, lseg, lseg->pls_range.iomode,
 		lseg->pls_range.offset, lseg->pls_range.length);
 out:
-	get_layout_hdr(lo);
+	pnfs_get_layout_hdr(lo);
 
 	dprintk("%s:Return\n", __func__);
 }
@@ -1058,7 +1058,7 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 
-	get_layout_hdr(lo);
+	pnfs_get_layout_hdr(lo);
 	if (list_empty(&lo->plh_segs))
 		first = true;
 
@@ -1091,7 +1091,7 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&clp->cl_lock);
 	}
 	atomic_dec(&lo->plh_outstanding);
-	put_layout_hdr(lo);
+	pnfs_put_layout_hdr(lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6af5189..2af681f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -176,7 +176,7 @@ extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lg
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
 /* pnfs.c */
-void get_layout_hdr(struct pnfs_layout_hdr *lo);
+void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
@@ -196,7 +196,7 @@ struct pnfs_layout_segment *pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
-void put_layout_hdr(struct pnfs_layout_hdr *lo);
+void pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *new,
 			     bool update_barrier);
-- 
1.7.11.4


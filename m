Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59485 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849Ab0JGQhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 12:37:17 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@rhel6-1.androsmac.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/3] pnfs_submit: fix deadlock in pnfs_clear_lseg_list
Date: Thu,  7 Oct 2010 12:37:09 -0700
Message-Id: <1286480230-9418-2-git-send-email-andros@netapp.com>
In-Reply-To: <1286480230-9418-1-git-send-email-andros@netapp.com>
References: <1286480230-9418-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@rhel6-1.androsmac.org>

The file layout free_lseg i/o operation called by destroy_lseg under the
inode->i_lock can call nfs_put_client() when a data
server is no longer referenced. nfs_put_client can end up taking the
i_mutex called in rpc_unlink (called from nfs_idmap_delete from
nfs_free_client) which can result in a deadlock.

Use a temporary list to hold layout segments to be freed, and free them outside
the inode->i_lock.

Reported-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   53 ++++++++++++++++++++++++++---------------------------
 fs/nfs/pnfs.h |    1 -
 2 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 24620cf..06fcc92 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -275,6 +275,7 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	lseg->layout = lo;
 }
 
+/* Called without i_lock held */
 static void
 destroy_lseg(struct kref *kref)
 {
@@ -285,29 +286,10 @@ destroy_lseg(struct kref *kref)
 	dprintk("--> %s\n", __func__);
 	NFS_SERVER(local->inode)->pnfs_curr_ld->free_lseg(lseg);
 	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
-	put_layout_hdr_locked(local);
+	put_layout_hdr(local->inode);
 }
 
 void
-put_lseg_locked(struct pnfs_layout_segment *lseg)
-{
-	bool do_wake_up;
-	struct nfs_inode *nfsi;
-
-	if (!lseg)
-		return;
-
-	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->kref.refcount), lseg->valid);
-	do_wake_up = !lseg->valid;
-	nfsi = NFS_I(lseg->layout->inode);
-	kref_put(&lseg->kref, destroy_lseg);
-	if (do_wake_up)
-		wake_up(&nfsi->lo_waitq);
-}
-EXPORT_SYMBOL_GPL(put_lseg_locked);
-
-void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
 	bool do_wake_up;
@@ -320,9 +302,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		atomic_read(&lseg->kref.refcount), lseg->valid);
 	do_wake_up = !lseg->valid;
 	nfsi = NFS_I(lseg->layout->inode);
-	spin_lock(&nfsi->vfs_inode.i_lock);
 	kref_put(&lseg->kref, destroy_lseg);
-	spin_unlock(&nfsi->vfs_inode.i_lock);
 	if (do_wake_up)
 		wake_up(&nfsi->lo_waitq);
 }
@@ -354,10 +334,11 @@ _pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
 }
 
 static void
-pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo,
+pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		     struct pnfs_layout_range *range)
 {
 	struct pnfs_layout_segment *lseg, *next;
+
 	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
 		__func__, lo, range->offset, range->length, range->iomode);
 
@@ -370,8 +351,7 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo,
 			"offset %llu length %llu\n", __func__,
 			lseg, lseg->range.iomode, lseg->range.offset,
 			lseg->range.length);
-		list_del(&lseg->fi_list);
-		put_lseg_locked(lseg);
+		list_move(&lseg->fi_list, tmp_list);
 	}
 	if (list_empty(&lo->segs)) {
 		struct nfs_client *clp;
@@ -387,6 +367,21 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Return\n", __func__);
 }
 
+static void
+pnfs_free_lseg_list(struct list_head *tmp_list)
+{
+	struct pnfs_layout_segment *lseg;
+
+	while (!list_empty(tmp_list)) {
+		lseg = list_entry(tmp_list->next, struct pnfs_layout_segment,
+				fi_list);
+		dprintk("%s calling put_lseg on %p\n", __func__, lseg);
+		list_del(&lseg->fi_list);
+		put_lseg(lseg);
+	}
+}
+
+
 void
 pnfs_layoutget_release(struct pnfs_layout_hdr *lo)
 {
@@ -403,12 +398,14 @@ pnfs_layoutreturn_release(struct pnfs_layout_hdr *lo,
 			  struct pnfs_layout_range *range)
 {
 	struct nfs_inode *nfsi = NFS_I(lo->inode);
+	LIST_HEAD(tmp_list);
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (range)
-		pnfs_clear_lseg_list(lo, range);
+		pnfs_clear_lseg_list(lo, &tmp_list, range);
 	put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
 	spin_unlock(&nfsi->vfs_inode.i_lock);
+	pnfs_free_lseg_list(&tmp_list);
 	wake_up_all(&nfsi->lo_waitq);
 }
 
@@ -421,11 +418,12 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		.offset = 0,
 		.length = NFS4_MAX_UINT64,
 	};
+	LIST_HEAD(tmp_list);
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	lo = nfsi->layout;
 	if (lo) {
-		pnfs_clear_lseg_list(lo, &range);
+		pnfs_clear_lseg_list(lo, &tmp_list,  &range);
 		WARN_ON(!list_empty(&nfsi->layout->segs));
 		WARN_ON(!list_empty(&nfsi->layout->layouts));
 		WARN_ON(nfsi->layout->refcount != 1);
@@ -434,6 +432,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		put_layout_hdr_locked(lo);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
+	pnfs_free_lseg_list(&tmp_list);
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1b1efcd..51f717d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -177,7 +177,6 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
 
 /* pnfs.c */
 void put_lseg(struct pnfs_layout_segment *lseg);
-void put_lseg_locked(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *
 pnfs_has_layout(struct pnfs_layout_hdr *lo, struct pnfs_layout_range *range);
 struct pnfs_layout_segment *
-- 
1.6.6


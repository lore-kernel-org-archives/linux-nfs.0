From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 3/3] pnfs-submit: remove list_empty check from put_layout
Date: Wed, 16 Jun 2010 19:44:48 -0400
Message-ID: <1276731888-3202-3-git-send-email-iisaman@netapp.com>
References: <1276731888-3202-1-git-send-email-iisaman@netapp.com>
 <1276731888-3202-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:48107 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757504Ab0FRQcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jun 2010 12:32:20 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id F3483180AE
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 12:32:19 -0400 (EDT)
In-Reply-To: <1276731888-3202-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The check on list empty before destroying a layout has always bothered me.
Get rid of it by having lsegs take a reference on their backpointer.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   55 +++++++++++++++++++++++++++++++++----------------------
 1 files changed, 33 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 49093a0..c939cb0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -60,6 +60,7 @@ static int pnfs_initialized;
 static void pnfs_free_layout(struct pnfs_layout_type *lo,
 			     struct nfs4_pnfs_layout_segment *range);
 static enum pnfs_try_status pnfs_commit(struct nfs_write_data *data, int sync);
+static inline void get_layout(struct pnfs_layout_type *lo);
 
 /* Locking:
  *
@@ -153,6 +154,7 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
 		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
+		get_layout(&nfsi->layout);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->vfs_inode.i_lock);
 		dprintk("%s: Set layoutcommit\n", __func__);
@@ -335,25 +337,18 @@ grab_current_layout(struct nfs_inode *nfsi)
 static inline void
 put_layout(struct pnfs_layout_type *lo)
 {
-	struct inode *inode = PNFS_INODE(lo);
-	struct nfs_client *clp;
-
 	BUG_ON_UNLOCKED_LO(lo);
 	BUG_ON(lo->refcount <= 0);
 
-	if (--lo->refcount == 0 && list_empty(&lo->segs)) {
+	lo->refcount--;
+	if (!lo->refcount) {
 		struct layoutdriver_io_operations *io_ops =
 			PNFS_LD_IO_OPS(lo);
 
 		dprintk("%s: freeing layout %p\n", __func__, lo->ld_data);
+		WARN_ON(!list_empty(&lo->lo_layouts));
 		io_ops->free_layout(lo->ld_data);
 		lo->ld_data = NULL;
-
-		/* Unlist the layout. */
-		clp = NFS_SERVER(inode)->nfs_client;
-		spin_lock(&clp->cl_lock);
-		list_del_init(&lo->lo_layouts);
-		spin_unlock(&clp->cl_lock);
 	}
 }
 
@@ -397,6 +392,7 @@ init_lseg(struct pnfs_layout_type *lo, struct pnfs_layout_segment *lseg)
 	kref_init(&lseg->kref);
 	lseg->valid = true;
 	lseg->layout = lo;
+	get_layout(lo);
 }
 
 static void
@@ -406,6 +402,7 @@ destroy_lseg(struct kref *kref)
 		container_of(kref, struct pnfs_layout_segment, kref);
 
 	dprintk("--> %s\n", __func__);
+	put_layout(lseg->layout);
 	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
 }
 
@@ -669,6 +666,15 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 			lseg->range.length);
 		list_del(&lseg->fi_list);
 		put_lseg_locked(lseg);
+		if (list_empty(&lo->segs)) {
+			struct nfs_client *clp;
+
+			clp = PNFS_NFS_SERVER(lo)->nfs_client;
+			spin_lock(&clp->cl_lock);
+			list_del_init(&lo->lo_layouts);
+			spin_unlock(&clp->cl_lock);
+			put_layout(lo);
+		}
 	}
 
 	dprintk("%s:Return\n", __func__);
@@ -854,6 +860,15 @@ pnfs_insert_layout(struct pnfs_layout_type *lo,
 	dprintk("%s:Begin\n", __func__);
 
 	BUG_ON_UNLOCKED_LO(lo);
+	if (list_empty(&lo->segs)) {
+		struct nfs_client *clp = PNFS_NFS_SERVER(lo)->nfs_client;
+
+		spin_lock(&clp->cl_lock);
+		BUG_ON(!list_empty(&lo->lo_layouts));
+		list_add_tail(&lo->lo_layouts, &clp->cl_layouts);
+		spin_unlock(&clp->cl_lock);
+		get_layout(lo);
+	}
 	list_for_each_entry (lp, &lo->segs, fi_list) {
 		if (cmp_layout(&lp->range, &lseg->range) > 0)
 			continue;
@@ -896,11 +911,13 @@ alloc_init_layout(struct inode *ino)
 		return NULL;
 	}
 
+	spin_lock(&ino->i_lock);
 	BUG_ON(lo->ld_data != NULL);
 	lo->ld_data = ld_data;
 	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
 	lo->refcount = 1;
 	lo->roc_iomode = 0;
+	spin_unlock(&ino->i_lock);
 	return lo;
 }
 
@@ -951,17 +968,9 @@ get_lock_alloc_layout(struct inode *ino)
 		}
 
 		lo = alloc_init_layout(ino);
-		if (lo) {
-			struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
-
-			/* must grab the layout lock before the client lock */
+		if (lo)
 			spin_lock(&ino->i_lock);
-
-			spin_lock(&clp->cl_lock);
-			if (list_empty(&lo->lo_layouts))
-				list_add_tail(&lo->lo_layouts, &clp->cl_layouts);
-			spin_unlock(&clp->cl_lock);
-		} else
+		else
 			lo = ERR_PTR(-ENOMEM);
 
 		/* release the NFS_INO_LAYOUT_ALLOC bit and wake up waiters */
@@ -1247,14 +1256,13 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
 		goto out;
 	}
 
+	spin_lock(&ino->i_lock);
 	init_lseg(lo, lseg);
 	lseg->range = res->lseg;
 	if (lgp->lsegpp) {
 		get_lseg(lseg);
 		*lgp->lsegpp = lseg;
 	}
-
-	spin_lock(&ino->i_lock);
 	pnfs_insert_layout(lo, lseg);
 
 	if (res->return_on_close) {
@@ -1642,6 +1650,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	}
 	status = pnfs4_proc_layoutcommit(data, sync);
 out:
+	spin_lock(&inode->i_lock);
+	put_layout(&nfsi->layout);
+	spin_unlock(&inode->i_lock);
 	dprintk("%s end (err:%d)\n", __func__, status);
 	return status;
 out_free:
-- 
1.6.6.1


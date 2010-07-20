From: andros@netapp.com
Subject: [PATCH 1/5] SQUASHME pnfs-submit alloc layout don't call put_layout under spin lock
Date: Tue, 20 Jul 2010 13:01:19 -0400
Message-ID: <1279645283-9862-2-git-send-email-andros@netapp.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33574 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761374Ab0GTRB6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 13:01:58 -0400
In-Reply-To: <1279645283-9862-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Remove the pnfs_alloc_layout call to put_layout_locked under the i_lock.

Combine the search for an lseg range with the potential allocation of the
pnfs_layout_type. Return a referenced layout segment or NULL with a reference
taken on the layout in preparation for a layoutget call

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |  117 +++++++++++++++++++++------------------------------------
 1 files changed, 43 insertions(+), 74 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index fd979ec..77e6671 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -863,40 +863,6 @@ alloc_init_layout(struct inode *ino)
 }
 
 /*
- * Retrieve and possibly allocate the inode layout
- *
- * ino->i_lock must be taken by the caller.
- */
-static struct pnfs_layout_type *
-pnfs_alloc_layout(struct inode *ino)
-{
-	struct nfs_inode *nfsi = NFS_I(ino);
-	struct pnfs_layout_type *new = NULL;
-
-	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
-
-	BUG_ON_UNLOCKED_INO(ino);
-	if (likely(nfsi->layout))
-		return nfsi->layout;
-
-	spin_unlock(&ino->i_lock);
-	new = alloc_init_layout(ino);
-	spin_lock(&ino->i_lock);
-
-	if (likely(nfsi->layout == NULL)) {	/* Won the race? */
-		nfsi->layout = new;
-	} else if (new) {
-		/* Reference the layout accross i_lock release and grab */
-		get_layout(nfsi->layout);
-		spin_unlock(&ino->i_lock);
-		NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->free_layout(new);
-		spin_lock(&ino->i_lock);
-		put_layout_locked(nfsi->layout);
-	}
-	return nfsi->layout;
-}
-
-/*
  * iomode matching rules:
  * range	lseg	match
  * -----	-----	-----
@@ -915,28 +881,52 @@ has_matching_lseg(struct pnfs_layout_segment *lseg,
 }
 
 /*
- * lookup range in layout
+ * Lookup range in layout. Return a referenced layout segment or
+ * NULL with a reference on the layout in preparation for a layoutget call.
  */
 static struct pnfs_layout_segment *
-pnfs_has_layout(struct pnfs_layout_type *lo,
-		struct nfs4_pnfs_layout_segment *range)
+pnfs_get_layout_segment(struct inode *inode,
+			struct nfs4_pnfs_layout_segment *range)
 {
 	struct pnfs_layout_segment *lseg, *ret = NULL;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct pnfs_layout_type *new = NULL;
 
 	dprintk("%s:Begin\n", __func__);
-
-	BUG_ON_UNLOCKED_LO(lo);
-	list_for_each_entry (lseg, &lo->segs, fi_list) {
-		if (has_matching_lseg(lseg, range)) {
+	spin_lock(&inode->i_lock);
+	if (nfsi->layout == NULL) {
+		spin_unlock(&inode->i_lock);
+		new = alloc_init_layout(inode);
+		if (new == NULL)
+			goto out;
+		spin_lock(&inode->i_lock);
+		if (NFS_I(inode)->layout == NULL) {
+			NFS_I(inode)->layout = new;
+			new = NULL;
+		}
+	}
+	/* Is there a layout segment covering requested range? */
+	list_for_each_entry(lseg, &NFS_I(inode)->layout->segs, fi_list) {
+		if (has_matching_lseg(lseg, range) && lseg->valid) {
 			ret = lseg;
 			get_lseg(ret);
-			break;
+			goto out_unlock;
 		}
 		if (cmp_layout(range, &lseg->range) > 0)
 			break;
 	}
+	/*
+	 * No layout segment. Reference the layout for layoutget
+	 * (matched in pnfs_layout_release)
+	 */
+	get_layout(NFS_I(inode)->layout);
 
-	dprintk("%s:Return lseg %p ref %d valid %d\n",
+out_unlock:
+	spin_unlock(&inode->i_lock);
+	if (new)
+		NFS_SERVER(inode)->pnfs_curr_ld->ld_io_ops->free_layout(new);
+out:
+	dprintk("<-- %s lseg %p ref %d valid %d\n",
 		__func__, ret, ret ? atomic_read(&ret->kref.refcount) : 0,
 		ret ? ret->valid : 0);
 	return ret;
@@ -958,26 +948,10 @@ _pnfs_update_layout(struct inode *ino,
 		.length = NFS4_MAX_UINT64,
 	};
 	struct nfs_inode *nfsi = NFS_I(ino);
-	struct pnfs_layout_type *lo;
 	struct pnfs_layout_segment *lseg = NULL;
 
 	*lsegpp = NULL;
-	spin_lock(&ino->i_lock);
-	lo = pnfs_alloc_layout(ino);
-	if (lo == NULL) {
-		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
-		goto out_unlock;
-	}
-
-	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_has_layout(lo, &arg);
-	if (lseg && !lseg->valid) {
-		put_lseg_locked(lseg);
-		/* someone is cleaning the layout */
-		lseg = NULL;
-		goto out_unlock;
-	}
-
+	lseg = pnfs_get_layout_segment(ino, &arg);
 	if (lseg) {
 		dprintk("%s: Using cached lseg %p for %llu@%llu iomode %d)\n",
 			__func__,
@@ -985,35 +959,30 @@ _pnfs_update_layout(struct inode *ino,
 			arg.length,
 			arg.offset,
 			arg.iomode);
-
-		goto out_unlock;
+		*lsegpp = lseg;
+		goto out;
 	}
 
-	/* if get layout already failed once goto out */
+	/* if layoutget failed wait pnfs_layout_suspend time to retry */
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->pnfs_layout_state)) {
 		if (unlikely(nfsi->pnfs_layout_suspend &&
 		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
 			dprintk("%s: layout_get resumed\n", __func__);
+			spin_lock(&ino->i_lock);
 			clear_bit(lo_fail_bit(iomode),
 				  &nfsi->layout->pnfs_layout_state);
 			nfsi->pnfs_layout_suspend = 0;
-		} else
-			goto out_unlock;
+			spin_unlock(&ino->i_lock);
+		} else {
+			goto out;
+		}
 	}
 
-	/* Reference the layout for layoutget matched in pnfs_layout_release */
-	get_layout(lo);
-	spin_unlock(&ino->i_lock);
-
-	send_layoutget(ino, ctx, &arg, lsegpp, lo);
+	send_layoutget(ino, ctx, &arg, lsegpp, nfsi->layout);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->pnfs_layout_state, lseg);
 	return;
-out_unlock:
-	*lsegpp = lseg;
-	spin_unlock(&ino->i_lock);
-	goto out;
 }
 
 void
-- 
1.6.6


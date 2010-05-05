From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 3/8] pnfs-submit: remove lgetcount, lretcount (outstanding LAYOUTGETs/LAYOUTRETUNs)
Date: Wed,  5 May 2010 10:00:53 -0700
Message-ID: <1273078858-1923-4-git-send-email-batsakis@netapp.com>
References: <1273078858-1923-1-git-send-email-batsakis@netapp.com>
 <1273078858-1923-2-git-send-email-batsakis@netapp.com>
 <1273078858-1923-3-git-send-email-batsakis@netapp.com>
Cc: bhalevy@panasas.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24594 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983Ab0FGF11 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 01:27:27 -0400
In-Reply-To: <1273078858-1923-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is in order to prepare for the forgetful client. There is no need to explicitly count the number of outstanding layout operations, as the protocol has provision for it (seqid of stateid -- e.g. section 12.5.5.2.1.2). As long as no requests for intersecting layouts are issued LAYOUTGETs/LAYOUTRETURNs can be sent in parallel

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c      |    5 ++---
 fs/nfs/pnfs.c          |   46 ++++++++++++----------------------------------
 fs/nfs/pnfs.h          |    3 +--
 include/linux/nfs_fs.h |    2 --
 4 files changed, 15 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c01ecd7..a89a290 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5503,7 +5503,7 @@ static void nfs4_pnfs_layoutget_release(void *calldata)
 	struct nfs4_pnfs_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	pnfs_layout_release(lgp->lo, &lgp->lo->lgetcount, NULL);
+	pnfs_layout_release(lgp->lo, NULL);
 	if (lgp->res.layout.buf != NULL)
 		free_page((unsigned long) lgp->res.layout.buf);
 	kfree(calldata);
@@ -5724,8 +5724,7 @@ static void nfs4_pnfs_layoutreturn_release(void *calldata)
 	if (lrp->lo && (lrp->args.return_type == RETURN_FILE)) {
 		if (!lrp->res.lrs_present)
 			pnfs_set_layout_stateid(lrp->lo, &zero_stateid);
-		pnfs_layout_release(lrp->lo, &lrp->lo->lretcount,
-				    &lrp->args.lseg);
+		pnfs_layout_release(lrp->lo, &lrp->args.lseg);
 	}
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a4031b4..c4c7c35 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -381,7 +381,7 @@ out:
 }
 
 void
-pnfs_layout_release(struct pnfs_layout_type *lo, atomic_t *count,
+pnfs_layout_release(struct pnfs_layout_type *lo,
 		    struct nfs4_pnfs_layout_segment *range)
 {
 	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
@@ -389,7 +389,6 @@ pnfs_layout_release(struct pnfs_layout_type *lo, atomic_t *count,
 	lock_current_layout(nfsi);
 	if (range)
 		pnfs_free_layout(lo, range);
-	atomic_dec(count);
 	put_unlock_current_layout(lo);
 	wake_up_all(&nfsi->lo_waitq);
 }
@@ -574,7 +573,7 @@ get_layout(struct inode *ino,
 
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
 	if (lgp == NULL) {
-		pnfs_layout_release(lo, &lo->lgetcount, NULL);
+		pnfs_layout_release(lo, NULL);
 		return -ENOMEM;
 	}
 	lgp->lo = lo;
@@ -648,6 +647,13 @@ has_layout_to_return(struct pnfs_layout_type *lo,
 	return out;
 }
 
+static inline bool
+_pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
+{
+	return atomic_read(&lseg->kref.refcount) == 1;
+}
+
+
 static void
 pnfs_free_layout(struct pnfs_layout_type *lo,
 		 struct nfs4_pnfs_layout_segment *range)
@@ -658,7 +664,8 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 
 	BUG_ON_UNLOCKED_LO(lo);
 	list_for_each_entry_safe (lseg, next, &lo->segs, fi_list) {
-		if (!should_free_lseg(lseg, range))
+		if (!should_free_lseg(lseg, range) ||
+		    !_pnfs_can_return_lseg(lseg))
 			continue;
 		dprintk("%s: freeing lseg %p iomode %d "
 			"offset %llu length %llu\n", __func__,
@@ -671,12 +678,6 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 	dprintk("%s:Return\n", __func__);
 }
 
-static inline bool
-_pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
-{
-	return atomic_read(&lseg->kref.refcount) == 1;
-}
-
 static bool
 pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 			   struct nfs4_pnfs_layout_segment *range)
@@ -696,8 +697,6 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 			ret = true;
 		}
 	}
-	if (atomic_read(&nfsi->layout.lgetcount))
-		ret = true;
 	unlock_current_layout(nfsi);
 
 	dprintk("%s:Return %d\n", __func__, ret);
@@ -719,7 +718,7 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (lrp == NULL) {
 		if (lo && (type == RETURN_FILE))
-			pnfs_layout_release(lo, &lo->lretcount, NULL);
+			pnfs_layout_release(lo, NULL);
 		goto out;
 	}
 	lrp->args.reclaim = 0;
@@ -774,9 +773,6 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 				goto out;
 		}
 
-		/* Matching dec is done in .rpc_release (on non-error paths) */
-		atomic_inc(&lo->lretcount);
-
 		/* unlock w/o put rebalanced by eventual call to
 		 * pnfs_layout_release
 		 */
@@ -901,8 +897,6 @@ alloc_init_layout(struct inode *ino)
 	seqlock_init(&lo->seqlock);
 	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
 	lo->refcount = 1;
-	atomic_set(&lo->lgetcount, 0);
-	atomic_set(&lo->lretcount, 0);
 	INIT_LIST_HEAD(&lo->segs);
 	lo->roc_iomode = 0;
 	return lo;
@@ -1066,19 +1060,6 @@ pnfs_find_get_lseg(struct inode *inode,
 	return lseg;
 }
 
-/* Called with spin lock held */
-void drain_layoutreturns(struct pnfs_layout_type *lo)
-{
-	while (atomic_read(&lo->lretcount)) {
-		struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
-
-		unlock_current_layout(nfsi);
-		dprintk("%s: waiting\n", __func__);
-		wait_event(nfsi->lo_waitq, (atomic_read(&lo->lretcount) == 0));
-		lock_current_layout(nfsi);
-	}
-}
-
 /* Update the file's layout for the given range and iomode.
  * Layout is retreived from the server if needed.
  * If lsegpp is given, the appropriate layout segment is referenced and
@@ -1166,9 +1147,6 @@ pnfs_update_layout(struct inode *ino,
 		}
 	}
 
-	drain_layoutreturns(lo);
-	/* Matching dec is done in .rpc_release (on non-error paths) */
-	atomic_inc(&lo->lgetcount);
 	/* Lose lock, but not reference, match this with pnfs_layout_release */
 	unlock_current_layout(nfsi);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f1132b3..908d32b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -68,8 +68,7 @@ void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
 ssize_t pnfs_file_write(struct file *, const char __user *, size_t, loff_t *);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
-void pnfs_layout_release(struct pnfs_layout_type *, atomic_t *,
-			 struct nfs4_pnfs_layout_segment *range);
+void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 787d2f4..eb95dbf 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -99,8 +99,6 @@ struct posix_acl;
 
 struct pnfs_layout_type {
 	int refcount;
-	atomic_t lretcount;		/* Layoutreturns outstanding */
-	atomic_t lgetcount;		/* Layoutgets outstanding */
 	struct list_head segs;		/* layout segments list */
 	int roc_iomode;			/* iomode to return on close, 0=none */
 	seqlock_t seqlock;		/* Protects the stateid */
-- 
1.6.2.5


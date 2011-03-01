Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757110Ab1CAR3o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 12:29:44 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH pNFS wave 3 Version 3 08/18] NFSv4.1: lseg refcounting
Date: Mon, 28 Feb 2011 20:34:13 -0500
Message-Id: <1298943263-2886-9-git-send-email-andros@netapp.com>
In-Reply-To: <1298943263-2886-8-git-send-email-andros@netapp.com>
References: <1298943263-2886-1-git-send-email-andros@netapp.com>
 <1298943263-2886-2-git-send-email-andros@netapp.com>
 <1298943263-2886-3-git-send-email-andros@netapp.com>
 <1298943263-2886-4-git-send-email-andros@netapp.com>
 <1298943263-2886-5-git-send-email-andros@netapp.com>
 <1298943263-2886-6-git-send-email-andros@netapp.com>
 <1298943263-2886-7-git-send-email-andros@netapp.com>
 <1298943263-2886-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Prepare put_lseg and get_lseg to be called from the pNFS I/O code.
Pull common code from pnfs_lseg_locked to call from pnfs_lseg.
Inline pnfs_lseg_locked into it's only caller.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   62 +++++++++++++++++++++++++++++++++++---------------------
 fs/nfs/pnfs.h |   20 ++++++++++++++++++
 2 files changed, 59 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7d031cd..3afa82e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -230,32 +230,41 @@ static void free_lseg(struct pnfs_layout_segment *lseg)
 	put_layout_hdr(NFS_I(ino)->layout);
 }
 
-/* The use of tmp_list is necessary because pnfs_curr_ld->free_lseg
- * could sleep, so must be called outside of the lock.
- * Returns 1 if object was removed, otherwise return 0.
- */
-static int
-put_lseg_locked(struct pnfs_layout_segment *lseg,
-		struct list_head *tmp_list)
+static void
+put_lseg_common(struct pnfs_layout_segment *lseg)
+{
+	struct inode *inode = lseg->pls_layout->plh_inode;
+
+	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
+	list_del_init(&lseg->pls_list);
+	if (list_empty(&lseg->pls_layout->plh_segs)) {
+		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
+		/* Matched by initial refcount set in alloc_init_layout_hdr */
+		put_layout_hdr_locked(lseg->pls_layout);
+	}
+	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
+}
+
+static void
+put_lseg(struct pnfs_layout_segment *lseg)
 {
+	struct inode *inode;
+
+	if (!lseg)
+		return;
+
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
 		atomic_read(&lseg->pls_refcount),
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
-	if (atomic_dec_and_test(&lseg->pls_refcount)) {
-		struct inode *ino = lseg->pls_layout->plh_inode;
+	inode = lseg->pls_layout->plh_inode;
+	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
+		LIST_HEAD(free_me);
 
-		BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
-		list_del(&lseg->pls_list);
-		if (list_empty(&lseg->pls_layout->plh_segs)) {
-			set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
-			/* Matched by initial refcount set in alloc_init_layout_hdr */
-			put_layout_hdr_locked(lseg->pls_layout);
-		}
-		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
-		list_add(&lseg->pls_list, tmp_list);
-		return 1;
+		put_lseg_common(lseg);
+		list_add(&lseg->pls_list, &free_me);
+		spin_unlock(&inode->i_lock);
+		pnfs_free_lseg_list(&free_me);
 	}
-	return 0;
 }
 
 static bool
@@ -276,7 +285,13 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 		 * list.  It will now be removed when all
 		 * outstanding io is finished.
 		 */
-		rv = put_lseg_locked(lseg, tmp_list);
+		dprintk("%s: lseg %p ref %d\n", __func__, lseg,
+			atomic_read(&lseg->pls_refcount));
+		if (atomic_dec_and_test(&lseg->pls_refcount)) {
+			put_lseg_common(lseg);
+			list_add(&lseg->pls_list, tmp_list);
+			rv = 1;
+		}
 	}
 	return rv;
 }
@@ -689,7 +704,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(lseg, iomode)) {
-			ret = lseg;
+			ret = get_lseg(lseg);
 			break;
 		}
 		if (cmp_layout(iomode, lseg->pls_range.iomode) > 0)
@@ -769,6 +784,7 @@ pnfs_update_layout(struct inode *ino,
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
+	put_lseg(lseg); /* STUB - callers currently ignore return value */
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
@@ -821,7 +837,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
-	*lgp->lsegpp = lseg;
+	*lgp->lsegpp = get_lseg(lseg);
 	pnfs_insert_layout(lo, lseg);
 
 	if (res->return_on_close) {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e2612ea..9a994bc 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -177,6 +177,16 @@ static inline int lo_fail_bit(u32 iomode)
 			 NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
 }
 
+static inline struct pnfs_layout_segment *
+get_lseg(struct pnfs_layout_segment *lseg)
+{
+	if (lseg) {
+		atomic_inc(&lseg->pls_refcount);
+		smp_mb__after_atomic_inc();
+	}
+	return lseg;
+}
+
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 {
@@ -194,6 +204,16 @@ static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
 }
 
 static inline struct pnfs_layout_segment *
+get_lseg(struct pnfs_layout_segment *lseg)
+{
+	return NULL;
+}
+
+static inline void put_lseg(struct pnfs_layout_segment *lseg)
+{
+}
+
+static inline struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type)
 {
-- 
1.6.6


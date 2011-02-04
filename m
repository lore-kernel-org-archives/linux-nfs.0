Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753100Ab1BDVeK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:10 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 01/40] pnfs-submit: wave3: lseg refcounting
Date: Fri,  4 Feb 2011 16:33:23 -0500
Message-Id: <1296855242-2592-2-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-1-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   48 ++++++++++++++++++++++++++++++++++++++----------
 fs/nfs/pnfs.h |   10 ++++++++++
 2 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0f5b66f..32ad768 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -230,6 +230,21 @@ static void free_lseg(struct pnfs_layout_segment *lseg)
 	put_layout_hdr(NFS_I(ino)->layout);
 }
 
+static void
+_put_lseg_common(struct pnfs_layout_segment *lseg)
+{
+	struct inode *ino = lseg->pls_layout->plh_inode;
+
+	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
+	list_del(&lseg->pls_list);
+	if (list_empty(&lseg->pls_layout->plh_segs)) {
+		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
+		/* Matched by initial refcount set in alloc_init_layout_hdr */
+		put_layout_hdr_locked(lseg->pls_layout);
+	}
+	rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
+}
+
 /* The use of tmp_list is necessary because pnfs_curr_ld->free_lseg
  * could sleep, so must be called outside of the lock.
  * Returns 1 if object was removed, otherwise return 0.
@@ -242,22 +257,32 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 		atomic_read(&lseg->pls_refcount),
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	if (atomic_dec_and_test(&lseg->pls_refcount)) {
-		struct inode *ino = lseg->pls_layout->plh_inode;
-
-		BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
-		list_del(&lseg->pls_list);
-		if (list_empty(&lseg->pls_layout->plh_segs)) {
-			set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
-			/* Matched by initial refcount set in alloc_init_layout_hdr */
-			put_layout_hdr_locked(lseg->pls_layout);
-		}
-		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
+		_put_lseg_common(lseg);
 		list_add(&lseg->pls_list, tmp_list);
 		return 1;
 	}
 	return 0;
 }
 
+static void
+put_lseg(struct pnfs_layout_segment *lseg)
+{
+	struct inode *ino;
+
+	if (!lseg)
+		return;
+
+	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
+		atomic_read(&lseg->pls_refcount),
+		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
+	ino = lseg->pls_layout->plh_inode;
+	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
+		_put_lseg_common(lseg);
+		spin_unlock(&ino->i_lock);
+		free_lseg(lseg);
+	}
+}
+
 static bool
 should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
 {
@@ -689,6 +714,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(lseg, iomode)) {
+			get_lseg(lseg);
 			ret = lseg;
 			break;
 		}
@@ -769,6 +795,7 @@ pnfs_update_layout(struct inode *ino,
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
+	put_lseg(lseg); /* STUB - callers currently ignore return value */
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
@@ -821,6 +848,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
+	get_lseg(lseg);
 	*lgp->lsegpp = lseg;
 	pnfs_insert_layout(lo, lseg);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e2612ea..fe50faa 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -177,6 +177,12 @@ static inline int lo_fail_bit(u32 iomode)
 			 NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
 }
 
+static inline void get_lseg(struct pnfs_layout_segment *lseg)
+{
+	atomic_inc(&lseg->pls_refcount);
+	smp_mb__after_atomic_inc();
+}
+
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 {
@@ -193,6 +199,10 @@ static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 }
 
+static inline void get_lseg(struct pnfs_layout_segment *lseg)
+{
+}
+
 static inline struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type)
-- 
1.6.6


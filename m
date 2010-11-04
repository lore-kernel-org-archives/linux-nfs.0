Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33429 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435Ab0KDPWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:51 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMO029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:36 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/18] pnfs-submit: change pnfs_layout_segment refcounting from kref to atomic_t
Date: Thu,  4 Nov 2010 11:22:15 -0400
Message-Id: <1288884151-11128-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Preparing for changes in pnfs_clear_lseg_list

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   37 ++++++++++++++-----------------------
 fs/nfs/pnfs.h |    5 +++--
 2 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 72d7ed3..3bbe3be 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -266,41 +266,32 @@ static void
 init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 {
 	INIT_LIST_HEAD(&lseg->fi_list);
-	kref_init(&lseg->kref);
+	atomic_set(&lseg->pls_refcount, 1);
+	smp_mb();
 	lseg->valid = true;
 	lseg->layout = lo;
 }
 
-/* Called without i_lock held, as the free_lseg call may sleep */
-static void
-destroy_lseg(struct kref *kref)
-{
-	struct pnfs_layout_segment *lseg =
-		container_of(kref, struct pnfs_layout_segment, kref);
-	struct inode *ino = lseg->layout->inode;
-
-	dprintk("--> %s\n", __func__);
-	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
-	put_layout_hdr(ino);
-}
-
 void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
 	bool do_wake_up;
-	struct nfs_inode *nfsi;
+	struct inode *ino;
 
 	if (!lseg)
 		return;
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->kref.refcount), lseg->valid);
+		atomic_read(&lseg->pls_refcount), lseg->valid);
 	do_wake_up = !lseg->valid;
-	nfsi = NFS_I(lseg->layout->inode);
-	kref_put(&lseg->kref, destroy_lseg);
+	ino = lseg->layout->inode;
+	if (atomic_dec_and_test(&lseg->pls_refcount)) {
+		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
+		put_layout_hdr(ino);
+	}
 	if (do_wake_up)
-		rpc_wake_up(&nfsi->lo_rpcwaitq);
+		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
 }
 EXPORT_SYMBOL_GPL(put_lseg);
 
@@ -326,7 +317,7 @@ should_free_lseg(struct pnfs_layout_segment *lseg,
 static bool
 _pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
 {
-	return atomic_read(&lseg->kref.refcount) == 1;
+	return atomic_read(&lseg->pls_refcount) == 1;
 }
 
 static void
@@ -570,7 +561,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 		if (!_pnfs_can_return_lseg(lseg)) {
 			dprintk("%s: wait on lseg %p refcount %d\n",
 				__func__, lseg,
-				atomic_read(&lseg->kref.refcount));
+				atomic_read(&lseg->pls_refcount));
 			ret = true;
 		}
 	}
@@ -827,7 +818,7 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo,
 	}
 
 	dprintk("%s:Return lseg %p ref %d valid %d\n",
-		__func__, ret, ret ? atomic_read(&ret->kref.refcount) : 0,
+		__func__, ret, ret ? atomic_read(&ret->pls_refcount) : 0,
 		ret ? ret->valid : 0);
 	return ret;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7e06437..05dd5e0 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -35,7 +35,7 @@
 struct pnfs_layout_segment {
 	struct list_head fi_list;
 	struct pnfs_layout_range range;
-	struct kref kref;
+	atomic_t pls_refcount;
 	bool valid;
 	struct pnfs_layout_hdr *layout;
 };
@@ -230,7 +230,8 @@ static inline void pnfs_invalidate_layout_stateid(struct pnfs_layout_hdr *lo)
 
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
 {
-	kref_get(&lseg->kref);
+	atomic_inc(&lseg->pls_refcount);
+	smp_mb__after_atomic_inc();
 }
 
 /* Return true if a layout driver is being used for this mountpoint */
-- 
1.7.2.1


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754581Ab2IUBgG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 21:36:06 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/14] NFSv4.1: Rename the pnfs_put_lseg_common to pnfs_layout_remove_lseg
Date: Thu, 20 Sep 2012 21:35:50 -0400
Message-Id: <1348191357-44503-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348191357-44503-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1348191357-44503-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The latter name is more descriptive of the actual function.
Also rename pnfs_insert_layout to pnfs_layout_insert_lseg.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8633b78..142d0f4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -294,21 +294,22 @@ static void free_lseg(struct pnfs_layout_segment *lseg)
 	struct inode *ino = lseg->pls_layout->plh_inode;
 
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	/* Matched by pnfs_get_layout_hdr in pnfs_insert_layout */
+	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	pnfs_put_layout_hdr(NFS_I(ino)->layout);
 }
 
 static void
-pnfs_put_lseg_common(struct pnfs_layout_segment *lseg)
+pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
+		struct pnfs_layout_segment *lseg)
 {
-	struct inode *inode = lseg->pls_layout->plh_inode;
+	struct inode *inode = lo->plh_inode;
 
 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
-	if (list_empty(&lseg->pls_layout->plh_segs)) {
-		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
+	if (list_empty(&lo->plh_segs)) {
+		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
 		/* Matched by initial refcount set in alloc_init_layout_hdr */
-		pnfs_put_layout_hdr_locked(lseg->pls_layout);
+		pnfs_put_layout_hdr_locked(lo);
 	}
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
@@ -316,6 +317,7 @@ pnfs_put_lseg_common(struct pnfs_layout_segment *lseg)
 void
 pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 {
+	struct pnfs_layout_hdr *lo;
 	struct inode *inode;
 
 	if (!lseg)
@@ -324,13 +326,14 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
 		atomic_read(&lseg->pls_refcount),
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
-	inode = lseg->pls_layout->plh_inode;
+	lo = lseg->pls_layout;
+	inode = lo->plh_inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
 		LIST_HEAD(free_me);
 
-		pnfs_put_lseg_common(lseg);
-		list_add(&lseg->pls_list, &free_me);
+		pnfs_layout_remove_lseg(lo, lseg);
 		spin_unlock(&inode->i_lock);
+		list_add(&lseg->pls_list, &free_me);
 		pnfs_free_lseg_list(&free_me);
 	}
 }
@@ -418,7 +421,7 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 		dprintk("%s: lseg %p ref %d\n", __func__, lseg,
 			atomic_read(&lseg->pls_refcount));
 		if (atomic_dec_and_test(&lseg->pls_refcount)) {
-			pnfs_put_lseg_common(lseg);
+			pnfs_layout_remove_lseg(lseg->pls_layout, lseg);
 			list_add(&lseg->pls_list, tmp_list);
 			rv = 1;
 		}
@@ -831,7 +834,7 @@ cmp_layout(struct pnfs_layout_range *l1,
 }
 
 static void
-pnfs_insert_layout(struct pnfs_layout_hdr *lo,
+pnfs_layout_insert_lseg(struct pnfs_layout_hdr *lo,
 		   struct pnfs_layout_segment *lseg)
 {
 	struct pnfs_layout_segment *lp;
@@ -1178,7 +1181,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
 	pnfs_get_lseg(lseg);
-	pnfs_insert_layout(lo, lseg);
+	pnfs_layout_insert_lseg(lo, lseg);
 
 	if (res->return_on_close) {
 		set_bit(NFS_LSEG_ROC, &lseg->pls_flags);
-- 
1.7.11.4


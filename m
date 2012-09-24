Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40062 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab2IXT7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:59:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 24/28] NFSv4.1: Get rid of the NFS_LAYOUT_DESTROYED state
Date: Mon, 24 Sep 2012 15:56:42 -0400
Message-Id: <1348516606-22721-24-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-23-git-send-email-Trond.Myklebust@netapp.com>
References: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-13-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-14-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-15-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-16-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-17-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-18-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-19-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-20-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-21-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-22-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-23-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already have a mechanism for blocking LAYOUTGET by means of the
plh_block_lgets counter. The only "service" that NFS_LAYOUT_DESTROYED
provides at this point is to block layoutget once the layout segment
list is empty, which basically means that you have to wait until
the pnfs_layout_hdr is destroyed before you can do pNFS on that file
again.

This patch enables the reuse of the pnfs_layout_hdr if the layout
segment list is empty.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 3 +--
 fs/nfs/pnfs.c           | 9 +--------
 fs/nfs/pnfs.h           | 7 -------
 3 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 6cce57e..52d8472 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -279,8 +279,7 @@ filelayout_reset_to_mds(struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_deviceid_node *node = FILELAYOUT_DEVID_NODE(lseg);
 
-	return pnfs_test_layout_destroyed(lseg->pls_layout) ||
-		filelayout_test_devid_unavailable(node);
+	return filelayout_test_devid_unavailable(node);
 }
 
 /*
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b8dac08..791eda9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -331,8 +331,6 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	atomic_dec(&lo->plh_refcount);
-	if (list_empty(&lo->plh_segs))
-		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
@@ -463,10 +461,8 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
-	if (list_empty(&lo->plh_segs)) {
-		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
+	if (list_empty(&lo->plh_segs))
 		return 0;
-	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		if (!recall_range ||
 		    should_free_lseg(&lseg->pls_range, recall_range)) {
@@ -590,7 +586,6 @@ pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
 	    (int)(lo->plh_barrier - be32_to_cpu(stateid->seqid)) >= 0)
 		return true;
 	return lo->plh_block_lgets ||
-		test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 		(list_empty(&lo->plh_segs) &&
 		 (atomic_read(&lo->plh_outstanding) > lget));
@@ -912,8 +907,6 @@ pnfs_find_alloc_layout(struct inode *ino,
 	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
 
 	if (nfsi->layout) {
-		if (test_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags))
-			return NULL;
 		pnfs_get_layout_hdr(nfsi->layout);
 		return nfsi->layout;
 	}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index aacda7f..92f6ce6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -62,7 +62,6 @@ enum {
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
-	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 	NFS_LAYOUT_RETURNED,		/* layout has already been returned */
 };
 
@@ -278,12 +277,6 @@ pnfs_test_layout_returned(struct pnfs_layout_hdr *lo)
 	return test_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
 }
 
-static inline bool
-pnfs_test_layout_destroyed(struct pnfs_layout_hdr *lo)
-{
-	return test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
-}
-
 static inline struct pnfs_layout_segment *
 pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
-- 
1.7.11.4


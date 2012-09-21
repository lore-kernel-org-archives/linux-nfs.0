Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59283 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359Ab2IUUxH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:53:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 24/26] NFSv4.1: Get rid of the NFS_LAYOUT_DESTROYED state
Date: Fri, 21 Sep 2012 16:50:19 -0400
Message-Id: <1348260621-10294-24-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-23-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-13-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-14-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-15-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-16-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-17-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-18-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-19-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-20-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-21-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-22-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-23-git-send-email-Trond.Myklebust@netapp.com>
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
index bdb70cc..8ba7c35 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -306,8 +306,6 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	atomic_dec(&lo->plh_refcount);
-	if (list_empty(&lo->plh_segs))
-		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
@@ -438,10 +436,8 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
-	if (list_empty(&lo->plh_segs)) {
-		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
+	if (list_empty(&lo->plh_segs))
 		return 0;
-	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		if (!recall_range ||
 		    should_free_lseg(&lseg->pls_range, recall_range)) {
@@ -560,7 +556,6 @@ pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
 	    (int)(lo->plh_barrier - be32_to_cpu(stateid->seqid)) >= 0)
 		return true;
 	return lo->plh_block_lgets ||
-		test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 		(list_empty(&lo->plh_segs) &&
 		 (atomic_read(&lo->plh_outstanding) > lget));
@@ -882,8 +877,6 @@ pnfs_find_alloc_layout(struct inode *ino,
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


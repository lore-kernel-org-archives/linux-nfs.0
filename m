Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53744 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932102Ab2IXT64 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:58:56 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 17/28] NFSv4.1: Remove redundant reference to the pnfs_layout_hdr
Date: Mon, 24 Sep 2012 15:56:35 -0400
Message-Id: <1348516606-22721-17-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-16-git-send-email-Trond.Myklebust@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Each layout segment already holds a reference to the pnfs_layout_hdr,
so there is no need to hold an extra reference that is released once
the last layout segment is freed.

Ensure that pnfs_find_alloc_layout() always returns a reference
to the pnfs_layout_hdr, which will be matched by the final call to
pnfs_put_layout_hdr() in pnfs_update_layout().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e434bd1..d4b55bf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -331,11 +331,8 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 
 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
-	if (list_empty(&lo->plh_segs)) {
+	if (list_empty(&lo->plh_segs))
 		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
-		/* Matched by initial refcount set in alloc_init_layout_hdr */
-		pnfs_put_layout_hdr_locked(lo);
-	}
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
@@ -468,8 +465,7 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
 	if (list_empty(&lo->plh_segs)) {
-		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
-			pnfs_put_layout_hdr_locked(lo);
+		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
 		return 0;
 	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
@@ -929,8 +925,8 @@ pnfs_find_alloc_layout(struct inode *ino,
 	if (nfsi->layout) {
 		if (test_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags))
 			return NULL;
-		else
-			return nfsi->layout;
+		pnfs_get_layout_hdr(nfsi->layout);
+		return nfsi->layout;
 	}
 	spin_unlock(&ino->i_lock);
 	new = alloc_init_layout_hdr(ino, ctx, gfp_flags);
@@ -1131,7 +1127,6 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 
-	pnfs_get_layout_hdr(lo);
 	if (list_empty(&lo->plh_segs))
 		first = true;
 
-- 
1.7.11.4


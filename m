Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754682Ab2IUBgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 21:36:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/14] NFSv4.1: Remove redundant reference to the pnfs_layout_hdr
Date: Thu, 20 Sep 2012 21:35:51 -0400
Message-Id: <1348191357-44503-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348191357-44503-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1348191357-44503-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Each layout segment already holds a reference to the pnfs_layout_hdr,
so there is no need to hold an extra reference that is released once
the last layout segment is freed.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 142d0f4..767c748 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -306,11 +306,8 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 
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
 
@@ -443,8 +440,7 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
 	if (list_empty(&lo->plh_segs)) {
-		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
-			pnfs_put_layout_hdr_locked(lo);
+		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
 		return 0;
 	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
@@ -1102,7 +1098,6 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 
-	pnfs_get_layout_hdr(lo);
 	if (list_empty(&lo->plh_segs))
 		first = true;
 
-- 
1.7.11.4


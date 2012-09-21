Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754716Ab2IUBgK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 21:36:10 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/14] NFSv4.1: Balance pnfs_layout_hdr refcount in pnfs_layout_(insert|remove)_lseg
Date: Thu, 20 Sep 2012 21:35:55 -0400
Message-Id: <1348191357-44503-12-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348191357-44503-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1348191357-44503-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the reference count for pnfs_layout_hdr reverts to the
original value after a call to pnfs_layout_remove_lseg().

Note that the caller is expected to hold a reference to the struct
pnfs_layout_hdr.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ed8d674..9c5320c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -295,8 +295,6 @@ static void pnfs_free_lseg(struct pnfs_layout_segment *lseg)
 	struct inode *ino = lseg->pls_layout->plh_inode;
 
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
-	pnfs_put_layout_hdr(NFS_I(ino)->layout);
 }
 
 static void
@@ -307,6 +305,8 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 
 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
+	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
+	atomic_dec(&lo->plh_refcount);
 	if (list_empty(&lo->plh_segs))
 		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
@@ -327,9 +327,11 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
+		pnfs_get_layout_hdr(lo);
 		pnfs_layout_remove_lseg(lo, lseg);
 		spin_unlock(&inode->i_lock);
 		pnfs_free_lseg(lseg);
+		pnfs_put_layout_hdr(lo);
 	}
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg);
-- 
1.7.11.4


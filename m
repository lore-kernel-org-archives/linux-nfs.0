Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39998 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757659Ab2IXT7V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:59:21 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 21/28] NFSv4.1: Balance pnfs_layout_hdr refcount in pnfs_layout_(insert|remove)_lseg
Date: Mon, 24 Sep 2012 15:56:39 -0400
Message-Id: <1348516606-22721-21-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-20-git-send-email-Trond.Myklebust@netapp.com>
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
index 7b4741f..bfe5170 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -320,8 +320,6 @@ static void pnfs_free_lseg(struct pnfs_layout_segment *lseg)
 	struct inode *ino = lseg->pls_layout->plh_inode;
 
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
-	pnfs_put_layout_hdr(NFS_I(ino)->layout);
 }
 
 static void
@@ -332,6 +330,8 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 
 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
+	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
+	atomic_dec(&lo->plh_refcount);
 	if (list_empty(&lo->plh_segs))
 		set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
@@ -352,9 +352,11 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
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


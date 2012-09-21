Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700Ab2IUBgI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 21:36:08 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/14] NFSv4.1: Free the pnfs_layout_hdr outside the inode->i_lock
Date: Thu, 20 Sep 2012 21:35:52 -0400
Message-Id: <1348191357-44503-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348191357-44503-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1348191357-44503-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

None of the existing pNFS layout drivers seem to require the inode
to be locked while they free the layout header.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 767c748..1827cae 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -213,7 +213,7 @@ pnfs_free_layout_hdr(struct pnfs_layout_hdr *lo)
 }
 
 static void
-destroy_layout_hdr(struct pnfs_layout_hdr *lo)
+pnfs_detach_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	struct nfs_inode *nfsi = NFS_I(lo->plh_inode);
 	dprintk("%s: freeing layout cache %p\n", __func__, lo);
@@ -222,14 +222,6 @@ destroy_layout_hdr(struct pnfs_layout_hdr *lo)
 	/* Reset MDS Threshold I/O counters */
 	nfsi->write_io = 0;
 	nfsi->read_io = 0;
-	pnfs_free_layout_hdr(lo);
-}
-
-static void
-pnfs_put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
-{
-	if (atomic_dec_and_test(&lo->plh_refcount))
-		destroy_layout_hdr(lo);
 }
 
 void
@@ -238,8 +230,9 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
 	struct inode *inode = lo->plh_inode;
 
 	if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
-		destroy_layout_hdr(lo);
+		pnfs_detach_layout_hdr(lo);
 		spin_unlock(&inode->i_lock);
+		pnfs_free_layout_hdr(lo);
 	}
 }
 
@@ -762,8 +755,12 @@ void pnfs_roc_release(struct inode *ino)
 	spin_lock(&ino->i_lock);
 	lo = NFS_I(ino)->layout;
 	lo->plh_block_lgets--;
-	pnfs_put_layout_hdr_locked(lo);
-	spin_unlock(&ino->i_lock);
+	if (atomic_dec_and_test(&lo->plh_refcount)) {
+		pnfs_detach_layout_hdr(lo);
+		spin_unlock(&ino->i_lock);
+		pnfs_free_layout_hdr(lo);
+	} else
+		spin_unlock(&ino->i_lock);
 }
 
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
-- 
1.7.11.4


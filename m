Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517Ab2IUBgF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 21:36:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/14] NFSv4.1: reset the inode MDS threshold counters on layout destruction
Date: Thu, 20 Sep 2012 21:35:49 -0400
Message-Id: <1348191357-44503-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348191357-44503-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1348191357-44503-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of resetting the inode MDS threshold counters when we mark
the layout for destruction, do it as part of freeing the layout.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f3acb68..8633b78 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -215,9 +215,13 @@ pnfs_free_layout_hdr(struct pnfs_layout_hdr *lo)
 static void
 destroy_layout_hdr(struct pnfs_layout_hdr *lo)
 {
+	struct nfs_inode *nfsi = NFS_I(lo->plh_inode);
 	dprintk("%s: freeing layout cache %p\n", __func__, lo);
 	BUG_ON(!list_empty(&lo->plh_layouts));
-	NFS_I(lo->plh_inode)->layout = NULL;
+	nfsi->layout = NULL;
+	/* Reset MDS Threshold I/O counters */
+	nfsi->write_io = 0;
+	nfsi->read_io = 0;
 	pnfs_free_layout_hdr(lo);
 }
 
@@ -436,9 +440,6 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
 	if (list_empty(&lo->plh_segs)) {
-		/* Reset MDS Threshold I/O counters */
-		NFS_I(lo->plh_inode)->write_io = 0;
-		NFS_I(lo->plh_inode)->read_io = 0;
 		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
 			pnfs_put_layout_hdr_locked(lo);
 		return 0;
-- 
1.7.11.4


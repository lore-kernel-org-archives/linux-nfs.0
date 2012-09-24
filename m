Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5506 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932137Ab2IXT6o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:58:44 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 15/28] NFSv4.1: reset the inode MDS threshold counters on layout destruction
Date: Mon, 24 Sep 2012 15:56:33 -0400
Message-Id: <1348516606-22721-15-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-14-git-send-email-Trond.Myklebust@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of resetting the inode MDS threshold counters when we mark
the layout for destruction, do it as part of freeing the layout.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f48bfef..098624d 100644
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
 
@@ -461,9 +465,6 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
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


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46480 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072Ab2IXT7H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:59:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 19/28] NFSv4.1: Clean up the removal of pnfs_layout_hdr from the server list
Date: Mon, 24 Sep 2012 15:56:37 -0400
Message-Id: <1348516606-22721-19-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-18-git-send-email-Trond.Myklebust@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the code into pnfs_free_layout_hdr(), and add checks to
get_layout_by_fh_locked to ensure that they don't reference a layout
that is being freed.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c | 19 ++++++++++++++++++-
 fs/nfs/pnfs.c          | 29 ++++++++++-------------------
 2 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 24252fe..76b4a7a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -122,7 +122,15 @@ static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
 			ino = igrab(lo->plh_inode);
 			if (!ino)
 				continue;
+			spin_lock(&ino->i_lock);
+			/* Is this layout in the process of being freed? */
+			if (NFS_I(ino)->layout != lo) {
+				spin_unlock(&ino->i_lock);
+				iput(ino);
+				continue;
+			}
 			pnfs_get_layout_hdr(lo);
+			spin_unlock(&ino->i_lock);
 			return lo;
 		}
 	}
@@ -196,9 +204,18 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 			continue;
 
 		list_for_each_entry(lo, &server->layouts, plh_layouts) {
-			if (!igrab(lo->plh_inode))
+			ino = igrab(lo->plh_inode);
+			if (ino)
+				continue;
+			spin_lock(&ino->i_lock);
+			/* Is this layout in the process of being freed? */
+			if (NFS_I(ino)->layout != lo) {
+				spin_unlock(&ino->i_lock);
+				iput(ino);
 				continue;
+			}
 			pnfs_get_layout_hdr(lo);
+			spin_unlock(&ino->i_lock);
 			BUG_ON(!list_empty(&lo->plh_bulk_recall));
 			list_add(&lo->plh_bulk_recall, &recall_list);
 		}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c16c805..cc1d403 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -207,7 +207,16 @@ pnfs_alloc_layout_hdr(struct inode *ino, gfp_t gfp_flags)
 static void
 pnfs_free_layout_hdr(struct pnfs_layout_hdr *lo)
 {
-	struct pnfs_layoutdriver_type *ld = NFS_SERVER(lo->plh_inode)->pnfs_curr_ld;
+	struct nfs_server *server = NFS_SERVER(lo->plh_inode);
+	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
+
+	if (!list_empty(&lo->plh_layouts)) {
+		struct nfs_client *clp = server->nfs_client;
+
+		spin_lock(&clp->cl_lock);
+		list_del_init(&lo->plh_layouts);
+		spin_unlock(&clp->cl_lock);
+	}
 	put_rpccred(lo->plh_lc_cred);
 	return ld->alloc_layout_hdr ? ld->free_layout_hdr(lo) : kfree(lo);
 }
@@ -217,7 +226,6 @@ pnfs_detach_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	struct nfs_inode *nfsi = NFS_I(lo->plh_inode);
 	dprintk("%s: freeing layout cache %p\n", __func__, lo);
-	BUG_ON(!list_empty(&lo->plh_layouts));
 	nfsi->layout = NULL;
 	/* Reset MDS Threshold I/O counters */
 	nfsi->write_io = 0;
@@ -480,22 +488,10 @@ void
 pnfs_free_lseg_list(struct list_head *free_me)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
-	struct pnfs_layout_hdr *lo;
 
 	if (list_empty(free_me))
 		return;
 
-	lo = list_first_entry(free_me, struct pnfs_layout_segment,
-			      pls_list)->pls_layout;
-
-	if (test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags)) {
-		struct nfs_client *clp;
-
-		clp = NFS_SERVER(lo->plh_inode)->nfs_client;
-		spin_lock(&clp->cl_lock);
-		list_del_init(&lo->plh_layouts);
-		spin_unlock(&clp->cl_lock);
-	}
 	list_for_each_entry_safe(lseg, tmp, free_me, pls_list) {
 		list_del(&lseg->pls_list);
 		free_lseg(lseg);
@@ -1150,11 +1146,6 @@ pnfs_update_layout(struct inode *ino,
 		arg.length = PAGE_CACHE_ALIGN(arg.length);
 
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
-	if (!lseg && first) {
-		spin_lock(&clp->cl_lock);
-		list_del_init(&lo->plh_layouts);
-		spin_unlock(&clp->cl_lock);
-	}
 	atomic_dec(&lo->plh_outstanding);
 out:
 	pnfs_put_layout_hdr(lo);
-- 
1.7.11.4


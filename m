Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53797 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932379Ab1BCS3C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Feb 2011 13:29:02 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/3] pnfs: fix pnfs lock inversion of i_lock and cl_lock
Date: Thu,  3 Feb 2011 13:28:52 -0500
Message-Id: <1296757732-16261-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1296757732-16261-1-git-send-email-iisaman@netapp.com>
References: <1296757732-16261-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The pnfs code was using throughout the lock order i_lock, cl_lock.
This conflicts with the nfs delegation code.  Rework the pnfs code
to avoid taking both locks simultaneously.

Currently the code takes the double lock to add/remove the layout to a
nfs_client list, while atomically checking that the list of lsegs is
empty.  To avoid this, we rely on existing serializations.  When a
layout is initialized with lseg count equal zero, LAYOUTGET's
openstateid serialization is in effect, making it safe to assume it
stays zero unless we change it.  And once a layout's lseg count drops
to zero, it is set as DESTROYED and so will stay at zero.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    2 +-
 fs/nfs/pnfs.c          |   42 +++++++++++++++++++++++++-----------------
 2 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 8958757..2f41dcce 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -188,10 +188,10 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 			rv = NFS4ERR_DELAY;
 		list_del_init(&lo->plh_bulk_recall);
 		spin_unlock(&ino->i_lock);
+		pnfs_free_lseg_list(&free_me_list);
 		put_layout_hdr(lo);
 		iput(ino);
 	}
-	pnfs_free_lseg_list(&free_me_list);
 	return rv;
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c17edfb..0f5b66f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -247,13 +247,6 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 		BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 		list_del(&lseg->pls_list);
 		if (list_empty(&lseg->pls_layout->plh_segs)) {
-			struct nfs_client *clp;
-
-			clp = NFS_SERVER(ino)->nfs_client;
-			spin_lock(&clp->cl_lock);
-			/* List does not take a reference, so no need for put here */
-			list_del_init(&lseg->pls_layout->plh_layouts);
-			spin_unlock(&clp->cl_lock);
 			set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
 			/* Matched by initial refcount set in alloc_init_layout_hdr */
 			put_layout_hdr_locked(lseg->pls_layout);
@@ -319,11 +312,27 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	return invalid - removed;
 }
 
+/* note free_me must contain lsegs from a single layout_hdr */
 void
 pnfs_free_lseg_list(struct list_head *free_me)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
+	struct pnfs_layout_hdr *lo;
+
+	if (list_empty(free_me))
+		return;
 
+	lo = list_first_entry(free_me, struct pnfs_layout_segment,
+			      pls_list)->pls_layout;
+
+	if (test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags)) {
+		struct nfs_client *clp;
+
+		clp = NFS_SERVER(lo->plh_inode)->nfs_client;
+		spin_lock(&clp->cl_lock);
+		list_del_init(&lo->plh_layouts);
+		spin_unlock(&clp->cl_lock);
+	}
 	list_for_each_entry_safe(lseg, tmp, free_me, pls_list) {
 		list_del(&lseg->pls_list);
 		free_lseg(lseg);
@@ -705,6 +714,7 @@ pnfs_update_layout(struct inode *ino,
 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
+	bool first = false;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		return NULL;
@@ -735,7 +745,10 @@ pnfs_update_layout(struct inode *ino,
 	atomic_inc(&lo->plh_outstanding);
 
 	get_layout_hdr(lo);
-	if (list_empty(&lo->plh_segs)) {
+	if (list_empty(&lo->plh_segs))
+		first = true;
+	spin_unlock(&ino->i_lock);
+	if (first) {
 		/* The lo must be on the clp list if there is any
 		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
 		 */
@@ -744,17 +757,12 @@ pnfs_update_layout(struct inode *ino,
 		list_add_tail(&lo->plh_layouts, &clp->cl_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
-	spin_unlock(&ino->i_lock);
 
 	lseg = send_layoutget(lo, ctx, iomode);
-	if (!lseg) {
-		spin_lock(&ino->i_lock);
-		if (list_empty(&lo->plh_segs)) {
-			spin_lock(&clp->cl_lock);
-			list_del_init(&lo->plh_layouts);
-			spin_unlock(&clp->cl_lock);
-		}
-		spin_unlock(&ino->i_lock);
+	if (!lseg && first) {
+		spin_lock(&clp->cl_lock);
+		list_del_init(&lo->plh_layouts);
+		spin_unlock(&clp->cl_lock);
 	}
 	atomic_dec(&lo->plh_outstanding);
 	put_layout_hdr(lo);
-- 
1.7.2.1


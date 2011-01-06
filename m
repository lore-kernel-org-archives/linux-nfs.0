Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13367 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995Ab1AFLg4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 06:36:56 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/15] pnfs: add layout to client list before sending rpc
Date: Thu,  6 Jan 2011 06:36:26 -0500
Message-Id: <1294313792-14280-10-git-send-email-iisaman@netapp.com>
In-Reply-To: <1294313792-14280-1-git-send-email-iisaman@netapp.com>
References: <1294313792-14280-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Since this list will be used to search for layouts to recall,
this is necessary to avoid a race where the recall comes in,
sees there is nothing in the client list, and prepares to return
NOMATCHING, while the LAYOUTGET gets processed before the recall
updates the stateid.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   27 +++++++++++++++++++--------
 1 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 59ed68b..c00b673 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -469,14 +469,6 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Begin\n", __func__);
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
-	if (list_empty(&lo->plh_segs)) {
-		struct nfs_client *clp = NFS_SERVER(lo->plh_inode)->nfs_client;
-
-		spin_lock(&clp->cl_lock);
-		BUG_ON(!list_empty(&lo->plh_layouts));
-		list_add_tail(&lo->plh_layouts, &clp->cl_layouts);
-		spin_unlock(&clp->cl_lock);
-	}
 	list_for_each_entry(lp, &lo->plh_segs, pls_list) {
 		if (cmp_layout(lp->pls_range.iomode, lseg->pls_range.iomode) > 0)
 			continue;
@@ -597,6 +589,7 @@ pnfs_update_layout(struct inode *ino,
 		   enum pnfs_iomode iomode)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
+	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
 
@@ -626,9 +619,27 @@ pnfs_update_layout(struct inode *ino,
 	atomic_inc(&lo->plh_outstanding);
 
 	get_layout_hdr_locked(lo);
+	if (list_empty(&lo->plh_segs)) {
+		/* The lo must be on the clp list if there is any
+		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
+		 */
+		spin_lock(&clp->cl_lock);
+		BUG_ON(!list_empty(&lo->plh_layouts));
+		list_add_tail(&lo->plh_layouts, &clp->cl_layouts);
+		spin_unlock(&clp->cl_lock);
+	}
 	spin_unlock(&ino->i_lock);
 
 	lseg = send_layoutget(lo, ctx, iomode);
+	if (!lseg) {
+		spin_lock(&ino->i_lock);
+		if (list_empty(&lo->plh_segs)) {
+			spin_lock(&clp->cl_lock);
+			list_del_init(&lo->plh_layouts);
+			spin_unlock(&clp->cl_lock);
+		}
+		spin_unlock(&ino->i_lock);
+	}
 	atomic_dec(&lo->plh_outstanding);
 	put_layout_hdr(ino);
 out:
-- 
1.7.2.1


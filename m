Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50842 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab1FMWy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 18:54:56 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] nfs4.1: fix several problems with _pnfs_return_layout
Date: Mon, 13 Jun 2011 18:54:53 -0400
Message-Id: <1308005693-8330-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

_pnfs_return_layout had the following problems:

- it did not call pnfs_free_lseg_list on all paths
- it unintentionally did a forgetful return when there was no outstanding io
- it raced with concurrent LAYOUTGETS

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    8 ++++----
 fs/nfs/pnfs.c     |    8 +++++---
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bc78597..2b2f51b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5757,6 +5757,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
 	struct nfs_server *server;
+	struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
 
 	dprintk("--> %s\n", __func__);
 
@@ -5768,16 +5769,15 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		nfs_restart_rpc(task, lrp->clp);
 		return;
 	}
+	spin_lock(&lo->plh_inode->i_lock);
 	if (task->tk_status == 0) {
-		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
-
 		if (lrp->res.lrs_present) {
-			spin_lock(&lo->plh_inode->i_lock);
 			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-			spin_unlock(&lo->plh_inode->i_lock);
 		} else
 			BUG_ON(!list_empty(&lo->plh_segs));
 	}
+	lo->plh_block_lgets--;
+	spin_unlock(&lo->plh_inode->i_lock);
 	dprintk("<-- %s\n", __func__);
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8ff8c1b..1abb300 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -640,12 +640,14 @@ _pnfs_return_layout(struct inode *ino)
 
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
-	if (!lo || !mark_matching_lsegs_invalid(lo, &tmp_list, NULL)) {
+	if (!lo) {
 		spin_unlock(&ino->i_lock);
-		dprintk("%s: no layout segments to return\n", __func__);
-		goto out;
+		dprintk("%s: no layout to return\n", __func__);
+		return status;
 	}
 	stateid = nfsi->layout->plh_stateid;
+	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
+	lo->plh_block_lgets++;
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
 	spin_unlock(&ino->i_lock);
-- 
1.7.2.1


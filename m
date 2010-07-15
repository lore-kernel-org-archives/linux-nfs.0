From: andros@netapp.com
Subject: [PATCH 3/4] SQUASHME pnfs-submit remove unnecessary layoutreturn field
Date: Thu, 15 Jul 2010 16:58:53 -0400
Message-ID: <1279227534-3226-4-git-send-email-andros@netapp.com>
References: <1279227534-3226-1-git-send-email-andros@netapp.com>
 <1279227534-3226-2-git-send-email-andros@netapp.com>
 <1279227534-3226-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934693Ab0GOU6c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 16:58:32 -0400
In-Reply-To: <1279227534-3226-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Don't need both an inode and a pnfs_layout_type field.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c   |    1 -
 fs/nfs/nfs4proc.c        |    9 +++++----
 fs/nfs/pnfs.c            |    1 -
 include/linux/pnfs_xdr.h |    1 -
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index d999ea8..e2ea2be 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -274,7 +274,6 @@ static int pnfs_recall_layout(void *data)
 	lrp->args.return_type = rl.cbl_recall_type;
 	lrp->args.lseg = rl.cbl_seg;
 	lrp->args.inode = inode;
-	lrp->lo = NULL;
 	pnfs4_proc_layoutreturn(lrp, true);
 
 out:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 288025e..ebe1b49 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5660,14 +5660,15 @@ static void nfs4_pnfs_layoutreturn_done(struct rpc_task *task, void *calldata)
 static void nfs4_pnfs_layoutreturn_release(void *calldata)
 {
 	struct nfs4_pnfs_layoutreturn *lrp = calldata;
+	struct pnfs_layout_type *lo = NFS_I(lrp->args.inode)->layout;
 
 	dprintk("--> %s return_type %d lo %p\n", __func__,
-		lrp->args.return_type, lrp->lo);
+		lrp->args.return_type, lo);
 
-	if (lrp->lo && (lrp->args.return_type == RETURN_FILE)) {
+	if (lrp->args.return_type == RETURN_FILE) {
 		if (!lrp->res.lrs_present)
-			pnfs_set_layout_stateid(lrp->lo, &zero_stateid);
-		pnfs_layout_release(lrp->lo, &lrp->args.lseg);
+			pnfs_set_layout_stateid(lo, &zero_stateid);
+		pnfs_layout_release(lo, &lrp->args.lseg);
 	}
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ea508bf..edcbe46 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -682,7 +682,6 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	lrp->args.return_type = type;
 	lrp->args.lseg = *range;
 	lrp->args.inode = ino;
-	lrp->lo = lo;
 
 	status = pnfs4_proc_layoutreturn(lrp, wait);
 out:
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 185fade..f9c9950 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -105,7 +105,6 @@ struct nfs4_pnfs_layoutreturn_res {
 };
 
 struct nfs4_pnfs_layoutreturn {
-	struct pnfs_layout_type *lo;
 	struct nfs4_pnfs_layoutreturn_arg args;
 	struct nfs4_pnfs_layoutreturn_res res;
 	struct rpc_cred *cred;
-- 
1.6.6


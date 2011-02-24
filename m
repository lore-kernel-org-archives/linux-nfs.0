Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51461 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365Ab1BXWJF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 17:09:05 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: pnfsd-lexp: pnfsd_lexp_recall_layout fixes
Date: Thu, 24 Feb 2011 14:09:05 -0800
Message-Id: <1298585345-618-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix Boaz Harrosh's review comments.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/pnfsd_lexp.c |   25 +++++++++----------------
 1 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 71d503e..e9382da 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -239,9 +239,9 @@ is_inode_pnfsd_lexp(struct inode *inode)
 }
 
 static bool
-has_no_layout(struct nfs4_file *fp)
+has_layout(struct nfs4_file *fp)
 {
-	return list_empty(&fp->fi_layouts);
+	return !list_empty(&fp->fi_layouts);
 }
 
 /*
@@ -252,20 +252,15 @@ pnfsd_lexp_recall_layout(struct inode *inode)
 {
 	struct nfs4_file *fp;
 	struct nfsd4_pnfs_cb_layout cbl;
-	struct pnfsd_cb_ctl cb_ctl;
 	int status = 0;
 
 	dprintk("%s: begin\n", __func__);
 	fp = find_file(inode);
 	BUG_ON(!fp);
 
-	if (has_no_layout(fp))
+	if (!has_layout(fp))
 		goto out;
 
-	memset(&cb_ctl, 0, sizeof(cb_ctl));
-	status = pnfsd_get_cb_op(&cb_ctl);
-	BUG_ON(status);
-
 	memset(&cbl, 0, sizeof(cbl));
 	cbl.cbl_recall_type = RETURN_FILE;
 	cbl.cbl_seg.layout_type = LAYOUT_NFSV4_1_FILES;
@@ -274,9 +269,9 @@ pnfsd_lexp_recall_layout(struct inode *inode)
 	cbl.cbl_seg.offset = 0;
 	cbl.cbl_seg.length = NFS4_MAX_UINT64;
 
-	while (!has_no_layout(fp)) {
+	while (has_layout(fp)) {
 		dprintk("%s: recalling layout\n", __func__);
-		status = cb_ctl.cb_op->cb_layout_recall(inode->i_sb, inode, &cbl);
+		status = nfsd_layout_recall_cb(inode->i_sb, inode, &cbl);
 
 		switch (status) {
 		case 0:
@@ -284,18 +279,16 @@ pnfsd_lexp_recall_layout(struct inode *inode)
 			break;
 		case -ENOENT:	/* no matching layout */
 			status = 0;
-			goto out_put_cb;
+			goto out;
 		default:
-			goto out_put_cb;
+			goto out;
 		}
 
-		dprintk("%s: waiting\n", __func__);
-		status = wait_event_interruptible(lo_recall_wq, has_no_layout(fp));
+		dprintk("%s: waiting status=%d\n", __func__, status);
+		status = wait_event_interruptible(lo_recall_wq, !has_layout(fp));
 		if (status)
 			break;
 	}
-out_put_cb:
-	pnfsd_put_cb_op(&cb_ctl);
 out:
 	put_nfs4_file(fp);
 	dprintk("%s: status=%d\n", __func__, status);
-- 
1.7.3.4


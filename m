Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60583 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758884Ab0J1TKJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 15:10:09 -0400
Received: from localhost.localdomain (elee16240.hq.netapp.com [10.58.53.47] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o9SJA27i000482
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 12:10:07 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] pnfs_submit: fix layoutreturn layout stateid processing
Date: Thu, 28 Oct 2010 15:10:01 -0400
Message-Id: <1288293001-26289-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
References: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

This is a rebase of Andy's patch (which is not yet in the pns-submit tree)
onto my patches, yet taking into account some issues Benny noted which are
best addressed by ensuring that nfs4_layoutreturn_release make no reference
to call results, as there is no guarantee that a call was made.

Add missing layoutreturn stateid update.
This patch also enforces the following rfc 5661 requirement:

section 12.5.3
   "For LAYOUTRETURN results, the client MUST delete the range from its
   record of what ranges of the file's layout it had before using the
   seqid."

Reported-by: P.B.Shelley <shelleypt@gmail.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 96bd822..4fba3f0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5674,10 +5674,6 @@ static void nfs4_layoutreturn_release(void *calldata)
 
 	if (lrp->args.return_type == RETURN_FILE) {
 		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
-		spin_lock(&lo->inode->i_lock);
-		if (!lrp->res.lrs_present)
-			pnfs_invalidate_layout_stateid(lo);
-		spin_unlock(&lo->inode->i_lock);
 		pnfs_layoutreturn_release(lo, &lrp->args.range);
 	}
 	kfree(calldata);
@@ -5720,6 +5716,16 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
 	if (status != 0)
 		goto out;
 	status = task->tk_status;
+	if (status == 0 && lrp->args.return_type == RETURN_FILE) {
+		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
+
+		spin_lock(&lo->inode->i_lock);
+		if (!lrp->res.lrs_present)
+			pnfs_invalidate_layout_stateid(lo);
+		else
+			pnfs_set_layout_stateid(lo, &lrp->res.stateid);
+		spin_unlock(&lo->inode->i_lock);
+	}
 out:
 	dprintk("<-- %s\n", __func__);
 	rpc_put_task(task);
-- 
1.7.2.1


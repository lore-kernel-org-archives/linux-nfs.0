Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33876 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbbGMFUd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:20:33 -0400
Received: by lbnk3 with SMTP id k3so118084542lbn.1
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:20:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] pNFS: pnfs_roc_drain should return 'true' when sleeping
Date: Mon, 13 Jul 2015 07:20:02 +0200
Message-Id: <1436764805-2893-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1436764805-2893-1-git-send-email-trond.myklebust@primarydata.com>
References: <1436764805-2893-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also clean up the case where we don't find a return-on-close layout segment.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0ba9a02c9566..8e9f467e409c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1146,14 +1146,14 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 	struct pnfs_layout_segment *lseg;
 	nfs4_stateid stateid;
 	u32 current_seqid;
-	bool found = false, layoutreturn = false;
+	bool layoutreturn = false;
 
 	spin_lock(&ino->i_lock);
 	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list)
 		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
 			rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
-			found = true;
-			goto out;
+			spin_unlock(&ino->i_lock);
+			return true;
 		}
 	lo = nfsi->layout;
 	current_seqid = be32_to_cpu(lo->plh_stateid.seqid);
@@ -1162,23 +1162,21 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 	 * a barrier, we choose the worst-case barrier.
 	 */
 	*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
-out:
-	if (!found) {
-		stateid = lo->plh_stateid;
-		layoutreturn =
-			test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+	stateid = lo->plh_stateid;
+	layoutreturn = test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
 					   &lo->plh_flags);
-		if (layoutreturn) {
-			lo->plh_block_lgets++;
-			pnfs_get_layout_hdr(lo);
-		}
+	if (layoutreturn) {
+		lo->plh_block_lgets++;
+		pnfs_get_layout_hdr(lo);
 	}
+
 	spin_unlock(&ino->i_lock);
 	if (layoutreturn) {
 		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
 		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, false);
+		return true;
 	}
-	return found;
+	return false;
 }
 
 /*
-- 
2.4.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5021 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564Ab1A0UgY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jan 2011 15:36:24 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] SQUASHME: pnfs: call pnfs_choose_layoutget_stateid under the inode lock
Date: Thu, 27 Jan 2011 22:36:19 +0200
Message-Id: <1296160579-29977-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Also, On ther success leg of nfs4_layoutget_prepare plh_outstanding should remain
incremented until the layoutget call is processed.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 59d372a..3cc398c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5427,21 +5427,23 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 	 * serialize openstateid LAYOUTGETs.
 	 */
 	atomic_inc(&nfsi->layout->plh_outstanding);
-	spin_unlock(&ino->i_lock);
-
-	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
-				&lgp->res.seq_res, 0, task)) {
-		goto err_out;
-	}
 	if (pnfs_choose_layoutget_stateid(&lgp->args.stateid,
 					  NFS_I(lgp->args.inode)->layout,
 					  lgp->args.ctx->state)) {
 		rpc_exit(task, NFS4_OK);
+		goto err_out_locked;
+	}
+	spin_unlock(&ino->i_lock);
+
+	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
+				&lgp->res.seq_res, 0, task)) {
 		goto err_out;
 	}
 	rpc_call_start(task);
+	return;
 err_out:
 	spin_lock(&ino->i_lock);
+err_out_locked:
 	atomic_dec(&nfsi->layout->plh_outstanding);
 	spin_unlock(&ino->i_lock);
 }
-- 
1.7.3.4


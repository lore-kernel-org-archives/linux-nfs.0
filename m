Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753476Ab0LWRaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 12:30:24 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/15] pnfs: layoutget rpc code cleanup
Date: Thu, 23 Dec 2010 12:29:49 -0500
Message-Id: <1293125397-30088-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
References: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

No functional changes, just some code minor code rearrangement and
comments.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f475516..1609a07 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5297,10 +5297,14 @@ static void
 nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
-	struct inode *ino = lgp->args.inode;
-	struct nfs_server *server = NFS_SERVER(ino);
+	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 
 	dprintk("--> %s\n", __func__);
+	/* Note the is a race here, where a CB_LAYOUTRECALL can come in
+	 * right now covering the LAYOUTGET we are about to send.
+	 * However, that is not so catastrophic, and there seems
+	 * to be no way to prevent it completely.
+	 */
 	if (nfs4_setup_sequence(server, &lgp->args.seq_args,
 				&lgp->res.seq_res, 0, task))
 		return;
@@ -5383,13 +5387,10 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = nfs4_wait_for_completion_rpc_task(task);
-	if (status != 0)
-		goto out;
-	status = task->tk_status;
-	if (status != 0)
-		goto out;
-	status = pnfs_layout_process(lgp);
-out:
+	if (status == 0)
+		status = task->tk_status;
+	if (status == 0)
+		status = pnfs_layout_process(lgp);
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
-- 
1.7.2.1


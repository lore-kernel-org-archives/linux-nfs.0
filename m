Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0JAQDn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 12:03:43 -0400
Received: from localhost.localdomain (vpn2ntap-420885.hq.netapp.com [10.58.51.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o91G3Uep008238
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 09:03:42 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] SQUASHME: pnfs-devinfo-submit: Use only asynch error handler for LAYOUTGET
Date: Fri,  1 Oct 2010 12:02:49 -0400
Message-Id: <1285948971-2048-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
References: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This corrects the problem where a retry uses freed memory.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   38 +++++++++++++++-----------------------
 1 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aad6fdc..e28da81 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5426,15 +5426,26 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
+	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 
 	dprintk("--> %s\n", __func__);
 
 	if (!nfs4_sequence_done(task, &lgp->res.seq_res))
 		return;
 
-	/* Error handling done later using nfs4_handle_exception to get
-	 * exponential backoff.
-	 */
+	switch (task->tk_status) {
+	case 0:
+		break;
+	case -NFS4ERR_LAYOUTTRYLATER:
+	case -NFS4ERR_RECALLCONFLICT:
+		task->tk_status = -NFS4ERR_DELAY;
+		/* Fall through */
+	default:
+		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
+			rpc_restart_call_prepare(task);
+			return;
+		}
+	}
 	lgp->status = task->tk_status;
 	dprintk("<-- %s\n", __func__);
 }
@@ -5458,7 +5469,7 @@ static const struct rpc_call_ops nfs4_layoutget_call_ops = {
 	.rpc_release = nfs4_layoutget_release,
 };
 
-static int _nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
+int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 {
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 	struct rpc_task *task;
@@ -5501,25 +5512,6 @@ out:
 	return status;
 }
 
-int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
-{
-	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
-	struct nfs4_exception exception = { };
-	int err;
-	do {
-		err = _nfs4_proc_layoutget(lgp);
-		switch (err) {
-		case -NFS4ERR_LAYOUTTRYLATER:
-		case -NFS4ERR_RECALLCONFLICT:
-			err = -NFS4ERR_DELAY;
-			/* Fall through */
-		default:
-			err = nfs4_handle_exception(server, err, &exception);
-		}
-	} while (exception.retry);
-	return err;
-}
-
 static void nfs4_layoutcommit_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_layoutcommit_data *ldata =
-- 
1.7.2.1


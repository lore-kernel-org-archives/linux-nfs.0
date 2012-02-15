Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39849 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755060Ab2BOTm1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 14:42:27 -0500
Received: by mail-iy0-f174.google.com with SMTP id b35so1851170iac.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 11:42:27 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/13] NFS: Add debugging messages to NFSv4's CLOSE procedure
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 14:42:25 -0500
Message-ID: <20120215194225.2925.46180.stgit@ellison.1015granger.net>
In-Reply-To: <20120215193059.2925.10928.stgit@ellison.1015granger.net>
References: <20120215193059.2925.10928.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CLOSE is new with NFSv4.  Sometimes it's important to know the timing
of this operation compared to things like lease renewal.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5ff9c5a..5629858 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1947,6 +1947,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	struct nfs4_state *state = calldata->state;
 	struct nfs_server *server = NFS_SERVER(calldata->inode);
 
+	dprintk("%s: begin!\n", __func__);
 	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
 		return;
         /* hmm. we are done with the inode, and in the process of freeing
@@ -1974,6 +1975,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	}
 	nfs_release_seqid(calldata->arg.seqid);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
+	dprintk("%s: done, ret = %d!\n", __func__, task->tk_status);
 }
 
 static void nfs4_close_prepare(struct rpc_task *task, void *data)
@@ -1982,6 +1984,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	struct nfs4_state *state = calldata->state;
 	int call_close = 0;
 
+	dprintk("%s: begin!\n", __func__);
 	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		return;
 
@@ -2006,7 +2009,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	if (!call_close) {
 		/* Note: exit _without_ calling nfs4_close_done */
 		task->tk_action = NULL;
-		return;
+		goto out;
 	}
 
 	if (calldata->arg.fmode == 0) {
@@ -2015,7 +2018,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		    pnfs_roc_drain(calldata->inode, &calldata->roc_barrier)) {
 			rpc_sleep_on(&NFS_SERVER(calldata->inode)->roc_rpcwaitq,
 				     task, NULL);
-			return;
+			goto out;
 		}
 	}
 
@@ -2024,8 +2027,10 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	if (nfs4_setup_sequence(NFS_SERVER(calldata->inode),
 				&calldata->arg.seq_args, &calldata->res.seq_res,
 				1, task))
-		return;
+		goto out;
 	rpc_call_start(task);
+out:
+	dprintk("%s: done!\n", __func__);
 }
 
 static const struct rpc_call_ops nfs4_close_ops = {


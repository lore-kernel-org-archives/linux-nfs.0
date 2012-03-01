Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42665 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab2CAWAl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:00:41 -0500
Received: by ghrr11 with SMTP id r11so544349ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:00:41 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/15] NFS: Add debugging messages to NFSv4's CLOSE procedure
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:00:40 -0500
Message-ID: <20120301220039.2138.66911.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
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
index 87c584d..53daab9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1983,6 +1983,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	struct nfs4_state *state = calldata->state;
 	struct nfs_server *server = NFS_SERVER(calldata->inode);
 
+	dprintk("%s: begin!\n", __func__);
 	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
 		return;
         /* hmm. we are done with the inode, and in the process of freeing
@@ -2010,6 +2011,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	}
 	nfs_release_seqid(calldata->arg.seqid);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
+	dprintk("%s: done, ret = %d!\n", __func__, task->tk_status);
 }
 
 static void nfs4_close_prepare(struct rpc_task *task, void *data)
@@ -2018,6 +2020,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	struct nfs4_state *state = calldata->state;
 	int call_close = 0;
 
+	dprintk("%s: begin!\n", __func__);
 	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		return;
 
@@ -2042,7 +2045,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	if (!call_close) {
 		/* Note: exit _without_ calling nfs4_close_done */
 		task->tk_action = NULL;
-		return;
+		goto out;
 	}
 
 	if (calldata->arg.fmode == 0) {
@@ -2051,7 +2054,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		    pnfs_roc_drain(calldata->inode, &calldata->roc_barrier)) {
 			rpc_sleep_on(&NFS_SERVER(calldata->inode)->roc_rpcwaitq,
 				     task, NULL);
-			return;
+			goto out;
 		}
 	}
 
@@ -2061,8 +2064,10 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 				&calldata->arg.seq_args,
 				&calldata->res.seq_res,
 				task))
-		return;
+		goto out;
 	rpc_call_start(task);
+out:
+	dprintk("%s: done!\n", __func__);
 }
 
 static const struct rpc_call_ops nfs4_close_ops = {


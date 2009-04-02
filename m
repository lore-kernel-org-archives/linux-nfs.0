From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 38/67] nfs41: locku sequence setup/done support
Date: Thu,  2 Apr 2009 16:55:56 +0300
Message-ID: <1238680556-14590-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30877 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755115AbZDBN4I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:56:08 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate nfs4_locku calls from nfs41: sequence setup/done support
Call nfs4_sequence_done from respective rpc_call_done methods.

Note that we need to pass a pointer to the nfs_server in calls data
for passing on to nfs4_sequence_done.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: client data server write validate and release]
Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs4_sequence_free_slot use nfs_client for data server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9f1da6c..6e6bb5b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3536,7 +3536,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	struct nfs4_unlockdata *p;
 	struct inode *inode = lsp->ls_state->inode;
 
-	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
 		return NULL;
 	p->arg.fh = NFS_FH(inode);
@@ -3567,6 +3567,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_unlockdata *calldata = data;
 
+	nfs4_sequence_done(calldata->server, &calldata->res.seq_res,
+			   task->tk_status);
 	if (RPC_ASSASSINATED(task))
 		return;
 	switch (task->tk_status) {
@@ -3585,6 +3587,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
 				rpc_restart_call(task);
 	}
+	nfs4_sequence_free_slot(calldata->server->nfs_client,
+				&calldata->res.seq_res);
 }
 
 static void nfs4_locku_prepare(struct rpc_task *task, void *data)
@@ -3599,6 +3603,10 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	calldata->timestamp = jiffies;
+	if (nfs4_setup_sequence(calldata->server->nfs_client,
+				&calldata->arg.seq_args,
+				&calldata->res.seq_res, 1, task))
+		return;
 	rpc_call_start(task);
 }
 
-- 
1.6.2.1


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 41/46] nfs41: locku sequence setup/done support
Date: Wed,  4 Mar 2009 02:01:24 +0200
Message-ID: <1236124884-4110-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17942
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755766AbZCDABh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:01:37 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate nfs4_locku calls from nfs41: sequence setup/done support
Call nfs4_sequence_done from respective rpc_call_done methods.

Note that we need to pass a pointer to the nfs_server in calls data
for passing on to nfs4_sequence_done.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: client data server write validate and release]
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9c41d42..5d13918 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3557,7 +3557,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	struct nfs4_unlockdata *p;
 	struct inode *inode = lsp->ls_state->inode;
 
-	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
 		return NULL;
 	p->arg.fh = NFS_FH(inode);
@@ -3588,6 +3588,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_unlockdata *calldata = data;
 
+	nfs4_sequence_done(calldata->server, &calldata->res.seq_res,
+			   task->tk_status);
 	if (RPC_ASSASSINATED(task))
 		return;
 	switch (task->tk_status) {
@@ -3606,6 +3608,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
 				rpc_restart_call(task);
 	}
+	nfs4_sequence_free_slot(calldata->server, &calldata->res.seq_res);
 }
 
 static void nfs4_locku_prepare(struct rpc_task *task, void *data)
@@ -3620,6 +3623,10 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
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
1.6.1.3


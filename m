From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 37/67] nfs41: lock sequence setup/done support
Date: Thu,  2 Apr 2009 16:55:46 +0300
Message-ID: <1238680546-14559-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30562 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754967AbZDBNz6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:55:58 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate nfs4_lock calls from nfs41: sequence setup/done support
Call nfs4_sequence_done from respective rpc_call_done methods.

Note that we need to pass a pointer to the nfs_server in calls data
for passing on to nfs4_sequence_done.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: client data server write validate and release]
[use nfs4_sequence_done_free_slot]
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8654a96..9f1da6c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3691,6 +3691,7 @@ struct nfs4_lockdata {
 	unsigned long timestamp;
 	int rpc_status;
 	int cancelled;
+	struct nfs_server *server;
 };
 
 static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
@@ -3718,6 +3719,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->res.lock_seqid = p->arg.lock_seqid;
 	p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	p->lsp = lsp;
+	p->server = server;
 	atomic_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
 	memcpy(&p->fl, fl, sizeof(p->fl));
@@ -3747,6 +3749,9 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	} else
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
+	if (nfs4_setup_sequence(data->server->nfs_client, &data->arg.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
 	rpc_call_start(task);
 	dprintk("%s: done!, ret = %d\n", __func__, data->rpc_status);
 }
@@ -3757,6 +3762,9 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 
 	dprintk("%s: begin!\n", __func__);
 
+	nfs4_sequence_done_free_slot(data->server, &data->res.seq_res,
+				     task->tk_status);
+
 	data->rpc_status = task->tk_status;
 	if (RPC_ASSASSINATED(task))
 		goto out;
-- 
1.6.2.1


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 40/46] nfs41: lock sequence setup/done support
Date: Wed,  4 Mar 2009 02:01:12 +0200
Message-ID: <1236124872-4085-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17906
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755766AbZCDAB1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:01:27 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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
index 56612d1..9c41d42 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3712,6 +3712,7 @@ struct nfs4_lockdata {
 	unsigned long timestamp;
 	int rpc_status;
 	int cancelled;
+	struct nfs_server *server;
 };
 
 static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
@@ -3739,6 +3740,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->res.lock_seqid = p->arg.lock_seqid;
 	p->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	p->lsp = lsp;
+	p->server = server;
 	atomic_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
 	memcpy(&p->fl, fl, sizeof(p->fl));
@@ -3768,6 +3770,9 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	} else
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
+	if (nfs4_setup_sequence(data->server->nfs_client, &data->arg.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
 	rpc_call_start(task);
 	dprintk("%s: done!, ret = %d\n", __func__, data->rpc_status);
 }
@@ -3778,6 +3783,9 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 
 	dprintk("%s: begin!\n", __func__);
 
+	nfs4_sequence_done_free_slot(data->server, &data->res.seq_res,
+				     task->tk_status);
+
 	data->rpc_status = task->tk_status;
 	if (RPC_ASSASSINATED(task))
 		goto out;
-- 
1.6.1.3


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 35/67] nfs41: close sequence setup/done support
Date: Thu,  2 Apr 2009 16:55:23 +0300
Message-ID: <1238680523-14496-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15387 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751792AbZDBNza (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:55:30 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate nfs4_close calls from nfs41: sequence setup/done support
Call nfs4_sequence_done from respective rpc_call_done methods.

Note that we need to pass a pointer to the nfs_server in calls data
for passing on to nfs4_sequence_done.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: client data server write validate and release]
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: separate free slot from sequence done]
[nfs41: sequence res use slotid]
[nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
[nfs41: nfs4_sequence_free_slot use nfs_client for data server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2b481db..638dea9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1630,6 +1630,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	struct nfs4_state *state = calldata->state;
 	struct nfs_server *server = NFS_SERVER(calldata->inode);
 
+	nfs4_sequence_done(server, &calldata->res.seq_res, task->tk_status);
 	if (RPC_ASSASSINATED(task))
 		return;
         /* hmm. we are done with the inode, and in the process of freeing
@@ -1652,6 +1653,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				return;
 			}
 	}
+	nfs4_sequence_free_slot(server->nfs_client, &calldata->res.seq_res);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
 }
 
@@ -1692,6 +1694,10 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		calldata->arg.fmode = FMODE_WRITE;
 	}
 	calldata->timestamp = jiffies;
+	if (nfs4_setup_sequence((NFS_SERVER(calldata->inode))->nfs_client,
+				&calldata->arg.seq_args, &calldata->res.seq_res,
+				1, task))
+		return;
 	rpc_call_start(task);
 }
 
@@ -1731,7 +1737,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	};
 	int status = -ENOMEM;
 
-	calldata = kmalloc(sizeof(*calldata), GFP_KERNEL);
+	calldata = kzalloc(sizeof(*calldata), GFP_KERNEL);
 	if (calldata == NULL)
 		goto out;
 	calldata->inode = state->inode;
-- 
1.6.2.1


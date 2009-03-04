From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 38/46] nfs41: close sequence setup/done support
Date: Wed,  4 Mar 2009 02:00:49 +0200
Message-ID: <1236124849-4026-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17889
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753428AbZCDABC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:01:02 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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

move nfs4_sequence_free_slot from nfs41: separate free slot from sequence done
[nfs41: sequence res use slotid]
[nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f2fc8fe..f11c38f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1662,6 +1662,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	struct nfs4_state *state = calldata->state;
 	struct nfs_server *server = NFS_SERVER(calldata->inode);
 
+	nfs4_sequence_done(server, &calldata->res.seq_res, task->tk_status);
 	if (RPC_ASSASSINATED(task))
 		return;
         /* hmm. we are done with the inode, and in the process of freeing
@@ -1684,6 +1685,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				return;
 			}
 	}
+	nfs4_sequence_free_slot(server, &calldata->res.seq_res);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
 }
 
@@ -1724,6 +1726,10 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		calldata->arg.fmode = FMODE_WRITE;
 	}
 	calldata->timestamp = jiffies;
+	if (nfs4_setup_sequence((NFS_SERVER(calldata->inode))->nfs_client,
+				&calldata->arg.seq_args, &calldata->res.seq_res,
+				1, task))
+		return;
 	rpc_call_start(task);
 }
 
@@ -1763,7 +1769,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	};
 	int status = -ENOMEM;
 
-	calldata = kmalloc(sizeof(*calldata), GFP_KERNEL);
+	calldata = kzalloc(sizeof(*calldata), GFP_KERNEL);
 	if (calldata == NULL)
 		goto out;
 	calldata->inode = state->inode;
-- 
1.6.1.3


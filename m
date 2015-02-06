Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:63421 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbbBFEpL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 23:45:11 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so5441213igk.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 20:45:10 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v3 2/5] NFSv4.1: Pin the inode and super block in asynchronous layoutcommit
Date: Thu,  5 Feb 2015 23:45:04 -0500
Message-Id: <1423197907-75541-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423197907-75541-1-git-send-email-trond.myklebust@primarydata.com>
References: <1423197907-75541-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're sending an asynchronous layoutcommit, then we need to ensure
that the inode and the super block remain pinned.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 19 +++++++++++--------
 include/linux/nfs_xdr.h |  1 +
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dd892a4e7eb3..e092b8540e2e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7989,6 +7989,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 	nfs_post_op_update_inode_force_wcc(data->args.inode,
 					   data->res.fattr);
 	put_rpccred(data->cred);
+	nfs_iput_and_deactive(data->inode);
 	kfree(data);
 }
 
@@ -8013,7 +8014,6 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_layoutcommit_ops,
 		.callback_data = data,
-		.flags = RPC_TASK_ASYNC,
 	};
 	struct rpc_task *task;
 	int status = 0;
@@ -8024,18 +8024,21 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 		data->args.lastbytewritten,
 		data->args.inode->i_ino);
 
+	if (!sync) {
+		data->inode = nfs_igrab_and_active(data->args.inode);
+		if (data->inode == NULL) {
+			nfs4_layoutcommit_release(data);
+			return -EAGAIN;
+		}
+		task_setup_data.flags = RPC_TASK_ASYNC;
+	}
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	if (sync == false)
-		goto out;
-	status = nfs4_wait_for_completion_rpc_task(task);
-	if (status != 0)
-		goto out;
-	status = task->tk_status;
+	if (sync)
+		status = task->tk_status;
 	trace_nfs4_layoutcommit(data->args.inode, status);
-out:
 	dprintk("%s: status %d\n", __func__, status);
 	rpc_put_task(task);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2c35e2affa6f..bb0d56f737e0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -285,6 +285,7 @@ struct nfs4_layoutcommit_data {
 	struct nfs_fattr fattr;
 	struct list_head lseg_list;
 	struct rpc_cred *cred;
+	struct inode *inode;
 	struct nfs4_layoutcommit_args args;
 	struct nfs4_layoutcommit_res res;
 };
-- 
2.1.0


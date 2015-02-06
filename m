Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:59759 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbbBFEpM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 23:45:12 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so5279108igd.4
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 20:45:11 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v3 3/5] NFSv4.1: Pin the inode and super block in asynchronous layoutreturns
Date: Thu,  5 Feb 2015 23:45:05 -0500
Message-Id: <1423197907-75541-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423197907-75541-2-git-send-email-trond.myklebust@primarydata.com>
References: <1423197907-75541-1-git-send-email-trond.myklebust@primarydata.com>
 <1423197907-75541-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're sending an asynchronous layoutreturn, then we need to ensure
that the inode and the super block remain pinned.

Cc: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 19 +++++++++++--------
 include/linux/nfs_xdr.h |  1 +
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e092b8540e2e..2e7c9f7a6f7c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7856,6 +7856,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
 	pnfs_put_layout_hdr(lrp->args.layout);
+	nfs_iput_and_deactive(lrp->inode);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
 }
@@ -7880,23 +7881,25 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_layoutreturn_call_ops,
 		.callback_data = lrp,
-		.flags = RPC_TASK_ASYNC,
 	};
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
+	if (!sync) {
+		lrp->inode = nfs_igrab_and_active(lrp->args.inode);
+		if (!lrp->inode) {
+			nfs4_layoutreturn_release(lrp);
+			return -EAGAIN;
+		}
+		task_setup_data.flags |= RPC_TASK_ASYNC;
+	}
 	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
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
 	trace_nfs4_layoutreturn(lrp->args.inode, status);
-out:
 	dprintk("<-- %s status=%d\n", __func__, status);
 	rpc_put_task(task);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bb0d56f737e0..38d96ba935c2 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -310,6 +310,7 @@ struct nfs4_layoutreturn {
 	struct nfs4_layoutreturn_res res;
 	struct rpc_cred *cred;
 	struct nfs_client *clp;
+	struct inode *inode;
 	int rpc_status;
 };
 
-- 
2.1.0


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: pnfsd: move kfree of the cb_layout rpc_args to release time
Date: Fri, 18 Jun 2010 17:03:32 -0400
Message-ID: <1276895012-29846-1-git-send-email-bhalevy@panasas.com>
References: <4C1BDE45.6020806@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50186 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751899Ab0FRVDY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 17:03:24 -0400
In-Reply-To: <4C1BDE45.6020806@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c          |    4 +++-
 include/linux/nfsd/nfsd4_pnfs.h |    2 ++
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c98e64f..cdf9d6d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1020,7 +1020,6 @@ static void nfsd4_cb_layout_done(struct rpc_task *task, void *calldata)
 	struct nfs4_client *clp = clr->clr_client;
 
 	nfsd4_cb_done_sequence(task, clp);
-	kfree(task->tk_msg.rpc_argp);
 
 	if (!task->tk_status)
 		return;
@@ -1057,6 +1056,8 @@ static void nfsd4_cb_layout_done(struct rpc_task *task, void *calldata)
 static void nfsd4_cb_layout_release(void *calldata)
 {
 	struct nfs4_layoutrecall *clr = calldata;
+	kfree(clr->clr_args);
+	clr->clr_args = NULL;
 	put_layoutrecall(clr);
 }
 
@@ -1086,6 +1087,7 @@ nfsd4_cb_layout(struct nfs4_layoutrecall *clr)
 		status = -ENOMEM;
 		goto out;
 	}
+	clr->clr_args = args;
 	args->args_op = clr;
 	msg.rpc_argp = args;
 	status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 2f4d493..2e66837 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -234,6 +234,8 @@ struct nfs4_layoutrecall {
 	struct timespec			clr_time;	/* last activity */
 	struct super_block 		*clr_sb; /* We might not have a file */
 	struct nfs4_layoutrecall	*parent; /* The initiating recall */
+
+	void				*clr_args;	/* nfsd internal */
 };
 
 struct nfsd4_pnfs_cb_dev_item {
-- 
1.6.4.4


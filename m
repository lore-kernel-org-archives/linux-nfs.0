From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 43/67] nfs41 delegreturn sequence setup done support
Date: Thu,  2 Apr 2009 16:56:47 +0300
Message-ID: <1238680607-14747-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1086 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757314AbZDBN4x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:56:53 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate delegreturn calls from nfs41: sequence setup/done support

Implement the delegreturn rpc_call_prepare method for
asynchronuos nfs rpcs, call nfs41_setup_sequence from
respective rpc_call_validate_args methods.

Call nfs4_sequence_done from respective rpc_call_done methods.

Note that we need to pass a pointer to the nfs_server in calls data
for passing on to nfs4_sequence_done.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: client data server write validate and release]
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1132eda..ffdc7e8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3363,6 +3363,10 @@ struct nfs4_delegreturndata {
 static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegreturndata *data = calldata;
+
+	nfs4_sequence_done_free_slot(data->res.server, &data->res.seq_res,
+				     task->tk_status);
+
 	data->rpc_status = task->tk_status;
 	if (data->rpc_status == 0)
 		renew_lease(data->res.server, data->timestamp);
@@ -3373,7 +3377,25 @@ static void nfs4_delegreturn_release(void *calldata)
 	kfree(calldata);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
+{
+	struct nfs4_delegreturndata *d_data;
+
+	d_data = (struct nfs4_delegreturndata *)data;
+
+	if (nfs4_setup_sequence(d_data->res.server->nfs_client,
+				&d_data->args.seq_args,
+				&d_data->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 static const struct rpc_call_ops nfs4_delegreturn_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs4_delegreturn_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs4_delegreturn_done,
 	.rpc_release = nfs4_delegreturn_release,
 };
@@ -3395,7 +3417,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	};
 	int status = 0;
 
-	data = kmalloc(sizeof(*data), GFP_KERNEL);
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data == NULL)
 		return -ENOMEM;
 	data->args.fhandle = &data->fh;
-- 
1.6.2.1


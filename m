From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 46/46] nfs41 delegreturn sequence setup done support
Date: Wed,  4 Mar 2009 02:02:22 +0200
Message-ID: <1236124942-4237-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:18006
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755875AbZCDACf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:02:35 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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
index 6f92037..d85f15d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3383,6 +3383,10 @@ struct nfs4_delegreturndata {
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
@@ -3393,7 +3397,25 @@ static void nfs4_delegreturn_release(void *calldata)
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
@@ -3415,7 +3437,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	};
 	int status = 0;
 
-	data = kmalloc(sizeof(*data), GFP_KERNEL);
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data == NULL)
 		return -ENOMEM;
 	data->args.fhandle = &data->fh;
-- 
1.6.1.3


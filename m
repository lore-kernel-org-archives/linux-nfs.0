Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10796 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933810Ab3ECU1p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 May 2013 16:27:45 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Convert nfs41_free_stateid to use an asynchronous RPC call
Date: Fri,  3 May 2013 16:27:40 -0400
Message-Id: <1367612861-37915-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main reason for doing this is will be to allow for an asynchronous
RPC mode that we can use for freeing lock stateids as per section
8.2.4 of RFC5661.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       | 98 +++++++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4xdr.c        |  2 +-
 include/linux/nfs_xdr.h |  2 +-
 3 files changed, 77 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3f4e512..95f73ca 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6783,26 +6783,76 @@ static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 	return err;
 }
 
-static int _nfs4_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
-{
-	struct nfs41_free_stateid_args args = {
-		.stateid = stateid,
-	};
+struct nfs_free_stateid_data {
+	struct nfs_server *server;
+	struct nfs41_free_stateid_args args;
 	struct nfs41_free_stateid_res res;
+};
+
+static void nfs41_free_stateid_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_free_stateid_data *data = calldata;
+	nfs41_setup_sequence(nfs4_get_session(data->server),
+			&data->args.seq_args,
+			&data->res.seq_res,
+			task);
+}
+
+static void nfs41_free_stateid_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs_free_stateid_data *data = calldata;
+
+	nfs41_sequence_done(task, &data->res.seq_res);
+
+	switch (task->tk_status) {
+	case -NFS4ERR_DELAY:
+		if (nfs4_async_handle_error(task, data->server, NULL) == -EAGAIN)
+			rpc_restart_call_prepare(task);
+	}
+}
+
+static void nfs41_free_stateid_release(void *calldata)
+{
+	kfree(calldata);
+}
+
+const struct rpc_call_ops nfs41_free_stateid_ops = {
+	.rpc_call_prepare = nfs41_free_stateid_prepare,
+	.rpc_call_done = nfs41_free_stateid_done,
+	.rpc_release = nfs41_free_stateid_release,
+};
+
+static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
+		nfs4_stateid *stateid,
+		bool privileged)
+{
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FREE_STATEID],
-		.rpc_argp = &args,
-		.rpc_resp = &res,
 	};
-	int status;
+	struct rpc_task_setup task_setup = {
+		.rpc_client = server->client,
+		.rpc_message = &msg,
+		.callback_ops = &nfs41_free_stateid_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
+	struct nfs_free_stateid_data *data;
 
 	dprintk("NFS call  free_stateid %p\n", stateid);
-	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
-	nfs4_set_sequence_privileged(&args.seq_args);
-	status = nfs4_call_sync_sequence(server->client, server, &msg,
-			&args.seq_args, &res.seq_res);
-	dprintk("NFS reply free_stateid: %d\n", status);
-	return status;
+	data = kmalloc(sizeof(*data), GFP_NOFS);
+	if (!data)
+		return ERR_PTR(-ENOMEM);
+	data->server = server;
+	nfs4_stateid_copy(&data->args.stateid, stateid);
+
+	task_setup.callback_data = data;
+
+	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
+	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
+	if (privileged)
+		nfs4_set_sequence_privileged(&data->args.seq_args);
+
+	return rpc_run_task(&task_setup);
 }
 
 /**
@@ -6816,15 +6866,17 @@ static int _nfs4_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
  */
 static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
-	struct nfs4_exception exception = { };
-	int err;
-	do {
-		err = _nfs4_free_stateid(server, stateid);
-		if (err != -NFS4ERR_DELAY)
-			break;
-		nfs4_handle_exception(server, err, &exception);
-	} while (exception.retry);
-	return err;
+	struct rpc_task *task;
+	int ret;
+
+	task = _nfs41_free_stateid(server, stateid, true);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	ret = rpc_wait_for_completion_task(task);
+	if (!ret)
+		ret = task->tk_status;
+	rpc_put_task(task);
+	return ret;
 }
 
 static bool nfs41_match_stateid(const nfs4_stateid *s1,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d40a89b..9be2326e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2003,7 +2003,7 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 				struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_FREE_STATEID, decode_free_stateid_maxsz, hdr);
-	encode_nfs4_stateid(xdr, args->stateid);
+	encode_nfs4_stateid(xdr, &args->stateid);
 }
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 766c5bc..104b62f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1176,7 +1176,7 @@ struct nfs41_test_stateid_res {
 
 struct nfs41_free_stateid_args {
 	struct nfs4_sequence_args	seq_args;
-	nfs4_stateid			*stateid;
+	nfs4_stateid			stateid;
 };
 
 struct nfs41_free_stateid_res {
-- 
1.8.1.4


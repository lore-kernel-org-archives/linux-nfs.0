Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33994 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752166AbdHAUDA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 16:03:00 -0400
Received: by mail-it0-f65.google.com with SMTP id t78so2400722ita.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 13:03:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: davej@codemonkey.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4: Fix double frees in nfs4_test_session_trunk()
Date: Tue,  1 Aug 2017 16:02:48 -0400
Message-Id: <20170801200251.130635-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170801200251.130635-1-trond.myklebust@primarydata.com>
References: <20170801200251.130635-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc_clnt_add_xprt() expects the callback function to be synchronous, and
expects to release the transport and switch references itself.

Fixes: 04fa2c6bb51b1 ("NFS pnfs data server multipath session trunking")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4client.c |  3 ---
 fs/nfs/nfs4proc.c   | 16 +++-------------
 2 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 50566acb5469..e9bea90dc017 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -660,9 +660,6 @@ int nfs4_detect_session_trunking(struct nfs_client *clp,
 	if (!nfs4_check_server_scope(clp->cl_serverscope, res->server_scope))
 		goto out_err;
 
-	/* Session trunking passed, add the xprt */
-	rpc_clnt_xprt_switch_add_xprt(clp->cl_rpcclient, xprt);
-
 	pr_info("NFS:  %s: Session trunking succeeded for %s\n",
 		clp->cl_hostname,
 		xprt->address_strings[RPC_DISPLAY_ADDR]);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0cd98e253e23..ffd2e712595d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7474,10 +7474,6 @@ static void nfs4_exchange_id_release(void *data)
 	struct nfs41_exchange_id_data *cdata =
 					(struct nfs41_exchange_id_data *)data;
 
-	if (cdata->xprt) {
-		xprt_put(cdata->xprt);
-		rpc_clnt_xprt_switch_put(cdata->args.client->cl_rpcclient);
-	}
 	nfs_put_client(cdata->args.client);
 	kfree(cdata->res.impl_id);
 	kfree(cdata->res.server_scope);
@@ -7506,7 +7502,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		.rpc_client = clp->cl_rpcclient,
 		.callback_ops = &nfs4_exchange_id_call_ops,
 		.rpc_message = &msg,
-		.flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT,
+		.flags = RPC_TASK_TIMEOUT,
 	};
 	struct nfs41_exchange_id_data *calldata;
 	struct rpc_task *task;
@@ -7560,8 +7556,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	if (xprt) {
 		calldata->xprt = xprt;
 		task_setup_data.rpc_xprt = xprt;
-		task_setup_data.flags =
-				RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC;
+		task_setup_data.flags |= RPC_TASK_SOFTCONN;
 		memcpy(calldata->args.verifier.data, clp->cl_confirm.data,
 				sizeof(calldata->args.verifier.data));
 	}
@@ -7582,12 +7577,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 
-	if (!xprt) {
-		status = rpc_wait_for_completion_task(task);
-		if (!status)
-			status = calldata->rpc_status;
-	} else	/* session trunking test */
-		status = calldata->rpc_status;
+	status = calldata->rpc_status;
 
 	rpc_put_task(task);
 out:
-- 
2.13.3


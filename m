Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35258 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752198AbdHAUDC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 16:03:02 -0400
Received: by mail-it0-f65.google.com with SMTP id v127so2398746itd.2
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 13:03:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: davej@codemonkey.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4: Refactor _nfs4_proc_exchange_id()
Date: Tue,  1 Aug 2017 16:02:49 -0400
Message-Id: <20170801200251.130635-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170801200251.130635-2-trond.myklebust@primarydata.com>
References: <20170801200251.130635-1-trond.myklebust@primarydata.com>
 <20170801200251.130635-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tease apart the functionality in nfs4_exchange_id_done() so that
it is easier to debug exchange id vs trunking issues by moving
all the processing out of nfs4_exchange_id_done() and into the
callers.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 171 +++++++++++++++++++++++++++---------------------------
 1 file changed, 85 insertions(+), 86 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ffd2e712595d..34190c2c0900 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7403,72 +7403,8 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 struct nfs41_exchange_id_data {
 	struct nfs41_exchange_id_res res;
 	struct nfs41_exchange_id_args args;
-	struct rpc_xprt *xprt;
-	int rpc_status;
 };
 
-static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
-{
-	struct nfs41_exchange_id_data *cdata =
-					(struct nfs41_exchange_id_data *)data;
-	struct nfs_client *clp = cdata->args.client;
-	int status = task->tk_status;
-
-	trace_nfs4_exchange_id(clp, status);
-
-	if (status == 0)
-		status = nfs4_check_cl_exchange_flags(cdata->res.flags);
-
-	if (cdata->xprt && status == 0) {
-		status = nfs4_detect_session_trunking(clp, &cdata->res,
-						      cdata->xprt);
-		goto out;
-	}
-
-	if (status  == 0)
-		status = nfs4_sp4_select_mode(clp, &cdata->res.state_protect);
-
-	if (status == 0) {
-		clp->cl_clientid = cdata->res.clientid;
-		clp->cl_exchange_flags = cdata->res.flags;
-		clp->cl_seqid = cdata->res.seqid;
-		/* Client ID is not confirmed */
-		if (!(cdata->res.flags & EXCHGID4_FLAG_CONFIRMED_R))
-			clear_bit(NFS4_SESSION_ESTABLISHED,
-				  &clp->cl_session->session_state);
-
-		kfree(clp->cl_serverowner);
-		clp->cl_serverowner = cdata->res.server_owner;
-		cdata->res.server_owner = NULL;
-
-		/* use the most recent implementation id */
-		kfree(clp->cl_implid);
-		clp->cl_implid = cdata->res.impl_id;
-		cdata->res.impl_id = NULL;
-
-		if (clp->cl_serverscope != NULL &&
-		    !nfs41_same_server_scope(clp->cl_serverscope,
-					cdata->res.server_scope)) {
-			dprintk("%s: server_scope mismatch detected\n",
-				__func__);
-			set_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state);
-			kfree(clp->cl_serverscope);
-			clp->cl_serverscope = NULL;
-		}
-
-		if (clp->cl_serverscope == NULL) {
-			clp->cl_serverscope = cdata->res.server_scope;
-			cdata->res.server_scope = NULL;
-		}
-		/* Save the EXCHANGE_ID verifier session trunk tests */
-		memcpy(clp->cl_confirm.data, cdata->args.verifier.data,
-		       sizeof(clp->cl_confirm.data));
-	}
-out:
-	cdata->rpc_status = status;
-	return;
-}
-
 static void nfs4_exchange_id_release(void *data)
 {
 	struct nfs41_exchange_id_data *cdata =
@@ -7482,7 +7418,6 @@ static void nfs4_exchange_id_release(void *data)
 }
 
 static const struct rpc_call_ops nfs4_exchange_id_call_ops = {
-	.rpc_call_done = nfs4_exchange_id_done,
 	.rpc_release = nfs4_exchange_id_release,
 };
 
@@ -7491,7 +7426,8 @@ static const struct rpc_call_ops nfs4_exchange_id_call_ops = {
  *
  * Wrapper for EXCHANGE_ID operation.
  */
-static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
+static struct rpc_task *
+nfs4_run_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 			u32 sp4_how, struct rpc_xprt *xprt)
 {
 	struct rpc_message msg = {
@@ -7505,17 +7441,15 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		.flags = RPC_TASK_TIMEOUT,
 	};
 	struct nfs41_exchange_id_data *calldata;
-	struct rpc_task *task;
 	int status;
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
-		return -EIO;
+		return ERR_PTR(-EIO);
 
+	status = -ENOMEM;
 	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
-	if (!calldata) {
-		nfs_put_client(clp);
-		return -ENOMEM;
-	}
+	if (!calldata)
+		goto out;
 
 	nfs4_init_boot_verifier(clp, &calldata->args.verifier);
 
@@ -7554,7 +7488,6 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		goto out_impl_id;
 	}
 	if (xprt) {
-		calldata->xprt = xprt;
 		task_setup_data.rpc_xprt = xprt;
 		task_setup_data.flags |= RPC_TASK_SOFTCONN;
 		memcpy(calldata->args.verifier.data, clp->cl_confirm.data,
@@ -7573,15 +7506,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
 
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-
-	status = calldata->rpc_status;
-
-	rpc_put_task(task);
-out:
-	return status;
+	return rpc_run_task(&task_setup_data);
 
 out_impl_id:
 	kfree(calldata->res.impl_id);
@@ -7591,8 +7516,69 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	kfree(calldata->res.server_owner);
 out_calldata:
 	kfree(calldata);
+out:
 	nfs_put_client(clp);
-	goto out;
+	return ERR_PTR(status);
+}
+
+/*
+ * _nfs4_proc_exchange_id()
+ *
+ * Wrapper for EXCHANGE_ID operation.
+ */
+static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
+			u32 sp4_how)
+{
+	struct rpc_task *task;
+	struct nfs41_exchange_id_args *argp;
+	struct nfs41_exchange_id_res *resp;
+	int status;
+
+	task = nfs4_run_exchange_id(clp, cred, sp4_how, NULL);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+
+	argp = task->tk_msg.rpc_argp;
+	resp = task->tk_msg.rpc_resp;
+	status = task->tk_status;
+	if (status  != 0)
+		goto out;
+
+	status = nfs4_check_cl_exchange_flags(resp->flags);
+	if (status  != 0)
+		goto out;
+
+	status = nfs4_sp4_select_mode(clp, &resp->state_protect);
+	if (status != 0)
+		goto out;
+
+	clp->cl_clientid = resp->clientid;
+	clp->cl_exchange_flags = resp->flags;
+	clp->cl_seqid = resp->seqid;
+	/* Client ID is not confirmed */
+	if (!(resp->flags & EXCHGID4_FLAG_CONFIRMED_R))
+		clear_bit(NFS4_SESSION_ESTABLISHED,
+			  &clp->cl_session->session_state);
+
+	if (clp->cl_serverscope != NULL &&
+	    !nfs41_same_server_scope(clp->cl_serverscope,
+				resp->server_scope)) {
+		dprintk("%s: server_scope mismatch detected\n",
+			__func__);
+		set_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state);
+	}
+
+	swap(clp->cl_serverowner, resp->server_owner);
+	swap(clp->cl_serverscope, resp->server_scope);
+	swap(clp->cl_implid, resp->impl_id);
+
+	/* Save the EXCHANGE_ID verifier session trunk tests */
+	memcpy(clp->cl_confirm.data, argp->verifier.data,
+	       sizeof(clp->cl_confirm.data));
+out:
+	trace_nfs4_exchange_id(clp, status);
+	rpc_put_task(task);
+	return status;
 }
 
 /*
@@ -7615,13 +7601,13 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	/* try SP4_MACH_CRED if krb5i/p	*/
 	if (authflavor == RPC_AUTH_GSS_KRB5I ||
 	    authflavor == RPC_AUTH_GSS_KRB5P) {
-		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED, NULL);
+		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED);
 		if (!status)
 			return 0;
 	}
 
 	/* try SP4_NONE */
-	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE, NULL);
+	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE);
 }
 
 /**
@@ -7643,6 +7629,9 @@ int nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt *xprt,
 			    void *data)
 {
 	struct nfs4_add_xprt_data *adata = (struct nfs4_add_xprt_data *)data;
+	struct rpc_task *task;
+	int status;
+
 	u32 sp4_how;
 
 	dprintk("--> %s try %s\n", __func__,
@@ -7651,7 +7640,17 @@ int nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt *xprt,
 	sp4_how = (adata->clp->cl_sp4_flags == 0 ? SP4_NONE : SP4_MACH_CRED);
 
 	/* Test connection for session trunking. Async exchange_id call */
-	return  _nfs4_proc_exchange_id(adata->clp, adata->cred, sp4_how, xprt);
+	task = nfs4_run_exchange_id(adata->clp, adata->cred, sp4_how, xprt);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+
+	status = task->tk_status;
+	if (status == 0)
+		status = nfs4_detect_session_trunking(adata->clp,
+				task->tk_msg.rpc_resp, xprt);
+
+	rpc_put_task(task);
+	return status;
 }
 EXPORT_SYMBOL_GPL(nfs4_test_session_trunk);
 
-- 
2.13.3


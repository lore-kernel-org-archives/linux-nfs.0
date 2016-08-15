Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:55115 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004AbcHOSwk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2016 14:52:40 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 01/12] NFS setup async exchange_id
Date: Mon, 15 Aug 2016 14:50:37 -0400
Message-ID: <1471287048-27007-2-git-send-email-andros@netapp.com>
In-Reply-To: <1471287048-27007-1-git-send-email-andros@netapp.com>
References: <1471287048-27007-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Testing an rpc_xprt for session trunking should not delay application
progress over already established transports.
Setup exchange_id to be able to be an async call to test an rpc_xprt
for session trunking use.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 215 ++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 134 insertions(+), 81 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index da5c9e5..e29f5ce 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7051,6 +7051,80 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 	return 0;
 }
 
+struct nfs41_exchange_id_data {
+	struct nfs41_exchange_id_res res;
+	struct nfs41_exchange_id_args args;
+	int rpc_status;
+};
+
+static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
+{
+	struct nfs41_exchange_id_data *cdata =
+					(struct nfs41_exchange_id_data *)data;
+	struct nfs_client *clp = cdata->args.client;
+	int status = task->tk_status;
+
+	trace_nfs4_exchange_id(clp, status);
+
+	if (status == 0)
+		status = nfs4_check_cl_exchange_flags(cdata->res.flags);
+	if (status  == 0)
+		status = nfs4_sp4_select_mode(clp, &cdata->res.state_protect);
+
+	if (status == 0) {
+		clp->cl_clientid = cdata->res.clientid;
+		clp->cl_exchange_flags = cdata->res.flags;
+		/* Client ID is not confirmed */
+		if (!(cdata->res.flags & EXCHGID4_FLAG_CONFIRMED_R)) {
+			clear_bit(NFS4_SESSION_ESTABLISHED,
+			&clp->cl_session->session_state);
+			clp->cl_seqid = cdata->res.seqid;
+		}
+
+		kfree(clp->cl_serverowner);
+		clp->cl_serverowner = cdata->res.server_owner;
+		cdata->res.server_owner = NULL;
+
+		/* use the most recent implementation id */
+		kfree(clp->cl_implid);
+		clp->cl_implid = cdata->res.impl_id;
+		cdata->res.impl_id = NULL;
+
+		if (clp->cl_serverscope != NULL &&
+		    !nfs41_same_server_scope(clp->cl_serverscope,
+					cdata->res.server_scope)) {
+			dprintk("%s: server_scope mismatch detected\n",
+				__func__);
+			set_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state);
+			kfree(clp->cl_serverscope);
+			clp->cl_serverscope = NULL;
+		}
+
+		if (clp->cl_serverscope == NULL) {
+			clp->cl_serverscope = cdata->res.server_scope;
+			cdata->res.server_scope = NULL;
+		}
+	}
+	cdata->rpc_status = status;
+}
+
+static void nfs4_exchange_id_release(void *data)
+{
+	struct nfs41_exchange_id_data *cdata =
+					(struct nfs41_exchange_id_data *)data;
+
+	nfs_put_client(cdata->args.client);
+	kfree(cdata->res.impl_id);
+	kfree(cdata->res.server_scope);
+	kfree(cdata->res.server_owner);
+	kfree(cdata);
+}
+
+static const struct rpc_call_ops nfs4_exchange_id_call_ops = {
+	.rpc_call_done = nfs4_exchange_id_done,
+	.rpc_release = nfs4_exchange_id_release,
+};
+
 /*
  * _nfs4_proc_exchange_id()
  *
@@ -7060,66 +7134,60 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	u32 sp4_how)
 {
 	nfs4_verifier verifier;
-	struct nfs41_exchange_id_args args = {
-		.verifier = &verifier,
-		.client = clp,
-#ifdef CONFIG_NFS_V4_1_MIGRATION
-		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
-			 EXCHGID4_FLAG_BIND_PRINC_STATEID |
-			 EXCHGID4_FLAG_SUPP_MOVED_MIGR,
-#else
-		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
-			 EXCHGID4_FLAG_BIND_PRINC_STATEID,
-#endif
-	};
-	struct nfs41_exchange_id_res res = {
-		0
-	};
-	int status;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_EXCHANGE_ID],
-		.rpc_argp = &args,
-		.rpc_resp = &res,
 		.rpc_cred = cred,
 	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clp->cl_rpcclient,
+		.callback_ops = &nfs4_exchange_id_call_ops,
+		.rpc_message = &msg,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT,
+	};
+	struct nfs41_exchange_id_data *calldata;
+	struct rpc_task *task;
+	int status = -EIO;
+
+	if (!atomic_inc_not_zero(&clp->cl_count))
+		goto out;
+
+	status = -ENOMEM;
+	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
+	if (!calldata)
+		goto out;
 
 	nfs4_init_boot_verifier(clp, &verifier);
 
 	status = nfs4_init_uniform_client_string(clp);
 	if (status)
-		goto out;
+		goto out_calldata;
 
 	dprintk("NFS call  exchange_id auth=%s, '%s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		clp->cl_owner_id);
 
-	res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
-					GFP_NOFS);
-	if (unlikely(res.server_owner == NULL)) {
-		status = -ENOMEM;
-		goto out;
-	}
+	calldata->res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
+						GFP_NOFS);
+	status = -ENOMEM;
+	if (unlikely(calldata->res.server_owner == NULL))
+		goto out_calldata;
 
-	res.server_scope = kzalloc(sizeof(struct nfs41_server_scope),
+	calldata->res.server_scope = kzalloc(sizeof(struct nfs41_server_scope),
 					GFP_NOFS);
-	if (unlikely(res.server_scope == NULL)) {
-		status = -ENOMEM;
+	if (unlikely(calldata->res.server_scope == NULL))
 		goto out_server_owner;
-	}
 
-	res.impl_id = kzalloc(sizeof(struct nfs41_impl_id), GFP_NOFS);
-	if (unlikely(res.impl_id == NULL)) {
-		status = -ENOMEM;
+	calldata->res.impl_id = kzalloc(sizeof(struct nfs41_impl_id), GFP_NOFS);
+	if (unlikely(calldata->res.impl_id == NULL))
 		goto out_server_scope;
-	}
 
 	switch (sp4_how) {
 	case SP4_NONE:
-		args.state_protect.how = SP4_NONE;
+		calldata->args.state_protect.how = SP4_NONE;
 		break;
 
 	case SP4_MACH_CRED:
-		args.state_protect = nfs4_sp4_mach_cred_request;
+		calldata->args.state_protect = nfs4_sp4_mach_cred_request;
 		break;
 
 	default:
@@ -7129,55 +7197,30 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		goto out_impl_id;
 	}
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
-	trace_nfs4_exchange_id(clp, status);
-	if (status == 0)
-		status = nfs4_check_cl_exchange_flags(res.flags);
-
-	if (status == 0)
-		status = nfs4_sp4_select_mode(clp, &res.state_protect);
-
-	if (status == 0) {
-		clp->cl_clientid = res.clientid;
-		clp->cl_exchange_flags = res.flags;
-		/* Client ID is not confirmed */
-		if (!(res.flags & EXCHGID4_FLAG_CONFIRMED_R)) {
-			clear_bit(NFS4_SESSION_ESTABLISHED,
-					&clp->cl_session->session_state);
-			clp->cl_seqid = res.seqid;
-		}
-
-		kfree(clp->cl_serverowner);
-		clp->cl_serverowner = res.server_owner;
-		res.server_owner = NULL;
-
-		/* use the most recent implementation id */
-		kfree(clp->cl_implid);
-		clp->cl_implid = res.impl_id;
-		res.impl_id = NULL;
-
-		if (clp->cl_serverscope != NULL &&
-		    !nfs41_same_server_scope(clp->cl_serverscope,
-					     res.server_scope)) {
-			dprintk("%s: server_scope mismatch detected\n",
-				__func__);
-			set_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state);
-			kfree(clp->cl_serverscope);
-			clp->cl_serverscope = NULL;
-		}
+	calldata->args.verifier = &verifier;
+	calldata->args.client = clp;
+#ifdef CONFIG_NFS_V4_1_MIGRATION
+	calldata->args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
+	EXCHGID4_FLAG_BIND_PRINC_STATEID |
+	EXCHGID4_FLAG_SUPP_MOVED_MIGR,
+#else
+	calldata->args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
+	EXCHGID4_FLAG_BIND_PRINC_STATEID,
+#endif
+	msg.rpc_argp = &calldata->args;
+	msg.rpc_resp = &calldata->res;
+	task_setup_data.callback_data = calldata;
 
-		if (clp->cl_serverscope == NULL) {
-			clp->cl_serverscope = res.server_scope;
-			res.server_scope = NULL;
-		}
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task)) {
+	status = PTR_ERR(task);
+		goto out_impl_id;
 	}
 
-out_impl_id:
-	kfree(res.impl_id);
-out_server_scope:
-	kfree(res.server_scope);
-out_server_owner:
-	kfree(res.server_owner);
+	status = rpc_wait_for_completion_task(task);
+	if (!status)
+		status = calldata->rpc_status;
+	rpc_put_task(task);
 out:
 	if (clp->cl_implid != NULL)
 		dprintk("NFS reply exchange_id: Server Implementation ID: "
@@ -7187,6 +7230,16 @@ out:
 			clp->cl_implid->date.nseconds);
 	dprintk("NFS reply exchange_id: %d\n", status);
 	return status;
+
+out_impl_id:
+	kfree(calldata->res.impl_id);
+out_server_scope:
+	kfree(calldata->res.server_scope);
+out_server_owner:
+	kfree(calldata->res.server_owner);
+out_calldata:
+	kfree(calldata);
+	goto out;
 }
 
 /*
-- 
1.8.3.1


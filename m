Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:61757 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753592AbcIINY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 09:24:27 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 10 11/12] NFS test session trunking with exchange id
Date: Fri, 9 Sep 2016 09:22:28 -0400
Message-ID: <1473427349-13265-12-git-send-email-andros@netapp.com>
In-Reply-To: <1473427349-13265-1-git-send-email-andros@netapp.com>
References: <1473427349-13265-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use an async exchange id call to test for session trunking

To conform with RFC 5661 section 18.35.4, the Non-Update on
Existing Clientid case, save the exchange id verifier in
cl_confirm and use it for the session trunking exhange id test.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4client.c | 10 +++++++---
 fs/nfs/nfs4proc.c   | 45 +++++++++++++++++++++++++++++++++++++--------
 2 files changed, 44 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 3371395..5a45d07 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -637,9 +637,10 @@ out_scope_mismatch:
 }
 
 /**
- * nfs4_detect_session_trunking - Checks for session trunking called
- * after a successful EXCHANGE_ID testing a multi-addr connection to be
- * potentially added as a session trunk
+ * nfs4_detect_session_trunking - Checks for session trunking.
+ *
+ * Called after a successful EXCHANGE_ID on a multi-addr connection.
+ * Upon success, add the transport.
  *
  * @clp:    original mount nfs_client
  * @res:    result structure from an exchange_id using the original mount
@@ -673,6 +674,9 @@ int nfs4_detect_session_trunking(struct nfs_client *clp,
 	if (!nfs4_check_server_scope(clp->cl_serverscope, res->server_scope))
 		goto out_err;
 
+	/* Session trunking passed, add the xprt */
+	rpc_clnt_xprt_switch_add_xprt(clp->cl_rpcclient, xprt);
+
 	pr_info("NFS:  %s: Session trunking succeeded for %s\n",
 		clp->cl_hostname,
 		xprt->address_strings[RPC_DISPLAY_ADDR]);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 98bd30e..0cea0e4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7051,6 +7051,7 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 struct nfs41_exchange_id_data {
 	struct nfs41_exchange_id_res res;
 	struct nfs41_exchange_id_args args;
+	struct rpc_xprt *xprt;
 	int rpc_status;
 };
 
@@ -7065,6 +7066,13 @@ static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
 
 	if (status == 0)
 		status = nfs4_check_cl_exchange_flags(cdata->res.flags);
+
+	if (cdata->xprt && status == 0) {
+		status = nfs4_detect_session_trunking(clp, &cdata->res,
+						      cdata->xprt);
+		goto out;
+	}
+
 	if (status  == 0)
 		status = nfs4_sp4_select_mode(clp, &cdata->res.state_protect);
 
@@ -7101,8 +7109,13 @@ static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
 			clp->cl_serverscope = cdata->res.server_scope;
 			cdata->res.server_scope = NULL;
 		}
+		/* Save the EXCHANGE_ID verifier session trunk tests */
+		memcpy(clp->cl_confirm.data, cdata->args.verifier->data,
+		       sizeof(clp->cl_confirm.data));
 	}
+out:
 	cdata->rpc_status = status;
+	return;
 }
 
 static void nfs4_exchange_id_release(void *data)
@@ -7111,6 +7124,10 @@ static void nfs4_exchange_id_release(void *data)
 					(struct nfs41_exchange_id_data *)data;
 
 	nfs_put_client(cdata->args.client);
+	if (cdata->xprt) {
+		xprt_put(cdata->xprt);
+		rpc_clnt_xprt_switch_put(cdata->args.client->cl_rpcclient);
+	}
 	kfree(cdata->res.impl_id);
 	kfree(cdata->res.server_scope);
 	kfree(cdata->res.server_owner);
@@ -7128,7 +7145,7 @@ static const struct rpc_call_ops nfs4_exchange_id_call_ops = {
  * Wrapper for EXCHANGE_ID operation.
  */
 static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
-	u32 sp4_how)
+			u32 sp4_how, struct rpc_xprt *xprt)
 {
 	nfs4_verifier verifier;
 	struct rpc_message msg = {
@@ -7153,7 +7170,8 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	if (!calldata)
 		goto out;
 
-	nfs4_init_boot_verifier(clp, &verifier);
+	if (!xprt)
+		nfs4_init_boot_verifier(clp, &verifier);
 
 	status = nfs4_init_uniform_client_string(clp);
 	if (status)
@@ -7193,8 +7211,15 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		status = -EINVAL;
 		goto out_impl_id;
 	}
-
-	calldata->args.verifier = &verifier;
+	if (xprt) {
+		calldata->xprt = xprt;
+		task_setup_data.rpc_xprt = xprt;
+		task_setup_data.flags =
+				RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC;
+		calldata->args.verifier = &clp->cl_confirm;
+	} else {
+		calldata->args.verifier = &verifier;
+	}
 	calldata->args.client = clp;
 #ifdef CONFIG_NFS_V4_1_MIGRATION
 	calldata->args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
@@ -7214,9 +7239,13 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		goto out_impl_id;
 	}
 
-	status = rpc_wait_for_completion_task(task);
-	if (!status)
+	if (!xprt) {
+		status = rpc_wait_for_completion_task(task);
+		if (!status)
+			status = calldata->rpc_status;
+	} else	/* session trunking test */
 		status = calldata->rpc_status;
+
 	rpc_put_task(task);
 out:
 	if (clp->cl_implid != NULL)
@@ -7259,13 +7288,13 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	/* try SP4_MACH_CRED if krb5i/p	*/
 	if (authflavor == RPC_AUTH_GSS_KRB5I ||
 	    authflavor == RPC_AUTH_GSS_KRB5P) {
-		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED);
+		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED, NULL);
 		if (!status)
 			return 0;
 	}
 
 	/* try SP4_NONE */
-	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE);
+	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE, NULL);
 }
 
 static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
-- 
1.8.3.1


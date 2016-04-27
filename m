Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:3483 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394AbcD0Pgs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:36:48 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 6/9] NFS refactor _nfs4_proc_exchange_id for session trunking
Date: Wed, 27 Apr 2016 11:36:07 -0400
Message-ID: <1461771370-16375-7-git-send-email-andros@netapp.com>
In-Reply-To: <1461771370-16375-1-git-send-email-andros@netapp.com>
References: <1461771370-16375-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Add an rpc_xprt parameter to test it's connection for session trunking

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 34 ++++++++++++++++++++++++++++------
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index da2aa2e..70537f0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7024,7 +7024,7 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
  * Wrapper for EXCHANGE_ID operation.
  */
 static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
-	u32 sp4_how)
+	u32 sp4_how, struct rpc_xprt *xprt)
 {
 	nfs4_verifier verifier;
 	struct nfs41_exchange_id_args args = {
@@ -7049,6 +7049,18 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		.rpc_resp = &res,
 		.rpc_cred = cred,
 	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clp->cl_rpcclient,
+		.rpc_xprt = xprt,
+		.callback_ops = &nfs4_proc_default_ops,
+		.rpc_message = &msg,
+		.flags = RPC_TASK_TIMEOUT,
+	};
+	struct rpc_task *task;
+
+	/* Do not run exchange_id against the established mount connection */
+	if (xprt && xprt == rcu_access_pointer(clp->cl_rpcclient->cl_xprt))
+		return 1;
 
 	nfs4_init_boot_verifier(clp, &verifier);
 
@@ -7096,11 +7108,17 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 		goto out_impl_id;
 	}
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	task = rpc_run_task(&task_setup_data);
+	if (!IS_ERR(task)) {
+		status = task->tk_status;
+		rpc_put_task(task);
+	} else
+		status = PTR_ERR(task);
 	trace_nfs4_exchange_id(clp, status);
 	if (status == 0)
 		status = nfs4_check_cl_exchange_flags(res.flags);
-
+	if (xprt)
+		goto session_trunk;
 	if (status == 0)
 		status = nfs4_sp4_select_mode(clp, &res.state_protect);
 
@@ -7138,7 +7156,6 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 			res.server_scope = NULL;
 		}
 	}
-
 out_impl_id:
 	kfree(res.impl_id);
 out_server_scope:
@@ -7154,6 +7171,11 @@ out:
 			clp->cl_implid->date.nseconds);
 	dprintk("NFS reply exchange_id: %d\n", status);
 	return status;
+
+session_trunk:
+	if (status == 0)
+		status = nfs4_detect_session_trunking(clp, &res);
+	goto out_impl_id;
 }
 
 /*
@@ -7176,13 +7198,13 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
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


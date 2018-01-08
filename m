Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33805 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751838AbeAHFbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jan 2018 00:31:39 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 08 Jan 2018 16:26:19 +1100
Subject: [PATCH 10/20] SUNRPC: introduce RPC_TASK_NULLCREDS to request
 auth_none
Cc: linux-nfs@vger.kernel.org
Message-ID: <151538917906.25812.606388515969165496.stgit@noble>
In-Reply-To: <151538903497.25812.13293229343061416612.stgit@noble>
References: <151538903497.25812.13293229343061416612.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In almost all cases the credential stored in rpc_message.rpc_cred
is a "generic" credential.  One of the two expections is when an
AUTH_NULL credential is used such as for RPC ping requests.

To improve consistency, don't pass an explicit credential in
these cases, but instead pass NULL and set a task flag,
similar to RPC_TASK_ROOTCREDS, which requests that NULL credentials
be used by default.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/auth.c            |    2 ++
 net/sunrpc/clnt.c            |   19 ++++++-------------
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 3b3c5ab57341..0c773194eb47 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -118,6 +118,7 @@ struct rpc_task_setup {
  */
 #define RPC_TASK_ASYNC		0x0001		/* is an async task */
 #define RPC_TASK_SWAPPER	0x0002		/* is swapping in/out */
+#define RPC_TASK_NULLCREDS	0x0010		/* Use AUTH_NULL credential */
 #define RPC_CALL_MAJORSEEN	0x0020		/* major timeout seen */
 #define RPC_TASK_ROOTCREDS	0x0040		/* force root creds */
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index ddffc602f423..b0963f642f0d 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -736,6 +736,8 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 		;
 	else if (cred == &machine_cred || (flags & RPC_TASK_ROOTCREDS))
 		new = rpcauth_bind_root_cred(task, lookupflags);
+	else if (flags & RPC_TASK_NULLCREDS)
+		new = authnull_ops.lookup_cred(NULL, NULL, 0);
 	else
 		new = rpcauth_bind_new_cred(task, lookupflags);
 	if (IS_ERR(new))
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 68faee0f3671..1aef8d1b9ef4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2520,9 +2520,8 @@ static int rpc_ping(struct rpc_clnt *clnt)
 		.rpc_proc = &rpcproc_null,
 	};
 	int err;
-	msg.rpc_cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN);
-	put_rpccred(msg.rpc_cred);
+	err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN |
+			    RPC_TASK_NULLCREDS);
 	return err;
 }
 
@@ -2592,7 +2591,6 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 		void *dummy)
 {
 	struct rpc_cb_add_xprt_calldata *data;
-	struct rpc_cred *cred;
 	struct rpc_task *task;
 
 	data = kmalloc(sizeof(*data), GFP_NOFS);
@@ -2601,11 +2599,9 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 	data->xps = xprt_switch_get(xps);
 	data->xprt = xprt_get(xprt);
 
-	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	task = rpc_call_null_helper(clnt, xprt, cred,
-			RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC,
+	task = rpc_call_null_helper(clnt, xprt, NULL,
+			RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC|RPC_TASK_NULLCREDS,
 			&rpc_cb_add_xprt_call_ops, data);
-	put_rpccred(cred);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	rpc_put_task(task);
@@ -2636,7 +2632,6 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 				     struct rpc_xprt *xprt,
 				     void *data)
 {
-	struct rpc_cred *cred;
 	struct rpc_task *task;
 	struct rpc_add_xprt_test *xtest = (struct rpc_add_xprt_test *)data;
 	int status = -EADDRINUSE;
@@ -2648,11 +2643,9 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 		goto out_err;
 
 	/* Test the connection */
-	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	task = rpc_call_null_helper(clnt, xprt, cred,
-				    RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
+	task = rpc_call_null_helper(clnt, xprt, NULL,
+				    RPC_TASK_SOFT | RPC_TASK_SOFTCONN | RPC_TASK_NULLCREDS,
 				    NULL, NULL);
-	put_rpccred(cred);
 	if (IS_ERR(task)) {
 		status = PTR_ERR(task);
 		goto out_err;



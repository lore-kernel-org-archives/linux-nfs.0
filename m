Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:37320 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932162Ab3IBSRS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 14:17:18 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v3 17/17] SUNRPC: rpcauth_create needs to know about rpc_clnt clone status
Date: Mon, 2 Sep 2013 14:17:00 -0400
Message-ID: <1378145820-29990-17-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378145820-29990-16-git-send-email-Trond.Myklebust@netapp.com>
References: <1378145820-29990-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-2-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-3-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-4-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-5-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-6-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-7-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-8-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-9-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-10-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-11-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-12-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-13-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-14-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-15-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-16-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we set rpc_clnt->cl_parent before calling rpc_client_register
so that rpcauth_create can find any existing RPCSEC_GSS caches for this
transport.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index af3f0cf..8572d32 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -313,7 +313,9 @@ out:
 	return err;
 }
 
-static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
+static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
+		struct rpc_xprt *xprt,
+		struct rpc_clnt *parent)
 {
 	const struct rpc_program *program = args->program;
 	const struct rpc_version *version;
@@ -339,7 +341,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	clnt = kzalloc(sizeof(*clnt), GFP_KERNEL);
 	if (!clnt)
 		goto out_err;
-	clnt->cl_parent = clnt;
+	clnt->cl_parent = parent ? : clnt;
 
 	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
@@ -377,6 +379,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	err = rpc_client_register(args, clnt);
 	if (err)
 		goto out_no_path;
+	if (parent)
+		atomic_inc(&parent->cl_count);
 	return clnt;
 
 out_no_path:
@@ -467,7 +471,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
 		xprt->resvport = 0;
 
-	clnt = rpc_new_client(args, xprt);
+	clnt = rpc_new_client(args, xprt, NULL);
 	if (IS_ERR(clnt))
 		return clnt;
 
@@ -514,15 +518,12 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 		goto out_err;
 	args->servername = xprt->servername;
 
-	new = rpc_new_client(args, xprt);
+	new = rpc_new_client(args, xprt, clnt);
 	if (IS_ERR(new)) {
 		err = PTR_ERR(new);
 		goto out_err;
 	}
 
-	atomic_inc(&clnt->cl_count);
-	new->cl_parent = clnt;
-
 	/* Turn off autobind on clones */
 	new->cl_autobind = 0;
 	new->cl_softrtry = clnt->cl_softrtry;
-- 
1.8.3.1


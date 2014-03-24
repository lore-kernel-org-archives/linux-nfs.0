Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59342 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbaCXD7G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 23:59:06 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so4879776pab.13
        for <linux-nfs@vger.kernel.org>; Sun, 23 Mar 2014 20:59:05 -0700 (PDT)
Message-ID: <532FAD83.4040907@gmail.com>
Date: Mon, 24 Mar 2014 11:58:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/5][RESEND] SUNRPC: New helper for creating client with rpc_xprt
References: <532FAC85.20909@gmail.com>
In-Reply-To: <532FAC85.20909@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/clnt.h |  2 ++
 net/sunrpc/clnt.c           | 58 ++++++++++++++++++++++++++-------------------
 2 files changed, 35 insertions(+), 25 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 8af2804..70736b9 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -130,6 +130,8 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT	(1UL << 9)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
+struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
+					struct rpc_xprt *xprt);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
 				const struct rpc_program *, u32);
 void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0edada9..3c9a0f0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -438,6 +438,38 @@ out_no_rpciod:
 	return ERR_PTR(err);
 }
 
+struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
+					struct rpc_xprt *xprt)
+{
+	struct rpc_clnt *clnt = NULL;
+
+	clnt = rpc_new_client(args, xprt, NULL);
+	if (IS_ERR(clnt))
+		return clnt;
+
+	if (!(args->flags & RPC_CLNT_CREATE_NOPING)) {
+		int err = rpc_ping(clnt);
+		if (err != 0) {
+			rpc_shutdown_client(clnt);
+			return ERR_PTR(err);
+		}
+	}
+
+	clnt->cl_softrtry = 1;
+	if (args->flags & RPC_CLNT_CREATE_HARDRTRY)
+		clnt->cl_softrtry = 0;
+
+	if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
+		clnt->cl_autobind = 1;
+	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
+		clnt->cl_discrtry = 1;
+	if (!(args->flags & RPC_CLNT_CREATE_QUIET))
+		clnt->cl_chatty = 1;
+
+	return clnt;
+}
+EXPORT_SYMBOL_GPL(rpc_create_xprt);
+
 /**
  * rpc_create - create an RPC client and transport with one call
  * @args: rpc_clnt create argument structure
@@ -451,7 +483,6 @@ out_no_rpciod:
 struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 {
 	struct rpc_xprt *xprt;
-	struct rpc_clnt *clnt;
 	struct xprt_create xprtargs = {
 		.net = args->net,
 		.ident = args->protocol,
@@ -515,30 +546,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
 		xprt->resvport = 0;
 
-	clnt = rpc_new_client(args, xprt, NULL);
-	if (IS_ERR(clnt))
-		return clnt;
-
-	if (!(args->flags & RPC_CLNT_CREATE_NOPING)) {
-		int err = rpc_ping(clnt);
-		if (err != 0) {
-			rpc_shutdown_client(clnt);
-			return ERR_PTR(err);
-		}
-	}
-
-	clnt->cl_softrtry = 1;
-	if (args->flags & RPC_CLNT_CREATE_HARDRTRY)
-		clnt->cl_softrtry = 0;
-
-	if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
-		clnt->cl_autobind = 1;
-	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
-		clnt->cl_discrtry = 1;
-	if (!(args->flags & RPC_CLNT_CREATE_QUIET))
-		clnt->cl_chatty = 1;
-
-	return clnt;
+	return rpc_create_xprt(args, xprt);
 }
 EXPORT_SYMBOL_GPL(rpc_create);
 
-- 
1.8.5.3

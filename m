Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:61322 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaAIKcu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 05:32:50 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so3143504pab.20
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 02:32:50 -0800 (PST)
Message-ID: <52CE7ACC.3090906@gmail.com>
Date: Thu, 09 Jan 2014 18:32:44 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/5] SUNRPC: New helper for creating client with rpc_xprt
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org> <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com> <52CB8B79.6040907@gmail.com> <52CE7A76.3080101@gmail.com>
In-Reply-To: <52CE7A76.3080101@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/clnt.h |  2 ++
 net/sunrpc/clnt.c           | 58 ++++++++++++++++++++++++++-------------------
 2 files changed, 35 insertions(+), 25 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 8af2804..bb9a1fa 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -130,6 +130,8 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT	(1UL << 9)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
+struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
+				struct rpc_xprt *xprt);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
 				const struct rpc_program *, u32);
 void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b9276a6..c70da0e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -438,6 +438,38 @@ out_no_rpciod:
 	return ERR_PTR(err);
 }
 
+struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
+					struct rpc_xprt *xprt)
+{
+	struct rpc_clnt *clnt;
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
1.8.4.2

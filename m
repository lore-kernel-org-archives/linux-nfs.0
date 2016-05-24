Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59266 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbcEXVQU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 17:16:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] nfsd4/rpc: move backchannel create logic into rpc code
Date: Tue, 24 May 2016 17:16:15 -0400
Message-Id: <1464124576-27467-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1464124576-27467-1-git-send-email-bfields@redhat.com>
References: <1464124576-27467-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Also simplify the logic a bit.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c      | 18 +-----------------
 include/linux/sunrpc/clnt.h |  2 --
 net/sunrpc/clnt.c           | 12 ++++++++++--
 3 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7389cb1d7409..04c68d900324 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -710,22 +710,6 @@ static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc
 	}
 }
 
-static struct rpc_clnt *create_backchannel_client(struct rpc_create_args *args)
-{
-	struct rpc_xprt *xprt;
-
-	if (args->protocol != XPRT_TRANSPORT_BC_TCP)
-		return rpc_create(args);
-
-	xprt = args->bc_xprt->xpt_bc_xprt;
-	if (xprt) {
-		xprt_get(xprt);
-		return rpc_create_xprt(args, xprt);
-	}
-
-	return rpc_create(args);
-}
-
 static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn, struct nfsd4_session *ses)
 {
 	int maxtime = max_cb_time(clp->net);
@@ -768,7 +752,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		args.authflavor = ses->se_cb_sec.flavor;
 	}
 	/* Create RPC client */
-	client = create_backchannel_client(&args);
+	client = rpc_create(&args);
 	if (IS_ERR(client)) {
 		dprintk("NFSD: couldn't create callback client: %ld\n",
 			PTR_ERR(client));
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 9a7ddbaf116e..14d70f59f0c2 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -137,8 +137,6 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT	(1UL << 9)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
-struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
-					struct rpc_xprt *xprt);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
 				const struct rpc_program *, u32);
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a87e29ac993e..ad3f5ebec2d1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -446,7 +446,7 @@ out_no_rpciod:
 	return ERR_PTR(err);
 }
 
-struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
+static struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 					struct rpc_xprt *xprt)
 {
 	struct rpc_clnt *clnt = NULL;
@@ -484,7 +484,6 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 
 	return clnt;
 }
-EXPORT_SYMBOL_GPL(rpc_create_xprt);
 
 /**
  * rpc_create - create an RPC client and transport with one call
@@ -510,6 +509,15 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	};
 	char servername[48];
 
+	if (args->bc_xprt) {
+		WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
+		xprt = args->bc_xprt->xpt_bc_xprt;
+		if (xprt) {
+			xprt_get(xprt);
+			return rpc_create_xprt(args, xprt);
+		}
+	}
+
 	if (args->flags & RPC_CLNT_CREATE_INFINITE_SLOTS)
 		xprtargs.flags |= XPRT_CREATE_INFINITE_SLOTS;
 	if (args->flags & RPC_CLNT_CREATE_NO_IDLE_TIMEOUT)
-- 
2.5.5


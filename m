Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:40494 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaCXEAM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Mar 2014 00:00:12 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so4767646pde.15
        for <linux-nfs@vger.kernel.org>; Sun, 23 Mar 2014 21:00:12 -0700 (PDT)
Message-ID: <532FADB2.2070006@gmail.com>
Date: Mon, 24 Mar 2014 11:59:46 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/5][RESEND] NFSD/SUNRPC: Check rpc_xprt out of xs_setup_bc_tcp
References: <532FAC85.20909@gmail.com>
In-Reply-To: <532FAC85.20909@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Besides checking rpc_xprt out of xs_setup_bc_tcp,
increase it's reference (it's important).

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c      | 19 ++++++++++++++++++-
 include/linux/sunrpc/xprt.h | 13 ++++++++++++-
 net/sunrpc/xprt.c           | 12 ------------
 net/sunrpc/xprtsock.c       |  9 ---------
 4 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7f05cd1..39c8ef8 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/slab.h>
 #include "nfsd.h"
@@ -635,6 +636,22 @@ static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc
 	}
 }
 
+static struct rpc_clnt *create_backchannel_client(struct rpc_create_args *args)
+{
+	struct rpc_xprt *xprt;
+
+	if (args->protocol != XPRT_TRANSPORT_BC_TCP)
+		return rpc_create(args);
+
+	xprt = args->bc_xprt->xpt_bc_xprt;
+	if (xprt) {
+		xprt_get(xprt);
+		return rpc_create_xprt(args, xprt);
+	}
+
+	return rpc_create(args);
+}
+
 static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn, struct nfsd4_session *ses)
 {
 	struct rpc_timeout	timeparms = {
@@ -674,7 +691,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		args.authflavor = ses->se_cb_sec.flavor;
 	}
 	/* Create RPC client */
-	client = rpc_create(&args);
+	client = create_backchannel_client(&args);
 	if (IS_ERR(client)) {
 		dprintk("NFSD: couldn't create callback client: %ld\n",
 			PTR_ERR(client));
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8097b9d..3e5efb2 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -295,13 +295,24 @@ int			xprt_adjust_timeout(struct rpc_rqst *req);
 void			xprt_release_xprt(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_release_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_release(struct rpc_task *task);
-struct rpc_xprt *	xprt_get(struct rpc_xprt *xprt);
 void			xprt_put(struct rpc_xprt *xprt);
 struct rpc_xprt *	xprt_alloc(struct net *net, size_t size,
 				unsigned int num_prealloc,
 				unsigned int max_req);
 void			xprt_free(struct rpc_xprt *);
 
+/**
+ * xprt_get - return a reference to an RPC transport.
+ * @xprt: pointer to the transport
+ *
+ */
+static inline struct rpc_xprt *xprt_get(struct rpc_xprt *xprt)
+{
+	if (atomic_inc_not_zero(&xprt->count))
+		return xprt;
+	return NULL;
+}
+
 static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
 {
 	return p + xprt->tsh_size;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 7d4df99..d173f79 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1383,15 +1383,3 @@ void xprt_put(struct rpc_xprt *xprt)
 	if (atomic_dec_and_test(&xprt->count))
 		xprt_destroy(xprt);
 }
-
-/**
- * xprt_get - return a reference to an RPC transport.
- * @xprt: pointer to the transport
- *
- */
-struct rpc_xprt *xprt_get(struct rpc_xprt *xprt)
-{
-	if (atomic_inc_not_zero(&xprt->count))
-		return xprt;
-	return NULL;
-}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index da882af..252a56e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2927,15 +2927,6 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	struct svc_sock *bc_sock;
 	struct rpc_xprt *ret;
 
-	if (args->bc_xprt->xpt_bc_xprt) {
-		/*
-		 * This server connection already has a backchannel
-		 * transport; we can't create a new one, as we wouldn't
-		 * be able to match replies based on xid any more.  So,
-		 * reuse the already-existing one:
-		 */
-		 return args->bc_xprt->xpt_bc_xprt;
-	}
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries,
 			xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
-- 
1.8.5.3

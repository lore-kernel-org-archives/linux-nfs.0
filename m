Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33830 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbaAIKdQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 05:33:16 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so3029043pdj.33
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 02:33:16 -0800 (PST)
Message-ID: <52CE7AE6.4010603@gmail.com>
Date: Thu, 09 Jan 2014 18:33:10 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/5] NFSD/SUNRPC: Check rpc_xprt out of  xs_setup_bc_tcp
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org> <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com> <52CB8B79.6040907@gmail.com> <52CE7A76.3080101@gmail.com>
In-Reply-To: <52CE7A76.3080101@gmail.com>
Content-Type: text/plain; charset=windows-1252
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
index ddd198e..b0a1bbb 100644
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
index 7289e3c..37ea15a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2923,15 +2923,6 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
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
1.8.4.2

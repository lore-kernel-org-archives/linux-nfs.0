Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38898 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933001AbcBAPXN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 10:23:13 -0500
Received: by mail-ig0-f178.google.com with SMTP id mw1so35265837igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 07:23:13 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 03/13] SUNRPC: Uninline xprt_get(); It isn't performance critical.
Date: Mon,  1 Feb 2016 10:22:25 -0500
Message-Id: <1454340155-7670-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454340155-7670-3-git-send-email-trond.myklebust@primarydata.com>
References: <1454340155-7670-1-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-2-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also allow callers to pass NULL arguments to xprt_get() and xprt_put().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h | 16 +++-------------
 net/sunrpc/xprt.c           | 24 +++++++++++++++++++++---
 2 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 69ef5b3ab038..1bdb59a2efe8 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -13,6 +13,7 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 #include <linux/ktime.h>
+#include <linux/kref.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/msg_prot.h>
@@ -166,7 +167,7 @@ enum xprt_transports {
 };
 
 struct rpc_xprt {
-	atomic_t		count;		/* Reference count */
+	struct kref		kref;		/* Reference count */
 	struct rpc_xprt_ops *	ops;		/* transport methods */
 
 	const struct rpc_timeout *timeout;	/* timeout parms */
@@ -318,24 +319,13 @@ int			xprt_adjust_timeout(struct rpc_rqst *req);
 void			xprt_release_xprt(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_release_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_release(struct rpc_task *task);
+struct rpc_xprt *	xprt_get(struct rpc_xprt *xprt);
 void			xprt_put(struct rpc_xprt *xprt);
 struct rpc_xprt *	xprt_alloc(struct net *net, size_t size,
 				unsigned int num_prealloc,
 				unsigned int max_req);
 void			xprt_free(struct rpc_xprt *);
 
-/**
- * xprt_get - return a reference to an RPC transport.
- * @xprt: pointer to the transport
- *
- */
-static inline struct rpc_xprt *xprt_get(struct rpc_xprt *xprt)
-{
-	if (atomic_inc_not_zero(&xprt->count))
-		return xprt;
-	return NULL;
-}
-
 static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *p)
 {
 	return p + xprt->tsh_size;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 37edea6fa92d..d8fd84c0cbba 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1307,7 +1307,7 @@ void xprt_release(struct rpc_task *task)
 
 static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 {
-	atomic_set(&xprt->count, 1);
+	kref_init(&xprt->kref);
 
 	spin_lock_init(&xprt->transport_lock);
 	spin_lock_init(&xprt->reserve_lock);
@@ -1415,6 +1415,24 @@ static void xprt_destroy(struct rpc_xprt *xprt)
 	xprt->ops->destroy(xprt);
 }
 
+static void xprt_destroy_kref(struct kref *kref)
+{
+	xprt_destroy(container_of(kref, struct rpc_xprt, kref));
+}
+
+/**
+ * xprt_get - return a reference to an RPC transport.
+ * @xprt: pointer to the transport
+ *
+ */
+struct rpc_xprt *xprt_get(struct rpc_xprt *xprt)
+{
+	if (xprt != NULL && kref_get_unless_zero(&xprt->kref))
+		return xprt;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xprt_get);
+
 /**
  * xprt_put - release a reference to an RPC transport.
  * @xprt: pointer to the transport
@@ -1422,7 +1440,7 @@ static void xprt_destroy(struct rpc_xprt *xprt)
  */
 void xprt_put(struct rpc_xprt *xprt)
 {
-	if (atomic_dec_and_test(&xprt->count))
-		xprt_destroy(xprt);
+	if (xprt != NULL)
+		kref_put(&xprt->kref, xprt_destroy_kref);
 }
 EXPORT_SYMBOL_GPL(xprt_put);
-- 
2.5.0


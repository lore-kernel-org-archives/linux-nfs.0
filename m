Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56184 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932359Ab1AKQVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:43 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/14] rpc: keep backchannel xprt as long as server connection
Date: Tue, 11 Jan 2011 11:21:25 -0500
Message-Id: <1294762894-21371-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Multiple backchannels can share the same tcp connection; from rfc 5661 section
2.10.3.1:

	A connection's association with a session is not exclusive.  A
	connection associated with the channel(s) of one session may be
	simultaneously associated with the channel(s) of other sessions
	including sessions associated with other client IDs.

However, multiple backchannels share a connection, they must all share
the same xid stream (hence the same rpc_xprt); the only way we have to
match replies with calls at the rpc layer is using the xid.

So, keep the rpc_xprt around as long as the connection lasts, in case
we're asked to use the connection as a backchannel again.

Requests to create new backchannel clients over a given server
connection should results in creating new clients that reuse the
existing rpc_xprt.

But to start, just reject attempts to associate multiple rpc_xprt's with
the same underlying bc_xprt.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |    4 ++++
 net/sunrpc/xprt.c     |    2 +-
 net/sunrpc/xprtsock.c |   34 ++++++++++++++++++++++++----------
 3 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 173f3b9..ab86b79 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -13,6 +13,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/xprt.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -128,6 +129,9 @@ static void svc_xprt_free(struct kref *kref)
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
 	put_net(xprt->xpt_net);
+	/* See comment on corresponding get in xs_setup_bc_tcp(): */
+	if (xprt->xpt_bc_xprt)
+		xprt_put(xprt->xpt_bc_xprt);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 4c8f18a..749ad15 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -965,6 +965,7 @@ struct rpc_xprt *xprt_alloc(struct net *net, int size, int max_req)
 	xprt = kzalloc(size, GFP_KERNEL);
 	if (xprt == NULL)
 		goto out;
+	kref_init(&xprt->kref);
 
 	xprt->max_reqs = max_req;
 	xprt->slot = kcalloc(max_req, sizeof(struct rpc_rqst), GFP_KERNEL);
@@ -1102,7 +1103,6 @@ found:
 		return xprt;
 	}
 
-	kref_init(&xprt->kref);
 	spin_lock_init(&xprt->transport_lock);
 	spin_lock_init(&xprt->reserve_lock);
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 18dc42e..0ef4dd4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2375,16 +2375,6 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	xprt->reestablish_timeout = 0;
 	xprt->idle_timeout = 0;
 
-	/*
-	 * The backchannel uses the same socket connection as the
-	 * forechannel
-	 */
-	args->bc_xprt->xpt_bc_xprt = xprt;
-	xprt->bc_xprt = args->bc_xprt;
-	bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
-	transport->sock = bc_sock->sk_sock;
-	transport->inet = bc_sock->sk_sk;
-
 	xprt->ops = &bc_tcp_ops;
 
 	switch (addr->sa_family) {
@@ -2407,6 +2397,29 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 			xprt->address_strings[RPC_DISPLAY_PROTO]);
 
 	/*
+	 * The backchannel uses the same socket connection as the
+	 * forechannel
+	 */
+	if (args->bc_xprt->xpt_bc_xprt) {
+		/* XXX: actually, want to catch this case... */
+		ret = ERR_PTR(-EINVAL);
+		goto out_err;
+	}
+	/*
+	 * Once we've associated a backchannel xprt with a connection,
+	 * we want to keep it around as long as long as the connection
+	 * lasts, in case we need to start using it for a backchannel
+	 * again; this reference won't be dropped until bc_xprt is
+	 * destroyed.
+	 */
+	xprt_get(xprt);
+	args->bc_xprt->xpt_bc_xprt = xprt;
+	xprt->bc_xprt = args->bc_xprt;
+	bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
+	transport->sock = bc_sock->sk_sock;
+	transport->inet = bc_sock->sk_sk;
+
+	/*
 	 * Since we don't want connections for the backchannel, we set
 	 * the xprt status to connected
 	 */
@@ -2415,6 +2428,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
+	xprt_put(xprt);
 	ret = ERR_PTR(-EINVAL);
 out_err:
 	xprt_free(xprt);
-- 
1.7.1


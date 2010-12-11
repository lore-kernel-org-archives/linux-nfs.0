Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55931 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757234Ab0LKAUP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 19:20:15 -0500
Date: Fri, 10 Dec 2010 19:20:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: backchannel transport
Message-ID: <20101211002013.GF18141@fieldses.org>
References: <20101201175348.GF6832@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101201175348.GF6832@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 01, 2010 at 12:53:49PM -0500, bfields wrote:
> This is just a small question about the nfsd-side backchannel code that
> touches the rpc client code:
> 
> There's nothing preventing multiple backchannels from sharing the same
> tcp connection, either simultaneously or over time; from rfc 5661
> section 2.10.3.1:
> 
> 	A connection's association with a session is not exclusive.  A
> 	connection associated with the channel(s) of one session may be
> 	simultaneously associated with the channel(s) of other sessions
> 	including sessions associated with other client IDs.
> 
> The current code creates a new rpc_xprt every time an rpc client is
> created for a backchannel.
> 
> But that's wrong: if two sessions share a backchannel, then they don't
> necessarily want to share the same rpc_client, but they *do* need to
> share the same rpc_xprt, to prevent xid reuse at least.
> 
> So I think we should create one rpc_xprt the first time we use a
> connection for a backchannel, and then keep it around as long as the
> connection is open (in case the client reassociates it with a
> backchannel again).
> 
> rpc_clone_client() allows clients to share an rpc_xprt.  I could use
> that for example by keeping an nfsd-level data structure allowing me to
> look up rpc_client's by connection.
> 
> However, the server- and client- side xprt's already reference each
> other--the client's pointer to the server is used to send requests, and
> the server's pointer to the client is used to match incoming replies
> with requests.
> 
> So it would seem simplest to use the already existing pointer from the
> svc_xprt back to the rpc_xprt.
> 
> So, that would mean:
> 
> 	- Allowing nfsd to create a client with the already-existing
> 	  rpc_xprt--maybe export rpc_new_client()?  Or allow the
> 	  xprt->setup method to find an already-existing transport?
> 	- Keeping any backchannel rpc_xprt around somehow as long as the
> 	  connection is open.  Maybe let svc_xprt keep a reference on
> 	  the client xprt until svc_delete_xprt()??

So that would be something like the following.

?

--b.

commit 1eb4f46889940b861805742d67ba114e5de7ddf0
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Nov 30 19:15:01 2010 -0500

    rpc: move sk_bc_xprt to svc_xprt
    
    This seems obviously transport-level information even if it's currently
    used only by the server socket code.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index aea0d43..92ac407 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -80,6 +80,7 @@ struct svc_xprt {
 	struct list_head	xpt_users;	/* callbacks on free */
 
 	struct net		*xpt_net;
+	struct rpc_xprt		*xpt_bc_xprt;	/* NFSv4.1 backchannel */
 };
 
 static inline void unregister_xpt_user(struct svc_xprt *xpt, struct svc_xpt_user *u)
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 1b353a7..04dba23 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -28,7 +28,6 @@ struct svc_sock {
 	/* private TCP part */
 	u32			sk_reclen;	/* length of record */
 	u32			sk_tcplen;	/* current read length */
-	struct rpc_xprt		*sk_bc_xprt;	/* NFSv4.1 backchannel xprt */
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 07919e1..5a27d09 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -985,15 +985,17 @@ static int svc_process_calldir(struct svc_sock *svsk, struct svc_rqst *rqstp,
 		vec[0] = rqstp->rq_arg.head[0];
 	} else {
 		/* REPLY */
-		if (svsk->sk_bc_xprt)
-			req = xprt_lookup_rqst(svsk->sk_bc_xprt, xid);
+		struct rpc_xprt *bc_xprt = svsk->sk_xprt.xpt_bc_xprt;
+
+		if (bc_xprt)
+			req = xprt_lookup_rqst(bc_xprt, xid);
 
 		if (!req) {
 			printk(KERN_NOTICE
 				"%s: Got unrecognized reply: "
-				"calldir 0x%x sk_bc_xprt %p xid %08x\n",
+				"calldir 0x%x xpt_bc_xprt %p xid %08x\n",
 				__func__, ntohl(calldir),
-				svsk->sk_bc_xprt, xid);
+				bc_xprt, xid);
 			vec[0] = rqstp->rq_arg.head[0];
 			goto out;
 		}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dfcab5a..18dc42e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2379,9 +2379,9 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	 * The backchannel uses the same socket connection as the
 	 * forechannel
 	 */
+	args->bc_xprt->xpt_bc_xprt = xprt;
 	xprt->bc_xprt = args->bc_xprt;
 	bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
-	bc_sock->sk_bc_xprt = xprt;
 	transport->sock = bc_sock->sk_sock;
 	transport->inet = bc_sock->sk_sk;
 

commit 218a5c9b8fb3e9f33a3ef761dfaff2f9387686c4
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Dec 8 12:45:44 2010 -0500

    rpc: keep backchannel xprt as long as server connection
    
    Multiple backchannels can share the same tcp connection; from rfc 5661
    section 2.10.3.1:
    
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

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ea2ff78..597c79c 100644
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

commit ba7febf8e1ff482a6dc535e08e550053d9e34a74
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Dec 8 13:48:19 2010 -0500

    rpc: allow xprt_class->setup to return a preexisting xprt
    
    This allows us to reuse the xprt associated with a server connection if
    one has already been set up.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 89d10d2..bef0f53 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -321,6 +321,7 @@ void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 #define XPRT_CLOSING		(6)
 #define XPRT_CONNECTION_ABORT	(7)
 #define XPRT_CONNECTION_CLOSE	(8)
+#define XPRT_INITIALIZED	(9)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 749ad15..856274d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1102,6 +1102,9 @@ found:
 				-PTR_ERR(xprt));
 		return xprt;
 	}
+	if (test_and_set_bit(XPRT_INITIALIZED, &xprt->state))
+		/* ->setup returned a pre-initialized xprt: */
+		return xprt;
 
 	spin_lock_init(&xprt->transport_lock);
 	spin_lock_init(&xprt->reserve_lock);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0ef4dd4..4aced17 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2359,6 +2359,15 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	struct svc_sock *bc_sock;
 	struct rpc_xprt *ret;
 
+	if (args->bc_xprt->xpt_bc_xprt) {
+		/*
+		 * This server connection already has a backchannel
+		 * export; we can't create a new one, as we wouldn't be
+		 * able to match replies based on xid any more.  So,
+		 * reuse the already-existing one:
+		 */
+		 return args->bc_xprt->xpt_bc_xprt;
+	}
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;

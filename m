From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: nfsd41: change bc_sock to bc_xprt
Date: Sun, 28 Jun 2009 19:20:36 +0300
Message-ID: <1246206036-14021-1-git-send-email-bhalevy@panasas.com>
References: <4A3F7DB9.9030701@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:7152
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752916AbZF1QUj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jun 2009 12:20:39 -0400
In-Reply-To: <4A3F7DB9.9030701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c      |    6 ++----
 include/linux/sunrpc/clnt.h |    2 +-
 include/linux/sunrpc/xprt.h |    6 +++---
 net/sunrpc/clnt.c           |    2 +-
 net/sunrpc/xprt.c           |    2 +-
 net/sunrpc/xprtsock.c       |   18 ++++++++++--------
 6 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 9142ff9..6f1c046 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -505,10 +505,8 @@ int setup_callback_client(struct nfs4_client *clp)
 	addr.sin_family = AF_INET;
 	addr.sin_port = htons(cb->cb_port);
 	addr.sin_addr.s_addr = htonl(cb->cb_addr);
-	if (cb->cb_minorversion) {
-		args.bc_sock = container_of(clp->cl_cb_xprt, struct svc_sock,
-					    sk_xprt);
-	}
+	if (cb->cb_minorversion)
+		args.bc_xprt = clp->cl_cb_xprt;
 
 	dprintk("%s: program %s 0x%x nrvers %u version %u minorversion %u\n",
 		__func__, args.program->name, args.prognumber,
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 77d77f9..d904889 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -110,7 +110,7 @@ struct rpc_create_args {
 	rpc_authflavor_t	authflavor;
 	unsigned long		flags;
 	char			*client_name;
-	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
+	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 };
 
 /* Values for "flags" field */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index e17ef6f..75cb619 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -181,7 +181,7 @@ struct rpc_xprt {
 	spinlock_t		reserve_lock;	/* lock slot table */
 	u32			xid;		/* Next XID value to use */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
-	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
+	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 #if defined(CONFIG_NFS_V4_1)
 	struct svc_serv		*bc_serv;       /* The RPC service which will */
 						/* process the callback */
@@ -234,7 +234,7 @@ struct xprt_create {
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
-	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
+	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 };
 
 struct xprt_class {
@@ -372,7 +372,7 @@ static inline int xprt_test_and_set_binding(struct rpc_xprt *xprt)
 
 static inline int xprt_server_backchannel(struct rpc_xprt *xprt)
 {
-	return xprt->bc_sock != NULL;
+	return xprt->bc_xprt != NULL;
 }
 
 #endif /* __KERNEL__*/
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d5a85a9..51bf57a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -271,7 +271,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
-		.bc_sock = args->bc_sock,
+		.bc_xprt = args->bc_xprt,
 	};
 	char servername[48];
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 23c623b..b6d4d0d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1114,7 +1114,7 @@ found:
 	 * Since we don't want connections for the backchannel, we set
 	 * the xprt status to connected
 	 */
-	if (args->bc_sock)
+	if (args->bc_xprt)
 		xprt_set_connected(xprt);
 
 	return xprt;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 78ec5c8..4098a92 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2234,7 +2234,6 @@ static int bc_sendto(struct rpc_rqst *req)
 static int bc_send_request(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	struct rpc_xprt *bc_xprt = req->rq_xprt;
 	struct svc_xprt	*xprt;
 	struct svc_sock         *svsk;
 	u32                     len;
@@ -2243,8 +2242,8 @@ static int bc_send_request(struct rpc_task *task)
 	/*
 	 * Get the server socket associated with this callback xprt
 	 */
-	svsk = bc_xprt->bc_sock;
-	xprt = &svsk->sk_xprt;
+	xprt = req->rq_xprt->bc_xprt;
+	svsk = container_of(xprt, struct svc_sock, sk_xprt);
 
 	/*
 	 * Grab the mutex to serialize data as the connection is shared
@@ -2467,7 +2466,9 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 	xprt->timeout = &xs_tcp_default_timeout;
 
-	if (args->bc_sock) {
+	if (args->bc_xprt) {
+		struct svc_sock *bc_sock;
+
 		/* backchannel */
 		xprt_set_bound(xprt);
 		xprt->bind_timeout = 0;
@@ -2479,10 +2480,11 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 		 * The backchannel uses the same socket connection as the
 		 * forechannel
 		 */
-		xprt->bc_sock = args->bc_sock;
-		xprt->bc_sock->sk_bc_xprt = xprt;
-		transport->sock = xprt->bc_sock->sk_sock;
-		transport->inet = xprt->bc_sock->sk_sk;
+		xprt->bc_xprt = args->bc_xprt;
+		bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
+		bc_sock->sk_bc_xprt = xprt;
+		transport->sock = bc_sock->sk_sock;
+		transport->inet = bc_sock->sk_sk;
 
 		xprt->ops = &bc_tcp_ops;
 
-- 
1.6.3.3


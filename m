From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] SUNRPC: Pass full bind address to transports after
	GETPORT/GETADDR
Date: Wed, 15 Jul 2009 17:42:38 -0400
Message-ID: <20090715214238.7883.91886.stgit@matisse.1015granger.net>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:60993
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754642AbZGOVml (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:42:41 -0400
In-Reply-To: <20090715213842.7883.48947.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TI-RPC rpcbind operations provide not just a port number, but a full
socket address the client should connect to.  This allows rpcbind to
redirect RPC traffic to specific network interfaces or servers.  The
Linux kernel rpcbind client implementation currently ignores the
address.

Expand the ->set_port transport method so an address is passed to
transports during an RPC bind operation.  Additional changes to
individual client transports will be required to replace the peer
address after an rpcbind operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h     |    4 +++-
 net/sunrpc/rpcb_clnt.c          |   22 +++++++---------------
 net/sunrpc/xprtrdma/transport.c |   23 +++++++++++++++++++----
 net/sunrpc/xprtsock.c           |   35 +++++++++++++++++++++++++++--------
 4 files changed, 56 insertions(+), 28 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 65fad95..deb39d5 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -112,7 +112,9 @@ struct rpc_xprt_ops {
 	int		(*reserve_xprt)(struct rpc_task *task);
 	void		(*release_xprt)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void		(*rpcbind)(struct rpc_task *task);
-	void		(*set_port)(struct rpc_xprt *xprt, unsigned short port);
+	void		(*set_address)(struct rpc_xprt *xprt,
+					const struct sockaddr *sap,
+					const size_t salen);
 	void		(*connect)(struct rpc_task *task);
 	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
 	void		(*buf_free)(void *buffer);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 4cc2c58..68046df 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -681,7 +681,6 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 	struct sockaddr *sap = (struct sockaddr *)&map->r_raddr;
 	struct rpc_xprt *xprt = map->r_xprt;
 	int status = child->tk_status;
-	unsigned short port = 0;
 
 	/* Garbage reply: retry with a lesser rpcbind version */
 	if (status == -EIO)
@@ -693,31 +692,24 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 
 	if (status < 0) {
 		/* rpcbind server not available on remote host? */
-		xprt->ops->set_port(xprt, 0);
+		xprt->ops->set_address(xprt, &rpcb_inaddr_unspec,
+					sizeof(rpcb_inaddr_unspec));
 		xprt_clear_bound(xprt);
 	} else if (sap->sa_family == AF_UNSPEC) {
 		/* Requested RPC service wasn't registered on remote host */
-		xprt->ops->set_port(xprt, 0);
+		xprt->ops->set_address(xprt, &rpcb_inaddr_unspec,
+					sizeof(rpcb_inaddr_unspec));
 		xprt_clear_bound(xprt);
 		status = -EACCES;
 	} else {
 		/* Succeeded */
-		switch (sap->sa_family) {
-		case AF_INET:
-			port = ntohs(((struct sockaddr_in *)sap)->sin_port);
-			break;
-		case AF_INET6:
-			port = ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
-			break;
-		}
-
-		xprt->ops->set_port(xprt, port);
+		xprt->ops->set_address(xprt, sap, map->r_raddrlen);
 		xprt_set_bound(xprt);
 		status = 0;
 	}
 
-	dprintk("RPC: %5u rpcb_getport_done(status %d, port %u)\n",
-			child->tk_pid, status, port);
+	dprintk("RPC: %5u rpcb_getport_done(status %d)\n",
+			child->tk_pid, status);
 
 	map->r_status = status;
 }
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 5f9b867..780385f 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -453,14 +453,29 @@ xprt_rdma_close(struct rpc_xprt *xprt)
 }
 
 static void
-xprt_rdma_set_port(struct rpc_xprt *xprt, u16 port)
+xprt_rdma_set_address(struct rpc_xprt *xprt, const struct sockaddr *bindaddr,
+			const size_t bindaddr_len)
 {
 	struct sockaddr_in *sap;
+	__be16 port;
+
+	switch (bindaddr->sa_family) {
+	case AF_UNSPEC:
+		port = 0;
+		break;
+	case AF_INET:
+		port = ((struct sockaddr_in *)bindaddr)->sin_port;
+		break;
+	default:
+		dprintk("RPC:       %s: address family not supported\n",
+				__func__);
+		return;
+	}
 
 	sap = (struct sockaddr_in *)&xprt->addr;
-	sap->sin_port = htons(port);
+	sap->sin_port = port;
 	sap = (struct sockaddr_in *)&rpcx_to_rdmad(xprt).addr;
-	sap->sin_port = htons(port);
+	sap->sin_port = port;
 	dprintk("RPC:       %s: %u\n", __func__, port);
 }
 
@@ -752,7 +767,7 @@ static struct rpc_xprt_ops xprt_rdma_procs = {
 	.release_request	= xprt_release_rqst_cong,       /* ditto */
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def, /* ditto */
 	.rpcbind		= rpcb_getport_async,	/* sunrpc/rpcb_clnt.c */
-	.set_port		= xprt_rdma_set_port,
+	.set_address		= xprt_rdma_set_address,
 	.connect		= xprt_rdma_connect,
 	.buf_alloc		= xprt_rdma_allocate,
 	.buf_free		= xprt_rdma_free,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 302a409..000ddd9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1521,23 +1521,42 @@ static unsigned short xs_get_random_port(void)
 }
 
 /**
- * xs_set_port - reset the port number in the remote endpoint address
+ * xs_set_address - reset the port number in the remote endpoint address
  * @xprt: generic transport
- * @port: new port number
+ * @bindaddr: socket address to connect to
+ * @bindaddr_len: length of socket address
  *
  */
-static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
+static void xs_set_address(struct rpc_xprt *xprt,
+			   const struct sockaddr *bindaddr,
+			   const size_t bindaddr_len)
 {
 	struct sockaddr *addr = xs_addr(xprt);
+	__be16 port;
 
-	dprintk("RPC:       setting port for xprt %p to %u\n", xprt, port);
+	switch (bindaddr->sa_family) {
+	case AF_UNSPEC:
+		port = 0;
+		break;
+	case AF_INET:
+		port = ((struct sockaddr_in *)bindaddr)->sin_port;
+		break;
+	case AF_INET6:
+		port = ((struct sockaddr_in6 *)bindaddr)->sin6_port;
+		break;
+	default:
+		BUG();
+	}
+
+	dprintk("RPC:       setting port for xprt %p to %u\n",
+			xprt, ntohs(port));
 
 	switch (addr->sa_family) {
 	case AF_INET:
-		((struct sockaddr_in *)addr)->sin_port = htons(port);
+		((struct sockaddr_in *)addr)->sin_port = port;
 		break;
 	case AF_INET6:
-		((struct sockaddr_in6 *)addr)->sin6_port = htons(port);
+		((struct sockaddr_in6 *)addr)->sin6_port = port;
 		break;
 	default:
 		BUG();
@@ -2102,7 +2121,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
 	.rpcbind		= rpcb_getport_async,
-	.set_port		= xs_set_port,
+	.set_address		= xs_set_address,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
@@ -2119,7 +2138,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.rpcbind		= rpcb_getport_async,
-	.set_port		= xs_set_port,
+	.set_address		= xs_set_address,
 	.connect		= xs_tcp_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,


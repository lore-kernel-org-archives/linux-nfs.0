From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] SUNRPC: Use address returned by rpcbind when connecting
Date: Wed, 15 Jul 2009 17:42:53 -0400
Message-ID: <20090715214253.7883.7760.stgit@matisse.1015granger.net>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:60999
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753360AbZGOVmz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:42:55 -0400
In-Reply-To: <20090715213842.7883.48947.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcbind provides an RPC service address and port number.  Currently
the transport capabilities defined in net/sunrpc/xprtsock.c use only
the port number.  Teach them to use the returned address as well.

After a bind completes, update the transport instance's address
strings so debugging messages display the current port and address
it's connected to.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |  148 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 98 insertions(+), 50 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4804d88..df3d4af 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -250,6 +250,8 @@ struct sock_xprt {
 	struct delayed_work	connect_worker;
 	struct sockaddr_storage	srcaddr;
 	unsigned short		srcport;
+	struct sockaddr_storage rpcbindaddr;
+	size_t			rpcbindaddr_len;
 
 	/*
 	 * UDP socket buffer size parameters
@@ -296,9 +298,39 @@ static inline struct sockaddr_in6 *xs_addr_in6(struct rpc_xprt *xprt)
 	return (struct sockaddr_in6 *) &xprt->addr;
 }
 
+static inline struct sockaddr *xs_rpcbindaddr(struct sock_xprt *trans)
+{
+	return (struct sockaddr *)&trans->rpcbindaddr;
+}
+
+static inline struct sockaddr_in *xs_rpcbindaddr_in(struct sock_xprt *trans)
+{
+	return (struct sockaddr_in *)&trans->rpcbindaddr;
+}
+
+static inline struct sockaddr_in6 *xs_rpcbindaddr_in6(struct sock_xprt *trans)
+{
+	return (struct sockaddr_in6 *)&trans->rpcbindaddr;
+}
+
+static void xs_free_peer_addresses(struct rpc_xprt *xprt)
+{
+	unsigned int i;
+
+	for (i = 0; i < RPC_DISPLAY_MAX; i++)
+		switch (i) {
+		case RPC_DISPLAY_PROTO:
+		case RPC_DISPLAY_NETID:
+			continue;
+		default:
+			kfree(xprt->address_strings[i]);
+		}
+}
+
 static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 {
-	struct sockaddr *sap = xs_addr(xprt);
+	struct sock_xprt *trans = container_of(xprt, struct sock_xprt, xprt);
+	struct sockaddr *sap = xs_rpcbindaddr(trans);
 	char buf[128];
 
 	(void)rpc_ntop(sap, buf, sizeof(buf));
@@ -321,7 +353,8 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
 					  const char *protocol,
 					  const char *netid)
 {
-	struct sockaddr_in *sin = xs_addr_in(xprt);
+	struct sock_xprt *trans = container_of(xprt, struct sock_xprt, xprt);
+	struct sockaddr_in *sin = xs_rpcbindaddr_in(trans);
 	char buf[16];
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
@@ -334,11 +367,27 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
 	xs_format_common_peer_addresses(xprt);
 }
 
+static void xs_update_ipv4_peer_addresses(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *trans = container_of(xprt, struct sock_xprt, xprt);
+	struct sockaddr_in *sin = xs_rpcbindaddr_in(trans);
+	char buf[16];
+
+	xs_free_peer_addresses(xprt);
+
+	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
+				NIPQUAD(sin->sin_addr.s_addr));
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
+
+	xs_format_common_peer_addresses(xprt);
+}
+
 static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 					  const char *protocol,
 					  const char *netid)
 {
-	struct sockaddr_in6 *sin6 = xs_addr_in6(xprt);
+	struct sock_xprt *trans = container_of(xprt, struct sock_xprt, xprt);
+	struct sockaddr_in6 *sin6 = xs_rpcbindaddr_in6(trans);
 	char buf[48];
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
@@ -350,18 +399,18 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 	xs_format_common_peer_addresses(xprt);
 }
 
-static void xs_free_peer_addresses(struct rpc_xprt *xprt)
+static void xs_update_ipv6_peer_addresses(struct rpc_xprt *xprt)
 {
-	unsigned int i;
+	struct sock_xprt *trans = container_of(xprt, struct sock_xprt, xprt);
+	struct sockaddr_in6 *sin6 = xs_rpcbindaddr_in6(trans);
+	char buf[48];
 
-	for (i = 0; i < RPC_DISPLAY_MAX; i++)
-		switch (i) {
-		case RPC_DISPLAY_PROTO:
-		case RPC_DISPLAY_NETID:
-			continue;
-		default:
-			kfree(xprt->address_strings[i]);
-		}
+	xs_free_peer_addresses(xprt);
+
+	(void)snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
+
+	xs_format_common_peer_addresses(xprt);
 }
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
@@ -545,9 +594,9 @@ static int xs_udp_send_request(struct rpc_task *task)
 	if (!xprt_bound(xprt))
 		return -ENOTCONN;
 	status = xs_sendpages(transport->sock,
-			      xs_addr(xprt),
-			      xprt->addrlen, xdr,
-			      req->rq_bytes_sent);
+			      xs_rpcbindaddr(transport),
+			      transport->rpcbindaddr_len,
+			      xdr, req->rq_bytes_sent);
 
 	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
 			xdr->len - req->rq_bytes_sent, status);
@@ -1531,36 +1580,28 @@ static void xs_set_address(struct rpc_xprt *xprt,
 			   const struct sockaddr *bindaddr,
 			   const size_t bindaddr_len)
 {
-	struct sockaddr *addr = xs_addr(xprt);
-	__be16 port;
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
+							xprt);
+
+	memcpy(&transport->rpcbindaddr, bindaddr, bindaddr_len);
+	transport->rpcbindaddr_len = bindaddr_len;
 
 	switch (bindaddr->sa_family) {
 	case AF_UNSPEC:
-		port = 0;
-		break;
+		dprintk("RPC:       xprt %p not bound\n", xprt);
+		return;
 	case AF_INET:
-		port = ((struct sockaddr_in *)bindaddr)->sin_port;
+		xs_update_ipv4_peer_addresses(xprt);
 		break;
 	case AF_INET6:
-		port = ((struct sockaddr_in6 *)bindaddr)->sin6_port;
+		xs_update_ipv6_peer_addresses(xprt);
 		break;
 	default:
 		BUG();
 	}
 
-	dprintk("RPC:       setting port for xprt %p to %u\n",
-			xprt, ntohs(port));
-
-	switch (addr->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)addr)->sin_port = port;
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)addr)->sin6_port = port;
-		break;
-	default:
-		BUG();
-	}
+	dprintk("RPC:       xprt %p bound to %s\n",
+			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 }
 
 static unsigned short xs_get_srcport(struct sock_xprt *transport, struct socket *sock)
@@ -1867,7 +1908,8 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
-	return kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
+	return kernel_connect(sock, xs_rpcbindaddr(transport),
+				transport->rpcbindaddr_len, O_NONBLOCK);
 }
 
 /**
@@ -2227,29 +2269,32 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 	switch (addr->sa_family) {
 	case AF_INET:
-		if (((struct sockaddr_in *)addr)->sin_port != htons(0))
+		xs_format_ipv4_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP);
+		if (((struct sockaddr_in *)addr)->sin_port != htons(0)) {
+			xs_set_address(xprt, addr,
+					sizeof(struct sockaddr_in));
 			xprt_set_bound(xprt);
+		}
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_udp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP);
 		break;
 	case AF_INET6:
-		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
+		xs_format_ipv6_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
+		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0)) {
+			xs_set_address(xprt, addr,
+					sizeof(struct sockaddr_in6));
 			xprt_set_bound(xprt);
+		}
 
 		INIT_DELAYED_WORK(&transport->connect_worker,
 					xs_udp_connect_worker6);
-		xs_format_ipv6_peer_addresses(xprt, "udp", RPCBIND_NETID_UDP6);
 		break;
 	default:
 		kfree(xprt);
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
-	dprintk("RPC:       set up transport to address %s\n",
-			xprt->address_strings[RPC_DISPLAY_ALL]);
-
 	if (try_module_get(THIS_MODULE))
 		return xprt;
 
@@ -2294,27 +2339,30 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 
 	switch (addr->sa_family) {
 	case AF_INET:
-		if (((struct sockaddr_in *)addr)->sin_port != htons(0))
+		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
+		if (((struct sockaddr_in *)addr)->sin_port != htons(0)) {
+			xs_set_address(xprt, addr,
+					sizeof(struct sockaddr_in));
 			xprt_set_bound(xprt);
+		}
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
 		break;
 	case AF_INET6:
-		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
+		xs_format_ipv6_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
+		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0)) {
+			xs_set_address(xprt, addr,
+					sizeof(struct sockaddr_in6));
 			xprt_set_bound(xprt);
+		}
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
-		xs_format_ipv6_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
 		break;
 	default:
 		kfree(xprt);
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
-	dprintk("RPC:       set up transport to address %s\n",
-			xprt->address_strings[RPC_DISPLAY_ALL]);
-
 	if (try_module_get(THIS_MODULE))
 		return xprt;
 


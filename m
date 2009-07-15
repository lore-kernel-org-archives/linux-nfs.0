From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] SUNRPC: Remove duplicate universal address generation
Date: Wed, 15 Jul 2009 17:37:16 -0400
Message-ID: <20090715213716.7582.87628.stgit@matisse.1015granger.net>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38861
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752649AbZGOVhT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:37:19 -0400
In-Reply-To: <20090715212628.7582.98251.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC universal address generation is currently done in several places:
rpcb_clnt.c, nfs4proc.c xprtsock.c, and xprtrdma.c.  Remove the
redundant cases that convert a socket address to a universal
address.  The nfs4proc.c case takes a pre-formatted presentation
address string, not a socket address, so we'll leave that one.

Because the new uaddr constructor uses the recently introduced
rpc_ntop(), it now supports proper "::" shorthanding for IPv6
addresses.  This allows the kernel to register properly formed
universal addresses with the local rpcbind service, in _all_ cases.

The kernel can now also send properly formed universal addresses in
RPCB_GETADDR requests, and support link-local properly when
encoding and decoding IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h     |    1 -
 net/sunrpc/rpcb_clnt.c          |   48 ++++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/transport.c |    8 -------
 net/sunrpc/xprtsock.c           |   18 ---------------
 4 files changed, 29 insertions(+), 46 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1175d58..65fad95 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -41,7 +41,6 @@ enum rpc_display_format_t {
 	RPC_DISPLAY_ALL,
 	RPC_DISPLAY_HEX_ADDR,
 	RPC_DISPLAY_HEX_PORT,
-	RPC_DISPLAY_UNIVERSAL_ADDR,
 	RPC_DISPLAY_NETID,
 	RPC_DISPLAY_MAX,
 };
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index ad1d731..1fb1c07 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -153,6 +153,7 @@ static void rpcb_map_release(void *data)
 
 	rpcb_wake_rpcbind_waiters(map->r_xprt, map->r_status);
 	xprt_put(map->r_xprt);
+	kfree(map->r_addr);
 	kfree(map);
 }
 
@@ -299,12 +300,9 @@ static int rpcb_register_inet4(const struct sockaddr *sap,
 	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
 	struct rpcbind_args *map = msg->rpc_argp;
 	unsigned short port = ntohs(sin->sin_port);
-	char buf[32];
+	int result;
 
-	/* Construct AF_INET universal address */
-	snprintf(buf, sizeof(buf), "%pI4.%u.%u",
-		 &sin->sin_addr.s_addr, port >> 8, port & 0xff);
-	map->r_addr = buf;
+	map->r_addr = rpc_sockaddr2uaddr(sap);
 
 	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
 		"local rpcbind\n", (port ? "" : "un"),
@@ -315,7 +313,9 @@ static int rpcb_register_inet4(const struct sockaddr *sap,
 	if (port)
 		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
 
-	return rpcb_register_call(RPCBVERS_4, msg);
+	result = rpcb_register_call(RPCBVERS_4, msg);
+	kfree(map->r_addr);
+	return result;
 }
 
 /*
@@ -327,16 +327,9 @@ static int rpcb_register_inet6(const struct sockaddr *sap,
 	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
 	struct rpcbind_args *map = msg->rpc_argp;
 	unsigned short port = ntohs(sin6->sin6_port);
-	char buf[64];
+	int result;
 
-	/* Construct AF_INET6 universal address */
-	if (ipv6_addr_any(&sin6->sin6_addr))
-		snprintf(buf, sizeof(buf), "::.%u.%u",
-				port >> 8, port & 0xff);
-	else
-		snprintf(buf, sizeof(buf), "%pI6.%u.%u",
-			 &sin6->sin6_addr, port >> 8, port & 0xff);
-	map->r_addr = buf;
+	map->r_addr = rpc_sockaddr2uaddr(sap);
 
 	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
 		"local rpcbind\n", (port ? "" : "un"),
@@ -347,7 +340,9 @@ static int rpcb_register_inet6(const struct sockaddr *sap,
 	if (port)
 		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
 
-	return rpcb_register_call(RPCBVERS_4, msg);
+	result = rpcb_register_call(RPCBVERS_4, msg);
+	kfree(map->r_addr);
+	return result;
 }
 
 static int rpcb_unregister_all_protofamilies(struct rpc_message *msg)
@@ -570,6 +565,7 @@ void rpcb_getport_async(struct rpc_task *task)
 		goto bailout_nofree;
 	}
 
+	/* Parent transport's destination address */
 	salen = rpc_peeraddr(clnt, sap, sizeof(addr));
 
 	/* Don't ever use rpcbind v2 for AF_INET6 requests */
@@ -620,11 +616,22 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_prot = xprt->prot;
 	map->r_port = 0;
 	map->r_xprt = xprt_get(xprt);
-	map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
-	map->r_addr = rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR);
-	map->r_owner = "";
 	map->r_status = -EIO;
 
+	switch (bind_version) {
+	case RPCBVERS_4:
+	case RPCBVERS_3:
+		map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
+		map->r_addr = rpc_sockaddr2uaddr(sap);
+		map->r_owner = "";
+		break;
+	case RPCBVERS_2:
+		map->r_addr = NULL;
+		break;
+	default:
+		BUG();
+	}
+
 	child = rpcb_call_async(rpcb_clnt, map, proc);
 	rpc_release_client(rpcb_clnt);
 	if (IS_ERR(child)) {
@@ -722,6 +729,9 @@ static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
 static int rpcb_encode_getaddr(struct rpc_rqst *req, __be32 *p,
 			       struct rpcbind_args *rpcb)
 {
+	if (rpcb->r_addr == NULL)
+		return -EIO;
+
 	dprintk("RPC:       encoding rpcb request (%u, %u, %s)\n",
 			rpcb->r_prog, rpcb->r_vers, rpcb->r_addr);
 	*p++ = htonl(rpcb->r_prog);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 1dd6123..537c210 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -202,14 +202,6 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 		snprintf(buf, 8, "%4hx", ntohs(addr->sin_port));
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
 
-	buf = kzalloc(30, GFP_KERNEL);
-	if (buf)
-		snprintf(buf, 30, "%pI4.%u.%u",
-			&addr->sin_addr.s_addr,
-			ntohs(addr->sin_port) >> 8,
-			ntohs(addr->sin_port) & 0xff);
-	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
-
 	/* netid */
 	xprt->address_strings[RPC_DISPLAY_NETID] = "rdma";
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 83c73c4..a42c2ad 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -341,15 +341,6 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
 	}
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
 
-	buf = kzalloc(30, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 30, "%pI4.%u.%u",
-				&addr->sin_addr.s_addr,
-				ntohs(addr->sin_port) >> 8,
-				ntohs(addr->sin_port) & 0xff);
-	}
-	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
-
 	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
 }
 
@@ -397,15 +388,6 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 	}
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = buf;
 
-	buf = kzalloc(50, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 50, "%pI6.%u.%u",
-			 &addr->sin6_addr,
-			 ntohs(addr->sin6_port) >> 8,
-			 ntohs(addr->sin6_port) & 0xff);
-	}
-	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
-
 	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
 }
 


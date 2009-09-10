From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 03/12] nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel
Date: Thu, 10 Sep 2009 12:25:32 +0300
Message-ID: <1252574732-30108-1-git-send-email-bhalevy@panasas.com>
References: <4AA8C597.8080809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Alexandros Batsakis <batsakis@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:51473 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755298AbZIJJZE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 05:25:04 -0400
In-Reply-To: <4AA8C597.8080809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Alexandros Batsakis <batsakis@netapp.com>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/clnt.h     |    1 +
 include/linux/sunrpc/xprt.h     |    1 +
 include/linux/sunrpc/xprtrdma.h |    5 --
 include/linux/sunrpc/xprtsock.h |    9 +++-
 net/sunrpc/clnt.c               |    1 +
 net/sunrpc/xprtsock.c           |   96 ++++++++++++++++++++++++++++++++++++++-
 6 files changed, 104 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 3d02558..8ed9642 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -114,6 +114,7 @@ struct rpc_create_args {
 	rpc_authflavor_t	authflavor;
 	unsigned long		flags;
 	char			*client_name;
+	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 };
 
 /* Values for "flags" field */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 228d694..7cc42af 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -232,6 +232,7 @@ struct xprt_create {
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
+	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 };
 
 struct xprt_class {
diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 54a379c..c2f04e1 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -41,11 +41,6 @@
 #define _LINUX_SUNRPC_XPRTRDMA_H
 
 /*
- * RPC transport identifier for RDMA
- */
-#define XPRT_TRANSPORT_RDMA	256
-
-/*
  * rpcbind (v3+) RDMA netid.
  */
 #define RPCBIND_NETID_RDMA	"rdma"
diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index c2a46c4..d7c98d1 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -20,8 +20,13 @@ void		cleanup_socket_xprt(void);
  * values. No such restriction exists for new transports, except that
  * they may not collide with these values (17 and 6, respectively).
  */
-#define XPRT_TRANSPORT_UDP	IPPROTO_UDP
-#define XPRT_TRANSPORT_TCP	IPPROTO_TCP
+#define XPRT_TRANSPORT_BC	(1 << 31)
+enum xprt_transports {
+	XPRT_TRANSPORT_UDP 	= IPPROTO_UDP,
+	XPRT_TRANSPORT_TCP 	= IPPROTO_TCP,
+	XPRT_TRANSPORT_BC_TCP 	= IPPROTO_TCP | XPRT_TRANSPORT_BC,
+	XPRT_TRANSPORT_RDMA	= 256
+};
 
 /*
  * RPC slot table sizes for UDP, TCP transports
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c1e467e..7389804 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -288,6 +288,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
+		.bc_xprt = args->bc_xprt,
 	};
 	char servername[48];
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d9a2b81..6edcd5c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2468,11 +2468,93 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	return ERR_PTR(-EINVAL);
 }
 
+/**
+ * xs_setup_bc_tcp - Set up transport to use a TCP backchannel socket
+ * @args: rpc transport creation arguments
+ *
+ */
+static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
+{
+	struct sockaddr *addr = args->dstaddr;
+	struct rpc_xprt *xprt;
+	struct sock_xprt *transport;
+	struct svc_sock *bc_sock;
+
+	if (!args->bc_xprt)
+		ERR_PTR(-EINVAL);
+
+	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
+	if (IS_ERR(xprt))
+		return xprt;
+	transport = container_of(xprt, struct sock_xprt, xprt);
+
+	xprt->prot = IPPROTO_TCP;
+	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
+	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
+	xprt->timeout = &xs_tcp_default_timeout;
+
+	/* backchannel */
+	xprt_set_bound(xprt);
+	xprt->bind_timeout = 0;
+	xprt->connect_timeout = 0;
+	xprt->reestablish_timeout = 0;
+	xprt->idle_timeout = (~0);
+
+	/*
+	 * The backchannel uses the same socket connection as the
+	 * forechannel
+	 */
+	xprt->bc_xprt = args->bc_xprt;
+	bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
+	bc_sock->sk_bc_xprt = xprt;
+	transport->sock = bc_sock->sk_sock;
+	transport->inet = bc_sock->sk_sk;
+
+	xprt->ops = &bc_tcp_ops;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		xs_format_peer_addresses(xprt, "tcp",
+					 RPCBIND_NETID_TCP);
+		break;
+	case AF_INET6:
+		xs_format_peer_addresses(xprt, "tcp",
+				   RPCBIND_NETID_TCP6);
+		break;
+	default:
+		kfree(xprt);
+		return ERR_PTR(-EAFNOSUPPORT);
+	}
+
+	if (xprt_bound(xprt))
+		dprintk("RPC:       set up xprt to %s (port %s) via %s\n",
+				xprt->address_strings[RPC_DISPLAY_ADDR],
+				xprt->address_strings[RPC_DISPLAY_PORT],
+				xprt->address_strings[RPC_DISPLAY_PROTO]);
+	else
+		dprintk("RPC:       set up xprt to %s (autobind) via %s\n",
+				xprt->address_strings[RPC_DISPLAY_ADDR],
+				xprt->address_strings[RPC_DISPLAY_PROTO]);
+
+	/*
+	 * Since we don't want connections for the backchannel, we set
+	 * the xprt status to connected
+	 */
+	xprt_set_connected(xprt);
+
+
+	if (try_module_get(THIS_MODULE))
+		return xprt;
+	kfree(xprt->slot);
+	kfree(xprt);
+	return ERR_PTR(-EINVAL);
+}
+
 static struct xprt_class	xs_udp_transport = {
 	.list		= LIST_HEAD_INIT(xs_udp_transport.list),
 	.name		= "udp",
 	.owner		= THIS_MODULE,
-	.ident		= IPPROTO_UDP,
+	.ident		= XPRT_TRANSPORT_UDP,
 	.setup		= xs_setup_udp,
 };
 
@@ -2480,10 +2562,18 @@ static struct xprt_class	xs_tcp_transport = {
 	.list		= LIST_HEAD_INIT(xs_tcp_transport.list),
 	.name		= "tcp",
 	.owner		= THIS_MODULE,
-	.ident		= IPPROTO_TCP,
+	.ident		= XPRT_TRANSPORT_TCP,
 	.setup		= xs_setup_tcp,
 };
 
+static struct xprt_class	xs_bc_tcp_transport = {
+	.list		= LIST_HEAD_INIT(xs_bc_tcp_transport.list),
+	.name		= "tcp NFSv4.1 backchannel",
+	.owner		= THIS_MODULE,
+	.ident		= XPRT_TRANSPORT_BC_TCP,
+	.setup		= xs_setup_bc_tcp,
+};
+
 /**
  * init_socket_xprt - set up xprtsock's sysctls, register with RPC client
  *
@@ -2497,6 +2587,7 @@ int init_socket_xprt(void)
 
 	xprt_register_transport(&xs_udp_transport);
 	xprt_register_transport(&xs_tcp_transport);
+	xprt_register_transport(&xs_bc_tcp_transport);
 
 	return 0;
 }
@@ -2516,6 +2607,7 @@ void cleanup_socket_xprt(void)
 
 	xprt_unregister_transport(&xs_udp_transport);
 	xprt_unregister_transport(&xs_tcp_transport);
+	xprt_unregister_transport(&xs_bc_tcp_transport);
 }
 
 static int param_set_uint_minmax(const char *val, struct kernel_param *kp,
-- 
1.6.4


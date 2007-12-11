From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 02/38] svc: Make svc_sock the tcp/udp transport
Date: Tue, 11 Dec 2007 17:31:56 -0600
Message-ID: <20071211233156.15718.7813.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35346 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753653AbXLKXb5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:31:57 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Make TCP and UDP svc_sock transports, and register them
with the svc transport core. 

A transport type (svc_sock) has an svc_xprt as its first member, 
and calls svc_xprt_init to initialize this field.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/debug.h   |    1 -
 include/linux/sunrpc/svcsock.h |    4 ++++
 net/sunrpc/sunrpc_syms.c       |    4 +++-
 net/sunrpc/svcsock.c           |   33 ++++++++++++++++++++++++++++++++-
 4 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 092fcfa..10709cb 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -20,7 +20,6 @@
 #define RPCDBG_BIND		0x0020
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
-#define RPCDBG_SVCSOCK		0x0100
 #define RPCDBG_SVCXPRT		0x0100
 #define RPCDBG_SVCDSP		0x0200
 #define RPCDBG_MISC		0x0400
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index a53e0fa..1878cbe 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -10,11 +10,13 @@
 #define SUNRPC_SVCSOCK_H
 
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/svc_xprt.h>
 
 /*
  * RPC server socket.
  */
 struct svc_sock {
+	struct svc_xprt		sk_xprt;
 	struct list_head	sk_ready;	/* list of ready sockets */
 	struct list_head	sk_list;	/* list of all sockets */
 	struct socket *		sk_sock;	/* berkeley socket layer */
@@ -78,6 +80,8 @@ int		svc_addsock(struct svc_serv *serv,
 			    int fd,
 			    char *name_return,
 			    int *proto);
+void		svc_init_xprt_sock(void);
+void		svc_cleanup_xprt_sock(void);
 
 /*
  * svc_makesock socket characteristics
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 33d89e8..79ea05f 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -151,7 +151,8 @@ init_sunrpc(void)
 #endif
 	cache_register(&ip_map_cache);
 	cache_register(&unix_gid_cache);
-	init_socket_xprt();
+	svc_init_xprt_sock();	/* svc sock transport */
+	init_socket_xprt();	/* clnt sock transport */
 	rpcauth_init_module();
 out:
 	return err;
@@ -162,6 +163,7 @@ cleanup_sunrpc(void)
 {
 	rpcauth_remove_module();
 	cleanup_socket_xprt();
+	svc_cleanup_xprt_sock();
 	unregister_rpc_pipefs();
 	rpc_destroy_mempool();
 	if (cache_unregister(&ip_map_cache))
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c75bffe..4755467 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -75,7 +75,7 @@
  *
  */
 
-#define RPCDBG_FACILITY	RPCDBG_SVCSOCK
+#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
@@ -900,12 +900,21 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
+static struct svc_xprt_ops svc_udp_ops = {
+};
+
+static struct svc_xprt_class svc_udp_class = {
+	.xcl_name = "udp",
+	.xcl_ops = &svc_udp_ops,
+};
+
 static void
 svc_udp_init(struct svc_sock *svsk)
 {
 	int one = 1;
 	mm_segment_t oldfs;
 
+	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt);
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
 	svsk->sk_recvfrom = svc_udp_recvfrom;
@@ -1344,12 +1353,33 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
+static struct svc_xprt_ops svc_tcp_ops = {
+};
+
+static struct svc_xprt_class svc_tcp_class = {
+	.xcl_name = "tcp",
+	.xcl_ops = &svc_tcp_ops,
+};
+
+void svc_init_xprt_sock(void)
+{
+	svc_reg_xprt_class(&svc_tcp_class);
+	svc_reg_xprt_class(&svc_udp_class);
+}
+
+void svc_cleanup_xprt_sock(void)
+{
+	svc_unreg_xprt_class(&svc_tcp_class);
+	svc_unreg_xprt_class(&svc_udp_class);
+}
+
 static void
 svc_tcp_init(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt);
 	svsk->sk_recvfrom = svc_tcp_recvfrom;
 	svsk->sk_sendto = svc_tcp_sendto;
 
@@ -1965,3 +1995,4 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
 	spin_unlock(&svsk->sk_lock);
 	return dr;
 }
+

From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 048/100] svc: Make svc_sock the tcp/udp transport
Date: Fri, 25 Jan 2008 18:16:28 -0500
Message-ID: <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47413 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932080AbYAYXRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:43 -0500
In-Reply-To: <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Make TCP and UDP svc_sock transports, and register them
with the svc transport core.

A transport type (svc_sock) has an svc_xprt as its first member,
and calls svc_xprt_init to initialize this field.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/debug.h   |    1 -
 include/linux/sunrpc/svcsock.h |    4 ++++
 net/sunrpc/sunrpc_syms.c       |    4 +++-
 net/sunrpc/svcsock.c           |   32 +++++++++++++++++++++++++++++++-
 4 files changed, 38 insertions(+), 3 deletions(-)

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
index 5793e00..a7827e4 100644
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
 	cache_unregister(&ip_map_cache);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c75bffe..54f1b3d 100644
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
 
-- 
1.5.4.rc2.60.gb2e62


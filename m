From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 02/33] svc: Make svc_sock the tcp/udp transport
Date: Thu, 27 Sep 2007 00:01:38 -0500
Message-ID: <20070927050138.12677.7673.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVM-0005b2-CZ
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:40 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVQ-00059Z-VS
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:45 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


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
@@ -20,7 +20,6 @@ #define RPCDBG_AUTH		0x0010
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
@@ -10,11 +10,13 @@ #ifndef SUNRPC_SVCSOCK_H
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
index 384c4ad..a62ce47 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -151,7 +151,8 @@ #ifdef CONFIG_PROC_FS
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
index 036ab52..2a56697 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -74,7 +74,7 @@ #include <linux/sunrpc/stats.h>
  *
  */
 
-#define RPCDBG_FACILITY	RPCDBG_SVCSOCK
+#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
@@ -899,12 +899,21 @@ svc_udp_sendto(struct svc_rqst *rqstp)
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
@@ -1343,12 +1352,33 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
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
 
@@ -1964,3 +1994,4 @@ static struct svc_deferred_req *svc_defe
 	spin_unlock(&svsk->sk_lock);
 	return dr;
 }
+

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

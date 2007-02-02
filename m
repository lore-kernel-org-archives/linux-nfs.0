From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 14] knfsd: SUNRPC: update internal API: separate pmap register and temp sockets
Date: Fri, 2 Feb 2007 15:39:41 +1100
Message-ID: <1070202043941.18926@suse.de>
References: <20070202153531.18622.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965361AbXBBEkL@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


From: Chuck Lever <chuck.lever@oracle.com>
Currently in the RPC server, registering with the local portmapper and
creating "permanent" sockets are tied together.  Expand the internal APIs
to allow these two socket characteristics to be separately specified.

This will be externalized in the next patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svcsock.h |    7 +++++
 ./net/sunrpc/svcsock.c           |   47 ++++++++++++++++++++++-----------------
 2 files changed, 34 insertions(+), 20 deletions(-)

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2007-02-02 14:32:25.000000000 +1100
+++ ./include/linux/sunrpc/svcsock.h	2007-02-02 14:39:07.000000000 +1100
@@ -74,4 +74,11 @@ int		svc_addsock(struct svc_serv *serv,
 			    char *name_return,
 			    int *proto);
 
+/*
+ * svc_makesock socket characteristics
+ */
+#define SVC_SOCK_DEFAULTS	(0U)
+#define SVC_SOCK_ANONYMOUS	(1U << 0)	/* don't register with pmap */
+#define SVC_SOCK_TEMPORARY	(1U << 1)	/* flag socket as temporary */
+
 #endif /* SUNRPC_SVCSOCK_H */

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-02-02 14:32:25.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-02-02 14:39:07.000000000 +1100
@@ -69,7 +69,7 @@
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
-					 int *errp, int pmap_reg);
+					 int *, int);
 static void		svc_udp_data_ready(struct sock *, int);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
@@ -922,7 +922,8 @@ svc_tcp_accept(struct svc_sock *svsk)
 	 */
 	newsock->sk->sk_sndtimeo = HZ*30;
 
-	if (!(newsvsk = svc_setup_socket(serv, newsock, &err, 0)))
+	if (!(newsvsk = svc_setup_socket(serv, newsock, &err,
+				 (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY))))
 		goto failed;
 
 
@@ -1462,12 +1463,14 @@ svc_age_temp_sockets(unsigned long closu
  * Initialize socket for RPC use and create svc_sock struct
  * XXX: May want to setsockopt SO_SNDBUF and SO_RCVBUF.
  */
-static struct svc_sock *
-svc_setup_socket(struct svc_serv *serv, struct socket *sock,
-					int *errp, int pmap_register)
+static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
+						struct socket *sock,
+						int *errp, int flags)
 {
 	struct svc_sock	*svsk;
 	struct sock	*inet;
+	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
+	int		is_temporary = flags & SVC_SOCK_TEMPORARY;
 
 	dprintk("svc: svc_setup_socket %p\n", sock);
 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
@@ -1509,7 +1512,7 @@ svc_setup_socket(struct svc_serv *serv, 
 		svc_tcp_init(svsk);
 
 	spin_lock_bh(&serv->sv_lock);
-	if (!pmap_register) {
+	if (is_temporary) {
 		set_bit(SK_TEMP, &svsk->sk_flags);
 		list_add(&svsk->sk_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
@@ -1553,7 +1556,7 @@ int svc_addsock(struct svc_serv *serv,
 	else if (so->state > SS_UNCONNECTED)
 		err = -EISCONN;
 	else {
-		svsk = svc_setup_socket(serv, so, &err, 1);
+		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
 		if (svsk)
 			err = 0;
 	}
@@ -1569,8 +1572,8 @@ EXPORT_SYMBOL_GPL(svc_addsock);
 /*
  * Create socket for RPC service.
  */
-static int
-svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr_in *sin)
+static int svc_create_socket(struct svc_serv *serv, int protocol,
+				struct sockaddr_in *sin, int flags)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
@@ -1606,8 +1609,8 @@ svc_create_socket(struct svc_serv *serv,
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, 1)) != NULL)
-		return 0;
+	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL)
+		return ntohs(inet_sk(svsk->sk_sk)->sport);
 
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);
@@ -1657,19 +1660,23 @@ svc_delete_socket(struct svc_sock *svsk)
 	svc_sock_put(svsk);
 }
 
-/*
- * Make a socket for nfsd and lockd
+/**
+ * svc_makesock - Make a socket for nfsd and lockd
+ * @serv: RPC server structure
+ * @protocol: transport protocol to use
+ * @port: port to use
+ *
  */
-int
-svc_makesock(struct svc_serv *serv, int protocol, unsigned short port)
+int svc_makesock(struct svc_serv *serv, int protocol, unsigned short port)
 {
-	struct sockaddr_in	sin;
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= INADDR_ANY,
+		.sin_port		= htons(port),
+	};
 
 	dprintk("svc: creating socket proto = %d\n", protocol);
-	sin.sin_family      = AF_INET;
-	sin.sin_addr.s_addr = INADDR_ANY;
-	sin.sin_port        = htons(port);
-	return svc_create_socket(serv, protocol, &sin);
+	return svc_create_socket(serv, protocol, &sin, SVC_SOCK_DEFAULTS);
 }
 
 /*

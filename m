From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 13] knfsd: SUNRPC: update internal API:
	separate pmap register and temp sockets
Date: Fri, 8 Dec 2006 23:01:52 +1100
Message-ID: <1061208120152.18136@suse.de>
References: <20061208225655.17970.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GseQB-00065Q-3O
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 04:01:43 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GseQB-0004re-MQ
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 04:01:44 -0800
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


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
--- .prev/include/linux/sunrpc/svcsock.h	2006-12-08 13:35:42.000000000 +1100
+++ ./include/linux/sunrpc/svcsock.h	2006-12-08 13:35:43.000000000 +1100
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
--- .prev/net/sunrpc/svcsock.c	2006-12-08 13:35:43.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2006-12-08 13:35:43.000000000 +1100
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
 
 
@@ -1456,12 +1457,14 @@ svc_age_temp_sockets(unsigned long closu
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
@@ -1503,7 +1506,7 @@ svc_setup_socket(struct svc_serv *serv, 
 		svc_tcp_init(svsk);
 
 	spin_lock_bh(&serv->sv_lock);
-	if (!pmap_register) {
+	if (is_temporary) {
 		set_bit(SK_TEMP, &svsk->sk_flags);
 		list_add(&svsk->sk_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
@@ -1547,7 +1550,7 @@ int svc_addsock(struct svc_serv *serv,
 	else if (so->state > SS_UNCONNECTED)
 		err = -EISCONN;
 	else {
-		svsk = svc_setup_socket(serv, so, &err, 1);
+		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
 		if (svsk)
 			err = 0;
 	}
@@ -1563,8 +1566,8 @@ EXPORT_SYMBOL_GPL(svc_addsock);
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
@@ -1600,8 +1603,8 @@ svc_create_socket(struct svc_serv *serv,
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, 1)) != NULL)
-		return 0;
+	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL)
+		return ntohs(inet_sk(svsk->sk_sk)->sport);
 
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);
@@ -1651,19 +1654,23 @@ svc_delete_socket(struct svc_sock *svsk)
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

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

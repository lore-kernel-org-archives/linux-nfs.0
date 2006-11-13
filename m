From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/13] SUNRPC: update internal API: separate pmap
	register and temp sockets
Date: Mon, 13 Nov 2006 07:57:53 -0500
Message-ID: <20061113125753.4435.16475.stgit@localhost.localdomain>
References: <20061113125640.4435.11957.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gjdep-00047b-BX
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:23:35 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gjdeq-0005ZB-8X
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:23:36 -0800
To: neilb@suse.de
In-Reply-To: <20061113125640.4435.11957.stgit@localhost.localdomain>
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

Currently in the RPC server, registering with the local portmapper and
creating "permanent" sockets are tied together.  Expand the internal APIs
to allow these two socket characteristics to be separately specified.

This will be externalized in the next patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 include/linux/sunrpc/svcsock.h |    7 ++++++
 net/sunrpc/svcsock.c           |   47 +++++++++++++++++++++++-----------------
 2 files changed, 34 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 98b21ad..3c38789 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
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
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 64ca1f6..f42d29d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -68,7 +68,7 @@ #define RPCDBG_FACILITY	RPCDBG_SVCSOCK
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
-					 int *errp, int pmap_reg);
+					 int *, int);
 static void		svc_udp_data_ready(struct sock *, int);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
@@ -892,7 +892,8 @@ svc_tcp_accept(struct svc_sock *svsk)
 	 */
 	newsock->sk->sk_sndtimeo = HZ*30;
 
-	if (!(newsvsk = svc_setup_socket(serv, newsock, &err, 0)))
+	if (!(newsvsk = svc_setup_socket(serv, newsock, &err,
+				 (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY))))
 		goto failed;
 
 
@@ -1426,12 +1427,14 @@ svc_age_temp_sockets(unsigned long closu
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
@@ -1473,7 +1476,7 @@ svc_setup_socket(struct svc_serv *serv, 
 		svc_tcp_init(svsk);
 
 	spin_lock_bh(&serv->sv_lock);
-	if (!pmap_register) {
+	if (is_temporary) {
 		set_bit(SK_TEMP, &svsk->sk_flags);
 		list_add(&svsk->sk_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
@@ -1517,7 +1520,7 @@ int svc_addsock(struct svc_serv *serv,
 	else if (so->state > SS_UNCONNECTED)
 		err = -EISCONN;
 	else {
-		svsk = svc_setup_socket(serv, so, &err, 1);
+		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
 		if (svsk)
 			err = 0;
 	}
@@ -1533,8 +1536,8 @@ EXPORT_SYMBOL_GPL(svc_addsock);
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
@@ -1568,8 +1571,8 @@ svc_create_socket(struct svc_serv *serv,
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, 1)) != NULL)
-		return 0;
+	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL)
+		return ntohs(inet_sk(svsk->sk_sk)->sport);
 
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);
@@ -1619,19 +1622,23 @@ svc_delete_socket(struct svc_sock *svsk)
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
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

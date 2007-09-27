From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 13/33] svc: Change services to use new svc_create_xprt service
Date: Thu, 27 Sep 2007 00:02:01 -0500
Message-ID: <20070927050201.12677.53731.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVk-0005fh-AC
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:04 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVn-0001mU-7A
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:09 -0700
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


Modify the various kernel RPC svcs to use the svc_create_xprt service.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/lockd/svc.c                 |   21 ++++++++++-----------
 fs/nfs/callback.c              |    4 ++--
 fs/nfsd/nfssvc.c               |    4 ++--
 include/linux/sunrpc/svcsock.h |    1 -
 net/sunrpc/sunrpc_syms.c       |    1 -
 net/sunrpc/svcsock.c           |   22 ----------------------
 6 files changed, 14 insertions(+), 39 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 82e2192..e71cc37 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -219,13 +219,12 @@ lockd(struct svc_rqst *rqstp)
 	module_put_and_exit(0);
 }
 
-
-static int find_socket(struct svc_serv *serv, int proto)
+static int find_xprt(struct svc_serv *serv, char *proto)
 {
-	struct svc_sock *svsk;
+	struct svc_xprt *xprt;
 	int found = 0;
-	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list)
-		if (svsk->sk_sk->sk_protocol == proto) {
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
+		if (strcmp(xprt->xpt_class->xcl_name, proto)==0) {
 			found = 1;
 			break;
 		}
@@ -243,13 +242,13 @@ static int make_socks(struct svc_serv *s
 	int err = 0;
 
 	if (proto == IPPROTO_UDP || nlm_udpport)
-		if (!find_socket(serv, IPPROTO_UDP))
-			err = svc_makesock(serv, IPPROTO_UDP, nlm_udpport,
-						SVC_SOCK_DEFAULTS);
+		if (!find_xprt(serv,"udp"))
+			err = svc_create_xprt(serv, "udp", nlm_udpport,
+					      SVC_SOCK_DEFAULTS);
 	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport))
-		if (!find_socket(serv, IPPROTO_TCP))
-			err = svc_makesock(serv, IPPROTO_TCP, nlm_tcpport,
-						SVC_SOCK_DEFAULTS);
+		if (!find_xprt(serv,"tcp"))
+			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
+					      SVC_SOCK_DEFAULTS);
 
 	if (err >= 0) {
 		warned = 0;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a796be5..e27ca14 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -123,8 +123,8 @@ int nfs_callback_up(void)
 	if (!serv)
 		goto out_err;
 
-	ret = svc_makesock(serv, IPPROTO_TCP, nfs_callback_set_tcpport,
-							SVC_SOCK_ANONYMOUS);
+	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
+			      SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
 		goto out_destroy;
 	nfs_callback_tcpport = ret;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index a8c89ae..bf70b06 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -236,7 +236,7 @@ static int nfsd_init_socks(int port)
 
 	error = lockd_up(IPPROTO_UDP);
 	if (error >= 0) {
-		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port,
+		error = svc_create_xprt(nfsd_serv, "udp", port,
 					SVC_SOCK_DEFAULTS);
 		if (error < 0)
 			lockd_down();
@@ -247,7 +247,7 @@ static int nfsd_init_socks(int port)
 #ifdef CONFIG_NFSD_TCP
 	error = lockd_up(IPPROTO_TCP);
 	if (error >= 0) {
-		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port,
+		error = svc_create_xprt(nfsd_serv, "tcp", port,
 					SVC_SOCK_DEFAULTS);
 		if (error < 0)
 			lockd_down();
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 9882ce0..3181d9d 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -67,7 +67,6 @@ #define SK_LISTENER	11			/* listening en
 /*
  * Function prototypes.
  */
-int		svc_makesock(struct svc_serv *, int, unsigned short, int flags);
 void		svc_force_close_socket(struct svc_sock *);
 int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index a62ce47..e4cad0f 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -72,7 +72,6 @@ EXPORT_SYMBOL(svc_drop);
 EXPORT_SYMBOL(svc_process);
 EXPORT_SYMBOL(svc_recv);
 EXPORT_SYMBOL(svc_wake_up);
-EXPORT_SYMBOL(svc_makesock);
 EXPORT_SYMBOL(svc_reserve);
 EXPORT_SYMBOL(svc_auth_register);
 EXPORT_SYMBOL(auth_domain_lookup);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d37f773..f6a6e57 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -2012,28 +2012,6 @@ void svc_force_close_socket(struct svc_s
 	svc_close_socket(svsk);
 }
 
-/**
- * svc_makesock - Make a socket for nfsd and lockd
- * @serv: RPC server structure
- * @protocol: transport protocol to use
- * @port: port to use
- * @flags: requested socket characteristics
- *
- */
-int svc_makesock(struct svc_serv *serv, int protocol, unsigned short port,
-			int flags)
-{
-	dprintk("svc: creating socket proto = %d\n", protocol);
-	switch (protocol) {
-	case IPPROTO_TCP:
-		return svc_create_xprt(serv, "tcp", port, flags);
-	case IPPROTO_UDP:
-		return svc_create_xprt(serv, "udp", port, flags);
-	default:
-		return -EINVAL;
-	}
-}
-
 /*
  * Handle defer and revisit of requests
  */

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

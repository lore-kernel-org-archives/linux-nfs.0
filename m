From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/12] SUNRPC: allow creating an RPC service without
	registering with portmapper
Date: Wed, 01 Nov 2006 13:08:08 -0500
Message-ID: <20061101180808.14581.98744.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfKVl-0006E6-C0
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:08:25 -0800
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GfKVi-0002aS-2Y
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 10:08:26 -0800
To: neilb@suse.de
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

Sometimes we need to create an RPC service but not register it with the
local portmapper.  NFSv4 delegation callback, for example.

And, replace a BUG() in fs/nfs/callback.c.  If this BUG() triggers, it
could make the whole system unusable, especially during bootup.  Just
print an error message instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/callback.c              |   20 +++++++++++---------
 include/linux/sunrpc/svcsock.h |    1 +
 net/sunrpc/sunrpc_syms.c       |    1 +
 net/sunrpc/svcsock.c           |   39 ++++++++++++++++++++++++++++++---------
 4 files changed, 43 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 7933e2e..9bdf766 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -119,17 +119,17 @@ int nfs_callback_up(void)
 	ret = -ENOMEM;
 	if (!serv)
 		goto out_err;
-	/* FIXME: We don't want to register this socket with the portmapper */
-	ret = svc_makesock(serv, IPPROTO_TCP, nfs_callback_set_tcpport);
+	ret = svc_makesock_noregister(serv, IPPROTO_TCP, nfs_callback_set_tcpport);
 	if (ret < 0)
 		goto out_destroy;
-	if (!list_empty(&serv->sv_permsocks)) {
-		svsk = list_entry(serv->sv_permsocks.next,
-				struct svc_sock, sk_list);
-		nfs_callback_tcpport = ntohs(inet_sk(svsk->sk_sk)->sport);
-		dprintk ("Callback port = 0x%x\n", nfs_callback_tcpport);
-	} else
-		BUG();
+	if (list_empty(&serv->sv_tempsocks)) {
+		ret = -ENOMEM;
+		goto out_destroy;
+	}
+	svsk = list_entry(serv->sv_tempsocks.next, struct svc_sock, sk_list);
+	nfs_callback_tcpport = ntohs(inet_sk(svsk->sk_sk)->sport);
+	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
+
 	ret = svc_create_thread(nfs_callback_svc, serv);
 	if (ret < 0)
 		goto out_destroy;
@@ -140,6 +140,8 @@ out:
 	unlock_kernel();
 	return ret;
 out_destroy:
+	dprintk("Couldn't create callback socket or server thread; err = %d\n",
+		ret);
 	svc_destroy(serv);
 out_err:
 	nfs_callback_info.users--;
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 98b21ad..dbcbfff 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -63,6 +63,7 @@ #define	SK_DETACHED	10			/* detached fro
  * Function prototypes.
  */
 int		svc_makesock(struct svc_serv *, int, unsigned short);
+int		svc_makesock_noregister(struct svc_serv *, int, unsigned short);
 void		svc_delete_socket(struct svc_sock *);
 int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 87f3f13..ec6a60e 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -79,6 +79,7 @@ EXPORT_SYMBOL(svc_process);
 EXPORT_SYMBOL(svc_recv);
 EXPORT_SYMBOL(svc_wake_up);
 EXPORT_SYMBOL(svc_makesock);
+EXPORT_SYMBOL(svc_makesock_noregister);
 EXPORT_SYMBOL(svc_reserve);
 EXPORT_SYMBOL(svc_auth_register);
 EXPORT_SYMBOL(auth_domain_lookup);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 64ca1f6..0868b26 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1534,7 +1534,7 @@ EXPORT_SYMBOL_GPL(svc_addsock);
  * Create socket for RPC service.
  */
 static int
-svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr_in *sin)
+svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr_in *sin, int pmap_register)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
@@ -1568,7 +1568,7 @@ svc_create_socket(struct svc_serv *serv,
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, 1)) != NULL)
+	if ((svsk = svc_setup_socket(serv, sock, &error, pmap_register)) != NULL)
 		return 0;
 
 bummer:
@@ -1619,19 +1619,40 @@ svc_delete_socket(struct svc_sock *svsk)
 	svc_sock_put(svsk);
 }
 
-/*
- * Make a socket for nfsd and lockd
- */
-int
-svc_makesock(struct svc_serv *serv, int protocol, unsigned short port)
+static inline int __svc_makesock(struct svc_serv *serv, int protocol, unsigned short port, int pmap_register)
 {
-	struct sockaddr_in	sin;
+	struct sockaddr_in sin;
 
 	dprintk("svc: creating socket proto = %d\n", protocol);
 	sin.sin_family      = AF_INET;
 	sin.sin_addr.s_addr = INADDR_ANY;
 	sin.sin_port        = htons(port);
-	return svc_create_socket(serv, protocol, &sin);
+	return svc_create_socket(serv, protocol, &sin, pmap_register);
+}
+
+/**
+ * svc_makesock - Make a socket for nfsd and lockd
+ * @serv: RPC server structure
+ * @protocol: transport protocol to use
+ * @port: port to use
+ *
+ */
+int svc_makesock(struct svc_serv *serv, int protocol, unsigned short port)
+{
+	return __svc_makesock(serv, protocol, port, 1);
+}
+
+/**
+ * svc_makesock_noregister - Make a socket for nfsd and lockd
+ * @serv: RPC server structure
+ * @protocol: transport protocol to use
+ * @port: port to use
+ *
+ * This one doesn't register the new service with the local portmapper.
+ */
+int svc_makesock_noregister(struct svc_serv *serv, int protocol, unsigned short port)
+{
+	return __svc_makesock(serv, protocol, port, 0);
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

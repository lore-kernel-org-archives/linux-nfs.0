From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 12/33] svc: Add a generic transport svc_create_xprt function
Date: Thu, 27 Sep 2007 00:01:59 -0500
Message-ID: <20070927050159.12677.37758.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVg-0005bt-Pp
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:00 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVl-0001kb-3s
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:05 -0700
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


The svc_create_xprt function is a transport independent version
of the svc_makesock function. 

Since transport instance creation contains transport dependent and 
independent components, add an xpo_create transport function. The 
transport implementation of this function allocates the memory for the 
endpoint, implements the transport dependent initialization logic, and
calls svc_xprt_init to initialize the transport independent field (svc_xprt) 
in it's data structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    4 +++
 net/sunrpc/svc_xprt.c           |   38 ++++++++++++++++++++++++++
 net/sunrpc/svcsock.c            |   58 +++++++++++++++++++++++++++++----------
 3 files changed, 85 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 4c1a650..6a34bb4 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -10,6 +10,9 @@ #define SUNRPC_SVC_XPRT_H
 #include <linux/sunrpc/svc.h>
 
 struct svc_xprt_ops {
+	struct svc_xprt	*(*xpo_create)(struct svc_serv *,
+				       struct sockaddr *,
+				       int);
 	struct svc_xprt	*(*xpo_accept)(struct svc_xprt *);
 	int		(*xpo_has_wspace)(struct svc_xprt *);
 	int		(*xpo_recvfrom)(struct svc_rqst *);
@@ -37,5 +40,6 @@ struct svc_xprt {
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 int	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
+int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
 
 #endif /* SUNRPC_SVC_XPRT_H */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 6151db5..fab0ce3 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -93,3 +93,41 @@ void svc_xprt_init(struct svc_xprt_class
 	xpt->xpt_max_payload = xcl->xcl_max_payload;
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
+
+int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
+		    int flags)
+{
+	int ret = -ENOENT;
+	struct list_head *le;
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+ 		.sin_addr.s_addr	= INADDR_ANY,
+ 		.sin_port		= htons(port),
+ 	};
+	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
+	spin_lock(&svc_xprt_class_lock);
+	list_for_each(le, &svc_xprt_class_list) {
+		struct svc_xprt_class *xcl =
+			list_entry(le, struct svc_xprt_class, xcl_list);
+		if (strcmp(xprt_name, xcl->xcl_name)==0) {
+			spin_unlock(&svc_xprt_class_lock);
+			if (try_module_get(xcl->xcl_owner)) {
+				struct svc_xprt *newxprt;
+				ret = 0;
+				newxprt = xcl->xcl_ops->xpo_create
+					(serv, (struct sockaddr*)&sin, flags);
+				if (IS_ERR(newxprt)) {
+					module_put(xcl->xcl_owner);
+					ret = PTR_ERR(newxprt);
+				}
+				goto out;
+			}
+		}
+	}
+	spin_unlock(&svc_xprt_class_lock);
+	dprintk("svc: transport %s not found\n", xprt_name);
+ out:
+	return ret;
+}
+EXPORT_SYMBOL_GPL(svc_create_xprt);
+
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 19f7bbc..d37f773 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -90,6 +90,8 @@ static void		svc_sock_free(struct svc_xp
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
+static struct svc_xprt *
+svc_create_socket(struct svc_serv *, int, struct sockaddr *, int, int);
 
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
@@ -381,6 +383,7 @@ svc_sock_put(struct svc_sock *svsk)
 {
 	if (atomic_dec_and_test(&svsk->sk_inuse)) {
 		BUG_ON(!test_bit(SK_DEAD, &svsk->sk_flags));
+		module_put(svsk->sk_xprt.xpt_class->xcl_owner);
 		svsk->sk_xprt.xpt_ops.xpo_free(&svsk->sk_xprt);
 	}
 }
@@ -921,7 +924,15 @@ svc_udp_accept(struct svc_xprt *xprt)
 	return NULL;
 }
 
+static struct svc_xprt *
+svc_udp_create(struct svc_serv *serv, struct sockaddr *sa, int flags)
+{
+	return svc_create_socket(serv, IPPROTO_UDP, sa,
+				 sizeof(struct sockaddr_in), flags);
+}
+
 static struct svc_xprt_ops svc_udp_ops = {
+	.xpo_create = svc_udp_create,
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
 	.xpo_release = svc_release_skb,
@@ -934,6 +945,7 @@ static struct svc_xprt_ops svc_udp_ops =
 
 static struct svc_xprt_class svc_udp_class = {
 	.xcl_name = "udp",
+	.xcl_owner = THIS_MODULE,
 	.xcl_ops = &svc_udp_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 };
@@ -1357,7 +1369,15 @@ svc_tcp_has_wspace(struct svc_xprt *xprt
 	return 1;
 }
 
+static struct svc_xprt *
+svc_tcp_create(struct svc_serv *serv, struct sockaddr *sa, int flags)
+{
+	return svc_create_socket(serv, IPPROTO_TCP, sa,
+				 sizeof(struct sockaddr_in), flags);
+}
+
 static struct svc_xprt_ops svc_tcp_ops = {
+	.xpo_create = svc_tcp_create,
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
 	.xpo_release = svc_release_skb,
@@ -1370,6 +1390,7 @@ static struct svc_xprt_ops svc_tcp_ops =
 
 static struct svc_xprt_class svc_tcp_class = {
 	.xcl_name = "tcp",
+	.xcl_owner = THIS_MODULE,
 	.xcl_ops = &svc_tcp_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
@@ -1594,8 +1615,14 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = svsk->sk_xprt.xpt_ops.xpo_accept(&svsk->sk_xprt);
-		if (newxpt)
+		if (newxpt) {
+			/* 
+			 * We know this module_get will succeed because the
+			 * listener holds a reference too 
+			 */
+			__module_get(newxpt->xpt_class->xcl_owner);
 			svc_check_conn_limits(svsk->sk_server);
+		}			
 		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
@@ -1835,8 +1862,9 @@ EXPORT_SYMBOL_GPL(svc_addsock);
 /*
  * Create socket for RPC service.
  */
-static int svc_create_socket(struct svc_serv *serv, int protocol,
-				struct sockaddr *sin, int len, int flags)
+static struct svc_xprt *
+svc_create_socket(struct svc_serv *serv, int protocol,
+		  struct sockaddr *sin, int len, int flags)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
@@ -1851,13 +1879,13 @@ static int svc_create_socket(struct svc_
 	if (protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
 		printk(KERN_WARNING "svc: only UDP and TCP "
 				"sockets supported\n");
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 	}
 	type = (protocol == IPPROTO_UDP)? SOCK_DGRAM : SOCK_STREAM;
 
 	error = sock_create_kern(sin->sa_family, type, protocol, &sock);
 	if (error < 0)
-		return error;
+		return ERR_PTR(error);
 
 	svc_reclassify_socket(sock);
 
@@ -1876,13 +1904,13 @@ static int svc_create_socket(struct svc_
 		if (protocol == IPPROTO_TCP) 
 			set_bit(SK_LISTENER, &svsk->sk_flags);
 		svc_sock_received(svsk);
-		return ntohs(inet_sk(svsk->sk_sk)->sport);
+		return (struct svc_xprt *)svsk;
 	}
 
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);
 	sock_release(sock);
-	return error;
+	return ERR_PTR(error);
 }
 
 /*
@@ -1995,15 +2023,15 @@ void svc_force_close_socket(struct svc_s
 int svc_makesock(struct svc_serv *serv, int protocol, unsigned short port,
 			int flags)
 {
-	struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-		.sin_addr.s_addr	= INADDR_ANY,
-		.sin_port		= htons(port),
-	};
-
 	dprintk("svc: creating socket proto = %d\n", protocol);
-	return svc_create_socket(serv, protocol, (struct sockaddr *) &sin,
-							sizeof(sin), flags);
+	switch (protocol) {
+	case IPPROTO_TCP:
+		return svc_create_xprt(serv, "tcp", port, flags);
+	case IPPROTO_UDP:
+		return svc_create_xprt(serv, "udp", port, flags);
+	default:
+		return -EINVAL;
+	}
 }
 
 /*

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

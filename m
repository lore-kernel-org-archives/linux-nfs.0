From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 16/20] svc: sko_create_svc
Date: Tue, 10 Jul 2007 00:34:53 -0500
Message-ID: <20070710053453.28979.74690.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88NE-000769-RB
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:56 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88NH-0004wk-BE
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:35:00 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id E95717C7BF
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:53 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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


Add an sko function that makes the creation of a listening endpoint 
transport independent.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    5 +++
 net/sunrpc/svcsock.c           |   64 +++++++++++++++++++++++++++++++++++++---
 2 files changed, 64 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index d132dd5..383ac4f 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -14,6 +14,10 @@ #include <linux/sunrpc/svc.h>
 struct svc_sock_ops {
 	const char		*sko_name;
 	struct module		*sko_owner;
+	/* Create an svc socket for this transport */
+	int			(*sko_create_svc)(struct svc_serv *,
+						  struct sockaddr *,
+						  int);
 	int			(*sko_recvfrom)(struct svc_rqst *rqstp);
 	int			(*sko_sendto)(struct svc_rqst *rqstp);
 	/*
@@ -110,6 +114,7 @@ #define	SK_LISTENER	11			/* listener (e.
 int 		svc_register_transport(struct svc_sock_ops *xprt);
 int 		svc_unregister_transport(struct svc_sock_ops *xprt);
 int		svc_makesock(struct svc_serv *, int, unsigned short, int flags);
+int		svc_create_svcsock(struct svc_serv *, char *, unsigned short, int);
 void		svc_force_close_socket(struct svc_sock *);
 int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 33aff99..b14dc46 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -87,6 +87,8 @@ static void		svc_close_socket(struct svc
 static void		svc_tcpip_detach(struct svc_sock *);
 static void		svc_tcpip_free(struct svc_sock *);
 
+static int
+svc_create_socket(struct svc_serv *, int, struct sockaddr *, int, int);
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
@@ -434,6 +436,7 @@ __svc_sock_put(struct svc_sock *svsk)
 
 	if (svsk->sk_info_authunix != NULL)
 		svcauth_unix_info_release(svsk->sk_info_authunix);
+	module_put(svsk->sk_ops->sko_owner);
     	svsk->sk_ops->sko_free(svsk);
 }
 EXPORT_SYMBOL(__svc_sock_put);
@@ -961,9 +964,17 @@ svc_udp_has_wspace(struct svc_sock *svsk
 	return svc_sock_has_write_space(svsk, sock_wspace(svsk->sk_sk));
 }
 
+static int
+svc_udp_create_svc(struct svc_serv *serv, struct sockaddr *sa, int flags)
+{
+	return svc_create_socket(serv, IPPROTO_UDP, sa,
+				 sizeof(struct sockaddr_in), flags);
+}
+
 static struct svc_sock_ops svc_udp_ops = {
 	.sko_name = "udp",
 	.sko_owner = THIS_MODULE,
+	.sko_create_svc = svc_udp_create_svc,
 	.sko_recvfrom = svc_udp_recvfrom,
 	.sko_sendto = svc_udp_sendto,
 	.sko_detach = svc_tcpip_detach,
@@ -1421,9 +1432,17 @@ svc_tcp_has_wspace(struct svc_sock *svsk
 	return svc_sock_has_write_space(svsk, sk_stream_wspace(svsk->sk_sk));
 }
 
+static int
+svc_tcp_create_svc(struct svc_serv *serv, struct sockaddr *sa, int flags)
+{
+	return svc_create_socket(serv, IPPROTO_TCP, sa,
+				 sizeof(struct sockaddr_in), flags);
+}
+
 static struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
 	.sko_owner = THIS_MODULE,
+	.sko_create_svc = svc_tcp_create_svc,
 	.sko_recvfrom = svc_tcp_recvfrom,
 	.sko_sendto = svc_tcp_sendto,
 	.sko_detach = svc_tcpip_detach,
@@ -1605,6 +1624,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		svc_delete_socket(svsk);
 	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
 		svsk->sk_ops->sko_accept(svsk);
+		__module_get(svsk->sk_ops->sko_owner);
 		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
@@ -1884,7 +1904,7 @@ EXPORT_SYMBOL_GPL(svc_addsock);
  * Create socket for RPC service.
  */
 static int svc_create_socket(struct svc_serv *serv, int protocol,
-				struct sockaddr *sin, int len, int flags)
+			     struct sockaddr *sin, int len, int flags)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
@@ -2036,17 +2056,51 @@ void svc_force_close_socket(struct svc_s
  *
  */
 int svc_makesock(struct svc_serv *serv, int protocol, unsigned short port,
-			int flags)
+		 int flags)
 {
+	dprintk("svc: creating socket proto = %d\n", protocol);
+	switch (protocol) {
+	case IPPROTO_TCP:
+		return svc_create_svcsock(serv, "tcp", port, flags);
+	case IPPROTO_UDP:
+		return svc_create_svcsock(serv, "udp", port, flags);
+	default:
+		return -EINVAL;
+	}
+}
+
+int svc_create_svcsock(struct svc_serv *serv, char *transport, unsigned short port,
+		       int flags)
+{
+	int ret = -ENOENT;
+	struct list_head *le;
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= INADDR_ANY,
 		.sin_port		= htons(port),
 	};
+	dprintk("svc: creating transport socket %s[%d]\n", transport, port);
+	spin_lock(&svc_transport_lock);
+	list_for_each(le, &svc_transport_list) {
+		struct svc_sock_ops *op = 
+			list_entry(le, struct svc_sock_ops, sko_list);
 
-	dprintk("svc: creating socket proto = %d\n", protocol);
-	return svc_create_socket(serv, protocol, (struct sockaddr *) &sin,
-							sizeof(sin), flags);
+		if (strcmp(transport, op->sko_name)==0) {
+			spin_unlock(&svc_transport_lock);
+			if (try_module_get(op->sko_owner)) {
+				ret = op->sko_create_svc(serv, 
+							 (struct sockaddr*)&sin, 
+							 flags);
+				if (ret < 0)
+					module_put(op->sko_owner);
+				goto out;
+			}
+		}
+	}
+	spin_unlock(&svc_transport_lock);
+	dprintk("svc: transport %s not found\n", transport);
+ out:
+	return ret;
 }
 
 /*

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

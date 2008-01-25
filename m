From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 060/100] svc: Add a generic transport svc_create_xprt function
Date: Fri, 25 Jan 2008 18:16:40 -0500
Message-ID: <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
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
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47457 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762051AbYAYXRw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:52 -0500
In-Reply-To: <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

The svc_create_xprt function is a transport independent version
of the svc_makesock function.

Since transport instance creation contains transport dependent and
independent components, add an xpo_create transport function. The
transport implementation of this function allocates the memory for the
endpoint, implements the transport dependent initialization logic, and
calls svc_xprt_init to initialize the transport independent field (svc_xprt)
in it's data structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc_xprt.h |    4 ++
 net/sunrpc/svc_xprt.c           |   37 ++++++++++++++++++++++++
 net/sunrpc/svcsock.c            |   59 +++++++++++++++++++++++++++++----------
 3 files changed, 85 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 31a44f4..986a5a0 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -10,6 +10,9 @@
 #include <linux/sunrpc/svc.h>
 
 struct svc_xprt_ops {
+	struct svc_xprt	*(*xpo_create)(struct svc_serv *,
+				       struct sockaddr *, int,
+				       int);
 	struct svc_xprt	*(*xpo_accept)(struct svc_xprt *);
 	int		(*xpo_has_wspace)(struct svc_xprt *);
 	int		(*xpo_recvfrom)(struct svc_rqst *);
@@ -36,5 +39,6 @@ struct svc_xprt {
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 void	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
+int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
 
 #endif /* SUNRPC_SVC_XPRT_H */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index fe5270f..6ff5ca7 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -81,3 +81,40 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt)
 	xprt->xpt_ops = xcl->xcl_ops;
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
+
+int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
+		    int flags)
+{
+	struct svc_xprt_class *xcl;
+	int ret = -ENOENT;
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= INADDR_ANY,
+		.sin_port		= htons(port),
+	};
+	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
+	spin_lock(&svc_xprt_class_lock);
+	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
+		if (strcmp(xprt_name, xcl->xcl_name) == 0) {
+			spin_unlock(&svc_xprt_class_lock);
+			if (try_module_get(xcl->xcl_owner)) {
+				struct svc_xprt *newxprt;
+				ret = 0;
+				newxprt = xcl->xcl_ops->xpo_create
+					(serv,
+					 (struct sockaddr *)&sin, sizeof(sin),
+					 flags);
+				if (IS_ERR(newxprt)) {
+					module_put(xcl->xcl_owner);
+					ret = PTR_ERR(newxprt);
+				}
+			}
+			goto out;
+		}
+	}
+	spin_unlock(&svc_xprt_class_lock);
+	dprintk("svc: transport %s not found\n", xprt_name);
+ out:
+	return ret;
+}
+EXPORT_SYMBOL_GPL(svc_create_xprt);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 6e9dc8f..9f0f6d0 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -91,6 +91,8 @@ static void		svc_sock_free(struct svc_xprt *);
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
+static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
+					  struct sockaddr *, int, int);
 
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
@@ -365,6 +367,7 @@ svc_sock_put(struct svc_sock *svsk)
 {
 	if (atomic_dec_and_test(&svsk->sk_inuse)) {
 		BUG_ON(!test_bit(SK_DEAD, &svsk->sk_flags));
+		module_put(svsk->sk_xprt.xpt_class->xcl_owner);
 		svsk->sk_xprt.xpt_ops->xpo_free(&svsk->sk_xprt);
 	}
 }
@@ -902,7 +905,15 @@ static struct svc_xprt *svc_udp_accept(struct svc_xprt *xprt)
 	return NULL;
 }
 
+static struct svc_xprt *svc_udp_create(struct svc_serv *serv,
+				       struct sockaddr *sa, int salen,
+				       int flags)
+{
+	return svc_create_socket(serv, IPPROTO_UDP, sa, salen, flags);
+}
+
 static struct svc_xprt_ops svc_udp_ops = {
+	.xpo_create = svc_udp_create,
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
 	.xpo_release_rqst = svc_release_skb,
@@ -915,6 +926,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 
 static struct svc_xprt_class svc_udp_class = {
 	.xcl_name = "udp",
+	.xcl_owner = THIS_MODULE,
 	.xcl_ops = &svc_udp_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 };
@@ -1384,7 +1396,15 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 	return 1;
 }
 
+static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
+				       struct sockaddr *sa, int salen,
+				       int flags)
+{
+	return svc_create_socket(serv, IPPROTO_TCP, sa, salen, flags);
+}
+
 static struct svc_xprt_ops svc_tcp_ops = {
+	.xpo_create = svc_tcp_create,
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
 	.xpo_release_rqst = svc_release_skb,
@@ -1397,6 +1417,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
 
 static struct svc_xprt_class svc_tcp_class = {
 	.xcl_name = "tcp",
+	.xcl_owner = THIS_MODULE,
 	.xcl_ops = &svc_tcp_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
@@ -1573,8 +1594,14 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = svsk->sk_xprt.xpt_ops->xpo_accept(&svsk->sk_xprt);
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
@@ -1814,8 +1841,10 @@ EXPORT_SYMBOL_GPL(svc_addsock);
 /*
  * Create socket for RPC service.
  */
-static int svc_create_socket(struct svc_serv *serv, int protocol,
-				struct sockaddr *sin, int len, int flags)
+static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
+					  int protocol,
+					  struct sockaddr *sin, int len,
+					  int flags)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
@@ -1830,13 +1859,13 @@ static int svc_create_socket(struct svc_serv *serv, int protocol,
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
 
@@ -1853,13 +1882,13 @@ static int svc_create_socket(struct svc_serv *serv, int protocol,
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
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
@@ -1970,15 +1999,15 @@ void svc_force_close_socket(struct svc_sock *svsk)
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
-- 
1.5.4.rc2.60.gb2e62


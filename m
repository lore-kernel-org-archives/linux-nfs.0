Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3783 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780Ab0I0KHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:07:42 -0400
Message-ID: <4CA06CE3.1040907@parallels.com>
Date: Mon, 27 Sep 2010 14:07:31 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] sunrpc: Pull net argument downto svc_create_socket
References: <4CA06C7A.5060307@parallels.com>
In-Reply-To: <4CA06C7A.5060307@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

After this the socket creation in it knows the context.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/svc_xprt.h          |    1 +
 net/sunrpc/svc_xprt.c                    |    5 +++--
 net/sunrpc/svcsock.c                     |   10 +++++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 ++
 4 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 646263c..bb18297 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -12,6 +12,7 @@
 
 struct svc_xprt_ops {
 	struct svc_xprt	*(*xpo_create)(struct svc_serv *,
+				       struct net *net,
 				       struct sockaddr *, int,
 				       int);
 	struct svc_xprt	*(*xpo_accept)(struct svc_xprt *);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d80789a..678b6ee 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -166,6 +166,7 @@ EXPORT_SYMBOL_GPL(svc_xprt_init);
 
 static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 					 struct svc_serv *serv,
+					 struct net *net,
 					 const int family,
 					 const unsigned short port,
 					 int flags)
@@ -200,7 +201,7 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
-	return xcl->xcl_ops->xpo_create(serv, sap, len, flags);
+	return xcl->xcl_ops->xpo_create(serv, net, sap, len, flags);
 }
 
 int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
@@ -221,7 +222,7 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 			goto err;
 
 		spin_unlock(&svc_xprt_class_lock);
-		newxprt = __svc_xpo_create(xcl, serv, family, port, flags);
+		newxprt = __svc_xpo_create(xcl, serv, net, family, port, flags);
 		if (IS_ERR(newxprt)) {
 			module_put(xcl->xcl_owner);
 			return PTR_ERR(newxprt);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7e534dd..5593385 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -64,7 +64,8 @@ static void		svc_tcp_sock_detach(struct svc_xprt *);
 static void		svc_sock_free(struct svc_xprt *);
 
 static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
-					  struct sockaddr *, int, int);
+					  struct net *, struct sockaddr *,
+					  int, int);
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key svc_key[2];
 static struct lock_class_key svc_slock_key[2];
@@ -657,10 +658,11 @@ static struct svc_xprt *svc_udp_accept(struct svc_xprt *xprt)
 }
 
 static struct svc_xprt *svc_udp_create(struct svc_serv *serv,
+				       struct net *net,
 				       struct sockaddr *sa, int salen,
 				       int flags)
 {
-	return svc_create_socket(serv, IPPROTO_UDP, sa, salen, flags);
+	return svc_create_socket(serv, IPPROTO_UDP, net, sa, salen, flags);
 }
 
 static struct svc_xprt_ops svc_udp_ops = {
@@ -1178,10 +1180,11 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 }
 
 static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
+				       struct net *net,
 				       struct sockaddr *sa, int salen,
 				       int flags)
 {
-	return svc_create_socket(serv, IPPROTO_TCP, sa, salen, flags);
+	return svc_create_socket(serv, IPPROTO_TCP, net, sa, salen, flags);
 }
 
 static struct svc_xprt_ops svc_tcp_ops = {
@@ -1385,6 +1388,7 @@ EXPORT_SYMBOL_GPL(svc_addsock);
  */
 static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 					  int protocol,
+					  struct net *net,
 					  struct sockaddr *sin, int len,
 					  int flags)
 {
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index edea15a..950a206 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -52,6 +52,7 @@
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
+					struct net *net,
 					struct sockaddr *sa, int salen,
 					int flags);
 static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt);
@@ -670,6 +671,7 @@ static int rdma_cma_handler(struct rdma_cm_id *cma_id,
  * Create a listening RDMA service endpoint.
  */
 static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
+					struct net *net,
 					struct sockaddr *sa, int salen,
 					int flags)
 {
-- 
1.5.5.6


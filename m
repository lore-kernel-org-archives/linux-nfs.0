Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932245AbbFDQqO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:46:14 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 08/10] SUNRPC: add vsock-bc backchannel
Date: Thu,  4 Jun 2015 17:45:51 +0100
Message-Id: <1433436353-6761-9-git-send-email-stefanha@redhat.com>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note that this is currently a hack which unconditionally replaces
"tcp-bc" with "vsock-bc".  Need to find a way to select the appropriate
backchannel name based on the address family.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 fs/nfs/callback.c    |  7 +++++--
 net/sunrpc/svcsock.c | 48 ++++++++++++++++++++++++++++++------------------
 2 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 8d129bb..ce4cae1 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -106,8 +106,11 @@ static int nfs41_callback_up_net(struct svc_serv *serv, struct net *net)
 	 * fore channel connection.
 	 * Returns the input port (0) and sets the svc_serv bc_xprt on success
 	 */
-	return svc_create_xprt(serv, "tcp-bc", net, PF_INET, 0,
-			      SVC_SOCK_ANONYMOUS);
+/*	return svc_create_xprt(serv, "tcp-bc", net, PF_INET, 0,
+			      SVC_SOCK_ANONYMOUS); */
+	/* TODO check address family and choose appropriately */
+	return svc_create_xprt(serv, "vsock-bc", net, AF_VSOCK, 0,
+			       SVC_SOCK_ANONYMOUS);
 }
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0c81202..c6ba593 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -71,7 +71,7 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
 					  struct net *, struct sockaddr *,
 					  int, int);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
-static struct svc_xprt *svc_bc_create_socket(struct svc_serv *, int,
+static struct svc_xprt *svc_bc_create_socket(struct svc_serv *,
 					     struct net *, struct sockaddr *,
 					     int, int);
 static void svc_bc_sock_free(struct svc_xprt *xprt);
@@ -1232,25 +1232,17 @@ static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
 }
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
-static struct svc_xprt *svc_bc_create_socket(struct svc_serv *, int,
+static struct svc_xprt *svc_bc_create_socket(struct svc_serv *,
 					     struct net *, struct sockaddr *,
 					     int, int);
 static void svc_bc_sock_free(struct svc_xprt *xprt);
 
-static struct svc_xprt *svc_bc_tcp_create(struct svc_serv *serv,
-				       struct net *net,
-				       struct sockaddr *sa, int salen,
-				       int flags)
-{
-	return svc_bc_create_socket(serv, IPPROTO_TCP, net, sa, salen, flags);
-}
-
 static void svc_bc_tcp_sock_detach(struct svc_xprt *xprt)
 {
 }
 
 static struct svc_xprt_ops svc_tcp_bc_ops = {
-	.xpo_create = svc_bc_tcp_create,
+	.xpo_create = svc_bc_create_socket,
 	.xpo_detach = svc_bc_tcp_sock_detach,
 	.xpo_free = svc_bc_sock_free,
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
@@ -1264,14 +1256,41 @@ static struct svc_xprt_class svc_tcp_bc_class = {
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
 
+#if IS_ENABLED(CONFIG_VSOCKETS)
+static void svc_bc_vsock_sock_detach(struct svc_xprt *xprt)
+{
+}
+
+static struct svc_xprt_ops svc_vsock_bc_ops = {
+	.xpo_create = svc_bc_create_socket,
+	.xpo_detach = svc_bc_vsock_sock_detach,
+	.xpo_free = svc_bc_sock_free,
+	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.xpo_secure_port = svc_sock_secure_port,
+};
+
+static struct svc_xprt_class svc_vsock_bc_class = {
+	.xcl_name = "vsock-bc",
+	.xcl_owner = THIS_MODULE,
+	.xcl_ops = &svc_vsock_bc_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD,
+};
+#endif /* IS_ENABLED(CONFIG_VSOCKETS) */
+
 static void svc_init_bc_xprt_sock(void)
 {
 	svc_reg_xprt_class(&svc_tcp_bc_class);
+#if IS_ENABLED(CONFIG_VSOCKETS)
+	svc_reg_xprt_class(&svc_vsock_bc_class);
+#endif
 }
 
 static void svc_cleanup_bc_xprt_sock(void)
 {
 	svc_unreg_xprt_class(&svc_tcp_bc_class);
+#if IS_ENABLED(CONFIG_VSOCKETS)
+	svc_unreg_xprt_class(&svc_vsock_bc_class);
+#endif
 }
 #else /* CONFIG_SUNRPC_BACKCHANNEL */
 static void svc_init_bc_xprt_sock(void)
@@ -1635,7 +1654,6 @@ static void svc_sock_free(struct svc_xprt *xprt)
  * Create a back channel svc_xprt which shares the fore channel socket.
  */
 static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
-					     int protocol,
 					     struct net *net,
 					     struct sockaddr *sin, int len,
 					     int flags)
@@ -1643,12 +1661,6 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
 	struct svc_sock *svsk;
 	struct svc_xprt *xprt;
 
-	if (protocol != IPPROTO_TCP) {
-		printk(KERN_WARNING "svc: only TCP sockets"
-			" supported on shared back channel\n");
-		return ERR_PTR(-EINVAL);
-	}
-
 	svsk = kzalloc(sizeof(*svsk), GFP_KERNEL);
 	if (!svsk)
 		return ERR_PTR(-ENOMEM);
-- 
2.4.2


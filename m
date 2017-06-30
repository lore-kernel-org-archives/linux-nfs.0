Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41716 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752381AbdF3NYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:25 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 07/14] SUNRPC: drop unnecessary svc_bc_tcp_create() helper
Date: Fri, 30 Jun 2017 14:23:45 +0100
Message-Id: <20170630132352.32133-8-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_bc_tcp_create() is a helper function that simply calls
svc_bc_create_socket() with an added IPPROTO_TCP argument.

svc_bc_create_socket() then checks that the protocol argument is indeed
IPPROTO_TCP.

This isn't necessary since svc_bc_tcp_create() is the only
svc_bc_create_socket() caller.  The next patch adds a second caller for
AF_VSOCK where IPPROTO_TCP will not be used.

Scrap this scheme and just call svc_bc_create_socket() directly.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/svcsock.c | 21 +++------------------
 1 file changed, 3 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2b720fa..394e7a2 100644
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
@@ -1212,25 +1212,17 @@ static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
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
@@ -1615,7 +1607,6 @@ static void svc_sock_free(struct svc_xprt *xprt)
  * Create a back channel svc_xprt which shares the fore channel socket.
  */
 static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
-					     int protocol,
 					     struct net *net,
 					     struct sockaddr *sin, int len,
 					     int flags)
@@ -1623,12 +1614,6 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
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
2.9.4


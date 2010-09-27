Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5770 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614Ab0I0KKP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:10:15 -0400
Message-ID: <4CA06D7A.1010202@parallels.com>
Date: Mon, 27 Sep 2010 14:10:02 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 8/8] sunrpc: Create sockets in net namespaces
References: <4CA06C7A.5060307@parallels.com>
In-Reply-To: <4CA06C7A.5060307@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The context is already known in all the sock_create callers.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/svcsock.c  |    2 +-
 net/sunrpc/xprtsock.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5593385..88de3d0 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1425,7 +1425,7 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 		return ERR_PTR(-EINVAL);
 	}
 
-	error = sock_create_kern(family, type, protocol, &sock);
+	error = __sock_create(net, family, type, protocol, &sock, 1);
 	if (error < 0)
 		return ERR_PTR(error);
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 292f449..aa24ba5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1682,7 +1682,7 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
 
-	err = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	err = __sock_create(xprt->xprt_net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
 	if (err < 0) {
 		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
 		goto out;
@@ -1727,7 +1727,7 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
 
-	err = sock_create_kern(PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	err = __sock_create(xprt->xprt_net, PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
 	if (err < 0) {
 		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
 		goto out;
@@ -1933,7 +1933,7 @@ static struct socket *xs_create_tcp_sock4(struct rpc_xprt *xprt,
 	int err;
 
 	/* start from scratch */
-	err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	err = __sock_create(xprt->xprt_net, PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock, 1);
 	if (err < 0) {
 		dprintk("RPC:       can't create TCP transport socket (%d).\n",
 				-err);
@@ -1972,7 +1972,7 @@ static struct socket *xs_create_tcp_sock6(struct rpc_xprt *xprt,
 	int err;
 
 	/* start from scratch */
-	err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock);
+	err = __sock_create(xprt->xprt_net, PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock, 1);
 	if (err < 0) {
 		dprintk("RPC:       can't create TCP transport socket (%d).\n",
 				-err);
-- 
1.5.5.6


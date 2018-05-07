Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:37525 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752601AbeEGT1D (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:27:03 -0400
Subject: [PATCH v1 02/19] svcrdma: Use passed-in net namespace when creating
 RDMA listener
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:27:00 -0400
Message-ID: <20180507192700.4608.34235.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure each RDMA listener and its children transports are created in
the same net namespace as the user that started the NFS service.
This is similar to how listener sockets are created in
svc_create_socket, required for enabling support for containers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   35 +++++++++++++++---------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 3633254..22e2595 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -60,7 +60,8 @@
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 static int svc_rdma_post_recv(struct svcxprt_rdma *xprt);
-static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *, int);
+static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
+						 struct net *net);
 static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 					struct net *net,
 					struct sockaddr *sa, int salen,
@@ -124,7 +125,7 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
 	struct svcxprt_rdma *cma_xprt;
 	struct svc_xprt *xprt;
 
-	cma_xprt = rdma_create_xprt(serv, 0);
+	cma_xprt = svc_rdma_create_xprt(serv, net);
 	if (!cma_xprt)
 		return ERR_PTR(-ENOMEM);
 	xprt = &cma_xprt->sc_xprt;
@@ -374,14 +375,16 @@ void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 	svc_xprt_put(&xprt->sc_xprt);
 }
 
-static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
-					     int listener)
+static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
+						 struct net *net)
 {
 	struct svcxprt_rdma *cma_xprt = kzalloc(sizeof *cma_xprt, GFP_KERNEL);
 
-	if (!cma_xprt)
+	if (!cma_xprt) {
+		dprintk("svcrdma: failed to create new transport\n");
 		return NULL;
-	svc_xprt_init(&init_net, &svc_rdma_class, &cma_xprt->sc_xprt, serv);
+	}
+	svc_xprt_init(net, &svc_rdma_class, &cma_xprt->sc_xprt, serv);
 	INIT_LIST_HEAD(&cma_xprt->sc_accept_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
@@ -402,11 +405,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	 */
 	set_bit(XPT_CONG_CTRL, &cma_xprt->sc_xprt.xpt_flags);
 
-	if (listener) {
-		strcpy(cma_xprt->sc_xprt.xpt_remotebuf, "listener");
-		set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
-	}
-
 	return cma_xprt;
 }
 
@@ -505,11 +503,10 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id,
 	struct sockaddr *sa;
 
 	/* Create a new transport */
-	newxprt = rdma_create_xprt(listen_xprt->sc_xprt.xpt_server, 0);
-	if (!newxprt) {
-		dprintk("svcrdma: failed to create new transport\n");
+	newxprt = svc_rdma_create_xprt(listen_xprt->sc_xprt.xpt_server,
+				       listen_xprt->sc_xprt.xpt_net);
+	if (!newxprt)
 		return;
-	}
 	newxprt->sc_cm_id = new_cma_id;
 	new_cma_id->context = newxprt;
 	dprintk("svcrdma: Creating newxprt=%p, cm_id=%p, listenxprt=%p\n",
@@ -635,16 +632,18 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	struct svcxprt_rdma *cma_xprt;
 	int ret;
 
-	dprintk("svcrdma: Creating RDMA socket\n");
+	dprintk("svcrdma: Creating RDMA listener\n");
 	if ((sa->sa_family != AF_INET) && (sa->sa_family != AF_INET6)) {
 		dprintk("svcrdma: Address family %d is not supported.\n", sa->sa_family);
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
-	cma_xprt = rdma_create_xprt(serv, 1);
+	cma_xprt = svc_rdma_create_xprt(serv, net);
 	if (!cma_xprt)
 		return ERR_PTR(-ENOMEM);
+	set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
+	strcpy(cma_xprt->sc_xprt.xpt_remotebuf, "listener");
 
-	listen_id = rdma_create_id(&init_net, rdma_listen_handler, cma_xprt,
+	listen_id = rdma_create_id(net, rdma_listen_handler, cma_xprt,
 				   RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(listen_id)) {
 		ret = PTR_ERR(listen_id);


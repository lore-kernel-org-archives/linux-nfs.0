Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:44874 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbbAMQCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:02:48 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 02/10] svcrdma: Remove unused variable
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 13 Jan 2015 11:02:45 -0500
Message-ID: <20150113160245.8118.24476.stgit@klimt.1015granger.net>
In-Reply-To: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
References: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nit: remove an unused variable to squelch a compiler warning.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4e61880..4ba11d0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -687,7 +687,6 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 {
 	struct rdma_cm_id *listen_id;
 	struct svcxprt_rdma *cma_xprt;
-	struct svc_xprt *xprt;
 	int ret;
 
 	dprintk("svcrdma: Creating RDMA socket\n");
@@ -698,7 +697,6 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	cma_xprt = rdma_create_xprt(serv, 1);
 	if (!cma_xprt)
 		return ERR_PTR(-ENOMEM);
-	xprt = &cma_xprt->sc_xprt;
 
 	listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP,
 				   IB_QPT_RC);


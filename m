Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35805 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbcAGTs5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2016 14:48:57 -0500
Subject: [PATCH v5 01/10] svcrdma: Clean up rdma_create_xprt()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, dledford@redhat.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2016 14:48:55 -0500
Message-ID: <20160107194855.2662.37386.stgit@klimt.1015granger.net>
In-Reply-To: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
References: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kzalloc is used here, so setting the atomic fields to zero is
unnecessary. sc_ord is set again in handle_connect_req. The other
fields are re-initialized in svc_rdma_accept().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Bruce Fields <bfields@fieldses.org>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4d695af..45d1824 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -529,14 +529,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
 	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
 
-	cma_xprt->sc_ord = svcrdma_ord;
-
-	cma_xprt->sc_max_req_size = svcrdma_max_req_size;
-	cma_xprt->sc_max_requests = svcrdma_max_requests;
-	cma_xprt->sc_sq_depth = svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT;
-	atomic_set(&cma_xprt->sc_sq_count, 0);
-	atomic_set(&cma_xprt->sc_ctxt_used, 0);
-
 	if (listener)
 		set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
 
@@ -918,6 +910,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 				  (size_t)RPCSVC_MAXPAGES);
 	newxprt->sc_max_sge_rd = min_t(size_t, dev->attrs.max_sge_rd,
 				       RPCSVC_MAXPAGES);
+	newxprt->sc_max_req_size = svcrdma_max_req_size;
 	newxprt->sc_max_requests = min((size_t)dev->attrs.max_qp_wr,
 				   (size_t)svcrdma_max_requests);
 	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:56553 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdJ0Otx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 10:49:53 -0400
Subject: [PATCH] svcrdma: Enqueue after setting XPT_CLOSE in completion
 handlers
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Oct 2017 10:49:51 -0400
Message-ID: <20171027144743.15444.3407.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed the server was sometimes not closing the connection after
a flushed Send. For example, if the client responds with an RNR NAK
to a Reply from the server, that client might be deadlocked, and
thus wouldn't send any more traffic. Thus the server wouldn't have
any opportunity to notice the XPT_CLOSE bit has been set.

Enqueue the transport so that svcxprt notices the bit even if there
is no more transport activity after a flushed completion, QP access
error, or device removal event.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

Hi Bruce-

Please consider this patch for v4.15. Thanks!


diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 5caf8e7..46ec069 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -290,6 +290,7 @@ static void qp_event_handler(struct ib_event *event, void *context)
 			ib_event_msg(event->event), event->event,
 			event->element.qp);
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
+		svc_xprt_enqueue(xprt);
 		break;
 	}
 }
@@ -322,8 +323,7 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 	set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
 	if (test_bit(RDMAXPRT_CONN_PENDING, &xprt->sc_flags))
 		goto out;
-	svc_xprt_enqueue(&xprt->sc_xprt);
-	goto out;
+	goto out_enqueue;
 
 flushed:
 	if (wc->status != IB_WC_WR_FLUSH_ERR)
@@ -333,6 +333,8 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 	set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
 	svc_rdma_put_context(ctxt, 1);
 
+out_enqueue:
+	svc_xprt_enqueue(&xprt->sc_xprt);
 out:
 	svc_xprt_put(&xprt->sc_xprt);
 }
@@ -358,6 +360,7 @@ void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 
 	if (unlikely(wc->status != IB_WC_SUCCESS)) {
 		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
+		svc_xprt_enqueue(&xprt->sc_xprt);
 		if (wc->status != IB_WC_WR_FLUSH_ERR)
 			pr_err("svcrdma: Send: %s (%u/0x%x)\n",
 			       ib_wc_status_msg(wc->status),
@@ -569,8 +572,10 @@ static int rdma_listen_handler(struct rdma_cm_id *cma_id,
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 		dprintk("svcrdma: Device removal xprt=%p, cm_id=%p\n",
 			xprt, cma_id);
-		if (xprt)
+		if (xprt) {
 			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
+			svc_xprt_enqueue(&xprt->sc_xprt);
+		}
 		break;
 
 	default:


From: Tom Tucker <tom@opengridcomputing.com>
Subject: SVCRDMA: Add refs to RDMA transport close path
Date: Thu, 06 Mar 2008 11:55:37 -0600
Message-ID: <1204826137.21546.9.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:51123 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751316AbYCFRpb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2008 12:45:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The close code was refactored so that transport close in error and close
are performed by the same code.
   
Additional transport references were added as follows:
- A reference when on the DTO Q to avoid having the transport
  deleted while queued for I/O.
- A reference while there is a QP able to generate events.
- A reference until the DISCONNECTED event is received on the CM ID

Finally, the QP and CQ event handler messages were changed to printk's to
make it easier for system administrators to diagnose RDMA transport
problems.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f09444c..8c9917c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -54,7 +54,6 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 					int flags);
 static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt);
 static void svc_rdma_release_rqst(struct svc_rqst *);
-static void rdma_destroy_xprt(struct svcxprt_rdma *xprt);
 static void dto_tasklet_func(unsigned long data);
 static void svc_rdma_detach(struct svc_xprt *xprt);
 static void svc_rdma_free(struct svc_xprt *xprt);
@@ -174,8 +173,9 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 static void cq_event_handler(struct ib_event *event, void *context)
 {
 	struct svc_xprt *xprt = context;
-	dprintk("svcrdma: received CQ event id=%d, context=%p\n",
-		event->event, context);
+	printk(KERN_INFO
+	       "svcrdma: received CQ event id=%d, context=%p\n",
+	       event->event, context);
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
 }
 
@@ -190,8 +190,9 @@ static void qp_event_handler(struct ib_event *event, void *context)
 	case IB_EVENT_COMM_EST:
 	case IB_EVENT_SQ_DRAINED:
 	case IB_EVENT_QP_LAST_WQE_REACHED:
-		dprintk("svcrdma: QP event %d received for QP=%p\n",
-			event->event, event->element.qp);
+		printk(KERN_INFO
+		       "svcrdma: QP event %d received for QP=%p\n",
+		       event->event, event->element.qp);
 		break;
 	/* These are considered fatal events */
 	case IB_EVENT_PATH_MIG_ERR:
@@ -200,9 +201,10 @@ static void qp_event_handler(struct ib_event *event, void *context)
 	case IB_EVENT_QP_ACCESS_ERR:
 	case IB_EVENT_DEVICE_FATAL:
 	default:
-		dprintk("svcrdma: QP ERROR event %d received for QP=%p, "
-			"closing transport\n",
-			event->event, event->element.qp);
+		printk(KERN_INFO
+		       "svcrdma: QP ERROR event %d received for QP=%p, "
+		       "closing transport\n",
+		       event->event, event->element.qp);
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
 		break;
 	}
@@ -247,6 +249,7 @@ static void dto_tasklet_func(unsigned long data)
 			sq_cq_reap(xprt);
 		}
 
+		svc_xprt_put(&xprt->sc_xprt);
 		spin_lock_irqsave(&dto_lock, flags);
 	}
 	spin_unlock_irqrestore(&dto_lock, flags);
@@ -275,8 +278,10 @@ static void rq_comp_handler(struct ib_cq *cq, void *cq_context)
 	 * add it
 	 */
 	spin_lock_irqsave(&dto_lock, flags);
-	if (list_empty(&xprt->sc_dto_q))
+	if (list_empty(&xprt->sc_dto_q)) {
+		svc_xprt_get(&xprt->sc_xprt);
 		list_add_tail(&xprt->sc_dto_q, &dto_xprt_q);
+	}
 	spin_unlock_irqrestore(&dto_lock, flags);
 
 	/* Tasklet does all the work to avoid irqsave locks. */
@@ -386,8 +391,10 @@ static void sq_comp_handler(struct ib_cq *cq, void *cq_context)
 	 * add it
 	 */
 	spin_lock_irqsave(&dto_lock, flags);
-	if (list_empty(&xprt->sc_dto_q))
+	if (list_empty(&xprt->sc_dto_q)) {
+		svc_xprt_get(&xprt->sc_xprt);
 		list_add_tail(&xprt->sc_dto_q, &dto_xprt_q);
+	}
 	spin_unlock_irqrestore(&dto_lock, flags);
 
 	/* Tasklet does all the work to avoid irqsave locks. */
@@ -611,6 +618,7 @@ static int rdma_cma_handler(struct rdma_cm_id *cma_id,
 	switch (event->event) {
 	case RDMA_CM_EVENT_ESTABLISHED:
 		/* Accept complete */
+		svc_xprt_get(xprt);
 		dprintk("svcrdma: Connection completed on DTO xprt=%p, "
 			"cm_id=%p\n", xprt, cma_id);
 		clear_bit(RDMAXPRT_CONN_PENDING, &rdma->sc_flags);
@@ -661,15 +669,15 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 
 	listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP);
 	if (IS_ERR(listen_id)) {
-		rdma_destroy_xprt(cma_xprt);
+		svc_xprt_put(&cma_xprt->sc_xprt);
 		dprintk("svcrdma: rdma_create_id failed = %ld\n",
 			PTR_ERR(listen_id));
 		return (void *)listen_id;
 	}
 	ret = rdma_bind_addr(listen_id, sa);
 	if (ret) {
-		rdma_destroy_xprt(cma_xprt);
 		rdma_destroy_id(listen_id);
+		svc_xprt_put(&cma_xprt->sc_xprt);
 		dprintk("svcrdma: rdma_bind_addr failed = %d\n", ret);
 		return ERR_PTR(ret);
 	}
@@ -678,8 +686,9 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 	ret = rdma_listen(listen_id, RPCRDMA_LISTEN_BACKLOG);
 	if (ret) {
 		rdma_destroy_id(listen_id);
-		rdma_destroy_xprt(cma_xprt);
+		svc_xprt_put(&cma_xprt->sc_xprt);
 		dprintk("svcrdma: rdma_listen failed = %d\n", ret);
+		return ret;
 	}
 
 	/*
@@ -820,6 +829,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		newxprt->sc_sq_depth = qp_attr.cap.max_send_wr;
 		newxprt->sc_max_requests = qp_attr.cap.max_recv_wr;
 	}
+	svc_xprt_get(&newxprt->sc_xprt);
 	newxprt->sc_qp = newxprt->sc_cm_id->qp;
 
 	/* Register all of physical memory */
@@ -891,8 +901,15 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
  errout:
 	dprintk("svcrdma: failure accepting new connection rc=%d.\n", ret);
+	/* Take a reference in case the DTO handler runs */
+	svc_xprt_get(&newxprt->sc_xprt);
+	if (newxprt->sc_qp && !IS_ERR(newxprt->sc_qp)) {
+		ib_destroy_qp(newxprt->sc_qp);
+		svc_xprt_put(&newxprt->sc_xprt);
+	}
 	rdma_destroy_id(newxprt->sc_cm_id);
-	rdma_destroy_xprt(newxprt);
+	/* This call to put will destroy the transport */
+	svc_xprt_put(&newxprt->sc_xprt);
 	return NULL;
 }
 
@@ -919,54 +936,60 @@ static void svc_rdma_release_rqst(struct svc_rqst *rqstp)
 	rqstp->rq_xprt_ctxt = NULL;
 }
 
-/* Disable data ready events for this connection */
+/*
+ * When connected, an svc_xprt has at least three references:
+ *
+ * - A reference held by the QP. We still hold that here because this
+ *   code deletes the QP and puts the reference.
+ *
+ * - A reference held by the cm_id between the ESTABLISHED and
+ *   DISCONNECTED events. If the remote peer disconnected first, this
+ *   reference could be gone.
+ *
+ * - A reference held by the svc_recv code that called this function
+ *   as part of close processing.
+ *
+ * At a minimum two references should still be held.
+ */
 static void svc_rdma_detach(struct svc_xprt *xprt)
 {
 	struct svcxprt_rdma *rdma =
 		container_of(xprt, struct svcxprt_rdma, sc_xprt);
-	unsigned long flags;
-
 	dprintk("svc: svc_rdma_detach(%p)\n", xprt);
-	/*
-	 * Shutdown the connection. This will ensure we don't get any
-	 * more events from the provider.
-	 */
+
+	/* Disconnect and flush posted WQE */
 	rdma_disconnect(rdma->sc_cm_id);
-	rdma_destroy_id(rdma->sc_cm_id);
 
-	/* We may already be on the DTO list */
-	spin_lock_irqsave(&dto_lock, flags);
-	if (!list_empty(&rdma->sc_dto_q))
-		list_del_init(&rdma->sc_dto_q);
-	spin_unlock_irqrestore(&dto_lock, flags);
+	/* Destroy the QP if present (not a listener) */
+	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp)) {
+		ib_destroy_qp(rdma->sc_qp);
+		svc_xprt_put(xprt);
+	}
+
+	/* Destroy the CM ID */
+	rdma_destroy_id(rdma->sc_cm_id);
 }
 
 static void svc_rdma_free(struct svc_xprt *xprt)
 {
 	struct svcxprt_rdma *rdma = (struct svcxprt_rdma *)xprt;
 	dprintk("svcrdma: svc_rdma_free(%p)\n", rdma);
-	rdma_destroy_xprt(rdma);
-	kfree(rdma);
-}
-
-static void rdma_destroy_xprt(struct svcxprt_rdma *xprt)
-{
-	if (xprt->sc_qp && !IS_ERR(xprt->sc_qp))
-		ib_destroy_qp(xprt->sc_qp);
-
-	if (xprt->sc_sq_cq && !IS_ERR(xprt->sc_sq_cq))
-		ib_destroy_cq(xprt->sc_sq_cq);
+	/* We should only be called from kref_put */
+	BUG_ON(atomic_read(&xprt->xpt_ref.refcount) != 0);
+	if (rdma->sc_sq_cq && !IS_ERR(rdma->sc_sq_cq))
+		ib_destroy_cq(rdma->sc_sq_cq);
 
-	if (xprt->sc_rq_cq && !IS_ERR(xprt->sc_rq_cq))
-		ib_destroy_cq(xprt->sc_rq_cq);
+	if (rdma->sc_rq_cq && !IS_ERR(rdma->sc_rq_cq))
+		ib_destroy_cq(rdma->sc_rq_cq);
 
-	if (xprt->sc_phys_mr && !IS_ERR(xprt->sc_phys_mr))
-		ib_dereg_mr(xprt->sc_phys_mr);
+	if (rdma->sc_phys_mr && !IS_ERR(rdma->sc_phys_mr))
+		ib_dereg_mr(rdma->sc_phys_mr);
 
-	if (xprt->sc_pd && !IS_ERR(xprt->sc_pd))
-		ib_dealloc_pd(xprt->sc_pd);
+	if (rdma->sc_pd && !IS_ERR(rdma->sc_pd))
+		ib_dealloc_pd(rdma->sc_pd);
 
-	destroy_context_cache(xprt->sc_ctxt_head);
+	destroy_context_cache(rdma->sc_ctxt_head);
+	kfree(rdma);
 }
 
 static int svc_rdma_has_wspace(struct svc_xprt *xprt)


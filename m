Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33361 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752765AbdDKRXM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Apr 2017 13:23:12 -0400
Subject: [PATCH v3 06/13] xprtrdma: Support unplugging an HCA from under an
 NFS mount
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 11 Apr 2017 13:23:10 -0400
Message-ID: <20170411172310.11300.29973.stgit@manet.1015granger.net>
In-Reply-To: <20170411171820.11300.55637.stgit@manet.1015granger.net>
References: <20170411171820.11300.55637.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The device driver for the underlying physical device associated
with an RPC-over-RDMA transport can be removed while RPC-over-RDMA
transports are still in use (ie, while NFS filesystems are still
mounted and active). The IB core performs a connection event upcall
to request that consumers free all RDMA resources associated with
a transport.

There may be pending RPCs when this occurs. Care must be taken to
release associated resources without leaving references that can
trigger a subsequent crash if a signal or soft timeout occurs. We
rely on the caller of the transport's ->close method to ensure that
the previous RPC task has invoked xprt_release but the transport
remains write-locked.

A DEVICE_REMOVE upcall forces a disconnect then sleeps. When ->close
is invoked, it destroys the transport's H/W resources, then wakes
the upcall, which completes and allows the core driver unload to
continue.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=266
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   29 +++++++++++++--
 net/sunrpc/xprtrdma/verbs.c     |   74 +++++++++++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    7 ++++
 3 files changed, 101 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 83e219d..62ecbcc 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -457,19 +457,33 @@
 	return ERR_PTR(rc);
 }
 
-/*
- * Close a connection, during shutdown or timeout/reconnect
+/**
+ * xprt_rdma_close - Close down RDMA connection
+ * @xprt: generic transport to be closed
+ *
+ * Called during transport shutdown reconnect, or device
+ * removal. Caller holds the transport's write lock.
  */
 static void
 xprt_rdma_close(struct rpc_xprt *xprt)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+
+	dprintk("RPC:       %s: closing xprt %p\n", __func__, xprt);
 
-	dprintk("RPC:       %s: closing\n", __func__);
-	if (r_xprt->rx_ep.rep_connected > 0)
+	if (test_and_clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
+		xprt_clear_connected(xprt);
+		rpcrdma_ia_remove(ia);
+		return;
+	}
+	if (ep->rep_connected == -ENODEV)
+		return;
+	if (ep->rep_connected > 0)
 		xprt->reestablish_timeout = 0;
 	xprt_disconnect_done(xprt);
-	rpcrdma_ep_disconnect(&r_xprt->rx_ep, &r_xprt->rx_ia);
+	rpcrdma_ep_disconnect(ep, ia);
 }
 
 static void
@@ -680,6 +694,8 @@
  * xprt_rdma_send_request - marshal and send an RPC request
  * @task: RPC task with an RPC message in rq_snd_buf
  *
+ * Caller holds the transport's write lock.
+ *
  * Return values:
  *        0:	The request has been sent
  * ENOTCONN:	Caller needs to invoke connect logic then call again
@@ -706,6 +722,9 @@
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	int rc = 0;
 
+	if (!xprt_connected(xprt))
+		goto drop_connection;
+
 	/* On retransmit, remove any previously registered chunks */
 	if (unlikely(!list_empty(&req->rl_registered)))
 		r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c8813fb..938fd9e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -69,6 +69,8 @@
 /*
  * internal functions
  */
+static void rpcrdma_destroy_mrs(struct rpcrdma_buffer *buf);
+static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
 
 static struct workqueue_struct *rpcrdma_receive_wq;
 
@@ -262,6 +264,21 @@
 			__func__, ep);
 		complete(&ia->ri_done);
 		break;
+	case RDMA_CM_EVENT_DEVICE_REMOVAL:
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+		pr_info("rpcrdma: removing device for %pIS:%u\n",
+			sap, rpc_get_port(sap));
+#endif
+		set_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags);
+		ep->rep_connected = -ENODEV;
+		xprt_force_disconnect(&xprt->rx_xprt);
+		wait_for_completion(&ia->ri_remove_done);
+
+		ia->ri_id = NULL;
+		ia->ri_pd = NULL;
+		ia->ri_device = NULL;
+		/* Return 1 to ensure the core destroys the id. */
+		return 1;
 	case RDMA_CM_EVENT_ESTABLISHED:
 		connstate = 1;
 		ib_query_qp(ia->ri_id->qp, attr,
@@ -291,9 +308,6 @@
 		goto connected;
 	case RDMA_CM_EVENT_DISCONNECTED:
 		connstate = -ECONNABORTED;
-		goto connected;
-	case RDMA_CM_EVENT_DEVICE_REMOVAL:
-		connstate = -ENODEV;
 connected:
 		dprintk("RPC:       %s: %sconnected\n",
 					__func__, connstate > 0 ? "" : "dis");
@@ -346,6 +360,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	int rc;
 
 	init_completion(&ia->ri_done);
+	init_completion(&ia->ri_remove_done);
 
 	id = rdma_create_id(&init_net, rpcrdma_conn_upcall, xprt, RDMA_PS_TCP,
 			    IB_QPT_RC);
@@ -469,6 +484,56 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 }
 
 /**
+ * rpcrdma_ia_remove - Handle device driver unload
+ * @ia: interface adapter being removed
+ *
+ * Divest transport H/W resources associated with this adapter,
+ * but allow it to be restored later.
+ */
+void
+rpcrdma_ia_remove(struct rpcrdma_ia *ia)
+{
+	struct rpcrdma_xprt *r_xprt = container_of(ia, struct rpcrdma_xprt,
+						   rx_ia);
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_req *req;
+	struct rpcrdma_rep *rep;
+
+	cancel_delayed_work_sync(&buf->rb_refresh_worker);
+
+	/* This is similar to rpcrdma_ep_destroy, but:
+	 * - Don't cancel the connect worker.
+	 * - Don't call rpcrdma_ep_disconnect, which waits
+	 *   for another conn upcall, which will deadlock.
+	 * - rdma_disconnect is unneeded, the underlying
+	 *   connection is already gone.
+	 */
+	if (ia->ri_id->qp) {
+		ib_drain_qp(ia->ri_id->qp);
+		rdma_destroy_qp(ia->ri_id);
+		ia->ri_id->qp = NULL;
+	}
+	ib_free_cq(ep->rep_attr.recv_cq);
+	ib_free_cq(ep->rep_attr.send_cq);
+
+	/* The ULP is responsible for ensuring all DMA
+	 * mappings and MRs are gone.
+	 */
+	list_for_each_entry(rep, &buf->rb_recv_bufs, rr_list)
+		rpcrdma_dma_unmap_regbuf(rep->rr_rdmabuf);
+	list_for_each_entry(req, &buf->rb_allreqs, rl_all) {
+		rpcrdma_dma_unmap_regbuf(req->rl_rdmabuf);
+		rpcrdma_dma_unmap_regbuf(req->rl_sendbuf);
+		rpcrdma_dma_unmap_regbuf(req->rl_recvbuf);
+	}
+	rpcrdma_destroy_mrs(buf);
+
+	/* Allow waiters to continue */
+	complete(&ia->ri_remove_done);
+}
+
+/**
  * rpcrdma_ia_close - Clean up/close an IA.
  * @ia: interface adapter to close
  *
@@ -1080,7 +1145,8 @@ struct rpcrdma_mw *
 
 out_nomws:
 	dprintk("RPC:       %s: no MWs available\n", __func__);
-	schedule_delayed_work(&buf->rb_refresh_worker, 0);
+	if (r_xprt->rx_ep.rep_connected != -ENODEV)
+		schedule_delayed_work(&buf->rb_refresh_worker, 0);
 
 	/* Allow the reply handler and refresh worker to run */
 	cond_resched();
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 9d58260..1c5de1a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -69,6 +69,7 @@ struct rpcrdma_ia {
 	struct rdma_cm_id 	*ri_id;
 	struct ib_pd		*ri_pd;
 	struct completion	ri_done;
+	struct completion	ri_remove_done;
 	int			ri_async_rc;
 	unsigned int		ri_max_segs;
 	unsigned int		ri_max_frmr_depth;
@@ -78,10 +79,15 @@ struct rpcrdma_ia {
 	bool			ri_reminv_expected;
 	bool			ri_implicit_roundup;
 	enum ib_mr_type		ri_mrtype;
+	unsigned long		ri_flags;
 	struct ib_qp_attr	ri_qp_attr;
 	struct ib_qp_init_attr	ri_qp_init_attr;
 };
 
+enum {
+	RPCRDMA_IAF_REMOVING = 0,
+};
+
 /*
  * RDMA Endpoint -- one per transport instance
  */
@@ -511,6 +517,7 @@ struct rpcrdma_xprt {
  * Interface Adapter calls - xprtrdma/verbs.c
  */
 int rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr);
+void rpcrdma_ia_remove(struct rpcrdma_ia *ia);
 void rpcrdma_ia_close(struct rpcrdma_ia *);
 bool frwr_is_supported(struct rpcrdma_ia *);
 bool fmr_is_supported(struct rpcrdma_ia *);


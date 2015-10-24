Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36790 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131AbbJXV1M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 17:27:12 -0400
Subject: [PATCH v4 06/16] xprtrdma: Use workqueue to process RPC/RDMA replies
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 24 Oct 2015 17:27:10 -0400
Message-ID: <20151024212710.4715.40751.stgit@manet.1015granger.net>
In-Reply-To: <20151024211707.4715.61650.stgit@manet.1015granger.net>
References: <20151024211707.4715.61650.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The reply tasklet is fast, but it's single threaded. After reply
traffic saturates a single CPU, there's no more reply processing
capacity.

Replace the tasklet with a workqueue to spread reply handling across
all CPUs.  This also moves RPC/RDMA reply handling out of the soft
IRQ context and into a context that allows sleeps.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   17 +++++++-----
 net/sunrpc/xprtrdma/transport.c |    8 ++++++
 net/sunrpc/xprtrdma/verbs.c     |   54 ++++++++++++++++++++++++++++++++-------
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 +++
 4 files changed, 65 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 60ffa63..95774fc 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -723,8 +723,8 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
 	schedule_delayed_work(&ep->rep_connect_worker, 0);
 }
 
-/*
- * Called as a tasklet to do req/reply match and complete a request
+/* Process received RPC/RDMA messages.
+ *
  * Errors must result in the RPC task either being awakened, or
  * allowed to timeout, to discover the errors at that time.
  */
@@ -752,13 +752,14 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	if (headerp->rm_vers != rpcrdma_version)
 		goto out_badversion;
 
-	/* Get XID and try for a match. */
-	spin_lock(&xprt->transport_lock);
+	/* Match incoming rpcrdma_rep to an rpcrdma_req to
+	 * get context for handling any incoming chunks.
+	 */
+	spin_lock_bh(&xprt->transport_lock);
 	rqst = xprt_lookup_rqst(xprt, headerp->rm_xid);
 	if (!rqst)
 		goto out_nomatch;
 
-	/* get request object */
 	req = rpcr_to_rdmar(rqst);
 	if (req->rl_reply)
 		goto out_duplicate;
@@ -859,7 +860,7 @@ badheader:
 		xprt_release_rqst_cong(rqst->rq_task);
 
 	xprt_complete_rqst(rqst->rq_task, status);
-	spin_unlock(&xprt->transport_lock);
+	spin_unlock_bh(&xprt->transport_lock);
 	dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
 			__func__, xprt, rqst, status);
 	return;
@@ -882,14 +883,14 @@ out_badversion:
 	goto repost;
 
 out_nomatch:
-	spin_unlock(&xprt->transport_lock);
+	spin_unlock_bh(&xprt->transport_lock);
 	dprintk("RPC:       %s: no match for incoming xid 0x%08x len %d\n",
 		__func__, be32_to_cpu(headerp->rm_xid),
 		rep->rr_len);
 	goto repost;
 
 out_duplicate:
-	spin_unlock(&xprt->transport_lock);
+	spin_unlock_bh(&xprt->transport_lock);
 	dprintk("RPC:       %s: "
 		"duplicate reply %p to RPC request %p: xid 0x%08x\n",
 		__func__, rep, req, be32_to_cpu(headerp->rm_xid));
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index e9e5ed7..897a2f3 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -732,6 +732,7 @@ void xprt_rdma_cleanup(void)
 		dprintk("RPC:       %s: xprt_unregister returned %i\n",
 			__func__, rc);
 
+	rpcrdma_destroy_wq();
 	frwr_destroy_recovery_wq();
 }
 
@@ -743,8 +744,15 @@ int xprt_rdma_init(void)
 	if (rc)
 		return rc;
 
+	rc = rpcrdma_alloc_wq();
+	if (rc) {
+		frwr_destroy_recovery_wq();
+		return rc;
+	}
+
 	rc = xprt_register_transport(&xprt_rdma);
 	if (rc) {
+		rpcrdma_destroy_wq();
 		frwr_destroy_recovery_wq();
 		return rc;
 	}
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c09f1b6..5c20629 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -100,6 +100,35 @@ rpcrdma_run_tasklet(unsigned long data)
 
 static DECLARE_TASKLET(rpcrdma_tasklet_g, rpcrdma_run_tasklet, 0UL);
 
+static struct workqueue_struct *rpcrdma_receive_wq;
+
+int
+rpcrdma_alloc_wq(void)
+{
+	struct workqueue_struct *recv_wq;
+
+	recv_wq = alloc_workqueue("xprtrdma_receive",
+				  WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_HIGHPRI,
+				  0);
+	if (!recv_wq)
+		return -ENOMEM;
+
+	rpcrdma_receive_wq = recv_wq;
+	return 0;
+}
+
+void
+rpcrdma_destroy_wq(void)
+{
+	struct workqueue_struct *wq;
+
+	if (rpcrdma_receive_wq) {
+		wq = rpcrdma_receive_wq;
+		rpcrdma_receive_wq = NULL;
+		destroy_workqueue(wq);
+	}
+}
+
 static void
 rpcrdma_schedule_tasklet(struct list_head *sched_list)
 {
@@ -196,7 +225,16 @@ rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
 }
 
 static void
-rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
+rpcrdma_receive_worker(struct work_struct *work)
+{
+	struct rpcrdma_rep *rep =
+			container_of(work, struct rpcrdma_rep, rr_work);
+
+	rpcrdma_reply_handler(rep);
+}
+
+static void
+rpcrdma_recvcq_process_wc(struct ib_wc *wc)
 {
 	struct rpcrdma_rep *rep =
 			(struct rpcrdma_rep *)(unsigned long)wc->wr_id;
@@ -219,8 +257,9 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 	prefetch(rdmab_to_msg(rep->rr_rdmabuf));
 
 out_schedule:
-	list_add_tail(&rep->rr_list, sched_list);
+	queue_work(rpcrdma_receive_wq, &rep->rr_work);
 	return;
+
 out_fail:
 	if (wc->status != IB_WC_WR_FLUSH_ERR)
 		pr_err("RPC:       %s: rep %p: %s\n",
@@ -239,7 +278,6 @@ static void
 rpcrdma_recvcq_poll(struct ib_cq *cq)
 {
 	struct ib_wc *pos, wcs[4];
-	LIST_HEAD(sched_list);
 	int count, rc;
 
 	do {
@@ -251,10 +289,8 @@ rpcrdma_recvcq_poll(struct ib_cq *cq)
 
 		count = rc;
 		while (count-- > 0)
-			rpcrdma_recvcq_process_wc(pos++, &sched_list);
+			rpcrdma_recvcq_process_wc(pos++);
 	} while (rc == ARRAY_SIZE(wcs));
-
-	rpcrdma_schedule_tasklet(&sched_list);
 }
 
 /* Handle provider receive completion upcalls.
@@ -272,12 +308,9 @@ static void
 rpcrdma_flush_cqs(struct rpcrdma_ep *ep)
 {
 	struct ib_wc wc;
-	LIST_HEAD(sched_list);
 
 	while (ib_poll_cq(ep->rep_attr.recv_cq, 1, &wc) > 0)
-		rpcrdma_recvcq_process_wc(&wc, &sched_list);
-	if (!list_empty(&sched_list))
-		rpcrdma_schedule_tasklet(&sched_list);
+		rpcrdma_recvcq_process_wc(&wc);
 	while (ib_poll_cq(ep->rep_attr.send_cq, 1, &wc) > 0)
 		rpcrdma_sendcq_process_wc(&wc);
 }
@@ -913,6 +946,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 
 	rep->rr_device = ia->ri_device;
 	rep->rr_rxprt = r_xprt;
+	INIT_WORK(&rep->rr_work, rpcrdma_receive_worker);
 	return rep;
 
 out_free:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index e6a358f..6ea1dbe 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -164,6 +164,7 @@ struct rpcrdma_rep {
 	unsigned int		rr_len;
 	struct ib_device	*rr_device;
 	struct rpcrdma_xprt	*rr_rxprt;
+	struct work_struct	rr_work;
 	struct list_head	rr_list;
 	struct rpcrdma_regbuf	*rr_rdmabuf;
 };
@@ -430,6 +431,9 @@ unsigned int rpcrdma_max_segments(struct rpcrdma_xprt *);
 int frwr_alloc_recovery_wq(void);
 void frwr_destroy_recovery_wq(void);
 
+int rpcrdma_alloc_wq(void);
+void rpcrdma_destroy_wq(void);
+
 /*
  * Wrappers for chunk registration, shared by read/write chunk code.
  */


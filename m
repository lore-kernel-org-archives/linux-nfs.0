Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:35872 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171AbbJPNY0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 09:24:26 -0400
Subject: [PATCH v3 03/16] xprtrdma: Prevent loss of completion signals
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Oct 2015 09:24:25 -0400
Message-ID: <20151016132424.6819.3130.stgit@oracle-122.nfsv4bat.org>
In-Reply-To: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
References: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 8301a2c047cc ("xprtrdma: Limit work done by completion
handler") was supposed to prevent xprtrdma's upcall handlers from
starving other softIRQ work by letting them return to the provider
before all CQEs have been polled.

The logic assumes the provider will call the upcall handler again
immediately if the CQ is re-armed while there are still queued CQEs.

This assumption is invalid. The IBTA spec says that after a CQ is
armed, the hardware must interrupt only when a new CQE is inserted.
xprtrdma can't rely on the provider calling again, even though some
providers do.

Therefore, leaving CQEs on queue makes sense only when there is
another mechanism that ensures all remaining CQEs are consumed in a
timely fashion. xprtrdma does not have such a mechanism. If a CQE
remains queued, the transport can wait forever to send the next RPC.

Finally, move the wcs array back onto the stack to ensure that the
poll array is always local to the CPU where the completion upcall is
running.

Fixes: 8301a2c047cc ("xprtrdma: Limit work done by completion ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   74 ++++++++++++++++++++-------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 ---
 2 files changed, 38 insertions(+), 41 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c713909..e9599e9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -158,25 +158,30 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 	}
 }
 
-static int
-rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
+/* The common case is a single send completion is waiting. By
+ * passing two WC entries to ib_poll_cq, a return code of 1
+ * means there is exactly one WC waiting and no more. We don't
+ * have to invoke ib_poll_cq again to know that the CQ has been
+ * properly drained.
+ */
+static void
+rpcrdma_sendcq_poll(struct ib_cq *cq)
 {
-	struct ib_wc *wcs;
-	int budget, count, rc;
+	struct ib_wc *pos, wcs[2];
+	int count, rc;
 
-	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
 	do {
-		wcs = ep->rep_send_wcs;
+		pos = wcs;
 
-		rc = ib_poll_cq(cq, RPCRDMA_POLLSIZE, wcs);
-		if (rc <= 0)
-			return rc;
+		rc = ib_poll_cq(cq, ARRAY_SIZE(wcs), pos);
+		if (rc < 0)
+			break;
 
 		count = rc;
 		while (count-- > 0)
-			rpcrdma_sendcq_process_wc(wcs++);
-	} while (rc == RPCRDMA_POLLSIZE && --budget);
-	return 0;
+			rpcrdma_sendcq_process_wc(pos++);
+	} while (rc == ARRAY_SIZE(wcs));
+	return;
 }
 
 /* Handle provider send completion upcalls.
@@ -184,10 +189,8 @@ rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 static void
 rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
 {
-	struct rpcrdma_ep *ep = (struct rpcrdma_ep *)cq_context;
-
 	do {
-		rpcrdma_sendcq_poll(cq, ep);
+		rpcrdma_sendcq_poll(cq);
 	} while (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
 				  IB_CQ_REPORT_MISSED_EVENTS) > 0);
 }
@@ -226,31 +229,32 @@ out_fail:
 	goto out_schedule;
 }
 
-static int
-rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
+/* The wc array is on stack: automatic memory is always CPU-local.
+ *
+ * struct ib_wc is 64 bytes, making the poll array potentially
+ * large. But this is at the bottom of the call chain. Further
+ * substantial work is done in another thread.
+ */
+static void
+rpcrdma_recvcq_poll(struct ib_cq *cq)
 {
-	struct list_head sched_list;
-	struct ib_wc *wcs;
-	int budget, count, rc;
+	struct ib_wc *pos, wcs[4];
+	LIST_HEAD(sched_list);
+	int count, rc;
 
-	INIT_LIST_HEAD(&sched_list);
-	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
 	do {
-		wcs = ep->rep_recv_wcs;
+		pos = wcs;
 
-		rc = ib_poll_cq(cq, RPCRDMA_POLLSIZE, wcs);
-		if (rc <= 0)
-			goto out_schedule;
+		rc = ib_poll_cq(cq, ARRAY_SIZE(wcs), pos);
+		if (rc < 0)
+			break;
 
 		count = rc;
 		while (count-- > 0)
-			rpcrdma_recvcq_process_wc(wcs++, &sched_list);
-	} while (rc == RPCRDMA_POLLSIZE && --budget);
-	rc = 0;
+			rpcrdma_recvcq_process_wc(pos++, &sched_list);
+	} while (rc == ARRAY_SIZE(wcs));
 
-out_schedule:
 	rpcrdma_schedule_tasklet(&sched_list);
-	return rc;
 }
 
 /* Handle provider receive completion upcalls.
@@ -258,10 +262,8 @@ out_schedule:
 static void
 rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
 {
-	struct rpcrdma_ep *ep = (struct rpcrdma_ep *)cq_context;
-
 	do {
-		rpcrdma_recvcq_poll(cq, ep);
+		rpcrdma_recvcq_poll(cq);
 	} while (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
 				  IB_CQ_REPORT_MISSED_EVENTS) > 0);
 }
@@ -625,7 +627,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	cq_attr.cqe = ep->rep_attr.cap.max_send_wr + 1;
 	sendcq = ib_create_cq(ia->ri_device, rpcrdma_sendcq_upcall,
-			      rpcrdma_cq_async_error_upcall, ep, &cq_attr);
+			      rpcrdma_cq_async_error_upcall, NULL, &cq_attr);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
@@ -642,7 +644,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	cq_attr.cqe = ep->rep_attr.cap.max_recv_wr + 1;
 	recvcq = ib_create_cq(ia->ri_device, rpcrdma_recvcq_upcall,
-			      rpcrdma_cq_async_error_upcall, ep, &cq_attr);
+			      rpcrdma_cq_async_error_upcall, NULL, &cq_attr);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
 		dprintk("RPC:       %s: failed to create recv CQ: %i\n",
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c09414e..42c8d44 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -77,9 +77,6 @@ struct rpcrdma_ia {
  * RDMA Endpoint -- one per transport instance
  */
 
-#define RPCRDMA_WC_BUDGET	(128)
-#define RPCRDMA_POLLSIZE	(16)
-
 struct rpcrdma_ep {
 	atomic_t		rep_cqcount;
 	int			rep_cqinit;
@@ -89,8 +86,6 @@ struct rpcrdma_ep {
 	struct rdma_conn_param	rep_remote_cma;
 	struct sockaddr_storage	rep_remote_addr;
 	struct delayed_work	rep_connect_worker;
-	struct ib_wc		rep_send_wcs[RPCRDMA_POLLSIZE];
-	struct ib_wc		rep_recv_wcs[RPCRDMA_POLLSIZE];
 };
 
 /*


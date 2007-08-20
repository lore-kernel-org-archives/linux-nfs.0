From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 05/10] rdma: SVCRDMA Core Transport Services
Date: Mon, 20 Aug 2007 11:58:11 -0500
Message-ID: <20070820165811.15938.9769.stgit@dell3.ogc.int>
References: <20070820165635.15938.57184.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INAa0-00020N-6D
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:16 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INAa1-0003Il-UD
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:20 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id ED9D67C79B
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:58:11 -0500 (CDT)
In-Reply-To: <20070820165635.15938.57184.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


This file implements the core transport data management and I/O
path. The I/O path for RDMA involves receiving callbacks on interrupt
context. Since all the svc transport locks are _bh locks we enqueue the
transport on a list, schedule a tasklet to dequeue data indications from
the RDMA completion queue. The tasklet in turn takes _bh locks to
enqueue receive data indications on a list for the transport. The
svc_rdma_recvfrom transport function dequeues data from this list in an
NFSD thread context.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_rdma_transport.c | 1207 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/svcauth_unix.c       |    3 
 2 files changed, 1208 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_rdma_transport.c b/net/sunrpc/svc_rdma_transport.c
new file mode 100644
index 0000000..3f1f251
--- /dev/null
+++ b/net/sunrpc/svc_rdma_transport.c
@@ -0,0 +1,1207 @@
+/*
+ * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the BSD-type
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *      Redistributions of source code must retain the above copyright
+ *      notice, this list of conditions and the following disclaimer.
+ *
+ *      Redistributions in binary form must reproduce the above
+ *      copyright notice, this list of conditions and the following
+ *      disclaimer in the documentation and/or other materials provided
+ *      with the distribution.
+ *
+ *      Neither the name of the Network Appliance, Inc. nor the names of
+ *      its contributors may be used to endorse or promote products
+ *      derived from this software without specific prior written
+ *      permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Author: Tom Tucker <tom@opengridcomputing.com>
+ */
+
+#include <asm/semaphore.h>
+#include <linux/device.h>
+#include <linux/in.h>
+#include <linux/err.h>
+#include <linux/time.h>
+#include <linux/delay.h>
+
+#include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/debug.h>
+#include <linux/sunrpc/rpc_rdma.h>
+#include <linux/mm.h>		/* num_physpages */
+#include <linux/spinlock.h>
+#include <linux/net.h>
+#include <net/sock.h>
+#include <asm/io.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/rdma_cm.h>
+#include <net/ipv6.h>
+#include <linux/sunrpc/svc_rdma.h>
+
+#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
+
+int svc_rdma_create_svc(struct svc_serv *serv, struct sockaddr *sa, int flags);
+static int svc_rdma_accept(struct svc_sock *xprt);
+static void rdma_destroy_xprt(struct svcxprt_rdma *xprt);
+static void dto_tasklet_func(unsigned long data);
+static struct cache_deferred_req *svc_rdma_defer(struct cache_req *req);
+static void svc_rdma_detach(struct svc_sock *svsk);
+static void svc_rdma_free(struct svc_sock *svsk);
+static int svc_rdma_has_wspace(struct svc_sock *svsk);
+static int svc_rdma_get_name(char *buf, struct svc_sock *svsk);
+
+static void rq_cq_reap(struct svcxprt_rdma *xprt);
+static void sq_cq_reap(struct svcxprt_rdma *xprt);
+
+DECLARE_TASKLET(dto_tasklet, dto_tasklet_func, 0UL);
+static spinlock_t dto_lock = SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(dto_xprt_q);
+
+struct svc_xprt svc_rdma_xprt = {
+	.xpt_name = "rdma",
+	.xpt_owner = THIS_MODULE,
+	.xpt_create_svc = svc_rdma_create_svc,
+	.xpt_get_name = svc_rdma_get_name,
+	.xpt_recvfrom = svc_rdma_recvfrom,
+	.xpt_sendto = svc_rdma_sendto,
+	.xpt_detach = svc_rdma_detach,
+	.xpt_free = svc_rdma_free,
+	.xpt_has_wspace = svc_rdma_has_wspace,
+	.xpt_max_payload = RPCSVC_MAXPAYLOAD_TCP,
+	.xpt_accept = svc_rdma_accept,
+	.xpt_defer = svc_rdma_defer
+};
+
+static int rdma_bump_context_cache(struct svcxprt_rdma *xprt)
+{
+	int target;
+	int at_least_one = 0;
+	struct svc_rdma_op_ctxt *ctxt;
+
+	target = min(xprt->sc_ctxt_cnt + xprt->sc_ctxt_bump,
+		     xprt->sc_ctxt_max);
+
+	spin_lock_bh(&xprt->sc_ctxt_lock);
+	while (xprt->sc_ctxt_cnt < target) {
+		xprt->sc_ctxt_cnt ++;
+		spin_unlock_bh(&xprt->sc_ctxt_lock);
+
+		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
+
+		spin_lock_bh(&xprt->sc_ctxt_lock);
+		if (ctxt) {
+			at_least_one = 1;
+			ctxt->next = xprt->sc_ctxt_head;
+			xprt->sc_ctxt_head = ctxt;
+		} else {
+			/* kmalloc failed...give up for now */
+			xprt->sc_ctxt_cnt --;
+			break;
+		}
+	}
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	dprintk("svcrdma: sc_ctxt_max=%d, sc_ctxt_cnt=%d\n", 
+		xprt->sc_ctxt_max,xprt->sc_ctxt_cnt);
+	return at_least_one;
+}
+
+struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
+{
+	struct svc_rdma_op_ctxt *ctxt;
+
+	while (1) {
+		spin_lock_bh(&xprt->sc_ctxt_lock);
+		if (unlikely(xprt->sc_ctxt_head == NULL)) {
+			/* Try to bump my cache. */
+			spin_unlock_bh(&xprt->sc_ctxt_lock);
+
+			if (rdma_bump_context_cache(xprt))
+				continue;
+
+			printk(KERN_INFO "svcrdma: sleeping waiting for context "
+			       "memory on xprt=%p\n",
+			       xprt);
+			schedule_timeout_uninterruptible(msecs_to_jiffies(500));
+			continue;
+		}
+		ctxt = xprt->sc_ctxt_head;
+		xprt->sc_ctxt_head = ctxt->next;
+		spin_unlock_bh(&xprt->sc_ctxt_lock);
+		ctxt->xprt = xprt;
+		INIT_LIST_HEAD(&ctxt->dto_q);
+		ctxt->count = 0;
+		break;
+	}
+	return ctxt;
+}
+
+void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
+{
+	struct svcxprt_rdma *xprt;
+	int i;
+
+	BUG_ON(!ctxt);
+	xprt = ctxt->xprt;
+	if (free_pages) {
+		for (i=0; i < ctxt->count; i++)
+			put_page(ctxt->pages[i]);
+	}
+
+	for (i=0; i < ctxt->count; i++) {
+		dma_unmap_single(xprt->sc_cm_id->device->dma_device,
+				 ctxt->sge[i].addr,
+				 ctxt->sge[i].length,
+				 ctxt->direction);
+	}
+	spin_lock_bh(&xprt->sc_ctxt_lock);
+	ctxt->next = xprt->sc_ctxt_head;
+	xprt->sc_ctxt_head = ctxt;
+	spin_unlock_bh(&xprt->sc_ctxt_lock);
+}
+
+/* ib_cq event handler */
+static void cq_event_handler(struct ib_event *event, void *context)
+{
+	struct svcxprt_rdma *xprt = (struct svcxprt_rdma *)context;
+	printk(KERN_INFO "svcrdma: received CQ event id=%d, context=%p\n",
+	       event->event, context);
+	set_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags);
+}
+
+/* QP event handler */
+static void qp_event_handler(struct ib_event *event, void *context)
+{
+	struct svcxprt_rdma *xprt = context;
+
+        switch (event->event) {
+        /* These are considered benign events */
+        case IB_EVENT_PATH_MIG:
+        case IB_EVENT_COMM_EST:
+        case IB_EVENT_SQ_DRAINED:
+        case IB_EVENT_QP_LAST_WQE_REACHED:
+                printk(KERN_INFO "svcrdma: QP event %d received for QP=%p\n",
+                       event->event, event->element.qp);
+                break;
+        /* These are considered fatal events */
+        case IB_EVENT_PATH_MIG_ERR:
+        case IB_EVENT_QP_FATAL:
+        case IB_EVENT_QP_REQ_ERR:
+        case IB_EVENT_QP_ACCESS_ERR:
+        case IB_EVENT_DEVICE_FATAL:
+        default:
+                printk(KERN_ERR "svcrdma: QP ERROR event %d received for QP=%p, "
+		       "closing transport\n",
+                       event->event, event->element.qp);
+                set_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags);
+                break;
+        }
+}
+
+/*
+ * Data Transfer Operation Tasklet
+ *
+ * Walks a list of transports with I/O pending, removing entries as
+ * they are added to the server's I/O pending list. Two bits indicate
+ * if SQ, RQ, or both have I/O pending. The dto_lock is an irqsave
+ * spinlock that serializes access to the transport list with the RQ
+ * and SQ interrupt handlers.
+ */
+static void dto_tasklet_func(unsigned long data)
+{
+	struct svcxprt_rdma *xprt;
+	unsigned long flags;
+
+	spin_lock_irqsave(&dto_lock, flags);
+	while (!list_empty(&dto_xprt_q)) {
+		xprt = list_entry(dto_xprt_q.next, struct svcxprt_rdma, sc_dto_q);
+		list_del_init(&xprt->sc_dto_q);
+		spin_unlock_irqrestore(&dto_lock, flags);
+
+		if (test_and_clear_bit(RDMAXPRT_RQ_PENDING, &xprt->sc_flags)) {
+			ib_req_notify_cq(xprt->sc_rq_cq, IB_CQ_NEXT_COMP);
+			rq_cq_reap(xprt);
+			set_bit(SK_DATA, &xprt->sc_xprt.sk_flags);
+			svc_sock_enqueue(&xprt->sc_xprt);
+		}
+
+		if (test_and_clear_bit(RDMAXPRT_SQ_PENDING, &xprt->sc_flags)) {
+			ib_req_notify_cq(xprt->sc_sq_cq, IB_CQ_NEXT_COMP);
+			sq_cq_reap(xprt);
+		}
+
+		spin_lock_irqsave(&dto_lock, flags);
+	}
+	spin_unlock_irqrestore(&dto_lock, flags);
+}
+
+/*
+ * Receive Queue Completion Handler - potentially called on interrupt context.
+ *
+ * svc_sock_enqueue and the remainder of the svc core assumes
+ * uses _bh locks. Since the rq_comp_handler is called on interrupt
+ * context, we need to refer the handling of the I/O to a tasklet
+ */
+static void
+rq_comp_handler(struct ib_cq *cq, void *cq_context)
+{
+	struct svcxprt_rdma *xprt = cq_context;
+	unsigned long flags;
+
+	/* 
+	 * Set the bit regardless of whether or not it's on the list
+	 * because it may be on the list already due to an SQ
+	 * completion.
+	*/
+	set_bit(RDMAXPRT_RQ_PENDING, &xprt->sc_flags);
+
+	/*
+	 * If this transport is not already on the DTO transport queue,
+	 * add it
+	 */
+	spin_lock_irqsave(&dto_lock, flags);
+	if (list_empty(&xprt->sc_dto_q))
+		list_add_tail(&xprt->sc_dto_q, &dto_xprt_q);
+	spin_unlock_irqrestore(&dto_lock, flags);
+
+	/* Tasklet does all the work to avoid irqsave locks. */
+	tasklet_schedule(&dto_tasklet);
+}
+
+/*
+ * rq_cq_reap - Process the RQ CQ.
+ *
+ * Take all completing WC off the CQE and enqueue the associated DTO context
+ * on the dto_q for the transport.
+ */
+static void
+rq_cq_reap(struct svcxprt_rdma *xprt)
+{
+	int ret;
+	struct ib_wc wc;
+	struct svc_rdma_op_ctxt *ctxt = NULL;
+
+	rdma_stat_rq_poll ++;
+
+	spin_lock_bh(&xprt->sc_rq_dto_lock);
+	while ((ret = ib_poll_cq(xprt->sc_rq_cq, 1, &wc)) > 0) {
+		ctxt = (struct svc_rdma_op_ctxt*)(unsigned long)wc.wr_id;
+		ctxt->wc_status = wc.status;
+		ctxt->byte_len = wc.byte_len;
+		if (wc.status != IB_WC_SUCCESS) {
+			/* Close the transport */
+			set_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags);
+			svc_rdma_put_context(ctxt, 1);
+			continue;
+		}
+		list_add_tail(&ctxt->dto_q, &xprt->sc_rq_dto_q);
+	}
+	spin_unlock_bh(&xprt->sc_rq_dto_lock);
+
+	if (ctxt)
+		rdma_stat_rq_prod ++;
+}
+
+/*
+ * Send Queue Completion Handler - potentially called on interrupt context.
+ */
+static void
+sq_cq_reap(struct svcxprt_rdma *xprt)
+{
+	struct svc_rdma_op_ctxt *ctxt = NULL;
+	struct ib_wc wc;
+	struct ib_cq *cq = xprt->sc_sq_cq;
+	int ret;
+
+	rdma_stat_sq_poll ++;
+	while ((ret = ib_poll_cq(cq, 1, &wc)) > 0) {
+		ctxt = (struct svc_rdma_op_ctxt*)(unsigned long)wc.wr_id;
+		xprt = ctxt->xprt;
+
+		if (wc.status != IB_WC_SUCCESS)
+			/* Close the transport */
+			set_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags);
+
+		/* Decrement used SQ WR count */
+		atomic_dec(&xprt->sc_sq_count);
+		wake_up(&xprt->sc_send_wait);
+
+		switch (ctxt->wr_op) {
+		case IB_WR_SEND:
+		case IB_WR_RDMA_WRITE:
+			svc_rdma_put_context(ctxt,1);
+			break;
+
+		case IB_WR_RDMA_READ:
+			if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
+				set_bit(SK_DATA, &xprt->sc_xprt.sk_flags);
+				set_bit(RDMACTXT_F_READ_DONE, &ctxt->flags);
+				spin_lock_bh(&xprt->sc_read_complete_lock);
+				list_add_tail(&ctxt->dto_q, &xprt->sc_read_complete_q);
+				spin_unlock_bh(&xprt->sc_read_complete_lock);
+				svc_sock_enqueue(&xprt->sc_xprt);
+			}
+			break;
+
+		default:
+			printk(KERN_ERR "svcrdma: unexpected completion type, "
+			       "opcode=%d, status=%d\n",
+			       wc.opcode, wc.status);
+			break;
+		}
+	}
+
+	if (ctxt)
+		rdma_stat_sq_prod ++;
+}
+
+static void
+sq_comp_handler(struct ib_cq *cq, void *cq_context)
+{
+	struct svcxprt_rdma *xprt = cq_context;
+	unsigned long flags;
+	
+	/* 
+	 * Set the bit regardless of whether or not it's on the list
+	 * because it may be on the list already due to an RQ
+	 * completion.
+	*/
+	set_bit(RDMAXPRT_SQ_PENDING,&xprt->sc_flags);
+
+	/*
+	 * If this transport is not already on the DTO transport queue,
+	 * add it
+	 */
+	spin_lock_irqsave(&dto_lock, flags);
+	if (list_empty(&xprt->sc_dto_q))
+		list_add_tail(&xprt->sc_dto_q, &dto_xprt_q);
+	spin_unlock_irqrestore(&dto_lock, flags);
+	
+	/* Tasklet does all the work to avoid irqsave locks. */
+	tasklet_schedule(&dto_tasklet);
+}
+
+static void
+create_context_cache(struct svcxprt_rdma *xprt,
+		     int ctxt_count, int ctxt_bump, int ctxt_max)
+{
+	struct svc_rdma_op_ctxt *ctxt;
+	int i;
+
+	xprt->sc_ctxt_max = ctxt_max;
+	xprt->sc_ctxt_bump = ctxt_bump;
+	xprt->sc_ctxt_cnt = 0;
+	xprt->sc_ctxt_head = NULL;
+	for (i=0; i < ctxt_count; i++) {
+		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
+		if (ctxt) {
+			ctxt->next = xprt->sc_ctxt_head;
+			xprt->sc_ctxt_head = ctxt;
+			xprt->sc_ctxt_cnt ++;
+		}
+	}
+}
+
+static void destroy_context_cache(struct svc_rdma_op_ctxt *ctxt)
+{
+	struct svc_rdma_op_ctxt *next;
+	if (!ctxt)
+		return;
+
+	do {
+		next = ctxt->next;
+		kfree(ctxt);
+		ctxt = next;
+	} while (next);
+}
+
+static struct svcxprt_rdma *rdma_create_xprt(int listener)
+{
+	struct svcxprt_rdma *cma_xprt = kzalloc(sizeof *cma_xprt, GFP_KERNEL);
+
+	if (!cma_xprt)
+		return NULL;
+
+	INIT_LIST_HEAD(&cma_xprt->sc_accept_q);
+	INIT_LIST_HEAD(&cma_xprt->sc_dto_q);
+	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
+	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
+	init_waitqueue_head(&cma_xprt->sc_send_wait);
+
+	spin_lock_init(&cma_xprt->sc_lock);
+	spin_lock_init(&cma_xprt->sc_read_complete_lock);
+	spin_lock_init(&cma_xprt->sc_ctxt_lock);
+	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
+
+	cma_xprt->sc_ord = svcrdma_ord;
+
+	cma_xprt->sc_max_req_size = svcrdma_max_req_size;
+	cma_xprt->sc_max_requests = svcrdma_max_requests;
+	cma_xprt->sc_sq_depth = svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT;
+	atomic_set(&cma_xprt->sc_sq_count,0);
+
+	if (!listener) {
+		int reqs = cma_xprt->sc_max_requests;
+		create_context_cache(cma_xprt,
+				     reqs << 1, /* starting size */
+				     reqs, 	/* bump amount */
+				     reqs +
+				     cma_xprt->sc_sq_depth +
+				     RPCRDMA_MAX_THREADS + 1); /* max */
+		if (!cma_xprt->sc_ctxt_head) {
+			kfree(cma_xprt);
+			return NULL;
+		}
+	}
+
+	return cma_xprt;
+}
+
+/*
+ * Create a string for presentation in the portlist file. The RDMA
+ * listener presents an issue because it is a) transport independent,
+ * and b) not bound to a local interface yet. That is, it's listening
+ * on INADDR_ANY. This means that the endpoint 'cm_id' is not yet
+ * bound to a device and therefore, we dont' know if it's IP or
+ * IB. The string created here, therefore, is a fabrication unless the
+ * service has bound to a specific local endpoint.
+ */
+static int svc_rdma_get_name(char *buf, struct svc_sock *svsk)
+{
+	int len;
+	struct svcxprt_rdma *rdma = (struct svcxprt_rdma *)svsk;
+	
+	BUG_ON(rdma->sc_cm_id==NULL);
+
+	/* Check if we're bound to a device. If not,  */
+	if (!rdma->sc_cm_id->device) {
+		/* fabricate a string */
+		len = sprintf(buf, "ofa rdma 0.0.0.0 %d\n", 
+			      ntohs(((struct sockaddr_in*)&rdma->sc_cm_id->
+				     route.addr.src_addr)->sin_port));
+		return len;
+	}
+
+	switch (rdma_node_get_transport(rdma->sc_cm_id->device->node_type)) {
+	case RDMA_TRANSPORT_IB:
+		len = sprintf(buf, "ib rdma %u.%u.%u.%u %d\n",
+			      NIPQUAD(((struct sockaddr_in*)&rdma->sc_cm_id->
+				       route.addr.src_addr)->sin_addr.s_addr),
+			      ntohs(((struct sockaddr_in*)&rdma->sc_cm_id->
+				     route.addr.src_addr)->sin_port));
+		break;
+	case RDMA_TRANSPORT_IWARP:
+		len = sprintf(buf, "ipv4 rdma %u.%u.%u.%u %d\n",
+			      NIPQUAD(((struct sockaddr_in*)&rdma->sc_cm_id->
+				       route.addr.src_addr)->sin_addr.s_addr),
+			      ntohs(((struct sockaddr_in*)&rdma->sc_cm_id->
+				     route.addr.src_addr)->sin_port));
+		break;
+	default:
+		len = sprintf(buf, "*unknown-%d*\n",
+			      rdma->sc_cm_id->device->node_type);
+	}
+		
+	return len;
+}
+
+struct page *svc_rdma_get_page(void)
+{
+	struct page *page;
+
+	while ((page = alloc_page(GFP_KERNEL))==NULL) {
+		/* If we can't get memory, wait a bit and try again */
+		printk(KERN_INFO "svcrdma: out of memory...retrying in 1000 jiffies.\n");
+		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
+	}
+	return page;
+}
+
+int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
+{
+	struct ib_recv_wr recv_wr, *bad_recv_wr;
+	struct svc_rdma_op_ctxt *ctxt;
+	struct page *page;
+	unsigned long pa;
+	int sge_no;
+	int buflen;
+	int ret;
+
+	ctxt = svc_rdma_get_context(xprt);
+	buflen = 0;
+	ctxt->direction = DMA_FROM_DEVICE;
+	for (sge_no=0; buflen < xprt->sc_max_req_size; sge_no++) {
+		BUG_ON(sge_no >= xprt->sc_max_sge);
+		page = svc_rdma_get_page();
+		ctxt->pages[sge_no] = page;
+		pa = ib_dma_map_page(xprt->sc_cm_id->device,
+				     page, 0, PAGE_SIZE,
+				     DMA_FROM_DEVICE);
+		ctxt->sge[sge_no].addr = pa;
+		ctxt->sge[sge_no].length = PAGE_SIZE;
+		ctxt->sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
+		buflen += PAGE_SIZE;
+	}
+	ctxt->count = sge_no;
+	recv_wr.next = NULL;
+	recv_wr.sg_list = &ctxt->sge[0];
+	recv_wr.num_sge = ctxt->count;
+	recv_wr.wr_id = (u64)(unsigned long)ctxt;
+
+	ret = ib_post_recv(xprt->sc_qp, &recv_wr, &bad_recv_wr);
+	return ret;
+}
+
+static void init_sock(struct svc_sock *svsk, struct svc_serv* serv)
+{
+	svsk->sk_xprt = &svc_rdma_xprt;
+	INIT_LIST_HEAD(&svsk->sk_list);
+	svc_sock_init(svsk, serv);
+}
+
+/*
+ * This function handles the CONNECT_REQUEST event on a listening
+ * endpoint. It is passed the cma_id for the _new_ connection. The context in
+ * this cma_id is inherited from the listening cma_id and is the svc_sock
+ * structure for the listening endpoint.
+ *
+ * This function creates a new xprt for the new connection and enqueues it on
+ * the accept queue for the listent xprt. When the listen thread is kicked, it
+ * will call the recvfrom method on the listen xprt which will accept the new
+ * connection.
+ */
+static void handle_connect_req(struct rdma_cm_id *new_cma_id)
+{
+	struct svcxprt_rdma *listen_xprt = new_cma_id->context;
+	struct svcxprt_rdma *newxprt;
+
+	/* Create a new transport */
+	newxprt = rdma_create_xprt(0);
+	if (!newxprt) {
+		dprintk("svcrdma: failed to create new transport\n");
+		return;
+	}
+	newxprt->sc_cm_id = new_cma_id;
+	new_cma_id->context = newxprt;
+	dprintk("svcrdma: Creating newxprt=%p, cm_id=%p, listenxprt=%p\n",
+		newxprt, newxprt->sc_cm_id, listen_xprt);
+
+	/* Initialize the new transport */
+	init_sock(&newxprt->sc_xprt, listen_xprt->sc_xprt.sk_server);
+
+	/* Enqueue the new transport on the accept queue of the listening
+	 * transport */
+	spin_lock_bh(&listen_xprt->sc_lock);
+	list_add_tail(&newxprt->sc_accept_q, &listen_xprt->sc_accept_q);
+	spin_unlock_bh(&listen_xprt->sc_lock);
+
+	listen_xprt->sc_xprt.sk_pool = NULL;
+	set_bit(SK_CONN, &listen_xprt->sc_xprt.sk_flags);
+	svc_sock_enqueue(&listen_xprt->sc_xprt);
+}
+
+/*
+ * Handles events generated on the listening endpoint. These events will be
+ * either be incoming connect requests or adapter removal  events.
+ * @param cma_id The CMA ID for the listening endpoint
+ * @event the event being delivered.
+ */
+static int
+rdma_listen_handler(struct rdma_cm_id *cma_id, struct rdma_cm_event *event)
+{
+	struct svcxprt_rdma *xprt = cma_id->context;
+	int ret = 0;
+
+	switch (event->event) {
+	case RDMA_CM_EVENT_CONNECT_REQUEST:
+		dprintk("svcrdma: Connect request on cma_id=%p, xprt = %p, event=%d\n",
+			cma_id, cma_id->context, event->event);
+		handle_connect_req(cma_id);
+		break;
+
+	case RDMA_CM_EVENT_ESTABLISHED:
+		/* Accept complete */
+		dprintk("svcrdma: Connection completed on LISTEN xprt=%p, cm_id=%p\n",
+			xprt, cma_id);
+		break;
+
+	case RDMA_CM_EVENT_DEVICE_REMOVAL:
+		dprintk("svcrdma: Device removal xprt=%p, cm_id=%p\n",
+			xprt, cma_id);
+		if (xprt)
+			set_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags);
+		break;
+
+	default:
+		dprintk("svcrdma: Unexpected event on listening endpoint %p, event=%d\n",
+			cma_id, event->event);
+		break;
+	}
+
+	return ret;
+}
+
+static int
+rdma_cma_handler(struct rdma_cm_id *cma_id, struct rdma_cm_event *event)
+{
+	struct svcxprt_rdma *xprt = cma_id->context;
+	int ret = 0;
+
+	switch (event->event) {
+	case RDMA_CM_EVENT_ESTABLISHED:
+		/* Accept complete */
+		dprintk("svcrdma: Connection completed on DTO xprt=%p, cm_id=%p\n",
+			xprt, cma_id);
+		break;
+
+	case RDMA_CM_EVENT_DISCONNECTED:
+		dprintk("svcrdma: Disconnect on DTO xprt=%p, cm_id=%p\n",
+			xprt, cma_id);
+		if (xprt) {
+			xprt->sc_xprt.sk_pool = NULL;
+			set_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags);
+			svc_sock_enqueue(&xprt->sc_xprt);
+		}
+		break;
+
+	case RDMA_CM_EVENT_DEVICE_REMOVAL:
+		dprintk("svcrdma: Device removal cma_id=%p, xprt = %p, event=%d\n",
+			cma_id, cma_id->context, event->event);
+		if (xprt) {
+			xprt->sc_xprt.sk_pool = NULL;
+			set_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags);
+			svc_sock_enqueue(&xprt->sc_xprt);
+		}
+		break;
+
+	default:
+		dprintk("svcrdma: Unexpected event on DTO endpoint %p, event=%d\n",
+			cma_id, event->event);
+		break;
+	}
+
+	return ret;
+}
+
+/*
+ * Create a listening RDMA service endpoint
+ * @param serv the RPC service this instance will belong to
+ * @param protocol the protocol for the instance
+ * @param sa the address to bind the local interface to
+ * @return 0 on success, negative value for errors
+ */
+int svc_rdma_create_svc(struct svc_serv *serv, struct sockaddr *sa,
+			int flags)
+{
+	struct rdma_cm_id *listen_id;
+	struct svcxprt_rdma *cma_xprt;
+	struct svc_sock *xprt;
+	int ret;
+
+	dprintk("svcrdma: Creating RDMA socket\n");
+
+	cma_xprt = rdma_create_xprt(1);
+	if (!cma_xprt)
+		return -ENOMEM;
+
+	xprt = &cma_xprt->sc_xprt;
+	init_sock(xprt, serv);
+	set_bit(SK_LISTENER, &xprt->sk_flags);
+
+	/*
+	 * We shouldn't receive any events (except device removal) on
+	 * the id until we submit the listen request.  Any events that
+	 * we do receive will get logged as errors and ignored
+	 */
+	listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP);
+	if (IS_ERR(listen_id)) {
+		ret = PTR_ERR(listen_id);
+		rdma_destroy_xprt(cma_xprt);
+		dprintk("svcrdma: rdma_create_id failed = %d\n", ret);
+		return ret;
+	}
+	ret = rdma_bind_addr(listen_id, sa);
+	if (ret) {
+		ret = PTR_ERR(listen_id);
+		rdma_destroy_xprt(cma_xprt);
+		rdma_destroy_id(listen_id);
+		dprintk("svcrdma: rdma_bind_addr failed = %d\n", ret);
+		return ret;
+	}
+	cma_xprt->sc_cm_id = listen_id;
+
+	/* The xprt is ready to process events at this point */
+	ret = rdma_listen(listen_id, RPCRDMA_LISTEN_BACKLOG);
+	if (ret) {
+		ret = PTR_ERR(listen_id);
+		rdma_destroy_id(listen_id);
+		rdma_destroy_xprt(cma_xprt);
+		dprintk("svcrdma: rdma_listen failed = %d\n", ret);
+		return ret;
+	}
+
+	/* Add to list of permanent (listening/unconnected) sockets */
+	svc_sock_add_listener(xprt);
+	clear_bit(SK_BUSY, &xprt->sk_flags);
+
+	return 0;
+}
+
+/*
+ * This is the sk_recvfrom function for listening endpoints. It's purpose is
+ * to accept incoming connections. The CMA callback handler has already
+ * created a new transport and attached the new CMA ID.
+ *
+ * There is a queue of pending connections hung on the listening
+ * transport. This queue contains the new svc_sock structure. This function
+ * takes svc_sock structures off the accept_q and completes the
+ * connection.
+ */
+static int
+svc_rdma_accept(struct svc_sock *xprt)
+{
+	struct svcxprt_rdma *listen_xprt;
+	struct svcxprt_rdma *newxprt;
+	struct rdma_conn_param conn_param;
+	struct ib_qp_init_attr qp_attr;
+	struct ib_device_attr devattr;
+	int ret;
+	int i;
+
+	listen_xprt = (struct svcxprt_rdma*)xprt;
+	if (list_empty(&listen_xprt->sc_accept_q)) {
+		printk(KERN_INFO
+		       "svcrdma: woke-up with no pending connection!\n");
+		clear_bit(SK_CONN, &listen_xprt->sc_xprt.sk_flags);
+		BUG_ON(test_bit(SK_BUSY, &listen_xprt->sc_xprt.sk_flags)==0);
+		clear_bit(SK_BUSY, &listen_xprt->sc_xprt.sk_flags);
+		return 0;
+	}
+
+	/* Get the next entry off the accept list */
+	spin_lock_bh(&listen_xprt->sc_lock);
+	newxprt = list_entry(listen_xprt->sc_accept_q.next,
+			     struct svcxprt_rdma, sc_accept_q);
+	list_del_init(&newxprt->sc_accept_q);
+	spin_unlock_bh(&listen_xprt->sc_lock);
+
+	dprintk("svcrdma: newxprt from accept queue = %p, cm_id=%p\n",
+		newxprt, newxprt->sc_cm_id);
+
+	ret = ib_query_device(newxprt->sc_cm_id->device, &devattr);
+	if (ret) {
+		printk(KERN_ERR
+		       "svcrdma: could not query device attributes on "
+		       "device %p, rc=%d\n",
+		       newxprt->sc_cm_id->device, ret);
+		goto errout;
+	}
+
+	/* Qualify the transport resource defaults with the
+	 * capabilities of this particular device */
+	newxprt->sc_max_sge = min((size_t)devattr.max_sge,
+				  (size_t)RPCSVC_MAXPAGES);
+	newxprt->sc_max_requests = min((size_t)devattr.max_qp_wr,
+				   (size_t)svcrdma_max_requests);
+	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
+
+	newxprt->sc_ord =  min((size_t)devattr.max_qp_rd_atom,
+			       (size_t)svcrdma_ord);
+
+	newxprt->sc_pd = ib_alloc_pd(newxprt->sc_cm_id->device);
+	if (IS_ERR(newxprt->sc_pd)) {
+		printk(KERN_ERR
+		       "svcrdma: error creating PD for connect request\n");
+		ret = PTR_ERR(newxprt->sc_pd);
+		goto errout;
+	}
+	newxprt->sc_sq_cq = ib_create_cq(newxprt->sc_cm_id->device,
+					 sq_comp_handler,
+					 cq_event_handler,
+					 newxprt,
+					 newxprt->sc_sq_depth,
+					 0);
+	if (IS_ERR(newxprt->sc_sq_cq)) {
+		printk(KERN_ERR
+		       "svcrdma: error creating SQ CQ for connect request\n");
+		ret = PTR_ERR(newxprt->sc_sq_cq);
+		goto errout;
+	}
+	newxprt->sc_rq_cq = ib_create_cq(newxprt->sc_cm_id->device,
+					 rq_comp_handler,
+					 cq_event_handler,
+					 newxprt,
+					 newxprt->sc_max_requests,
+					 0);
+	if (IS_ERR(newxprt->sc_rq_cq)) {
+		printk(KERN_ERR
+		       "svcrdma: error creating RQ CQ for connect request\n");
+		ret = PTR_ERR(newxprt->sc_rq_cq);
+		goto errout;
+	}
+
+	memset(&qp_attr, 0, sizeof qp_attr);
+	qp_attr.event_handler = qp_event_handler;
+	qp_attr.qp_context = newxprt;
+	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth;
+	qp_attr.cap.max_recv_wr = newxprt->sc_max_requests;
+	qp_attr.cap.max_send_sge = newxprt->sc_max_sge;
+	qp_attr.cap.max_recv_sge = newxprt->sc_max_sge;
+	qp_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
+	qp_attr.qp_type = IB_QPT_RC;
+	qp_attr.send_cq = newxprt->sc_sq_cq;
+	qp_attr.recv_cq = newxprt->sc_rq_cq;
+	dprintk("newxprt->sc_cm_id=%p, newxprt->sc_pd=%p\n"
+		"cm_id->device=%p, sc_pd->device=%p\n"
+		"qp_attr.cap.max_send_wr = %d\n"
+		"qp_attr.cap.max_recv_wr = %d\n"
+		"qp_attr.cap.max_send_sge = %d\n"
+		"qp_attr.cap.max_recv_sge = %d\n",
+		newxprt->sc_cm_id, newxprt->sc_pd,
+		newxprt->sc_cm_id->device, newxprt->sc_pd->device,
+		qp_attr.cap.max_send_wr,
+		qp_attr.cap.max_recv_wr,
+		qp_attr.cap.max_send_sge,
+		qp_attr.cap.max_recv_sge);
+
+	ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd, &qp_attr);
+	if (ret) {
+		/*
+		 * XXX: This is a hack. We need a xx_request_qp interface
+		 * that will adjust the qp_attr's with a best-effort
+		 * number
+		 */
+		qp_attr.cap.max_send_sge -= 2;
+		qp_attr.cap.max_recv_sge -= 2;
+		ret = rdma_create_qp(newxprt->sc_cm_id, newxprt->sc_pd, &qp_attr);
+		if (ret) {
+			printk(KERN_ERR "svcrdma: failed to create QP, ret=%d\n", ret);
+			goto errout;
+		}
+		newxprt->sc_max_sge = qp_attr.cap.max_send_sge;
+		newxprt->sc_max_sge = qp_attr.cap.max_recv_sge;
+		newxprt->sc_sq_depth = qp_attr.cap.max_send_wr;
+		newxprt->sc_max_requests = qp_attr.cap.max_recv_wr;
+	}
+	newxprt->sc_qp = newxprt->sc_cm_id->qp;
+
+	/* Register all of physical memory */
+	newxprt->sc_phys_mr = ib_get_dma_mr(newxprt->sc_pd,
+					    IB_ACCESS_LOCAL_WRITE |
+					    IB_ACCESS_REMOTE_WRITE);
+	if (IS_ERR(newxprt->sc_phys_mr)) {
+		ret = PTR_ERR(newxprt->sc_phys_mr);
+		printk(KERN_ERR
+		       "svcrdma: Failed to create DMA MR ret=%d\n", ret);
+		goto errout;
+	}
+
+	/* Post receive buffers */
+	for (i=0; i < newxprt->sc_max_requests; i++)
+		if ((ret = svc_rdma_post_recv(newxprt))) {
+			printk(KERN_ERR
+			       "svcrdma: failure posting receive buffers\n");
+			goto errout;
+		}
+
+	/* Swap out the handler */
+	newxprt->sc_cm_id->event_handler = rdma_cma_handler;
+
+	/* We will get a getattr request from the client before we see
+	 * the connect complete event because DTO's run on tasklets,
+	 * and connection events run on threads
+	*/
+	clear_bit(SK_BUSY, &newxprt->sc_xprt.sk_flags);
+
+	/* Accept Connection */
+	memset(&conn_param, 0, sizeof conn_param);
+	conn_param.responder_resources = 0;
+	conn_param.initiator_depth = newxprt->sc_ord;
+	ret = rdma_accept(newxprt->sc_cm_id, &conn_param);
+	if (ret) {
+		printk(KERN_ERR
+		       "svcrdma: failed to accept new connection, ret=%d\n",
+		       ret);
+		goto errout;
+	}
+
+	dprintk("svcrdma: new connection %p accepted with the following "
+		"attributes:\n"
+		"\tlocal_ip        : %d.%d.%d.%d\n"
+		"\tlocal_port	   : %d\n"
+		"\tremote_ip       : %d.%d.%d.%d\n"
+		"\tremote_port     : %d\n"
+		"\tmax_sge         : %d\n"
+		"\tsq_depth        : %d\n"
+		"\tmax_requests    : %d\n"
+		"\tord             : %d\n",
+		newxprt,
+		NIPQUAD(((struct sockaddr_in*)&newxprt->sc_cm_id->
+			 route.addr.src_addr)->sin_addr.s_addr),
+		ntohs(((struct sockaddr_in*)&newxprt->sc_cm_id->
+		       route.addr.src_addr)->sin_port),
+		NIPQUAD(((struct sockaddr_in*)&newxprt->sc_cm_id->
+			 route.addr.dst_addr)->sin_addr.s_addr),
+		ntohs(((struct sockaddr_in*)&newxprt->sc_cm_id->
+		       route.addr.dst_addr)->sin_port),
+		newxprt->sc_max_sge,
+		newxprt->sc_sq_depth,
+		newxprt->sc_max_requests,
+		newxprt->sc_ord);
+
+	spin_lock_bh(&listen_xprt->sc_lock);
+	if (list_empty(&listen_xprt->sc_accept_q))
+		clear_bit(SK_CONN, &listen_xprt->sc_xprt.sk_flags);
+	spin_unlock_bh(&listen_xprt->sc_lock);
+	listen_xprt->sc_xprt.sk_pool = NULL;
+	BUG_ON(test_bit(SK_BUSY, &listen_xprt->sc_xprt.sk_flags)==0);
+	clear_bit(SK_BUSY, &listen_xprt->sc_xprt.sk_flags);
+	svc_sock_enqueue(&listen_xprt->sc_xprt);
+
+	/* Add to the server's temporary (connected) socket list */ 
+	svc_sock_add_connection(&newxprt->sc_xprt);
+
+	ib_req_notify_cq(newxprt->sc_sq_cq, IB_CQ_NEXT_COMP);
+	ib_req_notify_cq(newxprt->sc_rq_cq, IB_CQ_NEXT_COMP);
+	return ret;
+
+ errout:
+	printk(KERN_ERR "svcrdma: failure accepting new connection rc=%d.\n",
+	       ret);
+	BUG_ON(test_bit(SK_BUSY, &listen_xprt->sc_xprt.sk_flags)==0);
+	clear_bit(SK_BUSY, &listen_xprt->sc_xprt.sk_flags);
+	clear_bit(SK_CONN, &listen_xprt->sc_xprt.sk_flags);
+	rdma_destroy_id(newxprt->sc_cm_id);
+	rdma_destroy_xprt(newxprt);
+	return 0; /* ret; */
+}
+
+/* Disable data ready events for this connection */
+static void svc_rdma_detach(struct svc_sock *svsk)
+{
+	struct svcxprt_rdma *rdma = (struct svcxprt_rdma*)svsk;
+	unsigned long flags;
+
+	dprintk("svc: svc_rdma_detach(%p)\n", svsk);
+
+	/* 
+	 * Shutdown the connection. This will ensure we don't get any
+	 * more events from the provider. 
+	 */
+	rdma_disconnect(rdma->sc_cm_id);
+	rdma_destroy_id(rdma->sc_cm_id);
+
+	/* We may already be on the DTO list, however */
+	spin_lock_irqsave(&dto_lock, flags);
+	if (!list_empty(&rdma->sc_dto_q)) 
+		list_del_init(&rdma->sc_dto_q);
+	spin_unlock_irqrestore(&dto_lock, flags);
+}
+
+static void svc_rdma_free(struct svc_sock *svsk)
+{
+	struct svcxprt_rdma *xprt = (struct svcxprt_rdma *)svsk;
+	dprintk("svcrdma: svc_rdma_free(%p)\n", svsk);
+
+	rdma_destroy_xprt(xprt);
+	kfree(svsk);
+}
+
+static void rdma_destroy_xprt(struct svcxprt_rdma *xprt)
+{
+	if (xprt->sc_qp)
+		ib_destroy_qp(xprt->sc_qp);
+
+	if (xprt->sc_sq_cq)
+		ib_destroy_cq(xprt->sc_sq_cq);
+
+	if (xprt->sc_rq_cq)
+		ib_destroy_cq(xprt->sc_rq_cq);
+
+	if (xprt->sc_pd)
+		ib_dealloc_pd(xprt->sc_pd);
+
+	destroy_context_cache(xprt->sc_ctxt_head);
+}
+
+static int svc_rdma_has_wspace(struct svc_sock *svsk)
+{
+	struct svcxprt_rdma *xprt = (struct svcxprt_rdma *)svsk;
+	/*
+	 * If there are fewer SQ WR available than required to send a
+	 * simple response, return false.
+	 */
+	if ((xprt->sc_sq_depth - atomic_read(&xprt->sc_sq_count) < 3))
+		return 0;
+
+	/*
+	 * ...or there are already waiters on the SQ,
+	 * return false. 
+	 */
+	if (waitqueue_active(&xprt->sc_send_wait))
+		return 0;
+
+	/* Otherwise return true. */
+	return 1;
+}
+
+int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
+{
+	struct ib_send_wr *bad_wr;
+	int ret;
+
+	if (test_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags))
+		return 0;
+
+	BUG_ON(wr->send_flags != IB_SEND_SIGNALED);
+	BUG_ON(((struct svc_rdma_op_ctxt*)(unsigned long)wr->wr_id)->wr_op !=
+		wr->opcode);
+	/* If the SQ is full, wait until an SQ entry is available */
+	while (1) {
+		spin_lock_bh(&xprt->sc_lock);
+		if (xprt->sc_sq_depth == atomic_read(&xprt->sc_sq_count)) {
+			spin_unlock_bh(&xprt->sc_lock);
+			rdma_stat_sq_starve ++;
+			/* First see if we can opportunistically reap some SQ WR */
+			sq_cq_reap(xprt);
+
+			/* Wait until SQ WR available if SQ still full */
+			wait_event(xprt->sc_send_wait,
+				   atomic_read(&xprt->sc_sq_count) < xprt->sc_sq_depth);
+			continue;
+		}
+		/* Bumped used SQ WR count and post */
+		ret = ib_post_send(xprt->sc_qp, wr, &bad_wr);
+		if (!ret)
+			atomic_inc(&xprt->sc_sq_count);
+		else {
+			printk(KERN_ERR "svcrdma: failed to post SQ WR rc=%d, "
+			       "sc_sq_count=%d, sc_sq_depth=%d\n",
+			       ret, atomic_read(&xprt->sc_sq_count),
+			       xprt->sc_sq_depth);
+		}
+		spin_unlock_bh(&xprt->sc_lock);
+		break;
+	}
+
+	return ret;
+}
+
+int svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
+		    enum rpcrdma_errcode err)
+{
+	struct ib_send_wr err_wr;
+	struct ib_sge sge;
+	struct page *p;
+	struct svc_rdma_op_ctxt *ctxt;
+	u32 *va;
+	int length;
+	int ret;
+
+	p = svc_rdma_get_page();
+	va = page_address(p);
+
+	/* XDR encode error */
+	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
+
+	/* Prepare SGE for local address */
+	sge.addr = ib_dma_map_page(xprt->sc_cm_id->device,
+				   p, 0, PAGE_SIZE, DMA_FROM_DEVICE);
+	sge.lkey = xprt->sc_phys_mr->lkey;
+	sge.length = length;
+
+	ctxt = svc_rdma_get_context(xprt);
+	ctxt->count = 1;
+	ctxt->pages[0] = p;
+
+	/* Prepare SEND WR */
+	memset(&err_wr, 0, sizeof err_wr);
+	ctxt->wr_op = IB_WR_SEND;
+	err_wr.wr_id = (unsigned long)ctxt;
+	err_wr.sg_list = &sge;
+	err_wr.num_sge = 1;
+	err_wr.opcode = IB_WR_SEND;
+	err_wr.send_flags = IB_SEND_SIGNALED;
+
+	/* Post It */
+	ret = svc_rdma_send(xprt, &err_wr);
+	if (ret) {
+		dprintk("svcrdma: Error posting send = %d\n", ret);
+		svc_rdma_put_context(ctxt,1);
+	}
+
+	return ret;
+}
+
+/*
+ * This request cannot be handled right now. Allocate a structure to
+ * keep it's state pending completion processing. To accomplish this, the
+ * function creates an svc_rdma_op_ctxt that looks like a receive completion and
+ * enqueues it on the svc_sock's deferred request list.  When*
+ * svc_rdma_recvfrom is subsequently called, it first checks if there is a
+ * deferred RPC and if there is:
+ * - Takes the deferred request off the deferred request queue
+ * - Extracts the svc_rdma_op_ctxt from the deferred request structure
+ * - Frees the deferred request structure
+ * - Skips the ib_cq_poll call and processes the svc_rdma_op_ctxt as if it had
+ *   just come out of an WR pulled from the CQ.
+ */
+static struct cache_deferred_req *
+svc_rdma_defer(struct cache_req *req)
+{
+	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
+	struct svcxprt_rdma *xprt;
+	struct svc_rdma_deferred_req *dr;
+
+	dprintk("svcrdma: deferring request on \n"
+		"  rqstp=%p\n"
+		"  rqstp->rq_arg.len=%d\n",
+		rqstp,
+		rqstp->rq_arg.len);
+
+	/* if more than a page, give up FIXME */
+	if (rqstp->rq_arg.page_len)
+		return NULL;
+
+	BUG_ON(rqstp->rq_deferred);
+	xprt = (struct svcxprt_rdma*)rqstp->rq_sock;
+	dr = kmalloc(sizeof(struct svc_rdma_deferred_req), GFP_KERNEL);
+	if (!dr)
+		return NULL;
+
+	dr->req.handle.owner = rqstp->rq_server;
+	dr->req.prot = rqstp->rq_prot;
+	dr->req.addr = rqstp->rq_addr;
+	dr->req.daddr = rqstp->rq_daddr;
+	dr->req.argslen = rqstp->rq_arg.len >> 2;
+	dr->arg_page = rqstp->rq_pages[0];
+	dr->arg_len = rqstp->rq_arg.len;
+	rqstp->rq_pages[0] = svc_rdma_get_page();
+
+	svc_sock_get(rqstp->rq_sock);
+	dr->req.svsk = rqstp->rq_sock;
+	dr->req.handle.revisit = svc_revisit;
+
+	return &dr->req.handle;
+}
+
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 07dcd20..4029924 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -409,9 +409,8 @@ static inline void
 ip_map_cached_put(struct svc_rqst *rqstp, struct ip_map *ipm)
 {
 	struct svc_sock *svsk = rqstp->rq_sock;
-
 	spin_lock(&svsk->sk_lock);
-	if (svsk->sk_sock->type == SOCK_STREAM &&
+	if (test_bit(SK_TEMP, &svsk->sk_flags) && 
 	    svsk->sk_info_authunix == NULL) {
 		/* newly cached, keep the reference */
 		svsk->sk_info_authunix = ipm;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37591 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752460AbeEGT1T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:27:19 -0400
Subject: [PATCH v1 05/19] svcrdma: Trace key RDMA API events
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:27:16 -0400
Message-ID: <20180507192716.4608.74208.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This includes:
  * Posting on the Send and Receive queues
  * Send, Receive, Read, and Write completion
  * Connect upcalls
  * QP errors

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h             |  322 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/backchannel.c          |    1 
 net/sunrpc/xprtrdma/fmr_ops.c              |    2 
 net/sunrpc/xprtrdma/frwr_ops.c             |    1 
 net/sunrpc/xprtrdma/rpc_rdma.c             |    2 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    3 
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |    2 
 net/sunrpc/xprtrdma/svc_rdma_rw.c          |   14 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |    6 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   70 ++----
 net/sunrpc/xprtrdma/transport.c            |    3 
 11 files changed, 374 insertions(+), 52 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 633520a..094a676 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -1145,6 +1145,328 @@
 DEFINE_ERROR_EVENT(vers);
 DEFINE_ERROR_EVENT(chunk);
 
+/**
+ ** Server-side RDMA API events
+ **/
+
+TRACE_EVENT(svcrdma_dma_map_page,
+	TP_PROTO(
+		const struct svcxprt_rdma *rdma,
+		const void *page
+	),
+
+	TP_ARGS(rdma, page),
+
+	TP_STRUCT__entry(
+		__field(const void *, page);
+		__string(device, rdma->sc_cm_id->device->name)
+		__string(addr, rdma->sc_xprt.xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__assign_str(device, rdma->sc_cm_id->device->name);
+		__assign_str(addr, rdma->sc_xprt.xpt_remotebuf);
+	),
+
+	TP_printk("addr=%s device=%s page=%p",
+		__get_str(addr), __get_str(device), __entry->page
+	)
+);
+
+TRACE_EVENT(svcrdma_dma_map_rwctx,
+	TP_PROTO(
+		const struct svcxprt_rdma *rdma,
+		int status
+	),
+
+	TP_ARGS(rdma, status),
+
+	TP_STRUCT__entry(
+		__field(int, status)
+		__string(device, rdma->sc_cm_id->device->name)
+		__string(addr, rdma->sc_xprt.xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->status = status;
+		__assign_str(device, rdma->sc_cm_id->device->name);
+		__assign_str(addr, rdma->sc_xprt.xpt_remotebuf);
+	),
+
+	TP_printk("addr=%s device=%s status=%d",
+		__get_str(addr), __get_str(device), __entry->status
+	)
+);
+
+TRACE_EVENT(svcrdma_send_failed,
+	TP_PROTO(
+		const struct svc_rqst *rqst,
+		int status
+	),
+
+	TP_ARGS(rqst, status),
+
+	TP_STRUCT__entry(
+		__field(int, status)
+		__field(u32, xid)
+		__field(const void *, xprt)
+		__string(addr, rqst->rq_xprt->xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->status = status;
+		__entry->xid = __be32_to_cpu(rqst->rq_xid);
+		__entry->xprt = rqst->rq_xprt;
+		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
+	),
+
+	TP_printk("xprt=%p addr=%s xid=0x%08x status=%d",
+		__entry->xprt, __get_str(addr),
+		__entry->xid, __entry->status
+	)
+);
+
+DECLARE_EVENT_CLASS(svcrdma_sendcomp_event,
+	TP_PROTO(
+		const struct ib_wc *wc
+	),
+
+	TP_ARGS(wc),
+
+	TP_STRUCT__entry(
+		__field(const void *, cqe)
+		__field(unsigned int, status)
+		__field(unsigned int, vendor_err)
+	),
+
+	TP_fast_assign(
+		__entry->cqe = wc->wr_cqe;
+		__entry->status = wc->status;
+		if (wc->status)
+			__entry->vendor_err = wc->vendor_err;
+		else
+			__entry->vendor_err = 0;
+	),
+
+	TP_printk("cqe=%p status=%s (%u/0x%x)",
+		__entry->cqe, rdma_show_wc_status(__entry->status),
+		__entry->status, __entry->vendor_err
+	)
+);
+
+#define DEFINE_SENDCOMP_EVENT(name)					\
+		DEFINE_EVENT(svcrdma_sendcomp_event, svcrdma_wc_##name,	\
+				TP_PROTO(				\
+					const struct ib_wc *wc		\
+				),					\
+				TP_ARGS(wc))
+
+TRACE_EVENT(svcrdma_post_send,
+	TP_PROTO(
+		const struct ib_send_wr *wr,
+		int status
+	),
+
+	TP_ARGS(wr, status),
+
+	TP_STRUCT__entry(
+		__field(const void *, cqe)
+		__field(unsigned int, num_sge)
+		__field(u32, inv_rkey)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->cqe = wr->wr_cqe;
+		__entry->num_sge = wr->num_sge;
+		__entry->inv_rkey = (wr->opcode == IB_WR_SEND_WITH_INV) ?
+					wr->ex.invalidate_rkey : 0;
+		__entry->status = status;
+	),
+
+	TP_printk("cqe=%p num_sge=%u inv_rkey=0x%08x status=%d",
+		__entry->cqe, __entry->num_sge,
+		__entry->inv_rkey, __entry->status
+	)
+);
+
+DEFINE_SENDCOMP_EVENT(send);
+
+TRACE_EVENT(svcrdma_post_recv,
+	TP_PROTO(
+		const struct ib_recv_wr *wr,
+		int status
+	),
+
+	TP_ARGS(wr, status),
+
+	TP_STRUCT__entry(
+		__field(const void *, cqe)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->cqe = wr->wr_cqe;
+		__entry->status = status;
+	),
+
+	TP_printk("cqe=%p status=%d",
+		__entry->cqe, __entry->status
+	)
+);
+
+TRACE_EVENT(svcrdma_wc_receive,
+	TP_PROTO(
+		const struct ib_wc *wc
+	),
+
+	TP_ARGS(wc),
+
+	TP_STRUCT__entry(
+		__field(const void *, cqe)
+		__field(u32, byte_len)
+		__field(unsigned int, status)
+		__field(u32, vendor_err)
+	),
+
+	TP_fast_assign(
+		__entry->cqe = wc->wr_cqe;
+		__entry->status = wc->status;
+		if (wc->status) {
+			__entry->byte_len = 0;
+			__entry->vendor_err = wc->vendor_err;
+		} else {
+			__entry->byte_len = wc->byte_len;
+			__entry->vendor_err = 0;
+		}
+	),
+
+	TP_printk("cqe=%p byte_len=%u status=%s (%u/0x%x)",
+		__entry->cqe, __entry->byte_len,
+		rdma_show_wc_status(__entry->status),
+		__entry->status, __entry->vendor_err
+	)
+);
+
+TRACE_EVENT(svcrdma_post_rw,
+	TP_PROTO(
+		const void *cqe,
+		int sqecount,
+		int status
+	),
+
+	TP_ARGS(cqe, sqecount, status),
+
+	TP_STRUCT__entry(
+		__field(const void *, cqe)
+		__field(int, sqecount)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->cqe = cqe;
+		__entry->sqecount = sqecount;
+		__entry->status = status;
+	),
+
+	TP_printk("cqe=%p sqecount=%d status=%d",
+		__entry->cqe, __entry->sqecount, __entry->status
+	)
+);
+
+DEFINE_SENDCOMP_EVENT(read);
+DEFINE_SENDCOMP_EVENT(write);
+
+TRACE_EVENT(svcrdma_cm_event,
+	TP_PROTO(
+		const struct rdma_cm_event *event,
+		const struct sockaddr *sap
+	),
+
+	TP_ARGS(event, sap),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, event)
+		__field(int, status)
+		__array(__u8, addr, INET6_ADDRSTRLEN + 10)
+	),
+
+	TP_fast_assign(
+		__entry->event = event->event;
+		__entry->status = event->status;
+		snprintf(__entry->addr, sizeof(__entry->addr) - 1,
+			 "%pISpc", sap);
+	),
+
+	TP_printk("addr=%s event=%s (%u/%d)",
+		__entry->addr,
+		rdma_show_cm_event(__entry->event),
+		__entry->event, __entry->status
+	)
+);
+
+TRACE_EVENT(svcrdma_qp_error,
+	TP_PROTO(
+		const struct ib_event *event,
+		const struct sockaddr *sap
+	),
+
+	TP_ARGS(event, sap),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, event)
+		__string(device, event->device->name)
+		__array(__u8, addr, INET6_ADDRSTRLEN + 10)
+	),
+
+	TP_fast_assign(
+		__entry->event = event->event;
+		__assign_str(device, event->device->name);
+		snprintf(__entry->addr, sizeof(__entry->addr) - 1,
+			 "%pISpc", sap);
+	),
+
+	TP_printk("addr=%s dev=%s event=%s (%u)",
+		__entry->addr, __get_str(device),
+		rdma_show_ib_event(__entry->event), __entry->event
+	)
+);
+
+DECLARE_EVENT_CLASS(svcrdma_sendqueue_event,
+	TP_PROTO(
+		const struct svcxprt_rdma *rdma
+	),
+
+	TP_ARGS(rdma),
+
+	TP_STRUCT__entry(
+		__field(int, avail)
+		__field(int, depth)
+		__string(addr, rdma->sc_xprt.xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->avail = atomic_read(&rdma->sc_sq_avail);
+		__entry->depth = rdma->sc_sq_depth;
+		__assign_str(addr, rdma->sc_xprt.xpt_remotebuf);
+	),
+
+	TP_printk("addr=%s sc_sq_avail=%d/%d",
+		__get_str(addr), __entry->avail, __entry->depth
+	)
+);
+
+#define DEFINE_SQ_EVENT(name)						\
+		DEFINE_EVENT(svcrdma_sendqueue_event, svcrdma_sq_##name,\
+				TP_PROTO(				\
+					const struct svcxprt_rdma *rdma \
+				),					\
+				TP_ARGS(rdma))
+
+DEFINE_SQ_EVENT(full);
+DEFINE_SQ_EVENT(retry);
+
 #endif /* _TRACE_RPCRDMA_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 05c69ac..dbedc87 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -9,6 +9,7 @@
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
+#include <linux/sunrpc/svc_rdma.h>
 
 #include "xprt_rdma.h"
 #include <trace/events/rpcrdma.h>
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 08de7da..c74b415 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -20,6 +20,8 @@
  * verb (fmr_op_unmap).
  */
 
+#include <linux/sunrpc/svc_rdma.h>
+
 #include "xprt_rdma.h"
 #include <trace/events/rpcrdma.h>
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index f8312e3..5d6c01c 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -71,6 +71,7 @@
  */
 
 #include <linux/sunrpc/rpc_rdma.h>
+#include <linux/sunrpc/svc_rdma.h>
 
 #include "xprt_rdma.h"
 #include <trace/events/rpcrdma.h>
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index f358d1e..b942d7e 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -48,6 +48,8 @@
 
 #include <linux/highmem.h>
 
+#include <linux/sunrpc/svc_rdma.h>
+
 #include "xprt_rdma.h"
 #include <trace/events/rpcrdma.h>
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index a73632c..d501521 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -6,8 +6,11 @@
  */
 
 #include <linux/module.h>
+
 #include <linux/sunrpc/svc_rdma.h>
+
 #include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 78ca580..330d542 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -432,8 +432,6 @@ static void svc_rdma_send_error(struct svcxprt_rdma *xprt,
 
 	ret = svc_rdma_post_send_wr(xprt, ctxt, 1, 0);
 	if (ret) {
-		dprintk("svcrdma: Error %d posting send for protocol error\n",
-			ret);
 		svc_rdma_unmap_dma(ctxt);
 		svc_rdma_put_context(ctxt, 1);
 	}
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 4b9cb54..887ceef 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -208,6 +208,8 @@ static void svc_rdma_write_done(struct ib_cq *cq, struct ib_wc *wc)
 	struct svc_rdma_write_info *info =
 			container_of(cc, struct svc_rdma_write_info, wi_cc);
 
+	trace_svcrdma_wc_write(wc);
+
 	atomic_add(cc->cc_sqecount, &rdma->sc_sq_avail);
 	wake_up(&rdma->sc_send_wait);
 
@@ -269,6 +271,8 @@ static void svc_rdma_wc_read_done(struct ib_cq *cq, struct ib_wc *wc)
 	struct svc_rdma_read_info *info =
 			container_of(cc, struct svc_rdma_read_info, ri_cc);
 
+	trace_svcrdma_wc_read(wc);
+
 	atomic_add(cc->cc_sqecount, &rdma->sc_sq_avail);
 	wake_up(&rdma->sc_send_wait);
 
@@ -326,18 +330,20 @@ static int svc_rdma_post_chunk_ctxt(struct svc_rdma_chunk_ctxt *cc)
 		if (atomic_sub_return(cc->cc_sqecount,
 				      &rdma->sc_sq_avail) > 0) {
 			ret = ib_post_send(rdma->sc_qp, first_wr, &bad_wr);
+			trace_svcrdma_post_rw(&cc->cc_cqe,
+					      cc->cc_sqecount, ret);
 			if (ret)
 				break;
 			return 0;
 		}
 
-		atomic_inc(&rdma_stat_sq_starve);
+		trace_svcrdma_sq_full(rdma);
 		atomic_add(cc->cc_sqecount, &rdma->sc_sq_avail);
 		wait_event(rdma->sc_send_wait,
 			   atomic_read(&rdma->sc_sq_avail) > cc->cc_sqecount);
+		trace_svcrdma_sq_retry(rdma);
 	} while (1);
 
-	pr_err("svcrdma: ib_post_send failed (%d)\n", ret);
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
 
 	/* If even one was posted, there will be a completion. */
@@ -466,7 +472,7 @@ static void svc_rdma_pagelist_to_sg(struct svc_rdma_write_info *info,
 
 out_initerr:
 	svc_rdma_put_rw_ctxt(rdma, ctxt);
-	pr_err("svcrdma: failed to map pagelist (%d)\n", ret);
+	trace_svcrdma_dma_map_rwctx(rdma, ret);
 	return -EIO;
 }
 
@@ -661,8 +667,8 @@ static int svc_rdma_build_read_segment(struct svc_rdma_read_info *info,
 	return -EINVAL;
 
 out_initerr:
+	trace_svcrdma_dma_map_rwctx(cc->cc_rdma, ret);
 	svc_rdma_put_rw_ctxt(cc->cc_rdma, ctxt);
-	pr_err("svcrdma: failed to map pagelist (%d)\n", ret);
 	return -EIO;
 }
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 4c58083..fed28de 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -353,7 +353,7 @@ static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
 	return 0;
 
 out_maperr:
-	pr_err("svcrdma: failed to map page\n");
+	trace_svcrdma_dma_map_page(rdma, page);
 	return -EIO;
 }
 
@@ -597,7 +597,6 @@ static int svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
 	return 0;
 
 err:
-	pr_err("svcrdma: failed to post Send WR (%d)\n", ret);
 	svc_rdma_unmap_dma(ctxt);
 	svc_rdma_put_context(ctxt, 1);
 	return ret;
@@ -690,8 +689,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
  err1:
 	put_page(res_page);
  err0:
-	pr_err("svcrdma: Could not send reply, err=%d. Closing transport.\n",
-	       ret);
+	trace_svcrdma_send_failed(rqstp, ret);
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
 	return -ENOTCONN;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index d2cdffa..ca9001d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -275,16 +275,15 @@ static void qp_event_handler(struct ib_event *event, void *context)
 {
 	struct svc_xprt *xprt = context;
 
+	trace_svcrdma_qp_error(event, (struct sockaddr *)&xprt->xpt_remote);
 	switch (event->event) {
 	/* These are considered benign events */
 	case IB_EVENT_PATH_MIG:
 	case IB_EVENT_COMM_EST:
 	case IB_EVENT_SQ_DRAINED:
 	case IB_EVENT_QP_LAST_WQE_REACHED:
-		dprintk("svcrdma: QP event %s (%d) received for QP=%p\n",
-			ib_event_msg(event->event), event->event,
-			event->element.qp);
 		break;
+
 	/* These are considered fatal events */
 	case IB_EVENT_PATH_MIG_ERR:
 	case IB_EVENT_QP_FATAL:
@@ -292,10 +291,6 @@ static void qp_event_handler(struct ib_event *event, void *context)
 	case IB_EVENT_QP_ACCESS_ERR:
 	case IB_EVENT_DEVICE_FATAL:
 	default:
-		dprintk("svcrdma: QP ERROR event %s (%d) received for QP=%p, "
-			"closing transport\n",
-			ib_event_msg(event->event), event->event,
-			event->element.qp);
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
 		svc_xprt_enqueue(xprt);
 		break;
@@ -314,6 +309,8 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 	struct ib_cqe *cqe = wc->wr_cqe;
 	struct svc_rdma_op_ctxt *ctxt;
 
+	trace_svcrdma_wc_receive(wc);
+
 	/* WARNING: Only wc->wr_cqe and wc->status are reliable */
 	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
 	svc_rdma_unmap_dma(ctxt);
@@ -360,6 +357,8 @@ void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 	struct ib_cqe *cqe = wc->wr_cqe;
 	struct svc_rdma_op_ctxt *ctxt;
 
+	trace_svcrdma_wc_send(wc);
+
 	atomic_inc(&xprt->sc_sq_avail);
 	wake_up(&xprt->sc_send_wait);
 
@@ -455,6 +454,7 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 
 	svc_xprt_get(&xprt->sc_xprt);
 	ret = ib_post_recv(xprt->sc_qp, &recv_wr, &bad_recv_wr);
+	trace_svcrdma_post_recv(&recv_wr, ret);
 	if (ret) {
 		svc_rdma_unmap_dma(ctxt);
 		svc_rdma_put_context(ctxt, 1);
@@ -513,8 +513,6 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id,
 		return;
 	newxprt->sc_cm_id = new_cma_id;
 	new_cma_id->context = newxprt;
-	dprintk("svcrdma: Creating newxprt=%p, cm_id=%p, listenxprt=%p\n",
-		newxprt, newxprt->sc_cm_id, listen_xprt);
 	svc_rdma_parse_connect_private(newxprt, param);
 
 	/* Save client advertised inbound read limit for use later in accept. */
@@ -545,33 +543,21 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id,
 static int rdma_listen_handler(struct rdma_cm_id *cma_id,
 			       struct rdma_cm_event *event)
 {
-	struct svcxprt_rdma *xprt = cma_id->context;
+	struct sockaddr *sap = (struct sockaddr *)&cma_id->route.addr.src_addr;
+	struct svcxprt_rdma *rdma = cma_id->context;
 	int ret = 0;
 
+	trace_svcrdma_cm_event(event, sap);
+
 	switch (event->event) {
 	case RDMA_CM_EVENT_CONNECT_REQUEST:
 		dprintk("svcrdma: Connect request on cma_id=%p, xprt = %p, "
-			"event = %s (%d)\n", cma_id, cma_id->context,
+			"event = %s (%d)\n", cma_id, rdma,
 			rdma_event_msg(event->event), event->event);
 		handle_connect_req(cma_id, &event->param.conn);
 		break;
-
-	case RDMA_CM_EVENT_ESTABLISHED:
-		/* Accept complete */
-		dprintk("svcrdma: Connection completed on LISTEN xprt=%p, "
-			"cm_id=%p\n", xprt, cma_id);
-		break;
-
-	case RDMA_CM_EVENT_DEVICE_REMOVAL:
-		dprintk("svcrdma: Device removal xprt=%p, cm_id=%p\n",
-			xprt, cma_id);
-		if (xprt) {
-			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-			svc_xprt_enqueue(&xprt->sc_xprt);
-		}
-		break;
-
 	default:
+		/* NB: No device removal upcall for INADDR_ANY listeners */
 		dprintk("svcrdma: Unexpected event on listening endpoint %p, "
 			"event = %s (%d)\n", cma_id,
 			rdma_event_msg(event->event), event->event);
@@ -584,9 +570,12 @@ static int rdma_listen_handler(struct rdma_cm_id *cma_id,
 static int rdma_cma_handler(struct rdma_cm_id *cma_id,
 			    struct rdma_cm_event *event)
 {
-	struct svc_xprt *xprt = cma_id->context;
-	struct svcxprt_rdma *rdma =
-		container_of(xprt, struct svcxprt_rdma, sc_xprt);
+	struct sockaddr *sap = (struct sockaddr *)&cma_id->route.addr.dst_addr;
+	struct svcxprt_rdma *rdma = cma_id->context;
+	struct svc_xprt *xprt = &rdma->sc_xprt;
+
+	trace_svcrdma_cm_event(event, sap);
+
 	switch (event->event) {
 	case RDMA_CM_EVENT_ESTABLISHED:
 		/* Accept complete */
@@ -599,21 +588,17 @@ static int rdma_cma_handler(struct rdma_cm_id *cma_id,
 	case RDMA_CM_EVENT_DISCONNECTED:
 		dprintk("svcrdma: Disconnect on DTO xprt=%p, cm_id=%p\n",
 			xprt, cma_id);
-		if (xprt) {
-			set_bit(XPT_CLOSE, &xprt->xpt_flags);
-			svc_xprt_enqueue(xprt);
-			svc_xprt_put(xprt);
-		}
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
+		svc_xprt_enqueue(xprt);
+		svc_xprt_put(xprt);
 		break;
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 		dprintk("svcrdma: Device removal cma_id=%p, xprt = %p, "
 			"event = %s (%d)\n", cma_id, xprt,
 			rdma_event_msg(event->event), event->event);
-		if (xprt) {
-			set_bit(XPT_CLOSE, &xprt->xpt_flags);
-			svc_xprt_enqueue(xprt);
-			svc_xprt_put(xprt);
-		}
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
+		svc_xprt_enqueue(xprt);
+		svc_xprt_put(xprt);
 		break;
 	default:
 		dprintk("svcrdma: Unexpected event on DTO endpoint %p, "
@@ -1022,13 +1007,13 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 	while (1) {
 		if ((atomic_sub_return(wr_count, &xprt->sc_sq_avail) < 0)) {
 			atomic_inc(&rdma_stat_sq_starve);
-
-			/* Wait until SQ WR available if SQ still full */
+			trace_svcrdma_sq_full(xprt);
 			atomic_add(wr_count, &xprt->sc_sq_avail);
 			wait_event(xprt->sc_send_wait,
 				   atomic_read(&xprt->sc_sq_avail) > wr_count);
 			if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
 				return -ENOTCONN;
+			trace_svcrdma_sq_retry(xprt);
 			continue;
 		}
 		/* Take a transport ref for each WR posted */
@@ -1037,6 +1022,7 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 
 		/* Bump used SQ WR count and post */
 		ret = ib_post_send(xprt->sc_qp, wr, &bad_wr);
+		trace_svcrdma_post_send(wr, ret);
 		if (ret) {
 			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
 			for (i = 0; i < wr_count; i ++)
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 3d1b277..caca977 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -51,7 +51,10 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/seq_file.h>
+#include <linux/smp.h>
+
 #include <linux/sunrpc/addr.h>
+#include <linux/sunrpc/svc_rdma.h>
 
 #include "xprt_rdma.h"
 #include <trace/events/rpcrdma.h>


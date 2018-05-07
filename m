Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:42029 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752601AbeEGT1N (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:27:13 -0400
Subject: [PATCH v1 04/19] svcrdma: Trace key RPC/RDMA protocol events
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:27:11 -0400
Message-ID: <20180507192711.4608.75635.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This includes:
  * Transport accept and tear-down
  * Decisions about using Write and Reply chunks
  * Each RDMA segment that is handled
  * Whenever an RDMA_ERR is sent

As a clean-up, I've standardized the order of the includes, and
removed some now redundant dprintk call sites.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h           |  262 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   36 ++--
 net/sunrpc/xprtrdma/svc_rdma_rw.c        |   23 ++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   19 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   19 +-
 5 files changed, 311 insertions(+), 48 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 50ed3f8..633520a 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -1,6 +1,8 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /*
- * Copyright (c) 2017 Oracle.  All rights reserved.
+ * Copyright (c) 2017, 2018 Oracle.  All rights reserved.
+ *
+ * Trace point definitions for the "rpcrdma" subsystem.
  */
 #undef TRACE_SYSTEM
 #define TRACE_SYSTEM rpcrdma
@@ -885,6 +887,264 @@
 DEFINE_CB_EVENT(xprtrdma_cb_call);
 DEFINE_CB_EVENT(xprtrdma_cb_reply);
 
+/**
+ ** Server-side RPC/RDMA events
+ **/
+
+DECLARE_EVENT_CLASS(svcrdma_xprt_event,
+	TP_PROTO(
+		const struct svc_xprt *xprt
+	),
+
+	TP_ARGS(xprt),
+
+	TP_STRUCT__entry(
+		__field(const void *, xprt)
+		__string(addr, xprt->xpt_remotebuf)
+	),
+
+	TP_fast_assign(
+		__entry->xprt = xprt;
+		__assign_str(addr, xprt->xpt_remotebuf);
+	),
+
+	TP_printk("xprt=%p addr=%s",
+		__entry->xprt, __get_str(addr)
+	)
+);
+
+#define DEFINE_XPRT_EVENT(name)						\
+		DEFINE_EVENT(svcrdma_xprt_event, svcrdma_xprt_##name,	\
+				TP_PROTO(				\
+					const struct svc_xprt *xprt	\
+				),					\
+				TP_ARGS(xprt))
+
+DEFINE_XPRT_EVENT(accept);
+DEFINE_XPRT_EVENT(fail);
+DEFINE_XPRT_EVENT(free);
+
+TRACE_DEFINE_ENUM(RDMA_MSG);
+TRACE_DEFINE_ENUM(RDMA_NOMSG);
+TRACE_DEFINE_ENUM(RDMA_MSGP);
+TRACE_DEFINE_ENUM(RDMA_DONE);
+TRACE_DEFINE_ENUM(RDMA_ERROR);
+
+#define show_rpcrdma_proc(x)						\
+		__print_symbolic(x,					\
+				{ RDMA_MSG, "RDMA_MSG" },		\
+				{ RDMA_NOMSG, "RDMA_NOMSG" },		\
+				{ RDMA_MSGP, "RDMA_MSGP" },		\
+				{ RDMA_DONE, "RDMA_DONE" },		\
+				{ RDMA_ERROR, "RDMA_ERROR" })
+
+TRACE_EVENT(svcrdma_decode_rqst,
+	TP_PROTO(
+		__be32 *p,
+		unsigned int hdrlen
+	),
+
+	TP_ARGS(p, hdrlen),
+
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, vers)
+		__field(u32, proc)
+		__field(u32, credits)
+		__field(unsigned int, hdrlen)
+	),
+
+	TP_fast_assign(
+		__entry->xid = be32_to_cpup(p++);
+		__entry->vers = be32_to_cpup(p++);
+		__entry->credits = be32_to_cpup(p++);
+		__entry->proc = be32_to_cpup(p);
+		__entry->hdrlen = hdrlen;
+	),
+
+	TP_printk("xid=0x%08x vers=%u credits=%u proc=%s hdrlen=%u",
+		__entry->xid, __entry->vers, __entry->credits,
+		show_rpcrdma_proc(__entry->proc), __entry->hdrlen)
+);
+
+TRACE_EVENT(svcrdma_decode_short,
+	TP_PROTO(
+		unsigned int hdrlen
+	),
+
+	TP_ARGS(hdrlen),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, hdrlen)
+	),
+
+	TP_fast_assign(
+		__entry->hdrlen = hdrlen;
+	),
+
+	TP_printk("hdrlen=%u", __entry->hdrlen)
+);
+
+DECLARE_EVENT_CLASS(svcrdma_badreq_event,
+	TP_PROTO(
+		__be32 *p
+	),
+
+	TP_ARGS(p),
+
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, vers)
+		__field(u32, proc)
+		__field(u32, credits)
+	),
+
+	TP_fast_assign(
+		__entry->xid = be32_to_cpup(p++);
+		__entry->vers = be32_to_cpup(p++);
+		__entry->credits = be32_to_cpup(p++);
+		__entry->proc = be32_to_cpup(p);
+	),
+
+	TP_printk("xid=0x%08x vers=%u credits=%u proc=%u",
+		__entry->xid, __entry->vers, __entry->credits, __entry->proc)
+);
+
+#define DEFINE_BADREQ_EVENT(name)					\
+		DEFINE_EVENT(svcrdma_badreq_event, svcrdma_decode_##name,\
+				TP_PROTO(				\
+					__be32 *p			\
+				),					\
+				TP_ARGS(p))
+
+DEFINE_BADREQ_EVENT(badvers);
+DEFINE_BADREQ_EVENT(drop);
+DEFINE_BADREQ_EVENT(badproc);
+DEFINE_BADREQ_EVENT(parse);
+
+DECLARE_EVENT_CLASS(svcrdma_segment_event,
+	TP_PROTO(
+		u32 handle,
+		u32 length,
+		u64 offset
+	),
+
+	TP_ARGS(handle, length, offset),
+
+	TP_STRUCT__entry(
+		__field(u32, handle)
+		__field(u32, length)
+		__field(u64, offset)
+	),
+
+	TP_fast_assign(
+		__entry->handle = handle;
+		__entry->length = length;
+		__entry->offset = offset;
+	),
+
+	TP_printk("%u@0x%016llx:0x%08x",
+		__entry->length, (unsigned long long)__entry->offset,
+		__entry->handle
+	)
+);
+
+#define DEFINE_SEGMENT_EVENT(name)					\
+		DEFINE_EVENT(svcrdma_segment_event, svcrdma_encode_##name,\
+				TP_PROTO(				\
+					u32 handle,			\
+					u32 length,			\
+					u64 offset			\
+				),					\
+				TP_ARGS(handle, length, offset))
+
+DEFINE_SEGMENT_EVENT(rseg);
+DEFINE_SEGMENT_EVENT(wseg);
+
+DECLARE_EVENT_CLASS(svcrdma_chunk_event,
+	TP_PROTO(
+		u32 length
+	),
+
+	TP_ARGS(length),
+
+	TP_STRUCT__entry(
+		__field(u32, length)
+	),
+
+	TP_fast_assign(
+		__entry->length = length;
+	),
+
+	TP_printk("length=%u",
+		__entry->length
+	)
+);
+
+#define DEFINE_CHUNK_EVENT(name)					\
+		DEFINE_EVENT(svcrdma_chunk_event, svcrdma_encode_##name,\
+				TP_PROTO(				\
+					u32 length			\
+				),					\
+				TP_ARGS(length))
+
+DEFINE_CHUNK_EVENT(pzr);
+DEFINE_CHUNK_EVENT(write);
+DEFINE_CHUNK_EVENT(reply);
+
+TRACE_EVENT(svcrdma_encode_read,
+	TP_PROTO(
+		u32 length,
+		u32 position
+	),
+
+	TP_ARGS(length, position),
+
+	TP_STRUCT__entry(
+		__field(u32, length)
+		__field(u32, position)
+	),
+
+	TP_fast_assign(
+		__entry->length = length;
+		__entry->position = position;
+	),
+
+	TP_printk("length=%u position=%u",
+		__entry->length, __entry->position
+	)
+);
+
+DECLARE_EVENT_CLASS(svcrdma_error_event,
+	TP_PROTO(
+		__be32 xid
+	),
+
+	TP_ARGS(xid),
+
+	TP_STRUCT__entry(
+		__field(u32, xid)
+	),
+
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(xid);
+	),
+
+	TP_printk("xid=0x%08x",
+		__entry->xid
+	)
+);
+
+#define DEFINE_ERROR_EVENT(name)					\
+		DEFINE_EVENT(svcrdma_error_event, svcrdma_err_##name,	\
+				TP_PROTO(				\
+					__be32 xid			\
+				),					\
+				TP_ARGS(xid))
+
+DEFINE_ERROR_EVENT(vers);
+DEFINE_ERROR_EVENT(chunk);
+
 #endif /* _TRACE_RPCRDMA_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 9eae95d..78ca580 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -93,17 +93,19 @@
  * (see rdma_read_complete() below).
  */
 
+#include <linux/spinlock.h>
 #include <asm/unaligned.h>
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
 
-#include <linux/spinlock.h>
-
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/rpc_rdma.h>
 #include <linux/sunrpc/svc_rdma.h>
 
+#include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
+
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 /*
@@ -295,7 +297,6 @@ static int svc_rdma_xdr_decode_req(struct xdr_buf *rq_arg)
 {
 	__be32 *p, *end, *rdma_argp;
 	unsigned int hdr_len;
-	char *proc;
 
 	/* Verify that there's enough bytes for header + something */
 	if (rq_arg->len <= RPCRDMA_HDRLEN_ERR)
@@ -307,10 +308,8 @@ static int svc_rdma_xdr_decode_req(struct xdr_buf *rq_arg)
 
 	switch (*(rdma_argp + 3)) {
 	case rdma_msg:
-		proc = "RDMA_MSG";
 		break;
 	case rdma_nomsg:
-		proc = "RDMA_NOMSG";
 		break;
 
 	case rdma_done:
@@ -340,30 +339,27 @@ static int svc_rdma_xdr_decode_req(struct xdr_buf *rq_arg)
 	hdr_len = (unsigned long)p - (unsigned long)rdma_argp;
 	rq_arg->head[0].iov_len -= hdr_len;
 	rq_arg->len -= hdr_len;
-	dprintk("svcrdma: received %s request for XID 0x%08x, hdr_len=%u\n",
-		proc, be32_to_cpup(rdma_argp), hdr_len);
+	trace_svcrdma_decode_rqst(rdma_argp, hdr_len);
 	return hdr_len;
 
 out_short:
-	dprintk("svcrdma: header too short = %d\n", rq_arg->len);
+	trace_svcrdma_decode_short(rq_arg->len);
 	return -EINVAL;
 
 out_version:
-	dprintk("svcrdma: bad xprt version: %u\n",
-		be32_to_cpup(rdma_argp + 1));
+	trace_svcrdma_decode_badvers(rdma_argp);
 	return -EPROTONOSUPPORT;
 
 out_drop:
-	dprintk("svcrdma: dropping RDMA_DONE/ERROR message\n");
+	trace_svcrdma_decode_drop(rdma_argp);
 	return 0;
 
 out_proc:
-	dprintk("svcrdma: bad rdma procedure (%u)\n",
-		be32_to_cpup(rdma_argp + 3));
+	trace_svcrdma_decode_badproc(rdma_argp);
 	return -EINVAL;
 
 out_inval:
-	dprintk("svcrdma: failed to parse transport header\n");
+	trace_svcrdma_decode_parse(rdma_argp);
 	return -EINVAL;
 }
 
@@ -412,12 +408,16 @@ static void svc_rdma_send_error(struct svcxprt_rdma *xprt,
 	*p++ = *(rdma_argp + 1);
 	*p++ = xprt->sc_fc_credits;
 	*p++ = rdma_error;
-	if (status == -EPROTONOSUPPORT) {
+	switch (status) {
+	case -EPROTONOSUPPORT:
 		*p++ = err_vers;
 		*p++ = rpcrdma_version;
 		*p++ = rpcrdma_version;
-	} else {
+		trace_svcrdma_err_vers(*rdma_argp);
+		break;
+	default:
 		*p++ = err_chunk;
+		trace_svcrdma_err_chunk(*rdma_argp);
 	}
 	length = (unsigned long)p - (unsigned long)err_msgp;
 
@@ -532,8 +532,6 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	}
 	spin_unlock(&rdma_xprt->sc_rq_dto_lock);
 
-	dprintk("svcrdma: recvfrom: ctxt=%p on xprt=%p, rqstp=%p\n",
-		ctxt, rdma_xprt, rqstp);
 	atomic_inc(&rdma_stat_recv);
 
 	svc_rdma_build_arg_xdr(rqstp, ctxt);
@@ -559,8 +557,6 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 
 complete:
 	svc_rdma_put_context(ctxt, 0);
-	dprintk("svcrdma: recvfrom: xprt=%p, rqstp=%p, rq_arg.len=%u\n",
-		rdma_xprt, rqstp, rqstp->rq_arg.len);
 	rqstp->rq_prot = IPPROTO_MAX;
 	svc_xprt_copy_addrs(rqstp, xprt);
 	return rqstp->rq_arg.len;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 12b9a7e..4b9cb54 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -5,11 +5,14 @@
  * Use the core R/W API to move RPC-over-RDMA Read and Write chunks.
  */
 
+#include <rdma/rw.h>
+
 #include <linux/sunrpc/rpc_rdma.h>
 #include <linux/sunrpc/svc_rdma.h>
 #include <linux/sunrpc/debug.h>
 
-#include <rdma/rw.h>
+#include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -437,6 +440,7 @@ static void svc_rdma_pagelist_to_sg(struct svc_rdma_write_info *info,
 		if (ret < 0)
 			goto out_initerr;
 
+		trace_svcrdma_encode_wseg(seg_handle, write_len, seg_offset);
 		list_add(&ctxt->rw_list, &cc->cc_rwctxts);
 		cc->cc_sqecount += ret;
 		if (write_len == seg_length - info->wi_seg_off) {
@@ -526,6 +530,8 @@ int svc_rdma_send_write_chunk(struct svcxprt_rdma *rdma, __be32 *wr_ch,
 	ret = svc_rdma_post_chunk_ctxt(&info->wi_cc);
 	if (ret < 0)
 		goto out_err;
+
+	trace_svcrdma_encode_write(xdr->page_len);
 	return xdr->page_len;
 
 out_err:
@@ -582,6 +588,8 @@ int svc_rdma_send_reply_chunk(struct svcxprt_rdma *rdma, __be32 *rp_ch,
 	ret = svc_rdma_post_chunk_ctxt(&info->wi_cc);
 	if (ret < 0)
 		goto out_err;
+
+	trace_svcrdma_encode_reply(consumed);
 	return consumed;
 
 out_err:
@@ -606,9 +614,6 @@ static int svc_rdma_build_read_segment(struct svc_rdma_read_info *info,
 		goto out_noctx;
 	ctxt->rw_nents = sge_no;
 
-	dprintk("svcrdma: reading segment %u@0x%016llx:0x%08x (%u sges)\n",
-		len, offset, rkey, sge_no);
-
 	sg = ctxt->rw_sg_table.sgl;
 	for (sge_no = 0; sge_no < ctxt->rw_nents; sge_no++) {
 		seg_len = min_t(unsigned int, len,
@@ -686,6 +691,7 @@ static int svc_rdma_build_read_chunk(struct svc_rqst *rqstp,
 		if (ret < 0)
 			break;
 
+		trace_svcrdma_encode_rseg(rs_handle, rs_length, rs_offset);
 		info->ri_chunklen += rs_length;
 	}
 
@@ -706,9 +712,6 @@ static int svc_rdma_build_normal_read_chunk(struct svc_rqst *rqstp,
 	struct svc_rdma_op_ctxt *head = info->ri_readctxt;
 	int ret;
 
-	dprintk("svcrdma: Reading Read chunk at position %u\n",
-		info->ri_position);
-
 	info->ri_pageno = head->hdr_count;
 	info->ri_pageoff = 0;
 
@@ -716,6 +719,8 @@ static int svc_rdma_build_normal_read_chunk(struct svc_rqst *rqstp,
 	if (ret < 0)
 		goto out;
 
+	trace_svcrdma_encode_read(info->ri_chunklen, info->ri_position);
+
 	/* Split the Receive buffer between the head and tail
 	 * buffers at Read chunk's position. XDR roundup of the
 	 * chunk is not included in either the pagelist or in
@@ -764,8 +769,6 @@ static int svc_rdma_build_pz_read_chunk(struct svc_rqst *rqstp,
 	struct svc_rdma_op_ctxt *head = info->ri_readctxt;
 	int ret;
 
-	dprintk("svcrdma: Reading Position Zero Read chunk\n");
-
 	info->ri_pageno = head->hdr_count - 1;
 	info->ri_pageoff = offset_in_page(head->byte_len);
 
@@ -773,6 +776,8 @@ static int svc_rdma_build_pz_read_chunk(struct svc_rqst *rqstp,
 	if (ret < 0)
 		goto out;
 
+	trace_svcrdma_encode_pzr(info->ri_chunklen);
+
 	head->arg.len += info->ri_chunklen;
 	head->arg.buflen += info->ri_chunklen;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 79bd3a3..4c58083 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -99,14 +99,19 @@
  * where two different Write segments send portions of the same page.
  */
 
-#include <linux/sunrpc/debug.h>
-#include <linux/sunrpc/rpc_rdma.h>
 #include <linux/spinlock.h>
 #include <asm/unaligned.h>
+
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
+
+#include <linux/sunrpc/debug.h>
+#include <linux/sunrpc/rpc_rdma.h>
 #include <linux/sunrpc/svc_rdma.h>
 
+#include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
+
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 static u32 xdr_padsize(u32 len)
@@ -524,12 +529,6 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
 	u32 inv_rkey;
 	int ret;
 
-	dprintk("svcrdma: sending %s reply: head=%zu, pagelen=%u, tail=%zu\n",
-		(rp_ch ? "RDMA_NOMSG" : "RDMA_MSG"),
-		rqstp->rq_res.head[0].iov_len,
-		rqstp->rq_res.page_len,
-		rqstp->rq_res.tail[0].iov_len);
-
 	ctxt = svc_rdma_get_context(rdma);
 
 	ret = svc_rdma_map_reply_hdr(rdma, ctxt, rdma_resp,
@@ -580,6 +579,7 @@ static int svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
 	/* Replace the original transport header with an
 	 * RDMA_ERROR response. XID etc are preserved.
 	 */
+	trace_svcrdma_err_chunk(*rdma_resp);
 	p = rdma_resp + 3;
 	*p++ = rdma_error;
 	*p   = err_chunk;
@@ -635,9 +635,6 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	rdma_argp = page_address(rqstp->rq_pages[0]);
 	svc_rdma_get_write_arrays(rdma_argp, &wr_lst, &rp_ch);
 
-	dprintk("svcrdma: preparing response for XID 0x%08x\n",
-		be32_to_cpup(rdma_argp));
-
 	/* Create the RDMA response header. xprt->xpt_mutex,
 	 * acquired in svc_send(), serializes RPC replies. The
 	 * code path below that inserts the credit grant value
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 22e2595..d2cdffa 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -41,21 +41,25 @@
  * Author: Tom Tucker <tom@opengridcomputing.com>
  */
 
-#include <linux/sunrpc/svc_xprt.h>
-#include <linux/sunrpc/addr.h>
-#include <linux/sunrpc/debug.h>
-#include <linux/sunrpc/rpc_rdma.h>
 #include <linux/interrupt.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
+#include <linux/export.h>
+
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
 #include <rdma/rw.h>
+
+#include <linux/sunrpc/addr.h>
+#include <linux/sunrpc/debug.h>
+#include <linux/sunrpc/rpc_rdma.h>
+#include <linux/sunrpc/svc_xprt.h>
 #include <linux/sunrpc/svc_rdma.h>
-#include <linux/export.h>
+
 #include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -862,10 +866,12 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	dprintk("    max_requests    : %d\n", newxprt->sc_max_requests);
 	dprintk("    ord             : %d\n", conn_param.initiator_depth);
 
+	trace_svcrdma_xprt_accept(&newxprt->sc_xprt);
 	return &newxprt->sc_xprt;
 
  errout:
 	dprintk("svcrdma: failure accepting new connection rc=%d.\n", ret);
+	trace_svcrdma_xprt_fail(&newxprt->sc_xprt);
 	/* Take a reference in case the DTO handler runs */
 	svc_xprt_get(&newxprt->sc_xprt);
 	if (newxprt->sc_qp && !IS_ERR(newxprt->sc_qp))
@@ -896,7 +902,6 @@ static void svc_rdma_detach(struct svc_xprt *xprt)
 {
 	struct svcxprt_rdma *rdma =
 		container_of(xprt, struct svcxprt_rdma, sc_xprt);
-	dprintk("svc: svc_rdma_detach(%p)\n", xprt);
 
 	/* Disconnect and flush posted WQE */
 	rdma_disconnect(rdma->sc_cm_id);
@@ -908,7 +913,7 @@ static void __svc_rdma_free(struct work_struct *work)
 		container_of(work, struct svcxprt_rdma, sc_work);
 	struct svc_xprt *xprt = &rdma->sc_xprt;
 
-	dprintk("svcrdma: %s(%p)\n", __func__, rdma);
+	trace_svcrdma_xprt_free(xprt);
 
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
 		ib_drain_qp(rdma->sc_qp);


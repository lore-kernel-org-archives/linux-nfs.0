Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:43688 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756004AbdLTVbG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:31:06 -0500
Subject: [PATCH v1 06/12] xprtrdma: Add trace points in reply decoder path
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:31:04 -0500
Message-ID: <20171220213104.29321.13167.stgit@manet.1015granger.net>
In-Reply-To: <20171220210236.29321.59307.stgit@manet.1015granger.net>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This includes decoding Write and Reply chunks, and fixing up inline
payloads.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   93 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c |   29 ++++--------
 2 files changed, 102 insertions(+), 20 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index bc7f2db..8176215 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -452,6 +452,99 @@
 DEFINE_REPLY_EVENT(xprtrdma_reply_short);
 DEFINE_REPLY_EVENT(xprtrdma_reply_hdr);
 
+TRACE_EVENT(xprtrdma_fixup,
+	TP_PROTO(
+		const struct rpc_rqst *rqst,
+		int len,
+		int hdrlen
+	),
+
+	TP_ARGS(rqst, len, hdrlen),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(const void *, base)
+		__field(int, len)
+		__field(int, hdrlen)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = rqst->rq_task->tk_pid;
+		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
+		__entry->base = rqst->rq_rcv_buf.head[0].iov_base;
+		__entry->len = len;
+		__entry->hdrlen = hdrlen;
+	),
+
+	TP_printk("task:%u@%u base=%p len=%d hdrlen=%d",
+		__entry->task_id, __entry->client_id,
+		__entry->base, __entry->len, __entry->hdrlen
+	)
+);
+
+TRACE_EVENT(xprtrdma_fixup_pg,
+	TP_PROTO(
+		const struct rpc_rqst *rqst,
+		int pageno,
+		const void *pos,
+		int len,
+		int curlen
+	),
+
+	TP_ARGS(rqst, pageno, pos, len, curlen),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(const void *, pos)
+		__field(int, pageno)
+		__field(int, len)
+		__field(int, curlen)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = rqst->rq_task->tk_pid;
+		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
+		__entry->pos = pos;
+		__entry->pageno = pageno;
+		__entry->len = len;
+		__entry->curlen = curlen;
+	),
+
+	TP_printk("task:%u@%u pageno=%d pos=%p len=%d curlen=%d",
+		__entry->task_id, __entry->client_id,
+		__entry->pageno, __entry->pos, __entry->len, __entry->curlen
+	)
+);
+
+TRACE_EVENT(xprtrdma_decode_seg,
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
 #endif /* _TRACE_RPCRDMA_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 634496c..1ae9b41 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -914,8 +914,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	curlen = rqst->rq_rcv_buf.head[0].iov_len;
 	if (curlen > copy_len)
 		curlen = copy_len;
-	dprintk("RPC:       %s: srcp 0x%p len %d hdrlen %d\n",
-		__func__, srcp, copy_len, curlen);
+	trace_xprtrdma_fixup(rqst, copy_len, curlen);
 	srcp += curlen;
 	copy_len -= curlen;
 
@@ -935,9 +934,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 			if (curlen > pagelist_len)
 				curlen = pagelist_len;
 
-			dprintk("RPC:       %s: page %d"
-				" srcp 0x%p len %d curlen %d\n",
-				__func__, i, srcp, copy_len, curlen);
+			trace_xprtrdma_fixup_pg(rqst, i, srcp,
+						copy_len, curlen);
 			destp = kmap_atomic(ppages[i]);
 			memcpy(destp + page_base, srcp, curlen);
 			flush_dcache_page(ppages[i]);
@@ -1028,26 +1026,19 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 static int decode_rdma_segment(struct xdr_stream *xdr, u32 *length)
 {
+	u32 handle;
+	u64 offset;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4 * sizeof(*p));
 	if (unlikely(!p))
 		return -EIO;
 
-	ifdebug(FACILITY) {
-		u64 offset;
-		u32 handle;
-
-		handle = be32_to_cpup(p++);
-		*length = be32_to_cpup(p++);
-		xdr_decode_hyper(p, &offset);
-		dprintk("RPC:       %s:   segment %u@0x%016llx:0x%08x\n",
-			__func__, *length, (unsigned long long)offset,
-			handle);
-	} else {
-		*length = be32_to_cpup(p + 1);
-	}
+	handle = be32_to_cpup(p++);
+	*length = be32_to_cpup(p++);
+	xdr_decode_hyper(p, &offset);
 
+	trace_xprtrdma_decode_seg(handle, *length, offset);
 	return 0;
 }
 
@@ -1068,8 +1059,6 @@ static int decode_write_chunk(struct xdr_stream *xdr, u32 *length)
 		*length += seglength;
 	}
 
-	dprintk("RPC:       %s: segcount=%u, %u bytes\n",
-		__func__, be32_to_cpup(p), *length);
 	return 0;
 }
 


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:60183 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932117Ab2BNXB2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Feb 2012 18:01:28 -0500
From: Tom Tucker <tom@ogc.us>
To: bfields@fieldses.org
Cc: tom@ogc.us, trond.myklebust@netapp.com, dan.carpenter@oracle.com,
        linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH] svcrdma: Cleanup sparse warnings in the svcrdma module
Date: Tue, 14 Feb 2012 17:01:25 -0600
Message-Id: <1329260485-16994-1-git-send-email-tom@ogc.us>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The svcrdma transport was un-marshalling requests in-place. This resulted
in sparse warnings due to __beXX data containing both NBO and HBO data.

The code has been restructured to do byte-swapping as the header is
parsed instead of when the header is validated immediately after receipt.

Also moved extern declarations for the workqueue and memory pools to the
private header file.

Signed-off-by: Tom Tucker <tom@ogc.us>
---
 include/linux/sunrpc/svc_rdma.h          |    8 ++--
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |   68 +++++++----------------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   24 ++++++-----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   26 ++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 +----
 net/sunrpc/xprtrdma/xprt_rdma.h          |    7 +++
 6 files changed, 56 insertions(+), 87 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index c14fe86..4f9a63a 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -238,7 +238,7 @@ svc_rdma_get_read_chunk(struct rpcrdma_msg *rmsgp)
 	struct rpcrdma_read_chunk *ch =
 		(struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
 
-	if (ch->rc_discrim == 0)
+	if (ch->rc_discrim == xdr_zero)
 		return NULL;
 
 	return ch;
@@ -277,7 +277,7 @@ svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp)
 
 	rch = svc_rdma_get_read_chunk(rmsgp);
 	if (rch) {
-		while (rch->rc_discrim)
+		while (rch->rc_discrim != xdr_zero)
 			rch++;
 
 		/* The reply list follows an empty write array located
@@ -292,7 +292,7 @@ svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp)
 	if (wr_ary) {
 		rp_ary = (struct rpcrdma_write_array *)
 			&wr_ary->
-			wc_array[wr_ary->wc_nchunks].wc_target.rs_length;
+			wc_array[ntohl(wr_ary->wc_nchunks)].wc_target.rs_length;
 
 		goto found_it;
 	}
@@ -302,7 +302,7 @@ svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp)
 		&rmsgp->rm_body.rm_chunks[2];
 
  found_it:
-	if (rp_ary->wc_discrim == 0)
+	if (rp_ary->wc_discrim == xdr_zero)
 		return NULL;
 
 	return rp_ary;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 9530ef2..8020b58 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -60,21 +60,11 @@ static u32 *decode_read_list(u32 *va, u32 *vaend)
 	struct rpcrdma_read_chunk *ch = (struct rpcrdma_read_chunk *)va;
 
 	while (ch->rc_discrim != xdr_zero) {
-		u64 ch_offset;
-
 		if (((unsigned long)ch + sizeof(struct rpcrdma_read_chunk)) >
 		    (unsigned long)vaend) {
 			dprintk("svcrdma: vaend=%p, ch=%p\n", vaend, ch);
 			return NULL;
 		}
-
-		ch->rc_discrim = ntohl(ch->rc_discrim);
-		ch->rc_position = ntohl(ch->rc_position);
-		ch->rc_target.rs_handle = ntohl(ch->rc_target.rs_handle);
-		ch->rc_target.rs_length = ntohl(ch->rc_target.rs_length);
-		va = (u32 *)&ch->rc_target.rs_offset;
-		xdr_decode_hyper(va, &ch_offset);
-		put_unaligned(ch_offset, (u64 *)va);
 		ch++;
 	}
 	return (u32 *)&ch->rc_position;
@@ -90,8 +80,8 @@ void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *ch,
 	/* compute the number of bytes represented by read chunks */
 	*byte_count = 0;
 	*ch_count = 0;
-	for (; ch->rc_discrim != 0; ch++) {
-		*byte_count = *byte_count + ch->rc_target.rs_length;
+	for (; ch->rc_discrim != xdr_zero; ch++) {
+		*byte_count = *byte_count + ntohl(ch->rc_target.rs_length);
 		*ch_count = *ch_count + 1;
 	}
 }
@@ -108,7 +98,8 @@ void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *ch,
  */
 static u32 *decode_write_list(u32 *va, u32 *vaend)
 {
-	int ch_no;
+	int nchunks;
+
 	struct rpcrdma_write_array *ary =
 		(struct rpcrdma_write_array *)va;
 
@@ -121,37 +112,24 @@ static u32 *decode_write_list(u32 *va, u32 *vaend)
 		dprintk("svcrdma: ary=%p, vaend=%p\n", ary, vaend);
 		return NULL;
 	}
-	ary->wc_discrim = ntohl(ary->wc_discrim);
-	ary->wc_nchunks = ntohl(ary->wc_nchunks);
+	nchunks = ntohl(ary->wc_nchunks);
 	if (((unsigned long)&ary->wc_array[0] +
-	     (sizeof(struct rpcrdma_write_chunk) * ary->wc_nchunks)) >
+	     (sizeof(struct rpcrdma_write_chunk) * nchunks)) >
 	    (unsigned long)vaend) {
 		dprintk("svcrdma: ary=%p, wc_nchunks=%d, vaend=%p\n",
-			ary, ary->wc_nchunks, vaend);
+			ary, nchunks, vaend);
 		return NULL;
 	}
-	for (ch_no = 0; ch_no < ary->wc_nchunks; ch_no++) {
-		u64 ch_offset;
-
-		ary->wc_array[ch_no].wc_target.rs_handle =
-			ntohl(ary->wc_array[ch_no].wc_target.rs_handle);
-		ary->wc_array[ch_no].wc_target.rs_length =
-			ntohl(ary->wc_array[ch_no].wc_target.rs_length);
-		va = (u32 *)&ary->wc_array[ch_no].wc_target.rs_offset;
-		xdr_decode_hyper(va, &ch_offset);
-		put_unaligned(ch_offset, (u64 *)va);
-	}
-
 	/*
 	 * rs_length is the 2nd 4B field in wc_target and taking its
 	 * address skips the list terminator
 	 */
-	return (u32 *)&ary->wc_array[ch_no].wc_target.rs_length;
+	return (u32 *)&ary->wc_array[nchunks].wc_target.rs_length;
 }
 
 static u32 *decode_reply_array(u32 *va, u32 *vaend)
 {
-	int ch_no;
+	int nchunks;
 	struct rpcrdma_write_array *ary =
 		(struct rpcrdma_write_array *)va;
 
@@ -164,28 +142,15 @@ static u32 *decode_reply_array(u32 *va, u32 *vaend)
 		dprintk("svcrdma: ary=%p, vaend=%p\n", ary, vaend);
 		return NULL;
 	}
-	ary->wc_discrim = ntohl(ary->wc_discrim);
-	ary->wc_nchunks = ntohl(ary->wc_nchunks);
+	nchunks = ntohl(ary->wc_nchunks);
 	if (((unsigned long)&ary->wc_array[0] +
-	     (sizeof(struct rpcrdma_write_chunk) * ary->wc_nchunks)) >
+	     (sizeof(struct rpcrdma_write_chunk) * nchunks)) >
 	    (unsigned long)vaend) {
 		dprintk("svcrdma: ary=%p, wc_nchunks=%d, vaend=%p\n",
-			ary, ary->wc_nchunks, vaend);
+			ary, nchunks, vaend);
 		return NULL;
 	}
-	for (ch_no = 0; ch_no < ary->wc_nchunks; ch_no++) {
-		u64 ch_offset;
-
-		ary->wc_array[ch_no].wc_target.rs_handle =
-			ntohl(ary->wc_array[ch_no].wc_target.rs_handle);
-		ary->wc_array[ch_no].wc_target.rs_length =
-			ntohl(ary->wc_array[ch_no].wc_target.rs_length);
-		va = (u32 *)&ary->wc_array[ch_no].wc_target.rs_offset;
-		xdr_decode_hyper(va, &ch_offset);
-		put_unaligned(ch_offset, (u64 *)va);
-	}
-
-	return (u32 *)&ary->wc_array[ch_no];
+	return (u32 *)&ary->wc_array[nchunks];
 }
 
 int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req,
@@ -386,13 +351,14 @@ void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *ary,
 
 void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *ary,
 				     int chunk_no,
-				     u32 rs_handle, u64 rs_offset,
+				     __be32 rs_handle,
+				     __be64 rs_offset,
 				     u32 write_len)
 {
 	struct rpcrdma_segment *seg = &ary->wc_array[chunk_no].wc_target;
-	seg->rs_handle = htonl(rs_handle);
+	seg->rs_handle = rs_handle;
+	seg->rs_offset = rs_offset;
 	seg->rs_length = htonl(write_len);
-	xdr_encode_hyper((u32 *) &seg->rs_offset, rs_offset);
 }
 
 void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *xprt,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index df67211..b708c06 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -147,7 +147,7 @@ static int map_read_chunks(struct svcxprt_rdma *xprt,
 	page_off = 0;
 	ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
 	ch_no = 0;
-	ch_bytes = ch->rc_target.rs_length;
+	ch_bytes = ntohl(ch->rc_target.rs_length);
 	head->arg.head[0] = rqstp->rq_arg.head[0];
 	head->arg.tail[0] = rqstp->rq_arg.tail[0];
 	head->arg.pages = &head->pages[head->count];
@@ -183,7 +183,7 @@ static int map_read_chunks(struct svcxprt_rdma *xprt,
 			ch_no++;
 			ch++;
 			chl_map->ch[ch_no].start = sge_no;
-			ch_bytes = ch->rc_target.rs_length;
+			ch_bytes = ntohl(ch->rc_target.rs_length);
 			/* If bytes remaining account for next chunk */
 			if (byte_count) {
 				head->arg.page_len += ch_bytes;
@@ -281,11 +281,12 @@ static int fast_reg_read_chunks(struct svcxprt_rdma *xprt,
 	offset = 0;
 	ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
 	for (ch_no = 0; ch_no < ch_count; ch_no++) {
+		int len = ntohl(ch->rc_target.rs_length);
 		rpl_map->sge[ch_no].iov_base = frmr->kva + offset;
-		rpl_map->sge[ch_no].iov_len = ch->rc_target.rs_length;
+		rpl_map->sge[ch_no].iov_len = len;
 		chl_map->ch[ch_no].count = 1;
 		chl_map->ch[ch_no].start = ch_no;
-		offset += ch->rc_target.rs_length;
+		offset += len;
 		ch++;
 	}
 
@@ -316,7 +317,7 @@ static int rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
 	for (i = 0; i < count; i++) {
 		ctxt->sge[i].length = 0; /* in case map fails */
 		if (!frmr) {
-			BUG_ON(0 == virt_to_page(vec[i].iov_base));
+			BUG_ON(NULL == virt_to_page(vec[i].iov_base));
 			off = (unsigned long)vec[i].iov_base & ~PAGE_MASK;
 			ctxt->sge[i].addr =
 				ib_dma_map_page(xprt->sc_cm_id->device,
@@ -425,7 +426,8 @@ static int rdma_read_xdr(struct svcxprt_rdma *xprt,
 	ch_no = 0;
 
 	for (ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
-	     ch->rc_discrim != 0; ch++, ch_no++) {
+	     ch->rc_discrim != xdr_zero; ch++, ch_no++) {
+		u64 rs_offset;
 next_sge:
 		ctxt = svc_rdma_get_context(xprt);
 		ctxt->direction = DMA_FROM_DEVICE;
@@ -440,10 +442,10 @@ next_sge:
 		read_wr.opcode = IB_WR_RDMA_READ;
 		ctxt->wr_op = read_wr.opcode;
 		read_wr.send_flags = IB_SEND_SIGNALED;
-		read_wr.wr.rdma.rkey = ch->rc_target.rs_handle;
-		read_wr.wr.rdma.remote_addr =
-			get_unaligned(&(ch->rc_target.rs_offset)) +
-			sgl_offset;
+		read_wr.wr.rdma.rkey = ntohl(ch->rc_target.rs_handle);
+		xdr_decode_hyper((__be32 *)&ch->rc_target.rs_offset,
+				 &rs_offset);
+		read_wr.wr.rdma.remote_addr = rs_offset + sgl_offset;
 		read_wr.sg_list = ctxt->sge;
 		read_wr.num_sge =
 			rdma_read_max_sge(xprt, chl_map->ch[ch_no].count);
@@ -456,7 +458,7 @@ next_sge:
 			svc_rdma_put_context(ctxt, 0);
 			goto out;
 		}
-		if (((ch+1)->rc_discrim == 0) &&
+		if (((ch+1)->rc_discrim == xdr_zero) &&
 		    (read_wr.num_sge == chl_map->ch[ch_no].count)) {
 			/*
 			 * Mark the last RDMA_READ with a bit to
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 249a835..42eb7ba 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -409,21 +409,21 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 		u64 rs_offset;
 
 		arg_ch = &arg_ary->wc_array[chunk_no].wc_target;
-		write_len = min(xfer_len, arg_ch->rs_length);
+		write_len = min(xfer_len, ntohl(arg_ch->rs_length));
 
 		/* Prepare the response chunk given the length actually
 		 * written */
-		rs_offset = get_unaligned(&(arg_ch->rs_offset));
+		xdr_decode_hyper((__be32 *)&arg_ch->rs_offset, &rs_offset);
 		svc_rdma_xdr_encode_array_chunk(res_ary, chunk_no,
-					    arg_ch->rs_handle,
-					    rs_offset,
-					    write_len);
+						arg_ch->rs_handle,
+						arg_ch->rs_offset,
+						write_len);
 		chunk_off = 0;
 		while (write_len) {
 			int this_write;
 			this_write = min(write_len, max_write);
 			ret = send_write(xprt, rqstp,
-					 arg_ch->rs_handle,
+					 ntohl(arg_ch->rs_handle),
 					 rs_offset + chunk_off,
 					 xdr_off,
 					 this_write,
@@ -457,6 +457,7 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	u32 xdr_off;
 	int chunk_no;
 	int chunk_off;
+	int nchunks;
 	struct rpcrdma_segment *ch;
 	struct rpcrdma_write_array *arg_ary;
 	struct rpcrdma_write_array *res_ary;
@@ -476,26 +477,27 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 		max_write = xprt->sc_max_sge * PAGE_SIZE;
 
 	/* xdr offset starts at RPC message */
+	nchunks = ntohl(arg_ary->wc_nchunks);
 	for (xdr_off = 0, chunk_no = 0;
-	     xfer_len && chunk_no < arg_ary->wc_nchunks;
+	     xfer_len && chunk_no < nchunks;
 	     chunk_no++) {
 		u64 rs_offset;
 		ch = &arg_ary->wc_array[chunk_no].wc_target;
-		write_len = min(xfer_len, ch->rs_length);
+		write_len = min(xfer_len, htonl(ch->rs_length));
 
 		/* Prepare the reply chunk given the length actually
 		 * written */
-		rs_offset = get_unaligned(&(ch->rs_offset));
+		xdr_decode_hyper((__be32 *)&ch->rs_offset, &rs_offset);
 		svc_rdma_xdr_encode_array_chunk(res_ary, chunk_no,
-					    ch->rs_handle, rs_offset,
-					    write_len);
+						ch->rs_handle, ch->rs_offset,
+						write_len);
 		chunk_off = 0;
 		while (write_len) {
 			int this_write;
 
 			this_write = min(write_len, max_write);
 			ret = send_write(xprt, rqstp,
-					 ch->rs_handle,
+					 ntohl(ch->rs_handle),
 					 rs_offset + chunk_off,
 					 xdr_off,
 					 this_write,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 894cb42..73b428b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -51,6 +51,7 @@
 #include <rdma/rdma_cm.h>
 #include <linux/sunrpc/svc_rdma.h>
 #include <linux/export.h>
+#include "xprt_rdma.h"
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -90,12 +91,6 @@ struct svc_xprt_class svc_rdma_class = {
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
 
-/* WR context cache. Created in svc_rdma.c  */
-extern struct kmem_cache *svc_rdma_ctxt_cachep;
-
-/* Workqueue created in svc_rdma.c */
-extern struct workqueue_struct *svc_rdma_wq;
-
 struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 {
 	struct svc_rdma_op_ctxt *ctxt;
@@ -150,9 +145,6 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 	atomic_dec(&xprt->sc_ctxt_used);
 }
 
-/* Temporary NFS request map cache. Created in svc_rdma.c  */
-extern struct kmem_cache *svc_rdma_map_cachep;
-
 /*
  * Temporary NFS req mappings are shared across all transport
  * instances. These are short lived and should be bounded by the number
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 08c5d5a..9a66c95 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -343,4 +343,11 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
  */
 int rpcrdma_marshal_req(struct rpc_rqst *);
 
+/* Temporary NFS request map cache. Created in svc_rdma.c  */
+extern struct kmem_cache *svc_rdma_map_cachep;
+/* WR context cache. Created in svc_rdma.c  */
+extern struct kmem_cache *svc_rdma_ctxt_cachep;
+/* Workqueue created in svc_rdma.c */
+extern struct workqueue_struct *svc_rdma_wq;
+
 #endif				/* _LINUX_SUNRPC_XPRT_RDMA_H */
-- 
1.7.3.1


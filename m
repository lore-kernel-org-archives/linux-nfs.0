Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34686 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdAXUe5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 15:34:57 -0500
Subject: [PATCH v1 3/7] svcrdma: Clean up RPC-over-RDMA Call header decoder
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 24 Jan 2017 15:34:55 -0500
Message-ID: <20170124203455.11807.53072.stgit@klimt.1015granger.net>
In-Reply-To: <20170124193242.11807.91861.stgit@klimt.1015granger.net>
References: <20170124193242.11807.91861.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace C structure-based XDR decoding with pointer arithmetic.
Pointer arithmetic is considered more portable.

Rename the "decode" functions. Nothing is decoded here, they
perform only transport header sanity checking. Use existing XDR
naming conventions to help readability.

Straight-line the hot path:
 - relocate the dprintk call sites out of line
 - remove unnecessary byte-swapping
 - reduce count of conditional branches

Deprecate RDMA_MSGP. It's not properly spec'd by RFC5666, and
therefore never used by any V1 client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_marshal.c |  232 +++++++++++---------------------
 1 file changed, 79 insertions(+), 153 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 5efa019..7c8d60f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2016 Oracle. All rights reserved.
  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
@@ -47,102 +48,43 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
-/*
- * Decodes a read chunk list. The expected format is as follows:
- *    descrim  : xdr_one
- *    position : __be32 offset into XDR stream
- *    handle   : __be32 RKEY
- *    . . .
- *  end-of-list: xdr_zero
- */
-static __be32 *decode_read_list(__be32 *va, __be32 *vaend)
+static __be32 *xdr_check_read_list(__be32 *p, __be32 *end)
 {
-	struct rpcrdma_read_chunk *ch = (struct rpcrdma_read_chunk *)va;
+	__be32 *next;
 
-	while (ch->rc_discrim != xdr_zero) {
-		if (((unsigned long)ch + sizeof(struct rpcrdma_read_chunk)) >
-		    (unsigned long)vaend) {
-			dprintk("svcrdma: vaend=%p, ch=%p\n", vaend, ch);
+	while (*p++ != xdr_zero) {
+		next = p + rpcrdma_readchunk_maxsz - 1;
+		if (next > end)
 			return NULL;
-		}
-		ch++;
+		p = next;
 	}
-	return &ch->rc_position;
+	return p;
 }
 
-/*
- * Decodes a write chunk list. The expected format is as follows:
- *    descrim  : xdr_one
- *    nchunks  : <count>
- *       handle   : __be32 RKEY           ---+
- *       length   : __be32 <len of segment>  |
- *       offset   : remove va                + <count>
- *       . . .                               |
- *                                        ---+
- */
-static __be32 *decode_write_list(__be32 *va, __be32 *vaend)
+static __be32 *xdr_check_write_list(__be32 *p, __be32 *end)
 {
-	unsigned long start, end;
-	int nchunks;
-
-	struct rpcrdma_write_array *ary =
-		(struct rpcrdma_write_array *)va;
-
-	/* Check for not write-array */
-	if (ary->wc_discrim == xdr_zero)
-		return &ary->wc_nchunks;
+	__be32 *next;
 
-	if ((unsigned long)ary + sizeof(struct rpcrdma_write_array) >
-	    (unsigned long)vaend) {
-		dprintk("svcrdma: ary=%p, vaend=%p\n", ary, vaend);
-		return NULL;
-	}
-	nchunks = be32_to_cpu(ary->wc_nchunks);
-
-	start = (unsigned long)&ary->wc_array[0];
-	end = (unsigned long)vaend;
-	if (nchunks < 0 ||
-	    nchunks > (SIZE_MAX - start) / sizeof(struct rpcrdma_write_chunk) ||
-	    (start + (sizeof(struct rpcrdma_write_chunk) * nchunks)) > end) {
-		dprintk("svcrdma: ary=%p, wc_nchunks=%d, vaend=%p\n",
-			ary, nchunks, vaend);
-		return NULL;
+	while (*p++ != xdr_zero) {
+		next = p + 1 + be32_to_cpup(p) * rpcrdma_segment_maxsz;
+		if (next > end)
+			return NULL;
+		p = next;
 	}
-	/*
-	 * rs_length is the 2nd 4B field in wc_target and taking its
-	 * address skips the list terminator
-	 */
-	return &ary->wc_array[nchunks].wc_target.rs_length;
+	return p;
 }
 
-static __be32 *decode_reply_array(__be32 *va, __be32 *vaend)
+static __be32 *xdr_check_reply_chunk(__be32 *p, __be32 *end)
 {
-	unsigned long start, end;
-	int nchunks;
-	struct rpcrdma_write_array *ary =
-		(struct rpcrdma_write_array *)va;
-
-	/* Check for no reply-array */
-	if (ary->wc_discrim == xdr_zero)
-		return &ary->wc_nchunks;
-
-	if ((unsigned long)ary + sizeof(struct rpcrdma_write_array) >
-	    (unsigned long)vaend) {
-		dprintk("svcrdma: ary=%p, vaend=%p\n", ary, vaend);
-		return NULL;
-	}
-	nchunks = be32_to_cpu(ary->wc_nchunks);
-
-	start = (unsigned long)&ary->wc_array[0];
-	end = (unsigned long)vaend;
-	if (nchunks < 0 ||
-	    nchunks > (SIZE_MAX - start) / sizeof(struct rpcrdma_write_chunk) ||
-	    (start + (sizeof(struct rpcrdma_write_chunk) * nchunks)) > end) {
-		dprintk("svcrdma: ary=%p, wc_nchunks=%d, vaend=%p\n",
-			ary, nchunks, vaend);
-		return NULL;
+	__be32 *next;
+
+	if (*p++ != xdr_zero) {
+		next = p + 1 + be32_to_cpup(p) * rpcrdma_segment_maxsz;
+		if (next > end)
+			return NULL;
+		p = next;
 	}
-	return (__be32 *)&ary->wc_array[nchunks];
+	return p;
 }
 
 /**
@@ -158,87 +100,71 @@ static __be32 *decode_reply_array(__be32 *va, __be32 *vaend)
  */
 int svc_rdma_xdr_decode_req(struct xdr_buf *rq_arg)
 {
-	struct rpcrdma_msg *rmsgp;
-	__be32 *va, *vaend;
-	unsigned int len;
-	u32 hdr_len;
+	__be32 *p, *end, *rdma_argp;
+	unsigned int hdr_len;
 
 	/* Verify that there's enough bytes for header + something */
-	if (rq_arg->len <= RPCRDMA_HDRLEN_ERR) {
-		dprintk("svcrdma: header too short = %d\n",
-			rq_arg->len);
-		return -EINVAL;
-	}
+	if (rq_arg->len <= RPCRDMA_HDRLEN_ERR)
+		goto out_short;
 
-	rmsgp = (struct rpcrdma_msg *)rq_arg->head[0].iov_base;
-	if (rmsgp->rm_vers != rpcrdma_version) {
-		dprintk("%s: bad version %u\n", __func__,
-			be32_to_cpu(rmsgp->rm_vers));
-		return -EPROTONOSUPPORT;
-	}
+	rdma_argp = rq_arg->head[0].iov_base;
+	if (*(rdma_argp + 1) != rpcrdma_version)
+		goto out_version;
 
-	switch (be32_to_cpu(rmsgp->rm_type)) {
-	case RDMA_MSG:
-	case RDMA_NOMSG:
+	switch (*(rdma_argp + 3)) {
+	case rdma_msg:
+	case rdma_nomsg:
 		break;
 
-	case RDMA_DONE:
-		/* Just drop it */
-		dprintk("svcrdma: dropping RDMA_DONE message\n");
-		return 0;
-
-	case RDMA_ERROR:
-		/* Possible if this is a backchannel reply.
-		 * XXX: We should cancel this XID, though.
-		 */
-		dprintk("svcrdma: dropping RDMA_ERROR message\n");
-		return 0;
-
-	case RDMA_MSGP:
-		/* Pull in the extra for the padded case, bump our pointer */
-		rmsgp->rm_body.rm_padded.rm_align =
-			be32_to_cpu(rmsgp->rm_body.rm_padded.rm_align);
-		rmsgp->rm_body.rm_padded.rm_thresh =
-			be32_to_cpu(rmsgp->rm_body.rm_padded.rm_thresh);
-
-		va = &rmsgp->rm_body.rm_padded.rm_pempty[4];
-		rq_arg->head[0].iov_base = va;
-		len = (u32)((unsigned long)va - (unsigned long)rmsgp);
-		rq_arg->head[0].iov_len -= len;
-		if (len > rq_arg->len)
-			return -EINVAL;
-		return len;
-	default:
-		dprintk("svcrdma: bad rdma procedure (%u)\n",
-			be32_to_cpu(rmsgp->rm_type));
-		return -EINVAL;
-	}
+	case rdma_done:
+		goto out_drop;
 
-	/* The chunk list may contain either a read chunk list or a write
-	 * chunk list and a reply chunk list.
-	 */
-	va = &rmsgp->rm_body.rm_chunks[0];
-	vaend = (__be32 *)((unsigned long)rmsgp + rq_arg->len);
-	va = decode_read_list(va, vaend);
-	if (!va) {
-		dprintk("svcrdma: failed to decode read list\n");
-		return -EINVAL;
-	}
-	va = decode_write_list(va, vaend);
-	if (!va) {
-		dprintk("svcrdma: failed to decode write list\n");
-		return -EINVAL;
-	}
-	va = decode_reply_array(va, vaend);
-	if (!va) {
-		dprintk("svcrdma: failed to decode reply chunk\n");
-		return -EINVAL;
+	case rdma_error:
+		goto out_drop;
+
+	default:
+		goto out_proc;
 	}
 
-	rq_arg->head[0].iov_base = va;
-	hdr_len = (unsigned long)va - (unsigned long)rmsgp;
+	end = (__be32 *)((unsigned long)rdma_argp + rq_arg->len);
+	p = xdr_check_read_list(rdma_argp + 4, end);
+	if (!p)
+		goto out_inval;
+	p = xdr_check_write_list(p, end);
+	if (!p)
+		goto out_inval;
+	p = xdr_check_reply_chunk(p, end);
+	if (!p)
+		goto out_inval;
+	if (p > end)
+		goto out_inval;
+
+	rq_arg->head[0].iov_base = p;
+	hdr_len = (unsigned long)p - (unsigned long)rdma_argp;
 	rq_arg->head[0].iov_len -= hdr_len;
 	return hdr_len;
+
+out_short:
+	dprintk("svcrdma: header too short = %d\n", rq_arg->len);
+	return -EINVAL;
+
+out_version:
+	dprintk("svcrdma: bad xprt version: %u\n",
+		be32_to_cpup(rdma_argp + 1));
+	return -EPROTONOSUPPORT;
+
+out_drop:
+	dprintk("svcrdma: dropping RDMA_DONE/ERROR message\n");
+	return 0;
+
+out_proc:
+	dprintk("svcrdma: bad rdma procedure (%u)\n",
+		be32_to_cpup(rdma_argp + 3));
+	return -EINVAL;
+
+out_inval:
+	dprintk("svcrdma: failed to parse transport header\n");
+	return -EINVAL;
 }
 
 int svc_rdma_xdr_encode_error(struct svcxprt_rdma *xprt,


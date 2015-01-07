Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:36968 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406AbbAGXMF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 18:12:05 -0500
Received: by mail-ie0-f175.google.com with SMTP id x19so6643101ier.6
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 15:12:04 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id f1sm7840304iga.1.2015.01.07.15.12.03
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 15:12:03 -0800 (PST)
Subject: [PATCH v1 02/20] xprtrdma: Modernize htonl and ntohl
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 07 Jan 2015 18:12:03 -0500
Message-ID: <20150107231202.13466.56693.stgit@manet.1015granger.net>
In-Reply-To: <20150107230859.13466.67723.stgit@manet.1015granger.net>
References: <20150107230859.13466.67723.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace htonl and ntohl with the be32 equivalents.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/rpc_rdma.h |    9 +++++++
 include/linux/sunrpc/svc_rdma.h |    2 --
 net/sunrpc/xprtrdma/rpc_rdma.c  |   48 +++++++++++++++++++++------------------
 3 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index b78f16b..1578ed2 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -42,6 +42,9 @@
 
 #include <linux/types.h>
 
+#define RPCRDMA_VERSION		1
+#define rpcrdma_version		cpu_to_be32(RPCRDMA_VERSION)
+
 struct rpcrdma_segment {
 	__be32 rs_handle;	/* Registered memory handle */
 	__be32 rs_length;	/* Length of the chunk in bytes */
@@ -115,4 +118,10 @@ enum rpcrdma_proc {
 	RDMA_ERROR = 4		/* An RPC RDMA encoding error */
 };
 
+#define rdma_msg	cpu_to_be32(RDMA_MSG)
+#define rdma_nomsg	cpu_to_be32(RDMA_NOMSG)
+#define rdma_msgp	cpu_to_be32(RDMA_MSGP)
+#define rdma_done	cpu_to_be32(RDMA_DONE)
+#define rdma_error	cpu_to_be32(RDMA_ERROR)
+
 #endif				/* _LINUX_SUNRPC_RPC_RDMA_H */
diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 975da75..ddfe88f 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -63,8 +63,6 @@ extern atomic_t rdma_stat_rq_prod;
 extern atomic_t rdma_stat_sq_poll;
 extern atomic_t rdma_stat_sq_prod;
 
-#define RPCRDMA_VERSION 1
-
 /*
  * Contexts are built when an RDMA request is created and are a
  * record of the resources that can be recovered when the request
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index df01d12..a6fb30b 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -209,9 +209,11 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 		if (cur_rchunk) {	/* read */
 			cur_rchunk->rc_discrim = xdr_one;
 			/* all read chunks have the same "position" */
-			cur_rchunk->rc_position = htonl(pos);
-			cur_rchunk->rc_target.rs_handle = htonl(seg->mr_rkey);
-			cur_rchunk->rc_target.rs_length = htonl(seg->mr_len);
+			cur_rchunk->rc_position = cpu_to_be32(pos);
+			cur_rchunk->rc_target.rs_handle =
+						cpu_to_be32(seg->mr_rkey);
+			cur_rchunk->rc_target.rs_length =
+						cpu_to_be32(seg->mr_len);
 			xdr_encode_hyper(
 					(__be32 *)&cur_rchunk->rc_target.rs_offset,
 					seg->mr_base);
@@ -222,8 +224,10 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 			cur_rchunk++;
 			r_xprt->rx_stats.read_chunk_count++;
 		} else {		/* write/reply */
-			cur_wchunk->wc_target.rs_handle = htonl(seg->mr_rkey);
-			cur_wchunk->wc_target.rs_length = htonl(seg->mr_len);
+			cur_wchunk->wc_target.rs_handle =
+						cpu_to_be32(seg->mr_rkey);
+			cur_wchunk->wc_target.rs_length =
+						cpu_to_be32(seg->mr_len);
 			xdr_encode_hyper(
 					(__be32 *)&cur_wchunk->wc_target.rs_offset,
 					seg->mr_base);
@@ -257,7 +261,7 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 		*iptr++ = xdr_zero;	/* encode a NULL reply chunk */
 	} else {
 		warray->wc_discrim = xdr_one;
-		warray->wc_nchunks = htonl(nchunks);
+		warray->wc_nchunks = cpu_to_be32(nchunks);
 		iptr = (__be32 *) cur_wchunk;
 		if (type == rpcrdma_writech) {
 			*iptr++ = xdr_zero; /* finish the write chunk list */
@@ -404,11 +408,11 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 
 	/* build RDMA header in private area at front */
 	headerp = (struct rpcrdma_msg *) req->rl_base;
-	/* don't htonl XID, it's already done in request */
+	/* don't byte-swap XID, it's already done in request */
 	headerp->rm_xid = rqst->rq_xid;
-	headerp->rm_vers = xdr_one;
-	headerp->rm_credit = htonl(r_xprt->rx_buf.rb_max_requests);
-	headerp->rm_type = htonl(RDMA_MSG);
+	headerp->rm_vers = rpcrdma_version;
+	headerp->rm_credit = cpu_to_be32(r_xprt->rx_buf.rb_max_requests);
+	headerp->rm_type = rdma_msg;
 
 	/*
 	 * Chunks needed for results?
@@ -482,11 +486,11 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 						RPCRDMA_INLINE_PAD_VALUE(rqst));
 
 		if (padlen) {
-			headerp->rm_type = htonl(RDMA_MSGP);
+			headerp->rm_type = rdma_msgp;
 			headerp->rm_body.rm_padded.rm_align =
-				htonl(RPCRDMA_INLINE_PAD_VALUE(rqst));
+				cpu_to_be32(RPCRDMA_INLINE_PAD_VALUE(rqst));
 			headerp->rm_body.rm_padded.rm_thresh =
-				htonl(RPCRDMA_INLINE_PAD_THRESH);
+				cpu_to_be32(RPCRDMA_INLINE_PAD_THRESH);
 			headerp->rm_body.rm_padded.rm_pempty[0] = xdr_zero;
 			headerp->rm_body.rm_padded.rm_pempty[1] = xdr_zero;
 			headerp->rm_body.rm_padded.rm_pempty[2] = xdr_zero;
@@ -570,7 +574,7 @@ rpcrdma_count_chunks(struct rpcrdma_rep *rep, unsigned int max, int wrchunk, __b
 	unsigned int i, total_len;
 	struct rpcrdma_write_chunk *cur_wchunk;
 
-	i = ntohl(**iptrp);	/* get array count */
+	i = be32_to_cpu(**iptrp);
 	if (i > max)
 		return -1;
 	cur_wchunk = (struct rpcrdma_write_chunk *) (*iptrp + 1);
@@ -582,11 +586,11 @@ rpcrdma_count_chunks(struct rpcrdma_rep *rep, unsigned int max, int wrchunk, __b
 			xdr_decode_hyper((__be32 *)&seg->rs_offset, &off);
 			dprintk("RPC:       %s: chunk %d@0x%llx:0x%x\n",
 				__func__,
-				ntohl(seg->rs_length),
+				be32_to_cpu(seg->rs_length),
 				(unsigned long long)off,
-				ntohl(seg->rs_handle));
+				be32_to_cpu(seg->rs_handle));
 		}
-		total_len += ntohl(seg->rs_length);
+		total_len += be32_to_cpu(seg->rs_length);
 		++cur_wchunk;
 	}
 	/* check and adjust for properly terminated write chunk */
@@ -749,9 +753,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		goto repost;
 	}
 	headerp = (struct rpcrdma_msg *) rep->rr_base;
-	if (headerp->rm_vers != xdr_one) {
+	if (headerp->rm_vers != rpcrdma_version) {
 		dprintk("RPC:       %s: invalid version %d\n",
-			__func__, ntohl(headerp->rm_vers));
+			__func__, be32_to_cpu(headerp->rm_vers));
 		goto repost;
 	}
 
@@ -793,7 +797,7 @@ repost:
 	/* check for expected message types */
 	/* The order of some of these tests is important. */
 	switch (headerp->rm_type) {
-	case htonl(RDMA_MSG):
+	case rdma_msg:
 		/* never expect read chunks */
 		/* never expect reply chunks (two ways to check) */
 		/* never expect write chunks without having offered RDMA */
@@ -832,7 +836,7 @@ repost:
 		rpcrdma_inline_fixup(rqst, (char *)iptr, rep->rr_len, rdmalen);
 		break;
 
-	case htonl(RDMA_NOMSG):
+	case rdma_nomsg:
 		/* never expect read or write chunks, always reply chunks */
 		if (headerp->rm_body.rm_chunks[0] != xdr_zero ||
 		    headerp->rm_body.rm_chunks[1] != xdr_zero ||
@@ -853,7 +857,7 @@ badheader:
 		dprintk("%s: invalid rpcrdma reply header (type %d):"
 				" chunks[012] == %d %d %d"
 				" expected chunks <= %d\n",
-				__func__, ntohl(headerp->rm_type),
+				__func__, be32_to_cpu(headerp->rm_type),
 				headerp->rm_body.rm_chunks[0],
 				headerp->rm_body.rm_chunks[1],
 				headerp->rm_body.rm_chunks[2],


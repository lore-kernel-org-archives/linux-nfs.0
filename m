Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34821 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417AbbCMVVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:21:42 -0400
Received: by ieclw3 with SMTP id lw3so127650005iec.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:21:41 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id o1sm1997378ioe.26.2015.03.13.14.21.37
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:21:38 -0700 (PDT)
Subject: [PATCH v1 02/16] xprtrdma: Perform a full marshal on retransmit
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:21:36 -0400
Message-ID: <20150313212136.22471.70340.stgit@manet.1015granger.net>
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 6ab59945f292 ("xprtrdma: Update rkeys after transport
reconnect" added logic in the ->send_request path to update the
chunk list when an RPC/RDMA request is retransmitted.

Note that rpc_xdr_encode() resets and re-encodes the entire RPC
send buffer for each retransmit of an RPC. The RPC send buffer
is not preserved from the previous transmission of an RPC.

Revert 6ab59945f292, and instead, just force each request to be
fully marshaled every time through ->send_request. This should
preserve the fix from 6ab59945f292, while also performing pullup
during retransmits.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   71 ++++++++++++++++++---------------------
 net/sunrpc/xprtrdma/transport.c |    5 +--
 net/sunrpc/xprtrdma/xprt_rdma.h |   10 -----
 3 files changed, 34 insertions(+), 52 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 91ffde8..41456d9 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -53,6 +53,14 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
+enum rpcrdma_chunktype {
+	rpcrdma_noch = 0,
+	rpcrdma_readch,
+	rpcrdma_areadch,
+	rpcrdma_writech,
+	rpcrdma_replych
+};
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static const char transfertypes[][12] = {
 	"pure inline",	/* no chunks */
@@ -284,28 +292,6 @@ out:
 }
 
 /*
- * Marshal chunks. This routine returns the header length
- * consumed by marshaling.
- *
- * Returns positive RPC/RDMA header size, or negative errno.
- */
-
-ssize_t
-rpcrdma_marshal_chunks(struct rpc_rqst *rqst, ssize_t result)
-{
-	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
-	struct rpcrdma_msg *headerp = rdmab_to_msg(req->rl_rdmabuf);
-
-	if (req->rl_rtype != rpcrdma_noch)
-		result = rpcrdma_create_chunks(rqst, &rqst->rq_snd_buf,
-					       headerp, req->rl_rtype);
-	else if (req->rl_wtype != rpcrdma_noch)
-		result = rpcrdma_create_chunks(rqst, &rqst->rq_rcv_buf,
-					       headerp, req->rl_wtype);
-	return result;
-}
-
-/*
  * Copy write data inline.
  * This function is used for "small" requests. Data which is passed
  * to RPC via iovecs (or page list) is copied directly into the
@@ -397,6 +383,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	char *base;
 	size_t rpclen, padlen;
 	ssize_t hdrlen;
+	enum rpcrdma_chunktype rtype, wtype;
 	struct rpcrdma_msg *headerp;
 
 	/*
@@ -433,13 +420,13 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 * into pages; otherwise use reply chunks.
 	 */
 	if (rqst->rq_rcv_buf.buflen <= RPCRDMA_INLINE_READ_THRESHOLD(rqst))
-		req->rl_wtype = rpcrdma_noch;
+		wtype = rpcrdma_noch;
 	else if (rqst->rq_rcv_buf.page_len == 0)
-		req->rl_wtype = rpcrdma_replych;
+		wtype = rpcrdma_replych;
 	else if (rqst->rq_rcv_buf.flags & XDRBUF_READ)
-		req->rl_wtype = rpcrdma_writech;
+		wtype = rpcrdma_writech;
 	else
-		req->rl_wtype = rpcrdma_replych;
+		wtype = rpcrdma_replych;
 
 	/*
 	 * Chunks needed for arguments?
@@ -456,16 +443,16 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 * TBD check NFSv4 setacl
 	 */
 	if (rqst->rq_snd_buf.len <= RPCRDMA_INLINE_WRITE_THRESHOLD(rqst))
-		req->rl_rtype = rpcrdma_noch;
+		rtype = rpcrdma_noch;
 	else if (rqst->rq_snd_buf.page_len == 0)
-		req->rl_rtype = rpcrdma_areadch;
+		rtype = rpcrdma_areadch;
 	else
-		req->rl_rtype = rpcrdma_readch;
+		rtype = rpcrdma_readch;
 
 	/* The following simplification is not true forever */
-	if (req->rl_rtype != rpcrdma_noch && req->rl_wtype == rpcrdma_replych)
-		req->rl_wtype = rpcrdma_noch;
-	if (req->rl_rtype != rpcrdma_noch && req->rl_wtype != rpcrdma_noch) {
+	if (rtype != rpcrdma_noch && wtype == rpcrdma_replych)
+		wtype = rpcrdma_noch;
+	if (rtype != rpcrdma_noch && wtype != rpcrdma_noch) {
 		dprintk("RPC:       %s: cannot marshal multiple chunk lists\n",
 			__func__);
 		return -EIO;
@@ -479,7 +466,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 * When padding is in use and applies to the transfer, insert
 	 * it and change the message type.
 	 */
-	if (req->rl_rtype == rpcrdma_noch) {
+	if (rtype == rpcrdma_noch) {
 
 		padlen = rpcrdma_inline_pullup(rqst,
 						RPCRDMA_INLINE_PAD_VALUE(rqst));
@@ -494,7 +481,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 			headerp->rm_body.rm_padded.rm_pempty[1] = xdr_zero;
 			headerp->rm_body.rm_padded.rm_pempty[2] = xdr_zero;
 			hdrlen += 2 * sizeof(u32); /* extra words in padhdr */
-			if (req->rl_wtype != rpcrdma_noch) {
+			if (wtype != rpcrdma_noch) {
 				dprintk("RPC:       %s: invalid chunk list\n",
 					__func__);
 				return -EIO;
@@ -515,18 +502,26 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 			 * on receive. Therefore, we request a reply chunk
 			 * for non-writes wherever feasible and efficient.
 			 */
-			if (req->rl_wtype == rpcrdma_noch)
-				req->rl_wtype = rpcrdma_replych;
+			if (wtype == rpcrdma_noch)
+				wtype = rpcrdma_replych;
 		}
 	}
 
-	hdrlen = rpcrdma_marshal_chunks(rqst, hdrlen);
+	if (rtype != rpcrdma_noch) {
+		hdrlen = rpcrdma_create_chunks(rqst, &rqst->rq_snd_buf,
+					       headerp, rtype);
+		wtype = rtype;	/* simplify dprintk */
+
+	} else if (wtype != rpcrdma_noch) {
+		hdrlen = rpcrdma_create_chunks(rqst, &rqst->rq_rcv_buf,
+					       headerp, wtype);
+	}
 	if (hdrlen < 0)
 		return hdrlen;
 
 	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd padlen %zd"
 		" headerp 0x%p base 0x%p lkey 0x%x\n",
-		__func__, transfertypes[req->rl_wtype], hdrlen, rpclen, padlen,
+		__func__, transfertypes[wtype], hdrlen, rpclen, padlen,
 		headerp, base, rdmab_lkey(req->rl_rdmabuf));
 
 	/*
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 26a62e7..271d306 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -608,10 +608,7 @@ xprt_rdma_send_request(struct rpc_task *task)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	int rc = 0;
 
-	if (req->rl_niovs == 0)
-		rc = rpcrdma_marshal_req(rqst);
-	else if (r_xprt->rx_ia.ri_memreg_strategy != RPCRDMA_ALLPHYSICAL)
-		rc = rpcrdma_marshal_chunks(rqst, 0);
+	rc = rpcrdma_marshal_req(rqst);
 	if (rc < 0)
 		goto failed_marshal;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0a16fb6..c8afd83 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -143,14 +143,6 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
 	return (struct rpcrdma_msg *)rb->rg_base;
 }
 
-enum rpcrdma_chunktype {
-	rpcrdma_noch = 0,
-	rpcrdma_readch,
-	rpcrdma_areadch,
-	rpcrdma_writech,
-	rpcrdma_replych
-};
-
 /*
  * struct rpcrdma_rep -- this structure encapsulates state required to recv
  * and complete a reply, asychronously. It needs several pieces of
@@ -258,7 +250,6 @@ struct rpcrdma_req {
 	unsigned int	rl_niovs;	/* 0, 2 or 4 */
 	unsigned int	rl_nchunks;	/* non-zero if chunks */
 	unsigned int	rl_connect_cookie;	/* retry detection */
-	enum rpcrdma_chunktype	rl_rtype, rl_wtype;
 	struct rpcrdma_buffer *rl_buffer; /* home base for this structure */
 	struct rpcrdma_rep	*rl_reply;/* holder for reply buffer */
 	struct ib_sge	rl_send_iov[4];	/* for active requests */
@@ -418,7 +409,6 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
 /*
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */
-ssize_t rpcrdma_marshal_chunks(struct rpc_rqst *, ssize_t);
 int rpcrdma_marshal_req(struct rpc_rqst *);
 size_t rpcrdma_max_payload(struct rpcrdma_xprt *);
 


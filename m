Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35422 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754335AbcKRPKg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 10:10:36 -0500
Subject: [PATCH v2 03/10] svcrdma: Renovate sendto chunk list parsing
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 10:10:33 -0500
Message-ID: <20161118151033.13658.76781.stgit@klimt.1015granger.net>
In-Reply-To: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
References: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current sendto code appears to support clients that provide only
one of a Read list, a Write list, or a Reply chunk. My reading of
that code is that it doesn't support the following cases:

 - Read list + Write list
 - Read list + Reply chunk
 - Write list + Reply chunk
 - Read list + Write list + Reply chunk

The protocol allows more than one Read or Write chunk in those
lists. Some clients do send a Read list and Reply chunk
simultaneously. NFSv4 WRITE uses a Read list for the data payload,
and a Reply chunk because the GETATTR result in the reply can
contain a large object like an ACL.

Generalize one of the sendto code paths needed to support all of
the above cases, and attempt to ensure that only one pass is done
through the RPC Call's transport header to gather chunk list
information for building the reply.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h         |    2 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   14 +++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |   92 ++++++++-----------------------
 3 files changed, 39 insertions(+), 69 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index cc3ae16..6aef63b 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -236,8 +236,6 @@ extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
 extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
 			    struct svc_rdma_req_map *, bool);
 extern int svc_rdma_sendto(struct svc_rqst *);
-extern struct rpcrdma_read_chunk *
-	svc_rdma_get_read_chunk(struct rpcrdma_msg *);
 extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				int);
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index ad1df97..873c2a9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -415,6 +415,20 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	return 1;
 }
 
+/* Returns the address of the first read chunk or <nul> if no read chunk
+ * is present
+ */
+static struct rpcrdma_read_chunk *
+svc_rdma_get_read_chunk(struct rpcrdma_msg *rmsgp)
+{
+	struct rpcrdma_read_chunk *ch =
+		(struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
+
+	if (ch->rc_discrim == xdr_zero)
+		return NULL;
+	return ch;
+}
+
 static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 			    struct rpcrdma_msg *rmsgp,
 			    struct svc_rqst *rqstp,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index f5a91ed..0a58d40 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -153,76 +153,35 @@ static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
 	return dma_addr;
 }
 
-/* Returns the address of the first read chunk or <nul> if no read chunk
- * is present
+/* Parse the RPC Call's transport header.
  */
-struct rpcrdma_read_chunk *
-svc_rdma_get_read_chunk(struct rpcrdma_msg *rmsgp)
+static void svc_rdma_get_write_arrays(struct rpcrdma_msg *rmsgp,
+				      struct rpcrdma_write_array **write,
+				      struct rpcrdma_write_array **reply)
 {
-	struct rpcrdma_read_chunk *ch =
-		(struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
+	__be32 *p;
 
-	if (ch->rc_discrim == xdr_zero)
-		return NULL;
-	return ch;
-}
-
-/* Returns the address of the first read write array element or <nul>
- * if no write array list is present
- */
-static struct rpcrdma_write_array *
-svc_rdma_get_write_array(struct rpcrdma_msg *rmsgp)
-{
-	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero ||
-	    rmsgp->rm_body.rm_chunks[1] == xdr_zero)
-		return NULL;
-	return (struct rpcrdma_write_array *)&rmsgp->rm_body.rm_chunks[1];
-}
+	p = (__be32 *)&rmsgp->rm_body.rm_chunks[0];
 
-/* Returns the address of the first reply array element or <nul> if no
- * reply array is present
- */
-static struct rpcrdma_write_array *
-svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp,
-			 struct rpcrdma_write_array *wr_ary)
-{
-	struct rpcrdma_read_chunk *rch;
-	struct rpcrdma_write_array *rp_ary;
+	/* Read list */
+	while (*p++ != xdr_zero)
+		p += 5;
 
-	/* XXX: Need to fix when reply chunk may occur with read list
-	 *	and/or write list.
-	 */
-	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero ||
-	    rmsgp->rm_body.rm_chunks[1] != xdr_zero)
-		return NULL;
-
-	rch = svc_rdma_get_read_chunk(rmsgp);
-	if (rch) {
-		while (rch->rc_discrim != xdr_zero)
-			rch++;
-
-		/* The reply chunk follows an empty write array located
-		 * at 'rc_position' here. The reply array is at rc_target.
-		 */
-		rp_ary = (struct rpcrdma_write_array *)&rch->rc_target;
-		goto found_it;
-	}
-
-	if (wr_ary) {
-		int chunk = be32_to_cpu(wr_ary->wc_nchunks);
-
-		rp_ary = (struct rpcrdma_write_array *)
-			 &wr_ary->wc_array[chunk].wc_target.rs_length;
-		goto found_it;
+	/* Write list */
+	if (*p != xdr_zero) {
+		*write = (struct rpcrdma_write_array *)p;
+		while (*p++ != xdr_zero)
+			p += 1 + be32_to_cpu(*p) * 4;
+	} else {
+		*write = NULL;
+		p++;
 	}
 
-	/* No read list, no write list */
-	rp_ary = (struct rpcrdma_write_array *)&rmsgp->rm_body.rm_chunks[2];
-
- found_it:
-	if (rp_ary->wc_discrim == xdr_zero)
-		return NULL;
-	return rp_ary;
+	/* Reply chunk */
+	if (*p != xdr_zero)
+		*reply = (struct rpcrdma_write_array *)p;
+	else
+		*reply = NULL;
 }
 
 /* RPC-over-RDMA Version One private extension: Remote Invalidation.
@@ -244,8 +203,8 @@ static u32 svc_rdma_get_inv_rkey(struct rpcrdma_msg *rdma_argp,
 
 	inv_rkey = 0;
 
-	rd_ary = svc_rdma_get_read_chunk(rdma_argp);
-	if (rd_ary) {
+	rd_ary = (struct rpcrdma_read_chunk *)&rdma_argp->rm_body.rm_chunks[0];
+	if (rd_ary->rc_discrim != xdr_zero) {
 		inv_rkey = be32_to_cpu(rd_ary->rc_target.rs_handle);
 		goto out;
 	}
@@ -622,8 +581,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	 * places this at the start of page 0.
 	 */
 	rdma_argp = page_address(rqstp->rq_pages[0]);
-	wr_ary = svc_rdma_get_write_array(rdma_argp);
-	rp_ary = svc_rdma_get_reply_array(rdma_argp, wr_ary);
+	svc_rdma_get_write_arrays(rdma_argp, &wr_ary, &rp_ary);
 
 	inv_rkey = 0;
 	if (rdma->sc_snd_w_inv)


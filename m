Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33467 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbbGIUpb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:45:31 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 3/5] svcrdma: Clean up svc_rdma_get_reply_array()
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Thu, 09 Jul 2015 16:45:28 -0400
Message-ID: <20150709204528.8481.2755.stgit@klimt.1015granger.net>
In-Reply-To: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
References: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kernel coding conventions frown upon having large nontrivial
functions in header files, and the preference these days is to
allow the compiler to make inlining decisions if possible.

As these functions are re-homed into a .c file, be sure that
comparisons with fields in struct rpcrdma_msg are with be32
constants.

This is a refactoring change; no behavior change is intended.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h       |   81 +--------------------------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   73 ++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+), 79 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index cb94ee4..ca4d86a 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -213,6 +213,8 @@ extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
 
 /* svc_rdma_sendto.c */
 extern int svc_rdma_sendto(struct svc_rqst *);
+extern struct rpcrdma_read_chunk *
+	svc_rdma_get_read_chunk(struct rpcrdma_msg *);
 
 /* svc_rdma_transport.c */
 extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
@@ -238,83 +240,4 @@ extern void svc_rdma_prep_reply_hdr(struct svc_rqst *);
 extern int svc_rdma_init(void);
 extern void svc_rdma_cleanup(void);
 
-/*
- * Returns the address of the first read chunk or <nul> if no read chunk is
- * present
- */
-static inline struct rpcrdma_read_chunk *
-svc_rdma_get_read_chunk(struct rpcrdma_msg *rmsgp)
-{
-	struct rpcrdma_read_chunk *ch =
-		(struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
-
-	if (ch->rc_discrim == 0)
-		return NULL;
-
-	return ch;
-}
-
-/*
- * Returns the address of the first read write array element or <nul> if no
- * write array list is present
- */
-static inline struct rpcrdma_write_array *
-svc_rdma_get_write_array(struct rpcrdma_msg *rmsgp)
-{
-	if (rmsgp->rm_body.rm_chunks[0] != 0
-	    || rmsgp->rm_body.rm_chunks[1] == 0)
-		return NULL;
-
-	return (struct rpcrdma_write_array *)&rmsgp->rm_body.rm_chunks[1];
-}
-
-/*
- * Returns the address of the first reply array element or <nul> if no
- * reply array is present
- */
-static inline struct rpcrdma_write_array *
-svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp)
-{
-	struct rpcrdma_read_chunk *rch;
-	struct rpcrdma_write_array *wr_ary;
-	struct rpcrdma_write_array *rp_ary;
-
-	/* XXX: Need to fix when reply list may occur with read-list and/or
-	 * write list */
-	if (rmsgp->rm_body.rm_chunks[0] != 0 ||
-	    rmsgp->rm_body.rm_chunks[1] != 0)
-		return NULL;
-
-	rch = svc_rdma_get_read_chunk(rmsgp);
-	if (rch) {
-		while (rch->rc_discrim)
-			rch++;
-
-		/* The reply list follows an empty write array located
-		 * at 'rc_position' here. The reply array is at rc_target.
-		 */
-		rp_ary = (struct rpcrdma_write_array *)&rch->rc_target;
-
-		goto found_it;
-	}
-
-	wr_ary = svc_rdma_get_write_array(rmsgp);
-	if (wr_ary) {
-		rp_ary = (struct rpcrdma_write_array *)
-			&wr_ary->
-			wc_array[ntohl(wr_ary->wc_nchunks)].wc_target.rs_length;
-
-		goto found_it;
-	}
-
-	/* No read list, no write list */
-	rp_ary = (struct rpcrdma_write_array *)
-		&rmsgp->rm_body.rm_chunks[2];
-
- found_it:
-	if (rp_ary->wc_discrim == 0)
-		return NULL;
-
-	return rp_ary;
-}
 #endif
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 95412ab..1dfae83 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -136,6 +136,79 @@ static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
 	return dma_addr;
 }
 
+/* Returns the address of the first read chunk or <nul> if no read chunk
+ * is present
+ */
+struct rpcrdma_read_chunk *
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
+/* Returns the address of the first read write array element or <nul>
+ * if no write array list is present
+ */
+static struct rpcrdma_write_array *
+svc_rdma_get_write_array(struct rpcrdma_msg *rmsgp)
+{
+	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero ||
+	    rmsgp->rm_body.rm_chunks[1] == xdr_zero)
+		return NULL;
+	return (struct rpcrdma_write_array *)&rmsgp->rm_body.rm_chunks[1];
+}
+
+/* Returns the address of the first reply array element or <nul> if no
+ * reply array is present
+ */
+static struct rpcrdma_write_array *
+svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp)
+{
+	struct rpcrdma_read_chunk *rch;
+	struct rpcrdma_write_array *wr_ary;
+	struct rpcrdma_write_array *rp_ary;
+
+	/* XXX: Need to fix when reply chunk may occur with read list
+	 *	and/or write list.
+	 */
+	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero ||
+	    rmsgp->rm_body.rm_chunks[1] != xdr_zero)
+		return NULL;
+
+	rch = svc_rdma_get_read_chunk(rmsgp);
+	if (rch) {
+		while (rch->rc_discrim != xdr_zero)
+			rch++;
+
+		/* The reply chunk follows an empty write array located
+		 * at 'rc_position' here. The reply array is at rc_target.
+		 */
+		rp_ary = (struct rpcrdma_write_array *)&rch->rc_target;
+		goto found_it;
+	}
+
+	wr_ary = svc_rdma_get_write_array(rmsgp);
+	if (wr_ary) {
+		int chunk = be32_to_cpu(wr_ary->wc_nchunks);
+
+		rp_ary = (struct rpcrdma_write_array *)
+			 &wr_ary->wc_array[chunk].wc_target.rs_length;
+		goto found_it;
+	}
+
+	/* No read list, no write list */
+	rp_ary = (struct rpcrdma_write_array *)&rmsgp->rm_body.rm_chunks[2];
+
+ found_it:
+	if (rp_ary->wc_discrim == xdr_zero)
+		return NULL;
+	return rp_ary;
+}
+
 /* Assumptions:
  * - The specified write_len can be represented in sc_max_sge * PAGE_SIZE
  */


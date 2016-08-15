Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34151 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbcHOU6b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:58:31 -0400
Subject: [PATCH v1 3/3] svcrdma: support Remote Invalidation for prototyping
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:58:24 -0400
Message-ID: <20160815205824.11731.37292.stgit@klimt.1015granger.net>
In-Reply-To: <20160815205032.11731.16708.stgit@klimt.1015granger.net>
References: <20160815205032.11731.16708.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To allow testing, add a sysctl that enables the use of Send With
Invalidate in place of Send when transmitting RPC replies. The
invalidate_rkey is arbitrarily chosen from among rkeys present
in the RPC-over-RDMA header's chunk lists.

Send With Invalidate can be enabled when all client and server HCAs
support it, and the client does not send persistently registered
rkeys (like a local DMA rkey).

Send With Invalidate improves performance only when clients can
recognize, while processing an RPC reply, that an rkey has already
been invalidated. That is a separate change.

In the future, the RPC-over-RDMA protocol might support Remote
Invalidation properly. The protocol needs to enable signaling
between peers to indicate when Remote Invalidation can be used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   58 ++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   12 +++++-
 3 files changed, 65 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index d6917b8..8a43650 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -136,6 +136,7 @@ struct svcxprt_rdma {
 	int		     sc_ord;		/* RDMA read limit */
 	int                  sc_max_sge;
 	int                  sc_max_sge_rd;	/* max sge for read target */
+	bool		     sc_snd_w_inv;	/* OK to use Send With Invalidate */
 
 	atomic_t             sc_sq_count;	/* Number of SQ WR on queue */
 	unsigned int	     sc_sq_depth;	/* Depth of SQ */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 54d53330..e9adbe5 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -225,6 +225,48 @@ svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp,
 	return rp_ary;
 }
 
+/* RPC-over-RDMA Version One private extension: Remote Invalidation.
+ * Responder's choice: requester signals it can handle Send With
+ * Invalidate, and responder chooses one rkey to invalidate.
+ *
+ * Find a candidate rkey to invalidate when sending a reply.  Picks the
+ * first rkey it finds in the chunks lists.
+ *
+ * Returns zero if RPC's chunk lists are empty.
+ */
+static u32 svc_rdma_get_inv_rkey(struct rpcrdma_msg *rdma_argp,
+				 struct rpcrdma_write_array *wr_ary,
+				 struct rpcrdma_write_array *rp_ary)
+{
+	struct rpcrdma_read_chunk *rd_ary;
+	struct rpcrdma_segment *arg_ch;
+	u32 inv_rkey;
+
+	inv_rkey = 0;
+
+	rd_ary = svc_rdma_get_read_chunk(rdma_argp);
+	if (rd_ary) {
+		inv_rkey = be32_to_cpu(rd_ary->rc_target.rs_handle);
+		goto out;
+	}
+
+	if (wr_ary && be32_to_cpu(wr_ary->wc_nchunks)) {
+		arg_ch = &wr_ary->wc_array[0].wc_target;
+		inv_rkey = be32_to_cpu(arg_ch->rs_handle);
+		goto out;
+	}
+
+	if (rp_ary && be32_to_cpu(rp_ary->wc_nchunks)) {
+		arg_ch = &rp_ary->wc_array[0].wc_target;
+		inv_rkey = be32_to_cpu(arg_ch->rs_handle);
+		goto out;
+	}
+
+out:
+	dprintk("svcrdma: Send With Invalidate rkey=%08x\n", inv_rkey);
+	return inv_rkey;
+}
+
 /* Assumptions:
  * - The specified write_len can be represented in sc_max_sge * PAGE_SIZE
  */
@@ -464,7 +506,8 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		      struct page *page,
 		      struct rpcrdma_msg *rdma_resp,
 		      struct svc_rdma_req_map *vec,
-		      int byte_count)
+		      int byte_count,
+		      u32 inv_rkey)
 {
 	struct svc_rdma_op_ctxt *ctxt;
 	struct ib_send_wr send_wr;
@@ -549,7 +592,11 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	send_wr.wr_cqe = &ctxt->cqe;
 	send_wr.sg_list = ctxt->sge;
 	send_wr.num_sge = sge_no;
-	send_wr.opcode = IB_WR_SEND;
+	if (inv_rkey) {
+		send_wr.opcode = IB_WR_SEND_WITH_INV;
+		send_wr.ex.invalidate_rkey = inv_rkey;
+	} else
+		send_wr.opcode = IB_WR_SEND;
 	send_wr.send_flags =  IB_SEND_SIGNALED;
 
 	ret = svc_rdma_send(rdma, &send_wr);
@@ -581,6 +628,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	int inline_bytes;
 	struct page *res_page;
 	struct svc_rdma_req_map *vec;
+	u32 inv_rkey;
 
 	dprintk("svcrdma: sending response for rqstp=%p\n", rqstp);
 
@@ -591,6 +639,10 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	wr_ary = svc_rdma_get_write_array(rdma_argp);
 	rp_ary = svc_rdma_get_reply_array(rdma_argp, wr_ary);
 
+	inv_rkey = 0;
+	if (rdma->sc_snd_w_inv)
+		inv_rkey = svc_rdma_get_inv_rkey(rdma_argp, wr_ary, rp_ary);
+
 	/* Build an req vec for the XDR */
 	vec = svc_rdma_get_req_map(rdma);
 	ret = svc_rdma_map_xdr(rdma, &rqstp->rq_res, vec, wr_ary != NULL);
@@ -633,7 +685,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		goto err1;
 
 	ret = send_reply(rdma, rqstp, res_page, rdma_resp, vec,
-			 inline_bytes);
+			 inline_bytes, inv_rkey);
 	if (ret < 0)
 		goto err1;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4843824..1fe34f6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -651,9 +651,14 @@ svc_rdma_parse_connect_private(struct svcxprt_rdma *newxprt,
 	if (pmsg &&
 	    pmsg->cp_magic == rpcrdma_cmp_magic &&
 	    pmsg->cp_version == RPCRDMA_CMP_VERSION) {
-		dprintk("svcrdma: client send_size %u, recv_size %u\n",
+		newxprt->sc_snd_w_inv = pmsg->cp_flags &
+					RPCRDMA_CMP_F_SND_W_INV_OK;
+
+		dprintk("svcrdma: client send_size %u, recv_size %u "
+			"remote inv %ssupported\n",
 			rpcrdma_decode_buffer_size(pmsg->cp_send_size),
-			rpcrdma_decode_buffer_size(pmsg->cp_recv_size));
+			rpcrdma_decode_buffer_size(pmsg->cp_recv_size),
+			newxprt->sc_snd_w_inv ? "" : "un");
 	}
 }
 
@@ -1087,7 +1092,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 			dev->attrs.max_fast_reg_page_list_len;
 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
 		newxprt->sc_reader = rdma_read_chunk_frmr;
-	}
+	} else
+		newxprt->sc_snd_w_inv = false;
 
 	/*
 	 * Determine if a DMA MR is required and if so, what privs are required


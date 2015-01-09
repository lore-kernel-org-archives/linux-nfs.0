Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:36799 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbbAITWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 14:22:47 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 06/10] svcrdma: Plant reader function in struct svcxprt_rdma
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 09 Jan 2015 14:22:45 -0500
Message-ID: <20150109192245.4901.89614.stgit@klimt.1015granger.net>
In-Reply-To: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RDMA reader function doesn't change once an svcxprt is
instantiated. Instead of checking sc_devcap during every incoming
RPC, set the reader function once when the connection is accepted.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h          |   10 ++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   71 +++++++++++-------------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +
 3 files changed, 39 insertions(+), 44 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 2280325..f161e30 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -150,6 +150,10 @@ struct svcxprt_rdma {
 	struct ib_cq         *sc_rq_cq;
 	struct ib_cq         *sc_sq_cq;
 	struct ib_mr         *sc_phys_mr;	/* MR for server memory */
+	int		     (*sc_reader)(struct svcxprt_rdma *,
+					  struct svc_rqst *,
+					  struct svc_rdma_op_ctxt *,
+					  int *, u32 *, u32, u32, u64, bool);
 	u32		     sc_dev_caps;	/* distilled device caps */
 	u32		     sc_dma_lkey;	/* local dma key */
 	unsigned int	     sc_frmr_pg_list_len;
@@ -195,6 +199,12 @@ extern int svc_rdma_xdr_get_reply_hdr_len(struct rpcrdma_msg *);
 
 /* svc_rdma_recvfrom.c */
 extern int svc_rdma_recvfrom(struct svc_rqst *);
+extern int rdma_read_chunk_lcl(struct svcxprt_rdma *, struct svc_rqst *,
+			       struct svc_rdma_op_ctxt *, int *, u32 *,
+			       u32, u32, u64, bool);
+extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
+				struct svc_rdma_op_ctxt *, int *, u32 *,
+				u32, u32, u64, bool);
 
 /* svc_rdma_sendto.c */
 extern int svc_rdma_sendto(struct svc_rqst *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 577f865..c3aebc1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -117,26 +117,16 @@ static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
 		return min_t(int, sge_count, xprt->sc_max_sge);
 }
 
-typedef int (*rdma_reader_fn)(struct svcxprt_rdma *xprt,
-			      struct svc_rqst *rqstp,
-			      struct svc_rdma_op_ctxt *head,
-			      int *page_no,
-			      u32 *page_offset,
-			      u32 rs_handle,
-			      u32 rs_length,
-			      u64 rs_offset,
-			      int last);
-
 /* Issue an RDMA_READ using the local lkey to map the data sink */
-static int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
-			       struct svc_rqst *rqstp,
-			       struct svc_rdma_op_ctxt *head,
-			       int *page_no,
-			       u32 *page_offset,
-			       u32 rs_handle,
-			       u32 rs_length,
-			       u64 rs_offset,
-			       int last)
+int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
+			struct svc_rqst *rqstp,
+			struct svc_rdma_op_ctxt *head,
+			int *page_no,
+			u32 *page_offset,
+			u32 rs_handle,
+			u32 rs_length,
+			u64 rs_offset,
+			bool last)
 {
 	struct ib_send_wr read_wr;
 	int pages_needed = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
@@ -221,15 +211,15 @@ static int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
 }
 
 /* Issue an RDMA_READ using an FRMR to map the data sink */
-static int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
-				struct svc_rqst *rqstp,
-				struct svc_rdma_op_ctxt *head,
-				int *page_no,
-				u32 *page_offset,
-				u32 rs_handle,
-				u32 rs_length,
-				u64 rs_offset,
-				int last)
+int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
+			 struct svc_rqst *rqstp,
+			 struct svc_rdma_op_ctxt *head,
+			 int *page_no,
+			 u32 *page_offset,
+			 u32 rs_handle,
+			 u32 rs_length,
+			 u64 rs_offset,
+			 bool last)
 {
 	struct ib_send_wr read_wr;
 	struct ib_send_wr inv_wr;
@@ -374,9 +364,9 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 {
 	int page_no, ret;
 	struct rpcrdma_read_chunk *ch;
-	u32 page_offset, byte_count;
+	u32 handle, page_offset, byte_count;
 	u64 rs_offset;
-	rdma_reader_fn reader;
+	bool last;
 
 	/* If no read list is present, return 0 */
 	ch = svc_rdma_get_read_chunk(rmsgp);
@@ -399,27 +389,20 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	head->arg.len = rqstp->rq_arg.len;
 	head->arg.buflen = rqstp->rq_arg.buflen;
 
-	/* Use FRMR if supported */
-	if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)
-		reader = rdma_read_chunk_frmr;
-	else
-		reader = rdma_read_chunk_lcl;
-
 	page_no = 0; page_offset = 0;
 	for (ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
 	     ch->rc_discrim != 0; ch++) {
-
+		handle = be32_to_cpu(ch->rc_target.rs_handle);
+		byte_count = be32_to_cpu(ch->rc_target.rs_length);
 		xdr_decode_hyper((__be32 *)&ch->rc_target.rs_offset,
 				 &rs_offset);
-		byte_count = ntohl(ch->rc_target.rs_length);
 
 		while (byte_count > 0) {
-			ret = reader(xprt, rqstp, head,
-				     &page_no, &page_offset,
-				     ntohl(ch->rc_target.rs_handle),
-				     byte_count, rs_offset,
-				     ((ch+1)->rc_discrim == 0) /* last */
-				     );
+			last = (ch + 1)->rc_discrim == xdr_zero;
+			ret = xprt->sc_reader(xprt, rqstp, head,
+					      &page_no, &page_offset,
+					      handle, byte_count,
+					      rs_offset, last);
 			if (ret < 0)
 				goto err;
 			byte_count -= ret;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f2e059b..f609c1c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -974,10 +974,12 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	 * NB:	iWARP requires remote write access for the data sink
 	 *	of an RDMA_READ. IB does not.
 	 */
+	newxprt->sc_reader = rdma_read_chunk_lcl;
 	if (devattr.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
 		newxprt->sc_frmr_pg_list_len =
 			devattr.max_fast_reg_page_list_len;
 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
+		newxprt->sc_reader = rdma_read_chunk_frmr;
 	}
 
 	/*


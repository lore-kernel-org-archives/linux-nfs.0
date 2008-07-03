From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 03/11] svcrdma: Use reply and chunk map for RDMA_READ processing
Date: Wed,  2 Jul 2008 21:27:35 -0500
Message-ID: <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-2-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48833 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753389AbYGCC1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 22:27:44 -0400
In-Reply-To: <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Modify the RDMA_READ processing to use the reply and chunk list mapping data
types. Also add a special purpose 'hdr_count' field in in the context to hold
the header page count instead of overloading the SGE length field and
corrupting the DMA map length.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 include/linux/sunrpc/svc_rdma.h         |    1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   83 ++++++++++++++-----------------
 2 files changed, 39 insertions(+), 45 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index bd8749c..fd5e8a1 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -72,6 +72,7 @@ extern atomic_t rdma_stat_sq_prod;
  */
 struct svc_rdma_op_ctxt {
 	struct svc_rdma_op_ctxt *read_hdr;
+	int hdr_count;
 	struct list_head free_list;
 	struct xdr_buf arg;
 	struct list_head dto_q;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 06ab484..d25971b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -112,11 +112,6 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 	rqstp->rq_arg.tail[0].iov_len = 0;
 }
 
-struct chunk_sge {
-	int start;		/* sge no for this chunk */
-	int count;		/* sge count for this chunk */
-};
-
 /* Encode a read-chunk-list as an array of IB SGE
  *
  * Assumptions:
@@ -134,8 +129,8 @@ static int rdma_rcl_to_sge(struct svcxprt_rdma *xprt,
 			   struct svc_rqst *rqstp,
 			   struct svc_rdma_op_ctxt *head,
 			   struct rpcrdma_msg *rmsgp,
-			   struct ib_sge *sge,
-			   struct chunk_sge *ch_sge_ary,
+			   struct svc_rdma_req_map *rpl_map,
+			   struct svc_rdma_req_map *chl_map,
 			   int ch_count,
 			   int byte_count)
 {
@@ -156,22 +151,18 @@ static int rdma_rcl_to_sge(struct svcxprt_rdma *xprt,
 	head->arg.head[0] = rqstp->rq_arg.head[0];
 	head->arg.tail[0] = rqstp->rq_arg.tail[0];
 	head->arg.pages = &head->pages[head->count];
-	head->sge[0].length = head->count; /* save count of hdr pages */
+	head->hdr_count = head->count; /* save count of hdr pages */
 	head->arg.page_base = 0;
 	head->arg.page_len = ch_bytes;
 	head->arg.len = rqstp->rq_arg.len + ch_bytes;
 	head->arg.buflen = rqstp->rq_arg.buflen + ch_bytes;
 	head->count++;
-	ch_sge_ary[0].start = 0;
+	chl_map->ch[0].start = 0;
 	while (byte_count) {
+		rpl_map->sge[sge_no].iov_base =
+			page_address(rqstp->rq_arg.pages[page_no]) + page_off;
 		sge_bytes = min_t(int, PAGE_SIZE-page_off, ch_bytes);
-		sge[sge_no].addr =
-			ib_dma_map_page(xprt->sc_cm_id->device,
-					rqstp->rq_arg.pages[page_no],
-					page_off, sge_bytes,
-					DMA_FROM_DEVICE);
-		sge[sge_no].length = sge_bytes;
-		sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
+		rpl_map->sge[sge_no].iov_len = sge_bytes;
 		/*
 		 * Don't bump head->count here because the same page
 		 * may be used by multiple SGE.
@@ -187,11 +178,11 @@ static int rdma_rcl_to_sge(struct svcxprt_rdma *xprt,
 		 * SGE, move to the next SGE
 		 */
 		if (ch_bytes == 0) {
-			ch_sge_ary[ch_no].count =
-				sge_no - ch_sge_ary[ch_no].start;
+			chl_map->ch[ch_no].count =
+				sge_no - chl_map->ch[ch_no].start;
 			ch_no++;
 			ch++;
-			ch_sge_ary[ch_no].start = sge_no;
+			chl_map->ch[ch_no].start = sge_no;
 			ch_bytes = ch->rc_target.rs_length;
 			/* If bytes remaining account for next chunk */
 			if (byte_count) {
@@ -220,18 +211,24 @@ static int rdma_rcl_to_sge(struct svcxprt_rdma *xprt,
 	return sge_no;
 }
 
-static void rdma_set_ctxt_sge(struct svc_rdma_op_ctxt *ctxt,
-			      struct ib_sge *sge,
+static void rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
+			      struct svc_rdma_op_ctxt *ctxt,
+			      struct kvec *vec,
 			      u64 *sgl_offset,
 			      int count)
 {
 	int i;
 
 	ctxt->count = count;
+	ctxt->direction = DMA_FROM_DEVICE;
 	for (i = 0; i < count; i++) {
-		ctxt->sge[i].addr = sge[i].addr;
-		ctxt->sge[i].length = sge[i].length;
-		*sgl_offset = *sgl_offset + sge[i].length;
+		ctxt->sge[i].addr =
+			ib_dma_map_single(xprt->sc_cm_id->device,
+					  vec[i].iov_base, vec[i].iov_len,
+					  DMA_FROM_DEVICE);
+		ctxt->sge[i].length = vec[i].iov_len;
+		ctxt->sge[i].lkey = xprt->sc_phys_mr->lkey;
+		*sgl_offset = *sgl_offset + vec[i].iov_len;
 	}
 }
 
@@ -282,34 +279,29 @@ static int rdma_read_xdr(struct svcxprt_rdma *xprt,
 	struct ib_send_wr read_wr;
 	int err = 0;
 	int ch_no;
-	struct ib_sge *sge;
 	int ch_count;
 	int byte_count;
 	int sge_count;
 	u64 sgl_offset;
 	struct rpcrdma_read_chunk *ch;
 	struct svc_rdma_op_ctxt *ctxt = NULL;
-	struct svc_rdma_op_ctxt *tmp_sge_ctxt;
-	struct svc_rdma_op_ctxt *tmp_ch_ctxt;
-	struct chunk_sge *ch_sge_ary;
+	struct svc_rdma_req_map *rpl_map;
+	struct svc_rdma_req_map *chl_map;
 
 	/* If no read list is present, return 0 */
 	ch = svc_rdma_get_read_chunk(rmsgp);
 	if (!ch)
 		return 0;
 
-	/* Allocate temporary contexts to keep SGE */
-	BUG_ON(sizeof(struct ib_sge) < sizeof(struct chunk_sge));
-	tmp_sge_ctxt = svc_rdma_get_context(xprt);
-	sge = tmp_sge_ctxt->sge;
-	tmp_ch_ctxt = svc_rdma_get_context(xprt);
-	ch_sge_ary = (struct chunk_sge *)tmp_ch_ctxt->sge;
+	/* Allocate temporary reply and chunk maps */
+	rpl_map = svc_rdma_get_req_map();
+	chl_map = svc_rdma_get_req_map();
 
 	svc_rdma_rcl_chunk_counts(ch, &ch_count, &byte_count);
 	if (ch_count > RPCSVC_MAXPAGES)
 		return -EINVAL;
 	sge_count = rdma_rcl_to_sge(xprt, rqstp, hdr_ctxt, rmsgp,
-				    sge, ch_sge_ary,
+				    rpl_map, chl_map,
 				    ch_count, byte_count);
 	sgl_offset = 0;
 	ch_no = 0;
@@ -331,14 +323,15 @@ next_sge:
 		read_wr.wr.rdma.remote_addr =
 			get_unaligned(&(ch->rc_target.rs_offset)) +
 			sgl_offset;
-		read_wr.sg_list = &sge[ch_sge_ary[ch_no].start];
+		read_wr.sg_list = ctxt->sge;
 		read_wr.num_sge =
-			rdma_read_max_sge(xprt, ch_sge_ary[ch_no].count);
-		rdma_set_ctxt_sge(ctxt, &sge[ch_sge_ary[ch_no].start],
+			rdma_read_max_sge(xprt, chl_map->ch[ch_no].count);
+		rdma_set_ctxt_sge(xprt, ctxt,
+				  &rpl_map->sge[chl_map->ch[ch_no].start],
 				  &sgl_offset,
 				  read_wr.num_sge);
 		if (((ch+1)->rc_discrim == 0) &&
-		    (read_wr.num_sge == ch_sge_ary[ch_no].count)) {
+		    (read_wr.num_sge == chl_map->ch[ch_no].count)) {
 			/*
 			 * Mark the last RDMA_READ with a bit to
 			 * indicate all RPC data has been fetched from
@@ -358,9 +351,9 @@ next_sge:
 		}
 		atomic_inc(&rdma_stat_read);
 
-		if (read_wr.num_sge < ch_sge_ary[ch_no].count) {
-			ch_sge_ary[ch_no].count -= read_wr.num_sge;
-			ch_sge_ary[ch_no].start += read_wr.num_sge;
+		if (read_wr.num_sge < chl_map->ch[ch_no].count) {
+			chl_map->ch[ch_no].count -= read_wr.num_sge;
+			chl_map->ch[ch_no].start += read_wr.num_sge;
 			goto next_sge;
 		}
 		sgl_offset = 0;
@@ -368,8 +361,8 @@ next_sge:
 	}
 
  out:
-	svc_rdma_put_context(tmp_sge_ctxt, 0);
-	svc_rdma_put_context(tmp_ch_ctxt, 0);
+	svc_rdma_put_req_map(rpl_map);
+	svc_rdma_put_req_map(chl_map);
 
 	/* Detach arg pages. svc_recv will replenish them */
 	for (ch_no = 0; &rqstp->rq_pages[ch_no] < rqstp->rq_respages; ch_no++)
@@ -399,7 +392,7 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 		rqstp->rq_pages[page_no] = head->pages[page_no];
 	}
 	/* Point rq_arg.pages past header */
-	rqstp->rq_arg.pages = &rqstp->rq_pages[head->sge[0].length];
+	rqstp->rq_arg.pages = &rqstp->rq_pages[head->hdr_count];
 	rqstp->rq_arg.page_len = head->arg.page_len;
 	rqstp->rq_arg.page_base = head->arg.page_base;
 

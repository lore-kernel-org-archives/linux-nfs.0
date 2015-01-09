Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:40792 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbbAITWb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 14:22:31 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 04/10] svcrdma: Scrub BUG_ON() and WARN_ON() call sites
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 09 Jan 2015 14:22:29 -0500
Message-ID: <20150109192228.4901.12925.stgit@klimt.1015granger.net>
In-Reply-To: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current convention is to avoid using BUG_ON() in places where an
oops could cause complete system failure.

Replace BUG_ON() call sites in svcrdma with an assertion error
message and allow execution to continue safely.

Some BUG_ON() calls are removed because they have never fired in
production (that we are aware of).

Some WARN_ON() calls are also replaced where a back trace is not
helpful; e.g., in a workqueue task.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   11 --------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   28 +++++++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   43 +++++++++++++++++++-----------
 3 files changed, 49 insertions(+), 33 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index b3b7bb8..577f865 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -95,14 +95,6 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 	rqstp->rq_respages = &rqstp->rq_pages[sge_no];
 	rqstp->rq_next_page = rqstp->rq_respages + 1;
 
-	/* We should never run out of SGE because the limit is defined to
-	 * support the max allowed RPC data length
-	 */
-	BUG_ON(bc && (sge_no == ctxt->count));
-	BUG_ON((rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len)
-	       != byte_count);
-	BUG_ON(rqstp->rq_arg.len != byte_count);
-
 	/* If not all pages were used from the SGL, free the remaining ones */
 	bc = sge_no;
 	while (sge_no < ctxt->count) {
@@ -477,8 +469,6 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 	int page_no;
 	int ret;
 
-	BUG_ON(!head);
-
 	/* Copy RPC pages */
 	for (page_no = 0; page_no < head->count; page_no++) {
 		put_page(rqstp->rq_pages[page_no]);
@@ -567,7 +557,6 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	}
 	dprintk("svcrdma: processing ctxt=%p on xprt=%p, rqstp=%p, status=%d\n",
 		ctxt, rdma_xprt, rqstp, ctxt->wc_status);
-	BUG_ON(ctxt->wc_status != IB_WC_SUCCESS);
 	atomic_inc(&rdma_stat_recv);
 
 	/* Build up the XDR from the receive buffers. */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 9f1b506..7d79897 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -60,8 +60,11 @@ static int map_xdr(struct svcxprt_rdma *xprt,
 	u32 page_off;
 	int page_no;
 
-	BUG_ON(xdr->len !=
-	       (xdr->head[0].iov_len + xdr->page_len + xdr->tail[0].iov_len));
+	if (xdr->len !=
+	    (xdr->head[0].iov_len + xdr->page_len + xdr->tail[0].iov_len)) {
+		pr_err("svcrdma: map_xdr: XDR buffer length error\n");
+		return -EIO;
+	}
 
 	/* Skip the first sge, this is for the RPCRDMA header */
 	sge_no = 1;
@@ -150,7 +153,11 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 	int bc;
 	struct svc_rdma_op_ctxt *ctxt;
 
-	BUG_ON(vec->count > RPCSVC_MAXPAGES);
+	if (vec->count > RPCSVC_MAXPAGES) {
+		pr_err("svcrdma: Too many pages (%lu)\n", vec->count);
+		return -EIO;
+	}
+
 	dprintk("svcrdma: RDMA_WRITE rmr=%x, to=%llx, xdr_off=%d, "
 		"write_len=%d, vec->sge=%p, vec->count=%lu\n",
 		rmr, (unsigned long long)to, xdr_off,
@@ -190,7 +197,10 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 		sge_off = 0;
 		sge_no++;
 		xdr_sge_no++;
-		BUG_ON(xdr_sge_no > vec->count);
+		if (xdr_sge_no > vec->count) {
+			pr_err("svcrdma: Too many sges (%d)\n", xdr_sge_no);
+			goto err;
+		}
 		bc -= sge_bytes;
 		if (sge_no == xprt->sc_max_sge)
 			break;
@@ -421,7 +431,10 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		ctxt->sge[sge_no].lkey = rdma->sc_dma_lkey;
 		ctxt->sge[sge_no].length = sge_bytes;
 	}
-	BUG_ON(byte_count != 0);
+	if (byte_count != 0) {
+		pr_err("svcrdma: Could not map %d bytes\n", byte_count);
+		goto err;
+	}
 
 	/* Save all respages in the ctxt and remove them from the
 	 * respages array. They are our pages until the I/O
@@ -442,7 +455,10 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	}
 	rqstp->rq_next_page = rqstp->rq_respages + 1;
 
-	BUG_ON(sge_no > rdma->sc_max_sge);
+	if (sge_no > rdma->sc_max_sge) {
+		pr_err("svcrdma: Too many sges (%d)\n", sge_no);
+		goto err;
+	}
 	memset(&send_wr, 0, sizeof send_wr);
 	ctxt->wr_op = IB_WR_SEND;
 	send_wr.wr_id = (unsigned long)ctxt;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4ba11d0..f2e059b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -139,7 +139,6 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 	struct svcxprt_rdma *xprt;
 	int i;
 
-	BUG_ON(!ctxt);
 	xprt = ctxt->xprt;
 	if (free_pages)
 		for (i = 0; i < ctxt->count; i++)
@@ -339,12 +338,14 @@ static void process_context(struct svcxprt_rdma *xprt,
 
 	switch (ctxt->wr_op) {
 	case IB_WR_SEND:
-		BUG_ON(ctxt->frmr);
+		if (ctxt->frmr)
+			pr_err("svcrdma: SEND: ctxt->frmr != NULL\n");
 		svc_rdma_put_context(ctxt, 1);
 		break;
 
 	case IB_WR_RDMA_WRITE:
-		BUG_ON(ctxt->frmr);
+		if (ctxt->frmr)
+			pr_err("svcrdma: WRITE: ctxt->frmr != NULL\n");
 		svc_rdma_put_context(ctxt, 0);
 		break;
 
@@ -353,19 +354,21 @@ static void process_context(struct svcxprt_rdma *xprt,
 		svc_rdma_put_frmr(xprt, ctxt->frmr);
 		if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
 			struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
-			BUG_ON(!read_hdr);
-			spin_lock_bh(&xprt->sc_rq_dto_lock);
-			set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
-			list_add_tail(&read_hdr->dto_q,
-				      &xprt->sc_read_complete_q);
-			spin_unlock_bh(&xprt->sc_rq_dto_lock);
+			if (read_hdr) {
+				spin_lock_bh(&xprt->sc_rq_dto_lock);
+				set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
+				list_add_tail(&read_hdr->dto_q,
+					      &xprt->sc_read_complete_q);
+				spin_unlock_bh(&xprt->sc_rq_dto_lock);
+			} else {
+				pr_err("svcrdma: ctxt->read_hdr == NULL\n");
+			}
 			svc_xprt_enqueue(&xprt->sc_xprt);
 		}
 		svc_rdma_put_context(ctxt, 0);
 		break;
 
 	default:
-		BUG_ON(1);
 		printk(KERN_ERR "svcrdma: unexpected completion type, "
 		       "opcode=%d\n",
 		       ctxt->wr_op);
@@ -513,7 +516,10 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 	buflen = 0;
 	ctxt->direction = DMA_FROM_DEVICE;
 	for (sge_no = 0; buflen < xprt->sc_max_req_size; sge_no++) {
-		BUG_ON(sge_no >= xprt->sc_max_sge);
+		if (sge_no >= xprt->sc_max_sge) {
+			pr_err("svcrdma: Too many sges (%d)\n", sge_no);
+			goto err_put_ctxt;
+		}
 		page = svc_rdma_get_page();
 		ctxt->pages[sge_no] = page;
 		pa = ib_dma_map_page(xprt->sc_cm_id->device,
@@ -820,7 +826,7 @@ void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
 	if (frmr) {
 		frmr_unmap_dma(rdma, frmr);
 		spin_lock_bh(&rdma->sc_frmr_q_lock);
-		BUG_ON(!list_empty(&frmr->frmr_list));
+		WARN_ON_ONCE(!list_empty(&frmr->frmr_list));
 		list_add(&frmr->frmr_list, &rdma->sc_frmr_q);
 		spin_unlock_bh(&rdma->sc_frmr_q_lock);
 	}
@@ -1123,7 +1129,9 @@ static void __svc_rdma_free(struct work_struct *work)
 	dprintk("svcrdma: svc_rdma_free(%p)\n", rdma);
 
 	/* We should only be called from kref_put */
-	BUG_ON(atomic_read(&rdma->sc_xprt.xpt_ref.refcount) != 0);
+	if (atomic_read(&rdma->sc_xprt.xpt_ref.refcount) != 0)
+		pr_err("svcrdma: sc_xprt still in use? (%d)\n",
+		       atomic_read(&rdma->sc_xprt.xpt_ref.refcount));
 
 	/*
 	 * Destroy queued, but not processed read completions. Note
@@ -1151,8 +1159,12 @@ static void __svc_rdma_free(struct work_struct *work)
 	}
 
 	/* Warn if we leaked a resource or under-referenced */
-	WARN_ON(atomic_read(&rdma->sc_ctxt_used) != 0);
-	WARN_ON(atomic_read(&rdma->sc_dma_used) != 0);
+	if (atomic_read(&rdma->sc_ctxt_used) != 0)
+		pr_err("svcrdma: ctxt still in use? (%d)\n",
+		       atomic_read(&rdma->sc_ctxt_used));
+	if (atomic_read(&rdma->sc_dma_used) != 0)
+		pr_err("svcrdma: dma still in use? (%d)\n",
+		       atomic_read(&rdma->sc_dma_used));
 
 	/* De-allocate fastreg mr */
 	rdma_dealloc_frmr_q(rdma);
@@ -1252,7 +1264,6 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 	if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
 		return -ENOTCONN;
 
-	BUG_ON(wr->send_flags != IB_SEND_SIGNALED);
 	wr_count = 1;
 	for (n_wr = wr->next; n_wr; n_wr = n_wr->next)
 		wr_count++;


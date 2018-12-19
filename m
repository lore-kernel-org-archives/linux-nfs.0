Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 960ABC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4EF20217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="q83qzki6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727920AbeLSP7E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:04 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:54631 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP7E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:04 -0500
Received: by mail-it1-f196.google.com with SMTP id i145so10381543ita.4;
        Wed, 19 Dec 2018 07:59:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=t1SJVy6xliRSaevRIUULty8en2M27Vr2nLDmtsR3UYE=;
        b=q83qzki6E9n0zBeOegCDAcMaTciEFAUIr/hm3dC98pzp6j/ocfVHYSPAlG31xorU9C
         g3ydVthFDTJlPelFZ14GM1dcGI9Z6kWhwI7cIx35pT093Vhl7J99Tuna3upp9qsSaDen
         s14+m5fzX994FoJqfzgeysJ/s1hnKSlOG35VjILZbZFUMXFQ+dUVCjs3j0Fb5Ca/y9A7
         RzOpOh3eatFef/VFa6BgWrqQCWPg6jwPSE8xIzfFP3++CkKOLdeK/k2e4T93Xr8DsGSF
         vy9dtC7gvgG4HWRQALWI/HBKLP9XQ4DYiLacyPgzxluk06rJAMiMwODgxIhwjMnyC03n
         XefQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=t1SJVy6xliRSaevRIUULty8en2M27Vr2nLDmtsR3UYE=;
        b=ITlZsLv2QaeSe48LPQJUTbI1G16y8aCVtjzHPmlFlQQNKP72D94E0ua7mOxW8VAko5
         OToGTnsQZQAjLF7GWT49w6zIEqza5Yl6Ba7eCbN3xvzFQjfagD2sLcNQVMjl/Zm17N+q
         +vK1J4xtq03Yp0QHgn+MmVaibLogZ0w9vyUvpzDcYg8qdJXdgOb1SECwdO0vS96MYFmy
         7ZUfcg5UCWE6LUfY8FFbf4VByDdFJ+NYXQNe8zqqOE1/i+BWM9WGFlmJ4TNyETqKV0S8
         pno/tOVdyqCm3r9xB6GR9Wewzs+nlhnFGZ9JjKjMHv41ldBFUFEnuBS+jSl6CNLzGnlh
         0OGA==
X-Gm-Message-State: AA+aEWZWnNkMGFXTpZkMH8wi7PQPL5pBftppYpgT2+6Fr2cSTNrDXYc4
        rTOEu923pZP+2OEp/5CxiNA=
X-Google-Smtp-Source: AFSGD/X3AsOpZjjvYAQecV22PiwOoF87P2D6OAO/6DQw5Z2n+hlyWHWIx+CmQ/0LiEzzM9qzMPlbYQ==
X-Received: by 2002:a02:818c:: with SMTP id n12mr19594785jag.108.1545235143205;
        Wed, 19 Dec 2018 07:59:03 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 81sm5789059itz.15.2018.12.19.07.59.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:02 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFx1oM025786;
        Wed, 19 Dec 2018 15:59:01 GMT
Subject: [PATCH v5 10/30] xprtrdma: Remove rpcrdma_memreg_ops
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:01 -0500
Message-ID: <20181219155901.11602.15647.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up: Now that there is only FRWR, there is no need for a memory
registration switch. The indirect calls to the memreg operations can
be replaced with faster direct calls.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |  131 +++++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/rpc_rdma.c  |   14 +---
 net/sunrpc/xprtrdma/transport.c |    2 -
 net/sunrpc/xprtrdma/verbs.c     |   22 +++----
 net/sunrpc/xprtrdma/xprt_rdma.h |   48 +++++---------
 5 files changed, 116 insertions(+), 101 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 16976b0..fb0944d 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -15,21 +15,21 @@
 /* Normal operation
  *
  * A Memory Region is prepared for RDMA READ or WRITE using a FAST_REG
- * Work Request (frwr_op_map). When the RDMA operation is finished, this
+ * Work Request (frwr_map). When the RDMA operation is finished, this
  * Memory Region is invalidated using a LOCAL_INV Work Request
- * (frwr_op_unmap_sync).
+ * (frwr_unmap_sync).
  *
  * Typically these Work Requests are not signaled, and neither are RDMA
  * SEND Work Requests (with the exception of signaling occasionally to
  * prevent provider work queue overflows). This greatly reduces HCA
  * interrupt workload.
  *
- * As an optimization, frwr_op_unmap marks MRs INVALID before the
+ * As an optimization, frwr_unmap marks MRs INVALID before the
  * LOCAL_INV WR is posted. If posting succeeds, the MR is placed on
  * rb_mrs immediately so that no work (like managing a linked list
  * under a spinlock) is needed in the completion upcall.
  *
- * But this means that frwr_op_map() can occasionally encounter an MR
+ * But this means that frwr_map() can occasionally encounter an MR
  * that is INVALID but the LOCAL_INV WR has not completed. Work Queue
  * ordering prevents a subsequent FAST_REG WR from executing against
  * that MR while it is still being invalidated.
@@ -57,14 +57,14 @@
  * FLUSHED_LI:	The MR was being invalidated when the QP entered ERROR
  *		state, and the pending WR was flushed.
  *
- * When frwr_op_map encounters FLUSHED and VALID MRs, they are recovered
+ * When frwr_map encounters FLUSHED and VALID MRs, they are recovered
  * with ib_dereg_mr and then are re-initialized. Because MR recovery
  * allocates fresh resources, it is deferred to a workqueue, and the
  * recovered MRs are placed back on the rb_mrs list when recovery is
- * complete. frwr_op_map allocates another MR for the current RPC while
+ * complete. frwr_map allocates another MR for the current RPC while
  * the broken MR is reset.
  *
- * To ensure that frwr_op_map doesn't encounter an MR that is marked
+ * To ensure that frwr_map doesn't encounter an MR that is marked
  * INVALID but that is about to be flushed due to a previous transport
  * disconnect, the transport connect worker attempts to drain all
  * pending send queue WRs before the transport is reconnected.
@@ -80,8 +80,13 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
-bool
-frwr_is_supported(struct rpcrdma_ia *ia)
+/**
+ * frwr_is_supported - Check if device supports FRWR
+ * @ia: interface adapter to check
+ *
+ * Returns true if device supports FRWR, otherwise false
+ */
+bool frwr_is_supported(struct rpcrdma_ia *ia)
 {
 	struct ib_device_attr *attrs = &ia->ri_device->attrs;
 
@@ -97,8 +102,12 @@
 	return false;
 }
 
-static void
-frwr_op_release_mr(struct rpcrdma_mr *mr)
+/**
+ * frwr_release_mr - Destroy one MR
+ * @mr: MR allocated by frwr_init_mr
+ *
+ */
+void frwr_release_mr(struct rpcrdma_mr *mr)
 {
 	int rc;
 
@@ -132,11 +141,19 @@
 	list_del(&mr->mr_all);
 	r_xprt->rx_stats.mrs_recycled++;
 	spin_unlock(&r_xprt->rx_buf.rb_mrlock);
-	frwr_op_release_mr(mr);
+
+	frwr_release_mr(mr);
 }
 
-static int
-frwr_op_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
+/**
+ * frwr_init_mr - Initialize one MR
+ * @ia: interface adapter
+ * @mr: generic MR to prepare for FRWR
+ *
+ * Returns zero if successful. Otherwise a negative errno
+ * is returned.
+ */
+int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
 {
 	unsigned int depth = ia->ri_max_frwr_depth;
 	struct rpcrdma_frwr *frwr = &mr->frwr;
@@ -172,7 +189,13 @@
 	return rc;
 }
 
-/* On success, sets:
+/**
+ * frwr_open - Prepare an endpoint for use with FRWR
+ * @ia: interface adapter this endpoint will use
+ * @ep: endpoint to prepare
+ * @cdata: transport parameters
+ *
+ * On success, sets:
  *	ep->rep_attr.cap.max_send_wr
  *	ep->rep_attr.cap.max_recv_wr
  *	cdata->max_requests
@@ -181,10 +204,11 @@
  * And these FRWR-related fields:
  *	ia->ri_max_frwr_depth
  *	ia->ri_mrtype
+ *
+ * On failure, a negative errno is returned.
  */
-static int
-frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
-	     struct rpcrdma_create_data_internal *cdata)
+int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
+	      struct rpcrdma_create_data_internal *cdata)
 {
 	struct ib_device_attr *attrs = &ia->ri_device->attrs;
 	int max_qp_wr, depth, delta;
@@ -258,11 +282,16 @@
 	return 0;
 }
 
-/* FRWR mode conveys a list of pages per chunk segment. The
+/**
+ * frwr_maxpages - Compute size of largest payload
+ * @r_xprt: transport
+ *
+ * Returns maximum size of an RPC message, in pages.
+ *
+ * FRWR mode conveys a list of pages per chunk segment. The
  * maximum length of that list is the FRWR page list depth.
  */
-static size_t
-frwr_op_maxpages(struct rpcrdma_xprt *r_xprt)
+size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
@@ -344,12 +373,24 @@
 	trace_xprtrdma_wc_li_wake(wc, frwr);
 }
 
-/* Post a REG_MR Work Request to register a memory region
+/**
+ * frwr_map - Register a memory region
+ * @r_xprt: controlling transport
+ * @seg: memory region co-ordinates
+ * @nsegs: number of segments remaining
+ * @writing: true when RDMA Write will be used
+ * @out: initialized MR
+ *
+ * Prepare a REG_MR Work Request to register a memory region
  * for remote access via RDMA READ or RDMA WRITE.
+ *
+ * Returns the next segment or a negative errno pointer.
+ * On success, the prepared MR is planted in @out.
  */
-static struct rpcrdma_mr_seg *
-frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
-	    int nsegs, bool writing, struct rpcrdma_mr **out)
+struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
+				struct rpcrdma_mr_seg *seg,
+				int nsegs, bool writing,
+				struct rpcrdma_mr **out)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	bool holes_ok = ia->ri_mrtype == IB_MR_TYPE_SG_GAPS;
@@ -434,14 +475,18 @@
 	return ERR_PTR(-EIO);
 }
 
-/* Post Send WR containing the RPC Call message.
+/**
+ * frwr_send - post Send WR containing the RPC Call message
+ * @ia: interface adapter
+ * @req: Prepared RPC Call
  *
  * For FRMR, chain any FastReg WRs to the Send WR. Only a
  * single ib_post_send call is needed to register memory
  * and then post the Send WR.
+ *
+ * Returns the result of ib_post_send.
  */
-static int
-frwr_op_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
+int frwr_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 {
 	struct ib_send_wr *post_wr;
 	struct rpcrdma_mr *mr;
@@ -468,10 +513,13 @@
 	return ib_post_send(ia->ri_id->qp, post_wr, NULL);
 }
 
-/* Handle a remotely invalidated mr on the @mrs list
+/**
+ * frwr_reminv - handle a remotely invalidated mr on the @mrs list
+ * @rep: Received reply
+ * @mrs: list of MRs to check
+ *
  */
-static void
-frwr_op_reminv(struct rpcrdma_rep *rep, struct list_head *mrs)
+void frwr_reminv(struct rpcrdma_rep *rep, struct list_head *mrs)
 {
 	struct rpcrdma_mr *mr;
 
@@ -485,7 +533,10 @@
 		}
 }
 
-/* Invalidate all memory regions that were registered for "req".
+/**
+ * frwr_unmap_sync - invalidate memory regions that were registered for @req
+ * @r_xprt: controlling transport
+ * @mrs: list of MRs to process
  *
  * Sleeps until it is safe for the host CPU to access the
  * previously mapped memory regions.
@@ -493,8 +544,7 @@
  * Caller ensures that @mrs is not empty before the call. This
  * function empties the list.
  */
-static void
-frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct list_head *mrs)
+void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct list_head *mrs)
 {
 	struct ib_send_wr *first, **prev, *last;
 	const struct ib_send_wr *bad_wr;
@@ -577,16 +627,3 @@
 		rpcrdma_mr_recycle(mr);
 	}
 }
-
-const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
-	.ro_map				= frwr_op_map,
-	.ro_send			= frwr_op_send,
-	.ro_reminv			= frwr_op_reminv,
-	.ro_unmap_sync			= frwr_op_unmap_sync,
-	.ro_open			= frwr_op_open,
-	.ro_maxpages			= frwr_op_maxpages,
-	.ro_init_mr			= frwr_op_init_mr,
-	.ro_release_mr			= frwr_op_release_mr,
-	.ro_displayname			= "frwr",
-	.ro_send_w_inv_ok		= RPCRDMA_CMP_F_SND_W_INV_OK,
-};
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 5738c9f..2a2023d 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -356,8 +356,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		return nsegs;
 
 	do {
-		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						   false, &mr);
+		seg = frwr_map(r_xprt, seg, nsegs, false, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
@@ -414,8 +413,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	nchunks = 0;
 	do {
-		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						   true, &mr);
+		seg = frwr_map(r_xprt, seg, nsegs, true, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
@@ -472,8 +470,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	nchunks = 0;
 	do {
-		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						   true, &mr);
+		seg = frwr_map(r_xprt, seg, nsegs, true, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
@@ -1262,8 +1259,7 @@ void rpcrdma_release_rqst(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 * RPC has relinquished all its Send Queue entries.
 	 */
 	if (!list_empty(&req->rl_registered))
-		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt,
-						    &req->rl_registered);
+		frwr_unmap_sync(r_xprt, &req->rl_registered);
 
 	/* Ensure that any DMA mapped pages associated with
 	 * the Send of the RPC Call have been unmapped before
@@ -1292,7 +1288,7 @@ void rpcrdma_deferred_completion(struct work_struct *work)
 
 	trace_xprtrdma_defer_cmp(rep);
 	if (rep->rr_wc_flags & IB_WC_WITH_INVALIDATE)
-		r_xprt->rx_ia.ri_ops->ro_reminv(rep, &req->rl_registered);
+		frwr_reminv(rep, &req->rl_registered);
 	rpcrdma_release_rqst(r_xprt, req);
 	rpcrdma_complete_rqst(rep);
 }
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d3f26c5..89e11f9 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -399,7 +399,7 @@
 	INIT_DELAYED_WORK(&new_xprt->rx_connect_worker,
 			  xprt_rdma_connect_worker);
 
-	xprt->max_payload = new_xprt->rx_ia.ri_ops->ro_maxpages(new_xprt);
+	xprt->max_payload = frwr_maxpages(new_xprt);
 	if (xprt->max_payload == 0)
 		goto out4;
 	xprt->max_payload <<= PAGE_SHIFT;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index ef17596..0cce7b2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -289,10 +289,9 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		break;
 	}
 
-	dprintk("RPC:       %s: %s:%s on %s/%s: %s\n", __func__,
+	dprintk("RPC:       %s: %s:%s on %s/frwr: %s\n", __func__,
 		rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt),
-		ia->ri_device->name, ia->ri_ops->ro_displayname,
-		rdma_event_msg(event->event));
+		ia->ri_device->name, rdma_event_msg(event->event));
 	return 0;
 }
 
@@ -392,10 +391,8 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 
 	switch (xprt_rdma_memreg_strategy) {
 	case RPCRDMA_FRWR:
-		if (frwr_is_supported(ia)) {
-			ia->ri_ops = &rpcrdma_frwr_memreg_ops;
+		if (frwr_is_supported(ia))
 			break;
-		}
 		/*FALLTHROUGH*/
 	default:
 		pr_err("rpcrdma: Device %s does not support memreg mode %d\n",
@@ -509,7 +506,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	}
 	ia->ri_max_send_sges = max_sge;
 
-	rc = ia->ri_ops->ro_open(ia, ep, cdata);
+	rc = frwr_open(ia, ep, cdata);
 	if (rc)
 		return rc;
 
@@ -567,7 +564,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	/* Prepare RDMA-CM private message */
 	pmsg->cp_magic = rpcrdma_cmp_magic;
 	pmsg->cp_version = RPCRDMA_CMP_VERSION;
-	pmsg->cp_flags |= ia->ri_ops->ro_send_w_inv_ok;
+	pmsg->cp_flags |= RPCRDMA_CMP_F_SND_W_INV_OK;
 	pmsg->cp_send_size = rpcrdma_encode_buffer_size(cdata->inline_wsize);
 	pmsg->cp_recv_size = rpcrdma_encode_buffer_size(cdata->inline_rsize);
 	ep->rep_remote_cma.private_data = pmsg;
@@ -991,7 +988,7 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 		if (!mr)
 			break;
 
-		rc = ia->ri_ops->ro_init_mr(ia, mr);
+		rc = frwr_init_mr(ia, mr);
 		if (rc) {
 			kfree(mr);
 			break;
@@ -1171,7 +1168,6 @@ struct rpcrdma_req *
 {
 	struct rpcrdma_xprt *r_xprt = container_of(buf, struct rpcrdma_xprt,
 						   rx_buf);
-	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
 	struct rpcrdma_mr *mr;
 	unsigned int count;
 
@@ -1187,7 +1183,7 @@ struct rpcrdma_req *
 		if (!list_empty(&mr->mr_list))
 			list_del(&mr->mr_list);
 
-		ia->ri_ops->ro_release_mr(mr);
+		frwr_release_mr(mr);
 		count++;
 		spin_lock(&buf->rb_mrlock);
 	}
@@ -1381,7 +1377,7 @@ struct rpcrdma_req *
  *
  * xprtrdma uses a regbuf for posting an outgoing RDMA SEND, or for
  * receiving the payload of RDMA RECV operations. During Long Calls
- * or Replies they may be registered externally via ro_map.
+ * or Replies they may be registered externally via frwr_map.
  */
 struct rpcrdma_regbuf *
 rpcrdma_alloc_regbuf(size_t size, enum dma_data_direction direction,
@@ -1472,7 +1468,7 @@ struct rpcrdma_regbuf *
 		--ep->rep_send_count;
 	}
 
-	rc = ia->ri_ops->ro_send(ia, req);
+	rc = frwr_send(ia, req);
 	trace_xprtrdma_post_send(req, rc);
 	if (rc)
 		return -ENOTCONN;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 84f7bbe..c42a003 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -66,7 +66,6 @@
  * Interface Adapter -- one per transport instance
  */
 struct rpcrdma_ia {
-	const struct rpcrdma_memreg_ops	*ri_ops;
 	struct ib_device	*ri_device;
 	struct rdma_cm_id 	*ri_id;
 	struct ib_pd		*ri_pd;
@@ -406,7 +405,6 @@ struct rpcrdma_buffer {
 	struct workqueue_struct *rb_completion_wq;
 	struct delayed_work	rb_refresh_worker;
 };
-#define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
 
 /* rb_flags */
 enum {
@@ -457,34 +455,6 @@ struct rpcrdma_stats {
 };
 
 /*
- * Per-registration mode operations
- */
-struct rpcrdma_xprt;
-struct rpcrdma_memreg_ops {
-	struct rpcrdma_mr_seg *
-			(*ro_map)(struct rpcrdma_xprt *,
-				  struct rpcrdma_mr_seg *, int, bool,
-				  struct rpcrdma_mr **);
-	int		(*ro_send)(struct rpcrdma_ia *ia,
-				   struct rpcrdma_req *req);
-	void		(*ro_reminv)(struct rpcrdma_rep *rep,
-				     struct list_head *mrs);
-	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
-					 struct list_head *);
-	int		(*ro_open)(struct rpcrdma_ia *,
-				   struct rpcrdma_ep *,
-				   struct rpcrdma_create_data_internal *);
-	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
-	int		(*ro_init_mr)(struct rpcrdma_ia *,
-				      struct rpcrdma_mr *);
-	void		(*ro_release_mr)(struct rpcrdma_mr *mr);
-	const char	*ro_displayname;
-	const int	ro_send_w_inv_ok;
-};
-
-extern const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops;
-
-/*
  * RPCRDMA transport -- encapsulates the structures above for
  * integration with RPC.
  *
@@ -535,7 +505,6 @@ struct rpcrdma_xprt {
 int rpcrdma_ia_open(struct rpcrdma_xprt *xprt);
 void rpcrdma_ia_remove(struct rpcrdma_ia *ia);
 void rpcrdma_ia_close(struct rpcrdma_ia *);
-bool frwr_is_supported(struct rpcrdma_ia *);
 
 /*
  * Endpoint calls - xprtrdma/verbs.c
@@ -601,6 +570,23 @@ struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
 	return writing ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
 }
 
+/* Memory registration calls xprtrdma/frwr_ops.c
+ */
+bool frwr_is_supported(struct rpcrdma_ia *);
+int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
+	      struct rpcrdma_create_data_internal *cdata);
+int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr);
+void frwr_release_mr(struct rpcrdma_mr *mr);
+size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt);
+struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
+				struct rpcrdma_mr_seg *seg,
+				int nsegs, bool writing,
+				struct rpcrdma_mr **mr);
+int frwr_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req);
+void frwr_reminv(struct rpcrdma_rep *rep, struct list_head *mrs);
+void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt,
+		     struct list_head *mrs);
+
 /*
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */


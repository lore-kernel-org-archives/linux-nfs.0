Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35407 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbcHOUwv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:52:51 -0400
Subject: [PATCH v1 19/22] xprtrdma: Use gathered Send for large inline
 messages
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:52:49 -0400
Message-ID: <20160815205249.11652.23617.stgit@manet.1015granger.net>
In-Reply-To: <20160815195649.11652.32252.stgit@manet.1015granger.net>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An RPC Call message that is sent inline but that has a data payload
(ie, one or more items in rq_snd_buf's page list) must be "pulled
up:"

- call_allocate has to reserve enough RPC Call buffer space to
accommodate the data payload

- call_transmit has to memcopy the rq_snd_buf's page list and tail
into its head iovec before it is sent

As the inline threshold is increased beyond its current 1KB default,
however, this means data payloads of more than a few dozen bytes
will be copied by the host CPU. For example, if the inline threshold
is increased to 4KB, then NFS WRITE requests up to 4KB would involve
a memcpy of the NFS WRITE's payload data into the RPC Call buffer.
This is an undesirable amount of participation by the host CPU.

The inline threshold may be larger than 4KB in the future.

Instead of copying the components of rq_snd_buf into its head iovec,
construct a gather list of these components, and send them all in
place. The same approach is already used in the Linux server's
RPC-over-RDMA reply path.

This same mechanism eliminates the need for rpcrdma_tail_pullup,
which is used to manage the XDR pad and trailing inline content when
a Read list is present.

This requires that the pages in rq_snd_buf's page list be DMA-mapped
during marshaling, and unmapped when a data-bearing RPC is
completed. This is slightly less efficient for very small I/O
payloads, but significantly more efficient as payload size and
inline threshold increase past a kilobyte.

Note: xprtrdma does not typically signal Sends. So we are playing
just a little fast and loose by assuming that the arrival of an RPC
Reply means the earlier Send of the matching RPC Call has completed
and its Send buffer can be re-cycled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   16 +-
 net/sunrpc/xprtrdma/rpc_rdma.c    |  265 ++++++++++++++++++++++++++-----------
 net/sunrpc/xprtrdma/transport.c   |   14 --
 net/sunrpc/xprtrdma/verbs.c       |   13 +-
 net/sunrpc/xprtrdma/xprt_rdma.h   |   21 +++
 5 files changed, 216 insertions(+), 113 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 61a58f5..e3cecde 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -229,20 +229,12 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 		__func__, (int)rpclen, rqst->rq_svec[0].iov_base);
 #endif
 
-	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_rdmabuf))
+	req->rl_send_wr.num_sge = 0;
+	req->rl_mapped_pages = 0;
+	if (!rpcrdma_prepare_hdr_sge(r_xprt, req, RPCRDMA_HDRLEN_MIN))
 		goto out_map;
-	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
-	req->rl_send_iov[0].length = RPCRDMA_HDRLEN_MIN;
-	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
-
-	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_sendbuf))
+	if (!rpcrdma_prepare_msg_sge(r_xprt, req, &rqst->rq_snd_buf))
 		goto out_map;
-	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
-	req->rl_send_iov[1].length = rpclen;
-	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
-
-	req->rl_send_wr.num_sge = 2;
-
 	return 0;
 
 out_map:
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 31a434d..e125a86 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -503,74 +503,191 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 	return iptr;
 }
 
-/*
- * Copy write data inline.
- * This function is used for "small" requests. Data which is passed
- * to RPC via iovecs (or page list) is copied directly into the
- * pre-registered memory buffer for this request. For small amounts
- * of data, this is efficient. The cutoff value is tunable.
+static void
+rpcrdma_dma_sync_sge(struct rpcrdma_xprt *r_xprt, struct ib_sge *sge)
+{
+	struct ib_device *device = r_xprt->rx_ia.ri_device;
+
+	ib_dma_sync_single_for_device(device, sge->addr,
+				      sge->length, DMA_TO_DEVICE);
+}
+
+/* Prepare the RPC-over-RDMA header SGE.
  */
-static void rpcrdma_inline_pullup(struct rpc_rqst *rqst)
+bool
+rpcrdma_prepare_hdr_sge(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+			u32 len)
 {
-	int i, npages, curlen;
-	int copy_len;
-	unsigned char *srcp, *destp;
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
-	int page_base;
-	struct page **ppages;
+	struct rpcrdma_regbuf *rb = req->rl_rdmabuf;
+	struct ib_sge *sge = &req->rl_send_sge[0];
+
+	if (!rpcrdma_regbuf_is_mapped(rb)) {
+		if (!__rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, rb))
+			return false;
+		sge->addr = rdmab_addr(rb);
+		sge->lkey = rdmab_lkey(rb);
+	}
+	sge->length = len;
+
+	rpcrdma_dma_sync_sge(r_xprt, sge);
 
-	destp = rqst->rq_svec[0].iov_base;
-	curlen = rqst->rq_svec[0].iov_len;
-	destp += curlen;
+	dprintk("RPC:       %s:  hdr: sge[0]: [%p, %u]\n",
+		__func__, (void *)sge->addr, sge->length);
+	req->rl_send_wr.num_sge++;
+	return true;
+}
+
+/* Prepare the RPC payload SGE. The tail iovec is pulled up into
+ * the head, in case it is not in the same page (krb5p). The
+ * page list is skipped: either it is going via RDMA Read, or we
+ * already know for sure there is no page list.
+ */
+bool
+rpcrdma_prepare_msg_sge(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+			struct xdr_buf *xdr)
+{
+	struct rpcrdma_regbuf *rb = req->rl_sendbuf;
+	struct ib_sge *sge = &req->rl_send_sge[1];
 
-	dprintk("RPC:       %s: destp 0x%p len %d hdrlen %d\n",
-		__func__, destp, rqst->rq_slen, curlen);
+	/* covers both the head and tail iovecs */
+	if (!rpcrdma_regbuf_is_mapped(rb))
+		if (!__rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, rb))
+			return false;
 
-	copy_len = rqst->rq_snd_buf.page_len;
+	/* head iovec */
+	sge->addr = rdmab_addr(rb);
+	sge->length = xdr->head[0].iov_len;
+	sge->lkey = rdmab_lkey(rb);
 
-	if (rqst->rq_snd_buf.tail[0].iov_len) {
-		curlen = rqst->rq_snd_buf.tail[0].iov_len;
-		if (destp + copy_len != rqst->rq_snd_buf.tail[0].iov_base) {
-			memmove(destp + copy_len,
-				rqst->rq_snd_buf.tail[0].iov_base, curlen);
-			r_xprt->rx_stats.pullup_copy_count += curlen;
+	/* tail iovec */
+	sge->length += rpcrdma_tail_pullup(xdr);
+
+	rpcrdma_dma_sync_sge(r_xprt, sge);
+
+	dprintk("RPC:       %s: head: sge[1]: [%p, %u]\n",
+		__func__, (void *)sge->addr, sge->length);
+	req->rl_send_wr.num_sge++;
+	return true;
+}
+
+/* Prepare the Send SGEs. The head and tail iovec, and each entry
+ * in the page list, gets its own SGE.
+ */
+bool
+rpcrdma_prepare_msg_sges(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
+			 struct xdr_buf *xdr)
+{
+	struct rpcrdma_regbuf *rb = req->rl_sendbuf;
+	unsigned int i, page_base, len, remaining;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct ib_sge *sge = req->rl_send_sge;
+	struct page **ppages;
+	bool result;
+
+	i = 1;
+	result = false;
+
+	/* covers both the head and tail iovecs */
+	if (!rpcrdma_regbuf_is_mapped(rb))
+		if (!__rpcrdma_dma_map_regbuf(ia, rb))
+			goto out;
+
+	sge[i].addr = rdmab_addr(rb);
+	sge[i].length = xdr->head[0].iov_len;
+	sge[i].lkey = rdmab_lkey(rb);
+	rpcrdma_dma_sync_sge(r_xprt, &sge[i]);
+	dprintk("RPC:       %s: head: sge[%u]: [%p, %u]\n",
+		__func__, i, (void *)sge[i].addr, sge[i].length);
+
+	if (!xdr->page_len)
+		goto tail;
+
+	ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
+	page_base = xdr->page_base & ~PAGE_MASK;
+	remaining = xdr->page_len;
+	while (remaining) {
+		i++;
+		if (i > RPCRDMA_MAX_SEND_SGES - 2) {
+			pr_err("rpcrdma: too many Send SGEs (%u)\n", i);
+			goto out;
 		}
-		dprintk("RPC:       %s: tail destp 0x%p len %d\n",
-			__func__, destp + copy_len, curlen);
-		rqst->rq_svec[0].iov_len += curlen;
-	}
-	r_xprt->rx_stats.pullup_copy_count += copy_len;
 
-	page_base = rqst->rq_snd_buf.page_base;
-	ppages = rqst->rq_snd_buf.pages + (page_base >> PAGE_SHIFT);
-	page_base &= ~PAGE_MASK;
-	npages = PAGE_ALIGN(page_base+copy_len) >> PAGE_SHIFT;
-	for (i = 0; copy_len && i < npages; i++) {
-		curlen = PAGE_SIZE - page_base;
-		if (curlen > copy_len)
-			curlen = copy_len;
-		dprintk("RPC:       %s: page %d destp 0x%p len %d curlen %d\n",
-			__func__, i, destp, copy_len, curlen);
-		srcp = kmap_atomic(ppages[i]);
-		memcpy(destp, srcp+page_base, curlen);
-		kunmap_atomic(srcp);
-		rqst->rq_svec[0].iov_len += curlen;
-		destp += curlen;
-		copy_len -= curlen;
+		len = min_t(u32, PAGE_SIZE - page_base, remaining);
+		sge[i].addr = ib_dma_map_page(ia->ri_device, *ppages,
+					      page_base, len,
+					      DMA_TO_DEVICE);
+		if (ib_dma_mapping_error(ia->ri_device, sge->addr)) {
+			pr_err("rpcrdma: Send mapping error\n");
+			goto out;
+		}
+		sge[i].length = len;
+		sge[i].lkey = ia->ri_pd->local_dma_lkey;
+
+		dprintk("RPC:       %s: page: sge[%u]: [%p, %u]\n",
+			__func__, i, (void *)sge[i].addr, sge[i].length);
+		req->rl_mapped_pages++;
+		ppages++;
+		remaining -= len;
 		page_base = 0;
 	}
-	/* header now contains entire send message */
+
+tail:
+	if (xdr->tail[0].iov_len) {
+		unsigned char *destp;
+
+		/* The tail iovec is not always constructed in the same
+		 * page where the head iovec resides (see, for example,
+		 * gss_wrap_req_priv). Check for that, and if needed,
+		 * move the tail into the rb so that it is properly
+		 * DMA-mapped.
+		 */
+		len = xdr->tail[0].iov_len;
+		destp = xdr->head[0].iov_base;
+		destp += xdr->head[0].iov_len;
+		if (destp != xdr->tail[0].iov_base) {
+			dprintk("RPC:       %s: moving %u tail bytes\n",
+				__func__, len);
+			memmove(destp, xdr->tail[0].iov_base, len);
+			r_xprt->rx_stats.pullup_copy_count += len;
+		}
+
+		i++;
+		sge[i].addr = rdmab_addr(rb) + xdr->head[0].iov_len;
+		sge[i].length = len;
+		sge[i].lkey = rdmab_lkey(rb);
+		rpcrdma_dma_sync_sge(r_xprt, &sge[i]);
+		dprintk("RPC:       %s: tail: sge[%u]: [%p, %u]\n",
+			__func__, i, (void *)sge[i].addr, sge[i].length);
+	}
+
+	i++;
+	result = true;
+
+out:
+	req->rl_send_wr.num_sge = i;
+	return result;
+}
+
+void
+rpcrdma_pages_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
+{
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct ib_sge *sge;
+	unsigned int i;
+
+	for (i = 2; req->rl_mapped_pages--; i++) {
+		sge = &req->rl_send_sge[i];
+		dprintk("RPC:       %s: unmapping sge[%u]: [%p, %u]\n",
+			__func__, i, (void *)sge->addr, sge->length);
+		ib_dma_unmap_page(ia->ri_device, sge->addr,
+				  sge->length, DMA_TO_DEVICE);
+	}
 }
 
 /*
  * Marshal a request: the primary job of this routine is to choose
  * the transfer modes. See comments below.
  *
- * Prepares up to two IOVs per Call message:
- *
- *  [0] -- RPC RDMA header
- *  [1] -- the RPC header/data
- *
  * Returns zero on success, otherwise a negative errno.
  */
 
@@ -638,12 +755,11 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 */
 	if (rpcrdma_args_inline(r_xprt, rqst)) {
 		rtype = rpcrdma_noch;
-		rpcrdma_inline_pullup(rqst);
-		rpclen = rqst->rq_svec[0].iov_len;
+		rpclen = rqst->rq_snd_buf.len;
 	} else if (ddp_allowed && rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
 		rtype = rpcrdma_readch;
-		rpclen = rqst->rq_svec[0].iov_len;
-		rpclen += rpcrdma_tail_pullup(&rqst->rq_snd_buf);
+		rpclen = rqst->rq_snd_buf.head[0].iov_len +
+			 rqst->rq_snd_buf.tail[0].iov_len;
 	} else {
 		r_xprt->rx_stats.nomsg_call_count++;
 		headerp->rm_type = htonl(RDMA_NOMSG);
@@ -685,39 +801,30 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 		goto out_unmap;
 	hdrlen = (unsigned char *)iptr - (unsigned char *)headerp;
 
-	if (hdrlen + rpclen > r_xprt->rx_data.inline_wsize)
-		goto out_overflow;
-
 	dprintk("RPC: %5u %s: %s/%s: hdrlen %zd rpclen %zd\n",
 		rqst->rq_task->tk_pid, __func__,
 		transfertypes[rtype], transfertypes[wtype],
 		hdrlen, rpclen);
 
-	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_rdmabuf))
-		goto out_map;
-	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
-	req->rl_send_iov[0].length = hdrlen;
-	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
-
-	req->rl_send_wr.num_sge = 1;
-	if (rtype == rpcrdma_areadch)
-		return 0;
-
-	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_sendbuf))
+	req->rl_send_wr.num_sge = 0;
+	req->rl_mapped_pages = 0;
+	if (!rpcrdma_prepare_hdr_sge(r_xprt, req, hdrlen))
 		goto out_map;
-	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
-	req->rl_send_iov[1].length = rpclen;
-	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
 
-	req->rl_send_wr.num_sge = 2;
+	switch (rtype) {
+	case rpcrdma_areadch:
+		break;
+	case rpcrdma_readch:
+		if (!rpcrdma_prepare_msg_sge(r_xprt, req, &rqst->rq_snd_buf))
+			goto out_map;
+		break;
+	default:
+		if (!rpcrdma_prepare_msg_sges(r_xprt, req, &rqst->rq_snd_buf))
+			goto out_map;
+	}
 
 	return 0;
 
-out_overflow:
-	pr_err("rpcrdma: send overflow: hdrlen %zd rpclen %zu %s/%s\n",
-		hdrlen, rpclen, transfertypes[rtype], transfertypes[wtype]);
-	iptr = ERR_PTR(-EIO);
-
 out_unmap:
 	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
 	return PTR_ERR(iptr);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 0ee841f..1762f59 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -499,30 +499,21 @@ rpcrdma_get_rdmabuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 	return true;
 }
 
-/* RPC/RDMA marshaling may choose to send payload bearing ops inline,
- * if the resulting Call message is smaller than the inline threshold.
- * The value of the "rq_callsize" argument accounts for RPC header
- * requirements, but not for the data payload in these cases.
- *
- * See rpcrdma_inline_pullup.
- */
 static bool
 rpcrdma_get_sendbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		    size_t size, gfp_t flags)
 {
 	struct rpcrdma_regbuf *rb;
-	size_t min_size;
 
 	if (req->rl_sendbuf && rdmab_length(req->rl_sendbuf) >= size)
 		return true;
 
-	min_size = max_t(size_t, size, r_xprt->rx_data.inline_wsize);
-	rb = rpcrdma_alloc_regbuf(min_size, DMA_TO_DEVICE, flags);
+	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, flags);
 	if (IS_ERR(rb))
 		return false;
 
 	rpcrdma_free_regbuf(req->rl_sendbuf);
-	r_xprt->rx_stats.hardway_register_count += min_size;
+	r_xprt->rx_stats.hardway_register_count += size;
 	req->rl_sendbuf = rb;
 	return true;
 }
@@ -630,6 +621,7 @@ xprt_rdma_free(struct rpc_task *task)
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
 	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, !RPC_IS_ASYNC(task));
+	rpcrdma_pages_unmap(r_xprt, req);
 	rpcrdma_buffer_put(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 55ce5a8..f921a03 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -493,7 +493,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	unsigned int max_qp_wr;
 	int rc;
 
-	if (ia->ri_device->attrs.max_sge < RPCRDMA_MAX_IOVS) {
+	if (ia->ri_device->attrs.max_sge < RPCRDMA_MAX_SEND_SGES) {
 		dprintk("RPC:       %s: insufficient sge's available\n",
 			__func__);
 		return -ENOMEM;
@@ -522,7 +522,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
 	ep->rep_attr.cap.max_recv_wr += RPCRDMA_BACKWARD_WRS;
 	ep->rep_attr.cap.max_recv_wr += 1;	/* drain cqe */
-	ep->rep_attr.cap.max_send_sge = RPCRDMA_MAX_IOVS;
+	ep->rep_attr.cap.max_send_sge = RPCRDMA_MAX_SEND_SGES;
 	ep->rep_attr.cap.max_recv_sge = 1;
 	ep->rep_attr.cap.max_inline_data = 0;
 	ep->rep_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
@@ -891,7 +891,7 @@ rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 	INIT_LIST_HEAD(&req->rl_registered);
 	req->rl_send_wr.next = NULL;
 	req->rl_send_wr.wr_cqe = &req->rl_cqe;
-	req->rl_send_wr.sg_list = req->rl_send_iov;
+	req->rl_send_wr.sg_list = req->rl_send_sge;
 	req->rl_send_wr.opcode = IB_WR_SEND;
 	return req;
 }
@@ -1288,11 +1288,9 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 		struct rpcrdma_ep *ep,
 		struct rpcrdma_req *req)
 {
-	struct ib_device *device = ia->ri_device;
 	struct ib_send_wr *send_wr = &req->rl_send_wr;
 	struct ib_send_wr *send_wr_fail;
-	struct ib_sge *sge = req->rl_send_iov;
-	int i, rc;
+	int rc;
 
 	if (req->rl_reply) {
 		rc = rpcrdma_ep_post_recv(ia, req->rl_reply);
@@ -1301,9 +1299,6 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 		req->rl_reply = NULL;
 	}
 
-	for (i = 0; i < send_wr->num_sge; i++)
-		ib_dma_sync_single_for_device(device, sge[i].addr,
-					      sge[i].length, DMA_TO_DEVICE);
 	dprintk("RPC:       %s: posting %d s/g entries\n",
 		__func__, send_wr->num_sge);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 36b7180..f90da22 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -285,16 +285,27 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 	char		*mr_offset;	/* kva if no page, else offset */
 };
 
-#define RPCRDMA_MAX_IOVS	(2)
+/* Reserve enough Send SGEs to send a maximum size inline request:
+ * - RPC-over-RDMA header
+ * - xdr_buf head iovec
+ * - RPCRDMA_MAX_INLINE bytes, possibly unaligned, in pages
+ * - xdr_buf tail iovec
+ */
+enum {
+	RPCRDMA_MAX_SEND_PAGES = PAGE_SIZE + RPCRDMA_MAX_INLINE - 1,
+	RPCRDMA_MAX_PAGE_SGES = (RPCRDMA_MAX_SEND_PAGES >> PAGE_SHIFT) + 1,
+	RPCRDMA_MAX_SEND_SGES = 1 + 1 + RPCRDMA_MAX_PAGE_SGES + 1,
+};
 
 struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_free;
+	unsigned int		rl_mapped_pages;
 	unsigned int		rl_connect_cookie;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;
 	struct ib_send_wr	rl_send_wr;
-	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
+	struct ib_sge		rl_send_sge[RPCRDMA_MAX_SEND_SGES];
 	struct rpcrdma_regbuf	*rl_rdmabuf;	/* xprt header */
 	struct rpcrdma_regbuf	*rl_sendbuf;	/* rq_snd_buf */
 	struct rpcrdma_regbuf	*rl_recvbuf;	/* rq_rcv_buf */
@@ -528,6 +539,12 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
 /*
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */
+bool rpcrdma_prepare_hdr_sge(struct rpcrdma_xprt *, struct rpcrdma_req *, u32);
+bool rpcrdma_prepare_msg_sge(struct rpcrdma_xprt *, struct rpcrdma_req *,
+			     struct xdr_buf *);
+bool rpcrdma_prepare_msg_sges(struct rpcrdma_xprt *, struct rpcrdma_req *,
+			      struct xdr_buf *);
+void rpcrdma_pages_unmap(struct rpcrdma_xprt *, struct rpcrdma_req *);
 int rpcrdma_marshal_req(struct rpc_rqst *);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 


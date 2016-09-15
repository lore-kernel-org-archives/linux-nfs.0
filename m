Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32949 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbcIOO50 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 10:57:26 -0400
Subject: [PATCH v3 18/22] xprtrdma: Use gathered Send for large inline
 messages
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 15 Sep 2016 10:57:24 -0400
Message-ID: <20160915145724.11080.78191.stgit@manet.1015granger.net>
In-Reply-To: <20160915143440.11080.89241.stgit@manet.1015granger.net>
References: <20160915143440.11080.89241.stgit@manet.1015granger.net>
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
however, this means data payloads of more than a few KB are copied
by the host CPU. For example, if the inline threshold is increased
just to 4KB, then NFS WRITE requests up to 4KB would involve a
memcpy of the NFS WRITE's payload data into the RPC Call buffer.
This is an undesirable amount of participation by the host CPU.

The inline threshold may be much larger than 4KB in the future,
after negotiation with a peer server.

Instead of copying the components of rq_snd_buf into its head iovec,
construct a gather list of these components, and send them all in
place. The same approach is already used in the Linux server's
RPC-over-RDMA reply path.

This mechanism also eliminates the need for rpcrdma_tail_pullup,
which is used to manage the XDR pad and trailing inline content when
a Read list is present.

This requires that the pages in rq_snd_buf's page list be DMA-mapped
during marshaling, and unmapped when a data-bearing RPC is
completed. This is slightly less efficient for very small I/O
payloads, but significantly more efficient as data payload size and
inline threshold increase past a kilobyte.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   33 ----
 net/sunrpc/xprtrdma/rpc_rdma.c    |  301 +++++++++++++++++++++----------------
 net/sunrpc/xprtrdma/transport.c   |   18 +-
 net/sunrpc/xprtrdma/verbs.c       |   13 --
 net/sunrpc/xprtrdma/xprt_rdma.h   |   27 +++
 5 files changed, 207 insertions(+), 185 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 61a58f5..2c472e1 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -206,7 +206,6 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	struct rpcrdma_msg *headerp;
-	size_t rpclen;
 
 	headerp = rdmab_to_msg(req->rl_rdmabuf);
 	headerp->rm_xid = rqst->rq_xid;
@@ -218,36 +217,10 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 	headerp->rm_body.rm_chunks[1] = xdr_zero;
 	headerp->rm_body.rm_chunks[2] = xdr_zero;
 
-	rpclen = rqst->rq_svec[0].iov_len;
-
-#ifdef RPCRDMA_BACKCHANNEL_DEBUG
-	pr_info("RPC:       %s: rpclen %zd headerp 0x%p lkey 0x%x\n",
-		__func__, rpclen, headerp, rdmab_lkey(req->rl_rdmabuf));
-	pr_info("RPC:       %s: RPC/RDMA: %*ph\n",
-		__func__, (int)RPCRDMA_HDRLEN_MIN, headerp);
-	pr_info("RPC:       %s:      RPC: %*ph\n",
-		__func__, (int)rpclen, rqst->rq_svec[0].iov_base);
-#endif
-
-	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_rdmabuf))
-		goto out_map;
-	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
-	req->rl_send_iov[0].length = RPCRDMA_HDRLEN_MIN;
-	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
-
-	if (!rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, req->rl_sendbuf))
-		goto out_map;
-	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
-	req->rl_send_iov[1].length = rpclen;
-	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
-
-	req->rl_send_wr.num_sge = 2;
-
+	if (!rpcrdma_prepare_send_sges(&r_xprt->rx_ia, req, RPCRDMA_HDRLEN_MIN,
+				       &rqst->rq_snd_buf, rpcrdma_noch))
+		return -EIO;
 	return 0;
-
-out_map:
-	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
-	return -EIO;
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 31a434d..63bf011 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -53,14 +53,6 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
-enum rpcrdma_chunktype {
-	rpcrdma_noch = 0,
-	rpcrdma_readch,
-	rpcrdma_areadch,
-	rpcrdma_writech,
-	rpcrdma_replych
-};
-
 static const char transfertypes[][12] = {
 	"inline",	/* no chunks */
 	"read list",	/* some argument via rdma read */
@@ -157,42 +149,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return rqst->rq_rcv_buf.buflen <= ia->ri_max_inline_read;
 }
 
-static int
-rpcrdma_tail_pullup(struct xdr_buf *buf)
-{
-	size_t tlen = buf->tail[0].iov_len;
-	size_t skip = tlen & 3;
-
-	/* Do not include the tail if it is only an XDR pad */
-	if (tlen < 4)
-		return 0;
-
-	/* xdr_write_pages() adds a pad at the beginning of the tail
-	 * if the content in "buf->pages" is unaligned. Force the
-	 * tail's actual content to land at the next XDR position
-	 * after the head instead.
-	 */
-	if (skip) {
-		unsigned char *src, *dst;
-		unsigned int count;
-
-		src = buf->tail[0].iov_base;
-		dst = buf->head[0].iov_base;
-		dst += buf->head[0].iov_len;
-
-		src += skip;
-		tlen -= skip;
-
-		dprintk("RPC:       %s: skip=%zu, memmove(%p, %p, %zu)\n",
-			__func__, skip, dst, src, tlen);
-
-		for (count = tlen; count; count--)
-			*dst++ = *src++;
-	}
-
-	return tlen;
-}
-
 /* Split "vec" on page boundaries into segments. FMR registers pages,
  * not a byte range. Other modes coalesce these segments into a single
  * MR when they can.
@@ -503,74 +459,184 @@ rpcrdma_encode_reply_chunk(struct rpcrdma_xprt *r_xprt,
 	return iptr;
 }
 
-/*
- * Copy write data inline.
- * This function is used for "small" requests. Data which is passed
- * to RPC via iovecs (or page list) is copied directly into the
- * pre-registered memory buffer for this request. For small amounts
- * of data, this is efficient. The cutoff value is tunable.
+/* Prepare the RPC-over-RDMA header SGE.
  */
-static void rpcrdma_inline_pullup(struct rpc_rqst *rqst)
+static bool
+rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
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
+	if (unlikely(!rpcrdma_regbuf_is_mapped(rb))) {
+		if (!__rpcrdma_dma_map_regbuf(ia, rb))
+			return false;
+		sge->addr = rdmab_addr(rb);
+		sge->lkey = rdmab_lkey(rb);
+	}
+	sge->length = len;
 
-	destp = rqst->rq_svec[0].iov_base;
-	curlen = rqst->rq_svec[0].iov_len;
-	destp += curlen;
+	ib_dma_sync_single_for_device(ia->ri_device, sge->addr,
+				      sge->length, DMA_TO_DEVICE);
+	req->rl_send_wr.num_sge++;
+	return true;
+}
 
-	dprintk("RPC:       %s: destp 0x%p len %d hdrlen %d\n",
-		__func__, destp, rqst->rq_slen, curlen);
+/* Prepare the Send SGEs. The head and tail iovec, and each entry
+ * in the page list, gets its own SGE.
+ */
+static bool
+rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
+			 struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
+{
+	unsigned int sge_no, page_base, len, remaining;
+	struct rpcrdma_regbuf *rb = req->rl_sendbuf;
+	struct ib_device *device = ia->ri_device;
+	struct ib_sge *sge = req->rl_send_sge;
+	u32 lkey = ia->ri_pd->local_dma_lkey;
+	struct page *page, **ppages;
+
+	/* The head iovec is straightforward, as it is already
+	 * DMA-mapped. Sync the content that has changed.
+	 */
+	if (!rpcrdma_dma_map_regbuf(ia, rb))
+		return false;
+	sge_no = 1;
+	sge[sge_no].addr = rdmab_addr(rb);
+	sge[sge_no].length = xdr->head[0].iov_len;
+	sge[sge_no].lkey = rdmab_lkey(rb);
+	ib_dma_sync_single_for_device(device, sge[sge_no].addr,
+				      sge[sge_no].length, DMA_TO_DEVICE);
+
+	/* If there is a Read chunk, the page list is being handled
+	 * via explicit RDMA, and thus is skipped here. However, the
+	 * tail iovec may include an XDR pad for the page list, as
+	 * well as additional content, and may not reside in the
+	 * same page as the head iovec.
+	 */
+	if (rtype == rpcrdma_readch) {
+		len = xdr->tail[0].iov_len;
 
-	copy_len = rqst->rq_snd_buf.page_len;
+		/* Do not include the tail if it is only an XDR pad */
+		if (len < 4)
+			goto out;
 
-	if (rqst->rq_snd_buf.tail[0].iov_len) {
-		curlen = rqst->rq_snd_buf.tail[0].iov_len;
-		if (destp + copy_len != rqst->rq_snd_buf.tail[0].iov_base) {
-			memmove(destp + copy_len,
-				rqst->rq_snd_buf.tail[0].iov_base, curlen);
-			r_xprt->rx_stats.pullup_copy_count += curlen;
+		page = virt_to_page(xdr->tail[0].iov_base);
+		page_base = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
+
+		/* If the content in the page list is an odd length,
+		 * xdr_write_pages() has added a pad at the beginning
+		 * of the tail iovec. Force the tail's non-pad content
+		 * to land at the next XDR position in the Send message.
+		 */
+		page_base += len & 3;
+		len -= len & 3;
+		goto map_tail;
+	}
+
+	/* If there is a page list present, temporarily DMA map
+	 * and prepare an SGE for each page to be sent.
+	 */
+	if (xdr->page_len) {
+		ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
+		page_base = xdr->page_base & ~PAGE_MASK;
+		remaining = xdr->page_len;
+		while (remaining) {
+			sge_no++;
+			if (sge_no > RPCRDMA_MAX_SEND_SGES - 2)
+				goto out_mapping_overflow;
+
+			len = min_t(u32, PAGE_SIZE - page_base, remaining);
+			sge[sge_no].addr = ib_dma_map_page(device, *ppages,
+							   page_base, len,
+							   DMA_TO_DEVICE);
+			if (ib_dma_mapping_error(device, sge[sge_no].addr))
+				goto out_mapping_err;
+			sge[sge_no].length = len;
+			sge[sge_no].lkey = lkey;
+
+			req->rl_mapped_sges++;
+			ppages++;
+			remaining -= len;
+			page_base = 0;
 		}
-		dprintk("RPC:       %s: tail destp 0x%p len %d\n",
-			__func__, destp + copy_len, curlen);
-		rqst->rq_svec[0].iov_len += curlen;
 	}
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
-		page_base = 0;
+	/* The tail iovec is not always constructed in the same
+	 * page where the head iovec resides (see, for example,
+	 * gss_wrap_req_priv). To neatly accommodate that case,
+	 * DMA map it separately.
+	 */
+	if (xdr->tail[0].iov_len) {
+		page = virt_to_page(xdr->tail[0].iov_base);
+		page_base = (unsigned long)xdr->tail[0].iov_base & ~PAGE_MASK;
+		len = xdr->tail[0].iov_len;
+
+map_tail:
+		sge_no++;
+		sge[sge_no].addr = ib_dma_map_page(device, page,
+						   page_base, len,
+						   DMA_TO_DEVICE);
+		if (ib_dma_mapping_error(device, sge[sge_no].addr))
+			goto out_mapping_err;
+		sge[sge_no].length = len;
+		sge[sge_no].lkey = lkey;
+		req->rl_mapped_sges++;
 	}
-	/* header now contains entire send message */
+
+out:
+	req->rl_send_wr.num_sge = sge_no + 1;
+	return true;
+
+out_mapping_overflow:
+	pr_err("rpcrdma: too many Send SGEs (%u)\n", sge_no);
+	return false;
+
+out_mapping_err:
+	pr_err("rpcrdma: Send mapping error\n");
+	return false;
+}
+
+bool
+rpcrdma_prepare_send_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
+			  u32 hdrlen, struct xdr_buf *xdr,
+			  enum rpcrdma_chunktype rtype)
+{
+	req->rl_send_wr.num_sge = 0;
+	req->rl_mapped_sges = 0;
+
+	if (!rpcrdma_prepare_hdr_sge(ia, req, hdrlen))
+		goto out_map;
+
+	if (rtype != rpcrdma_areadch)
+		if (!rpcrdma_prepare_msg_sges(ia, req, xdr, rtype))
+			goto out_map;
+
+	return true;
+
+out_map:
+	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
+	return false;
+}
+
+void
+rpcrdma_unmap_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
+{
+	struct ib_device *device = ia->ri_device;
+	struct ib_sge *sge;
+	int count;
+
+	sge = &req->rl_send_sge[2];
+	for (count = req->rl_mapped_sges; count--; sge++)
+		ib_dma_unmap_page(device, sge->addr, sge->length,
+				  DMA_TO_DEVICE);
+	req->rl_mapped_sges = 0;
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
 
@@ -638,12 +704,11 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
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
@@ -685,47 +750,21 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
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
-		goto out_map;
-	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
-	req->rl_send_iov[1].length = rpclen;
-	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
-
-	req->rl_send_wr.num_sge = 2;
-
+	if (!rpcrdma_prepare_send_sges(&r_xprt->rx_ia, req, hdrlen,
+				       &rqst->rq_snd_buf, rtype)) {
+		iptr = ERR_PTR(-EIO);
+		goto out_unmap;
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
-
-out_map:
-	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
-	iptr = ERR_PTR(-EIO);
-	goto out_unmap;
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 7e11d71..6a358ab 100644
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
@@ -623,14 +614,15 @@ xprt_rdma_free(struct rpc_task *task)
 	struct rpc_rqst *rqst = task->tk_rqstp;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
 	if (req->rl_backchannel)
 		return;
 
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
-	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req,
-					    !RPC_IS_ASYNC(task));
+	ia->ri_ops->ro_unmap_safe(r_xprt, req, !RPC_IS_ASYNC(task));
+	rpcrdma_unmap_sges(ia, req);
 	rpcrdma_buffer_put(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index e2d6390..eeaca9c 100644
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
@@ -1306,11 +1306,9 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
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
@@ -1319,9 +1317,6 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 		req->rl_reply = NULL;
 	}
 
-	for (i = 0; i < send_wr->num_sge; i++)
-		ib_dma_sync_single_for_device(device, sge[i].addr,
-					      sge[i].length, DMA_TO_DEVICE);
 	dprintk("RPC:       %s: posting %d s/g entries\n",
 		__func__, send_wr->num_sge);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 64b4e22..b2823d9 100644
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
+	unsigned int		rl_mapped_sges;
 	unsigned int		rl_connect_cookie;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;
 	struct ib_send_wr	rl_send_wr;
-	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
+	struct ib_sge		rl_send_sge[RPCRDMA_MAX_SEND_SGES];
 	struct rpcrdma_regbuf	*rl_rdmabuf;	/* xprt header */
 	struct rpcrdma_regbuf	*rl_sendbuf;	/* rq_snd_buf */
 	struct rpcrdma_regbuf	*rl_recvbuf;	/* rq_rcv_buf */
@@ -529,6 +540,18 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
 /*
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */
+
+enum rpcrdma_chunktype {
+	rpcrdma_noch = 0,
+	rpcrdma_readch,
+	rpcrdma_areadch,
+	rpcrdma_writech,
+	rpcrdma_replych
+};
+
+bool rpcrdma_prepare_send_sges(struct rpcrdma_ia *, struct rpcrdma_req *,
+			       u32, struct xdr_buf *, enum rpcrdma_chunktype);
+void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
 int rpcrdma_marshal_req(struct rpc_rqst *);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 


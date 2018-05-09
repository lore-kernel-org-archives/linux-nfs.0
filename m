Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53506 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935325AbeEIVSX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 May 2018 17:18:23 -0400
Date: Wed, 9 May 2018 17:18:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 10/19] svcrdma: Persistently allocate and DMA-map
 Receive buffers
Message-ID: <20180509211822.GD31959@fieldses.org>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
 <20180507192743.4608.77698.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180507192743.4608.77698.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 07, 2018 at 03:27:43PM -0400, Chuck Lever wrote:
> The current Receive path uses an array of pages which are allocated
> and DMA mapped when each Receive WR is posted, and then handed off
> to the upper layer in rqstp::rq_arg. The page flip releases unused
> pages in the rq_pages pagelist. This mechanism introduces a
> significant amount of overhead.
> 
> So instead, kmalloc the Receive buffer, and leave it DMA-mapped
> while the transport remains connected. This confers a number of
> benefits:
> 
> * Each Receive WR requires only one receive SGE, no matter how large
>   the inline threshold is. This helps the server-side NFS/RDMA
>   transport operate on less capable RDMA devices.
> 
> * The Receive buffer is left allocated and mapped all the time. This
>   relieves svc_rdma_post_recv from the overhead of allocating and
>   DMA-mapping a fresh buffer.

Dumb question: does that mean the buffer could still change if the
client does something weird?  (So could the xdr decoding code see data
change out from under it?)

--b.

> 
> * svc_rdma_wc_receive no longer has to DMA unmap the Receive buffer.
>   It has to DMA sync only the number of bytes that were received.
> 
> * svc_rdma_build_arg_xdr no longer has to free a page in rq_pages
>   for each page in the Receive buffer, making it a constant-time
>   function.
> 
> * The Receive buffer is now plugged directly into the rq_arg's
>   head[0].iov_vec, and can be larger than a page without spilling
>   over into rq_arg's page list. This enables simplification of
>   the RDMA Read path in subsequent patches.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/svc_rdma.h          |    4 -
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  168 +++++++++++-------------------
>  net/sunrpc/xprtrdma/svc_rdma_rw.c        |   32 ++----
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    5 -
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 
>  5 files changed, 75 insertions(+), 136 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index f0bd0b6d..01baabf 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -148,12 +148,12 @@ struct svc_rdma_recv_ctxt {
>  	struct list_head	rc_list;
>  	struct ib_recv_wr	rc_recv_wr;
>  	struct ib_cqe		rc_cqe;
> +	struct ib_sge		rc_recv_sge;
> +	void			*rc_recv_buf;
>  	struct xdr_buf		rc_arg;
>  	u32			rc_byte_len;
>  	unsigned int		rc_page_count;
>  	unsigned int		rc_hdr_count;
> -	struct ib_sge		rc_sges[1 +
> -					RPCRDMA_MAX_INLINE_THRESH / PAGE_SIZE];
>  	struct page		*rc_pages[RPCSVC_MAXPAGES];
>  };
>  
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index d9fef52..d4ccd1c 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -117,6 +117,43 @@
>  					rc_list);
>  }
>  
> +static struct svc_rdma_recv_ctxt *
> +svc_rdma_recv_ctxt_alloc(struct svcxprt_rdma *rdma)
> +{
> +	struct svc_rdma_recv_ctxt *ctxt;
> +	dma_addr_t addr;
> +	void *buffer;
> +
> +	ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
> +	if (!ctxt)
> +		goto fail0;
> +	buffer = kmalloc(rdma->sc_max_req_size, GFP_KERNEL);
> +	if (!buffer)
> +		goto fail1;
> +	addr = ib_dma_map_single(rdma->sc_pd->device, buffer,
> +				 rdma->sc_max_req_size, DMA_FROM_DEVICE);
> +	if (ib_dma_mapping_error(rdma->sc_pd->device, addr))
> +		goto fail2;
> +
> +	ctxt->rc_recv_wr.next = NULL;
> +	ctxt->rc_recv_wr.wr_cqe = &ctxt->rc_cqe;
> +	ctxt->rc_recv_wr.sg_list = &ctxt->rc_recv_sge;
> +	ctxt->rc_recv_wr.num_sge = 1;
> +	ctxt->rc_cqe.done = svc_rdma_wc_receive;
> +	ctxt->rc_recv_sge.addr = addr;
> +	ctxt->rc_recv_sge.length = rdma->sc_max_req_size;
> +	ctxt->rc_recv_sge.lkey = rdma->sc_pd->local_dma_lkey;
> +	ctxt->rc_recv_buf = buffer;
> +	return ctxt;
> +
> +fail2:
> +	kfree(buffer);
> +fail1:
> +	kfree(ctxt);
> +fail0:
> +	return NULL;
> +}
> +
>  /**
>   * svc_rdma_recv_ctxts_destroy - Release all recv_ctxt's for an xprt
>   * @rdma: svcxprt_rdma being torn down
> @@ -128,6 +165,11 @@ void svc_rdma_recv_ctxts_destroy(struct svcxprt_rdma *rdma)
>  
>  	while ((ctxt = svc_rdma_next_recv_ctxt(&rdma->sc_recv_ctxts))) {
>  		list_del(&ctxt->rc_list);
> +		ib_dma_unmap_single(rdma->sc_pd->device,
> +				    ctxt->rc_recv_sge.addr,
> +				    ctxt->rc_recv_sge.length,
> +				    DMA_FROM_DEVICE);
> +		kfree(ctxt->rc_recv_buf);
>  		kfree(ctxt);
>  	}
>  }
> @@ -145,32 +187,18 @@ void svc_rdma_recv_ctxts_destroy(struct svcxprt_rdma *rdma)
>  	spin_unlock(&rdma->sc_recv_lock);
>  
>  out:
> -	ctxt->rc_recv_wr.num_sge = 0;
>  	ctxt->rc_page_count = 0;
>  	return ctxt;
>  
>  out_empty:
>  	spin_unlock(&rdma->sc_recv_lock);
>  
> -	ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
> +	ctxt = svc_rdma_recv_ctxt_alloc(rdma);
>  	if (!ctxt)
>  		return NULL;
>  	goto out;
>  }
>  
> -static void svc_rdma_recv_ctxt_unmap(struct svcxprt_rdma *rdma,
> -				     struct svc_rdma_recv_ctxt *ctxt)
> -{
> -	struct ib_device *device = rdma->sc_cm_id->device;
> -	int i;
> -
> -	for (i = 0; i < ctxt->rc_recv_wr.num_sge; i++)
> -		ib_dma_unmap_page(device,
> -				  ctxt->rc_sges[i].addr,
> -				  ctxt->rc_sges[i].length,
> -				  DMA_FROM_DEVICE);
> -}
> -
>  /**
>   * svc_rdma_recv_ctxt_put - Return recv_ctxt to free list
>   * @rdma: controlling svcxprt_rdma
> @@ -191,46 +219,14 @@ void svc_rdma_recv_ctxt_put(struct svcxprt_rdma *rdma,
>  
>  static int svc_rdma_post_recv(struct svcxprt_rdma *rdma)
>  {
> -	struct ib_device *device = rdma->sc_cm_id->device;
>  	struct svc_rdma_recv_ctxt *ctxt;
>  	struct ib_recv_wr *bad_recv_wr;
> -	int sge_no, buflen, ret;
> -	struct page *page;
> -	dma_addr_t pa;
> +	int ret;
>  
>  	ctxt = svc_rdma_recv_ctxt_get(rdma);
>  	if (!ctxt)
>  		return -ENOMEM;
>  
> -	buflen = 0;
> -	ctxt->rc_cqe.done = svc_rdma_wc_receive;
> -	for (sge_no = 0; buflen < rdma->sc_max_req_size; sge_no++) {
> -		if (sge_no >= rdma->sc_max_sge) {
> -			pr_err("svcrdma: Too many sges (%d)\n", sge_no);
> -			goto err_put_ctxt;
> -		}
> -
> -		page = alloc_page(GFP_KERNEL);
> -		if (!page)
> -			goto err_put_ctxt;
> -		ctxt->rc_pages[sge_no] = page;
> -		ctxt->rc_page_count++;
> -
> -		pa = ib_dma_map_page(device, ctxt->rc_pages[sge_no],
> -				     0, PAGE_SIZE, DMA_FROM_DEVICE);
> -		if (ib_dma_mapping_error(device, pa))
> -			goto err_put_ctxt;
> -		ctxt->rc_sges[sge_no].addr = pa;
> -		ctxt->rc_sges[sge_no].length = PAGE_SIZE;
> -		ctxt->rc_sges[sge_no].lkey = rdma->sc_pd->local_dma_lkey;
> -		ctxt->rc_recv_wr.num_sge++;
> -
> -		buflen += PAGE_SIZE;
> -	}
> -	ctxt->rc_recv_wr.next = NULL;
> -	ctxt->rc_recv_wr.sg_list = &ctxt->rc_sges[0];
> -	ctxt->rc_recv_wr.wr_cqe = &ctxt->rc_cqe;
> -
>  	svc_xprt_get(&rdma->sc_xprt);
>  	ret = ib_post_recv(rdma->sc_qp, &ctxt->rc_recv_wr, &bad_recv_wr);
>  	trace_svcrdma_post_recv(&ctxt->rc_recv_wr, ret);
> @@ -238,12 +234,7 @@ static int svc_rdma_post_recv(struct svcxprt_rdma *rdma)
>  		goto err_post;
>  	return 0;
>  
> -err_put_ctxt:
> -	svc_rdma_recv_ctxt_unmap(rdma, ctxt);
> -	svc_rdma_recv_ctxt_put(rdma, ctxt);
> -	return -ENOMEM;
>  err_post:
> -	svc_rdma_recv_ctxt_unmap(rdma, ctxt);
>  	svc_rdma_recv_ctxt_put(rdma, ctxt);
>  	svc_xprt_put(&rdma->sc_xprt);
>  	return ret;
> @@ -289,7 +280,6 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
>  
>  	/* WARNING: Only wc->wr_cqe and wc->status are reliable */
>  	ctxt = container_of(cqe, struct svc_rdma_recv_ctxt, rc_cqe);
> -	svc_rdma_recv_ctxt_unmap(rdma, ctxt);
>  
>  	if (wc->status != IB_WC_SUCCESS)
>  		goto flushed;
> @@ -299,6 +289,10 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
>  
>  	/* All wc fields are now known to be valid */
>  	ctxt->rc_byte_len = wc->byte_len;
> +	ib_dma_sync_single_for_cpu(rdma->sc_pd->device,
> +				   ctxt->rc_recv_sge.addr,
> +				   wc->byte_len, DMA_FROM_DEVICE);
> +
>  	spin_lock(&rdma->sc_rq_dto_lock);
>  	list_add_tail(&ctxt->rc_list, &rdma->sc_rq_dto_q);
>  	spin_unlock(&rdma->sc_rq_dto_lock);
> @@ -339,64 +333,22 @@ void svc_rdma_flush_recv_queues(struct svcxprt_rdma *rdma)
>  	}
>  }
>  
> -/*
> - * Replace the pages in the rq_argpages array with the pages from the SGE in
> - * the RDMA_RECV completion. The SGL should contain full pages up until the
> - * last one.
> - */
>  static void svc_rdma_build_arg_xdr(struct svc_rqst *rqstp,
>  				   struct svc_rdma_recv_ctxt *ctxt)
>  {
> -	struct page *page;
> -	int sge_no;
> -	u32 len;
> -
> -	/* The reply path assumes the Call's transport header resides
> -	 * in rqstp->rq_pages[0].
> -	 */
> -	page = ctxt->rc_pages[0];
> -	put_page(rqstp->rq_pages[0]);
> -	rqstp->rq_pages[0] = page;
> -
> -	/* Set up the XDR head */
> -	rqstp->rq_arg.head[0].iov_base = page_address(page);
> -	rqstp->rq_arg.head[0].iov_len =
> -		min_t(size_t, ctxt->rc_byte_len, ctxt->rc_sges[0].length);
> -	rqstp->rq_arg.len = ctxt->rc_byte_len;
> -	rqstp->rq_arg.buflen = ctxt->rc_byte_len;
> -
> -	/* Compute bytes past head in the SGL */
> -	len = ctxt->rc_byte_len - rqstp->rq_arg.head[0].iov_len;
> -
> -	/* If data remains, store it in the pagelist */
> -	rqstp->rq_arg.page_len = len;
> -	rqstp->rq_arg.page_base = 0;
> -
> -	sge_no = 1;
> -	while (len && sge_no < ctxt->rc_recv_wr.num_sge) {
> -		page = ctxt->rc_pages[sge_no];
> -		put_page(rqstp->rq_pages[sge_no]);
> -		rqstp->rq_pages[sge_no] = page;
> -		len -= min_t(u32, len, ctxt->rc_sges[sge_no].length);
> -		sge_no++;
> -	}
> -	ctxt->rc_hdr_count = sge_no;
> -	rqstp->rq_respages = &rqstp->rq_pages[sge_no];
> +	struct xdr_buf *arg = &rqstp->rq_arg;
> +
> +	arg->head[0].iov_base = ctxt->rc_recv_buf;
> +	arg->head[0].iov_len = ctxt->rc_byte_len;
> +	arg->tail[0].iov_base = NULL;
> +	arg->tail[0].iov_len = 0;
> +	arg->page_len = 0;
> +	arg->page_base = 0;
> +	arg->buflen = ctxt->rc_byte_len;
> +	arg->len = ctxt->rc_byte_len;
> +
> +	rqstp->rq_respages = &rqstp->rq_pages[0];
>  	rqstp->rq_next_page = rqstp->rq_respages + 1;
> -
> -	/* If not all pages were used from the SGL, free the remaining ones */
> -	while (sge_no < ctxt->rc_recv_wr.num_sge) {
> -		page = ctxt->rc_pages[sge_no++];
> -		put_page(page);
> -	}
> -
> -	/* @ctxt's pages have all been released or moved to @rqstp->rq_pages.
> -	 */
> -	ctxt->rc_page_count = 0;
> -
> -	/* Set up tail */
> -	rqstp->rq_arg.tail[0].iov_base = NULL;
> -	rqstp->rq_arg.tail[0].iov_len = 0;
>  }
>  
>  /* This accommodates the largest possible Write chunk,
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> index 8242aa3..ce3ea84 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> @@ -718,15 +718,14 @@ static int svc_rdma_build_normal_read_chunk(struct svc_rqst *rqstp,
>  	struct svc_rdma_recv_ctxt *head = info->ri_readctxt;
>  	int ret;
>  
> -	info->ri_pageno = head->rc_hdr_count;
> -	info->ri_pageoff = 0;
> -
>  	ret = svc_rdma_build_read_chunk(rqstp, info, p);
>  	if (ret < 0)
>  		goto out;
>  
>  	trace_svcrdma_encode_read(info->ri_chunklen, info->ri_position);
>  
> +	head->rc_hdr_count = 0;
> +
>  	/* Split the Receive buffer between the head and tail
>  	 * buffers at Read chunk's position. XDR roundup of the
>  	 * chunk is not included in either the pagelist or in
> @@ -775,9 +774,6 @@ static int svc_rdma_build_pz_read_chunk(struct svc_rqst *rqstp,
>  	struct svc_rdma_recv_ctxt *head = info->ri_readctxt;
>  	int ret;
>  
> -	info->ri_pageno = head->rc_hdr_count - 1;
> -	info->ri_pageoff = offset_in_page(head->rc_byte_len);
> -
>  	ret = svc_rdma_build_read_chunk(rqstp, info, p);
>  	if (ret < 0)
>  		goto out;
> @@ -787,20 +783,13 @@ static int svc_rdma_build_pz_read_chunk(struct svc_rqst *rqstp,
>  	head->rc_arg.len += info->ri_chunklen;
>  	head->rc_arg.buflen += info->ri_chunklen;
>  
> -	if (head->rc_arg.buflen <= head->rc_sges[0].length) {
> -		/* Transport header and RPC message fit entirely
> -		 * in page where head iovec resides.
> -		 */
> -		head->rc_arg.head[0].iov_len = info->ri_chunklen;
> -	} else {
> -		/* Transport header and part of RPC message reside
> -		 * in the head iovec's page.
> -		 */
> -		head->rc_arg.head[0].iov_len =
> -			head->rc_sges[0].length - head->rc_byte_len;
> -		head->rc_arg.page_len =
> -			info->ri_chunklen - head->rc_arg.head[0].iov_len;
> -	}
> +	head->rc_hdr_count = 1;
> +	head->rc_arg.head[0].iov_base = page_address(head->rc_pages[0]);
> +	head->rc_arg.head[0].iov_len = min_t(size_t, PAGE_SIZE,
> +					     info->ri_chunklen);
> +
> +	head->rc_arg.page_len = info->ri_chunklen -
> +				head->rc_arg.head[0].iov_len;
>  
>  out:
>  	return ret;
> @@ -834,7 +823,6 @@ int svc_rdma_recv_read_chunk(struct svcxprt_rdma *rdma, struct svc_rqst *rqstp,
>  	 * head->rc_arg. Pages involved with RDMA Read I/O are
>  	 * transferred there.
>  	 */
> -	head->rc_page_count = head->rc_hdr_count;
>  	head->rc_arg.head[0] = rqstp->rq_arg.head[0];
>  	head->rc_arg.tail[0] = rqstp->rq_arg.tail[0];
>  	head->rc_arg.pages = head->rc_pages;
> @@ -847,6 +835,8 @@ int svc_rdma_recv_read_chunk(struct svcxprt_rdma *rdma, struct svc_rqst *rqstp,
>  	if (!info)
>  		return -ENOMEM;
>  	info->ri_readctxt = head;
> +	info->ri_pageno = 0;
> +	info->ri_pageoff = 0;
>  
>  	info->ri_position = be32_to_cpup(p + 1);
>  	if (info->ri_position)
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index cbbde70..b27b597 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -629,10 +629,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>  	struct page *res_page;
>  	int ret;
>  
> -	/* Find the call's chunk lists to decide how to send the reply.
> -	 * Receive places the Call's xprt header at the start of page 0.
> -	 */
> -	rdma_argp = page_address(rqstp->rq_pages[0]);
> +	rdma_argp = rctxt->rc_recv_buf;
>  	svc_rdma_get_write_arrays(rdma_argp, &wr_lst, &rp_ch);
>  
>  	/* Create the RDMA response header. xprt->xpt_mutex,
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 20abd3a..333c432 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -670,7 +670,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>  	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth - ctxts;
>  	qp_attr.cap.max_recv_wr = rq_depth;
>  	qp_attr.cap.max_send_sge = newxprt->sc_max_sge;
> -	qp_attr.cap.max_recv_sge = newxprt->sc_max_sge;
> +	qp_attr.cap.max_recv_sge = 1;
>  	qp_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
>  	qp_attr.qp_type = IB_QPT_RC;
>  	qp_attr.send_cq = newxprt->sc_sq_cq;

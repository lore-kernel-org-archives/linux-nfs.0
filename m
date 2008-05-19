From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 05/05] svcrdma: Add dma map count and WARN_ON
Date: Mon, 19 May 2008 15:18:56 -0400
Message-ID: <20080519191856.GE11993@fieldses.org>
References: <12111560011694-git-send-email-tom@opengridcomputing.com> <12111560022506-git-send-email-tom@opengridcomputing.com> <1211156002624-git-send-email-tom@opengridcomputing.com> <12111560022695-git-send-email-tom@opengridcomputing.com> <12111560022073-git-send-email-tom@opengridcomputing.com> <12111560023250-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34809 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430AbYESTS6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 15:18:58 -0400
In-Reply-To: <12111560023250-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 18, 2008 at 07:13:21PM -0500, Tom Tucker wrote:
> Add a dma map count in order to verify that all DMA mapping resources
> have been freed at unmount.

I'm not sure what you mean by "at unmount".

--b.

> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  include/linux/sunrpc/svc_rdma.h          |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    3 +++
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +++++
>  4 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index 29bfc9b..0a9c431 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -105,6 +105,7 @@ struct svcxprt_rdma {
>  
>  	struct ib_pd         *sc_pd;
>  
> +	atomic_t	     sc_dma_used;
>  	atomic_t	     sc_ctxt_used;
>  	struct list_head     sc_ctxt_free;
>  	int		     sc_ctxt_cnt;
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 174e888..9b3dff0 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -229,6 +229,7 @@ static void rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
>  	ctxt->count = count;
>  	ctxt->direction = DMA_FROM_DEVICE;
>  	for (i = 0; i < count; i++) {
> +		atomic_inc(&xprt->sc_dma_used);
>  		ctxt->sge[i].addr = (unsigned long)
>  			ib_dma_map_single(xprt->sc_cm_id->device,
>  					  (void*)sge[i].addr, sge[i].length,
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 85931c4..cdb0732 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -174,6 +174,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
>  		sge_bytes = min((size_t)bc,
>  				(size_t)(xdr_sge[xdr_sge_no].length-sge_off));
>  		sge[sge_no].length = sge_bytes;
> +		atomic_inc(&xprt->sc_dma_used);
>  		sge[sge_no].addr =
>  			ib_dma_map_single(xprt->sc_cm_id->device,
>  					  (void *)
> @@ -399,6 +400,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
>  	ctxt->count = 1;
>  
>  	/* Prepare the SGE for the RPCRDMA Header */
> +	atomic_inc(&rdma->sc_dma_used);
>  	ctxt->sge[0].addr =
>  		ib_dma_map_page(rdma->sc_cm_id->device,
>  				page, 0, PAGE_SIZE, DMA_TO_DEVICE);
> @@ -411,6 +413,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
>  		sge_bytes = min((size_t)ctxt->sge[sge_no].length,
>  				(size_t)byte_count);
>  		byte_count -= sge_bytes;
> +		atomic_inc(&rdma->sc_dma_used);
>  		ctxt->sge[sge_no].addr =
>  			ib_dma_map_single(rdma->sc_cm_id->device,
>  					  (void *)
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 8a50586..68908b5 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -155,6 +155,7 @@ static void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
>  	struct svcxprt_rdma *xprt = ctxt->xprt;
>  	int i;
>  	for (i = 0; i < ctxt->count && ctxt->sge[i].length; i++) {
> +		atomic_dec(&xprt->sc_dma_used);
>  		ib_dma_unmap_single(xprt->sc_cm_id->device,
>  				    ctxt->sge[i].addr,
>  				    ctxt->sge[i].length,
> @@ -493,6 +494,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
>  	cma_xprt->sc_max_requests = svcrdma_max_requests;
>  	cma_xprt->sc_sq_depth = svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT;
>  	atomic_set(&cma_xprt->sc_sq_count, 0);
> +	atomic_set(&cma_xprt->sc_ctxt_used, 0);
>  
>  	if (!listener) {
>  		int reqs = cma_xprt->sc_max_requests;
> @@ -543,6 +545,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
>  		BUG_ON(sge_no >= xprt->sc_max_sge);
>  		page = svc_rdma_get_page();
>  		ctxt->pages[sge_no] = page;
> +		atomic_inc(&xprt->sc_dma_used);
>  		pa = ib_dma_map_page(xprt->sc_cm_id->device,
>  				     page, 0, PAGE_SIZE,
>  				     DMA_FROM_DEVICE);
> @@ -1023,6 +1026,7 @@ static void __svc_rdma_free(struct work_struct *work)
>  
>  	/* Warn if we leaked a resource or under-referenced */
>  	WARN_ON(atomic_read(&rdma->sc_ctxt_used) != 0);
> +	WARN_ON(atomic_read(&rdma->sc_dma_used) != 0);
>  
>  	/* Destroy the QP if present (not a listener) */
>  	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
> @@ -1143,6 +1147,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
>  	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
>  
>  	/* Prepare SGE for local address */
> +	atomic_inc(&xprt->sc_dma_used);
>  	sge.addr = ib_dma_map_page(xprt->sc_cm_id->device,
>  				   p, 0, PAGE_SIZE, DMA_FROM_DEVICE);
>  	sge.lkey = xprt->sc_phys_mr->lkey;

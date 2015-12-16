Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47824 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965730AbbLPPRv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 10:17:51 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH] svc_rdma: use local_dma_lkey
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1450278664-2133-2-git-send-email-hch@lst.de>
Date: Wed, 16 Dec 2015 10:17:43 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2BBD28FF-8027-471F-8DCC-F9AA7F6C06E1@oracle.com>
References: <1450278664-2133-1-git-send-email-hch@lst.de> <1450278664-2133-2-git-send-email-hch@lst.de>
To: Christoph Hellwig <hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 16, 2015, at 10:11 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
> We now alwasy have a per-PD local_dma_lkey available.  Make use of that
> fact in svc_rdma and stop registering our own MR.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

> ---
> include/linux/sunrpc/svc_rdma.h            |  2 --
> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  2 +-
> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  4 ++--
> net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  6 ++---
> net/sunrpc/xprtrdma/svc_rdma_transport.c   | 36 ++++--------------------------
> 5 files changed, 10 insertions(+), 40 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index b13513a..5322fea 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -156,13 +156,11 @@ struct svcxprt_rdma {
> 	struct ib_qp         *sc_qp;
> 	struct ib_cq         *sc_rq_cq;
> 	struct ib_cq         *sc_sq_cq;
> -	struct ib_mr         *sc_phys_mr;	/* MR for server memory */
> 	int		     (*sc_reader)(struct svcxprt_rdma *,
> 					  struct svc_rqst *,
> 					  struct svc_rdma_op_ctxt *,
> 					  int *, u32 *, u32, u32, u64, bool);
> 	u32		     sc_dev_caps;	/* distilled device caps */
> -	u32		     sc_dma_lkey;	/* local dma key */
> 	unsigned int	     sc_frmr_pg_list_len;
> 	struct list_head     sc_frmr_q;
> 	spinlock_t	     sc_frmr_q_lock;
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index 417cec1..c428734 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -128,7 +128,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
> 
> 	ctxt->wr_op = IB_WR_SEND;
> 	ctxt->direction = DMA_TO_DEVICE;
> -	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
> +	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
> 	ctxt->sge[0].length = sndbuf->len;
> 	ctxt->sge[0].addr =
> 	    ib_dma_map_page(rdma->sc_cm_id->device, ctxt->pages[0], 0,
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 3dfe464..c8b8a8b 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -144,6 +144,7 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
> 
> 		head->arg.pages[pg_no] = rqstp->rq_arg.pages[pg_no];
> 		head->arg.page_len += len;
> +
> 		head->arg.len += len;
> 		if (!pg_off)
> 			head->count++;
> @@ -160,8 +161,7 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
> 			goto err;
> 		atomic_inc(&xprt->sc_dma_used);
> 
> -		/* The lkey here is either a local dma lkey or a dma_mr lkey */
> -		ctxt->sge[pno].lkey = xprt->sc_dma_lkey;
> +		ctxt->sge[pno].lkey = xprt->sc_pd->local_dma_lkey;
> 		ctxt->sge[pno].length = len;
> 		ctxt->count++;
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index ced3151..20bd5d4 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -265,7 +265,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
> 					 sge[sge_no].addr))
> 			goto err;
> 		atomic_inc(&xprt->sc_dma_used);
> -		sge[sge_no].lkey = xprt->sc_dma_lkey;
> +		sge[sge_no].lkey = xprt->sc_pd->local_dma_lkey;
> 		ctxt->count++;
> 		sge_off = 0;
> 		sge_no++;
> @@ -487,7 +487,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
> 	ctxt->count = 1;
> 
> 	/* Prepare the SGE for the RPCRDMA Header */
> -	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
> +	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
> 	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
> 	ctxt->sge[0].addr =
> 	    ib_dma_map_page(rdma->sc_cm_id->device, page, 0,
> @@ -511,7 +511,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
> 					 ctxt->sge[sge_no].addr))
> 			goto err;
> 		atomic_inc(&rdma->sc_dma_used);
> -		ctxt->sge[sge_no].lkey = rdma->sc_dma_lkey;
> +		ctxt->sge[sge_no].lkey = rdma->sc_pd->local_dma_lkey;
> 		ctxt->sge[sge_no].length = sge_bytes;
> 	}
> 	if (byte_count != 0) {
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index abfbd02..faf4c49 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -232,11 +232,11 @@ void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
> 	for (i = 0; i < ctxt->count && ctxt->sge[i].length; i++) {
> 		/*
> 		 * Unmap the DMA addr in the SGE if the lkey matches
> -		 * the sc_dma_lkey, otherwise, ignore it since it is
> +		 * the local_dma_lkey, otherwise, ignore it since it is
> 		 * an FRMR lkey and will be unmapped later when the
> 		 * last WR that uses it completes.
> 		 */
> -		if (ctxt->sge[i].lkey == xprt->sc_dma_lkey) {
> +		if (ctxt->sge[i].lkey == xprt->sc_pd->local_dma_lkey) {
> 			atomic_dec(&xprt->sc_dma_used);
> 			ib_dma_unmap_page(xprt->sc_cm_id->device,
> 					    ctxt->sge[i].addr,
> @@ -698,7 +698,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
> 		atomic_inc(&xprt->sc_dma_used);
> 		ctxt->sge[sge_no].addr = pa;
> 		ctxt->sge[sge_no].length = PAGE_SIZE;
> -		ctxt->sge[sge_no].lkey = xprt->sc_dma_lkey;
> +		ctxt->sge[sge_no].lkey = xprt->sc_pd->local_dma_lkey;
> 		ctxt->count = sge_no + 1;
> 		buflen += PAGE_SIZE;
> 	}
> @@ -1014,8 +1014,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
> 	struct ib_cq_init_attr cq_attr = {};
> 	struct ib_qp_init_attr qp_attr;
> 	struct ib_device *dev;
> -	int uninitialized_var(dma_mr_acc);
> -	int need_dma_mr = 0;
> 	unsigned int i;
> 	int ret = 0;
> 
> @@ -1160,32 +1158,9 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
> 	    !rdma_ib_or_roce(dev, newxprt->sc_cm_id->port_num))
> 		goto errout;
> 
> -	if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG) ||
> -	    !(dev->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)) {
> -		need_dma_mr = 1;
> -		dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
> -		if (rdma_protocol_iwarp(dev, newxprt->sc_cm_id->port_num) &&
> -		    !(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG))
> -			dma_mr_acc |= IB_ACCESS_REMOTE_WRITE;
> -	}
> -
> 	if (rdma_protocol_iwarp(dev, newxprt->sc_cm_id->port_num))
> 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV;
> 
> -	/* Create the DMA MR if needed, otherwise, use the DMA LKEY */
> -	if (need_dma_mr) {
> -		/* Register all of physical memory */
> -		newxprt->sc_phys_mr =
> -			ib_get_dma_mr(newxprt->sc_pd, dma_mr_acc);
> -		if (IS_ERR(newxprt->sc_phys_mr)) {
> -			dprintk("svcrdma: Failed to create DMA MR ret=%d\n",
> -				ret);
> -			goto errout;
> -		}
> -		newxprt->sc_dma_lkey = newxprt->sc_phys_mr->lkey;
> -	} else
> -		newxprt->sc_dma_lkey = dev->local_dma_lkey;
> -
> 	/* Post receive buffers */
> 	for (i = 0; i < newxprt->sc_rq_depth; i++) {
> 		ret = svc_rdma_post_recv(newxprt, GFP_KERNEL);
> @@ -1349,9 +1324,6 @@ static void __svc_rdma_free(struct work_struct *work)
> 	if (rdma->sc_rq_cq && !IS_ERR(rdma->sc_rq_cq))
> 		ib_destroy_cq(rdma->sc_rq_cq);
> 
> -	if (rdma->sc_phys_mr && !IS_ERR(rdma->sc_phys_mr))
> -		ib_dereg_mr(rdma->sc_phys_mr);
> -
> 	if (rdma->sc_pd && !IS_ERR(rdma->sc_pd))
> 		ib_dealloc_pd(rdma->sc_pd);
> 
> @@ -1479,7 +1451,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
> 		return;
> 	}
> 	atomic_inc(&xprt->sc_dma_used);
> -	ctxt->sge[0].lkey = xprt->sc_dma_lkey;
> +	ctxt->sge[0].lkey = xprt->sc_pd->local_dma_lkey;
> 	ctxt->sge[0].length = length;
> 
> 	/* Prepare SEND WR */
> -- 
> 1.9.1
> 

--
Chuck Lever





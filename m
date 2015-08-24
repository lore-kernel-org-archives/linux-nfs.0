Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24873 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbHXQBQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 12:01:16 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] svcrdma: remove dead code
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1440431931-24738-1-git-send-email-sagig@mellanox.com>
Date: Mon, 24 Aug 2015 12:01:09 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Wise <swise@opengridcomputing.com>
Message-Id: <B705F885-C903-4780-82F8-30AD3EC88865@oracle.com>
References: <1440431931-24738-1-git-send-email-sagig@mellanox.com>
To: Sagi Grimberg <sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 24, 2015, at 11:58 AM, Sagi Grimberg <sagig@mellanox.com> wrote:

> No one is calling svc_rdma_fastreg. remove it.
> 
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>

There's already a patch to remove svc_rdma_fastreg() queued
for 4.3 through Bruce's tree.


> ---
> include/linux/sunrpc/svc_rdma.h          |    1 -
> net/sunrpc/xprtrdma/svc_rdma_transport.c |   34 ------------------------------
> 2 files changed, 0 insertions(+), 35 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index cb94ee4..fa5b5eb 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -225,7 +225,6 @@ extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
> extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
> extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
> extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
> -extern int svc_rdma_fastreg(struct svcxprt_rdma *, struct svc_rdma_fastreg_mr *);
> extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
> extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
> 			      struct svc_rdma_fastreg_mr *);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index a0aa2d7..0e010fe 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -1201,40 +1201,6 @@ static int svc_rdma_secure_port(struct svc_rqst *rqstp)
> 	return 1;
> }
> 
> -/*
> - * Attempt to register the kvec representing the RPC memory with the
> - * device.
> - *
> - * Returns:
> - *  NULL : The device does not support fastreg or there were no more
> - *         fastreg mr.
> - *  frmr : The kvec register request was successfully posted.
> - *    <0 : An error was encountered attempting to register the kvec.
> - */
> -int svc_rdma_fastreg(struct svcxprt_rdma *xprt,
> -		     struct svc_rdma_fastreg_mr *frmr)
> -{
> -	struct ib_fast_reg_wr fastreg_wr;
> -	u8 key;
> -
> -	/* Bump the key */
> -	key = (u8)(frmr->mr->lkey & 0x000000FF);
> -	ib_update_fast_reg_key(frmr->mr, ++key);
> -
> -	/* Prepare FASTREG WR */
> -	memset(&fastreg_wr, 0, sizeof fastreg_wr);
> -	fastreg_wr.wr.opcode = IB_WR_FAST_REG_MR;
> -	fastreg_wr.wr.send_flags = IB_SEND_SIGNALED;
> -	fastreg_wr.iova_start = (unsigned long)frmr->kva;
> -	fastreg_wr.page_list = frmr->page_list;
> -	fastreg_wr.page_list_len = frmr->page_list_len;
> -	fastreg_wr.page_shift = PAGE_SHIFT;
> -	fastreg_wr.length = frmr->map_len;
> -	fastreg_wr.access_flags = frmr->access_flags;
> -	fastreg_wr.rkey = frmr->mr->lkey;
> -	return svc_rdma_send(xprt, &fastreg_wr.wr);
> -}
> -
> int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
> {
> 	struct ib_send_wr *bad_wr, *n_wr;
> -- 
> 1.7.1
> 

--
Chuck Lever




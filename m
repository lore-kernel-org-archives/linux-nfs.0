Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:34102 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564AbcBEKf4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 05:35:56 -0500
Received: by mail-yw0-f173.google.com with SMTP id h129so47765695ywb.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 02:35:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160203155203.13868.93909.stgit@klimt.1015granger.net>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net> <20160203155203.13868.93909.stgit@klimt.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Fri, 5 Feb 2016 16:05:16 +0530
Message-ID: <CANjDDBgUx26_4iaAQ63dv6RDH07KnSnKMrVvUn=608yLg1h1bw@mail.gmail.com>
Subject: Re: [PATCH v1 05/10] svcrdma: Make RDMA_ERROR messages work
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good

On Wed, Feb 3, 2016 at 9:22 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Fix several issues with svc_rdma_send_error():
>
>  - Post a receive buffer to replace the one that was consumed by
>    the incoming request
>  - Posting a send should use DMA_TO_DEVICE, not DMA_FROM_DEVICE
>  - No need to put_page _and_ free pages in svc_rdma_put_context
>  - Make sure the sge is set up completely in case the error
>    path goes through svc_rdma_unmap_dma()
>
> Related fixes in svc_rdma_recvfrom():
>
>  - Don't leak the ctxt associated with the incoming request
>  - Don't close the connection after sending an error reply
>  - Let svc_rdma_send_error() figure out the right header error code
>
> As a last clean up, move svc_rdma_send_error() to svc_rdma_sendto.c
> with other similar functions. There is some common logic in these
> functions that could someday be combined to reduce code duplication.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/svc_rdma.h          |    4 +-
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   19 ++++-----
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   62 ++++++++++++++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   54 --------------------------
>  4 files changed, 73 insertions(+), 66 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index d8fc58d..0589918 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -228,11 +228,11 @@ extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
>  extern int svc_rdma_sendto(struct svc_rqst *);
>  extern struct rpcrdma_read_chunk *
>         svc_rdma_get_read_chunk(struct rpcrdma_msg *);
> +extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
> +                               int);
>
>  /* svc_rdma_transport.c */
>  extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
> -extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
> -                               enum rpcrdma_errcode);
>  extern int svc_rdma_post_recv(struct svcxprt_rdma *, gfp_t);
>  extern int svc_rdma_repost_recv(struct svcxprt_rdma *, gfp_t);
>  extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index acf15b8..0f09052 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -612,7 +612,6 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>         struct svc_rdma_op_ctxt *ctxt = NULL;
>         struct rpcrdma_msg *rmsgp;
>         int ret = 0;
> -       int len;
>
>         dprintk("svcrdma: rqstp=%p\n", rqstp);
>
> @@ -654,15 +653,10 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>         rdma_build_arg_xdr(rqstp, ctxt, ctxt->byte_len);
>
>         /* Decode the RDMA header. */
> -       len = svc_rdma_xdr_decode_req(&rmsgp, rqstp);
> -       rqstp->rq_xprt_hlen = len;
> -
> -       /* If the request is invalid, reply with an error */
> -       if (len < 0) {
> -               if (len == -ENOSYS)
> -                       svc_rdma_send_error(rdma_xprt, rmsgp, ERR_VERS);
> -               goto close_out;
> -       }
> +       ret = svc_rdma_xdr_decode_req(&rmsgp, rqstp);
> +       if (ret < 0)
> +               goto out_err;
> +       rqstp->rq_xprt_hlen = ret;
>
>         if (svc_rdma_is_backchannel_reply(xprt, rmsgp)) {
>                 ret = svc_rdma_handle_bc_reply(xprt->xpt_bc_xprt, rmsgp,
> @@ -698,6 +692,11 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>         svc_xprt_copy_addrs(rqstp, xprt);
>         return ret;
>
> +out_err:
> +       svc_rdma_send_error(rdma_xprt, rmsgp, ret);
> +       svc_rdma_put_context(ctxt, 0);
> +       return 0;
> +
>   close_out:
>         if (ctxt)
>                 svc_rdma_put_context(ctxt, 1);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 687a91afe..73793dd 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -639,3 +639,65 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>         svc_rdma_put_context(ctxt, 0);
>         return ret;
>  }
> +
> +void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
> +                        int status)
> +{
> +       struct ib_send_wr err_wr;
> +       struct page *p;
> +       struct svc_rdma_op_ctxt *ctxt;
> +       enum rpcrdma_errcode err;
> +       __be32 *va;
> +       int length;
> +       int ret;
> +
> +       ret = svc_rdma_repost_recv(xprt, GFP_KERNEL);
> +       if (ret)
> +               return;
> +
> +       p = alloc_page(GFP_KERNEL);
> +       if (!p)
> +               return;
> +       va = page_address(p);
> +
> +       /* XDR encode an error reply */
> +       err = ERR_CHUNK;
> +       if (status == -ENOSYS)
> +               err = ERR_VERS;
> +       length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
> +
> +       ctxt = svc_rdma_get_context(xprt);
> +       ctxt->direction = DMA_TO_DEVICE;
> +       ctxt->count = 1;
> +       ctxt->pages[0] = p;
> +
> +       /* Prepare SGE for local address */
> +       ctxt->sge[0].lkey = xprt->sc_pd->local_dma_lkey;
> +       ctxt->sge[0].length = length;
> +       ctxt->sge[0].addr = ib_dma_map_page(xprt->sc_cm_id->device,
> +                                           p, 0, length, DMA_TO_DEVICE);
> +       if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
> +               dprintk("svcrdma: Error mapping buffer for protocol error\n");
> +               svc_rdma_put_context(ctxt, 1);
> +               return;
> +       }
> +       atomic_inc(&xprt->sc_dma_used);
> +
> +       /* Prepare SEND WR */
> +       memset(&err_wr, 0, sizeof err_wr);
> +       ctxt->wr_op = IB_WR_SEND;
> +       err_wr.wr_id = (unsigned long)ctxt;
> +       err_wr.sg_list = ctxt->sge;
> +       err_wr.num_sge = 1;
> +       err_wr.opcode = IB_WR_SEND;
> +       err_wr.send_flags = IB_SEND_SIGNALED;
> +
> +       /* Post It */
> +       ret = svc_rdma_send(xprt, &err_wr);
> +       if (ret) {
> +               dprintk("svcrdma: Error %d posting send for protocol error\n",
> +                       ret);
> +               svc_rdma_unmap_dma(ctxt);
> +               svc_rdma_put_context(ctxt, 1);
> +       }
> +}
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index da82e36..e7bda1e 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -1465,57 +1465,3 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
>         }
>         return ret;
>  }
> -
> -void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
> -                        enum rpcrdma_errcode err)
> -{
> -       struct ib_send_wr err_wr;
> -       struct page *p;
> -       struct svc_rdma_op_ctxt *ctxt;
> -       __be32 *va;
> -       int length;
> -       int ret;
> -
> -       p = alloc_page(GFP_KERNEL);
> -       if (!p)
> -               return;
> -       va = page_address(p);
> -
> -       /* XDR encode error */
> -       length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
> -
> -       ctxt = svc_rdma_get_context(xprt);
> -       ctxt->direction = DMA_FROM_DEVICE;
> -       ctxt->count = 1;
> -       ctxt->pages[0] = p;
> -
> -       /* Prepare SGE for local address */
> -       ctxt->sge[0].addr = ib_dma_map_page(xprt->sc_cm_id->device,
> -                                           p, 0, length, DMA_FROM_DEVICE);
> -       if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
> -               put_page(p);
> -               svc_rdma_put_context(ctxt, 1);
> -               return;
> -       }
> -       atomic_inc(&xprt->sc_dma_used);
> -       ctxt->sge[0].lkey = xprt->sc_pd->local_dma_lkey;
> -       ctxt->sge[0].length = length;
> -
> -       /* Prepare SEND WR */
> -       memset(&err_wr, 0, sizeof err_wr);
> -       ctxt->wr_op = IB_WR_SEND;
> -       err_wr.wr_id = (unsigned long)ctxt;
> -       err_wr.sg_list = ctxt->sge;
> -       err_wr.num_sge = 1;
> -       err_wr.opcode = IB_WR_SEND;
> -       err_wr.send_flags = IB_SEND_SIGNALED;
> -
> -       /* Post It */
> -       ret = svc_rdma_send(xprt, &err_wr);
> -       if (ret) {
> -               dprintk("svcrdma: Error %d posting send for protocol error\n",
> -                       ret);
> -               svc_rdma_unmap_dma(ctxt);
> -               svc_rdma_put_context(ctxt, 1);
> -       }
> -}
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

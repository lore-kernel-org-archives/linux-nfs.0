Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35070 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756429AbbIUJAE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 05:00:04 -0400
Received: by ykdz138 with SMTP id z138so15718328ykd.2
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2015 02:00:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150917204427.19671.53527.stgit@manet.1015granger.net>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net> <20150917204427.19671.53527.stgit@manet.1015granger.net>
From: Devesh Sharma <devesh.sharma@avagotech.com>
Date: Mon, 21 Sep 2015 14:29:24 +0530
Message-ID: <CANjDDBj245W37Ua8Ruem6G+92BdLa_xMMPGvYi6TXkSTkpK1Vg@mail.gmail.com>
Subject: Re: [PATCH v1 02/18] xprtrdma: Replace global lkey with lkey local to PD
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good, will test this ocrdma and update you.

On Fri, Sep 18, 2015 at 2:14 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> The core API has changed so that devices that do not have a global
> DMA lkey automatically create an mr, per-PD, and make that lkey
> available. The global DMA lkey interface is going away in favor of
> the per-PD DMA lkey.
>
> The per-PD DMA lkey is always available. Convert xprtrdma to use the
> device's per-PD DMA lkey for regbufs, no matter which memory
> registration scheme is in use.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/fmr_ops.c      |   19 -------------------
>  net/sunrpc/xprtrdma/frwr_ops.c     |    5 -----
>  net/sunrpc/xprtrdma/physical_ops.c |   10 +---------
>  net/sunrpc/xprtrdma/verbs.c        |    2 +-
>  net/sunrpc/xprtrdma/xprt_rdma.h    |    1 -
>  5 files changed, 2 insertions(+), 35 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index cb25c89..f1e8daf 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -39,25 +39,6 @@ static int
>  fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
>             struct rpcrdma_create_data_internal *cdata)
>  {
> -       struct ib_device_attr *devattr = &ia->ri_devattr;
> -       struct ib_mr *mr;
> -
> -       /* Obtain an lkey to use for the regbufs, which are
> -        * protected from remote access.
> -        */
> -       if (devattr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
> -               ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
> -       } else {
> -               mr = ib_get_dma_mr(ia->ri_pd, IB_ACCESS_LOCAL_WRITE);
> -               if (IS_ERR(mr)) {
> -                       pr_err("%s: ib_get_dma_mr for failed with %lX\n",
> -                              __func__, PTR_ERR(mr));
> -                       return -ENOMEM;
> -               }
> -               ia->ri_dma_lkey = ia->ri_dma_mr->lkey;
> -               ia->ri_dma_mr = mr;
> -       }
> -
>         return 0;
>  }
>
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index 21b3efb..004f1ad 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -189,11 +189,6 @@ frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
>         struct ib_device_attr *devattr = &ia->ri_devattr;
>         int depth, delta;
>
> -       /* Obtain an lkey to use for the regbufs, which are
> -        * protected from remote access.
> -        */
> -       ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
> -
>         ia->ri_max_frmr_depth =
>                         min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
>                               devattr->max_fast_reg_page_list_len);
> diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
> index 72cf8b1..617b76f 100644
> --- a/net/sunrpc/xprtrdma/physical_ops.c
> +++ b/net/sunrpc/xprtrdma/physical_ops.c
> @@ -23,7 +23,6 @@ static int
>  physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
>                  struct rpcrdma_create_data_internal *cdata)
>  {
> -       struct ib_device_attr *devattr = &ia->ri_devattr;
>         struct ib_mr *mr;
>
>         /* Obtain an rkey to use for RPC data payloads.
> @@ -37,15 +36,8 @@ physical_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
>                        __func__, PTR_ERR(mr));
>                 return -ENOMEM;
>         }
> -       ia->ri_dma_mr = mr;
> -
> -       /* Obtain an lkey to use for regbufs.
> -        */
> -       if (devattr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)
> -               ia->ri_dma_lkey = ia->ri_device->local_dma_lkey;
> -       else
> -               ia->ri_dma_lkey = ia->ri_dma_mr->lkey;
>
> +       ia->ri_dma_mr = mr;
>         return 0;
>  }
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 01a314a..8a477e2 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1255,7 +1255,7 @@ rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size, gfp_t flags)
>                 goto out_free;
>
>         iov->length = size;
> -       iov->lkey = ia->ri_dma_lkey;
> +       iov->lkey = ia->ri_pd->local_dma_lkey;
>         rb->rg_size = size;
>         rb->rg_owner = NULL;
>         return rb;
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 0251222..c09414e 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -65,7 +65,6 @@ struct rpcrdma_ia {
>         struct rdma_cm_id       *ri_id;
>         struct ib_pd            *ri_pd;
>         struct ib_mr            *ri_dma_mr;
> -       u32                     ri_dma_lkey;
>         struct completion       ri_done;
>         int                     ri_async_rc;
>         unsigned int            ri_max_frmr_depth;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

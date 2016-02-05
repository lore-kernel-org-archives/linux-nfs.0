Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:32857 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409AbcBEKW0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 05:22:26 -0500
Received: by mail-yw0-f182.google.com with SMTP id z185so47488527ywf.0
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 02:22:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160203155138.13868.38423.stgit@klimt.1015granger.net>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net> <20160203155138.13868.38423.stgit@klimt.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Fri, 5 Feb 2016 15:45:23 +0530
Message-ID: <CANjDDBgcNhpcyMpUF7SbD5eHZeXhx5ge+qSyfhhtHQbW-Gaqew@mail.gmail.com>
Subject: Re: [PATCH v1 02/10] svcrdma: Make svc_rdma_get_frmr() not sleep
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As I understand, you are pre-allocating because alloc_mr() can sleep
so separate it out while map-frmr-wqe would be non-blocking context by
definition, we are on the same page?


On Wed, Feb 3, 2016 at 9:21 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Want to call it in a context that cannot sleep. So pre-alloc
> the memory and the MRs.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   44 ++++++++++++++++++++++++++----
>  1 file changed, 38 insertions(+), 6 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 5763825..02eee12 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -949,7 +949,7 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
>         return ERR_PTR(-ENOMEM);
>  }
>
> -static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
> +static void svc_rdma_destroy_frmrs(struct svcxprt_rdma *xprt)
>  {
>         struct svc_rdma_fastreg_mr *frmr;
>
> @@ -963,6 +963,37 @@ static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
>         }
>  }
>
> +static bool svc_rdma_prealloc_frmrs(struct svcxprt_rdma *xprt)
> +{
> +       struct ib_device *dev = xprt->sc_cm_id->device;
> +       unsigned int i;
> +
> +       /* Pre-allocate based on the maximum amount of payload
> +        * the server's HCA can handle per RDMA Read, to keep
> +        * the number of MRs per connection in check.
> +        *
> +        * If a client sends small Read chunks (eg. it may be
> +        * using physical registration), more RDMA Reads per
> +        * NFS WRITE will be needed.  svc_rdma_get_frmr() dips
> +        * into its reserve in that case. Better would be for
> +        * the server to reduce the connection's credit limit.
> +        */
> +       i = 1 + RPCSVC_MAXPAGES / dev->attrs.max_fast_reg_page_list_len;
> +       i *= xprt->sc_max_requests;
> +
> +       while (i--) {
> +               struct svc_rdma_fastreg_mr *frmr;
> +
> +               frmr = rdma_alloc_frmr(xprt);
> +               if (!frmr) {
> +                       dprintk("svcrdma: No memory for request map\n");
> +                       return false;
> +               }
> +               list_add(&frmr->frmr_list, &xprt->sc_frmr_q);
> +       }
> +       return true;
> +}
> +
>  struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
>  {
>         struct svc_rdma_fastreg_mr *frmr = NULL;
> @@ -975,10 +1006,9 @@ struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
>                 frmr->sg_nents = 0;
>         }
>         spin_unlock_bh(&rdma->sc_frmr_q_lock);
> -       if (frmr)
> -               return frmr;
> -
> -       return rdma_alloc_frmr(rdma);
> +       if (!frmr)
> +               return ERR_PTR(-ENOMEM);
> +       return frmr;
>  }
>
>  void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
> @@ -1149,6 +1179,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>                         dev->attrs.max_fast_reg_page_list_len;
>                 newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
>                 newxprt->sc_reader = rdma_read_chunk_frmr;
> +               if (!svc_rdma_prealloc_frmrs(newxprt))
> +                       goto errout;
>         }
>
>         /*
> @@ -1310,7 +1342,7 @@ static void __svc_rdma_free(struct work_struct *work)
>                 xprt->xpt_bc_xprt = NULL;
>         }
>
> -       rdma_dealloc_frmr_q(rdma);
> +       svc_rdma_destroy_frmrs(rdma);
>         svc_rdma_destroy_ctxts(rdma);
>         svc_rdma_destroy_maps(rdma);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

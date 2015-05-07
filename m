Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:32916 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbbEGKhs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 06:37:48 -0400
Received: by lbbzk7 with SMTP id zk7so27776937lbb.0
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 03:37:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150504175749.3483.56570.stgit@manet.1015granger.net>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
	<20150504175749.3483.56570.stgit@manet.1015granger.net>
Date: Thu, 7 May 2015 16:07:46 +0530
Message-ID: <CANjDDBj55zA96TRND9pkQqoJ50RNi=ZcsnpuFo=Q3Wq0BuZdKA@mail.gmail.com>
Subject: Re: [PATCH v1 07/14] xprtrdma: Introduce an FRMR recovery workqueue
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good

Reviewed-By: Devesh Sharma <devesh.sharma@avagotech.com>

On Mon, May 4, 2015 at 11:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> After a transport disconnect, FRMRs can be left in an undetermined
> state. In particular, the MR's rkey is no good.
>
> Currently, FRMRs are fixed up by the transport connect worker, but
> that can race with ->ro_unmap if an RPC happens to exit while the
> transport connect worker is running.
>
> A better way of dealing with broken FRMRs is to detect them before
> they are re-used by ->ro_map. Such FRMRs are either already invalid
> or are owned by the sending RPC, and thus no race with ->ro_unmap
> is possible.
>
> Introduce a mechanism for handing broken FRMRs to a workqueue to be
> reset in a context that is appropriate for allocating resources
> (ie. an ib_alloc_fast_reg_mr() API call).
>
> This mechanism is not yet used, but will be in subsequent patches.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/frwr_ops.c  |   71
> ++++++++++++++++++++++++++++++++++++++-
>  net/sunrpc/xprtrdma/transport.c |   11 +++++-
>  net/sunrpc/xprtrdma/xprt_rdma.h |    5 +++
>  3 files changed, 84 insertions(+), 3 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index 66a85fa..a06d9a3 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -17,6 +17,74 @@
>  # define RPCDBG_FACILITY       RPCDBG_TRANS
>  #endif
>
> +static struct workqueue_struct *frwr_recovery_wq;
> +
> +#define FRWR_RECOVERY_WQ_FLAGS         (WQ_UNBOUND | WQ_MEM_RECLAIM)
> +
> +int
> +frwr_alloc_recovery_wq(void)
> +{
> +       frwr_recovery_wq = alloc_workqueue("frwr_recovery",
> +                                          FRWR_RECOVERY_WQ_FLAGS, 0);
> +       return !frwr_recovery_wq ? -ENOMEM : 0;
> +}
> +
> +void
> +frwr_destroy_recovery_wq(void)
> +{
> +       struct workqueue_struct *wq;
> +
> +       if (!frwr_recovery_wq)
> +               return;
> +
> +       wq = frwr_recovery_wq;
> +       frwr_recovery_wq = NULL;
> +       destroy_workqueue(wq);
> +}
> +
> +/* Deferred reset of a single FRMR. Generate a fresh rkey by
> + * replacing the MR.
> + *
> + * There's no recovery if this fails. The FRMR is abandoned, but
> + * remains in rb_all. It will be cleaned up when the transport is
> + * destroyed.
> + */
> +static void
> +__frwr_recovery_worker(struct work_struct *work)
> +{
> +       struct rpcrdma_mw *r = container_of(work, struct rpcrdma_mw,
> +                                           r.frmr.fr_work);
> +       struct rpcrdma_xprt *r_xprt = r->r.frmr.fr_xprt;
> +       unsigned int depth = r_xprt->rx_ia.ri_max_frmr_depth;
> +       struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
> +
> +       if (ib_dereg_mr(r->r.frmr.fr_mr))
> +               goto out_fail;
> +
> +       r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(pd, depth);
> +       if (IS_ERR(r->r.frmr.fr_mr))
> +               goto out_fail;
> +
> +       dprintk("RPC:       %s: recovered FRMR %p\n", __func__, r);
> +       r->r.frmr.fr_state = FRMR_IS_INVALID;
> +       rpcrdma_put_mw(r_xprt, r);
> +       return;
> +
> +out_fail:
> +       pr_warn("RPC:       %s: FRMR %p unrecovered\n",
> +               __func__, r);
> +}
> +
> +/* A broken MR was discovered in a context that can't sleep.
> + * Defer recovery to the recovery worker.
> + */
> +static void
> +__frwr_queue_recovery(struct rpcrdma_mw *r)
> +{
> +       INIT_WORK(&r->r.frmr.fr_work, __frwr_recovery_worker);
> +       queue_work(frwr_recovery_wq, &r->r.frmr.fr_work);
> +}
> +
>  static int
>  __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device
> *device,
>             unsigned int depth)
> @@ -128,7 +196,7 @@ frwr_sendcompletion(struct ib_wc *wc)
>
>         /* WARNING: Only wr_id and status are reliable at this point */
>         r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
> -       dprintk("RPC:       %s: frmr %p (stale), status %d\n",
> +       pr_warn("RPC:       %s: frmr %p flushed, status %d\n",
>                 __func__, r, wc->status);
>         r->r.frmr.fr_state = FRMR_IS_STALE;
>  }
> @@ -165,6 +233,7 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
>                 list_add(&r->mw_list, &buf->rb_mws);
>                 list_add(&r->mw_all, &buf->rb_all);
>                 r->mw_sendcompletion = frwr_sendcompletion;
> +               r->r.frmr.fr_xprt = r_xprt;
>         }
>
>         return 0;
> diff --git a/net/sunrpc/xprtrdma/transport.c
> b/net/sunrpc/xprtrdma/transport.c
> index ed70551..f1fa6a7 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -757,17 +757,24 @@ static void __exit xprt_rdma_cleanup(void)
>         if (rc)
>                 dprintk("RPC:       %s: xprt_unregister returned %i\n",
>                         __func__, rc);
> +
> +       frwr_destroy_recovery_wq();
>  }
>
>  static int __init xprt_rdma_init(void)
>  {
>         int rc;
>
> -       rc = xprt_register_transport(&xprt_rdma);
> -
> +       rc = frwr_alloc_recovery_wq();
>         if (rc)
>                 return rc;
>
> +       rc = xprt_register_transport(&xprt_rdma);
> +       if (rc) {
> +               frwr_destroy_recovery_wq();
> +               return rc;
> +       }
> +
>         dprintk("RPCRDMA Module Init, register RPC RDMA transport\n");
>
>         dprintk("Defaults:\n");
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h
> b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 7de424e..98227d6 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -204,6 +204,8 @@ struct rpcrdma_frmr {
>         struct ib_fast_reg_page_list    *fr_pgl;
>         struct ib_mr                    *fr_mr;
>         enum rpcrdma_frmr_state         fr_state;
> +       struct work_struct              fr_work;
> +       struct rpcrdma_xprt             *fr_xprt;
>  };
>
>  struct rpcrdma_mw {
> @@ -429,6 +431,9 @@ void rpcrdma_free_regbuf(struct rpcrdma_ia *,
>
>  unsigned int rpcrdma_max_segments(struct rpcrdma_xprt *);
>
> +int frwr_alloc_recovery_wq(void);
> +void frwr_destroy_recovery_wq(void);
> +
>  /*
>   * Wrappers for chunk registration, shared by read/write chunk code.
>   */
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
-Regards
Devesh

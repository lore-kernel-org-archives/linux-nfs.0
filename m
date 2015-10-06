Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:34429 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbbJFSSO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 14:18:14 -0400
Received: by ykdg206 with SMTP id g206so210157641ykd.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2015 11:18:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151006145851.11788.95912.stgit@manet.1015granger.net>
References: <20151006142430.11788.42604.stgit@manet.1015granger.net> <20151006145851.11788.95912.stgit@manet.1015granger.net>
From: Devesh Sharma <devesh.sharma@avagotech.com>
Date: Tue, 6 Oct 2015 23:47:34 +0530
Message-ID: <CANjDDBjtkwQgCCMMRDvkhKt0G6zKGSGpaRWfvSC1Sf3Zi0=muw@mail.gmail.com>
Subject: Re: [PATCH v2 02/16] xprtrdma: Re-arm after missed events
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-By: Devesh Sharma <devesh.sharma@avagotech.com>

Will send a test-report of this series with ocrdma drivers.



On Tue, Oct 6, 2015 at 8:28 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> ib_req_notify_cq(IB_CQ_REPORT_MISSED_EVENTS) returns a positive
> value if WCs were added to a CQ after the last completion upcall
> but before the CQ has been re-armed.
>
> Commit 7f23f6f6e388 ("xprtrmda: Reduce lock contention in
> completion handlers") assumed that when ib_req_notify_cq() returned
> a positive RC, the CQ had also been successfully re-armed, making
> it safe to return control to the provider without losing any
> completion signals. That is an invalid assumption.
>
> Change both completion handlers to continue polling while
> ib_req_notify_cq() returns a positive value.
>
> Fixes: 7f23f6f6e388 ("xprtrmda: Reduce lock contention in ...")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |   66 +++++++------------------------------------
>  1 file changed, 10 insertions(+), 56 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 8a477e2..c713909 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -179,38 +179,17 @@ rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
>         return 0;
>  }
>
> -/*
> - * Handle send, fast_reg_mr, and local_inv completions.
> - *
> - * Send events are typically suppressed and thus do not result
> - * in an upcall. Occasionally one is signaled, however. This
> - * prevents the provider's completion queue from wrapping and
> - * losing a completion.
> +/* Handle provider send completion upcalls.
>   */
>  static void
>  rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
>  {
>         struct rpcrdma_ep *ep = (struct rpcrdma_ep *)cq_context;
> -       int rc;
> -
> -       rc = rpcrdma_sendcq_poll(cq, ep);
> -       if (rc) {
> -               dprintk("RPC:       %s: ib_poll_cq failed: %i\n",
> -                       __func__, rc);
> -               return;
> -       }
>
> -       rc = ib_req_notify_cq(cq,
> -                       IB_CQ_NEXT_COMP | IB_CQ_REPORT_MISSED_EVENTS);
> -       if (rc == 0)
> -               return;
> -       if (rc < 0) {
> -               dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
> -                       __func__, rc);
> -               return;
> -       }
> -
> -       rpcrdma_sendcq_poll(cq, ep);
> +       do {
> +               rpcrdma_sendcq_poll(cq, ep);
> +       } while (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
> +                                 IB_CQ_REPORT_MISSED_EVENTS) > 0);
>  }
>
>  static void
> @@ -274,42 +253,17 @@ out_schedule:
>         return rc;
>  }
>
> -/*
> - * Handle receive completions.
> - *
> - * It is reentrant but processes single events in order to maintain
> - * ordering of receives to keep server credits.
> - *
> - * It is the responsibility of the scheduled tasklet to return
> - * recv buffers to the pool. NOTE: this affects synchronization of
> - * connection shutdown. That is, the structures required for
> - * the completion of the reply handler must remain intact until
> - * all memory has been reclaimed.
> +/* Handle provider receive completion upcalls.
>   */
>  static void
>  rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
>  {
>         struct rpcrdma_ep *ep = (struct rpcrdma_ep *)cq_context;
> -       int rc;
> -
> -       rc = rpcrdma_recvcq_poll(cq, ep);
> -       if (rc) {
> -               dprintk("RPC:       %s: ib_poll_cq failed: %i\n",
> -                       __func__, rc);
> -               return;
> -       }
>
> -       rc = ib_req_notify_cq(cq,
> -                       IB_CQ_NEXT_COMP | IB_CQ_REPORT_MISSED_EVENTS);
> -       if (rc == 0)
> -               return;
> -       if (rc < 0) {
> -               dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
> -                       __func__, rc);
> -               return;
> -       }
> -
> -       rpcrdma_recvcq_poll(cq, ep);
> +       do {
> +               rpcrdma_recvcq_poll(cq, ep);
> +       } while (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
> +                                 IB_CQ_REPORT_MISSED_EVENTS) > 0);
>  }
>
>  static void
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:35103 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbIRGwo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Sep 2015 02:52:44 -0400
Received: by ykdu9 with SMTP id u9so38797177ykd.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 23:52:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150917204435.19671.56195.stgit@manet.1015granger.net>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net> <20150917204435.19671.56195.stgit@manet.1015granger.net>
From: Devesh Sharma <devesh.sharma@avagotech.com>
Date: Fri, 18 Sep 2015 12:22:04 +0530
Message-ID: <CANjDDBgokeHEZ7jWhRKRRU4Usr655zRoYY-qUHc9jeuyjYBzpA@mail.gmail.com>
Subject: Re: [PATCH v1 03/18] xprtrdma: Remove completion polling budgets
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 18, 2015 at 2:14 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> Commit 8301a2c047cc ("xprtrdma: Limit work done by completion
> handler") was supposed to prevent xprtrdma's upcall handlers from
> starving other softIRQ work by letting them return to the provider
> before all CQEs have been polled.
>
> The logic assumes the provider will call the upcall handler again
> immediately if the CQ is re-armed while there are still queued CQEs.
>
> This assumption is invalid. The IBTA spec says that after a CQ is
> armed, the hardware must interrupt only when a new CQE is inserted.
> xprtrdma can't rely on the provider calling again, even though some
> providers do.
>
> Therefore, leaving CQEs on queue makes sense only when there is
> another mechanism that ensures all remaining CQEs are consumed in a
> timely fashion. xprtrdma does not have such a mechanism. If a CQE
> remains queued, the transport can wait forever to send the next RPC.
>
> Finally, move the wcs array back onto the stack to ensure that the
> poll array is always local to the CPU where the completion upcall is
> running.
>
> Fixes: 8301a2c047cc ("xprtrdma: Limit work done by completion ...")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c     |  100 ++++++++++++++++++---------------------
>  net/sunrpc/xprtrdma/xprt_rdma.h |    5 --
>  2 files changed, 45 insertions(+), 60 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 8a477e2..f2e3863 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -158,34 +158,37 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
>         }
>  }
>
> -static int
> +/* The wc array is on stack: automatic memory is always CPU-local.
> + *
> + * The common case is a single completion is ready. By asking
> + * for two entries, a return code of 1 means there is exactly
> + * one completion and no more. We don't have to poll again to
> + * know that the CQ is now empty.
> + */
> +static void
>  rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
>  {
> -       struct ib_wc *wcs;
> -       int budget, count, rc;
> +       struct ib_wc *pos, wcs[2];
> +       int count, rc;
>
> -       budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
>         do {
> -               wcs = ep->rep_send_wcs;
> +               pos = wcs;
>
> -               rc = ib_poll_cq(cq, RPCRDMA_POLLSIZE, wcs);
> -               if (rc <= 0)
> -                       return rc;
> +               rc = ib_poll_cq(cq, ARRAY_SIZE(wcs), pos);
> +               if (rc < 0)
> +                       goto out_warn;
>
>                 count = rc;
>                 while (count-- > 0)
> -                       rpcrdma_sendcq_process_wc(wcs++);
> -       } while (rc == RPCRDMA_POLLSIZE && --budget);
> -       return 0;
> +                       rpcrdma_sendcq_process_wc(pos++);
> +       } while (rc == ARRAY_SIZE(wcs));

I think I have missed something and not able to understand the reason
for polling 2 CQEs in one poll? It is possible that in a given poll_cq
call you end up getting on 1 completion, the other completion is
delayed due to some reason. Would it be better to poll for 1 in every
poll call Or
otherwise have this
while ( rc <= ARRAY_SIZE(wcs) && rc);

> +       return;
> +
> +out_warn:
> +       pr_warn("RPC:       %s: ib_poll_cq() failed %i\n", __func__, rc);
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
> @@ -193,12 +196,7 @@ rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
>         struct rpcrdma_ep *ep = (struct rpcrdma_ep *)cq_context;
>         int rc;
>
> -       rc = rpcrdma_sendcq_poll(cq, ep);
> -       if (rc) {
> -               dprintk("RPC:       %s: ib_poll_cq failed: %i\n",
> -                       __func__, rc);
> -               return;
> -       }
> +       rpcrdma_sendcq_poll(cq, ep);
>
>         rc = ib_req_notify_cq(cq,
>                         IB_CQ_NEXT_COMP | IB_CQ_REPORT_MISSED_EVENTS);
> @@ -247,44 +245,41 @@ out_fail:
>         goto out_schedule;
>  }
>
> -static int
> +/* The wc array is on stack: automatic memory is always CPU-local.
> + *
> + * struct ib_wc is 64 bytes, making the poll array potentially
> + * large. But this is at the bottom of the call chain. Further
> + * substantial work is done in another thread.
> + */
> +static void
>  rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
>  {
> -       struct list_head sched_list;
> -       struct ib_wc *wcs;
> -       int budget, count, rc;
> +       struct ib_wc *pos, wcs[4];
> +       LIST_HEAD(sched_list);
> +       int count, rc;
>
> -       INIT_LIST_HEAD(&sched_list);
> -       budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
>         do {
> -               wcs = ep->rep_recv_wcs;
> +               pos = wcs;
>
> -               rc = ib_poll_cq(cq, RPCRDMA_POLLSIZE, wcs);
> -               if (rc <= 0)
> -                       goto out_schedule;
> +               rc = ib_poll_cq(cq, ARRAY_SIZE(wcs), pos);
> +               if (rc < 0)
> +                       goto out_warn;
>
>                 count = rc;
>                 while (count-- > 0)
> -                       rpcrdma_recvcq_process_wc(wcs++, &sched_list);
> -       } while (rc == RPCRDMA_POLLSIZE && --budget);
> -       rc = 0;
> +                       rpcrdma_recvcq_process_wc(pos++, &sched_list);
> +       } while (rc == ARRAY_SIZE(wcs));
>
>  out_schedule:
>         rpcrdma_schedule_tasklet(&sched_list);
> -       return rc;
> +       return;
> +
> +out_warn:
> +       pr_warn("RPC:       %s: ib_poll_cq() failed %i\n", __func__, rc);
> +       goto out_schedule;
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
> @@ -292,12 +287,7 @@ rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
>         struct rpcrdma_ep *ep = (struct rpcrdma_ep *)cq_context;
>         int rc;
>
> -       rc = rpcrdma_recvcq_poll(cq, ep);
> -       if (rc) {
> -               dprintk("RPC:       %s: ib_poll_cq failed: %i\n",
> -                       __func__, rc);
> -               return;
> -       }
> +       rpcrdma_recvcq_poll(cq, ep);
>
>         rc = ib_req_notify_cq(cq,
>                         IB_CQ_NEXT_COMP | IB_CQ_REPORT_MISSED_EVENTS);
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index c09414e..42c8d44 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -77,9 +77,6 @@ struct rpcrdma_ia {
>   * RDMA Endpoint -- one per transport instance
>   */
>
> -#define RPCRDMA_WC_BUDGET      (128)
> -#define RPCRDMA_POLLSIZE       (16)
> -
>  struct rpcrdma_ep {
>         atomic_t                rep_cqcount;
>         int                     rep_cqinit;
> @@ -89,8 +86,6 @@ struct rpcrdma_ep {
>         struct rdma_conn_param  rep_remote_cma;
>         struct sockaddr_storage rep_remote_addr;
>         struct delayed_work     rep_connect_worker;
> -       struct ib_wc            rep_send_wcs[RPCRDMA_POLLSIZE];
> -       struct ib_wc            rep_recv_wcs[RPCRDMA_POLLSIZE];
>  };
>
>  /*
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

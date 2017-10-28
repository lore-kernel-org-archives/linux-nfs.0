Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:51627 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbdJ1Hnq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Oct 2017 03:43:46 -0400
Received: by mail-wm0-f68.google.com with SMTP id b9so7333807wmh.0
        for <linux-nfs@vger.kernel.org>; Sat, 28 Oct 2017 00:43:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171027144743.15444.3407.stgit@klimt.1015granger.net>
References: <20171027144743.15444.3407.stgit@klimt.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Sat, 28 Oct 2017 13:13:04 +0530
Message-ID: <CANjDDBi15wrUqnnpgBabwQLg1iz92PJkbt6vN9OBFK9E2Ng5SQ@mail.gmail.com>
Subject: Re: [PATCH] svcrdma: Enqueue after setting XPT_CLOSE in completion handlers
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

looks good

Reveiwed-By: Devesh Sharma <devesh.sharma@broadcom.com>

On Fri, Oct 27, 2017 at 8:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> I noticed the server was sometimes not closing the connection after
> a flushed Send. For example, if the client responds with an RNR NAK
> to a Reply from the server, that client might be deadlocked, and
> thus wouldn't send any more traffic. Thus the server wouldn't have
> any opportunity to notice the XPT_CLOSE bit has been set.
>
> Enqueue the transport so that svcxprt notices the bit even if there
> is no more transport activity after a flushed completion, QP access
> error, or device removal event.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
>
> Hi Bruce-
>
> Please consider this patch for v4.15. Thanks!
>
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 5caf8e7..46ec069 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -290,6 +290,7 @@ static void qp_event_handler(struct ib_event *event, void *context)
>                         ib_event_msg(event->event), event->event,
>                         event->element.qp);
>                 set_bit(XPT_CLOSE, &xprt->xpt_flags);
> +               svc_xprt_enqueue(xprt);
>                 break;
>         }
>  }
> @@ -322,8 +323,7 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
>         set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
>         if (test_bit(RDMAXPRT_CONN_PENDING, &xprt->sc_flags))
>                 goto out;
> -       svc_xprt_enqueue(&xprt->sc_xprt);
> -       goto out;
> +       goto out_enqueue;
>
>  flushed:
>         if (wc->status != IB_WC_WR_FLUSH_ERR)
> @@ -333,6 +333,8 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
>         set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
>         svc_rdma_put_context(ctxt, 1);
>
> +out_enqueue:
> +       svc_xprt_enqueue(&xprt->sc_xprt);
>  out:
>         svc_xprt_put(&xprt->sc_xprt);
>  }
> @@ -358,6 +360,7 @@ void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
>
>         if (unlikely(wc->status != IB_WC_SUCCESS)) {
>                 set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
> +               svc_xprt_enqueue(&xprt->sc_xprt);
>                 if (wc->status != IB_WC_WR_FLUSH_ERR)
>                         pr_err("svcrdma: Send: %s (%u/0x%x)\n",
>                                ib_wc_status_msg(wc->status),
> @@ -569,8 +572,10 @@ static int rdma_listen_handler(struct rdma_cm_id *cma_id,
>         case RDMA_CM_EVENT_DEVICE_REMOVAL:
>                 dprintk("svcrdma: Device removal xprt=%p, cm_id=%p\n",
>                         xprt, cma_id);
> -               if (xprt)
> +               if (xprt) {
>                         set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
> +                       svc_xprt_enqueue(&xprt->sc_xprt);
> +               }
>                 break;
>
>         default:
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

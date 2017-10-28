Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:46582 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbdJ1Hcv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Oct 2017 03:32:51 -0400
Received: by mail-wm0-f66.google.com with SMTP id m72so6849215wmc.1
        for <linux-nfs@vger.kernel.org>; Sat, 28 Oct 2017 00:32:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171027164354.10826.314.stgit@manet.1015granger.net>
References: <20171027164014.10826.10151.stgit@manet.1015granger.net> <20171027164354.10826.314.stgit@manet.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Sat, 28 Oct 2017 13:02:09 +0530
Message-ID: <CANjDDBiVPTjEqnoUHGkkDndfHOa=viS7mQT0odNi0PX=mL3WSQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good
Reviewed-By: Devesh Sharma <devesh.sharma@broadcom.com>

On Fri, Oct 27, 2017 at 10:13 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Lift the Send and LocalInv completion handlers out of soft IRQ mode
> to make room for other work. Also, move the Send CQ to a different
> CPU than the CPU where the Receive CQ is running, for improved
> scalability.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 22128a8..4cfa893 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -558,7 +558,7 @@
>
>         sendcq = ib_alloc_cq(ia->ri_device, NULL,
>                              ep->rep_attr.cap.max_send_wr + 1,
> -                            0, IB_POLL_SOFTIRQ);
> +                            1, IB_POLL_WORKQUEUE);
>         if (IS_ERR(sendcq)) {
>                 rc = PTR_ERR(sendcq);
>                 dprintk("RPC:       %s: failed to create send CQ: %i\n",
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

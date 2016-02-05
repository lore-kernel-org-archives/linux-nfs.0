Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:35924 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbcBEKmY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 05:42:24 -0500
Received: by mail-yw0-f175.google.com with SMTP id q190so47790290ywd.3
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 02:42:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160203155227.13868.21062.stgit@klimt.1015granger.net>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net> <20160203155227.13868.21062.stgit@klimt.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Fri, 5 Feb 2016 16:11:43 +0530
Message-ID: <CANjDDBhK9OnuyAiBDdu25wkTtqVdip2wKn2OfCnWay14L1RWcA@mail.gmail.com>
Subject: Re: [PATCH v1 08/10] svcrdma: Remove close_out exit path
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good.

On Wed, Feb 3, 2016 at 9:22 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Clean up: close_out is reached only when ctxt == NULL and XPT_CLOSE
> is already set.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   12 +-----------
>  1 file changed, 1 insertion(+), 11 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index f8b840b..d3718e9 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -641,8 +641,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>                  * transport list
>                  */
>                 if (test_bit(XPT_CLOSE, &xprt->xpt_flags))
> -                       goto close_out;
> -
> +                       goto defer;
>                 goto out;
>         }
>         dprintk("svcrdma: processing ctxt=%p on xprt=%p, rqstp=%p, status=%d\n",
> @@ -700,15 +699,6 @@ out_err:
>         svc_rdma_put_context(ctxt, 0);
>         return 0;
>
> - close_out:
> -       if (ctxt)
> -               svc_rdma_put_context(ctxt, 1);
> -       dprintk("svcrdma: transport %p is closing\n", xprt);
> -       /*
> -        * Set the close bit and enqueue it. svc_recv will see the
> -        * close bit and call svc_xprt_delete
> -        */
> -       set_bit(XPT_CLOSE, &xprt->xpt_flags);
>  defer:
>         return 0;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

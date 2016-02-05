Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:35655 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbcBEKRz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 05:17:55 -0500
Received: by mail-yw0-f180.google.com with SMTP id g127so47323444ywf.2
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 02:17:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160203155146.13868.14354.stgit@klimt.1015granger.net>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net> <20160203155146.13868.14354.stgit@klimt.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Fri, 5 Feb 2016 15:47:15 +0530
Message-ID: <CANjDDBiHk-tHqH-xwSqY7R8xo3BUm5XfPB2obD5w-9V7z2PE+g@mail.gmail.com>
Subject: Re: [PATCH v1 03/10] svcrdma: svc_rdma_post_recv() should close
 connection on error
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good.

On Wed, Feb 3, 2016 at 9:21 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Clean up: Most svc_rdma_post_recv() call sites close the transport
> connection when a receive cannot be posted. Wrap that in a common
> helper.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/svc_rdma.h            |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   11 ++---------
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   10 +---------
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c      |    7 +------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c   |   15 +++++++++++++++
>  5 files changed, 20 insertions(+), 24 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index 5322fea..d8fc58d 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -234,6 +234,7 @@ extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
>  extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
>                                 enum rpcrdma_errcode);
>  extern int svc_rdma_post_recv(struct svcxprt_rdma *, gfp_t);
> +extern int svc_rdma_repost_recv(struct svcxprt_rdma *, gfp_t);
>  extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
>  extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
>  extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index 65a7c23..4498eaf 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -111,16 +111,9 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
>         if (ret)
>                 goto out_err;
>
> -       /* Post a recv buffer to handle the reply for this request. */
> -       ret = svc_rdma_post_recv(rdma, GFP_NOIO);
> -       if (ret) {
> -               pr_err("svcrdma: Failed to post bc receive buffer, err=%d.\n",
> -                      ret);
> -               pr_err("svcrdma: closing transport %p.\n", rdma);
> -               set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
> -               ret = -ENOTCONN;
> +       ret = svc_rdma_repost_recv(rdma, GFP_NOIO);
> +       if (ret)
>                 goto out_err;
> -       }
>
>         ctxt = svc_rdma_get_context(rdma);
>         ctxt->pages[0] = virt_to_page(rqst->rq_buffer);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index c8b8a8b..acf15b8 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -711,13 +711,5 @@ defer:
>         return 0;
>
>  repost:
> -       ret = svc_rdma_post_recv(rdma_xprt, GFP_KERNEL);
> -       if (ret) {
> -               pr_err("svcrdma: could not post a receive buffer, err=%d.\n",
> -                      ret);
> -               pr_err("svcrdma: closing transport %p.\n", rdma_xprt);
> -               set_bit(XPT_CLOSE, &rdma_xprt->sc_xprt.xpt_flags);
> -               ret = -ENOTCONN;
> -       }
> -       return ret;
> +       return svc_rdma_repost_recv(rdma_xprt, GFP_KERNEL);
>  }
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 8591314..687a91afe 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -464,13 +464,8 @@ static int send_reply(struct svcxprt_rdma *rdma,
>         int pages;
>         int ret;
>
> -       /* Post a recv buffer to handle another request. */
> -       ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
> +       ret = svc_rdma_repost_recv(rdma, GFP_KERNEL);
>         if (ret) {
> -               printk(KERN_INFO
> -                      "svcrdma: could not post a receive buffer, err=%d."
> -                      "Closing transport %p.\n", ret, rdma);
> -               set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
>                 svc_rdma_put_context(ctxt, 0);
>                 return -ENOTCONN;
>         }
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 02eee12..da82e36 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -722,6 +722,21 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
>         return -ENOMEM;
>  }
>
> +int svc_rdma_repost_recv(struct svcxprt_rdma *xprt, gfp_t flags)
> +{
> +       int ret = 0;
> +
> +       ret = svc_rdma_post_recv(xprt, flags);
> +       if (ret) {
> +               pr_err("svcrdma: could not post a receive buffer, err=%d.\n",
> +                      ret);
> +               pr_err("svcrdma: closing transport %p.\n", xprt);
> +               set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
> +               ret = -ENOTCONN;
> +       }
> +       return ret;
> +}
> +
>  /*
>   * This function handles the CONNECT_REQUEST event on a listening
>   * endpoint. It is passed the cma_id for the _new_ connection. The context in
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

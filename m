Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f42.google.com ([209.85.160.42]:40811 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaBLCMY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 21:12:24 -0500
Received: by mail-pb0-f42.google.com with SMTP id jt11so8635695pbb.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 18:12:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1392147810-23405-1-git-send-email-trond.myklebust@primarydata.com>
References: <1392147810-23405-1-git-send-email-trond.myklebust@primarydata.com>
Date: Wed, 12 Feb 2014 10:12:23 +0800
Message-ID: <CALrKORqBECRi5jHNJNoXHQSy9rBYw+2=cD96ZVakEejCtzRB_w@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix potential memory scribble in xprt_free_bc_request()
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014-02-12 3:43 GMT+08:00 Trond Myklebust <trond.myklebust@primarydata.com>:
> The call to xprt_free_allocation() will call list_del() on
> req->rq_bc_pa_list, which is not attached to a list.

Since the type of req->rq_bc_pa_list is struct list_head,  I think it
is right on the tmp_list or
the xprt->bc_pa_list.  Do I misunderstand  sth?

> This patch moves the list_del() out of xprt_free_allocation()
> and into those callers that need it.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/backchannel_rqst.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
> index 890a29912d5a..e860d4f7ed2a 100644
> --- a/net/sunrpc/backchannel_rqst.c
> +++ b/net/sunrpc/backchannel_rqst.c
> @@ -64,7 +64,6 @@ static void xprt_free_allocation(struct rpc_rqst *req)
>         free_page((unsigned long)xbufp->head[0].iov_base);
>         xbufp = &req->rq_snd_buf;
>         free_page((unsigned long)xbufp->head[0].iov_base);
> -       list_del(&req->rq_bc_pa_list);
>         kfree(req);
>  }
>
> @@ -168,8 +167,10 @@ out_free:
>         /*
>          * Memory allocation failed, free the temporary list
>          */
> -       list_for_each_entry_safe(req, tmp, &tmp_list, rq_bc_pa_list)
> +       list_for_each_entry_safe(req, tmp, &tmp_list, rq_bc_pa_list) {
> +               list_del(&req->rq_bc_pa_list);
>                 xprt_free_allocation(req);
> +       }
>
>         dprintk("RPC:       setup backchannel transport failed\n");
>         return -ENOMEM;
> @@ -198,6 +199,7 @@ void xprt_destroy_backchannel(struct rpc_xprt *xprt, unsigned int max_reqs)
>         xprt_dec_alloc_count(xprt, max_reqs);
>         list_for_each_entry_safe(req, tmp, &xprt->bc_pa_list, rq_bc_pa_list) {
>                 dprintk("RPC:        req=%p\n", req);
> +               list_del(&req->rq_bc_pa_list);
>                 xprt_free_allocation(req);
>                 if (--max_reqs == 0)
>                         break;
> --
> 1.8.5.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

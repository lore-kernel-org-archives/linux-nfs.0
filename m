Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757581Ab0JEWqf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 18:46:35 -0400
Date: Tue, 5 Oct 2010 18:46:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH] sunrpc: Remove useless if (task == NULL) from
 xprt_reserve_xprt
Message-ID: <20101005224608.GA24954@fieldses.org>
References: <4CAB5694.5030400@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CAB5694.5030400@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 05, 2010 at 08:47:16PM +0400, Pavel Emelyanov wrote:
> The task in question is dereferenced above (and is actually never NULL).

Makes sense to me.

(But probably it should go through Trond unless there's some dependency
on your patches in my tree.)

--b.

> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> ---
>  net/sunrpc/xprt.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 953206d..64a4a94 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -199,8 +199,6 @@ int xprt_reserve_xprt(struct rpc_task *task)
>  	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
>  		if (task == xprt->snd_task)
>  			return 1;
> -		if (task == NULL)
> -			return 0;
>  		goto out_sleep;
>  	}
>  	xprt->snd_task = task;
> -- 
> 1.5.5.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:46316 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753376AbdKFUCB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 15:02:01 -0500
Date: Mon, 6 Nov 2017 15:02:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: netdev@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 01/21] grace: replace BUG_ON by WARN_ONCE in exit_net
 hook
Message-ID: <20171106200200.GB13456@fieldses.org>
References: <4fdc4264-e338-6ee8-a662-7d98b45733a1@virtuozzo.com>
 <a059abdd-e727-adcb-7b43-976be1d0a08e@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a059abdd-e727-adcb-7b43-976be1d0a08e@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm assuming you want me to apply this (and the following lockd patch),
but I'm not clear why this is part of a bigger series going to netdev.

--b.

On Mon, Nov 06, 2017 at 04:22:48PM +0300, Vasily Averin wrote:
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  fs/nfs_common/grace.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
> index 420d3a0..1bd6599 100644
> --- a/fs/nfs_common/grace.c
> +++ b/fs/nfs_common/grace.c
> @@ -104,7 +104,9 @@ grace_exit_net(struct net *net)
>  {
>  	struct list_head *grace_list = net_generic(net, grace_net_id);
>  
> -	BUG_ON(!list_empty(grace_list));
> +	WARN_ONCE(!list_empty(grace_list),
> +		  "net %x %s: grace_list is not empty\n",
> +		  net->ns.inum, __func__);
>  }
>  
>  static struct pernet_operations grace_net_ops = {
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

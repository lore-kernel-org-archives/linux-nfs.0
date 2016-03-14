Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754554AbcCNUir (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2016 16:38:47 -0400
Date: Mon, 14 Mar 2016 16:38:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc/cache: drop reference when
 sunrpc_cache_pipe_upcall() detects a race
Message-ID: <20160314203846.GA22276@fieldses.org>
References: <87y49ylq76.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87y49ylq76.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 04, 2016 at 05:20:13PM +1100, NeilBrown wrote:
> 
> sunrpc_cache_pipe_upcall() can detect a race if CACHE_PENDING is no longer
> set.  In this case it aborts the queuing of the upcall.
> However it has already taken a new counted reference on "h" and
> doesn't "put" it, even though it frees the data structure holding the reference.
> 
> So let's delay the "cache_get" until we know we need it.
> 
> Fixes: f9e1aedc6c79 ("sunrpc/cache: remove races with queuing an upcall.")
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  net/sunrpc/cache.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> I found this when I was looking for something else.  Testing hasn't
> shown a bug, and nor has it shown that this is bug-free.  But it looks
> right.

Sorry for the delay.  I agree, it seems simple enough; applying for
4.6....

--b.

> 
> NeilBrown
> 
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 273bc3a35425..008c25d1b9f9 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1182,14 +1182,14 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h)
>  	}
>  
>  	crq->q.reader = 0;
> -	crq->item = cache_get(h);
>  	crq->buf = buf;
>  	crq->len = 0;
>  	crq->readers = 0;
>  	spin_lock(&queue_lock);
> -	if (test_bit(CACHE_PENDING, &h->flags))
> +	if (test_bit(CACHE_PENDING, &h->flags)) {
> +		crq->item = cache_get(h);
>  		list_add_tail(&crq->q.list, &detail->queue);
> -	else
> +	} else
>  		/* Lost a race, no longer PENDING, so don't enqueue */
>  		ret = -EAGAIN;
>  	spin_unlock(&queue_lock);
> -- 
> 2.7.0
> 



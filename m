From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/9] sunrpc/cache: change cache_defer_req to return -ve
	error, not boolean.
Date: Fri, 11 Sep 2009 17:03:55 -0400
Message-ID: <20090911210355.GF5701@fieldses.org>
References: <20090909062539.20462.67466.stgit@notabene.brown> <20090909063254.20462.57204.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51167 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756640AbZIKVDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 17:03:52 -0400
In-Reply-To: <20090909063254.20462.57204.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 09, 2009 at 04:32:54PM +1000, NeilBrown wrote:
> As "cache_defer_req" does not sound like a predicate, having it return
> a boolean value can be confusing.  It is more consistent to return
> 0 for success and negative for error.
> 
> Exactly what error code to return is not important as we don't
> differentiate between reasons why the request wasn't deferred,
> we only care about whether it was deferred or not.

Thanks, applied.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  net/sunrpc/cache.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 1a61401..aafb0e7 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -255,7 +255,7 @@ int cache_check(struct cache_detail *detail,
>  	}
>  
>  	if (rv == -EAGAIN) {
> -		if (cache_defer_req(rqstp, h) == 0) {
> +		if (cache_defer_req(rqstp, h) < 0) {
>  			/* Request is not deferred */
>  			rv = cache_is_valid(detail, h);
>  			if (rv == -EAGAIN)
> @@ -511,11 +511,11 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
>  		 * or continue and drop the oldest below
>  		 */
>  		if (net_random()&1)
> -			return 0;
> +			return -ENOMEM;
>  	}
>  	dreq = req->defer(req);
>  	if (dreq == NULL)
> -		return 0;
> +		return -ENOMEM;
>  
>  	dreq->item = item;
>  
> @@ -545,9 +545,9 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
>  	if (!test_bit(CACHE_PENDING, &item->flags)) {
>  		/* must have just been validated... */
>  		cache_revisit_request(item);
> -		return 0;
> +		return -EAGAIN;
>  	}
> -	return 1;
> +	return 0;
>  }
>  
>  static void cache_revisit_request(struct cache_head *item)
> 
> 

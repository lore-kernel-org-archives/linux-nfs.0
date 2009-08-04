From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 04/12] sunrpc/cache: recheck cache validity after
	cache_defer_req
Date: Tue, 4 Aug 2009 16:42:52 -0400
Message-ID: <20090804204252.GA24758@fieldses.org>
References: <20090804051145.15929.11356.stgit@notabene.brown> <20090804052238.15929.56800.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932611AbZHDUmv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 16:42:51 -0400
In-Reply-To: <20090804052238.15929.56800.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 04, 2009 at 03:22:38PM +1000, NeilBrown wrote:
> If cache_defer_req did not leave the request on a queue, then it could
> possibly have waited long enough that the cache became valid.  So check the
> status after the call.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  net/sunrpc/cache.c |   53 ++++++++++++++++++++++++++++++++--------------------
>  1 files changed, 33 insertions(+), 20 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index c1f897c..bff4baa 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -173,6 +173,22 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
>  EXPORT_SYMBOL_GPL(sunrpc_cache_update);
>  
>  static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h);
> +
> +static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
> +{
> +	if (!test_bit(CACHE_VALID, &h->flags) ||
> +	    h->expiry_time < get_seconds())
> +		return -EAGAIN;
> +	else if (detail->flush_time > h->last_refresh)
> +		return -EAGAIN;
> +	else {
> +		/* entry is valid */
> +		if (test_bit(CACHE_NEGATIVE, &h->flags))
> +			return -ENOENT;
> +		else
> +			return 0;
> +	}
> +}
>  /*
>   * This is the generic cache management routine for all
>   * the authentication caches.
> @@ -181,8 +197,10 @@ static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h);
>   *
>   *
>   * Returns 0 if the cache_head can be used, or cache_puts it and returns
> - * -EAGAIN if upcall is pending,
> - * -ETIMEDOUT if upcall failed and should be retried,
> + * -EAGAIN if upcall is pending and request has been queued
> + * -ETIMEDOUT if upcall failed or request could not be queue or

s/queue/queued/

> + *           upcall completed but item is still invalid (implying that
> + *           the cache item has been replaced with a newer one).
>   * -ENOENT if cache entry was negative
>   */
>  int cache_check(struct cache_detail *detail,
> @@ -192,17 +210,7 @@ int cache_check(struct cache_detail *detail,
>  	long refresh_age, age;
>  
>  	/* First decide return status as best we can */
> -	if (!test_bit(CACHE_VALID, &h->flags) ||
> -	    h->expiry_time < get_seconds())
> -		rv = -EAGAIN;
> -	else if (detail->flush_time > h->last_refresh)
> -		rv = -EAGAIN;
> -	else {
> -		/* entry is valid */
> -		if (test_bit(CACHE_NEGATIVE, &h->flags))
> -			rv = -ENOENT;
> -		else rv = 0;
> -	}
> +	rv = cache_is_valid(detail, h);
>  
>  	/* now see if we want to start an upcall */
>  	refresh_age = (h->expiry_time - h->last_refresh);
> @@ -235,10 +243,14 @@ int cache_check(struct cache_detail *detail,
>  		}
>  	}
>  
> -	if (rv == -EAGAIN)
> -		if (cache_defer_req(rqstp, h) != 0)
> -			rv = -ETIMEDOUT;
> -
> +	if (rv == -EAGAIN) {
> +		if (cache_defer_req(rqstp, h) == 0) {
> +			/* Request is not deferred */

The code might be more self-explanatory if we wrote:

		if (cache_defer_req(rqstp, h) == -ETIMEDOUT) {

Well, at least it would be obvious we're handling the "failure" case?
(Even if admittedly it's a "failure" that we may be able to handle).

It always takes me a little thought whenever I encounter a
boolean-returning function whose name doesn't have an obvious truth
value (list_empty, cache_is_valid).

No complaints otherwise.

--b.

> +			rv = cache_is_valid(detail, h);
> +			if (rv == -EAGAIN)
> +				rv = -ETIMEDOUT;
> +		}
> +	}
>  	if (rv)
>  		cache_put(h, detail);
>  	return rv;
> @@ -557,11 +569,11 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
>  		 * or continue and drop the oldest below
>  		 */
>  		if (net_random()&1)
> -			return -ETIMEDOUT;
> +			return 0;
>  	}
>  	dreq = req->defer(req);
>  	if (dreq == NULL)
> -		return -ETIMEDOUT;
> +		return 0;
>  
>  	dreq->item = item;
>  
> @@ -591,8 +603,9 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
>  	if (!test_bit(CACHE_PENDING, &item->flags)) {
>  		/* must have just been validated... */
>  		cache_revisit_request(item);
> +		return 0;
>  	}
> -	return 0;
> +	return 1;
>  }
>  
>  static void cache_revisit_request(struct cache_head *item)
> 
> 

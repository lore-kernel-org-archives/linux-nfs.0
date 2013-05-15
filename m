Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35458 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757178Ab3EONsL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 09:48:11 -0400
Date: Wed, 15 May 2013 09:48:09 -0400
To: chaoting fan <tingchaofan@gmail.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: the cache_detail in cache_is_valid is unused any
 more
Message-ID: <20130515134809.GG16811@fieldses.org>
References: <CAK1jPnLSFxLwSbe14mMbrois6bwFzbG_Q1kudBuNyywj70s7LA@mail.gmail.com>
 <1364479112.11160.0.camel@leira.trondhjem.org>
 <CAK1jPnK_WHHH3cgnocQKgMDzcQOEn4Edc-MyaV8OwWLpBMQz3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAK1jPnK_WHHH3cgnocQKgMDzcQOEn4Edc-MyaV8OwWLpBMQz3g@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think this never got applied?  Applying for 3.11.--b.

On Thu, Mar 28, 2013 at 10:19:45PM +0800, chaoting fan wrote:
> > Why not just remove it altogether? There are only 3 callers.
> 
> thanks ,here is the change patch.
> 
> the cache_detail(*detail) in function cache_is_valid is unused any more.
> 
> Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
> 
> ---
>  net/sunrpc/cache.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 9afa439..adbbc19 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -201,7 +201,7 @@ static int cache_make_upcall(struct cache_detail
> *cd, struct cache_head *h)
>  	return cd->cache_upcall(cd, h);
>  }
> 
> -static inline int cache_is_valid(struct cache_detail *detail, struct
> cache_head *h)
> +static inline int cache_is_valid(struct cache_head *h)
>  {
>  	if (!test_bit(CACHE_VALID, &h->flags))
>  		return -EAGAIN;
> @@ -227,7 +227,7 @@ static int try_to_negate_entry(struct cache_detail
> *detail, struct cache_head *h
>  	int rv;
> 
>  	write_lock(&detail->hash_lock);
> -	rv = cache_is_valid(detail, h);
> +	rv = cache_is_valid(h);
>  	if (rv != -EAGAIN) {
>  		write_unlock(&detail->hash_lock);
>  		return rv;
> @@ -260,7 +260,7 @@ int cache_check(struct cache_detail *detail,
>  	long refresh_age, age;
> 
>  	/* First decide return status as best we can */
> -	rv = cache_is_valid(detail, h);
> +	rv = cache_is_valid(h);
> 
>  	/* now see if we want to start an upcall */
>  	refresh_age = (h->expiry_time - h->last_refresh);
> @@ -293,7 +293,7 @@ int cache_check(struct cache_detail *detail,
>  			 * Request was not deferred; handle it as best
>  			 * we can ourselves:
>  			 */
> -			rv = cache_is_valid(detail, h);
> +			rv = cache_is_valid(h);
>  			if (rv == -EAGAIN)
>  				rv = -ETIMEDOUT;
>  		}
> -- 
> 1.7.10.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

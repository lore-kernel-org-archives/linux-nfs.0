From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/9] sunrpc/cache: factor out cache_is_expired
Date: Sun, 14 Mar 2010 20:58:59 -0400
Message-ID: <20100315005859.GE4644@fieldses.org>
References: <20100203060657.12945.27293.stgit@notabene.brown> <20100203063131.12945.65321.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55750 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934806Ab0COA5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Mar 2010 20:57:23 -0400
In-Reply-To: <20100203063131.12945.65321.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 03, 2010 at 05:31:31PM +1100, NeilBrown wrote:
> This removes a tiny bit of code duplication, but more important
> prepares for following patch which will perform the expiry check in
> cache_lookup and the rest of the validity check in cache_check.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>

Also applied.--b.

> ---
>  net/sunrpc/cache.c |   13 ++++++++-----
>  1 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 83592e0..9826c5c 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -49,6 +49,12 @@ static void cache_init(struct cache_head *h)
>  	h->last_refresh = now;
>  }
>  
> +static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
> +{
> +	return  (h->expiry_time < get_seconds()) ||
> +		(detail->flush_time > h->last_refresh);
> +}
> +
>  struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
>  				       struct cache_head *key, int hash)
>  {
> @@ -184,9 +190,7 @@ static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
>  static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
>  {
>  	if (!test_bit(CACHE_VALID, &h->flags) ||
> -	    h->expiry_time < get_seconds())
> -		return -EAGAIN;
> -	else if (detail->flush_time > h->last_refresh)
> +	    cache_is_expired(detail, h))
>  		return -EAGAIN;
>  	else {
>  		/* entry is valid */
> @@ -400,8 +404,7 @@ static int cache_clean(void)
>  		for (ch = *cp ; ch ; cp = & ch->next, ch = *cp) {
>  			if (current_detail->nextcheck > ch->expiry_time)
>  				current_detail->nextcheck = ch->expiry_time+1;
> -			if (ch->expiry_time >= get_seconds() &&
> -			    ch->last_refresh >= current_detail->flush_time)
> +			if (!cache_is_expired(current_detail, ch))
>  				continue;
>  
>  			*cp = ch->next;
> 
> 

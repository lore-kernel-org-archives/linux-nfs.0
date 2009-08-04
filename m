From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 03/12] sunrpc/cache: simplify cache_fresh_locked and
	cache_fresh_unlocked.
Date: Tue, 4 Aug 2009 11:45:39 -0400
Message-ID: <20090804154539.GL14249@fieldses.org>
References: <20090804051145.15929.11356.stgit@notabene.brown> <20090804052238.15929.17142.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33276 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932297AbZHDPpj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 11:45:39 -0400
In-Reply-To: <20090804052238.15929.17142.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 04, 2009 at 03:22:38PM +1000, NeilBrown wrote:
> The extra call to cache_revisit_request in cache_fresh_unlocked is not
> needed, as should have been fairly clear at the time of
>    commit 4013edea9a0b6cdcb1fdf5d4011e47e068fd6efb
> 
> If there are requests to be revisited, then we can be sure that
> CACHE_PENDING is set, so the second call is sufficient.

Yes: the only cache_make_upcall() caller (cache_check()) sets
CACHE_PENDING first.  And a grep for CACHE_PENDING verifies that
everyone that clears it immediately calls either cache_revisit_request()
or cache_dequeue().  OK!

Thanks, applied.--b.

> 
> So remove the first call.
> Then remove the 'new' parameter,
> then remove the return value for cache_fresh_locked which is only used
> to provide the value for 'new'.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  net/sunrpc/cache.c |   23 ++++++++++-------------
>  1 files changed, 10 insertions(+), 13 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 44f4516..c1f897c 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -103,18 +103,16 @@ EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
>  
>  static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
>  
> -static int cache_fresh_locked(struct cache_head *head, time_t expiry)
> +static void cache_fresh_locked(struct cache_head *head, time_t expiry)
>  {
>  	head->expiry_time = expiry;
>  	head->last_refresh = get_seconds();
> -	return !test_and_set_bit(CACHE_VALID, &head->flags);
> +	set_bit(CACHE_VALID, &head->flags);
>  }
>  
>  static void cache_fresh_unlocked(struct cache_head *head,
> -			struct cache_detail *detail, int new)
> +				 struct cache_detail *detail)
>  {
> -	if (new)
> -		cache_revisit_request(head);
>  	if (test_and_clear_bit(CACHE_PENDING, &head->flags)) {
>  		cache_revisit_request(head);
>  		cache_dequeue(detail, head);
> @@ -130,7 +128,6 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
>  	 */
>  	struct cache_head **head;
>  	struct cache_head *tmp;
> -	int is_new;
>  
>  	if (!test_bit(CACHE_VALID, &old->flags)) {
>  		write_lock(&detail->hash_lock);
> @@ -139,9 +136,9 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
>  				set_bit(CACHE_NEGATIVE, &old->flags);
>  			else
>  				detail->update(old, new);
> -			is_new = cache_fresh_locked(old, new->expiry_time);
> +			cache_fresh_locked(old, new->expiry_time);
>  			write_unlock(&detail->hash_lock);
> -			cache_fresh_unlocked(old, detail, is_new);
> +			cache_fresh_unlocked(old, detail);
>  			return old;
>  		}
>  		write_unlock(&detail->hash_lock);
> @@ -165,11 +162,11 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
>  	*head = tmp;
>  	detail->entries++;
>  	cache_get(tmp);
> -	is_new = cache_fresh_locked(tmp, new->expiry_time);
> +	cache_fresh_locked(tmp, new->expiry_time);
>  	cache_fresh_locked(old, 0);
>  	write_unlock(&detail->hash_lock);
> -	cache_fresh_unlocked(tmp, detail, is_new);
> -	cache_fresh_unlocked(old, detail, 0);
> +	cache_fresh_unlocked(tmp, detail);
> +	cache_fresh_unlocked(old, detail);
>  	cache_put(old, detail);
>  	return tmp;
>  }
> @@ -224,8 +221,8 @@ int cache_check(struct cache_detail *detail,
>  				cache_revisit_request(h);
>  				if (rv == -EAGAIN) {
>  					set_bit(CACHE_NEGATIVE, &h->flags);
> -					cache_fresh_unlocked(h, detail,
> -					     cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY));
> +					cache_fresh_locked(h, get_seconds()+CACHE_NEW_EXPIRY);
> +					cache_fresh_unlocked(h, detail);
>  					rv = -ENOENT;
>  				}
>  				break;
> 
> 

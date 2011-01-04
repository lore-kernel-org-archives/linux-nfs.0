Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41037 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720Ab1ADFCA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 00:02:00 -0500
Date: Tue, 4 Jan 2011 16:01:52 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20110104160152.602a3c44@notabene.brown>
In-Reply-To: <20110103205514.GB18056@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
	<20101229205942.GD12218@fieldses.org>
	<20101230121940.3f48223a@notabene.brown>
	<20101230015719.GA27614@fieldses.org>
	<20110103205514.GB18056@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 3 Jan 2011 15:55:14 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Dec 29, 2010 at 08:57:19PM -0500, J. Bruce Fields wrote:
> > On Thu, Dec 30, 2010 at 12:19:40PM +1100, Neil Brown wrote:
> > > On Wed, 29 Dec 2010 15:59:42 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> > > wrote:
> > > > Also noticed while trying to track down an rhel5 oops in
> > > > svcauth_unix_set_client():
> > > > 
> > > > 	- cache_check() can set an entry negative in place, which if
> > > > 	  nothing else must cause a leak in some cases.  (Because when
> > > > 	  the entry is eventually destroyed, it will be assumed to not
> > > > 	  have any contents.)  I suppose the fix is again to try to
> > > > 	  adding a new negative entry instead.
> > > 
> > > cache_check should only set an entry 'negative' if it is not already valid
> > > (rv == -EAGAIN) and there is no up-call pending.
> > 
> > I don't think anything keeps VALID from being set after the
> > cache_is_valid check but before the code that does the
> > set_bit(CACHE_NEGATIVE).
> > 
> > > Maybe we should check CACHE_VALID again after the test_and_set of
> > > CACHE_PENDING, but is a very unlikely race (if it is actually a race at all)
> > > 
> > > > 
> > > > 	- since cache_check() doesn't use any locking, I can't see what
> > > > 	  guarantees that when it sees the CACHE_VALID bit set and
> > > > 	  CACHE_NEGATIVE cleared, it must necessarily see the new
> > > > 	  contents.   I think that'd be fixed by a wmb() before setting
> > > > 	  those bits and a rmb() after checking them.  I don't know if
> > > > 	  it's actually possible to hit that bug....
> > > 
> > > Yes, we probably want a set_bit_lock in cache_fresh_locked() though I don't
> > > think that exists, so we could use test_and_set_bit_locked() instead.
> > > 
> > > But it does feel like maybe we should add some locking to cache_check.
> > > Take the lock at the the start, and release it after the
> > > test_and_set_bit(CACHE_PENDING) or once we have decided not to do that ???
> > 
> > Maybe so.
> 
> Here's one attempt.
> 
> --b.
> 
> commit 55563023f85d01698ccf72325c87e3a7039a189b
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Mon Jan 3 15:10:27 2011 -0500
> 
>     svcrpc: take locks to fix cache_check races
>     
>     There are at least a couple races in cache_check:
>     
>     	- We attempt to turn a cache entry negative in place.  But that
>     	  entry may already have been filled in by some other task since
>     	  we last checked whether it was valid, so we could be modifying
>     	  an already-valid entry.  If nothing else there's a likely leak
>     	  in such a case when the entry is eventually put() and contents
>     	  are not freed because it has CACHE_NEGATIVE set.
>     	- If cache_check races with an update that is turning the entry
>     	  CACHE_VALID, then it's possible that the CACHE_VALID bit could
>     	  become visible on this CPU before the actual contents do, so
>     	  we could tell the caller this entry is ready to use when in
>     	  fact the caller could still get invalid contents.
>     
>     Some memory barriers might be sufficient to fix at least the latter; but
>     for now let's keep things simple and take the hash_lock when we turn an
>     entry negative or check the CACHE_VALID bit.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 0d6002f..2105b40 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -200,8 +200,9 @@ static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
>  	return cd->cache_upcall(cd, h);
>  }
>  
> -static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
> +static int __cache_is_valid(struct cache_detail *detail, struct cache_head *h)
>  {
> +
>  	if (!test_bit(CACHE_VALID, &h->flags))
>  		return -EAGAIN;
>  	else {
> @@ -213,6 +214,33 @@ static inline int cache_is_valid(struct cache_detail *detail, struct cache_head
>  	}
>  }
>  
> +static int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
> +{
> +	int rv;
> +
> +	read_lock(&detail->hash_lock);
> +	rv = __cache_is_valid(detail, h);
> +	read_unlock(&detail->hash_lock);
> +	return rv;
> +}

I don't think there is anything in __cache_is_valid that needs to be
protected.
The compiler will almost certainly produce code which loads f->flags once and
then performs 1 or 2 bit tests against the value in the register and produces
one of 3 possible return values based on the result.
There is absolutely no value in putting locking around that, especially as
CACHE_VALID is never cleared.

Maybe you imagine a re-ordering of setting CACHE_NEGATIVE and CACHE_VALID,
but as they are in the same cache line (and in fact in the same byte) they
cannot be re-ordered.  We always set CACHE_NEGATIVE before CACHE_VALID and
there is no way those two could get to memory in the wrong order.



> +
> +static int try_to_negate_entry(struct cache_detail *detail, struct cache_head *h)
> +{
> +	int rv;
> +
> +	write_lock(&detail->hash_lock);
> +	rv = __cache_is_valid(detail, h);
> +	if (rv != -EAGAIN) {
> +		write_unlock(&detail->hash_lock);
> +		return rv;
> +	}
> +	set_bit(CACHE_NEGATIVE, &h->flags);
> +	cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
> +	write_unlock(&detail->hash_lock);
> +	cache_fresh_unlocked(h, detail);
> +	return -ENOENT;
> +}
> +
>  /*
>   * This is the generic cache management routine for all
>   * the authentication caches.
> @@ -251,14 +279,8 @@ int cache_check(struct cache_detail *detail,
>  			case -EINVAL:
>  				clear_bit(CACHE_PENDING, &h->flags);
>  				cache_revisit_request(h);
> -				if (rv == -EAGAIN) {
> -					set_bit(CACHE_NEGATIVE, &h->flags);
> -					cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
> -					cache_fresh_unlocked(h, detail);
> -					rv = -ENOENT;
> -				}
> +				rv = try_to_negate_entry(detail, h);
>  				break;

This bit looks good those.  It feels much better having an 'unlock' between
'cache_fresh_locked' and 'cache_fresh_unlocked' !!

Thanks,

NeilBrown


> -
>  			case -EAGAIN:
>  				clear_bit(CACHE_PENDING, &h->flags);
>  				cache_revisit_request(h);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


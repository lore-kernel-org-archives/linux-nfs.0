Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58677 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933539Ab3BSVf2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 16:35:28 -0500
Date: Tue, 19 Feb 2013 16:35:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bstroesser@ts.fujitsu.com
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc.ko: RPC cache fix races
Message-ID: <20130219213522.GC14606@fieldses.org>
References: <61eb00$3f3hdt@dgate20u.abg.fsc.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <61eb00$3f3hdt@dgate20u.abg.fsc.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 19, 2013 at 06:08:40PM +0100, bstroesser@ts.fujitsu.com wrote:
> Second attempt using the correct FROM. Sorry for the noise.
> 
> 
> Hi,
> 
> I found a problem in sunrpc.ko on a SLES11 SP1 (2.6.32.59-0,7.1)
> and fixed it (see first patch ifor 2.6.32.60 below).
> For us the patch works fine (tested on 2.6.32.59-0.7.1).
> 
> AFAICS from the code, the problem seems to persist in current
> kernel versions also. Thus, I added the second patch for 3.7.9.
> As the setup to reproduce the problem is quite complex, I couldn't
> test the second patch yet. So consider this one as a RFC.
> 
> Best regards,
> Bodo
> 
> Please CC me, I'm not on the list.
> 
> =========================================
> From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Date: Fri, 08 Feb 2013
> Subject: [PATCH] net: sunrpc: fix races in RPC cache
> 
> We found the problem and tested the patch on a SLES11 SP1 2.6.32.59-0.7.1
> 
> This patch applies to linux-2.6.32.60 (changed monotonic_seconds -->
> get_seconds())

This patch may well be correct, but for stable I can't normally take
patches that aren't backports of specific upstream fixes.  That means:
first, we need to fix whatever remains to be fixed on the latest
upstream kernel.  Then, we need to identify the other upstream patches
are needed and aren't yet in 2.6.32.60.

...
> =========================================
> From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Date: Fri, 08 Feb 2013
> Subject: [PATCH] net: sunrpc: fix races in RPC cache
> 
> This patch applies to SLES 11 SP2 linux-3.0.51-0.7.9 and also to
> vanilla linux-3.7.9
> 
> It is untested and is only based on a code review after we
> analyzed the reason for NFS requests being dropped on a
> SLES11 SP1 (linux-2.6.32.59-0.7.1)
> 
> Sporadically NFS3 RPC requests to the nfs server are dropped due to
> cache_check() (net/sunrpc/cache.c) returning -ETIMEDOUT for an entry
> of the "auth.unix.gid" cache.
> In this case, no NFS reply is sent to the client.
> 
> The reason for the dropped requests are races in cache_check() when
> cache_make_upcall() returns -EINVAL (because it is called for a cache
> without readers) and cache_check() therefore refreshes the cache entry 
> (rv == -EAGAIN).
> 
> There are two details that need to be changed:
>  1) cache_revisit_request() must not be called before cache_fresh_locked()
>     has updated the cache entry, as cache_revisit_request() wakes up
>     threads waiting for the cache entry to be updated.
>     The explicit call to cache_revisit_request() is not needed, as
>     cache_fresh_unlocked() calls it anyway.
>     (But in case of not updating the cache entry, cache_revisit_request()
>     must be called).
>  2) CACHE_PENDING must not be cleared before cache_fresh_locked() has
>     updated the cache entry, as cache_wait_req() called by
>     cache_defer_req() can return without really sleeping if it detects
>     CACHE_PENDING unset.

I think that makes sense.  Thanks for the explanation.  This is all a
bit subtle, so any additional review or testing would be appreciated....

--b.

> 
> Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> ---
> 
> --- a/net/sunrpc/cache.c	2013-02-08 15:56:07.000000000 +0100
> +++ b/net/sunrpc/cache.c	2013-02-08 16:04:32.000000000 +0100
> @@ -230,11 +230,14 @@ static int try_to_negate_entry(struct ca
>  	rv = cache_is_valid(detail, h);
>  	if (rv != -EAGAIN) {
>  		write_unlock(&detail->hash_lock);
> +		clear_bit(CACHE_PENDING, &h->flags);
> +		cache_revisit_request(h);
>  		return rv;
>  	}
>  	set_bit(CACHE_NEGATIVE, &h->flags);
>  	cache_fresh_locked(h, seconds_since_boot()+CACHE_NEW_EXPIRY);
>  	write_unlock(&detail->hash_lock);
> +	clear_bit(CACHE_PENDING, &h->flags);
>  	cache_fresh_unlocked(h, detail);
>  	return -ENOENT;
>  }
> @@ -275,8 +278,6 @@ int cache_check(struct cache_detail *det
>  		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
>  			switch (cache_make_upcall(detail, h)) {
>  			case -EINVAL:
> -				clear_bit(CACHE_PENDING, &h->flags);
> -				cache_revisit_request(h);
>  				rv = try_to_negate_entry(detail, h);
>  				break;
>  			case -EAGAIN:

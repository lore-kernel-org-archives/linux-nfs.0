From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/12] sunrpc/cache: make sure deferred requests
	eventually get revisited.
Date: Tue, 4 Aug 2009 11:02:54 -0400
Message-ID: <20090804150254.GI14249@fieldses.org>
References: <20090804051145.15929.11356.stgit@notabene.brown> <20090804052238.15929.74402.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43990 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932172AbZHDPCy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 11:02:54 -0400
In-Reply-To: <20090804052238.15929.74402.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 04, 2009 at 03:22:38PM +1000, NeilBrown wrote:
> While deferred requests normally get revisited quite quickly,
> it is possible for a request to remain in the deferral queue
> when the cache item is discarded.  We can easily make sure that
> doesn't happen by calling cache_revisit_request just before
> the final 'put'.
> 
> Also there is a small chance that a race would cause one thread to
> defer a request against a cache item while another thread is failing
> to queue and upcall for that item.  So when the upcall fails,
> make sure to revisit all deferred requests.

OK, thanks--applied.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  net/sunrpc/cache.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index d19c075..44f4516 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -221,6 +221,7 @@ int cache_check(struct cache_detail *detail,
>  			switch (cache_make_upcall(detail, h)) {
>  			case -EINVAL:
>  				clear_bit(CACHE_PENDING, &h->flags);
> +				cache_revisit_request(h);
>  				if (rv == -EAGAIN) {
>  					set_bit(CACHE_NEGATIVE, &h->flags);
>  					cache_fresh_unlocked(h, detail,
> @@ -473,8 +474,10 @@ static int cache_clean(void)
>  		if (!ch)
>  			current_index ++;
>  		spin_unlock(&cache_list_lock);
> -		if (ch)
> +		if (ch) {
> +			cache_revisit_request(ch);

Possibly dumb question: does dreq->item hold a reference?  Assuming not:
should we zero it out on revisit?  It seems like an accident waiting to
happen otherwise.

--b.

>  			cache_put(ch, d);
> +		}
>  	} else
>  		spin_unlock(&cache_list_lock);
>  
> 
> 

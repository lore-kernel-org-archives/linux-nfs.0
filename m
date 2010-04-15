Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628Ab0DOPzx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Apr 2010 11:55:53 -0400
Date: Thu, 15 Apr 2010 11:55:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/9] sunrpc/cache: allow threads to block while waiting
	for cache update.
Message-ID: <20100415155552.GC10961@fieldses.org>
References: <20100203060657.12945.27293.stgit@notabene.brown> <20100203063131.12945.23572.stgit@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100203063131.12945.23572.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 03, 2010 at 05:31:31PM +1100, NeilBrown wrote:
> The current practice of waiting for cache updates by queueing the
> whole request to be retried has (at least) two problems.
> 
> 1/ With NFSv4, requests can be quite complex and re-trying a whole
>   request when a latter part fails should only be a last-resort, not a
>   normal practice.

I want to avoid it completely, actually.  It's not so much that the
retry is expensive, as that it's actually incorrect in the case of
nonidempotent operations.  (Chief among them, SEQUENCE--see
rq_usedeferral).

How about just letting the fallback be making the client retry?

We could do that just in the v4 case (returning DELAY to v4 clients, but
doing the existing deferral for others).  Or we could handle them all
similarly (returning JUKEBOX in the v3 case, and dropping in the v2
case?)

Making the client retry is not as nice, but this should be an unusual
case.  I'm not sure how to think about what the best behavior in such a
case.

> @@ -554,6 +573,29 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
>  		cache_revisit_request(item);
>  		return -EAGAIN;
>  	}
> +
> +	if (dreq == &sleeper.handle) {
> +		wait_event_interruptible_timeout(
> +			sleeper.wait,
> +			!test_bit(CACHE_PENDING, &item->flags)
> +			|| list_empty(&sleeper.handle.hash),
> +			req->thread_wait);
> +		spin_lock(&cache_defer_lock);
> +		if (!list_empty(&sleeper.handle.hash)) {
> +			list_del_init(&sleeper.handle.recent);
> +			list_del_init(&sleeper.handle.hash);
> +			cache_defer_cnt--;
> +		}
> +		spin_unlock(&cache_defer_lock);
> +		if (test_bit(CACHE_PENDING, &item->flags)) {
> +			/* item is still pending, try request
> +			 * deferral
> +			 */
> +			dreq = req->defer(req);
> +			goto retry;
> +		}
> +		return -EEXIST;

Can this be right?  If we wake up from sleep with CACHE_PENDING cleared,
that's the succesful case.

--b.

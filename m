From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 5/9] sunrpc/cache: allow threads to block while waiting
 for cache update.
Date: Wed, 02 Dec 2009 16:23:05 -0500
Message-ID: <1259788985.2663.38.camel@localhost>
References: <20090909062539.20462.67466.stgit@notabene.brown>
	 <20090909063254.20462.99277.stgit@notabene.brown>
	 <20091202205928.GF15045@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44352 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753800AbZLBVXF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2009 16:23:05 -0500
In-Reply-To: <20091202205928.GF15045@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-12-02 at 15:59 -0500, J. Bruce Fields wrote: 
> On Wed, Sep 09, 2009 at 04:32:54PM +1000, NeilBrown wrote:
> > The current practice of waiting for cache updates by queueing the
> > whole request to be retried has (at least) two problems.
> 
> Apologies for the delay!
> 
> > 1/ With NFSv4, requests can be quite complex and re-trying a whole
> >   request when a latter part fails should only be a last-resort, not a
> >   normal practice.
> > 
> > 2/ Large requests, and in particular any 'write' request, will not be
> >   queued by the current code and doing so would be undesirable.
> > 
> > In many cases only a very sort wait is needed before the cache gets
> > valid data.
> > 
> > So, providing the underlying transport permits it by setting
> >  ->thread_wait,
> > arrange to wait briefly for an upcall to be completed (as reflected in
> > the clearing of CACHE_PENDING).
> > If the short wait was not long enough and CACHE_PENDING is still set,
> > fall back on the old approach.
> > 
> > The 'thread_wait' value is set to 5 seconds when there are spare
> > threads, and 1 second when there are no spare threads.
> > 
> > These values are probably much higher than needed, but will ensure
> > some forward progress.
> 
> This looks fine, and I want to merge it.  One mainly superficial
> complaint:
> 
> >  static int cache_defer_req(struct cache_req *req, struct cache_head *item)
> >  {
> >  	struct cache_deferred_req *dreq, *discard;
> >  	int hash = DFR_HASH(item);
> > +	struct thread_deferred_req sleeper;
> >  
> >  	if (cache_defer_cnt >= DFR_MAX) {
> >  		/* too much in the cache, randomly drop this one,
> > @@ -510,7 +522,14 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
> >  		if (net_random()&1)
> >  			return -ENOMEM;
> >  	}
> > -	dreq = req->defer(req);
> > +	if (req->thread_wait) {
> > +		dreq = &sleeper.handle;
> > +		init_waitqueue_head(&sleeper.wait);
> > +		dreq->revisit = cache_restart_thread;
> > +	} else
> > +		dreq = req->defer(req);
> > +
> > + retry:
> >  	if (dreq == NULL)
> >  		return -ENOMEM;
> >  
> > @@ -544,6 +563,29 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
> >  		cache_revisit_request(item);
> >  		return -EAGAIN;
> >  	}
> > +
> > +	if (dreq == &sleeper.handle) {
> > +		wait_event_interruptible_timeout(
> > +			sleeper.wait,
> > +			!test_bit(CACHE_PENDING, &item->flags)
> > +			|| list_empty(&sleeper.handle.hash),
> > +			req->thread_wait);
> > +		spin_lock(&cache_defer_lock);
> > +		if (!list_empty(&sleeper.handle.hash)) {
> > +			list_del_init(&sleeper.handle.recent);
> > +			list_del_init(&sleeper.handle.hash);
> > +			cache_defer_cnt--;
> > +		}
> > +		spin_unlock(&cache_defer_lock);
> > +		if (test_bit(CACHE_PENDING, &item->flags)) {
> > +			/* item is still pending, try request
> > +			 * deferral
> > +			 */
> > +			dreq = req->defer(req);
> > +			goto retry;
> > +		}
> > +		return 0;
> > +	}
> 
> With this, cache_defer_req is tending towards the long and complicated
> side.  It'd probably suffice to do something as simple as moving some of
> the code into helper functions to hide the details.

Couldn't you also simplify things a good deal by just adding a
completion to struct cache_deferred_req, and then letting
cache_defer_req() call wait_for_completion_timeout()?

That's pretty much all we do in fs/nfs/cache_lib.c...

Cheers
  Trond


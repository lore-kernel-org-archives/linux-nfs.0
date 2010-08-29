Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:44332 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754127Ab0H2XgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Aug 2010 19:36:17 -0400
Date: Mon, 30 Aug 2010 09:36:08 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Anton Blanchard <anton@au1.ibm.com>
Subject: Re: [PATCH 1.5/6] Fix race in new request delay code.
Message-ID: <20100830093608.5936a554@notabene>
In-Reply-To: <20100826210800.GD10636@fieldses.org>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
	<20100817051509.26151.91127.stgit@localhost.localdomain>
	<20100826210800.GD10636@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 26 Aug 2010 17:08:00 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Aug 17, 2010 at 03:15:09PM +1000, NeilBrown wrote:
> > If the 'wait_for_completion_interruptible_timeout' completes due
> > to interrupt or timeout, just before cache_revisit request gets around
> > to calling ->revisit and thus the completion, we have a race with bad
> > consequences.
> > 
> > cache_defer_req will see that sleeper.handle.hash is empty (because
> > cache_revisit_request has already done the list_del_init), and that
> > CACHE_PENDING is clear, and so will exit that function leaving any
> > local variables such as 'sleeper' undefined.
> > 
> > Meanwhile cache_revisit_request could delete sleeper.handle.recent
> > from the 'pending' list, and call sleeper.hande.revisit, any of which
> > could have new garbage values and so could trigger a BUG.
> 
> Thanks, this looks correct to me!
> 
> I wish it were simpler, but don't see how right now.

I think the way to make it simpler is to get rid of the deferral altogether.
The more I think about it the less I like it :-)

The deferral code effectively gives you DFR_MAX extra virtual threads.  They
each are processing one request but have (supposedly) much lower over-head
than creating real threads.  So there are two groups of threads:
 - those that can wait a longish time for a reply to an upcall
 - those that only wait for IO.

This distinction could well still be useful as we don't really want all
threads to be tied up waiting on upcalls so that no really work can be done.
However we don't really need the deferral mechanism to achieve this.

Instead we impose a limit on the number of threads that can be in waiting on
a completion (in cache_wait_req in your revised code).
If the number of such threads ever reaches - say - half the total, then we
start dropping requests and closing TCP connections (or start new threads if
we ever work out a good way to dynamically manage the thread pool).

So I would suggest:
  - putting in a counter and limiting the number of waiting threads to
    half the pool size
  - removing all the deferral code
  - looking at cleaning up what is left to make it more readable.

???

NeilBrown


> 
> Some superficial cleanup might help me at least--see below (untested),
> which attempts to make obvious the first-try-sleeping-then-try-deferral
> logic, by turning cache_defer_req into basically:
> 
> 	if (req->thread_wait) {
> 		ret = cache_wait_req(req, item);
> 		if (ret != -ETIMEDOUT)
> 			return ret;
> 	}
> 	dreq = req->defer(req);
> 	if (dreq == NULL)
> 		return -ENOMEM;
> ...
> 
> I also wonder whether there would be a way to make most of this just
> another ->defer() method, so that we wouldn't need to switch on
> req->thread_wait here at all.  But maybe there's not a nice way to do
> that.  (Certainly I prefer your approach to what the idmap code was
> doing.)
> 
> --b.
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 2c5297f..da872f9 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -509,60 +509,39 @@ static LIST_HEAD(cache_defer_list);
>  static struct list_head cache_defer_hash[DFR_HASHSIZE];
>  static int cache_defer_cnt;
>  
> -struct thread_deferred_req {
> -	struct cache_deferred_req handle;
> -	struct completion completion;
> -};
> -static void cache_restart_thread(struct cache_deferred_req *dreq, int too_many)
> +static void __unhash_deferred_req(struct cache_deferred_req *dreq)
>  {
> -	struct thread_deferred_req *dr =
> -		container_of(dreq, struct thread_deferred_req, handle);
> -	complete(&dr->completion);
> +	list_del_init(&dreq->recent);
> +	list_del_init(&dreq->hash);
> +	cache_defer_cnt--;
>  }
>  
> -static int cache_defer_req(struct cache_req *req, struct cache_head *item)
> +static void __hash_deferred_req(struct cache_deferred_req *dreq, struct cache_head *item)
>  {
> -	struct cache_deferred_req *dreq, *discard;
>  	int hash = DFR_HASH(item);
> -	struct thread_deferred_req sleeper;
>  
> -	if (cache_defer_cnt >= DFR_MAX) {
> -		/* too much in the cache, randomly drop this one,
> -		 * or continue and drop the oldest below
> -		 */
> -		if (net_random()&1)
> -			return -ENOMEM;
> -	}
> -	if (req->thread_wait) {
> -		dreq = &sleeper.handle;
> -		sleeper.completion =
> -			COMPLETION_INITIALIZER_ONSTACK(sleeper.completion);
> -		dreq->revisit = cache_restart_thread;
> -	} else
> -		dreq = req->defer(req);
> +	list_add(&dreq->recent, &cache_defer_list);
> +	if (cache_defer_hash[hash].next == NULL)
> +		INIT_LIST_HEAD(&cache_defer_hash[hash]);
> +	list_add(&dreq->hash, &cache_defer_hash[hash]);
> +}
>  
> - retry:
> -	if (dreq == NULL)
> -		return -ENOMEM;
> +static int setup_deferral(struct cache_deferred_req *dreq, struct cache_head *item)
> +{
> +	struct cache_deferred_req *discard;
>  
>  	dreq->item = item;
>  
>  	spin_lock(&cache_defer_lock);
>  
> -	list_add(&dreq->recent, &cache_defer_list);
> -
> -	if (cache_defer_hash[hash].next == NULL)
> -		INIT_LIST_HEAD(&cache_defer_hash[hash]);
> -	list_add(&dreq->hash, &cache_defer_hash[hash]);
> +	__hash_deferred_req(dreq, item);
>  
>  	/* it is in, now maybe clean up */
>  	discard = NULL;
>  	if (++cache_defer_cnt > DFR_MAX) {
>  		discard = list_entry(cache_defer_list.prev,
>  				     struct cache_deferred_req, recent);
> -		list_del_init(&discard->recent);
> -		list_del_init(&discard->hash);
> -		cache_defer_cnt--;
> +		__unhash_deferred_req(discard);
>  	}
>  	spin_unlock(&cache_defer_lock);
>  
> @@ -575,44 +554,88 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
>  		cache_revisit_request(item);
>  		return -EAGAIN;
>  	}
> +	return 0;
> +}
>  
> -	if (dreq == &sleeper.handle) {
> -		if (wait_for_completion_interruptible_timeout(
> -			    &sleeper.completion, req->thread_wait) <= 0) {
> -			/* The completion wasn't completed, so we need
> -			 * to clean up
> -			 */
> -			spin_lock(&cache_defer_lock);
> -			if (!list_empty(&sleeper.handle.hash)) {
> -				list_del_init(&sleeper.handle.recent);
> -				list_del_init(&sleeper.handle.hash);
> -				cache_defer_cnt--;
> -				spin_unlock(&cache_defer_lock);
> -			} else {
> -				/* cache_revisit_request already removed
> -				 * this from the hash table, but hasn't
> -				 * called ->revisit yet.  It will very soon
> -				 * and we need to wait for it.
> -				 */
> -				spin_unlock(&cache_defer_lock);
> -				wait_for_completion(&sleeper.completion);
> -			}
> -		}
> -		if (test_bit(CACHE_PENDING, &item->flags)) {
> -			/* item is still pending, try request
> -			 * deferral
> +struct thread_deferred_req {
> +	struct cache_deferred_req handle;
> +	struct completion completion;
> +};
> +
> +static void cache_restart_thread(struct cache_deferred_req *dreq, int too_many)
> +{
> +	struct thread_deferred_req *dr =
> +		container_of(dreq, struct thread_deferred_req, handle);
> +	complete(&dr->completion);
> +}
> +
> +static int cache_wait_req(struct cache_req *req, struct cache_head *item)
> +{
> +	struct thread_deferred_req sleeper;
> +	struct cache_deferred_req *dreq = &sleeper.handle;
> +	int ret;
> +
> +	sleeper.completion = COMPLETION_INITIALIZER_ONSTACK(sleeper.completion);
> +	dreq->revisit = cache_restart_thread;
> +
> +	ret = setup_deferral(dreq, item);
> +	if (ret)
> +		return ret;
> +
> +	if (wait_for_completion_interruptible_timeout(
> +		    &sleeper.completion, req->thread_wait) <= 0) {
> +		/* The completion wasn't completed, so we need
> +		 * to clean up
> +		 */
> +		spin_lock(&cache_defer_lock);
> +		if (!list_empty(&sleeper.handle.hash)) {
> +			__unhash_deferred_req(&sleeper.handle);
> +			spin_unlock(&cache_defer_lock);
> +		} else {
> +			/* cache_revisit_request already removed
> +			 * this from the hash table, but hasn't
> +			 * called ->revisit yet.  It will very soon
> +			 * and we need to wait for it.
>  			 */
> -			dreq = req->defer(req);
> -			goto retry;
> +			spin_unlock(&cache_defer_lock);
> +			wait_for_completion(&sleeper.completion);
>  		}
> -		/* only return success if we actually deferred the
> -		 * request.  In this case we waited until it was
> -		 * answered so no deferral has happened - rather
> -		 * an answer already exists.
> +	}
> +	if (test_bit(CACHE_PENDING, &item->flags)) {
> +		/* item is still pending, try request
> +		 * deferral
>  		 */
> -		return -EEXIST;
> +		return -ETIMEDOUT;
>  	}
> -	return 0;
> +	/* only return success if we actually deferred the
> +	 * request.  In this case we waited until it was
> +	 * answered so no deferral has happened - rather
> +	 * an answer already exists.
> +	 */
> +	return -EEXIST;
> +}
> +
> +static int cache_defer_req(struct cache_req *req, struct cache_head *item)
> +{
> +	struct cache_deferred_req *dreq;
> +	int ret;
> +
> +	if (cache_defer_cnt >= DFR_MAX) {
> +		/* too much in the cache, randomly drop this one,
> +		 * or continue and drop the oldest
> +		 */
> +		if (net_random()&1)
> +			return -ENOMEM;
> +	}
> +	if (req->thread_wait) {
> +		ret = cache_wait_req(req, item);
> +		if (ret != -ETIMEDOUT)
> +			return ret;
> +	}
> +	dreq = req->defer(req);
> +	if (dreq == NULL)
> +		return -ENOMEM;
> +	return setup_deferral(dreq, item);
>  }
>  
>  static void cache_revisit_request(struct cache_head *item)
> @@ -632,9 +655,8 @@ static void cache_revisit_request(struct cache_head *item)
>  			dreq = list_entry(lp, struct cache_deferred_req, hash);
>  			lp = lp->next;
>  			if (dreq->item == item) {
> -				list_del_init(&dreq->hash);
> -				list_move(&dreq->recent, &pending);
> -				cache_defer_cnt--;
> +				__unhash_deferred_req(dreq);
> +				list_add(&dreq->recent, &pending);
>  			}
>  		}
>  	}
> @@ -657,11 +679,8 @@ void cache_clean_deferred(void *owner)
>  	spin_lock(&cache_defer_lock);
>  
>  	list_for_each_entry_safe(dreq, tmp, &cache_defer_list, recent) {
> -		if (dreq->owner == owner) {
> -			list_del_init(&dreq->hash);
> -			list_move(&dreq->recent, &pending);
> -			cache_defer_cnt--;
> -		}
> +		if (dreq->owner == owner)
> +			__unhash_deferred_req(dreq);
>  	}
>  	spin_unlock(&cache_defer_lock);
>  
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 8ff6840..95fc3e8 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -665,7 +665,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
>  
>  		/* As there is a shortage of threads and this request
> -		 * had to be queue, don't allow the thread to wait so
> +		 * had to be queued, don't allow the thread to wait so
>  		 * long for cache updates.
>  		 */
>  		rqstp->rq_chandle.thread_wait = 1*HZ;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51018 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbaLAXsD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Dec 2014 18:48:03 -0500
Date: Mon, 1 Dec 2014 18:47:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] sunrpc: convert to lockless lookup of queued server
 threads
Message-ID: <20141201234759.GF30749@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
 <1416597571-4265-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1416597571-4265-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 21, 2014 at 02:19:30PM -0500, Jeff Layton wrote:
> Testing has shown that the pool->sp_lock can be a bottleneck on a busy
> server. Every time data is received on a socket, the server must take
> that lock in order to dequeue a thread from the sp_threads list.
> 
> Address this problem by eliminating the sp_threads list (which contains
> threads that are currently idle) and replacing it with a RQ_BUSY flag in
> svc_rqst. This allows us to walk the sp_all_threads list under the
> rcu_read_lock and find a suitable thread for the xprt by doing a
> test_and_set_bit.
> 
> Note that we do still have a potential atomicity problem however with
> this approach.  We don't want svc_xprt_do_enqueue to set the
> rqst->rq_xprt pointer unless a test_and_set_bit of RQ_BUSY returned
> negative (which indicates that the thread was idle). But, by the time we
> check that, the big could be flipped by a waking thread.

(Nits: replacing "negative" by "zero" and "big" by "bit".)

> To address this, we acquire a new per-rqst spinlock (rq_lock) and take
> that before doing the test_and_set_bit. If that returns false, then we
> can set rq_xprt and drop the spinlock. Then, when the thread wakes up,
> it must set the bit under the same spinlock and can trust that if it was
> already set then the rq_xprt is also properly set.
> 
> With this scheme, the case where we have an idle thread no longer needs
> to take the highly contended pool->sp_lock at all, and that removes the
> bottleneck.
> 
> That still leaves one issue: What of the case where we walk the whole
> sp_all_threads list and don't find an idle thread? Because the search is
> lockess, it's possible for the queueing to race with a thread that is
> going to sleep. To address that, we queue the xprt and then search again.
> 
> If we find an idle thread at that point, we can't attach the xprt to it
> directly since that might race with a different thread waking up and
> finding it.  All we can do is wake the idle thread back up and let it
> attempt to find the now-queued xprt.

I find it hard to think about how we expect this to affect performance.
So it comes down to the observed results, I guess, but just trying to
get an idea:

	- this eliminates sp_lock.  I think the original idea here was
	  that if interrupts could be routed correctly then there
	  shouldn't normally be cross-cpu contention on this lock.  Do
	  we understand why that didn't pan out?  Is hardware capable of
	  doing this really rare, or is it just too hard to configure it
	  correctly?

	- instead we're walking the list of all threads looking for an
	  idle one.  I suppose that's tpyically not more than a few
	  hundred.  Does this being fast depend on the fact that that
	  list is almost never changed?  Should we be rearranging
	  svc_rqst so frequently-written fields aren't nearby?

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> Tested-by: Chris Worley <chris.worley@primarydata.com>
> ---
>  include/linux/sunrpc/svc.h    |   4 +-
>  include/trace/events/sunrpc.h |   3 +-
>  net/sunrpc/svc.c              |   7 +-
>  net/sunrpc/svc_xprt.c         | 221 ++++++++++++++++++++++++------------------
>  4 files changed, 132 insertions(+), 103 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 513957eba0a5..6f22cfeef5e3 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -45,7 +45,6 @@ struct svc_pool_stats {
>  struct svc_pool {
>  	unsigned int		sp_id;	    	/* pool id; also node id on NUMA */
>  	spinlock_t		sp_lock;	/* protects all fields */
> -	struct list_head	sp_threads;	/* idle server threads */
>  	struct list_head	sp_sockets;	/* pending sockets */
>  	unsigned int		sp_nrthreads;	/* # of threads in pool */
>  	struct list_head	sp_all_threads;	/* all server threads */
> @@ -221,7 +220,6 @@ static inline void svc_putu32(struct kvec *iov, __be32 val)
>   * processed.
>   */
>  struct svc_rqst {
> -	struct list_head	rq_list;	/* idle list */
>  	struct list_head	rq_all;		/* all threads list */
>  	struct rcu_head		rq_rcu_head;	/* for RCU deferred kfree */
>  	struct svc_xprt *	rq_xprt;	/* transport ptr */
> @@ -264,6 +262,7 @@ struct svc_rqst {
>  						 * to prevent encrypting page
>  						 * cache pages */
>  #define	RQ_VICTIM	(5)			/* about to be shut down */
> +#define	RQ_BUSY		(6)			/* request is busy */
>  	unsigned long		rq_flags;	/* flags field */
>  
>  	void *			rq_argp;	/* decoded arguments */
> @@ -285,6 +284,7 @@ struct svc_rqst {
>  	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
>  	struct svc_cacherep *	rq_cacherep;	/* cache info */
>  	struct task_struct	*rq_task;	/* service thread */
> +	spinlock_t		rq_lock;	/* per-request lock */
>  };
>  
>  #define SVC_NET(svc_rqst)	(svc_rqst->rq_xprt->xpt_net)
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index 08a5fed50f34..ee4438a63a48 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -419,7 +419,8 @@ TRACE_EVENT(xs_tcp_data_recv,
>  		{ (1UL << RQ_USEDEFERRAL),	"RQ_USEDEFERRAL"},	\
>  		{ (1UL << RQ_DROPME),		"RQ_DROPME"},		\
>  		{ (1UL << RQ_SPLICE_OK),	"RQ_SPLICE_OK"},	\
> -		{ (1UL << RQ_VICTIM),		"RQ_VICTIM"})
> +		{ (1UL << RQ_VICTIM),		"RQ_VICTIM"},		\
> +		{ (1UL << RQ_BUSY),		"RQ_BUSY"})
>  
>  TRACE_EVENT(svc_recv,
>  	TP_PROTO(struct svc_rqst *rqst, int status),
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 4edef32f3b9f..4308881d9d0a 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -476,7 +476,6 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>  				i, serv->sv_name);
>  
>  		pool->sp_id = i;
> -		INIT_LIST_HEAD(&pool->sp_threads);
>  		INIT_LIST_HEAD(&pool->sp_sockets);
>  		INIT_LIST_HEAD(&pool->sp_all_threads);
>  		spin_lock_init(&pool->sp_lock);
> @@ -614,12 +613,14 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
>  		goto out_enomem;
>  
>  	serv->sv_nrthreads++;
> +	__set_bit(RQ_BUSY, &rqstp->rq_flags);
> +	spin_lock_init(&rqstp->rq_lock);
> +	rqstp->rq_server = serv;
> +	rqstp->rq_pool = pool;
>  	spin_lock_bh(&pool->sp_lock);
>  	pool->sp_nrthreads++;
>  	list_add_rcu(&rqstp->rq_all, &pool->sp_all_threads);
>  	spin_unlock_bh(&pool->sp_lock);
> -	rqstp->rq_server = serv;
> -	rqstp->rq_pool = pool;
>  
>  	rqstp->rq_argp = kmalloc_node(serv->sv_xdrsize, GFP_KERNEL, node);
>  	if (!rqstp->rq_argp)
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 579ff2249562..ed90d955f733 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -310,25 +310,6 @@ char *svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
>  }
>  EXPORT_SYMBOL_GPL(svc_print_addr);
>  
> -/*
> - * Queue up an idle server thread.  Must have pool->sp_lock held.
> - * Note: this is really a stack rather than a queue, so that we only
> - * use as many different threads as we need, and the rest don't pollute
> - * the cache.
> - */
> -static void svc_thread_enqueue(struct svc_pool *pool, struct svc_rqst *rqstp)
> -{
> -	list_add(&rqstp->rq_list, &pool->sp_threads);
> -}
> -
> -/*
> - * Dequeue an nfsd thread.  Must have pool->sp_lock held.
> - */
> -static void svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
> -{
> -	list_del(&rqstp->rq_list);
> -}
> -
>  static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
>  {
>  	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
> @@ -343,6 +324,7 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
>  	struct svc_pool *pool;
>  	struct svc_rqst	*rqstp;
>  	int cpu;
> +	bool queued = false;
>  
>  	if (!svc_xprt_has_something_to_do(xprt))
>  		return;
> @@ -360,37 +342,60 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
>  
>  	cpu = get_cpu();
>  	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
> -	spin_lock_bh(&pool->sp_lock);
>  
>  	atomic_long_inc(&pool->sp_stats.packets);
>  
> -	if (!list_empty(&pool->sp_threads)) {
> -		rqstp = list_entry(pool->sp_threads.next,
> -				   struct svc_rqst,
> -				   rq_list);
> -		dprintk("svc: transport %p served by daemon %p\n",
> -			xprt, rqstp);
> -		svc_thread_dequeue(pool, rqstp);
> -		if (rqstp->rq_xprt)
> -			printk(KERN_ERR
> -				"svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
> -				rqstp, rqstp->rq_xprt);
> -		/* Note the order of the following 3 lines:
> -		 * We want to assign xprt to rqstp->rq_xprt only _after_
> -		 * we've woken up the process, so that we don't race with
> -		 * the lockless check in svc_get_next_xprt().
> +redo_search:
> +	/* find a thread for this xprt */
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(rqstp, &pool->sp_all_threads, rq_all) {
> +		/* Do a lockless check first */
> +		if (test_bit(RQ_BUSY, &rqstp->rq_flags))
> +			continue;
> +
> +		/*
> +		 * Once the xprt has been queued, it can only be dequeued by
> +		 * the task that intends to service it. All we can do at that
> +		 * point is to try to wake this thread back up so that it can
> +		 * do so.
>  		 */
> -		svc_xprt_get(xprt);
> -		wake_up_process(rqstp->rq_task);
> -		rqstp->rq_xprt = xprt;
> +		if (!queued) {
> +			spin_lock_bh(&rqstp->rq_lock);
> +			if (test_and_set_bit(RQ_BUSY, &rqstp->rq_flags)) {
> +				/* already busy, move on... */
> +				spin_unlock_bh(&rqstp->rq_lock);
> +				continue;
> +			}
> +
> +			/* this one will do */
> +			rqstp->rq_xprt = xprt;
> +			svc_xprt_get(xprt);
> +			spin_unlock_bh(&rqstp->rq_lock);
> +		}
> +		rcu_read_unlock();
> +
>  		atomic_long_inc(&pool->sp_stats.threads_woken);
> -	} else {
> +		wake_up_process(rqstp->rq_task);
> +		put_cpu();
> +		return;
> +	}
> +	rcu_read_unlock();
> +
> +	/*
> +	 * We didn't find an idle thread to use, so we need to queue the xprt.
> +	 * Do so and then search again. If we find one, we can't hook this one
> +	 * up to it directly but we can wake the thread up in the hopes that it
> +	 * will pick it up once it searches for a xprt to service.
> +	 */
> +	if (!queued) {
> +		queued = true;
>  		dprintk("svc: transport %p put into queue\n", xprt);
> +		spin_lock_bh(&pool->sp_lock);
>  		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
>  		pool->sp_stats.sockets_queued++;
> +		spin_unlock_bh(&pool->sp_lock);
> +		goto redo_search;
>  	}
> -
> -	spin_unlock_bh(&pool->sp_lock);
>  	put_cpu();
>  }
>  
> @@ -408,21 +413,26 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
>  EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
>  
>  /*
> - * Dequeue the first transport.  Must be called with the pool->sp_lock held.
> + * Dequeue the first transport, if there is one.
>   */
>  static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
>  {
> -	struct svc_xprt	*xprt;
> +	struct svc_xprt	*xprt = NULL;
>  
>  	if (list_empty(&pool->sp_sockets))
>  		return NULL;
>  
> -	xprt = list_entry(pool->sp_sockets.next,
> -			  struct svc_xprt, xpt_ready);
> -	list_del_init(&xprt->xpt_ready);
> +	spin_lock_bh(&pool->sp_lock);
> +	if (likely(!list_empty(&pool->sp_sockets))) {
> +		xprt = list_first_entry(&pool->sp_sockets,
> +					struct svc_xprt, xpt_ready);
> +		list_del_init(&xprt->xpt_ready);
> +		svc_xprt_get(xprt);
>  
> -	dprintk("svc: transport %p dequeued, inuse=%d\n",
> -		xprt, atomic_read(&xprt->xpt_ref.refcount));
> +		dprintk("svc: transport %p dequeued, inuse=%d\n",
> +			xprt, atomic_read(&xprt->xpt_ref.refcount));
> +	}
> +	spin_unlock_bh(&pool->sp_lock);
>  
>  	return xprt;
>  }
> @@ -497,16 +507,21 @@ void svc_wake_up(struct svc_serv *serv)
>  
>  	pool = &serv->sv_pools[0];
>  
> -	spin_lock_bh(&pool->sp_lock);
> -	if (!list_empty(&pool->sp_threads)) {
> -		rqstp = list_entry(pool->sp_threads.next,
> -				   struct svc_rqst,
> -				   rq_list);
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(rqstp, &pool->sp_all_threads, rq_all) {
> +		/* skip any that aren't queued */
> +		if (test_bit(RQ_BUSY, &rqstp->rq_flags))
> +			continue;
> +		rcu_read_unlock();
>  		dprintk("svc: daemon %p woken up.\n", rqstp);
>  		wake_up_process(rqstp->rq_task);
> -	} else
> -		set_bit(SP_TASK_PENDING, &pool->sp_flags);
> -	spin_unlock_bh(&pool->sp_lock);
> +		return;
> +	}
> +	rcu_read_unlock();
> +
> +	/* No free entries available */
> +	set_bit(SP_TASK_PENDING, &pool->sp_flags);
> +	smp_wmb();
>  }
>  EXPORT_SYMBOL_GPL(svc_wake_up);
>  
> @@ -617,22 +632,47 @@ static int svc_alloc_arg(struct svc_rqst *rqstp)
>  	return 0;
>  }
>  
> +static bool
> +rqst_should_sleep(struct svc_rqst *rqstp)
> +{
> +	struct svc_pool		*pool = rqstp->rq_pool;
> +
> +	/* did someone call svc_wake_up? */
> +	if (test_and_clear_bit(SP_TASK_PENDING, &pool->sp_flags))
> +		return false;
> +
> +	/* was a socket queued? */
> +	if (!list_empty(&pool->sp_sockets))
> +		return false;
> +
> +	/* are we shutting down? */
> +	if (signalled() || kthread_should_stop())
> +		return false;
> +
> +	/* are we freezing? */
> +	if (freezing(current))
> +		return false;
> +
> +	return true;
> +}
> +
>  static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  {
>  	struct svc_xprt *xprt;
>  	struct svc_pool		*pool = rqstp->rq_pool;
>  	long			time_left = 0;
>  
> +	/* rq_xprt should be clear on entry */
> +	WARN_ON_ONCE(rqstp->rq_xprt);
> +
>  	/* Normally we will wait up to 5 seconds for any required
>  	 * cache information to be provided.
>  	 */
>  	rqstp->rq_chandle.thread_wait = 5*HZ;
>  
> -	spin_lock_bh(&pool->sp_lock);
>  	xprt = svc_xprt_dequeue(pool);
>  	if (xprt) {
>  		rqstp->rq_xprt = xprt;
> -		svc_xprt_get(xprt);
>  
>  		/* As there is a shortage of threads and this request
>  		 * had to be queued, don't allow the thread to wait so
> @@ -640,51 +680,38 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  		 */
>  		rqstp->rq_chandle.thread_wait = 1*HZ;
>  		clear_bit(SP_TASK_PENDING, &pool->sp_flags);
> -	} else {
> -		if (test_and_clear_bit(SP_TASK_PENDING, &pool->sp_flags)) {
> -			xprt = ERR_PTR(-EAGAIN);
> -			goto out;
> -		}
> -		/*
> -		 * We have to be able to interrupt this wait
> -		 * to bring down the daemons ...
> -		 */
> -		set_current_state(TASK_INTERRUPTIBLE);
> +		return xprt;
> +	}
>  
> -		/* No data pending. Go to sleep */
> -		svc_thread_enqueue(pool, rqstp);
> -		spin_unlock_bh(&pool->sp_lock);
> +	/*
> +	 * We have to be able to interrupt this wait
> +	 * to bring down the daemons ...
> +	 */
> +	set_current_state(TASK_INTERRUPTIBLE);
> +	clear_bit(RQ_BUSY, &rqstp->rq_flags);
> +	smp_mb();
> +
> +	if (likely(rqst_should_sleep(rqstp)))
> +		time_left = schedule_timeout(timeout);
> +	else
> +		__set_current_state(TASK_RUNNING);
>  
> -		if (!(signalled() || kthread_should_stop())) {
> -			time_left = schedule_timeout(timeout);
> -			__set_current_state(TASK_RUNNING);
> +	try_to_freeze();
>  
> -			try_to_freeze();
> +	spin_lock_bh(&rqstp->rq_lock);
> +	set_bit(RQ_BUSY, &rqstp->rq_flags);
> +	spin_unlock_bh(&rqstp->rq_lock);
>  
> -			xprt = rqstp->rq_xprt;
> -			if (xprt != NULL)
> -				return xprt;
> -		} else
> -			__set_current_state(TASK_RUNNING);
> +	xprt = rqstp->rq_xprt;
> +	if (xprt != NULL)
> +		return xprt;
>  
> -		spin_lock_bh(&pool->sp_lock);
> -		if (!time_left)
> -			atomic_long_inc(&pool->sp_stats.threads_timedout);
> +	if (!time_left)
> +		atomic_long_inc(&pool->sp_stats.threads_timedout);
>  
> -		xprt = rqstp->rq_xprt;
> -		if (!xprt) {
> -			svc_thread_dequeue(pool, rqstp);
> -			spin_unlock_bh(&pool->sp_lock);
> -			dprintk("svc: server %p, no data yet\n", rqstp);
> -			if (signalled() || kthread_should_stop())
> -				return ERR_PTR(-EINTR);
> -			else
> -				return ERR_PTR(-EAGAIN);
> -		}
> -	}
> -out:
> -	spin_unlock_bh(&pool->sp_lock);
> -	return xprt;
> +	if (signalled() || kthread_should_stop())
> +		return ERR_PTR(-EINTR);
> +	return ERR_PTR(-EAGAIN);
>  }
>  
>  static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
> -- 
> 2.1.0
> 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17181 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751772AbdJSTiZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Oct 2017 15:38:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 2/2] SUNRPC: Improve ordering of transport processing
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20171010173143.106492-2-trond.myklebust@primarydata.com>
Date: Thu, 19 Oct 2017 15:38:17 -0400
Cc: Bruce Fields <bfields@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9D9E2C92-F1FF-4451-800D-54F74D815F7E@oracle.com>
References: <20171010173143.106492-1-trond.myklebust@primarydata.com> <20171010173143.106492-2-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 10, 2017, at 1:31 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> Since it can take a while before a specific thread gets scheduled, it
> is better to just implement a first come first served queue mechanism.
> That way, if a thread is already scheduled and is idle, it can pick up
> the work to do from the queue.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Tested-by: Chuck Lever <chuck.lever@oracle.com>

Light performance testing, and a git software build / regression
suite run on NFSv4.1. All on NFS/RDMA.


> ---
> include/linux/sunrpc/svc.h |   1 +
> net/sunrpc/svc_xprt.c      | 100 ++++++++++++++-------------------------------
> 2 files changed, 31 insertions(+), 70 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 38f561b2dda3..23c4d6496aac 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -46,6 +46,7 @@ struct svc_pool {
> 	struct svc_pool_stats	sp_stats;	/* statistics on pool operation */
> #define	SP_TASK_PENDING		(0)		/* still work to do even if no
> 						 * xprt is queued. */
> +#define SP_CONGESTED		(1)
> 	unsigned long		sp_flags;
> } ____cacheline_aligned_in_smp;
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index d16a8b423c20..9b29c53281a8 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -380,7 +380,6 @@ void svc_xprt_do_enqueue(struct svc_xprt *xprt)
> 	struct svc_pool *pool;
> 	struct svc_rqst	*rqstp = NULL;
> 	int cpu;
> -	bool queued = false;
> 
> 	if (!svc_xprt_has_something_to_do(xprt))
> 		goto out;
> @@ -401,58 +400,25 @@ void svc_xprt_do_enqueue(struct svc_xprt *xprt)
> 
> 	atomic_long_inc(&pool->sp_stats.packets);
> 
> -redo_search:
> +	dprintk("svc: transport %p put into queue\n", xprt);
> +	spin_lock_bh(&pool->sp_lock);
> +	list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
> +	pool->sp_stats.sockets_queued++;
> +	spin_unlock_bh(&pool->sp_lock);
> +
> 	/* find a thread for this xprt */
> 	rcu_read_lock();
> 	list_for_each_entry_rcu(rqstp, &pool->sp_all_threads, rq_all) {
> -		/* Do a lockless check first */
> -		if (test_bit(RQ_BUSY, &rqstp->rq_flags))
> +		if (test_and_set_bit(RQ_BUSY, &rqstp->rq_flags))
> 			continue;
> -
> -		/*
> -		 * Once the xprt has been queued, it can only be dequeued by
> -		 * the task that intends to service it. All we can do at that
> -		 * point is to try to wake this thread back up so that it can
> -		 * do so.
> -		 */
> -		if (!queued) {
> -			spin_lock_bh(&rqstp->rq_lock);
> -			if (test_and_set_bit(RQ_BUSY, &rqstp->rq_flags)) {
> -				/* already busy, move on... */
> -				spin_unlock_bh(&rqstp->rq_lock);
> -				continue;
> -			}
> -
> -			/* this one will do */
> -			rqstp->rq_xprt = xprt;
> -			svc_xprt_get(xprt);
> -			spin_unlock_bh(&rqstp->rq_lock);
> -		}
> -		rcu_read_unlock();
> -
> 		atomic_long_inc(&pool->sp_stats.threads_woken);
> 		wake_up_process(rqstp->rq_task);
> -		put_cpu();
> -		goto out;
> -	}
> -	rcu_read_unlock();
> -
> -	/*
> -	 * We didn't find an idle thread to use, so we need to queue the xprt.
> -	 * Do so and then search again. If we find one, we can't hook this one
> -	 * up to it directly but we can wake the thread up in the hopes that it
> -	 * will pick it up once it searches for a xprt to service.
> -	 */
> -	if (!queued) {
> -		queued = true;
> -		dprintk("svc: transport %p put into queue\n", xprt);
> -		spin_lock_bh(&pool->sp_lock);
> -		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
> -		pool->sp_stats.sockets_queued++;
> -		spin_unlock_bh(&pool->sp_lock);
> -		goto redo_search;
> +		goto out_unlock;
> 	}
> +	set_bit(SP_CONGESTED, &pool->sp_flags);
> 	rqstp = NULL;
> +out_unlock:
> +	rcu_read_unlock();
> 	put_cpu();
> out:
> 	trace_svc_xprt_do_enqueue(xprt, rqstp);
> @@ -721,38 +687,25 @@ rqst_should_sleep(struct svc_rqst *rqstp)
> 
> static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
> {
> -	struct svc_xprt *xprt;
> 	struct svc_pool		*pool = rqstp->rq_pool;
> 	long			time_left = 0;
> 
> 	/* rq_xprt should be clear on entry */
> 	WARN_ON_ONCE(rqstp->rq_xprt);
> 
> -	/* Normally we will wait up to 5 seconds for any required
> -	 * cache information to be provided.
> -	 */
> -	rqstp->rq_chandle.thread_wait = 5*HZ;
> -
> -	xprt = svc_xprt_dequeue(pool);
> -	if (xprt) {
> -		rqstp->rq_xprt = xprt;
> -
> -		/* As there is a shortage of threads and this request
> -		 * had to be queued, don't allow the thread to wait so
> -		 * long for cache updates.
> -		 */
> -		rqstp->rq_chandle.thread_wait = 1*HZ;
> -		clear_bit(SP_TASK_PENDING, &pool->sp_flags);
> -		return xprt;
> -	}
> +	rqstp->rq_xprt = svc_xprt_dequeue(pool);
> +	if (rqstp->rq_xprt)
> +		goto out_found;
> 
> 	/*
> 	 * We have to be able to interrupt this wait
> 	 * to bring down the daemons ...
> 	 */
> 	set_current_state(TASK_INTERRUPTIBLE);
> +	smp_mb__before_atomic();
> +	clear_bit(SP_CONGESTED, &pool->sp_flags);
> 	clear_bit(RQ_BUSY, &rqstp->rq_flags);
> -	smp_mb();
> +	smp_mb__after_atomic();
> 
> 	if (likely(rqst_should_sleep(rqstp)))
> 		time_left = schedule_timeout(timeout);
> @@ -761,13 +714,11 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
> 
> 	try_to_freeze();
> 
> -	spin_lock_bh(&rqstp->rq_lock);
> 	set_bit(RQ_BUSY, &rqstp->rq_flags);
> -	spin_unlock_bh(&rqstp->rq_lock);
> -
> -	xprt = rqstp->rq_xprt;
> -	if (xprt != NULL)
> -		return xprt;
> +	smp_mb__after_atomic();
> +	rqstp->rq_xprt = svc_xprt_dequeue(pool);
> +	if (rqstp->rq_xprt)
> +		goto out_found;
> 
> 	if (!time_left)
> 		atomic_long_inc(&pool->sp_stats.threads_timedout);
> @@ -775,6 +726,15 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
> 	if (signalled() || kthread_should_stop())
> 		return ERR_PTR(-EINTR);
> 	return ERR_PTR(-EAGAIN);
> +out_found:
> +	/* Normally we will wait up to 5 seconds for any required
> +	 * cache information to be provided.
> +	 */
> +	if (!test_bit(SP_CONGESTED, &pool->sp_flags))
> +		rqstp->rq_chandle.thread_wait = 5*HZ;
> +	else
> +		rqstp->rq_chandle.thread_wait = 1*HZ;
> +	return rqstp->rq_xprt;
> }
> 
> static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
> -- 
> 2.13.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




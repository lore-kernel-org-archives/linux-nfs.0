Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55962 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753878AbaHLTxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 15:53:09 -0400
Date: Tue, 12 Aug 2014 15:53:08 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/11] SUNRPC: get rid of the request wait queue
Message-ID: <20140812195308.GC25914@fieldses.org>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-7-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-8-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-9-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1407085393-3175-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 03, 2014 at 01:03:10PM -0400, Trond Myklebust wrote:
> We're always _only_ waking up tasks from within the sp_threads list, so
> we know that they are enqueued and alive. The rq_wait waitqueue is just
> a distraction with extra atomic semantics.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  include/linux/sunrpc/svc.h |  1 -
>  net/sunrpc/svc.c           |  2 --
>  net/sunrpc/svc_xprt.c      | 32 +++++++++++++++++---------------
>  3 files changed, 17 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 1bc7cd05b22e..3ec769b65c7f 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -280,7 +280,6 @@ struct svc_rqst {
>  	int			rq_splice_ok;   /* turned off in gss privacy
>  						 * to prevent encrypting page
>  						 * cache pages */
> -	wait_queue_head_t	rq_wait;	/* synchronization */
>  	struct task_struct	*rq_task;	/* service thread */
>  };
>  
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 5de6801cd924..dfb78c4f3031 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -612,8 +612,6 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
>  	if (!rqstp)
>  		goto out_enomem;
>  
> -	init_waitqueue_head(&rqstp->rq_wait);
> -
>  	serv->sv_nrthreads++;
>  	spin_lock_bh(&pool->sp_lock);
>  	pool->sp_nrthreads++;
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 2c30193c7a13..438e91c12851 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -348,8 +348,6 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
>  
>  	cpu = get_cpu();
>  	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
> -	put_cpu();
> -
>  	spin_lock_bh(&pool->sp_lock);
>  
>  	if (!list_empty(&pool->sp_threads) &&
> @@ -382,10 +380,15 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
>  			printk(KERN_ERR
>  				"svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
>  				rqstp, rqstp->rq_xprt);
> -		rqstp->rq_xprt = xprt;
> +		/* Note the order of the following 3 lines:
> +		 * We want to assign xprt to rqstp->rq_xprt only _after_
> +		 * we've woken up the process, so that we don't race with
> +		 * the lockless check in svc_get_next_xprt().

Sorry, I'm not following this: what exactly is the race?

--b.

> +		 */
>  		svc_xprt_get(xprt);
> +		wake_up_process(rqstp->rq_task);
> +		rqstp->rq_xprt = xprt;
>  		pool->sp_stats.threads_woken++;
> -		wake_up(&rqstp->rq_wait);
>  	} else {
>  		dprintk("svc: transport %p put into queue\n", xprt);
>  		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
> @@ -394,6 +397,7 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
>  
>  out_unlock:
>  	spin_unlock_bh(&pool->sp_lock);
> +	put_cpu();
>  }
>  
>  /*
> @@ -509,7 +513,7 @@ void svc_wake_up(struct svc_serv *serv)
>  			svc_thread_dequeue(pool, rqstp);
>  			rqstp->rq_xprt = NULL;
>  			 */
> -			wake_up(&rqstp->rq_wait);
> +			wake_up_process(rqstp->rq_task);
>  		} else
>  			pool->sp_task_pending = 1;
>  		spin_unlock_bh(&pool->sp_lock);
> @@ -628,7 +632,6 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  {
>  	struct svc_xprt *xprt;
>  	struct svc_pool		*pool = rqstp->rq_pool;
> -	DECLARE_WAITQUEUE(wait, current);
>  	long			time_left;
>  
>  	/* Normally we will wait up to 5 seconds for any required
> @@ -654,15 +657,15 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  			xprt = ERR_PTR(-EAGAIN);
>  			goto out;
>  		}
> -		/* No data pending. Go to sleep */
> -		svc_thread_enqueue(pool, rqstp);
> -
>  		/*
>  		 * We have to be able to interrupt this wait
>  		 * to bring down the daemons ...
>  		 */
>  		set_current_state(TASK_INTERRUPTIBLE);
>  
> +		/* No data pending. Go to sleep */
> +		svc_thread_enqueue(pool, rqstp);
> +
>  		/*
>  		 * checking kthread_should_stop() here allows us to avoid
>  		 * locking and signalling when stopping kthreads that call
> @@ -676,14 +679,13 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  			goto out;
>  		}
>  
> -		add_wait_queue(&rqstp->rq_wait, &wait);
>  		spin_unlock_bh(&pool->sp_lock);
>  
>  		time_left = schedule_timeout(timeout);
> +		__set_current_state(TASK_RUNNING);
>  
>  		try_to_freeze();
>  
> -		remove_wait_queue(&rqstp->rq_wait, &wait);
>  		xprt = rqstp->rq_xprt;
>  		if (xprt != NULL)
>  			return xprt;
> @@ -786,10 +788,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  		printk(KERN_ERR
>  			"svc_recv: service %p, transport not NULL!\n",
>  			 rqstp);
> -	if (waitqueue_active(&rqstp->rq_wait))
> -		printk(KERN_ERR
> -			"svc_recv: service %p, wait queue active!\n",
> -			 rqstp);
> +
> +	/* Make sure the task pointer is set! */
> +	if (WARN_ON_ONCE(!rqstp->rq_task))
> +		rqstp->rq_task = current_task;
>  
>  	err = svc_alloc_arg(rqstp);
>  	if (err)
> -- 
> 1.9.3
> 

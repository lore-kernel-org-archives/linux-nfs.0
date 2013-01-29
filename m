Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35180 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276Ab3A2W5j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2013 17:57:39 -0500
Date: Tue, 29 Jan 2013 17:57:36 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [RFC PATCH] SUNRPC: protect transport processing with rw sem
Message-ID: <20130129225736.GC6219@fieldses.org>
References: <20130129110317.29541.51920.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130129110317.29541.51920.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29, 2013 at 02:03:30PM +0300, Stanislav Kinsbursky wrote:
> There could be a service transport, which is processed by service thread and
> racing in the same time with per-net service shutdown like listed below:
> 
> CPU#0:                            CPU#1:
> 
> svc_recv                        svc_close_net
> svc_get_next_xprt (list_del_init(xpt_ready))
>                             svc_close_list (set XPT_BUSY and XPT_CLOSE)
>                             svc_clear_pools(xprt was gained on CPU#0 already)
>                             svc_delete_xprt (set XPT_DEAD)
> svc_handle_xprt (is XPT_CLOSE => svc_delete_xprt()
> BUG()
> 
> There could be different solutions of the problem.
> Probably, the patch doesn't implement the best one, but I hope the simple one.
> IOW, it protects critical section (dequeuing of pending transport and
> enqueuing  it back to the pool) by per-service rw semaphore,

It's actually per-thread (per-struct svc_rqst) here.

> taken for read.
> On per-net transports shutdown, this semaphore have to be taken for write.

There's no down_write in this patch.  Did you forget this part?

The server rpc code goes to some care not to write to any global
structure, to prevent server threads running on multiple cores from
bouncing cache lines between them.

But my understanding is that even down_read() does modify the semaphore.
So we might want something like the percpu semaphore describe in
Documentation/percpu-rw-semaphore.txt.

--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  fs/nfs/callback.c          |    2 ++
>  include/linux/sunrpc/svc.h |    2 ++
>  net/sunrpc/svc.c           |    2 ++
>  net/sunrpc/svc_xprt.c      |   24 ++++++++++++++++++------
>  4 files changed, 24 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 5088b57..76ba260 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -393,7 +393,9 @@ void nfs_callback_down(int minorversion, struct net *net)
>  	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
>  
>  	mutex_lock(&nfs_callback_mutex);
> +	down_write(&cb_info->rqst->rq_sem);
>  	nfs_callback_down_net(minorversion, cb_info->serv, net);
> +	up_write(&cb_info->rqst->rq_sem);
>  	cb_info->users--;
>  	if (cb_info->users == 0 && cb_info->task != NULL) {
>  		kthread_stop(cb_info->task);
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 1f0216b..8145009 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -278,6 +278,8 @@ struct svc_rqst {
>  						 * cache pages */
>  	wait_queue_head_t	rq_wait;	/* synchronization */
>  	struct task_struct	*rq_task;	/* service thread */
> +
> +	struct rw_semaphore	rq_sem;
>  };
>  
>  #define SVC_NET(svc_rqst)	(svc_rqst->rq_xprt->xpt_net)
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index b9ba2a8..71a53c1 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -642,6 +642,8 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
>  	if (!svc_init_buffer(rqstp, serv->sv_max_mesg, node))
>  		goto out_thread;
>  
> +	init_rwsem(&rqstp->rq_sem);
> +
>  	return rqstp;
>  out_thread:
>  	svc_exit_thread(rqstp);
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 5a9d40c..e75b20c 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -470,6 +470,7 @@ static void svc_xprt_release(struct svc_rqst *rqstp)
>  	rqstp->rq_res.head[0].iov_len = 0;
>  	svc_reserve(rqstp, 0);
>  	rqstp->rq_xprt = NULL;
> +	up_read(&rqstp->rq_sem);
>  
>  	svc_xprt_put(xprt);
>  }
> @@ -624,6 +625,7 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  	 */
>  	rqstp->rq_chandle.thread_wait = 5*HZ;
>  
> +	down_read(&rqstp->rq_sem);
>  	spin_lock_bh(&pool->sp_lock);
>  	xprt = svc_xprt_dequeue(pool);
>  	if (xprt) {
> @@ -640,7 +642,8 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  		if (pool->sp_task_pending) {
>  			pool->sp_task_pending = 0;
>  			spin_unlock_bh(&pool->sp_lock);
> -			return ERR_PTR(-EAGAIN);
> +			xprt = ERR_PTR(-EAGAIN);
> +			goto out_err;
>  		}
>  		/* No data pending. Go to sleep */
>  		svc_thread_enqueue(pool, rqstp);
> @@ -661,16 +664,19 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  		if (kthread_should_stop()) {
>  			set_current_state(TASK_RUNNING);
>  			spin_unlock_bh(&pool->sp_lock);
> -			return ERR_PTR(-EINTR);
> +			xprt = ERR_PTR(-EINTR);
> +			goto out_err;
>  		}
>  
>  		add_wait_queue(&rqstp->rq_wait, &wait);
>  		spin_unlock_bh(&pool->sp_lock);
> +		up_read(&rqstp->rq_sem);
>  
>  		time_left = schedule_timeout(timeout);
>  
>  		try_to_freeze();
>  
> +		down_read(&rqstp->rq_sem);
>  		spin_lock_bh(&pool->sp_lock);
>  		remove_wait_queue(&rqstp->rq_wait, &wait);
>  		if (!time_left)
> @@ -681,13 +687,19 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  			svc_thread_dequeue(pool, rqstp);
>  			spin_unlock_bh(&pool->sp_lock);
>  			dprintk("svc: server %p, no data yet\n", rqstp);
> -			if (signalled() || kthread_should_stop())
> -				return ERR_PTR(-EINTR);
> -			else
> -				return ERR_PTR(-EAGAIN);
> +			if (signalled() || kthread_should_stop()) {
> +				xprt = ERR_PTR(-EINTR);
> +				goto out_err;
> +			} else {
> +				xprt = ERR_PTR(-EAGAIN);
> +				goto out_err;
> +			}
>  		}
>  	}
>  	spin_unlock_bh(&pool->sp_lock);
> +out_err:
> +	if (IS_ERR(xprt))
> +		up_read(&rqstp->rq_sem);
>  	return xprt;
>  }
>  
> 

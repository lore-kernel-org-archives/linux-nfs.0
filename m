Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52054 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934757AbdDZU3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Apr 2017 16:29:03 -0400
Date: Wed, 26 Apr 2017 16:29:01 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH 2/2] NFSv4: Fix callback server shutdown
Message-ID: <20170426202900.GC4034@parsley.fieldses.org>
References: <20170426155527.92213-1-trond.myklebust@primarydata.com>
 <20170426155527.92213-2-trond.myklebust@primarydata.com>
 <20170426155527.92213-3-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170426155527.92213-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:55:27AM -0400, Trond Myklebust wrote:
> We want to use kthread_stop() in order to ensure the threads are
> shut down before we tear down the nfs_callback_info in nfs_callback_down.
> 
> Reported-by: Kinglong Mee <kinglongmee@gmail.com>
> Fixes: bb6aeba736ba9 ("NFSv4.x: Switch to using svc_set_num_threads()...")
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Cc: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfs/callback.c          | 24 ++++++++++++++++--------
>  include/linux/sunrpc/svc.h |  1 +
>  net/sunrpc/svc.c           | 38 ++++++++++++++++++++++++++++++++++++++
>  3 files changed, 55 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 773774531aff..8cabae9b140e 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -76,7 +76,10 @@ nfs4_callback_svc(void *vrqstp)
>  
>  	set_freezable();
>  
> -	while (!kthread_should_stop()) {
> +	while (!kthread_freezable_should_stop(NULL)) {

OK, I looked quickly at the comments for those two calls
(kthread_should_stop and kthread_freezable_should_stop) and don't
completely understand the difference.  In any case, what does that
change have to do with this patch?

Patches make sense to me otherwise, shall I take them?

--b.

> +
> +		if (signal_pending(current))
> +			flush_signals(current);
>  		/*
>  		 * Listen for a request on the socket
>  		 */
> @@ -85,6 +88,8 @@ nfs4_callback_svc(void *vrqstp)
>  			continue;
>  		svc_process(rqstp);
>  	}
> +	svc_exit_thread(rqstp);
> +	module_put_and_exit(0);
>  	return 0;
>  }
>  
> @@ -103,9 +108,10 @@ nfs41_callback_svc(void *vrqstp)
>  
>  	set_freezable();
>  
> -	while (!kthread_should_stop()) {
> -		if (try_to_freeze())
> -			continue;
> +	while (!kthread_freezable_should_stop(NULL)) {
> +
> +		if (signal_pending(current))
> +			flush_signals(current);
>  
>  		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_INTERRUPTIBLE);
>  		spin_lock_bh(&serv->sv_cb_lock);
> @@ -121,11 +127,13 @@ nfs41_callback_svc(void *vrqstp)
>  				error);
>  		} else {
>  			spin_unlock_bh(&serv->sv_cb_lock);
> -			schedule();
> +			if (!kthread_should_stop())
> +				schedule();
>  			finish_wait(&serv->sv_cb_waitq, &wq);
>  		}
> -		flush_signals(current);
>  	}
> +	svc_exit_thread(rqstp);
> +	module_put_and_exit(0);
>  	return 0;
>  }
>  
> @@ -221,14 +229,14 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
>  static struct svc_serv_ops nfs40_cb_sv_ops = {
>  	.svo_function		= nfs4_callback_svc,
>  	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
> -	.svo_setup		= svc_set_num_threads,
> +	.svo_setup		= svc_set_num_threads_sync,
>  	.svo_module		= THIS_MODULE,
>  };
>  #if defined(CONFIG_NFS_V4_1)
>  static struct svc_serv_ops nfs41_cb_sv_ops = {
>  	.svo_function		= nfs41_callback_svc,
>  	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
> -	.svo_setup		= svc_set_num_threads,
> +	.svo_setup		= svc_set_num_threads_sync,
>  	.svo_module		= THIS_MODULE,
>  };
>  
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index e770abeed32d..11cef5a7bc87 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -474,6 +474,7 @@ void		   svc_pool_map_put(void);
>  struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
>  			struct svc_serv_ops *);
>  int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
> +int		   svc_set_num_threads_sync(struct svc_serv *, struct svc_pool *, int);
>  int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
>  void		   svc_destroy(struct svc_serv *);
>  void		   svc_shutdown_net(struct svc_serv *, struct net *);
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 98dc33ae738b..bc0f5a0ecbdc 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -795,6 +795,44 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
>  }
>  EXPORT_SYMBOL_GPL(svc_set_num_threads);
>  
> +/* destroy old threads */
> +static int
> +svc_stop_kthreads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
> +{
> +	struct task_struct *task;
> +	unsigned int state = serv->sv_nrthreads-1;
> +
> +	/* destroy old threads */
> +	do {
> +		task = choose_victim(serv, pool, &state);
> +		if (task == NULL)
> +			break;
> +		kthread_stop(task);
> +		nrservs++;
> +	} while (nrservs < 0);
> +	return 0;
> +}
> +
> +int
> +svc_set_num_threads_sync(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
> +{
> +	if (pool == NULL) {
> +		/* The -1 assumes caller has done a svc_get() */
> +		nrservs -= (serv->sv_nrthreads-1);
> +	} else {
> +		spin_lock_bh(&pool->sp_lock);
> +		nrservs -= pool->sp_nrthreads;
> +		spin_unlock_bh(&pool->sp_lock);
> +	}
> +
> +	if (nrservs > 0)
> +		return svc_start_kthreads(serv, pool, nrservs);
> +	if (nrservs < 0)
> +		return svc_stop_kthreads(serv, pool, nrservs);
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(svc_set_num_threads_sync);
> +
>  /*
>   * Called from a server thread as it's exiting. Caller must hold the "service
>   * mutex" for the service.
> -- 
> 2.9.3
> 

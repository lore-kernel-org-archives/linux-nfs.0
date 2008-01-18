From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/4] SUNRPC: spin svc_rqst initialization to its own
	function
Date: Fri, 18 Jan 2008 15:59:43 -0500
Message-ID: <20080118205943.GL15158@fieldses.org>
References: <1200319518-22422-1-git-send-email-jlayton@redhat.com> <1200319518-22422-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60134 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761821AbYARU7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 15:59:47 -0500
In-Reply-To: <1200319518-22422-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 14, 2008 at 09:05:15AM -0500, Jeff Layton wrote:
> Move the initialzation in __svc_create_thread that happens prior to
> thread creation to a new function. Export the function to allow
> services to have better control over the svc_rqst structs.
> 
> Also rearrange the rqstp initialization to prevent NULL pointer
> dereferences in svc_exit_thread in case allocations fail.

Those NULL dereferences are from the

	list_del(&rqstp->rq_all);

?  OK, make sense.  Thanks!

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/sunrpc/svc.h |    2 +
>  net/sunrpc/svc.c           |   59 +++++++++++++++++++++++++++++++------------
>  2 files changed, 44 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 8531a70..5f07300 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -382,6 +382,8 @@ struct svc_procedure {
>   */
>  struct svc_serv *  svc_create(struct svc_program *, unsigned int,
>  			      void (*shutdown)(struct svc_serv*));
> +struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
> +					struct svc_pool *pool);
>  int		   svc_create_thread(svc_thread_fn, struct svc_serv *);
>  void		   svc_exit_thread(struct svc_rqst *);
>  struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index fca17d0..f9636bf 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -538,31 +538,17 @@ svc_release_buffer(struct svc_rqst *rqstp)
>  			put_page(rqstp->rq_pages[i]);
>  }
>  
> -/*
> - * Create a thread in the given pool.  Caller must hold BKL.
> - * On a NUMA or SMP machine, with a multi-pool serv, the thread
> - * will be restricted to run on the cpus belonging to the pool.
> - */
> -static int
> -__svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
> -		    struct svc_pool *pool)
> +struct svc_rqst *
> +svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool)
>  {
>  	struct svc_rqst	*rqstp;
> -	int		error = -ENOMEM;
> -	int		have_oldmask = 0;
> -	cpumask_t	oldmask;
>  
>  	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
>  	if (!rqstp)
> -		goto out;
> +		goto out_enomem;
>  
>  	init_waitqueue_head(&rqstp->rq_wait);
>  
> -	if (!(rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
> -	 || !(rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
> -	 || !svc_init_buffer(rqstp, serv->sv_max_mesg))
> -		goto out_thread;
> -
>  	serv->sv_nrthreads++;
>  	spin_lock_bh(&pool->sp_lock);
>  	pool->sp_nrthreads++;
> @@ -571,6 +557,45 @@ __svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
>  	rqstp->rq_server = serv;
>  	rqstp->rq_pool = pool;
>  
> +	rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL);
> +	if (!rqstp->rq_argp)
> +		goto out_thread;
> +
> +	rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL);
> +	if (!rqstp->rq_resp)
> +		goto out_thread;
> +
> +	if (!svc_init_buffer(rqstp, serv->sv_max_mesg))
> +		goto out_thread;
> +
> +	return rqstp;
> +out_thread:
> +	svc_exit_thread(rqstp);
> +out_enomem:
> +	return ERR_PTR(-ENOMEM);
> +}
> +EXPORT_SYMBOL(svc_prepare_thread);
> +
> +/*
> + * Create a thread in the given pool.  Caller must hold BKL.
> + * On a NUMA or SMP machine, with a multi-pool serv, the thread
> + * will be restricted to run on the cpus belonging to the pool.
> + */
> +static int
> +__svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
> +		    struct svc_pool *pool)
> +{
> +	struct svc_rqst	*rqstp;
> +	int		error = -ENOMEM;
> +	int		have_oldmask = 0;
> +	cpumask_t	oldmask;
> +
> +	rqstp = svc_prepare_thread(serv, pool);
> +	if (IS_ERR(rqstp)) {
> +		error = PTR_ERR(rqstp);
> +		goto out;
> +	}
> +
>  	if (serv->sv_nrpools > 1)
>  		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
>  
> -- 
> 1.5.3.7
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

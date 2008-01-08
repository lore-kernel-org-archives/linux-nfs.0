From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/6] SUNRPC: spin svc_rqst initialization to its own function
Date: Tue, 8 Jan 2008 16:53:09 +1100
Message-ID: <18307.4037.415675.519239@notabene.brown>
References: <1199534542-3384-1-git-send-email-jlayton@redhat.com>
	<1199534542-3384-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:37946 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754247AbYAHFxT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 00:53:19 -0500
In-Reply-To: message from Jeff Layton on Saturday January 5
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday January 5, jlayton@redhat.com wrote:
> Move the initialzation in __svc_create_thread that happens prior to
> thread creation to a new function. Export the function to allow
> services to have better control over the svc_rqst structs.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/sunrpc/svc.h |    2 ++
>  net/sunrpc/svc.c           |   43 +++++++++++++++++++++++++++++++------------
>  2 files changed, 33 insertions(+), 12 deletions(-)
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
> index fca17d0..b29ed43 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -538,23 +538,14 @@ svc_release_buffer(struct svc_rqst *rqstp)
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
> @@ -570,6 +561,34 @@ __svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
>  	spin_unlock_bh(&pool->sp_lock);
>  	rqstp->rq_server = serv;
>  	rqstp->rq_pool = pool;
> +	return rqstp;
> +
> +out_thread:
> +	svc_exit_thread(rqstp);

I realise that the bug existed before your change, but calling
svc_exit_thread at this point is not good.
The 'goto out_thread' is *before* "pool->sp_nrthreads++", but
svc_exit_thread does "pool->sp_nrthreads--;".  Not good.

As you are playing is this code, do you feel like fixing that error
path??


Otherwise, patch looks good.
Acked-By: NeilBrown <neilb@suse.de>

Thanks,
NeilBrown

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34342 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753819Ab3ADAxs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2013 19:53:48 -0500
Date: Thu, 3 Jan 2013 19:53:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andriy Skulysh <andriy_skulysh@xyratex.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/1] sunrpc: Fix lockd sleeping until timeout
Message-ID: <20130104005345.GA4407@fieldses.org>
References: <CADug+U6-=+_Xy41Lw3hnOqSR84Bo7MjKDL_PykiZVdUx=b8tAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CADug+U6-=+_Xy41Lw3hnOqSR84Bo7MjKDL_PykiZVdUx=b8tAA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 26, 2012 at 05:09:07PM +0200, Andriy Skulysh wrote:
> There is a race in enqueueing thread to a pool and
> waking up a thread.
> lockd doesn't wake up on reception of lock granted callback
> if svc_wake_up() is called before lockd's thread is added
> to a pool.
> 
> Signed-off-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
> ---
>  include/linux/sunrpc/svc.h |    1 +
>  net/sunrpc/svc_xprt.c      |    9 ++++++++-
>  2 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 676ddf5..1f0216b 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -50,6 +50,7 @@ struct svc_pool {
>  	unsigned int		sp_nrthreads;	/* # of threads in pool */
>  	struct list_head	sp_all_threads;	/* all server threads */
>  	struct svc_pool_stats	sp_stats;	/* statistics on pool operation */
> +	int			sp_task_pending;/* has pending task */
>  } ____cacheline_aligned_in_smp;
> 
>  /*
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index b8e47fa..c7ab6f5 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -499,7 +499,8 @@ void svc_wake_up(struct svc_serv *serv)
>  			rqstp->rq_xprt = NULL;
>  			 */
>  			wake_up(&rqstp->rq_wait);
> -		}
> +		} else
> +			pool->sp_task_pending = 1;
>  		spin_unlock_bh(&pool->sp_lock);
>  	}
>  }
> @@ -634,7 +635,13 @@ struct svc_xprt *svc_get_next_xprt(struct
> svc_rqst *rqstp, long timeout)
>  		 * long for cache updates.
>  		 */
>  		rqstp->rq_chandle.thread_wait = 1*HZ;
> +		pool->sp_task_pending = 0;
>  	} else {
> +		if (pool->sp_task_pending) {
> +			pool->sp_task_pending = 0;
> +			spin_unlock_bh(&pool->sp_lock);
> +			return -EAGAIN;

That should be ERR_PTR(-EAGAIN).

Other than this this looks right to me....

Out of curiosity: how did you run across this problem, and how did you
test the fix?

--b.

> +		}
>  		/* No data pending. Go to sleep */
>  		svc_thread_enqueue(pool, rqstp);
> 
> -- 
> 1.7.1

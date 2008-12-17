From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 3/3] SUNRPC: svc_xprt_enqueue should not refuse to enqueue
 'XPT_DEAD' transports
Date: Wed, 17 Dec 2008 09:35:52 -0600
Message-ID: <49491C58.9@opengridcomputing.com>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>	 <1224484046.23068.14.camel@localhost.localdomain>	 <1225539927.2221.3.camel@localhost.localdomain>	 <1225546878.4390.3.camel@heimdal.trondhjem.org>	 <1227596962.16868.22.camel@localhost.localdomain>	 <1227619696.7057.19.camel@heimdal.trondhjem.org>	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>	 <1227621434.7057.33.camel@heimdal.trondhjem.org>	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>	 <1227737539.31008.2.camel@localhost.localdomain>	 <1228090631.7112.11.camel@heimdal.trondhjem.org> <1228090815.7112.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Ian Campbell <ijc@hellion.org.uk>, linux-nfs@vger.kernel.org,
	Max Kellermann <mk@cm4all.com>, linux-kernel@vger.kernel.org,
	gcosta@redhat.com, Grant Coady <grant_lkml@dodo.com.au>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754146AbYLQPgK@vger.kernel.org>
In-Reply-To: <1228090815.7112.15.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> Aside from being racy (there is nothing preventing someone setting XPT_DEAD
> after the test in svc_xprt_enqueue, and before XPT_BUSY is set), it is
> wrong to assume that transports which have called svc_delete_xprt() might
> not need to be re-enqueued.

This is only true because now you allow transports with XPT_DEAD set to 
be enqueued -- yes?

> 
> See the list of deferred requests, which is currently never going to
> be cleared if the revisit call happens after svc_delete_xprt(). In this
> case, the deferred request will currently keep a reference to the transport
> forever.
>

I agree this is a possibility and it needs to be fixed. I'm concerned 
that the root cause is still there though. I thought the test case was 
the client side timing out the connection. Why are there deferred 
requests sitting on what is presumably an idle connection?


> The fix should be to allow dead transports to be enqueued in order to clear
> the deferred requests, then change the order of processing in svc_recv() so
> that we pick up deferred requests before we do the XPT_CLOSE processing.
> 

Wouldn't it be simpler to clean up any deferred requests in the close 
path instead of changing the meaning of XPT_DEAD and dispatching 
N-threads to do the same?

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  net/sunrpc/svc_xprt.c |  124 +++++++++++++++++++++++++++----------------------
>  1 files changed, 69 insertions(+), 55 deletions(-)
> 
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index a417064..b54cf84 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -297,10 +297,15 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
>  	struct svc_serv	*serv = xprt->xpt_server;
>  	struct svc_pool *pool;
>  	struct svc_rqst	*rqstp;
> +	unsigned long flags;
>  	int cpu;
>  
> -	if (!(xprt->xpt_flags &
> -	      ((1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED))))
> +	flags = xprt->xpt_flags &
> +		(1UL<<XPT_CONN | 1UL<<XPT_DATA | 1UL<<XPT_CLOSE |
> +		 1UL<<XPT_DEAD | 1UL<<XPT_DEFERRED);
> +	if (flags == 0)
> +		return;
> +	if ((flags & 1UL<<XPT_DEAD) != 0 && (flags & 1UL<<XPT_DEFERRED) == 0)
>  		return;
>  
>  	cpu = get_cpu();
> @@ -315,12 +320,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
>  		       "svc_xprt_enqueue: "
>  		       "threads and transports both waiting??\n");
>  
> -	if (test_bit(XPT_DEAD, &xprt->xpt_flags)) {
> -		/* Don't enqueue dead transports */
> -		dprintk("svc: transport %p is dead, not enqueued\n", xprt);
> -		goto out_unlock;
> -	}
> -
>  	/* Mark transport as busy. It will remain in this state until
>  	 * the provider calls svc_xprt_received. We update XPT_BUSY
>  	 * atomically because it also guards against trying to enqueue
> @@ -566,6 +565,7 @@ static void svc_check_conn_limits(struct svc_serv *serv)
>  int svc_recv(struct svc_rqst *rqstp, long timeout)
>  {
>  	struct svc_xprt		*xprt = NULL;
> +	struct svc_xprt		*newxpt;
>  	struct svc_serv		*serv = rqstp->rq_server;
>  	struct svc_pool		*pool = rqstp->rq_pool;
>  	int			len, i;
> @@ -673,62 +673,76 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  	spin_unlock_bh(&pool->sp_lock);
>  
>  	len = 0;
> +
> +	/*
> +	 * Deal with deferred requests first, since they need to be
> +	 * dequeued and dropped if the transport has been closed.
> +	 */
> +	rqstp->rq_deferred = svc_deferred_dequeue(xprt);
> +	if (rqstp->rq_deferred) {
> +		svc_xprt_received(xprt);
> +		len = svc_deferred_recv(rqstp);
> +	}
> +
>  	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
>  		dprintk("svc_recv: found XPT_CLOSE\n");
>  		svc_delete_xprt(xprt);
> -	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
> -		struct svc_xprt *newxpt;
> -		newxpt = xprt->xpt_ops->xpo_accept(xprt);
> -		if (newxpt) {
> -			/*
> -			 * We know this module_get will succeed because the
> -			 * listener holds a reference too
> -			 */
> -			__module_get(newxpt->xpt_class->xcl_owner);
> -			svc_check_conn_limits(xprt->xpt_server);
> -			spin_lock_bh(&serv->sv_lock);
> -			set_bit(XPT_TEMP, &newxpt->xpt_flags);
> -			list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
> -			serv->sv_tmpcnt++;
> -			if (serv->sv_temptimer.function == NULL) {
> -				/* setup timer to age temp transports */
> -				setup_timer(&serv->sv_temptimer,
> -					    svc_age_temp_xprts,
> -					    (unsigned long)serv);
> -				mod_timer(&serv->sv_temptimer,
> -					  jiffies + svc_conn_age_period * HZ);
> -			}
> -			spin_unlock_bh(&serv->sv_lock);
> -			svc_xprt_received(newxpt);
> -		}
> -		svc_xprt_received(xprt);
> -	} else {
> -		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
> -			rqstp, pool->sp_id, xprt,
> -			atomic_read(&xprt->xpt_ref.refcount));
> -		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
> -		if (rqstp->rq_deferred) {
> -			svc_xprt_received(xprt);
> -			len = svc_deferred_recv(rqstp);
> -		} else
> +		goto drop_request;
> +	}
> +
> +	if (!test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
> +		if (len == 0) {
> +			dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
> +					rqstp, pool->sp_id, xprt,
> +					atomic_read(&xprt->xpt_ref.refcount));
>  			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
> +
> +			/* No data, incomplete (TCP) read, or accept() */
> +			if (len == 0 || len == -EAGAIN)
> +				goto drop_request;
> +		}
> +
>  		dprintk("svc: got len=%d\n", len);
> -	}
>  
> -	/* No data, incomplete (TCP) read, or accept() */
> -	if (len == 0 || len == -EAGAIN) {
> -		rqstp->rq_res.len = 0;
> -		svc_xprt_release(rqstp);
> -		return -EAGAIN;
> +		clear_bit(XPT_OLD, &xprt->xpt_flags);
> +
> +		rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
> +		rqstp->rq_chandle.defer = svc_defer;
> +
> +		if (serv->sv_stats)
> +			serv->sv_stats->netcnt++;
> +		return len;
>  	}
> -	clear_bit(XPT_OLD, &xprt->xpt_flags);
>  
> -	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
> -	rqstp->rq_chandle.defer = svc_defer;
> +	newxpt = xprt->xpt_ops->xpo_accept(xprt);
> +	if (newxpt) {
> +		/*
> +		 * We know this module_get will succeed because the
> +		 * listener holds a reference too
> +		 */
> +		__module_get(newxpt->xpt_class->xcl_owner);
> +		svc_check_conn_limits(xprt->xpt_server);
> +		spin_lock_bh(&serv->sv_lock);
> +		set_bit(XPT_TEMP, &newxpt->xpt_flags);
> +		list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
> +		serv->sv_tmpcnt++;
> +		if (serv->sv_temptimer.function == NULL) {
> +			/* setup timer to age temp transports */
> +			setup_timer(&serv->sv_temptimer,
> +				    svc_age_temp_xprts,
> +				    (unsigned long)serv);
> +			mod_timer(&serv->sv_temptimer,
> +				  jiffies + svc_conn_age_period * HZ);
> +		}
> +		spin_unlock_bh(&serv->sv_lock);
> +		svc_xprt_received(newxpt);
> +	}
> +	svc_xprt_received(xprt);
>  
> -	if (serv->sv_stats)
> -		serv->sv_stats->netcnt++;
> -	return len;
> +drop_request:
> +	rqstp->rq_res.len = 0;
> +	svc_xprt_release(rqstp);
> +	return -EAGAIN;
>  }
>  EXPORT_SYMBOL(svc_recv);
>  
> 

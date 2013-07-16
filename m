Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34388 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932346Ab3GPOYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jul 2013 10:24:32 -0400
Date: Tue, 16 Jul 2013 10:24:30 -0400
From: "J.Bruce Fields" <bfields@citi.umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, NFS <linux-nfs@vger.kernel.org>,
        Ben Myers <bpm@sgi.com>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130716142430.GA11977@fieldses.org>
References: <20130710092255.0240a36d@notabene.brown>
 <20130710022735.GI8281@fieldses.org>
 <20130710143233.77e35721@notabene.brown>
 <20130710190727.GA22305@fieldses.org>
 <20130715143203.51bc583b@notabene.brown>
 <20130716015803.GA5271@fieldses.org>
 <20130716140021.312b5b07@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130716140021.312b5b07@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding Ben Myers to Cc: in case he has any testing help or advice (see
below):

On Tue, Jul 16, 2013 at 02:00:21PM +1000, NeilBrown wrote:
> That would be because I only allowed extra requests up to half the number of
> idle threads, and there would be zero idle threads.
> 
> So yes - I see your point.
> 
> I now think that it is sufficient to just allow one request through per
> socket.  While there is high memory pressure, that is sufficient.  When the
> memory pressure drops, that should be enough to cause sndbuf to grow.
> 
> We should be able to use xpt_reserved to check if this is the only request
> or not: 

A remaining possible bad case is if the number of "bad" sockets is more
than the number of threads, and if the problem is something that won't
resolve itself by just waiting a little while.

I don't know if that's likely in practice.  Maybe a network failure cuts
you off from a large swath (but not all) of your clients?  Or maybe some
large proportion of your clients are just slow?

But this is two lines and looks likely to solve the immediate
problem:

> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 80a6640..5b832ef 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -331,7 +331,8 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
>  	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
>  		return true;
>  	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED)))
> -		return xprt->xpt_ops->xpo_has_wspace(xprt);
> +		return xprt->xpt_ops->xpo_has_wspace(xprt) ||
> +			atomic_read(&xprt->xpt_reserved) == 0;
>  	return false;
>  }
>  
> @@ -730,7 +731,8 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  		newxpt = xprt->xpt_ops->xpo_accept(xprt);
>  		if (newxpt)
>  			svc_add_new_temp_xprt(serv, newxpt);
> -	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
> +	} else if (xprt->xpt_ops->xpo_has_wspace(xprt) ||
> +		   atomic_read(&xprt->xpt_reserved) == 0) {
>  		/* XPT_DATA|XPT_DEFERRED case: */
>  		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
>  			rqstp, rqstp->rq_pool->sp_id, xprt,
> 
> 
> Thoughts?
> 
> I tried testing this, but xpo_has_wspace never fails for me, even if I remove
> the calls to svc_sock_setbufsize (which probably aren't wanted for TCP any
> more).

Ben, do you still have a setup that can reproduce the problem?  Or did
you ever find an easier way to reproduce?

--b.

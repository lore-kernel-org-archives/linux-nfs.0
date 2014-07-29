Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45104 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680AbaG2Tbi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jul 2014 15:31:38 -0400
Date: Tue, 29 Jul 2014 15:31:08 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org
Subject: Re: [PATCH 1/3] SUNRPC: Reduce contention in svc_xprt_enqueue()
Message-ID: <20140729193108.GC21091@fieldses.org>
References: <1406260773-16231-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406260773-16231-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All three patches look good to me, thanks.

>From private email, this:

On Thu, Jul 24, 2014 at 11:59:31PM -0400, Trond Myklebust wrote:
> @@ -222,11 +223,12 @@ static void svc_xprt_received(struct svc_xprt *xprt)
>  	if (!test_bit(XPT_BUSY, &xprt->xpt_flags))
>  		return;
>  	/* As soon as we clear busy, the xprt could be closed and
> -	 * 'put', so we need a reference to call svc_xprt_enqueue with:
> +	 * 'put', so we need a reference to call svc_xprt_do_enqueue with:
>  	 */
>  	svc_xprt_get(xprt);
> +	smp_mb__before_clear_bit();

triggered a warning about smp_mb__before_clear_bit noticed by the kbuild
robot.  Looks like that was due to
febdbfe8a91ce0d11939d4940b592eb0dba8d663 "arch: Prepare for
smp_mb__{before,after}_atomic()".

You questioned whether deprecating smp_mb__{before,after}_clear_bit was
an unnecessary burden on people maintaining stable kernels or doing
backports more generally.  Cc'ing some addresses from that commit.

Whatever--I'll probably just replace do the clear_bit->before_atomic
replacement and apply unless there's some objection.

--b.

>  	clear_bit(XPT_BUSY, &xprt->xpt_flags);
> -	svc_xprt_enqueue(xprt);
> +	svc_xprt_do_enqueue(xprt);
>  	svc_xprt_put(xprt);
>  }
>  
> @@ -335,12 +337,7 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
>  	return false;
>  }
>  
> -/*
> - * Queue up a transport with data pending. If there are idle nfsd
> - * processes, wake 'em up.
> - *
> - */
> -void svc_xprt_enqueue(struct svc_xprt *xprt)
> +static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
>  {
>  	struct svc_pool *pool;
>  	struct svc_rqst	*rqstp;
> @@ -398,6 +395,18 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
>  out_unlock:
>  	spin_unlock_bh(&pool->sp_lock);
>  }
> +
> +/*
> + * Queue up a transport with data pending. If there are idle nfsd
> + * processes, wake 'em up.
> + *
> + */
> +void svc_xprt_enqueue(struct svc_xprt *xprt)
> +{
> +	if (test_bit(XPT_BUSY, &xprt->xpt_flags))
> +		return;
> +	svc_xprt_do_enqueue(xprt);
> +}
>  EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
>  
>  /*
> -- 
> 1.9.3
> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32878 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756618Ab2HTWtS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 18:49:18 -0400
Date: Mon, 20 Aug 2012 18:49:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: Michael Tokarev <mjt@tls.msk.ru>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] svcrpc: fix svc_xprt_enqueue/svc_recv busy-looping
Message-ID: <20120820224915.GM5779@fieldses.org>
References: <20120820223746.GL5779@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120820223746.GL5779@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 20, 2012 at 06:37:47PM -0400, bfields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> The rpc server tries to ensure that there will be room to send a reply
> before it receives a request.
> 
> It does this by tracking, in xpt_reserved, an upper bound on the total
> size of the replies that is has already committed to for the socket.
> 
> Currently it is adding in the estimate for a new reply *before* it
> checks whether there is space available.  If it finds that there is not
> space, it then subtracts the estimate back out.
> 
> This may lead the subsequent svc_xprt_enqueue to decide that there is
> space after all.
> 
> The results is a svc_recv() that will repeatedly return -EAGAIN, causing
> server threads to loop without doing any actual work.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Michael Tokarev <mjt@tls.msk.ru>
> Tested-by: Michael Tokarev <mjt@tls.msk.ru>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  net/sunrpc/svc_xprt.c |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> Queuing up for 3.6 absent any objections.--b.

By the way, one thing I'm still curious about is how this got
introduced.  mjt bisected it to f03d78db65085609938fdb686238867e65003181
"net: refine {udp|tcp|sctp}_mem limits", which looks like it just made
the problem a little more likely.

The last substantive change to has_wspace logic was Trond's
47fcb03fefee2501e79176932a4184fc24d6f8ec, but I have a tough time
figuring out whether that would have affected it one way or the other.

As far as I can tell we've always added to xpt_reserved in this way, so
that svc_recv and svc_xprt_enqueue are comparing different things, and
surely this was always wrong even if the problem must have been harder
to trigger before.

But some of the wspace logic I don't understand, so cc'ing Neil and
Trond in case they see any other problem I missed.

--b.

> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 0d693a8..bac973a 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -316,7 +316,6 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
>   */
>  void svc_xprt_enqueue(struct svc_xprt *xprt)
>  {
> -	struct svc_serv	*serv = xprt->xpt_server;
>  	struct svc_pool *pool;
>  	struct svc_rqst	*rqstp;
>  	int cpu;
> @@ -362,8 +361,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
>  				rqstp, rqstp->rq_xprt);
>  		rqstp->rq_xprt = xprt;
>  		svc_xprt_get(xprt);
> -		rqstp->rq_reserved = serv->sv_max_mesg;
> -		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
>  		pool->sp_stats.threads_woken++;
>  		wake_up(&rqstp->rq_wait);
>  	} else {
> @@ -640,8 +637,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  	if (xprt) {
>  		rqstp->rq_xprt = xprt;
>  		svc_xprt_get(xprt);
> -		rqstp->rq_reserved = serv->sv_max_mesg;
> -		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
>  
>  		/* As there is a shortage of threads and this request
>  		 * had to be queued, don't allow the thread to wait so
> @@ -738,6 +733,8 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>  		else
>  			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
>  		dprintk("svc: got len=%d\n", len);
> +		rqstp->rq_reserved = serv->sv_max_mesg;
> +		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
>  	}
>  	svc_xprt_received(xprt);
>  
> -- 
> 1.7.9.5
> 

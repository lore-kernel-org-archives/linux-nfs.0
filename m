Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:43590 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751623AbdJTPGx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 11:06:53 -0400
Date: Fri, 20 Oct 2017 16:06:53 +0100
From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Remove redundant call to cancel_work_sync() in
 xprt_destroy()
Message-ID: <20171020150653.GA21501@red-moon>
References: <20171011180134.52476-1-trond.myklebust@primarydata.com>
 <20171012134730.GA4803@red-moon>
 <1508438956.72950.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1508438956.72950.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 06:49:18PM +0000, Trond Myklebust wrote:
> On Thu, 2017-10-12 at 14:47 +0100, Lorenzo Pieralisi wrote:
> > Hi Trond,
> > 
> > On Wed, Oct 11, 2017 at 02:01:34PM -0400, Trond Myklebust wrote:
> > > We know that the socket autoclose cannot be queued after we've set
> > > the XPRT_LOCKED bit, so the call to cancel_work_sync() is
> > > redundant.
> > > In addition, it is causing lockdep to complain about a false ABA
> > > lock dependency.
> > > 
> > > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > > ---
> > >  net/sunrpc/xprt.c | 1 -
> > >  1 file changed, 1 deletion(-)
> > > 
> > > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > > index e741ec2b4d8e..5f12fe145f02 100644
> > > --- a/net/sunrpc/xprt.c
> > > +++ b/net/sunrpc/xprt.c
> > > @@ -1464,7 +1464,6 @@ static void xprt_destroy(struct rpc_xprt
> > > *xprt)
> > >  	rpc_destroy_wait_queue(&xprt->pending);
> > >  	rpc_destroy_wait_queue(&xprt->sending);
> > >  	rpc_destroy_wait_queue(&xprt->backlog);
> > > -	cancel_work_sync(&xprt->task_cleanup);
> > 
> > This does not make the lockdep warning go away, actually the lockdep
> > is triggered by the xs_destroy() cancel_work_sync() call but I do not
> > know this code path so I can't really comment on it, let me know if
> > there is any specific test I can carry out.
> > 
> > Thanks for looking into this,
> > Lorenzo
> 
> Sorry for the delay. Does this one help?

Thank you.

Yes it does (on top of -rc5) - I get no lockdep warning anymore.

Lorenzo
 
> 8<----------------------------------
> From 528fd3547bad0bdd31c8f987e5bd00c83df8af39 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 19 Oct 2017 12:13:10 -0400
> Subject: [PATCH] SUNRPC: Destroy transport from the system workqueue
> 
> The transport may need to flush transport connect and receive tasks
> that are running on rpciod. In order to do so safely, we need to
> ensure that the caller of cancel_work_sync() etc is not itself
> running on rpciod.
> Do so by running the destroy task from the system workqueue.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprt.c | 34 ++++++++++++++++++++++++----------
>  1 file changed, 24 insertions(+), 10 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 1a39ad14c42f..898485e3ece4 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1445,6 +1445,23 @@ struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
>  	return xprt;
>  }
>  
> +static void xprt_destroy_cb(struct work_struct *work)
> +{
> +	struct rpc_xprt *xprt =
> +		container_of(work, struct rpc_xprt, task_cleanup);
> +
> +	rpc_xprt_debugfs_unregister(xprt);
> +	rpc_destroy_wait_queue(&xprt->binding);
> +	rpc_destroy_wait_queue(&xprt->pending);
> +	rpc_destroy_wait_queue(&xprt->sending);
> +	rpc_destroy_wait_queue(&xprt->backlog);
> +	kfree(xprt->servername);
> +	/*
> +	 * Tear down transport state and free the rpc_xprt
> +	 */
> +	xprt->ops->destroy(xprt);
> +}
> +
>  /**
>   * xprt_destroy - destroy an RPC transport, killing off all requests.
>   * @xprt: transport to destroy
> @@ -1454,22 +1471,19 @@ static void xprt_destroy(struct rpc_xprt *xprt)
>  {
>  	dprintk("RPC:       destroying transport %p\n", xprt);
>  
> -	/* Exclude transport connect/disconnect handlers */
> +	/*
> +	 * Exclude transport connect/disconnect handlers and autoclose
> +	 */
>  	wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_UNINTERRUPTIBLE);
>  
>  	del_timer_sync(&xprt->timer);
>  
> -	rpc_xprt_debugfs_unregister(xprt);
> -	rpc_destroy_wait_queue(&xprt->binding);
> -	rpc_destroy_wait_queue(&xprt->pending);
> -	rpc_destroy_wait_queue(&xprt->sending);
> -	rpc_destroy_wait_queue(&xprt->backlog);
> -	cancel_work_sync(&xprt->task_cleanup);
> -	kfree(xprt->servername);
>  	/*
> -	 * Tear down transport state and free the rpc_xprt
> +	 * Destroy sockets etc from the system workqueue so they can
> +	 * safely flush receive work running on rpciod.
>  	 */
> -	xprt->ops->destroy(xprt);
> +	INIT_WORK(&xprt->task_cleanup, xprt_destroy_cb);
> +	schedule_work(&xprt->task_cleanup);
>  }
>  
>  static void xprt_destroy_kref(struct kref *kref)
> -- 
> 2.13.6
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com

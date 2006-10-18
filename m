From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [patch 1/4] RPC: acquire BKL while calling
	rpc_release()	callback
Date: Wed, 18 Oct 2006 16:14:58 -0700
Message-ID: <1161213298.3315.26.camel@dyn9047022153>
References: <1161105873.3315.21.camel@dyn9047022153>
	<1161210013.6095.194.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaKcf-0001os-8h
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 16:14:53 -0700
Received: from e34.co.us.ibm.com ([32.97.110.152])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaKcf-00064i-Rg
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 16:14:54 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9INElH9008636
	for <nfs@lists.sourceforge.net>; Wed, 18 Oct 2006 19:14:47 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9INElCM507918
	for <nfs@lists.sourceforge.net>; Wed, 18 Oct 2006 17:14:47 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9INEknq013780
	for <nfs@lists.sourceforge.net>; Wed, 18 Oct 2006 17:14:47 -0600
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1161210013.6095.194.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2006-10-18 at 18:20 -0400, Trond Myklebust wrote:
> On Tue, 2006-10-17 at 10:24 -0700, Frank Filz wrote:
> > The Big Kernel Lock must be held while calling rpc_release().
> 
> Could we perhaps use something like the following helper instead? That
> ensures that we will not miss it again.

Yea, that looks good. Also less scary, only one lock_kernel() call
added. And definitely easier to later remove.

Frank

> ---------------------------------------------
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 18 Oct 2006 16:01:05 -0400
> Subject: SUNRPC: Fix up missing BKL in asynchronous RPC callback functions
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  include/linux/sunrpc/sched.h |    1 +
>  net/sunrpc/clnt.c            |    3 +--
>  net/sunrpc/sched.c           |   15 +++++++++++----
>  3 files changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index f399c13..d8e18ee 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -256,6 +256,7 @@ void		rpc_init_task(struct rpc_task *tas
>  				void *data);
>  void		rpc_release_task(struct rpc_task *);
>  void		rpc_exit_task(struct rpc_task *);
> +void		rpc_release_calldata(const struct rpc_call_ops *, void *);
>  void		rpc_killall_tasks(struct rpc_clnt *);
>  int		rpc_execute(struct rpc_task *);
>  void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 78696f2..a17cf0e 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -529,8 +529,7 @@ rpc_call_async(struct rpc_clnt *clnt, st
>  	rpc_restore_sigmask(&oldset);		
>  	return status;
>  out_release:
> -	if (tk_ops->rpc_release != NULL)
> -		tk_ops->rpc_release(data);
> +	rpc_release_calldata(tk_ops, data);
>  	return status;
>  }
>  
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index a1ab4ee..287fe9a 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -581,6 +581,15 @@ void rpc_exit_task(struct rpc_task *task
>  }
>  EXPORT_SYMBOL(rpc_exit_task);
>  
> +void rpc_release_calldata(const struct rpc_call_ops *ops, void *calldata)
> +{
> +	if (ops->rpc_release != NULL) {
> +		lock_kernel();
> +		ops->rpc_release(calldata);
> +		unlock_kernel();
> +	}
> +}
> +
>  /*
>   * This is the RPC `scheduler' (or rather, the finite state machine).
>   */
> @@ -884,8 +893,7 @@ #ifdef RPC_DEBUG
>  #endif
>  	if (task->tk_flags & RPC_TASK_DYNAMIC)
>  		rpc_free_task(task);
> -	if (tk_ops->rpc_release)
> -		tk_ops->rpc_release(calldata);
> +	rpc_release_calldata(tk_ops, calldata);
>  }
>  
>  /**
> @@ -902,8 +910,7 @@ struct rpc_task *rpc_run_task(struct rpc
>  	struct rpc_task *task;
>  	task = rpc_new_task(clnt, flags, ops, data);
>  	if (task == NULL) {
> -		if (ops->rpc_release != NULL)
> -			ops->rpc_release(data);
> +		rpc_release_calldata(ops, data);
>  		return ERR_PTR(-ENOMEM);
>  	}
>  	atomic_inc(&task->tk_count);
> 
> 


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

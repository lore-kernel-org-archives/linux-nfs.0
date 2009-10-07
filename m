From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/7] SUNRPC: Clean up call_transmit_status()
Date: Wed, 07 Oct 2009 18:22:38 -0400
Message-ID: <1254954158.7045.33.camel@heimdal.trondhjem.org>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net>
	 <20091007220239.1844.1995.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50790 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755327AbZJGWXY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2009 18:23:24 -0400
In-Reply-To: <20091007220239.1844.1995.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-10-07 at 18:02 -0400, Chuck Lever wrote:
> Clean up: re-arrange the cases in call_transmit_status() to make the
> code easier to read.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/clnt.c |   24 ++++++++++++------------
>  1 files changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 57f39b7..c26669c 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1175,25 +1175,21 @@ call_transmit(struct rpc_task *task)
>  
>  /*
>   * 5a.	Handle cleanup after a transmission
> + *	If we've been waiting on the socket's write_space()
> + *	callback, or if the server is temporarily unreachable,
> + *	continue holding the transport lock.
>   */
>  static void
>  call_transmit_status(struct rpc_task *task)
>  {
> +	dprint_status(task);
> +
>  	task->tk_action = call_status;
> +
>  	switch (task->tk_status) {
> -	case -EAGAIN:
> -		break;
> -	default:
> -		xprt_end_transmit(task);
> -		rpc_task_force_reencode(task);
> +	case -EAGAIN:			/* no write space */
>  		break;
> -		/*
> -		 * Special cases: if we've been waiting on the
> -		 * socket's write_space() callback, or if the
> -		 * socket just returned a connection error,
> -		 * then hold onto the transport lock.
> -		 */
> -	case -ECONNREFUSED:
> +	case -ECONNREFUSED:		/* connection problems */
>  	case -ECONNRESET:
>  	case -ENOTCONN:
>  	case -EHOSTDOWN:
> @@ -1206,6 +1202,10 @@ call_transmit_status(struct rpc_task *task)
>  			break;
>  		}
>  		rpc_task_force_reencode(task);
> +		break;
> +	default:			/* success, or some other error */
> +		xprt_end_transmit(task);
> +		rpc_task_force_reencode(task);
>  	}
>  }

This puts the most common case (success) at the very end of the switch
statement. Most compilers will generate the most efficient code when it
is at the very beginning...

Trond


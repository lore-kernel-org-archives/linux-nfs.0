Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:24283 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754994Ab3BUSRu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 13:17:50 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "simo@redhat.com" <simo@redhat.com>
Subject: Re: [PATCH 1/6] SUNRPC: make AF_LOCAL connect synchronous
Date: Thu, 21 Feb 2013 18:17:47 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA5F3@SACEXCMBX04-PRD.hq.netapp.com>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
	 <1361464705-12340-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1361464705-12340-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-02-21 at 11:38 -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> It doesn't appear that anyone actually needs to connect asynchronously.
> 
> Also, using a workqueue for the connect means we lose the namespace
> information from the original process.  This is a problem since there's
> no way to explicitly pass in a filesystem namespace for resolution of an
> AF_LOCAL address.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  net/sunrpc/xprtsock.c |   35 +++++++++++++++++++++++++++--------
>  1 file changed, 27 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index bbc0915..b1df874 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1866,13 +1866,9 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
>   * @xprt: RPC transport to connect
>   * @transport: socket transport to connect
>   * @create_sock: function to create a socket of the correct type
> - *
> - * Invoked by a work queue tasklet.
>   */
> -static void xs_local_setup_socket(struct work_struct *work)
> +static void xs_local_setup_socket(struct sock_xprt *transport)
>  {
> -	struct sock_xprt *transport =
> -		container_of(work, struct sock_xprt, connect_worker.work);
>  	struct rpc_xprt *xprt = &transport->xprt;
>  	struct socket *sock;
>  	int status = -EIO;
> @@ -1919,6 +1915,31 @@ out:
>  	current->flags &= ~PF_FSTRANS;
>  }
>  
> +static void xs_local_connect(struct rpc_task *task)
> +{
> +	struct rpc_xprt *xprt = task->tk_xprt;
> +	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> +	unsigned long timeout;
> +
> +	 if (RPC_IS_ASYNC(task))
> +	 	rpc_exit(task, -ENOTCONN);

Needs a "return"...


> +
> +	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
> +		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
> +				"seconds\n",
> +				xprt, xprt->reestablish_timeout / HZ);
> +		timeout = xprt->reestablish_timeout;
> +		xprt->reestablish_timeout <<= 1;
> +		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
> +			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
> +		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
> +			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
> +		rpc_delay(task, timeout);

This too needs to exit in order to sleep.

> +	} else
> +		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
> +	xs_local_setup_socket(transport);
> +}
> +
>  #ifdef CONFIG_SUNRPC_SWAP
>  static void xs_set_memalloc(struct rpc_xprt *xprt)
>  {
> @@ -2454,7 +2475,7 @@ static struct rpc_xprt_ops xs_local_ops = {
>  	.alloc_slot		= xprt_alloc_slot,
>  	.rpcbind		= xs_local_rpcbind,
>  	.set_port		= xs_local_set_port,
> -	.connect		= xs_connect,
> +	.connect		= xs_local_connect,
>  	.buf_alloc		= rpc_malloc,
>  	.buf_free		= rpc_free,
>  	.send_request		= xs_local_send_request,
> @@ -2627,8 +2648,6 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
>  			goto out_err;
>  		}
>  		xprt_set_bound(xprt);
> -		INIT_DELAYED_WORK(&transport->connect_worker,
> -					xs_local_setup_socket);
>  		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
>  		break;
>  	default:

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

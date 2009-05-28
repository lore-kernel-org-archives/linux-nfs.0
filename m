From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs41: sunrpc: xs_tcp_read_callback() should use xprt_force_disconnect()
Date: Thu, 28 May 2009 14:22:46 +0300
Message-ID: <4A1E7406.4020801@panasas.com>
References: <> <1243359172-32250-1-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23139 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751528AbZE1LWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 07:22:47 -0400
In-Reply-To: <1243359172-32250-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged onto my nfs41-all and nfs41-for-{2.6.31,next} branches.

Thanks!

Benny

On May. 26, 2009, 20:32 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> xs_tcp_read_callback() drops the connection when the number of expected
> callbacks is exceeded.  Use xprt_force_disconnect(), ensuring tasks on
> the pending queue are awaken on disconnect.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  net/sunrpc/xprtsock.c |    7 +------
>  1 files changed, 1 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 1a268bf..7445d4b 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1147,13 +1147,8 @@ static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
>  
>  	req = xprt_alloc_bc_request(xprt);
>  	if (req == NULL) {
> -		/*
> -		 * Schedule an autoclose RPC call
> -		 */
>  		printk(KERN_WARNING "Callback slot table overflowed\n");
> -		set_bit(XPRT_CLOSE_WAIT, &xprt->state);
> -		if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
> -			queue_work(rpciod_workqueue, &xprt->task_cleanup);
> +		xprt_force_disconnect(xprt);
>  		return -1;
>  	}
>  

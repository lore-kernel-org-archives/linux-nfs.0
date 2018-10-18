Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35678 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726340AbeJSD1W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Oct 2018 23:27:22 -0400
Date: Thu, 18 Oct 2018 15:24:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: Frank Sorenson <sorenson@redhat.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org, David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] sunrpc: safely reallow resvport min/max inversion
Message-ID: <20181018192454.GB28076@fieldses.org>
References: <20180904190632.GA22395@fieldses.org>
 <20180917152834.GD18600@fieldses.org>
 <20180917153306.GE18600@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180917153306.GE18600@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I didn't get any feedback on this patch.  Maybe the problem was this:

On Mon, Sep 17, 2018 at 11:33:06AM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Commits ffb6ca33b04b and e08ea3a96fc7 prevent setting xprt_min_resvport
> greater than xprt_max_resvport, but may also break simple code that sets
> one parameter then the other, if the new range does not overlap the old.
> 
> Also it looks racy to me, unless there's some serialization I'm not
> seeing.  Granted it would probably require malicious privileged processes
> (unless there's a chance these might eventually be settable in unprivileged
> containers), but still it seems better not to let userspace panic the
> kernel.
> 
> Simpler seems to be to allow setting the parameters to whatever you want
> but interpret xprt_min_resvport > xprt_max_resvport as the empty range.
> 
> Untested.

So, I've booted to it and verified that I can set min_resvport and
max_resvport, and that mount fails when min_resvport > max_resvport.

I'll resend.

--b.

> 
> Fixes: ffb6ca33b04b "sunrpc: Prevent resvport min/max inversion..."
> Fixes: e08ea3a96fc7 "sunrpc: Prevent rexvport min/max inversion..."
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  net/sunrpc/xprtsock.c | 34 ++++++++++++++++++----------------
>  1 file changed, 18 insertions(+), 16 deletions(-)
> 
> Whoops, I sent this before but just noticed that I failed to cc the
> list, then that I mispelled the address.  Argh.
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 9e1c5024aba9..5d59de92b5a1 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -129,7 +129,7 @@ static struct ctl_table xs_tunables_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
>  		.extra1		= &xprt_min_resvport_limit,
> -		.extra2		= &xprt_max_resvport
> +		.extra2		= &xprt_max_resvport_limit
>  	},
>  	{
>  		.procname	= "max_resvport",
> @@ -137,7 +137,7 @@ static struct ctl_table xs_tunables_table[] = {
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
> -		.extra1		= &xprt_min_resvport,
> +		.extra1		= &xprt_min_resvport_limit,
>  		.extra2		= &xprt_max_resvport_limit
>  	},
>  	{
> @@ -1773,11 +1773,17 @@ static void xs_udp_timer(struct rpc_xprt *xprt, struct rpc_task *task)
>  	spin_unlock_bh(&xprt->transport_lock);
>  }
>  
> -static unsigned short xs_get_random_port(void)
> +static int xs_get_random_port(void)
>  {
> -	unsigned short range = xprt_max_resvport - xprt_min_resvport + 1;
> -	unsigned short rand = (unsigned short) prandom_u32() % range;
> -	return rand + xprt_min_resvport;
> +	unsigned short min = xprt_min_resvport, max = xprt_max_resvport;
> +	unsigned short range;
> +	unsigned short rand;
> +
> +	if (max < min)
> +		return -EADDRINUSE;
> +	range = max - min + 1;
> +	rand = (unsigned short) prandom_u32() % range;
> +	return rand + min;
>  }
>  
>  /**
> @@ -1833,9 +1839,9 @@ static void xs_set_srcport(struct sock_xprt *transport, struct socket *sock)
>  		transport->srcport = xs_sock_getport(sock);
>  }
>  
> -static unsigned short xs_get_srcport(struct sock_xprt *transport)
> +static int xs_get_srcport(struct sock_xprt *transport)
>  {
> -	unsigned short port = transport->srcport;
> +	int port = transport->srcport;
>  
>  	if (port == 0 && transport->xprt.resvport)
>  		port = xs_get_random_port();
> @@ -1856,7 +1862,7 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
>  {
>  	struct sockaddr_storage myaddr;
>  	int err, nloop = 0;
> -	unsigned short port = xs_get_srcport(transport);
> +	int port = xs_get_srcport(transport);
>  	unsigned short last;
>  
>  	/*
> @@ -1874,8 +1880,8 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
>  	 * transport->xprt.resvport == 1) xs_get_srcport above will
>  	 * ensure that port is non-zero and we will bind as needed.
>  	 */
> -	if (port == 0)
> -		return 0;
> +	if (port <= 0)
> +		return port;
>  
>  	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);
>  	do {
> @@ -3317,12 +3323,8 @@ static int param_set_uint_minmax(const char *val,
>  
>  static int param_set_portnr(const char *val, const struct kernel_param *kp)
>  {
> -	if (kp->arg == &xprt_min_resvport)
> -		return param_set_uint_minmax(val, kp,
> -			RPC_MIN_RESVPORT,
> -			xprt_max_resvport);
>  	return param_set_uint_minmax(val, kp,
> -			xprt_min_resvport,
> +			RPC_MIN_RESVPORT,
>  			RPC_MAX_RESVPORT);
>  }
>  
> -- 
> 2.17.1
> 

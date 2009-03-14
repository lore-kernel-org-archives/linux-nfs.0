From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 29/30] SUNRPC: Add a sysctl to control the duration of
	the socket linger timeout
Date: Fri, 13 Mar 2009 23:19:37 -0400
Message-ID: <20090314031937.GA7166@fieldses.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org> <20090311184110.5578.89380.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:46883 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbZCNDTo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2009 23:19:44 -0400
In-Reply-To: <20090311184110.5578.89380.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Out of curiosity: how would a user decide what to set this to?

--b.

On Wed, Mar 11, 2009 at 02:41:10PM -0400, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  net/sunrpc/xprtsock.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index b51f58b..42222b4 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -50,6 +50,7 @@ unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
>  unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
>  
>  #define XS_TCP_LINGER_TO	(15U * HZ)
> +static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
>  
>  /*
>   * We can register our own files under /proc/sys/sunrpc by
> @@ -119,6 +120,14 @@ static ctl_table xs_tunables_table[] = {
>  		.extra2		= &xprt_max_resvport_limit
>  	},
>  	{
> +		.procname	= "tcp_fin_timeout",
> +		.data		= &xs_tcp_fin_timeout,
> +		.maxlen		= sizeof(xs_tcp_fin_timeout),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec_jiffies,
> +		.strategy	= sysctl_jiffies
> +	},
> +	{
>  		.ctl_name = 0,
>  	},
>  };
> @@ -1222,7 +1231,7 @@ static void xs_tcp_state_change(struct sock *sk)
>  		clear_bit(XPRT_CONNECTED, &xprt->state);
>  		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>  		smp_mb__after_clear_bit();
> -		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
> +		xs_tcp_schedule_linger_timeout(xprt, xs_tcp_fin_timeout);
>  		break;
>  	case TCP_CLOSE_WAIT:
>  		/* The server initiated a shutdown of the socket */
> @@ -1239,7 +1248,7 @@ static void xs_tcp_state_change(struct sock *sk)
>  		break;
>  	case TCP_LAST_ACK:
>  		set_bit(XPRT_CLOSING, &xprt->state);
> -		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
> +		xs_tcp_schedule_linger_timeout(xprt, xs_tcp_fin_timeout);
>  		smp_mb__before_clear_bit();
>  		clear_bit(XPRT_CONNECTED, &xprt->state);
>  		smp_mb__after_clear_bit();
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

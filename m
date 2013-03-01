Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51276 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112Ab3CAVHf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2013 16:07:35 -0500
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r21L7WPe021971
	for <linux-nfs@vger.kernel.org>; Fri, 1 Mar 2013 13:07:33 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] SUNRPC: add call to get configured timeout
Date: Fri, 1 Mar 2013 21:07:32 +0000
Message-ID: <0EC8763B847DB24D9ADF5EBD9CD7B4192BC8AD6B@SACEXCMBX02-PRD.hq.netapp.com>
References: <1362101410-22544-1-git-send-email-dros@netapp.com>
 <1362101410-22544-2-git-send-email-dros@netapp.com>
In-Reply-To: <1362101410-22544-2-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

One minor fixup here: the comment is wrong.  rpc_get_timeout returns the timeout in HZ.

Thanks!

-dros

On Feb 28, 2013, at 8:30 PM, Weston Andros Adamson <dros@netapp.com> wrote:

> Returns the configured timeout for the xprt of the rpc client.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> include/linux/sunrpc/clnt.h |  1 +
> net/sunrpc/clnt.c           | 15 +++++++++++++++
> 2 files changed, 16 insertions(+)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 34206b8..21d52d0 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -160,6 +160,7 @@ void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
> int		rpc_protocol(struct rpc_clnt *);
> struct net *	rpc_net_ns(struct rpc_clnt *);
> size_t		rpc_max_payload(struct rpc_clnt *);
> +unsigned long	rpc_get_timeout(struct rpc_clnt *clnt);
> void		rpc_force_rebind(struct rpc_clnt *);
> size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
> const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index a9f7906..09dc0c2 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1196,6 +1196,21 @@ size_t rpc_max_payload(struct rpc_clnt *clnt)
> EXPORT_SYMBOL_GPL(rpc_max_payload);
> 
> /**
> + * rpc_get_timeout - Get timeout for transport in tenths of seconds
> + * @clnt: RPC client to query
> + */
> +unsigned long rpc_get_timeout(struct rpc_clnt *clnt)
> +{
> +	unsigned long ret;
> +
> +	rcu_read_lock();
> +	ret = rcu_dereference(clnt->cl_xprt)->timeout->to_initval;
> +	rcu_read_unlock();
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(rpc_get_timeout);
> +
> +/**
>  * rpc_force_rebind - force transport to check that remote port is unchanged
>  * @clnt: client to rebind
>  *
> -- 
> 1.7.12.4 (Apple Git-37)
> 


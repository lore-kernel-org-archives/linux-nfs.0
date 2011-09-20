Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43248 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747Ab1ITNFg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 09:05:36 -0400
Message-ID: <4E788F8C.20103@netapp.com>
Date: Tue, 20 Sep 2011 09:05:16 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6>
In-Reply-To: <20110920101341.9861.51453.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/20/2011 06:13 AM, Stanislav Kinsbursky wrote:
> This helpers will be used for dynamical creation and destruction of rpcbind
> clients.
> Variable rpcb_users is actually a counter of lauched RPC services. If rpcbind
> clients has been created already, then we just increase rpcb_users.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
>  net/sunrpc/rpcb_clnt.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 50 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index e45d2fb..8724780 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>  static struct rpc_clnt *	rpcb_local_clnt;
>  static struct rpc_clnt *	rpcb_local_clnt4;
>  
> +DEFINE_SPINLOCK(rpcb_clnt_lock);
> +unsigned int			rpcb_users;
> +
>  struct rpcbind_args {
>  	struct rpc_xprt *	r_xprt;
>  
> @@ -161,6 +164,53 @@ static void rpcb_map_release(void *data)
>  	kfree(map);
>  }
>  
> +static int rpcb_get_local(void)
> +{
> +	spin_lock(&rpcb_clnt_lock);
> +	if (rpcb_users)
> +		rpcb_users++;
> +	spin_unlock(&rpcb_clnt_lock);
> +
> +	return rpcb_users;
        ^^^^^^^^^^^^^^^^^^
Is it safe to use this variable outside of the rpcb_clnt_lock?

> +}
> +
> +void rpcb_put_local(void)
> +{
> +	struct rpc_clnt *clnt = rpcb_local_clnt;
> +	struct rpc_clnt *clnt4 = rpcb_local_clnt4;
> +	int shutdown;
> +
> +	spin_lock(&rpcb_clnt_lock);
> +	if (--rpcb_users == 0) {
> +		rpcb_local_clnt = NULL;
> +		rpcb_local_clnt4 = NULL;
> +	}
> +	shutdown = !rpcb_users;
> +	spin_unlock(&rpcb_clnt_lock);
> +
> +	if (shutdown) {
> +		/*
> +		 * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
> +		 */
> +		if (clnt4)
> +			rpc_shutdown_client(clnt4);
> +		if (clnt)
> +			rpc_shutdown_client(clnt);
> +	}
> +	return;
> +}
> +
> +static void rpcb_set_local(struct rpc_clnt *clnt, struct rpc_clnt *clnt4)
> +{
> +	/* Protected by rpcb_create_local_mutex */
> +	rpcb_local_clnt = clnt;
> +	rpcb_local_clnt4 = clnt4;
> +	rpcb_users++;
> +	dprintk("RPC:       created new rpcb local clients (rpcb_local_clnt: "
> +			"%p, rpcb_local_clnt4: %p)\n", rpcb_local_clnt,
> +			rpcb_local_clnt4);
> +}
> +
>  /*
>   * Returns zero on success, otherwise a negative errno value
>   * is returned.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


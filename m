Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784Ab1ITOYn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 10:24:43 -0400
Date: Tue, 20 Sep 2011 10:24:31 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH v5 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Message-ID: <20110920102431.58ca1d96@tlielax.poochiereds.net>
In-Reply-To: <4E7899E7.9090809@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
	<20110920101341.9861.51453.stgit@localhost6.localdomain6>
	<4E7899E7.9090809@parallels.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 20 Sep 2011 17:49:27 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> v5: fixed races with rpcb_users in rpcb_get_local()
> 
> This helpers will be used for dynamical creation and destruction of rpcbind
> clients.
> Variable rpcb_users is actually a counter of lauched RPC services. If rpcbind
> clients has been created already, then we just increase rpcb_users.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
>   net/sunrpc/rpcb_clnt.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++
>   1 files changed, 53 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index e45d2fb..5f4a406 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>   static struct rpc_clnt *	rpcb_local_clnt;
>   static struct rpc_clnt *	rpcb_local_clnt4;
>   +DEFINE_SPINLOCK(rpcb_clnt_lock);
> +unsigned int			rpcb_users;
> +
>   struct rpcbind_args {
>   	struct rpc_xprt *	r_xprt;
>   @@ -161,6 +164,56 @@ static void rpcb_map_release(void *data)
>   	kfree(map);
>   }
>   +static int rpcb_get_local(void)
> +{
> +	int cnt;
> +
> +	spin_lock(&rpcb_clnt_lock);
> +	if (rpcb_users)
> +		rpcb_users++;
> +	cnt = rpcb_users;
> +	spin_unlock(&rpcb_clnt_lock);
> +
> +	return cnt;
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

In the function below, you mention that the above pointers are
protected by rpcb_create_local_mutex, but it looks like they get reset
here without that being held?

Might it be simpler to just protect rpcb_users with the
rpcb_create_local_mutex and ensure that it's held whenever you call one
of these routines? None of these are codepaths are particularly hot.

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
>   /*
>    * Returns zero on success, otherwise a negative errno value
>    * is returned.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@redhat.com>

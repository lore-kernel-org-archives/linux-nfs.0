Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49426 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752833Ab3KNLN3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Nov 2013 06:13:29 -0500
Date: Thu, 14 Nov 2013 06:13:04 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH v2] SUNRPC: Avoid deep recursion in rpc_release_client
Message-ID: <20131114061304.44aea650@tlielax.poochiereds.net>
In-Reply-To: <1384296615-17963-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1384295767-16456-1-git-send-email-Trond.Myklebust@netapp.com>
	<1384296615-17963-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Nov 2013 17:50:15 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> In cases where an rpc client has a parent hierarchy, then
> rpc_free_client may end up calling rpc_release_client() on the
> parent, thus recursing back into rpc_free_client. If the hierarchy
> is deep enough, then we can get into situations where the stack
> simply overflows.
> 
> The fix is to have rpc_release_client() loop so that it can take
> care of the parent rpc client hierarchy without needing to
> recurse.
> 
> Reported-by: Jeff Layton <jlayton@redhat.com>
> Reported-by: Weston Andros Adamson <dros@netapp.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> v2: Don't recurse if parent == NULL (Doh!)
> 
> 
>  net/sunrpc/clnt.c | 29 +++++++++++++++++------------
>  1 file changed, 17 insertions(+), 12 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index dab09dac8fc7..f09b7db2c492 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -750,14 +750,16 @@ EXPORT_SYMBOL_GPL(rpc_shutdown_client);
>  /*
>   * Free an RPC client
>   */
> -static void
> +static struct rpc_clnt *
>  rpc_free_client(struct rpc_clnt *clnt)
>  {
> +	struct rpc_clnt *parent = NULL;
> +
>  	dprintk_rcu("RPC:       destroying %s client for %s\n",
>  			clnt->cl_program->name,
>  			rcu_dereference(clnt->cl_xprt)->servername);
>  	if (clnt->cl_parent != clnt)
> -		rpc_release_client(clnt->cl_parent);
> +		parent = clnt->cl_parent;
>  	rpc_clnt_remove_pipedir(clnt);
>  	rpc_unregister_client(clnt);
>  	rpc_free_iostats(clnt->cl_metrics);
> @@ -766,18 +768,17 @@ rpc_free_client(struct rpc_clnt *clnt)
>  	rpciod_down();
>  	rpc_free_clid(clnt);
>  	kfree(clnt);
> +	return parent;
>  }
>  
>  /*
>   * Free an RPC client
>   */
> -static void
> +static struct rpc_clnt * 
>  rpc_free_auth(struct rpc_clnt *clnt)
>  {
> -	if (clnt->cl_auth == NULL) {
> -		rpc_free_client(clnt);
> -		return;
> -	}
> +	if (clnt->cl_auth == NULL)
> +		return rpc_free_client(clnt);
>  
>  	/*
>  	 * Note: RPCSEC_GSS may need to send NULL RPC calls in order to
> @@ -788,7 +789,8 @@ rpc_free_auth(struct rpc_clnt *clnt)
>  	rpcauth_release(clnt->cl_auth);
>  	clnt->cl_auth = NULL;
>  	if (atomic_dec_and_test(&clnt->cl_count))
> -		rpc_free_client(clnt);
> +		return rpc_free_client(clnt);
> +	return NULL;
>  }
>  
>  /*
> @@ -799,10 +801,13 @@ rpc_release_client(struct rpc_clnt *clnt)
>  {
>  	dprintk("RPC:       rpc_release_client(%p)\n", clnt);
>  
> -	if (list_empty(&clnt->cl_tasks))
> -		wake_up(&destroy_wait);
> -	if (atomic_dec_and_test(&clnt->cl_count))
> -		rpc_free_auth(clnt);
> +	do {
> +		if (list_empty(&clnt->cl_tasks))
> +			wake_up(&destroy_wait);
> +		if (!atomic_dec_and_test(&clnt->cl_count))
> +			break;
> +		clnt = rpc_free_auth(clnt);
> +	} while (clnt != NULL);
>  }
>  EXPORT_SYMBOL_GPL(rpc_release_client);
>  

Much better!

Reviewed-by: Jeff Layton <jlayton@redhat.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45377 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750889AbaEFQhS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 12:37:18 -0400
Date: Tue, 6 May 2014 12:37:17 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/70] NFSd: Move default initialisers from
 create_client() to alloc_client()
Message-ID: <20140506163717.GD18281@fieldses.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 02:43:56PM -0400, Trond Myklebust wrote:
> Aside from making it clearer what is non-trivial in create_client(), it
> also fixes a bug whereby we can call free_client() before idr_init()
> has been called.

Thanks, applying for 3.15 and stable.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3ba65979a3cd..230d21cb1717 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1078,6 +1078,18 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
>  		return NULL;
>  	}
>  	clp->cl_name.len = name.len;
> +	INIT_LIST_HEAD(&clp->cl_sessions);
> +	idr_init(&clp->cl_stateids);
> +	atomic_set(&clp->cl_refcount, 0);
> +	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
> +	INIT_LIST_HEAD(&clp->cl_idhash);
> +	INIT_LIST_HEAD(&clp->cl_openowners);
> +	INIT_LIST_HEAD(&clp->cl_delegations);
> +	INIT_LIST_HEAD(&clp->cl_lru);
> +	INIT_LIST_HEAD(&clp->cl_callbacks);
> +	INIT_LIST_HEAD(&clp->cl_revoked);
> +	spin_lock_init(&clp->cl_lock);
> +	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
>  	return clp;
>  }
>  
> @@ -1347,7 +1359,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
>  	if (clp == NULL)
>  		return NULL;
>  
> -	INIT_LIST_HEAD(&clp->cl_sessions);
>  	ret = copy_cred(&clp->cl_cred, &rqstp->rq_cred);
>  	if (ret) {
>  		spin_lock(&nn->client_lock);
> @@ -1355,20 +1366,9 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
>  		spin_unlock(&nn->client_lock);
>  		return NULL;
>  	}
> -	idr_init(&clp->cl_stateids);
> -	atomic_set(&clp->cl_refcount, 0);
> -	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
> -	INIT_LIST_HEAD(&clp->cl_idhash);
> -	INIT_LIST_HEAD(&clp->cl_openowners);
> -	INIT_LIST_HEAD(&clp->cl_delegations);
> -	INIT_LIST_HEAD(&clp->cl_lru);
> -	INIT_LIST_HEAD(&clp->cl_callbacks);
> -	INIT_LIST_HEAD(&clp->cl_revoked);
> -	spin_lock_init(&clp->cl_lock);
>  	nfsd4_init_callback(&clp->cl_cb_null);
>  	clp->cl_time = get_seconds();
>  	clear_bit(0, &clp->cl_cb_slot_busy);
> -	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
>  	copy_verf(clp, verf);
>  	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
>  	gen_confirm(clp);
> -- 
> 1.9.0
> 

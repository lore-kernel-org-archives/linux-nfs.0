Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50154 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbaEFQsa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 12:48:30 -0400
Date: Tue, 6 May 2014 12:48:29 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/70] nfsd4: use cl_lock to synchronize all stateid idr
 calls
Message-ID: <20140506164829.GG18281@fieldses.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Might be worth adding to the changelog something like "not currently
necessary, but will be once we drop the state lock here" to this and
similar patches (assuming that's accurate), just to make it clear what's
a bugfix and what isn't.

--b.

On Fri, Apr 18, 2014 at 02:44:00PM -0400, Trond Myklebust wrote:
> From: Benny Halevy <bhalevy@primarydata.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 34273ca482c3..626f310a74a8 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -334,7 +334,11 @@ kmem_cache *slab)
>  	if (!stid)
>  		return NULL;
>  
> -	new_id = idr_alloc_cyclic(stateids, stid, 0, 0, GFP_KERNEL);
> +	idr_preload(GFP_KERNEL);
> +	spin_lock(&cl->cl_lock);
> +	new_id = idr_alloc_cyclic(stateids, stid, 0, 0, GFP_NOWAIT);
> +	spin_unlock(&cl->cl_lock);
> +	idr_preload_end();
>  	if (new_id < 0)
>  		goto out_free;
>  	stid->sc_client = cl;
> @@ -397,9 +401,12 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
>  
>  static void remove_stid(struct nfs4_stid *s)
>  {
> -	struct idr *stateids = &s->sc_client->cl_stateids;
> +	struct nfs4_client *clp = s->sc_client;
> +	struct idr *stateids = &clp->cl_stateids;
>  
> +	spin_lock(&clp->cl_lock);
>  	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
> +	spin_unlock(&clp->cl_lock);
>  }
>  
>  static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
> @@ -1110,7 +1117,9 @@ free_client(struct nfs4_client *clp)
>  	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
>  	free_svc_cred(&clp->cl_cred);
>  	kfree(clp->cl_name.data);
> +	spin_lock(&clp->cl_lock);
>  	idr_destroy(&clp->cl_stateids);
> +	spin_unlock(&clp->cl_lock);
>  	kfree(clp);
>  }
>  
> @@ -1329,7 +1338,9 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
>  {
>  	struct nfs4_stid *ret;
>  
> +	spin_lock(&cl->cl_lock);
>  	ret = idr_find(&cl->cl_stateids, t->si_opaque.so_id);
> +	spin_unlock(&cl->cl_lock);
>  	if (!ret || !ret->sc_type)
>  		return NULL;
>  	return ret;
> -- 
> 1.9.0
> 

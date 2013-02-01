Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43964 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422874Ab3BANOK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 08:14:10 -0500
Date: Fri, 1 Feb 2013 08:14:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 08/16] nfsd: break out hashtable search into separate
 function
Message-ID: <20130201131409.GB30668@fieldses.org>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
 <1359402082-29195-9-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1359402082-29195-9-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2013 at 02:41:14PM -0500, Jeff Layton wrote:
> Later, we'll need more than one call site for this, so break it out
> into a new function.

I'm applying these first 8 to the for-3.9 branch at:

	git://linux-nfs.org/~bfields/linux.git for-3.9

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfscache.c | 46 +++++++++++++++++++++++++++++++++-------------
>  1 file changed, 33 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index 634b856..b89e7c8 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -150,6 +150,35 @@ nfsd_cache_entry_expired(struct svc_cacherep *rp)
>  }
>  
>  /*
> + * Search the request hash for an entry that matches the given rqstp.
> + * Must be called with cache_lock held. Returns the found entry or
> + * NULL on failure.
> + */
> +static struct svc_cacherep *
> +nfsd_cache_search(struct svc_rqst *rqstp)
> +{
> +	struct svc_cacherep	*rp;
> +	struct hlist_node	*hn;
> +	struct hlist_head 	*rh;
> +	__be32			xid = rqstp->rq_xid;
> +	u32			proto =  rqstp->rq_prot,
> +				vers = rqstp->rq_vers,
> +				proc = rqstp->rq_proc;
> +
> +	rh = &cache_hash[request_hash(xid)];
> +	hlist_for_each_entry(rp, hn, rh, c_hash) {
> +		if (rp->c_state != RC_UNUSED &&
> +		    xid == rp->c_xid && proc == rp->c_proc &&
> +		    proto == rp->c_prot && vers == rp->c_vers &&
> +		    !nfsd_cache_entry_expired(rp) &&
> +		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
> +		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
> +			return rp;
> +	}
> +	return NULL;
> +}
> +
> +/*
>   * Try to find an entry matching the current call in the cache. When none
>   * is found, we grab the oldest unlocked entry off the LRU list.
>   * Note that no operation within the loop may sleep.
> @@ -157,8 +186,6 @@ nfsd_cache_entry_expired(struct svc_cacherep *rp)
>  int
>  nfsd_cache_lookup(struct svc_rqst *rqstp)
>  {
> -	struct hlist_node	*hn;
> -	struct hlist_head 	*rh;
>  	struct svc_cacherep	*rp;
>  	__be32			xid = rqstp->rq_xid;
>  	u32			proto =  rqstp->rq_prot,
> @@ -177,17 +204,10 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  	spin_lock(&cache_lock);
>  	rtn = RC_DOIT;
>  
> -	rh = &cache_hash[request_hash(xid)];
> -	hlist_for_each_entry(rp, hn, rh, c_hash) {
> -		if (rp->c_state != RC_UNUSED &&
> -		    xid == rp->c_xid && proc == rp->c_proc &&
> -		    proto == rp->c_prot && vers == rp->c_vers &&
> -		    !nfsd_cache_entry_expired(rp) &&
> -		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
> -		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr)) {
> -			nfsdstats.rchits++;
> -			goto found_entry;
> -		}
> +	rp = nfsd_cache_search(rqstp);
> +	if (rp) {
> +		nfsdstats.rchits++;
> +		goto found_entry;
>  	}
>  	nfsdstats.rcmisses++;
>  
> -- 
> 1.7.11.7
> 

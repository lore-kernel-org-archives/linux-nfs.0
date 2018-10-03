Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57706 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726842AbeJDADm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Oct 2018 20:03:42 -0400
Date: Wed, 3 Oct 2018 13:14:24 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 13/15] knfsd: Simplify NFS duplicate replay cache
Message-ID: <20181003171424.GG17517@fieldses.org>
References: <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
 <20181001144157.3515-7-trond.myklebust@hammerspace.com>
 <20181001144157.3515-8-trond.myklebust@hammerspace.com>
 <20181001144157.3515-9-trond.myklebust@hammerspace.com>
 <20181001144157.3515-10-trond.myklebust@hammerspace.com>
 <20181001144157.3515-11-trond.myklebust@hammerspace.com>
 <20181001144157.3515-12-trond.myklebust@hammerspace.com>
 <20181001144157.3515-13-trond.myklebust@hammerspace.com>
 <20181001144157.3515-14-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181001144157.3515-14-trond.myklebust@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 01, 2018 at 10:41:55AM -0400, Trond Myklebust wrote:
> Simplify the duplicate replay cache by initialising the preallocated
> cache entry, so that we can use it as a key for the cache lookup.
> 
> Note that the 99.999% case we want to optimise for is still the one
> where the lookup fails, and we have to add this entry to the cache,
> so preinitialising should not cause a performance penalty.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfsd/cache.h    |  6 +--
>  fs/nfsd/nfscache.c | 94 ++++++++++++++++++++++------------------------
>  2 files changed, 47 insertions(+), 53 deletions(-)
> 
> diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> index b7559c6f2b97..bd77d5f6fe53 100644
> --- a/fs/nfsd/cache.h
> +++ b/fs/nfsd/cache.h
> @@ -24,13 +24,13 @@ struct svc_cacherep {
>  	unsigned char		c_state,	/* unused, inprog, done */
>  				c_type,		/* status, buffer */
>  				c_secure : 1;	/* req came from port < 1024 */
> -	struct sockaddr_in6	c_addr;
>  	__be32			c_xid;
> -	u32			c_prot;
> +	__wsum			c_csum;
>  	u32			c_proc;
> +	u32			c_prot;
>  	u32			c_vers;
>  	unsigned int		c_len;
> -	__wsum			c_csum;
> +	struct sockaddr_in6	c_addr;
>  	unsigned long		c_timestamp;
>  	union {
>  		struct kvec	u_vec;

Unless I've missed something subtle--I'll move this chunk into the next
patch.--b.

> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index cef4686f87ef..527ce4c65765 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -121,7 +121,7 @@ nfsd_cache_hash(__be32 xid)
>  }
>  
>  static struct svc_cacherep *
> -nfsd_reply_cache_alloc(void)
> +nfsd_reply_cache_alloc(struct svc_rqst *rqstp, __wsum csum)
>  {
>  	struct svc_cacherep	*rp;
>  
> @@ -130,6 +130,16 @@ nfsd_reply_cache_alloc(void)
>  		rp->c_state = RC_UNUSED;
>  		rp->c_type = RC_NOCACHE;
>  		INIT_LIST_HEAD(&rp->c_lru);
> +
> +		rp->c_xid = rqstp->rq_xid;
> +		rp->c_proc = rqstp->rq_proc;
> +		memset(&rp->c_addr, 0, sizeof(rp->c_addr));
> +		rpc_copy_addr((struct sockaddr *)&rp->c_addr, svc_addr(rqstp));
> +		rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
> +		rp->c_prot = rqstp->rq_prot;
> +		rp->c_vers = rqstp->rq_vers;
> +		rp->c_len = rqstp->rq_arg.len;
> +		rp->c_csum = csum;
>  	}
>  	return rp;
>  }
> @@ -141,9 +151,11 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
>  		drc_mem_usage -= rp->c_replvec.iov_len;
>  		kfree(rp->c_replvec.iov_base);
>  	}
> -	list_del(&rp->c_lru);
> -	atomic_dec(&num_drc_entries);
> -	drc_mem_usage -= sizeof(*rp);
> +	if (rp->c_state != RC_UNUSED) {
> +		list_del(&rp->c_lru);
> +		atomic_dec(&num_drc_entries);
> +		drc_mem_usage -= sizeof(*rp);
> +	}
>  	kmem_cache_free(drc_slab, rp);
>  }
>  
> @@ -319,24 +331,23 @@ nfsd_cache_csum(struct svc_rqst *rqstp)
>  }
>  
>  static bool
> -nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
> +nfsd_cache_match(const struct svc_cacherep *key, const struct svc_cacherep *rp)
>  {
>  	/* Check RPC XID first */
> -	if (rqstp->rq_xid != rp->c_xid)
> +	if (key->c_xid != rp->c_xid)
>  		return false;
>  	/* compare checksum of NFS data */
> -	if (csum != rp->c_csum) {
> +	if (key->c_csum != rp->c_csum) {
>  		++payload_misses;
>  		return false;
>  	}
>  
>  	/* Other discriminators */
> -	if (rqstp->rq_proc != rp->c_proc ||
> -	    rqstp->rq_prot != rp->c_prot ||
> -	    rqstp->rq_vers != rp->c_vers ||
> -	    rqstp->rq_arg.len != rp->c_len ||
> -	    !rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) ||
> -	    rpc_get_port(svc_addr(rqstp)) != rpc_get_port((struct sockaddr *)&rp->c_addr))
> +	if (key->c_proc != rp->c_proc ||
> +	    key->c_prot != rp->c_prot ||
> +	    key->c_vers != rp->c_vers ||
> +	    key->c_len != rp->c_len ||
> +	    memcmp(&key->c_addr, &rp->c_addr, sizeof(key->c_addr)) != 0)
>  		return false;
>  
>  	return true;
> @@ -345,19 +356,18 @@ nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
>  /*
>   * Search the request hash for an entry that matches the given rqstp.
>   * Must be called with cache_lock held. Returns the found entry or
> - * NULL on failure.
> + * inserts an empty key on failure.
>   */
>  static struct svc_cacherep *
> -nfsd_cache_search(struct nfsd_drc_bucket *b, struct svc_rqst *rqstp,
> -		__wsum csum)
> +nfsd_cache_insert(struct nfsd_drc_bucket *b, struct svc_cacherep *key)
>  {
> -	struct svc_cacherep	*rp, *ret = NULL;
> +	struct svc_cacherep	*rp, *ret = key;
>  	struct list_head 	*rh = &b->lru_head;
>  	unsigned int		entries = 0;
>  
>  	list_for_each_entry(rp, rh, c_lru) {
>  		++entries;
> -		if (nfsd_cache_match(rqstp, csum, rp)) {
> +		if (nfsd_cache_match(key, rp)) {
>  			ret = rp;
>  			break;
>  		}
> @@ -374,6 +384,7 @@ nfsd_cache_search(struct nfsd_drc_bucket *b, struct svc_rqst *rqstp,
>  				atomic_read(&num_drc_entries));
>  	}
>  
> +	lru_put_end(b, ret);
>  	return ret;
>  }
>  
> @@ -389,9 +400,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  {
>  	struct svc_cacherep	*rp, *found;
>  	__be32			xid = rqstp->rq_xid;
> -	u32			proto =  rqstp->rq_prot,
> -				vers = rqstp->rq_vers,
> -				proc = rqstp->rq_proc;
>  	__wsum			csum;
>  	u32 hash = nfsd_cache_hash(xid);
>  	struct nfsd_drc_bucket *b = &drc_hashtbl[hash];
> @@ -410,52 +418,38 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  	 * Since the common case is a cache miss followed by an insert,
>  	 * preallocate an entry.
>  	 */
> -	rp = nfsd_reply_cache_alloc();
> -	spin_lock(&b->cache_lock);
> -	if (likely(rp)) {
> -		atomic_inc(&num_drc_entries);
> -		drc_mem_usage += sizeof(*rp);
> +	rp = nfsd_reply_cache_alloc(rqstp, csum);
> +	if (!rp) {
> +		dprintk("nfsd: unable to allocate DRC entry!\n");
> +		return rtn;
>  	}
>  
> -	/* go ahead and prune the cache */
> -	prune_bucket(b);
> -
> -	found = nfsd_cache_search(b, rqstp, csum);
> -	if (found) {
> -		if (likely(rp))
> -			nfsd_reply_cache_free_locked(rp);
> +	spin_lock(&b->cache_lock);
> +	found = nfsd_cache_insert(b, rp);
> +	if (found != rp) {
> +		nfsd_reply_cache_free_locked(rp);
>  		rp = found;
>  		goto found_entry;
>  	}
>  
> -	if (!rp) {
> -		dprintk("nfsd: unable to allocate DRC entry!\n");
> -		goto out;
> -	}
> -
>  	nfsdstats.rcmisses++;
>  	rqstp->rq_cacherep = rp;
>  	rp->c_state = RC_INPROG;
> -	rp->c_xid = xid;
> -	rp->c_proc = proc;
> -	rpc_copy_addr((struct sockaddr *)&rp->c_addr, svc_addr(rqstp));
> -	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
> -	rp->c_prot = proto;
> -	rp->c_vers = vers;
> -	rp->c_len = rqstp->rq_arg.len;
> -	rp->c_csum = csum;
>  
> -	lru_put_end(b, rp);
> +	atomic_inc(&num_drc_entries);
> +	drc_mem_usage += sizeof(*rp);
> +
> +	/* go ahead and prune the cache */
> +	prune_bucket(b);
>   out:
>  	spin_unlock(&b->cache_lock);
>  	return rtn;
>  
>  found_entry:
> -	nfsdstats.rchits++;
>  	/* We found a matching entry which is either in progress or done. */
> -	lru_put_end(b, rp);
> -
> +	nfsdstats.rchits++;
>  	rtn = RC_DROPIT;
> +
>  	/* Request being processed */
>  	if (rp->c_state == RC_INPROG)
>  		goto out;
> -- 
> 2.17.1

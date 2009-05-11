From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 16/29] knfsd: use client IPv4 address in reply cache
	hash
Date: Mon, 11 May 2009 17:48:46 -0400
Message-ID: <20090511214846.GI793@fieldses.org>
References: <20090331202800.739621000@sgi.com> <20090331202943.645819000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60753 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760169AbZEKVsq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 17:48:46 -0400
In-Reply-To: <20090331202943.645819000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2009 at 07:28:16AM +1100, Greg Banks wrote:
> Use the IPv4 address of the client in the reply cache hash function.
> This can help improve the distribution of the hash function when the
> workload includes a large number of clients which mounted their NFS
> filesystems at nearly the same time and are doing similar sequences
> of NFS calls, a pattern seen with large compute clusters.
> 
> This code predates the IPv6 support in the current NFS server but
> should be harmless with IPv6 clients.
> 
> Signed-off-by: Greg Banks <gnb@sgi.com>
> ---
> 
>  fs/nfsd/nfscache.c |   27 +++++++++++++--------------
>  1 file changed, 13 insertions(+), 14 deletions(-)
> 
> Index: bfields/fs/nfsd/nfscache.c
> ===================================================================
> --- bfields.orig/fs/nfsd/nfscache.c
> +++ bfields/fs/nfsd/nfscache.c
> @@ -38,12 +38,17 @@ static int			cache_disabled = 1;
>   * Calculate the hash index from an XID.  Note, some clients increment
>   * their XIDs in host order, which can result in all the variation being
>   * in the top bits we see here.  So we fold those bits down.
> + *
> + * Experiment shows that using the Jenkins hash improves the spectral
> + * properties of this hash, but the CPU cost of calculating it outweighs
> + * the advantages.
>   */
> -static inline u32 request_hash(u32 xid)
> +static inline u32 request_hash(u32 xid, const struct sockaddr_in *sin)
>  {
>  	u32 h = xid;
>  	h ^= (xid >> 24);
>  	h ^= ((xid & 0xff0000) >> 8);
> +	h ^= sin->sin_addr.s_addr;

Tell me if I'm confused about the endianness: the variation is typically
in the low-order (host) end of the ip address, but the s_addr is stored
in network order, so the variation is in the high-order bits on a
little-endian machine, but &(HASHSIZE-1) is throwing out those bits.

>  	return h & (HASHSIZE-1);
>  }
>  

I'd've stuck the following in a separate patch as it's not really
related.

--b.

> @@ -114,16 +119,6 @@ lru_put_end(struct svc_cacherep *rp)
>  }
>  
>  /*
> - * Move a cache entry from one hash list to another
> - */
> -static void
> -hash_refile(struct svc_cacherep *rp)
> -{
> -	hlist_del_init(&rp->c_hash);
> -	hlist_add_head(&rp->c_hash, cache_hash + request_hash(rp->c_xid));
> -}
> -
> -/*
>   * Try to find an entry matching the current call in the cache. When none
>   * is found, we grab the oldest unlocked entry off the LRU list.
>   * Note that no operation within the loop may sleep.
> @@ -137,7 +132,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
>  	__be32			xid = rqstp->rq_xid;
>  	u32			proto =  rqstp->rq_prot,
>  				vers = rqstp->rq_vers,
> -				proc = rqstp->rq_proc;
> +				proc = rqstp->rq_proc,
> +				h;
>  	unsigned long		age;
>  	int rtn;
>  
> @@ -146,11 +142,12 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
>  		nfsdstats.rcnocache++;
>  		return RC_DOIT;
>  	}
> +	h = request_hash(xid, svc_addr_in(rqstp));
>  
>  	spin_lock(&cache_lock);
>  	rtn = RC_DOIT;
>  
> -	rh = &cache_hash[request_hash(xid)];
> +	rh = &cache_hash[h];
>  	hlist_for_each_entry(rp, hn, rh, c_hash) {
>  		if (rp->c_state != RC_UNUSED &&
>  		    xid == rp->c_xid && proc == rp->c_proc &&
> @@ -198,7 +195,9 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
>  	rp->c_vers = vers;
>  	rp->c_timestamp = jiffies;
>  
> -	hash_refile(rp);
> +	/* Move the cache entry from one hash list to another */
> +	hlist_del_init(&rp->c_hash);
> +	hlist_add_head(&rp->c_hash, cache_hash + h);
>  
>  	/* release any buffer */
>  	if (rp->c_type == RC_REPLBUFF) {
> 
> --
> Greg

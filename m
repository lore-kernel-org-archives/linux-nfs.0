Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48257 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754838Ab3BDUUr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 15:20:47 -0500
Date: Mon, 4 Feb 2013 15:20:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 8/8] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130204202046.GB8709@fieldses.org>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
 <1359983887-28535-9-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1359983887-28535-9-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2013 at 08:18:07AM -0500, Jeff Layton wrote:
> @@ -238,12 +243,37 @@ nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  }
>  
>  /*
> + * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
> + */
> +static u32
> +nfsd_cache_crc(struct xdr_buf *buf)
> +{
> +	u32 crc;
> +	const unsigned char *p = buf->head[0].iov_base;
> +	size_t csum_len = min_t(size_t, buf->head[0].iov_len + buf->page_len,
> +					RC_CSUMLEN);
> +	size_t len = min(buf->head[0].iov_len, csum_len);
> +
> +	/* rq_arg.head first */
> +	crc = crc32(crc_seed, p, len);
> +	csum_len -= len;

I'm getting a RPLY14 failure from pynfs --security=krb5i.

I suspect what's happening here is that the data you're checksumming
over includes the gss sequence number and the krbi integrity checksum.
Both those change, even on resends, to prevent an attacker from doing
something nefarious by resending an old rpc.

I think we really want to checksum just over the nfs-level data.  Our
checks for xid, program number, etc., already cover most of the rpc
header anyway.

--b.

> +
> +	/* Nothing left */
> +	if (!csum_len)
> +		return crc;
> +
> +	/* checksum the rest from the page_array */
> +	p = page_address(buf->pages[0]) + buf->page_base;
> +	return crc32(crc, p, csum_len);
> +}
> +
> +/*
>   * Search the request hash for an entry that matches the given rqstp.
>   * Must be called with cache_lock held. Returns the found entry or
>   * NULL on failure.
>   */
>  static struct svc_cacherep *
> -nfsd_cache_search(struct svc_rqst *rqstp)
> +nfsd_cache_search(struct svc_rqst *rqstp, u32 crc)
>  {
>  	struct svc_cacherep	*rp;
>  	struct hlist_node	*hn;
> @@ -257,6 +287,7 @@ nfsd_cache_search(struct svc_rqst *rqstp)
>  	hlist_for_each_entry(rp, hn, rh, c_hash) {
>  		if (xid == rp->c_xid && proc == rp->c_proc &&
>  		    proto == rp->c_prot && vers == rp->c_vers &&
> +		    rqstp->rq_arg.len == rp->c_len && crc == rp->c_crc &&
>  		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
>  		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
>  			return rp;
> @@ -276,7 +307,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  	__be32			xid = rqstp->rq_xid;
>  	u32			proto =  rqstp->rq_prot,
>  				vers = rqstp->rq_vers,
> -				proc = rqstp->rq_proc;
> +				proc = rqstp->rq_proc,
> +				crc;
>  	unsigned long		age;
>  	int type = rqstp->rq_cachetype;
>  	int rtn;
> @@ -287,10 +319,12 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  		return RC_DOIT;
>  	}
>  
> +	crc = nfsd_cache_crc(&rqstp->rq_arg);
> +
>  	spin_lock(&cache_lock);
>  	rtn = RC_DOIT;
>  
> -	rp = nfsd_cache_search(rqstp);
> +	rp = nfsd_cache_search(rqstp, crc);
>  	if (rp)
>  		goto found_entry;
>  
> @@ -318,7 +352,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  	 * Must search again just in case someone inserted one
>  	 * after we dropped the lock above.
>  	 */
> -	found = nfsd_cache_search(rqstp);
> +	found = nfsd_cache_search(rqstp, crc);
>  	if (found) {
>  		nfsd_reply_cache_free_locked(rp);
>  		rp = found;
> @@ -344,6 +378,8 @@ setup_entry:
>  	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
>  	rp->c_prot = proto;
>  	rp->c_vers = vers;
> +	rp->c_len = rqstp->rq_arg.len;
> +	rp->c_crc = crc;
>  
>  	hash_refile(rp);
>  	lru_put_end(rp);
> -- 
> 1.7.11.7
> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643Ab3BILhA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Feb 2013 06:37:00 -0500
Date: Sat, 9 Feb 2013 06:36:48 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        rees@umich.edu
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130209063648.5933529b@tlielax.poochiereds.net>
In-Reply-To: <20130208205555.GC21040@fieldses.org>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
	<1360248701-23963-3-git-send-email-jlayton@redhat.com>
	<DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
	<20130207130316.0cf29993@corrin.poochiereds.net>
	<20130208082706.614035e2@tlielax.poochiereds.net>
	<20130208205555.GC21040@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 8 Feb 2013 15:55:55 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Feb 08, 2013 at 08:27:06AM -0500, Jeff Layton wrote:
> > On Thu, 7 Feb 2013 13:03:16 -0500
> > Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > On Thu, 7 Feb 2013 10:51:02 -0500
> > > Chuck Lever <chuck.lever@oracle.com> wrote:
> > > 
> > > > 
> > > > On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > > > 
> > > > > Now that we're allowing more DRC entries, it becomes a lot easier to hit
> > > > > problems with XID collisions. In order to mitigate those, calculate the
> > > > > crc32 of up to the first 256 bytes of each request coming in and store
> > > > > that in the cache entry, along with the total length of the request.
> > > > 
> > > > I'm happy to see a checksummed DRC finally become reality for the Linux NFS server.
> > > > 
> > > > Have you measured the CPU utilization impact and CPU cache footprint of performing a CRC computation for every incoming RPC?  I'm wondering if a simpler checksum might be just as useful but less costly to compute.
> > > > 
> > > 
> > > No, I haven't, at least not in any sort of rigorous way. It's pretty
> > > negligible on "normal" PC hardware, but I think most intel and amd cpus
> > > have instructions for handling crc32. I'm ok with a different checksum,
> > > we don't need anything cryptographically secure here. I simply chose
> > > crc32 since it has an easily available API, and I figured it would be
> > > fairly lightweight.
> > > 
> > 
> > After an abortive attempt to measure this with ftrace, I ended up
> > hacking together a patch to just measure the latency of the
> > nfsd_cache_csum/_crc functions to get some rough numbers. On my x86_64
> > KVM guest, the avg time to calculate the crc32 is ~1750ns. Using IP
> > checksums cuts that roughly in half to ~800ns. I'm not sure how best to
> > measure the cache footprint however.
> > 
> > Neither seems terribly significant, especially given the other
> > inefficiencies in this code. OTOH, I guess those latencies can add up,
> > and I don't see any need to use crc32 over the net/checksum.h routines.
> > We probably ought to go with my RFC patch from yesterday.
> 
> OK, I hadn't committed the original yet, so I've just rolled them
> together and added a little of the above to the changelog.  Look OK?
> Chuck, should I add a Reviewed-by: ?
> 
> --b.
> 
> commit a937bd422ccc4306cdc81b5aa60b12a7212b70d3
> Author: Jeff Layton <jlayton@redhat.com>
> Date:   Mon Feb 4 11:57:27 2013 -0500
> 
>     nfsd: keep a checksum of the first 256 bytes of request
>     
>     Now that we're allowing more DRC entries, it becomes a lot easier to hit
>     problems with XID collisions. In order to mitigate those, calculate a
>     checksum of up to the first 256 bytes of each request coming in and store
>     that in the cache entry, along with the total length of the request.
>     
>     This initially used crc32, but Chuck Lever and Jim Rees pointed out that
>     crc32 is probably more heavyweight than we really need for generating
>     these checksums, and recommended looking at using the same routines that
>     are used to generate checksums for IP packets.
>     
>     On an x86_64 KVM guest measurements with ftrace showed ~800ns to use
>     csum_partial vs ~1750ns for crc32.  The difference probably isn't
>     terribly significant, but for now we may as well use csum_partial.
>     
>     Signed-off-by: Jeff Layton <jlayton@redhat.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 


Thanks Bruce. Looks good to me.

> diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> index 9c7232b..87fd141 100644
> --- a/fs/nfsd/cache.h
> +++ b/fs/nfsd/cache.h
> @@ -29,6 +29,8 @@ struct svc_cacherep {
>  	u32			c_prot;
>  	u32			c_proc;
>  	u32			c_vers;
> +	unsigned int		c_len;
> +	__wsum			c_csum;
>  	unsigned long		c_timestamp;
>  	union {
>  		struct kvec	u_vec;
> @@ -73,6 +75,9 @@ enum {
>  /* Cache entries expire after this time period */
>  #define RC_EXPIRE		(120 * HZ)
>  
> +/* Checksum this amount of the request */
> +#define RC_CSUMLEN		(256U)
> +
>  int	nfsd_reply_cache_init(void);
>  void	nfsd_reply_cache_shutdown(void);
>  int	nfsd_cache_lookup(struct svc_rqst *);
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index f754469..40db57e 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -11,6 +11,7 @@
>  #include <linux/slab.h>
>  #include <linux/sunrpc/addr.h>
>  #include <linux/highmem.h>
> +#include <net/checksum.h>
>  
>  #include "nfsd.h"
>  #include "cache.h"
> @@ -130,6 +131,7 @@ int nfsd_reply_cache_init(void)
>  	INIT_LIST_HEAD(&lru_head);
>  	max_drc_entries = nfsd_cache_size_limit();
>  	num_drc_entries = 0;
> +
>  	return 0;
>  out_nomem:
>  	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
> @@ -238,12 +240,45 @@ nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  }
>  
>  /*
> + * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
> + */
> +static __wsum
> +nfsd_cache_csum(struct svc_rqst *rqstp)
> +{
> +	int idx;
> +	unsigned int base;
> +	__wsum csum;
> +	struct xdr_buf *buf = &rqstp->rq_arg;
> +	const unsigned char *p = buf->head[0].iov_base;
> +	size_t csum_len = min_t(size_t, buf->head[0].iov_len + buf->page_len,
> +				RC_CSUMLEN);
> +	size_t len = min(buf->head[0].iov_len, csum_len);
> +
> +	/* rq_arg.head first */
> +	csum = csum_partial(p, len, 0);
> +	csum_len -= len;
> +
> +	/* Continue into page array */
> +	idx = buf->page_base / PAGE_SIZE;
> +	base = buf->page_base & ~PAGE_MASK;
> +	while (csum_len) {
> +		p = page_address(buf->pages[idx]) + base;
> +		len = min(PAGE_SIZE - base, csum_len);
> +		csum = csum_partial(p, len, csum);
> +		csum_len -= len;
> +		base = 0;
> +		++idx;
> +	}
> +	return csum;
> +}
> +
> +/*
>   * Search the request hash for an entry that matches the given rqstp.
>   * Must be called with cache_lock held. Returns the found entry or
>   * NULL on failure.
>   */
>  static struct svc_cacherep *
> -nfsd_cache_search(struct svc_rqst *rqstp)
> +nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
>  {
>  	struct svc_cacherep	*rp;
>  	struct hlist_node	*hn;
> @@ -257,6 +292,7 @@ nfsd_cache_search(struct svc_rqst *rqstp)
>  	hlist_for_each_entry(rp, hn, rh, c_hash) {
>  		if (xid == rp->c_xid && proc == rp->c_proc &&
>  		    proto == rp->c_prot && vers == rp->c_vers &&
> +		    rqstp->rq_arg.len == rp->c_len && csum == rp->c_csum &&
>  		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
>  		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
>  			return rp;
> @@ -277,6 +313,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  	u32			proto =  rqstp->rq_prot,
>  				vers = rqstp->rq_vers,
>  				proc = rqstp->rq_proc;
> +	__wsum			csum;
>  	unsigned long		age;
>  	int type = rqstp->rq_cachetype;
>  	int rtn;
> @@ -287,10 +324,12 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  		return RC_DOIT;
>  	}
>  
> +	csum = nfsd_cache_csum(rqstp);
> +
>  	spin_lock(&cache_lock);
>  	rtn = RC_DOIT;
>  
> -	rp = nfsd_cache_search(rqstp);
> +	rp = nfsd_cache_search(rqstp, csum);
>  	if (rp)
>  		goto found_entry;
>  
> @@ -318,7 +357,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  	 * Must search again just in case someone inserted one
>  	 * after we dropped the lock above.
>  	 */
> -	found = nfsd_cache_search(rqstp);
> +	found = nfsd_cache_search(rqstp, csum);
>  	if (found) {
>  		nfsd_reply_cache_free_locked(rp);
>  		rp = found;
> @@ -344,6 +383,8 @@ setup_entry:
>  	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
>  	rp->c_prot = proto;
>  	rp->c_vers = vers;
> +	rp->c_len = rqstp->rq_arg.len;
> +	rp->c_csum = csum;
>  
>  	hash_refile(rp);
>  	lru_put_end(rp);

-- 
Jeff Layton <jlayton@redhat.com>

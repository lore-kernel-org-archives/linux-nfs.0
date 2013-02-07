Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56161 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758240Ab3BGQAg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 11:00:36 -0500
Date: Thu, 7 Feb 2013 11:00:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130207160032.GF3222@fieldses.org>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
 <1360248701-23963-3-git-send-email-jlayton@redhat.com>
 <DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2013 at 10:51:02AM -0500, Chuck Lever wrote:
> 
> On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Now that we're allowing more DRC entries, it becomes a lot easier to
> > hit problems with XID collisions. In order to mitigate those,
> > calculate the crc32 of up to the first 256 bytes of each request
> > coming in and store that in the cache entry, along with the total
> > length of the request.
> 
> I'm happy to see a checksummed DRC finally become reality for the
> Linux NFS server.
> 
> Have you measured the CPU utilization impact and CPU cache footprint
> of performing a CRC computation for every incoming RPC?

Note this is over the first 256 bytes of the request--which we're
probably just about to read for xdr decoding anyway.

> I'm wondering if a simpler checksum might be just as useful but less
> costly to compute.

What would be an example of a simpler checksum?

--b.

> 
> 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfsd/cache.h    |  5 +++++
> > fs/nfsd/nfscache.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++----
> > 2 files changed, 54 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> > index 9c7232b..4822db3 100644
> > --- a/fs/nfsd/cache.h
> > +++ b/fs/nfsd/cache.h
> > @@ -29,6 +29,8 @@ struct svc_cacherep {
> > 	u32			c_prot;
> > 	u32			c_proc;
> > 	u32			c_vers;
> > +	unsigned int		c_len;
> > +	u32			c_crc;
> > 	unsigned long		c_timestamp;
> > 	union {
> > 		struct kvec	u_vec;
> > @@ -73,6 +75,9 @@ enum {
> > /* Cache entries expire after this time period */
> > #define RC_EXPIRE		(120 * HZ)
> > 
> > +/* Checksum this amount of the request */
> > +#define RC_CSUMLEN		(256U)
> > +
> > int	nfsd_reply_cache_init(void);
> > void	nfsd_reply_cache_shutdown(void);
> > int	nfsd_cache_lookup(struct svc_rqst *);
> > diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> > index f754469..a8c3f1e 100644
> > --- a/fs/nfsd/nfscache.c
> > +++ b/fs/nfsd/nfscache.c
> > @@ -11,6 +11,8 @@
> > #include <linux/slab.h>
> > #include <linux/sunrpc/addr.h>
> > #include <linux/highmem.h>
> > +#include <linux/crc32.h>
> > +#include <linux/sunrpc/svcauth_gss.h>
> > 
> > #include "nfsd.h"
> > #include "cache.h"
> > @@ -24,6 +26,7 @@ static struct list_head 	lru_head;
> > static struct kmem_cache	*drc_slab;
> > static unsigned int		num_drc_entries;
> > static unsigned int		max_drc_entries;
> > +static u32			crc_seed;
> > 
> > /*
> >  * Calculate the hash index from an XID.
> > @@ -130,6 +133,9 @@ int nfsd_reply_cache_init(void)
> > 	INIT_LIST_HEAD(&lru_head);
> > 	max_drc_entries = nfsd_cache_size_limit();
> > 	num_drc_entries = 0;
> > +
> > +	/* Is a random seed any better than some well-defined constant? */
> > +	get_random_bytes(&crc_seed, sizeof(crc_seed));
> > 	return 0;
> > out_nomem:
> > 	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
> > @@ -238,12 +244,45 @@ nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
> > }
> > 
> > /*
> > + * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
> > + */
> > +static u32
> > +nfsd_cache_crc(struct svc_rqst *rqstp)
> > +{
> > +	int idx;
> > +	unsigned int base;
> > +	u32 crc;
> > +	struct xdr_buf *buf = &rqstp->rq_arg;
> > +	const unsigned char *p = buf->head[0].iov_base;
> > +	size_t csum_len = min_t(size_t, buf->head[0].iov_len + buf->page_len,
> > +				RC_CSUMLEN);
> > +	size_t len = min(buf->head[0].iov_len, csum_len);
> > +
> > +	/* rq_arg.head first */
> > +	crc = crc32(crc_seed, p, len);
> > +	csum_len -= len;
> > +
> > +	/* Continue into page array */
> > +	idx = buf->page_base / PAGE_SIZE;
> > +	base = buf->page_base & ~PAGE_MASK;
> > +	while (csum_len) {
> > +		p = page_address(buf->pages[idx]) + base;
> > +		len = min(PAGE_SIZE - base, csum_len);
> > +		crc = crc32(crc, p, len);
> > +		csum_len -= len;
> > +		base = 0;
> > +		++idx;
> > +	}
> > +	return crc;
> > +}
> > +
> > +/*
> >  * Search the request hash for an entry that matches the given rqstp.
> >  * Must be called with cache_lock held. Returns the found entry or
> >  * NULL on failure.
> >  */
> > static struct svc_cacherep *
> > -nfsd_cache_search(struct svc_rqst *rqstp)
> > +nfsd_cache_search(struct svc_rqst *rqstp, u32 crc)
> > {
> > 	struct svc_cacherep	*rp;
> > 	struct hlist_node	*hn;
> > @@ -257,6 +296,7 @@ nfsd_cache_search(struct svc_rqst *rqstp)
> > 	hlist_for_each_entry(rp, hn, rh, c_hash) {
> > 		if (xid == rp->c_xid && proc == rp->c_proc &&
> > 		    proto == rp->c_prot && vers == rp->c_vers &&
> > +		    rqstp->rq_arg.len == rp->c_len && crc == rp->c_crc &&
> > 		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
> > 		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
> > 			return rp;
> > @@ -276,7 +316,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
> > 	__be32			xid = rqstp->rq_xid;
> > 	u32			proto =  rqstp->rq_prot,
> > 				vers = rqstp->rq_vers,
> > -				proc = rqstp->rq_proc;
> > +				proc = rqstp->rq_proc,
> > +				crc;
> > 	unsigned long		age;
> > 	int type = rqstp->rq_cachetype;
> > 	int rtn;
> > @@ -287,10 +328,12 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
> > 		return RC_DOIT;
> > 	}
> > 
> > +	crc = nfsd_cache_crc(rqstp);
> > +
> > 	spin_lock(&cache_lock);
> > 	rtn = RC_DOIT;
> > 
> > -	rp = nfsd_cache_search(rqstp);
> > +	rp = nfsd_cache_search(rqstp, crc);
> > 	if (rp)
> > 		goto found_entry;
> > 
> > @@ -318,7 +361,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
> > 	 * Must search again just in case someone inserted one
> > 	 * after we dropped the lock above.
> > 	 */
> > -	found = nfsd_cache_search(rqstp);
> > +	found = nfsd_cache_search(rqstp, crc);
> > 	if (found) {
> > 		nfsd_reply_cache_free_locked(rp);
> > 		rp = found;
> > @@ -344,6 +387,8 @@ setup_entry:
> > 	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
> > 	rp->c_prot = proto;
> > 	rp->c_vers = vers;
> > +	rp->c_len = rqstp->rq_arg.len;
> > +	rp->c_crc = crc;
> > 
> > 	hash_refile(rp);
> > 	lru_put_end(rp);
> > -- 
> > 1.7.11.7
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 

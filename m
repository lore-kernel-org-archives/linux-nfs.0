Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35848 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756511AbZEZTEO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2009 15:04:14 -0400
Date: Tue, 26 May 2009 15:04:15 -0400
To: Greg Banks <gnb@fmeh.org>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>,
        Robert Gardner <rob.gardner@hp.com>
Subject: Re: [patch 18/29] knfsd: dynamically expand the reply cache
Message-ID: <20090526190415.GF31567@fieldses.org>
References: <20090331202800.739621000@sgi.com> <20090331202944.386752000@sgi.com> <20090526185701.GE31567@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20090526185701.GE31567@fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

(With Greg's address corrected.)

On Tue, May 26, 2009 at 02:57:01PM -0400, bfields wrote:
> On Wed, Apr 01, 2009 at 07:28:18AM +1100, Greg Banks wrote:
> > Allow the reply cache to expand under nonidempotent NFS call load.
> > The current fixed limit on reply cache entries is actually so small
> > as to make the reply cache utterly ineffectual (see the comment in
> > nfscache.c for details).
> > 
> > This is a simpler version of an older more complicated patch which
> > dynamically expanded the hash index using lazy rehashing.  Here we
> > allocate a hash index which is too large for the initial size of the
> > reply cache, and don't ever resize it.
> 
> Hm, just on the subject; looks like someone (cc'd) is presenting at the
> Linux Symposium on reply cache improvements:
> 
> 	http://www.linuxsymposium.org/2009/view_abstract.php?content_key=89
> 
> I assume they're talking about the linux server?  Will there be patches?
> 
> --b.
> 
> > 
> > Signed-off-by: Greg Banks <gnb@sgi.com>
> > ---
> > 
> >  fs/nfsd/nfscache.c |   76 ++++++++++++++++++++++++++++++++++++------
> >  1 file changed, 66 insertions(+), 10 deletions(-)
> > 
> > Index: bfields/fs/nfsd/nfscache.c
> > ===================================================================
> > --- bfields.orig/fs/nfsd/nfscache.c
> > +++ bfields/fs/nfsd/nfscache.c
> > @@ -9,7 +9,7 @@
> >   *
> >   * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
> >   *
> > - * SMP lock splitting by Greg Banks <gnb@sgi.com>
> > + * Dynamic expansion and SMP lock splitting by Greg Banks <gnb@sgi.com>
> >   *     Copyright (c) 2005-2009 Silicon Graphics, Inc.
> >   */
> >  
> > @@ -24,11 +24,21 @@
> >  #include <linux/nfsd/nfsd.h>
> >  #include <linux/nfsd/cache.h>
> >  
> > -/* Size of reply cache. Common values are:
> > +/* Initial size of reply cache. Common values are:
> >   * 4.3BSD:	128
> >   * 4.4BSD:	256
> >   * Solaris2:	1024
> >   * DEC Unix:	512-4096
> > + *
> > + * All these values reflect network packet rates and NFS loads common
> > + * somewhen around 1990, and are utterly inadequate for modern NFS
> > + * servers.  To be at all effective the reply cache needs to hold all
> > + * NFS calls seen by the server for at least a client RPC timeout period
> > + * (typically 1.1 seconds), and to handle weird IP routing issues should
> > + * really hold 120 seconds of traffic.  A modern NFS server can be
> > + * fielding upwards of 10,000 calls per second, which means the default
> > + * cache size of 1024 holds about 102 milliseconds'  traffic, i.e. the
> > + * default size is three orders of magnitude too small.
> >   */
> >  /* number of buckets used to manage LRU lists and cache locks (power of 2) */
> >  #ifdef CONFIG_SMP
> > @@ -36,14 +46,22 @@
> >  #else
> >  #define CACHE_NUM_BUCKETS	1
> >  #endif
> > -/* number of entries in all LRU lists (power of 2) */
> > +/* initial number of entries in all LRU lists (power of 2) */
> >  #define CACHE_SIZE		(1024)
> > +/* largest possible number of entries in all LRU lists (power of 2) */
> > +#define CACHE_MAX_SIZE		(16*1024*CACHE_NUM_BUCKETS)
> >  /* largest possible number of entries in LRU per bucket */
> > -#define CACHE_BUCKET_MAX_SIZE	(CACHE_SIZE/CACHE_NUM_BUCKETS)
> > +#define CACHE_BUCKET_MAX_SIZE	(CACHE_MAX_SIZE/CACHE_NUM_BUCKETS)
> > +/* number of entries each bucket will expand by */
> > +#define CACHE_BUCKET_INCREMENT	(1024/CACHE_NUM_BUCKETS)
> >  /* log2 of largest desired hash chain length */
> >  #define MAX_CHAIN_ORDER		2
> >  /* initial and maximum size of the per-bucket hash table */
> > -#define HASHSIZE		((CACHE_SIZE>>MAX_CHAIN_ORDER)/CACHE_NUM_BUCKETS)
> > +#define HASHSIZE		((CACHE_MAX_SIZE>>MAX_CHAIN_ORDER)/CACHE_NUM_BUCKETS)
> > +/* the cache attempts to expand if an entry younger than this is evicted */
> > +#define CACHE_THRESH_AGE	(11 * HZ / 10)  /* in jiffies */
> > +/* parameters for rate limiting cache expansion */
> > +#define CACHE_RATE_JIFFIES	(HZ/2)
> >  
> >  /*
> >   * locking for the reply cache:
> > @@ -63,6 +81,9 @@ struct svc_cache_bucket
> >  	struct list_head lru;
> >  	unsigned int size;
> >  	struct hlist_head *hash;
> > +	/* parameters for expand rate limiting */
> > +	unsigned long last;
> > +	unsigned long nhits;
> >  } ____cacheline_aligned_in_smp;
> >  
> >  static struct svc_cache_bucket	cache_buckets[CACHE_NUM_BUCKETS];
> > @@ -90,18 +111,18 @@ static inline u32 request_hash(u32 xid, 
> >  static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
> >  
> >  /*
> > - * Initialise the reply cache data structures.
> > + * Expand (or initialise) the reply cache data structures.
> >   * Called without cache_lock, uses it internally.  Returns
> >   * 0 on success, an error otherwise.
> >   */
> > -static int nfsd_cache_bucket_init(struct svc_cache_bucket *b, unsigned int num)
> > +static int nfsd_cache_bucket_expand(struct svc_cache_bucket *b, unsigned int increment)
> >  {
> >  	struct svc_cacherep *rp;
> >  	unsigned int i;
> >  	LIST_HEAD(lru);
> >  
> >  	/* allocate new entries without the lock, keep them on their own list */
> > -	i = num;
> > +	i = increment;
> >  	while (i) {
> >  		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
> >  		if (!rp)
> > @@ -116,7 +137,7 @@ static int nfsd_cache_bucket_init(struct
> >  	/* add the new entries */
> >  	spin_lock(&b->lock);
> >  
> > -	b->size = num;
> > +	b->size += increment;
> >  	list_splice(&lru, &b->lru);
> >  
> >  	spin_unlock(&b->lock);
> > @@ -142,7 +163,7 @@ int nfsd_reply_cache_init(void)
> >  
> >  		INIT_LIST_HEAD(&b->lru);
> >  		spin_lock_init(&b->lock);
> > -		if (nfsd_cache_bucket_init(b, CACHE_SIZE/CACHE_NUM_BUCKETS))
> > +		if (nfsd_cache_bucket_expand(b, CACHE_SIZE/CACHE_NUM_BUCKETS))
> >  			goto out_nomem;
> >  		b->hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
> >  		if (!b->hash)
> > @@ -189,6 +210,26 @@ static inline void lru_put_end(struct sv
> >  }
> >  
> >  /*
> > + * Decide whether it is time to expand the cache.  Returns 1 iff
> > + * the cache is to be expanded.  Called with bucket lock held.
> > + */
> > +static int nfsd_cache_expand_ratelimit(struct svc_cache_bucket *b)
> > +{
> > +	unsigned long now = jiffies;
> > +
> > +	b->nhits++;
> > +	if (b->last == 0) {
> > +		b->last = now;
> > +	} else if ((now - b->last) > CACHE_RATE_JIFFIES &&
> > +		   b->nhits > (b->size >> 4)) {
> > +		b->nhits = 0;
> > +		b->last = now;
> > +		return 1;
> > +	}
> > +	return 0;
> > +}
> > +
> > +/*
> >   * Try to find an entry matching the current call in the cache. When none
> >   * is found, we grab the oldest unlocked entry off the LRU list.
> >   * Note that no operation within the loop may sleep.
> > @@ -207,6 +248,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
> >  	struct svc_cache_bucket *b;
> >  	unsigned long		age;
> >  	int			rtn;
> > +	int			expand = 0;
> >  
> >  	rqstp->rq_cacherep = NULL;
> >  	if (cache_disabled || type == RC_NOCACHE) {
> > @@ -259,6 +301,18 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
> >  		goto out;
> >  	}
> >  
> > +	if (rp->c_state != RC_UNUSED) {
> > +		/* reusing an existing cache entry */
> > +		age = jiffies - rp->c_timestamp;
> > +		if (age < CACHE_THRESH_AGE &&
> > +		    b->size < CACHE_BUCKET_MAX_SIZE &&
> > +		    nfsd_cache_expand_ratelimit(b)) {
> > +			expand = CACHE_BUCKET_INCREMENT;
> > +			if (b->size + expand > CACHE_BUCKET_MAX_SIZE)
> > +				expand = CACHE_BUCKET_MAX_SIZE - b->size;
> > +		}
> > +	}
> > +
> >  	rqstp->rq_cacherep = rp;
> >  	rp->c_state = RC_INPROG;
> >  	rp->c_xid = xid;
> > @@ -280,6 +334,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
> >  	rp->c_type = RC_NOCACHE;
> >   out:
> >  	spin_unlock(&b->lock);
> > +	if (expand)
> > +		nfsd_cache_bucket_expand(b, expand);
> >  	return rtn;
> >  
> >  found_entry:
> > 
> > --
> > Greg

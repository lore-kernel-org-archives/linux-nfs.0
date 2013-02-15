Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756805Ab3BOSeK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 13:34:10 -0500
Date: Fri, 15 Feb 2013 13:34:06 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: add new reply_cache_stats file in nfsdfs
Message-ID: <20130215133406.20b1ef09@tlielax.poochiereds.net>
In-Reply-To: <D3E38097-34BE-4A2D-91F6-200176FEA3F0@oracle.com>
References: <1360948990-2265-1-git-send-email-jlayton@redhat.com>
	<1360948990-2265-4-git-send-email-jlayton@redhat.com>
	<D3E38097-34BE-4A2D-91F6-200176FEA3F0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 15 Feb 2013 12:29:08 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Feb 15, 2013, at 12:23 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > For presenting statistics relating to duplicate reply cache.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfsd/cache.h    |  1 +
> > fs/nfsd/nfscache.c | 37 +++++++++++++++++++++++++++++++++----
> > fs/nfsd/nfsctl.c   |  9 +++++++++
> > 3 files changed, 43 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> > index 87fd141..d5c5b3e 100644
> > --- a/fs/nfsd/cache.h
> > +++ b/fs/nfsd/cache.h
> > @@ -82,6 +82,7 @@ int	nfsd_reply_cache_init(void);
> > void	nfsd_reply_cache_shutdown(void);
> > int	nfsd_cache_lookup(struct svc_rqst *);
> > void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
> > +int	nfsd_reply_cache_stats_open(struct inode *, struct file *);
> > 
> > #ifdef CONFIG_NFSD_V4
> > void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
> > diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> > index ad1d069..b155afa 100644
> > --- a/fs/nfsd/nfscache.c
> > +++ b/fs/nfsd/nfscache.c
> > @@ -23,12 +23,17 @@
> > static struct hlist_head *	cache_hash;
> > static struct list_head 	lru_head;
> > static struct kmem_cache	*drc_slab;
> > -static unsigned int		num_drc_entries;
> > -static unsigned int		max_drc_entries;
> > -static unsigned int		drc_mem_usage;
> > -static unsigned int		csum_misses;
> > 
> > /*
> > + * Stats on the duplicate reply cache code. All of these and the "rc" fields
> > + * in nfsdstats are protected by the cache_lock
> > + */
> > +static unsigned int		num_drc_entries; /* number of entries */
> > +static unsigned int		max_drc_entries; /* max number of entries */
> > +static unsigned int		drc_mem_usage;   /* memory used by cache */
> > +static unsigned int		csum_misses;     /* cache misses due only to
> > +						    csum comparison failures */
> > +/*
> >  * Calculate the hash index from an XID.
> >  */
> > static inline u32 request_hash(u32 xid)
> > @@ -545,3 +550,27 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
> > 	vec->iov_len += data->iov_len;
> > 	return 1;
> > }
> > +
> > +/*
> > + * Note that fields may be added, removed or reordered in the future. Programs
> > + * scraping this file for info should test the labels to ensure they're
> > + * getting the correct field.
> > + */
> > +static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
> > +{
> > +	spin_lock(&cache_lock);
> > +	seq_printf(m, "max entries:     %u\n", max_drc_entries);
> > +	seq_printf(m, "num entries:     %u\n", num_drc_entries);
> > +	seq_printf(m, "mem usage:       %u\n", drc_mem_usage);
> > +	seq_printf(m, "cache hits:      %u\n", nfsdstats.rchits);
> > +	seq_printf(m, "cache misses:    %u\n", nfsdstats.rcmisses);
> > +	seq_printf(m, "not cached:      %u\n", nfsdstats.rcnocache);
> > +	seq_printf(m, "checksum misses: %u\n", csum_misses);
> > +	spin_unlock(&cache_lock);
> > +	return 0;
> > +}
> 
> Would it be hard to add a statistic that quantified the distribution of entries in the cache hash table?  Something like "maximum length of cache hash chain" ?
> 

Hard? Not very, but it wouldn't be free...

I guess we'd need to keep an array of HASHSIZE (64) uints to track the
length of each hash bucket. Currently too, we don't need to know what
hash bucket an entry sits when freeing it. So we'd need to recompute
that when freeing the entry (which is fairly trivial).

Also, what sort of info do you want here? Longest hash chain that the
cache has ever had, or longest hash chain currently in the cache? It
may be better to just present the length of each chain instead and let
userland sort out the max.

I'd probably suggest that do this in a later patch on top of this
series once we determine what info we're looking for here. It should
be doable for 3.9 though...

-- 
Jeff Layton <jlayton@redhat.com>

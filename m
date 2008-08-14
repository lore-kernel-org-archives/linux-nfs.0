From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] knfsd: allocate readahead cache in individual chunks
Date: Thu, 14 Aug 2008 14:52:27 -0400
Message-ID: <20080814145227.15efe087@barsoom.rdu.redhat.com>
References: <1218679407-11364-1-git-send-email-jlayton@redhat.com>
	<20080814180635.GC23859@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011AbYHNSwb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 14:52:31 -0400
In-Reply-To: <20080814180635.GC23859@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Aug 2008 14:06:35 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Aug 13, 2008 at 10:03:27PM -0400, Jeff Layton wrote:
> > I had a report from someone building a large NFS server that they were
> > unable to start more than 585 nfsd threads. It was reported against an
> > older kernel using the slab allocator, and I tracked it down to the
> > large allocation in nfsd_racache_init failing.
> > 
> > It appears that the slub allocator handles large allocations better,
> > but large contiguous allocations can often be problematic. There
> > doesn't seem to be any reason that the racache has to be allocated as a
> > single large chunk. This patch breaks this up so that the racache is
> > built up from separate allocations.
> 
> So by default nfsd_racache_init gets called with size 2*nrservs, so 1170
> in this case.  Looks like struct raprms is about 50 bytes.  So that's
> about a 60k allocation?
> 

On my x86_64 box, sizeof(struct raparm) is 72 bytes for recent
kernels. For 2.6.18-ish it's 112:

2*585*112 = 131040

...which is just under a 128k allocation, and that seems to be as large
a kmalloc as you can do with slab. This is just the breakover point
though, the customer in question was trying to start 2048 nfsd's. That
might be considered insane, but if it is, we should probably reduce
NFSD_MAXSERVS which is set at 8192.

> And RAPARM_HASH_SIZE is 16.  So you could use an array for each hash
> bucket and each array would be under a page even in this rather extreme
> case, if you wanted to avoid lots of little allocations.  I don't know
> whether that really matters, though.
> 

I thought about that after I sent this patch.

I suppose there are 3 routes we can go with this:

1) do what I did here (individual kmalloc for each raparm)

2) do an allocation of an raparms array for each hash bucket, but when
we get to larger thread counts, these will still require multi-page
allocations:

8192 threads * 2 / 16 buckets * 72 bytes = 73728 byte allocation

3) declare a separate slabcache for this and allocate each raparm
individually from that

...#3 might be reasonable, but we could end up wasting even more memory
that way when we only have a few threads. Tough call...

> > +static unsigned int		raparm_hash_buckets;
> 
> It looks like this is here just to tell you how many bucket heads are
> non-null when freeing?  But I think the
> 
> 	if (cache_size < 2*RAPARM_HASH_SIZE)
> 		cache_size = 2*RAPARM_HASH_SIZE;
> 
> in nfsd_racache_init ensures no bucket is null, and anyway you check for
> null when freeing, so it doesn't seem like it would matter much.
> 

Very good point. Your way is better...

> >  	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
> > -	for (i = 0; i < cache_size - 1; i++) {
> > +	for (i = 0; i < cache_size; i++) {
> > +		raparm = kzalloc(sizeof(*raparm), GFP_KERNEL);
> > +		if (!raparm)
> > +			goto out_nomem;
> > +
> >  		if (i % nperbucket == 0)
> > -			raparm_hash[j++].pb_head = raparml + i;
> > -		if (i % nperbucket < nperbucket-1)
> > -			raparml[i].p_next = raparml + i + 1;
> > +			raparm_hash[j++].pb_head = raparm;
> > +		else
> > +			last_raparm->p_next = raparm;
> > +		last_raparm = raparm;
> 
> The modular arithmetic here always struck me as a bit convoluted.  Why
> not just nested for loops, and not be as fussy about the round-off
> error?  E.g.
> 
> 	for (i = 0; i < RAPARM_HASH_SIZE; i++) {
> 		spin_lock_init(&raparm_hash[i].pb_lock);
> 		raparm = &raparm_hash[i].pb_head;
> 
> 		for (j = 0; j < nperbucket; j++) {
> 			*raparm = kzalloc(sizeof(*raparm), GFP_KERNEL);
> 			if (!*raparm)
> 				goto out_nomem;
> 			raparm = &(*raparm)->p_next;
> 		}
> 		*raparm = NULL;
> 	}
>
> Lightly-tested patch (to apply on top of yours) follows.
> 
> --b.
>

The combined patch looks good to me

Thanks!
-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14328 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932315Ab3LENsw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 08:48:52 -0500
Date: Thu, 5 Dec 2013 08:48:25 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH RFC 3/3] nfsd: convert DRC code to use list_lru
Message-ID: <20131205084825.2bf1726d@tlielax.poochiereds.net>
In-Reply-To: <20131205134129.GE3381@infradead.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
	<1386241253-5781-4-git-send-email-jlayton@redhat.com>
	<20131205134129.GE3381@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Dec 2013 05:41:29 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> >  static void
> > -nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
> > +__nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
> >  {
> >  	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
> >  		drc_mem_usage -= rp->c_replvec.iov_len;
> > @@ -140,13 +141,26 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
> >  	}
> >  	if (!hlist_unhashed(&rp->c_hash))
> >  		hlist_del(&rp->c_hash);
> > -	list_del(&rp->c_lru);
> >  	--num_drc_entries;
> >  	drc_mem_usage -= sizeof(*rp);
> >  	kmem_cache_free(drc_slab, rp);
> 
> I would be better to move the hash list deletion out of this and
> keep this as a plain nfsd_reply_cache_free().  E.g. in the lookup
> cache hit case we've never linked any item and would want this low-level
> function.
> 

Ok.

> >  }
> >  
> >  static void
> > +nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
> > +{
> > +	list_lru_del(&lru_head, &rp->c_lru);
> > +	__nfsd_reply_cache_free_locked(rp);
> > +}
> > +
> > +static void
> > +nfsd_reply_cache_free_isolate(struct svc_cacherep *rp)
> > +{
> > +	list_del(&rp->c_lru);
> > +	__nfsd_reply_cache_free_locked(rp);
> > +}
> 
> Should be merged into the only caller.
> 

Ok.

> > +
> > +static void
> >  nfsd_reply_cache_free(struct svc_cacherep *rp)
> >  {
> >  	spin_lock(&cache_lock);
> > @@ -156,50 +170,66 @@ nfsd_reply_cache_free(struct svc_cacherep *rp)
> >  
> 
> > +static enum lru_status
> > +nfsd_purge_lru_entry(struct list_head *item, spinlock_t *lock, void *cb_arg)
> >  {
> > -	struct svc_cacherep	*rp;
> > +	struct svc_cacherep *rp = list_entry(item, struct svc_cacherep, c_lru);
> >  
> > +	nfsd_reply_cache_free_locked(rp);
> > +	return LRU_REMOVED;
> > +}
> > +
> > +void nfsd_reply_cache_shutdown(void)
> > +{
> >  	unregister_shrinker(&nfsd_reply_cache_shrinker);
> >  	cancel_delayed_work_sync(&cache_cleaner);
> >  
> > -	while (!list_empty(&lru_head)) {
> > -		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
> > -		nfsd_reply_cache_free_locked(rp);
> > -	}
> > +	/* In principle, nothing should be altering the list now, but... */
> > +	spin_lock(&cache_lock);
> > +	list_lru_walk(&lru_head, nfsd_purge_lru_entry, NULL, ULONG_MAX);
> > +	spin_unlock(&cache_lock);
> 
> This needs the version that does the list_del internally to, doesn't
> it?  I'd suggest to just use sd_purge_expired_entry with a forced
> flag in the argument.
> 

Yes it does. Good catch.

> > +	memset(&lru_head, 0, sizeof(lru_head));
> 
> don't think there's much of a point.
> 

Yeah, I got spooked by the fact that lru->node isn't zeroed out in
list_lru_destroy, but on list_lru_init it should get clobbered anyway
so the memset is pointless.

> 
> All together doesn't seem to helpful as long as the DRC keeps
> it's own timing based purge and similar bits unfortunatel.

Agreed. It might make sense to do this in the context of a larger
redesign but otherwise I can't get too excited about this set, TBH...

-- 
Jeff Layton <jlayton@redhat.com>

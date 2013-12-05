Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48225 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756604Ab3LENl3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 08:41:29 -0500
Date: Thu, 5 Dec 2013 05:41:29 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH RFC 3/3] nfsd: convert DRC code to use list_lru
Message-ID: <20131205134129.GE3381@infradead.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
 <1386241253-5781-4-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386241253-5781-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  static void
> -nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
> +__nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
>  {
>  	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
>  		drc_mem_usage -= rp->c_replvec.iov_len;
> @@ -140,13 +141,26 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
>  	}
>  	if (!hlist_unhashed(&rp->c_hash))
>  		hlist_del(&rp->c_hash);
> -	list_del(&rp->c_lru);
>  	--num_drc_entries;
>  	drc_mem_usage -= sizeof(*rp);
>  	kmem_cache_free(drc_slab, rp);

I would be better to move the hash list deletion out of this and
keep this as a plain nfsd_reply_cache_free().  E.g. in the lookup
cache hit case we've never linked any item and would want this low-level
function.

>  }
>  
>  static void
> +nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
> +{
> +	list_lru_del(&lru_head, &rp->c_lru);
> +	__nfsd_reply_cache_free_locked(rp);
> +}
> +
> +static void
> +nfsd_reply_cache_free_isolate(struct svc_cacherep *rp)
> +{
> +	list_del(&rp->c_lru);
> +	__nfsd_reply_cache_free_locked(rp);
> +}

Should be merged into the only caller.

> +
> +static void
>  nfsd_reply_cache_free(struct svc_cacherep *rp)
>  {
>  	spin_lock(&cache_lock);
> @@ -156,50 +170,66 @@ nfsd_reply_cache_free(struct svc_cacherep *rp)
>  

> +static enum lru_status
> +nfsd_purge_lru_entry(struct list_head *item, spinlock_t *lock, void *cb_arg)
>  {
> -	struct svc_cacherep	*rp;
> +	struct svc_cacherep *rp = list_entry(item, struct svc_cacherep, c_lru);
>  
> +	nfsd_reply_cache_free_locked(rp);
> +	return LRU_REMOVED;
> +}
> +
> +void nfsd_reply_cache_shutdown(void)
> +{
>  	unregister_shrinker(&nfsd_reply_cache_shrinker);
>  	cancel_delayed_work_sync(&cache_cleaner);
>  
> -	while (!list_empty(&lru_head)) {
> -		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
> -		nfsd_reply_cache_free_locked(rp);
> -	}
> +	/* In principle, nothing should be altering the list now, but... */
> +	spin_lock(&cache_lock);
> +	list_lru_walk(&lru_head, nfsd_purge_lru_entry, NULL, ULONG_MAX);
> +	spin_unlock(&cache_lock);

This needs the version that does the list_del internally to, doesn't
it?  I'd suggest to just use sd_purge_expired_entry with a forced
flag in the argument.

> +	memset(&lru_head, 0, sizeof(lru_head));

don't think there's much of a point.


All together doesn't seem to helpful as long as the DRC keeps
it's own timing based purge and similar bits unfortunatel.

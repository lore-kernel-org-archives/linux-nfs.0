Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44024 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557Ab3LCPub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Dec 2013 10:50:31 -0500
Date: Tue, 3 Dec 2013 10:50:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: hch@infradead.org, gartim@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash it
 first
Message-ID: <20131203155022.GA25173@fieldses.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 03:26:19PM -0500, Jeff Layton wrote:
> The DRC code will attempt to reuse an existing, expired cache entry in
> preference to allocating a new one. It'll then search the cache, and if
> it gets a hit it'll then free the cache entry that it was going to
> reuse.
> 
> The cache code doesn't unhash the entry that it's going to reuse
> however, so it's possible for it end up designating an entry for reuse
> and then subsequently freeing the same entry after it finds it.  This
> leads it to a later use-after-free situation and usually some list
> corruption warnings or an oops.
> 
> Fix this by simply unhashing the entry that we intend to reuse. That
> will mean that it's not findable via a search and should prevent this
> situation from occurring.

And that also makes it simpler to verify that prune_cache_entries()
isn't going to free rp, good.

Thanks, applying!

(But, note: I may not get things pushed out till next week as I don't
have as convenient a testing setup while I'm travelling this week.)

--b.

> 
> Cc: stable@vger.kernel.org # v3.10+
> Reported-by: Christoph Hellwig <hch@infradead.org>
> Reported-by: g. artim <gartim@gmail.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfscache.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index 9186c7c..b6af150 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -132,6 +132,13 @@ nfsd_reply_cache_alloc(void)
>  }
>  
>  static void
> +nfsd_reply_cache_unhash(struct svc_cacherep *rp)
> +{
> +	hlist_del_init(&rp->c_hash);
> +	list_del_init(&rp->c_lru);
> +}
> +
> +static void
>  nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
>  {
>  	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
> @@ -417,7 +424,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
>  		if (nfsd_cache_entry_expired(rp) ||
>  		    num_drc_entries >= max_drc_entries) {
> -			lru_put_end(rp);
> +			nfsd_reply_cache_unhash(rp);
>  			prune_cache_entries();
>  			goto search_cache;
>  		}
> -- 
> 1.8.4.2
> 

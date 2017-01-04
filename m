Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54296 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750822AbdADUhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 15:37:03 -0500
Date: Wed, 4 Jan 2017 15:26:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: neilb@suse.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 4] SVCAUTH reap the rsc cache entry on
 RPC_SS_PROC_DESTROY
Message-ID: <20170104202634.GA21562@fieldses.org>
References: <1482428286-33744-1-git-send-email-andros@netapp.com>
 <1482428286-33744-2-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1482428286-33744-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not against the patch, but I'm still not convinced by the
explanation:

On Thu, Dec 22, 2016 at 12:38:06PM -0500, andros@netapp.com wrote:
> From: Neil Brown <neilb@suse.com>
> 
> The rsc cache code operates in a read_lock/write_lock environment.
> Changes to a cache entry should use the provided rsc_update
> routine which takes the write_lock.

It looks pretty suspicious to be setting CACHE_NEGATIVE without the
cache_lock for write, but I'm not actually convinced there's a bug there
either.  In any case not one that you'd be hitting reliably.

> The current code sets the expiry_time and the CACHE_NEGATIVE flag
> without taking the write_lock as it does not call rsc_update.
> Without this patch, while cache_clean sees the entries to be
> removed, it does not remove the rsc_entries. This is because
> rsc_update updates other fields such as flush_time and last_refresh
> in the entry to trigger cache_clean to reap the entry.

I think the root cause of the particular behavior you were seeing was
actually an oversight from Neil's c5b29f885afe "sunrpc: use seconds
since boot in expiry cache", which missed this one occurrence of
get_seconds().  So it's setting the item's entry to something decades in
the future.

And that's probably not been a huge deal since these entries aren't so
big, and they will eventually get cleaned up by cache_purge when the
cache is destroyed.  Still, I can imagine it slowing down cache lookups
on a long-lived server.

The one-liner:

 -		rsci->h.expiry_time = get_seconds();
 +		rsci->h.expiry_time = seconds_since_boot();

would probably also do the job.  Am I missing something?

But, OK, I think Neil's patch will ensure entries get cleaned up more
quickly than that would, and might also fix a rare race.

--b.

> 
> Add a new sunrpc_cache_unhash() function (by Neil Brown) designed
> to directly unhash and reap the to be destroyed cache entry.
> 
> Signed-off-by: Neil Brown <neilb@suse.com>
> Reported-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  include/linux/sunrpc/cache.h      |  1 +
>  net/sunrpc/auth_gss/svcauth_gss.c |  4 ++--
>  net/sunrpc/cache.c                | 13 +++++++++++++
>  3 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 62a60ee..9dcf2c8 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -227,6 +227,7 @@ extern int cache_check(struct cache_detail *detail,
>  extern int sunrpc_cache_register_pipefs(struct dentry *parent, const char *,
>  					umode_t, struct cache_detail *);
>  extern void sunrpc_cache_unregister_pipefs(struct cache_detail *);
> +extern void sunrpc_cache_unhash(struct cache_detail *, struct cache_head *);
>  
>  /* Must store cache_detail in seq_file->private if using next three functions */
>  extern void *cache_seq_start(struct seq_file *file, loff_t *pos);
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 45662d7..78f8a9c 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1489,8 +1489,8 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>  	case RPC_GSS_PROC_DESTROY:
>  		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>  			goto auth_err;
> -		rsci->h.expiry_time = get_seconds();
> -		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
> +		/* Delete the entry from the cache_list and call cache_put */
> +		sunrpc_cache_unhash(sn->rsc_cache, &rsci->h);
>  		if (resv->iov_len + 4 > PAGE_SIZE)
>  			goto drop;
>  		svc_putnl(resv, RPC_SUCCESS);
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 8aabe12..153e254 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1855,3 +1855,16 @@ void sunrpc_cache_unregister_pipefs(struct cache_detail *cd)
>  }
>  EXPORT_SYMBOL_GPL(sunrpc_cache_unregister_pipefs);
>  
> +void sunrpc_cache_unhash(struct cache_detail *cd, struct cache_head *h)
> +{
> +	write_lock(&cd->hash_lock);
> +	if (!hlist_unhashed(&h->cache_list)){
> +		hlist_del_init(&h->cache_list);
> +		cd->entries--;
> +		write_unlock(&cd->hash_lock);
> +		cache_put(h, cd);
> +	} else
> +		write_unlock(&cd->hash_lock);
> +}
> +EXPORT_SYMBOL_GPL(sunrpc_cache_unhash);
> +
> -- 
> 1.8.3.1

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33061 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbaFEPKo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2014 11:10:44 -0400
Date: Thu, 5 Jun 2014 11:10:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't halt scanning the DRC LRU list when there's
 an RC_INPROG entry
Message-ID: <20140605151042.GF8362@fieldses.org>
References: <1401975900-13398-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401975900-13398-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2014 at 09:45:00AM -0400, Jeff Layton wrote:
> Currently, the DRC cache pruner will stop scanning the list when it
> hits an entry that is RC_INPROG. It's possible however for a call to
> take a *very* long time. In that case, we don't want it to block other
> entries from being pruned if they are expired or we need to trim the
> cache to get back under the limit.
> 
> Fix the DRC cache pruner to just ignore RC_INPROG entries.

Makes sense, applying for 3.16.  (Doesn't look like stable material.)

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfscache.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index f8f060ffbf4f..6040da8830ff 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -224,13 +224,6 @@ hash_refile(struct svc_cacherep *rp)
>  	hlist_add_head(&rp->c_hash, cache_hash + hash_32(rp->c_xid, maskbits));
>  }
>  
> -static inline bool
> -nfsd_cache_entry_expired(struct svc_cacherep *rp)
> -{
> -	return rp->c_state != RC_INPROG &&
> -	       time_after(jiffies, rp->c_timestamp + RC_EXPIRE);
> -}
> -
>  /*
>   * Walk the LRU list and prune off entries that are older than RC_EXPIRE.
>   * Also prune the oldest ones when the total exceeds the max number of entries.
> @@ -242,8 +235,14 @@ prune_cache_entries(void)
>  	long freed = 0;
>  
>  	list_for_each_entry_safe(rp, tmp, &lru_head, c_lru) {
> -		if (!nfsd_cache_entry_expired(rp) &&
> -		    num_drc_entries <= max_drc_entries)
> +		/*
> +		 * Don't free entries attached to calls that are still
> +		 * in-progress, but do keep scanning the list.
> +		 */
> +		if (rp->c_state == RC_INPROG)
> +			continue;
> +		if (num_drc_entries <= max_drc_entries &&
> +		    time_before(jiffies, rp->c_timestamp + RC_EXPIRE))
>  			break;
>  		nfsd_reply_cache_free_locked(rp);
>  		freed++;
> -- 
> 1.9.3
> 

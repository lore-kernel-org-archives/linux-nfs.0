Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34377 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932558Ab2GLPUo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 11:20:44 -0400
Date: Thu, 12 Jul 2012 11:20:43 -0400
From: "J.Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC/cache: fix reporting of expired cache entries
 in 'content' file.
Message-ID: <20120712152043.GB21577@fieldses.org>
References: <20120712103734.6dbc0207@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120712103734.6dbc0207@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks!  Applying for 3.6--b.

On Thu, Jul 12, 2012 at 10:37:34AM +1000, NeilBrown wrote:
> 
> Entries that are in a sunrpc cache but are not valid should be reported
> with a leading '#' so they look like a comment.
> Commit  d202cce8963d9 (sunrpc: never return expired entries in sunrpc_cache_lookup)
> broke this for expired entries.
> 
> This particularly applies to entries that have been replaced by newer entries.
> sunrpc_cache_update sets the expiry of the replaced entry to '0', but it
> remains in the cache until the next 'cache_clean'.
> The result is that if you
> 
>   echo 0 2000000000 1 0 > /proc/net/rpc/auth.unix.gid/channel
> 
> several times, then
> 
>   cat /proc/net/rpc/auth.unix.gid/content
> 
> It will display multiple entries for the one uid, which is at least confusing:
> 
>   #uid cnt: gids...
>   0 1: 0
>   0 1: 0
>   0 1: 0
> 
> With this patch, expired entries are marked as comments so you get
> 
>   #uid cnt: gids...
>   0 1: 0
>   # 0 1: 0
>   # 0 1: 0
> 
> These expired entries will never be seen by cache_check() as they are always
> *after* a non-expired entry with the same key - so the extra check is only
> needed in c_show()
> 
> Signed-off-by:  NeilBrown <neilb@suse.de>
> 
> --
> It's not a big problem, but it had me confused for a while, so it could
> well confuse others.
> Thanks,
> NeilBrown
> 
> 
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 47ad266..2afd2a8 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1349,8 +1349,11 @@ static int c_show(struct seq_file *m, void *p)
>  	if (cache_check(cd, cp, NULL))
>  		/* cache_check does a cache_put on failure */
>  		seq_printf(m, "# ");
> -	else
> +	else {
> +		if (cache_is_expired(cd, cp))
> +			seq_printf(m, "# ");
>  		cache_put(cp, cd);
> +	}
>  
>  	return cd->cache_show(m, cd, cp);
>  }



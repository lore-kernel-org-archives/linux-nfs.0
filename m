Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57326 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752416AbeC1TUt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Mar 2018 15:20:49 -0400
Message-ID: <1522264845.5165.1.camel@kernel.org>
Subject: Re: [PATCH] nfsd: Do not refuse to serve out of cache
From: Jeff Layton <jlayton@kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 28 Mar 2018 15:20:45 -0400
In-Reply-To: <20180328161801.8360-1-trond.myklebust@primarydata.com>
References: <20180328161801.8360-1-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-03-28 at 12:18 -0400, Trond Myklebust wrote:
> Currently the knfsd replay cache appears to try to refuse replying to
> retries that come within 200ms of the cache entry being created. That
> makes limited sense in today's world of high speed TCP.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/cache.h    | 5 -----
>  fs/nfsd/nfscache.c | 6 ++----
>  2 files changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> index 046b3f048757..b7559c6f2b97 100644
> --- a/fs/nfsd/cache.h
> +++ b/fs/nfsd/cache.h
> @@ -67,11 +67,6 @@ enum {
>  	RC_REPLBUFF,
>  };
>  
> -/*
> - * If requests are retransmitted within this interval, they're
> dropped.
> - */
> -#define RC_DELAY		(HZ/5)
> -
>  /* Cache entries expire after this time period */
>  #define RC_EXPIRE		(120 * HZ)
>  
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index 334f2ad60704..637f87c39183 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -394,7 +394,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  	__wsum			csum;
>  	u32 hash = nfsd_cache_hash(xid);
>  	struct nfsd_drc_bucket *b = &drc_hashtbl[hash];
> -	unsigned long		age;
>  	int type = rqstp->rq_cachetype;
>  	int rtn = RC_DOIT;
>  
> @@ -461,12 +460,11 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
>  found_entry:
>  	nfsdstats.rchits++;
>  	/* We found a matching entry which is either in progress or
> done. */
> -	age = jiffies - rp->c_timestamp;
>  	lru_put_end(b, rp);
>  
>  	rtn = RC_DROPIT;
> -	/* Request being processed or excessive rexmits */
> -	if (rp->c_state == RC_INPROG || age < RC_DELAY)
> +	/* Request being processed */
> +	if (rp->c_state == RC_INPROG)
>  		goto out;
>  
>  	/* From the hall of fame of impractical attacks:

That condition always looked a bit suspicious to me.

Acked-by: Jeff Layton <jlayton@kernel.org>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59686 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751976AbeC1UKn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Mar 2018 16:10:43 -0400
Date: Wed, 28 Mar 2018 16:10:43 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Do not refuse to serve out of cache
Message-ID: <20180328201043.GA6091@fieldses.org>
References: <20180328161801.8360-1-trond.myklebust@primarydata.com>
 <1522264845.5165.1.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1522264845.5165.1.camel@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applying, thanks.

On Wed, Mar 28, 2018 at 03:20:45PM -0400, Jeff Layton wrote:
> On Wed, 2018-03-28 at 12:18 -0400, Trond Myklebust wrote:
> > Currently the knfsd replay cache appears to try to refuse replying to
> > retries that come within 200ms of the cache entry being created. That
> > makes limited sense in today's world of high speed TCP.

Trond gave me some helpful context in person, I may tag that onto the
changelog:

	After a TCP disconnection, a client can very easily reconnect
	and retry an rpc in less than 200ms.  If this logic drops that
	retry, however, the client may be quite slow to retry again.
	This logic is original to the first reply cache implementation
	in 2.1, and may have made more sense for UDP clients that
	retried much more frequently.

	We're still dropping on finding the original request still in
	progress, which can cause the same problem, though it's less
	likely.

	Note svc_check_conn_limits is often the cause of those
	disconnections.  We may want to fix that some day.

--b.

> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfsd/cache.h    | 5 -----
> >  fs/nfsd/nfscache.c | 6 ++----
> >  2 files changed, 2 insertions(+), 9 deletions(-)
> > 
> > diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> > index 046b3f048757..b7559c6f2b97 100644
> > --- a/fs/nfsd/cache.h
> > +++ b/fs/nfsd/cache.h
> > @@ -67,11 +67,6 @@ enum {
> >  	RC_REPLBUFF,
> >  };
> >  
> > -/*
> > - * If requests are retransmitted within this interval, they're
> > dropped.
> > - */
> > -#define RC_DELAY		(HZ/5)
> > -
> >  /* Cache entries expire after this time period */
> >  #define RC_EXPIRE		(120 * HZ)
> >  
> > diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> > index 334f2ad60704..637f87c39183 100644
> > --- a/fs/nfsd/nfscache.c
> > +++ b/fs/nfsd/nfscache.c
> > @@ -394,7 +394,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
> >  	__wsum			csum;
> >  	u32 hash = nfsd_cache_hash(xid);
> >  	struct nfsd_drc_bucket *b = &drc_hashtbl[hash];
> > -	unsigned long		age;
> >  	int type = rqstp->rq_cachetype;
> >  	int rtn = RC_DOIT;
> >  
> > @@ -461,12 +460,11 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
> >  found_entry:
> >  	nfsdstats.rchits++;
> >  	/* We found a matching entry which is either in progress or
> > done. */
> > -	age = jiffies - rp->c_timestamp;
> >  	lru_put_end(b, rp);
> >  
> >  	rtn = RC_DROPIT;
> > -	/* Request being processed or excessive rexmits */
> > -	if (rp->c_state == RC_INPROG || age < RC_DELAY)
> > +	/* Request being processed */
> > +	if (rp->c_state == RC_INPROG)
> >  		goto out;
> >  
> >  	/* From the hall of fame of impractical attacks:
> 
> That condition always looked a bit suspicious to me.
> 
> Acked-by: Jeff Layton <jlayton@kernel.org>

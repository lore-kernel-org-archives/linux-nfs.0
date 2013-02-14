Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25245 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758567Ab3BNWRw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2013 17:17:52 -0500
Date: Thu, 14 Feb 2013 17:17:45 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd: break out comparator into separate function
Message-ID: <20130214171745.3eaef3e8@tlielax.poochiereds.net>
In-Reply-To: <20130214220802.GG8343@fieldses.org>
References: <1360878315-21578-1-git-send-email-jlayton@redhat.com>
	<1360878315-21578-3-git-send-email-jlayton@redhat.com>
	<20130214220802.GG8343@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Feb 2013 17:08:02 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Feb 14, 2013 at 04:45:14PM -0500, Jeff Layton wrote:
> > Break the function that compares the rqstp and checksum against a reply
> > cache entry. While we're at it, track the efficacy of the checksum over
> > the NFS data by tracking the cases where we would have incorrectly
> > matched a DRC entry if we had not tracked it or the length.
> 
> Why the checksum and length, as opposed to just the checksum?
> 
> Seems to me that comparing the length is no more expensive than any of
> the other comparisons (xid, proc, etc.) that we're already doing, so
> we're less likely to wonder whether it's worth it.
> 
> --b.
> 

I guess I was thinking that the length was sort of a property of the
NFS hunk of the packet, so it belonged with the checksum. OTOH, you
have a good point...

It's fairly trivial to change, so I'll plan to respin this once others
have had a chance to comment.

Thanks...

> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfscache.c | 37 +++++++++++++++++++++++++++----------
> >  1 file changed, 27 insertions(+), 10 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> > index 2f9c2d2..bccf74f 100644
> > --- a/fs/nfsd/nfscache.c
> > +++ b/fs/nfsd/nfscache.c
> > @@ -25,6 +25,7 @@ static struct list_head 	lru_head;
> >  static struct kmem_cache	*drc_slab;
> >  static unsigned int		num_drc_entries;
> >  static unsigned int		max_drc_entries;
> > +static unsigned int		csum_misses;
> >  
> >  /*
> >   * Calculate the hash index from an XID.
> > @@ -272,6 +273,30 @@ nfsd_cache_csum(struct svc_rqst *rqstp)
> >  	return csum;
> >  }
> >  
> > +static bool
> > +nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
> > +{
> > +	__be32			xid = rqstp->rq_xid;
> > +	u32			proto =  rqstp->rq_prot,
> > +				vers = rqstp->rq_vers,
> > +				proc = rqstp->rq_proc;
> > +
> > +	/* Check RPC header info first */
> > +	if (xid != rp->c_xid || proc != rp->c_proc ||
> > +	    proto != rp->c_prot || vers != rp->c_vers ||
> > +	    !rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) ||
> > +	    rpc_get_port(svc_addr(rqstp)) != rpc_get_port((struct sockaddr *)&rp->c_addr))
> > +		return false;
> > +
> > +	/* check contents of the NFS data */
> > +	if (rqstp->rq_arg.len != rp->c_len || csum != rp->c_csum) {
> > +		++csum_misses;
> > +		return false;
> > +	}
> > +
> > +	return true;
> > +}
> > +
> >  /*
> >   * Search the request hash for an entry that matches the given rqstp.
> >   * Must be called with cache_lock held. Returns the found entry or
> > @@ -283,18 +308,10 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
> >  	struct svc_cacherep	*rp;
> >  	struct hlist_node	*hn;
> >  	struct hlist_head 	*rh;
> > -	__be32			xid = rqstp->rq_xid;
> > -	u32			proto =  rqstp->rq_prot,
> > -				vers = rqstp->rq_vers,
> > -				proc = rqstp->rq_proc;
> >  
> > -	rh = &cache_hash[request_hash(xid)];
> > +	rh = &cache_hash[request_hash(rqstp->rq_xid)];
> >  	hlist_for_each_entry(rp, hn, rh, c_hash) {
> > -		if (xid == rp->c_xid && proc == rp->c_proc &&
> > -		    proto == rp->c_prot && vers == rp->c_vers &&
> > -		    rqstp->rq_arg.len == rp->c_len && csum == rp->c_csum &&
> > -		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
> > -		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
> > +		if (nfsd_cache_match(rqstp, csum, rp))
> >  			return rp;
> >  	}
> >  	return NULL;
> > -- 
> > 1.7.11.7
> > 


-- 
Jeff Layton <jlayton@redhat.com>

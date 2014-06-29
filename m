Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:51752 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaF2O5F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 10:57:05 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so1134845qgf.29
        for <linux-nfs@vger.kernel.org>; Sun, 29 Jun 2014 07:57:04 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 29 Jun 2014 10:57:02 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 022/117] nfsd: Cache the client that was looked up in
 lookup_clientid()
Message-ID: <20140629105702.2ca9e6ee@f20.localdomain>
In-Reply-To: <20140629121419.GC16150@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<1403810017-16062-23-git-send-email-jlayton@primarydata.com>
	<20140629121419.GC16150@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 29 Jun 2014 05:14:19 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 26, 2014 at 03:12:02PM -0400, Jeff Layton wrote:
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > We want to use the nfsd4_compound_state to cache the nfs4_client
> > in order to optimise away extra lookups of the clid.
> 
> Should mention that this is only for 4.0.  Actually, kooking at
> "nfsd: Allow struct nfsd4_compound_state to cache the nfs4_client" that
> patch seems to mostly be a few random code cleanups that should have
> a different title so it might make more sense to move the caching
> of the client for 4.1+ to this patch as well.
> 
> And please write proper, detailed changelogs :)
> 

Ok, I'll reshuffle those patches and squash them together, and flesh
out the changelog a bit more.

> > +static __be32 lookup_clientid(clientid_t *clid,
> > +		struct nfsd4_compound_state *cstate,
> > +		struct nfsd_net *nn)
> 
> Now that we don't look up the client idea for the normal case but just
> verify it we should probably rename this function to
> nfsd4_verify_clientid or something similar.
> 

Depends on what you mean by "normal case". For v4.0 we do look it up at
least once for each call into here. For v4.1 we get the pointer to the
client "for free" by virtue of looking up the session in the SEQUENCE
op. So, I think we are doing a bit more than just verifying the
clientid here. The name seems appropriate to me.

> While it doesn't belong into this patch:  why don't we cache the
> nfsd_net in the nfsd4_compound_state
> 

I'll go further and say that it doesn't really belong in this series.

If we have a pointer to the client, then we automatically have one to
the struct net. We certainly could cache the nfsd_net pointer and spare
some calls to net_generic, but I'd prefer that that be done as a
separate series on top of this one if it's worthwhile. I this series
brings us enough changes as it is. :)

> >  {
> >  	struct nfs4_client *found;
> >  
> > +	if (cstate->clp != NULL) {
> > +		found = cstate->clp;
> > +		if (!same_clid(&found->cl_clientid, clid))
> > +			return nfserr_stale_clientid;
> > +	} else {
> > +		if (STALE_CLIENTID(clid, nn))
> > +			return nfserr_stale_clientid;
> > +		/*
> > +		 * Usually for v4.1+ we get the client in the SEQUENCE op, so
> 
> Usually implices there might be a case where we don't get it.  Which
> case would that be?
> 

There are certain calls that don't require a SEQUENCE operation:

    BIND_CONN_TO_SESSION
    EXCHANGE_ID
    CREATE_SESSION
    DESTROY_SESSION

Granted, for those we don't use lookup_clientid but the "Usually" still
applies, in general. That said, if it bothers you I'll remove it.

> > +		 * if we don't have one cached already then we know this is for
> > +		 * is for v4.0 and "sessions" will be false.
> > +		 */
> > +		found = find_confirmed_client(clid, false, nn);
> > +		/* Cache the nfs4_client in cstate! */
> > +		if (found) {
> > +			cstate->clp = found;
> > +			atomic_inc(&found->cl_refcount);
> > +		}
> > +	}
> >  	return found ? nfs_ok : nfserr_expired;
> 
> The whole thing could be simplified a little more:
> 
> 	if (cstate->clp) {
> 		if (!same_clid(&cstate->clp->cl_clientid, clid))
> 			return nfserr_stale_clientid;
> 		retur nfs_ok;
> 	}
> 
> 	if (STALE_CLIENTID(clid, nn))
> 		return nfserr_stale_clientid;
> 
> 	found = find_confirmed_client(clid, false, nn);
> 	if (!found)
> 		return nfserr_expired;
> 
> 	cstate->clp = found;
> 	atomic_inc(&found->cl_refcount);
> 	return nfs_ok;
> 

Ok, I'll look into that.

> > +	status = lookup_clientid(&stateid->si_opaque.so_clid, cstate, nn);
> >  	if (status == nfserr_stale_clientid) {
> > +		if (cstate->session)
> >  			return nfserr_bad_stateid;
> >  		return nfserr_stale_stateid;
> >  	}
> 
> Why do we return a different error here for the 4.1+ case?  And why not
> in other places using lookup_clientid?
> 

That change predates this set, but see commit a8a7c6776f8d7478.

nfsd4_lookup_stateid is trying to look up a specific stateid -- the
other places that call lookup_clientid aren't necessarily doing so.
Returning that error may not be applicable there.

-- 
Jeff Layton <jlayton@primarydata.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:50349 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbaF3LCL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 07:02:11 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so1805647qgd.38
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 04:02:10 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 30 Jun 2014 07:02:08 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 018/117] nfsd: clean up nfs4_release_lockowner
Message-ID: <20140630070208.541871b7@f20.localdomain>
In-Reply-To: <20140629070812.414343ae@tlielax.poochiereds.net>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<1403810017-16062-19-git-send-email-jlayton@primarydata.com>
	<20140629064738.GA17739@infradead.org>
	<20140629070812.414343ae@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 29 Jun 2014 07:08:12 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> On Sat, 28 Jun 2014 23:47:38 -0700
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Thu, Jun 26, 2014 at 03:11:58PM -0400, Jeff Layton wrote:
> > > Now that we know that we won't have several lockowners with the same,
> > > owner->data, we can simplify nfs4_release_lockowner and get rid of
> > > the lo_list in the process.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > > ---
> > >  fs/nfsd/nfs4state.c | 44 ++++++++++++++++++++++----------------------
> > >  fs/nfsd/state.h     |  1 -
> > >  2 files changed, 22 insertions(+), 23 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > index 00a1b2cda3ab..a5bb96b97f09 100644
> > > --- a/fs/nfsd/nfs4state.c
> > > +++ b/fs/nfsd/nfs4state.c
> > > @@ -4828,7 +4828,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
> > >  			struct nfsd4_release_lockowner *rlockowner)
> > >  {
> > >  	clientid_t *clid = &rlockowner->rl_clientid;
> > > -	struct nfs4_stateowner *sop;
> > > +	struct nfs4_stateowner *sop = NULL, *tmp;
> > >  	struct nfs4_lockowner *lo;
> > >  	struct nfs4_ol_stateid *stp;
> > >  	struct xdr_netobj *owner = &rlockowner->rl_owner;
> > > @@ -4849,31 +4849,31 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
> > >  	status = nfserr_locks_held;
> > >  	INIT_LIST_HEAD(&matches);
> > 
> > I think matches is unused now.
> > 
> 
> Yep -- good catch.
> 
> > >  
> > > +	/* Find the matching lock stateowner */
> > > +	list_for_each_entry(tmp, &nn->ownerstr_hashtbl[hashval], so_strhash) {
> > > +		if (tmp->so_is_open_owner)
> > > +			continue;
> > > +		if (same_owner_str(tmp, owner, clid)) {
> > > +			sop = tmp;
> > > +			break;
> > >  		}
> > >  	}
> > > +
> > > +	/* No matching owner found, maybe a replay? Just declare victory... */
> > > +	if (!sop) {
> > > +		status = nfs_ok;
> > > +		goto out;
> > > +	}
> > > +
> > > +	lo = lockowner(sop);
> > > +	/* see if there are still any locks associated with it */
> > > +	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
> > > +		if (check_for_locks(stp->st_file, lo))
> > > +			goto out;
> > >  	}
> > > +
> > > +	status = nfs_ok;
> > > +	release_lockowner(lo);
> > 
> > I would seem simpler to do all the work in the loop, something like:
> > 
> > 	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
> > 		if (sop->so_is_open_owner)
> > 			continue;
> > 		if (!same_owner_str(sop, owner, clid))
> > 			continue;
> > 
> > 		list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
> > 			if (check_for_locks(stp->st_file, lockowner(sop))) {
> > 				status = nfserr_locks_held;
> > 				goto out;
> > 			}
> > 		}
> > 
> > 		release_lockowner(lo);
> > 		break;
> > 	}
> > 
> 
> Ok, sure...
> 

I started looking at reorganizing the function like you suggested, and
there's a bit of a problem. Once we start adding in locking this
becomes a bit of a mess, at least until the ownerstr_hashtbl gets moved
into the nfs4_client.

What I'd suggest is that we go ahead and take this patch as-is for now,
and I'll do the reorganization of the function along those lines in a
later patch once we only need to deal with the cl_lock there. Sound ok?

-- 
Jeff Layton <jlayton@primarydata.com>

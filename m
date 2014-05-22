Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:45473 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbaEVMUw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2014 08:20:52 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so5515596qcv.10
        for <linux-nfs@vger.kernel.org>; Thu, 22 May 2014 05:20:52 -0700 (PDT)
Date: Thu, 22 May 2014 08:20:48 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Bruce Fields <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 19/70] NFSd: Allow lockowners to hold several stateids
Message-ID: <20140522082048.75cb270c@tlielax.poochiereds.net>
In-Reply-To: <20140507152006.GC4240@fieldses.org>
References: <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
	<20140507152006.GC4240@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 7 May 2014 11:20:06 -0400
Bruce Fields <bfields@fieldses.org> wrote:

> Then did "NFSd: Lock owners are not per open stateid" introduce a
> temporary regression?
> 
> --b.
> 

No, I don't think it does. Even after that patch, you still only have
one lock stateid per lockowner. That patch is just adding some plumbing
that will eventually allow you to break that limitation.

That said, there are some problems with locking during the traversal of
the so_stateids list in this set that I'm looking at today.

> On Fri, Apr 18, 2014 at 02:44:13PM -0400, Trond Myklebust wrote:
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfsd/nfs4state.c | 46 +++++++++++++++++++++++++++++-----------------
> >  1 file changed, 29 insertions(+), 17 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 0809e8355577..dad2f7b511b8 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4390,6 +4390,19 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
> >  	return stp;
> >  }
> >  
> > +static struct nfs4_ol_stateid *
> > +find_lock_stateid(struct nfs4_lockowner *lo, struct inode *inode)
> > +{
> > +	struct nfs4_ol_stateid *lst;
> > +
> > +	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
> > +		if (lst->st_file->fi_inode == inode)
> > +			return lst;
> > +	}
> > +	return NULL;
> > +}
> > +
> > +
> >  static int
> >  check_lock_length(u64 offset, u64 length)
> >  {
> > @@ -4419,25 +4432,24 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
> >  
> >  	lo = find_lockowner_str(fi->fi_inode, &cl->cl_clientid,
> >  				&lock->v.new.owner, nn);
> > -	if (lo) {
> > -		if (!cstate->minorversion)
> > -			return nfserr_bad_seqid;
> > -		/* XXX: a lockowner always has exactly one stateid: */
> > -		*lst = list_first_entry(&lo->lo_owner.so_stateids,
> > -				struct nfs4_ol_stateid, st_perstateowner);
> > -		return nfs_ok;
> > +	if (!lo) {
> > +		strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
> > +				&lock->v.new.owner);
> > +		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
> > +		if (lo == NULL)
> > +			return nfserr_jukebox;
> >  	}
> > -	strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
> > -			&lock->v.new.owner);
> > -	lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
> > -	if (lo == NULL)
> > -		return nfserr_jukebox;
> > -	*lst = alloc_init_lock_stateid(lo, fi, ost);
> > +	if (!cstate->minorversion)
> > +		return nfserr_bad_seqid;
> > +	*lst = find_lock_stateid(lo, fi->fi_inode);
> >  	if (*lst == NULL) {
> > -		release_lockowner(lo);
> > -		return nfserr_jukebox;
> > +		*lst = alloc_init_lock_stateid(lo, fi, ost);
> > +		if (*lst == NULL) {
> > +			release_lockowner_if_empty(lo);
> > +			return nfserr_jukebox;
> > +		}
> > +		*new = true;
> >  	}
> > -	*new = true;
> >  	return nfs_ok;
> >  }
> >  
> > @@ -4596,7 +4608,7 @@ out:
> >  	if (filp)
> >  		fput(filp);
> >  	if (status && new_state)
> > -		release_lockowner(lock_sop);
> > +		release_lockowner_if_empty(lock_sop);
> >  	nfsd4_bump_seqid(cstate, status);
> >  	nfs4_unlock_state();
> >  	if (file_lock)
> > -- 
> > 1.9.0
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@poochiereds.net>

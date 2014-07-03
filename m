Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:55873 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758556AbaGCPUx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 11:20:53 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so364301qcy.15
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 08:20:52 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 3 Jul 2014 11:20:50 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
Message-ID: <20140703112050.61c1561d@tlielax.poochiereds.net>
In-Reply-To: <20140703151819.GC24322@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-16-git-send-email-jlayton@primarydata.com>
	<20140703151819.GC24322@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Jul 2014 11:18:19 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 30, 2014 at 11:48:44AM -0400, Jeff Layton wrote:
> > @@ -2997,6 +3009,38 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
> >  	return nfserr_bad_seqid;
> >  }
> >  
> > +static __be32 lookup_clientid(clientid_t *clid,
> > +		struct nfsd4_compound_state *cstate,
> > +		struct nfsd_net *nn)
> > +{
> > +	struct nfs4_client *found;
> > +
> > +	if (cstate->clp) {
> > +		found = cstate->clp;
> > +		if (!same_clid(&found->cl_clientid, clid))
> > +			return nfserr_stale_clientid;
> 
> That's new behavior, isn't it?
> 

Yeah, I suppose it is, but it's hard to understand a valid use-case for
sending multiple ops in a compound with different clientids. Certainly
no well-behaved client would do that, would it? (Hmm, that might be an
interesting pynfs test, come to think of it).

> But sending a single compound that references multiple clients sounds
> nuts even in the 4.0 case, OK.  Applying.
> 
> (And I've merged all but the delegation locking change up through here
> so far.)
> 
> --b.
> 

Thanks!


> > +		return nfs_ok;
> > +	}
> > +
> > +	if (STALE_CLIENTID(clid, nn))
> > +		return nfserr_stale_clientid;
> > +
> > +	/*
> > +	 * For v4.1+ we get the client in the SEQUENCE op. If we
> > don't have one
> > +	 * cached already then we know this is for is for v4.0 and
> > "sessions"
> > +	 * will be false.
> > +	 */
> > +	WARN_ON_ONCE(cstate->session);
> > +	found = find_confirmed_client(clid, false, nn);
> > +	if (!found)
> > +		return nfserr_expired;
> > +
> > +	/* Cache the nfs4_client in cstate! */
> > +	cstate->clp = found;
> > +	atomic_inc(&found->cl_refcount);
> > +	return nfs_ok;
> > +}
> > +
> >  __be32
> >  nfsd4_process_open1(struct nfsd4_compound_state *cstate,
> >  		    struct nfsd4_open *open, struct nfsd_net *nn)
> > @@ -3509,18 +3553,6 @@ void nfsd4_cleanup_open_state(struct
> > nfsd4_open *open, __be32 status) free_generic_stateid(open->op_stp);
> >  }
> >  
> > -static __be32 lookup_clientid(clientid_t *clid, bool session,
> > struct nfsd_net *nn, struct nfs4_client **clp) -{
> > -	struct nfs4_client *found;
> > -
> > -	if (STALE_CLIENTID(clid, nn))
> > -		return nfserr_stale_clientid;
> > -	found = find_confirmed_client(clid, session, nn);
> > -	if (clp)
> > -		*clp = found;
> > -	return found ? nfs_ok : nfserr_expired;
> > -}
> > -
> >  __be32
> >  nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state
> > *cstate, clientid_t *clid)
> > @@ -3532,9 +3564,10 @@ nfsd4_renew(struct svc_rqst *rqstp, struct
> > nfsd4_compound_state *cstate, nfs4_lock_state();
> >  	dprintk("process_renew(%08x/%08x): starting\n", 
> >  			clid->cl_boot, clid->cl_id);
> > -	status = lookup_clientid(clid, cstate->minorversion, nn,
> > &clp);
> > +	status = lookup_clientid(clid, cstate, nn);
> >  	if (status)
> >  		goto out;
> > +	clp = cstate->clp;
> >  	status = nfserr_cb_path_down;
> >  	if (!list_empty(&clp->cl_delegations)
> >  			&& clp->cl_cb_state != NFSD4_CB_UP)
> > @@ -3797,22 +3830,19 @@ nfsd4_lookup_stateid(struct
> > nfsd4_compound_state *cstate, stateid_t *stateid, unsigned char
> > typemask, struct nfs4_stid **s, struct nfsd_net *nn)
> >  {
> > -	struct nfs4_client *cl;
> >  	__be32 status;
> > -	bool sessions = cstate->minorversion != 0;
> >  
> >  	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
> >  		return nfserr_bad_stateid;
> > -	status = lookup_clientid(&stateid->si_opaque.so_clid,
> > sessions,
> > -							nn, &cl);
> > +	status = lookup_clientid(&stateid->si_opaque.so_clid,
> > cstate, nn); if (status == nfserr_stale_clientid) {
> > -		if (sessions)
> > +		if (cstate->session)
> >  			return nfserr_bad_stateid;
> >  		return nfserr_stale_stateid;
> >  	}
> >  	if (status)
> >  		return status;
> > -	*s = find_stateid_by_type(cl, stateid, typemask);
> > +	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
> >  	if (!*s)
> >  		return nfserr_bad_stateid;
> >  	return nfs_ok;
> > @@ -4662,7 +4692,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct
> > nfsd4_compound_state *cstate, nfs4_lock_state();
> >  
> >  	if (!nfsd4_has_session(cstate)) {
> > -		status = lookup_clientid(&lockt->lt_clientid,
> > false, nn, NULL);
> > +		status = lookup_clientid(&lockt->lt_clientid,
> > cstate, nn); if (status)
> >  			goto out;
> >  	}
> > @@ -4831,7 +4861,7 @@ nfsd4_release_lockowner(struct svc_rqst
> > *rqstp, 
> >  	nfs4_lock_state();
> >  
> > -	status = lookup_clientid(clid, cstate->minorversion, nn,
> > NULL);
> > +	status = lookup_clientid(clid, cstate, nn);
> >  	if (status)
> >  		goto out;
> >  
> > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> > index 7d8af164523b..312f6483a48e 100644
> > --- a/fs/nfsd/xdr4.h
> > +++ b/fs/nfsd/xdr4.h
> > @@ -55,6 +55,7 @@ struct nfsd4_compound_state {
> >  	struct svc_fh		current_fh;
> >  	struct svc_fh		save_fh;
> >  	struct nfs4_stateowner	*replay_owner;
> > +	struct nfs4_client	*clp;
> >  	/* For sessions DRC */
> >  	struct nfsd4_session	*session;
> >  	struct nfsd4_slot	*slot;
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>

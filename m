Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:35808 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbbI2V0n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Sep 2015 17:26:43 -0400
Received: by qgt47 with SMTP id 47so18733140qgt.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2015 14:26:42 -0700 (PDT)
Date: Tue, 29 Sep 2015 17:26:38 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Andrew W Elble <aweits@rit.edu>
Subject: Re: [PATCH] nfsd: serialize state seqid morphing operations
Message-ID: <20150929172638.6cc775ff@tlielax.poochiereds.net>
In-Reply-To: <20150929211155.GI3190@fieldses.org>
References: <1442490428-29487-1-git-send-email-jeff.layton@primarydata.com>
	<20150929211155.GI3190@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 29 Sep 2015 17:11:55 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Sep 17, 2015 at 07:47:08AM -0400, Jeff Layton wrote:
> > Andrew was seeing a race occur when an OPEN and OPEN_DOWNGRADE were
> > running in parallel. The server would receive the OPEN_DOWNGRADE first
> > and check its seqid, but then an OPEN would race in and bump it. The
> > OPEN_DOWNGRADE would then complete and bump the seqid again.  The result
> > was that the OPEN_DOWNGRADE would be applied after the OPEN, even though
> > it should have been rejected since the seqid changed.
> > 
> > The only recourse we have here I think is to serialize operations that
> > bump the seqid in a stateid, particularly when we're given a seqid in
> > the call. To address this, we add a new rw_semaphore to the
> > nfs4_ol_stateid struct. We do a down_write prior to checking the seqid
> > after looking up the stateid to ensure that nothing else is going to
> > bump it while we're operating on it.
> > 
> > In the case of OPEN, we do a down_read, as the call doesn't contain a
> > seqid. Those can run in parallel -- we just need to serialize them when
> > there is a concurrent OPEN_DOWNGRADE or CLOSE.
> > 
> > LOCK and LOCKU however always take the write lock as there is no
> > opportunity for parallelizing those.
> > 
> > Reported-and-Tested-by: Andrew W Elble <aweits@rit.edu>
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4state.c | 33 ++++++++++++++++++++++++++++-----
> >  fs/nfsd/state.h     | 19 ++++++++++---------
> >  2 files changed, 38 insertions(+), 14 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 0f1d5691b795..1b39edf10b67 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3360,6 +3360,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> >  	stp->st_access_bmap = 0;
> >  	stp->st_deny_bmap = 0;
> >  	stp->st_openstp = NULL;
> > +	init_rwsem(&stp->st_rwsem);
> >  	spin_lock(&oo->oo_owner.so_client->cl_lock);
> >  	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> >  	spin_lock(&fp->fi_lock);
> > @@ -4187,15 +4188,20 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
> >  	 */
> >  	if (stp) {
> >  		/* Stateid was found, this is an OPEN upgrade */
> > +		down_read(&stp->st_rwsem);
> >  		status = nfs4_upgrade_open(rqstp, fp, current_fh, stp, open);
> > -		if (status)
> > +		if (status) {
> > +			up_read(&stp->st_rwsem);
> >  			goto out;
> > +		}
> >  	} else {
> >  		stp = open->op_stp;
> >  		open->op_stp = NULL;
> >  		init_open_stateid(stp, fp, open);
> > +		down_read(&stp->st_rwsem);
> >  		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
> >  		if (status) {
> > +			up_read(&stp->st_rwsem);
> >  			release_open_stateid(stp);
> >  			goto out;
> >  		}
> > @@ -4207,6 +4213,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
> >  	}
> >  	update_stateid(&stp->st_stid.sc_stateid);
> >  	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
> > +	up_read(&stp->st_rwsem);
> >  
> >  	if (nfsd4_has_session(&resp->cstate)) {
> >  		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
> 
> The patch looks good, but:
> 
> Does it matter that we don't have an exclusive lock over that
> update_stateid?
> 
> I think there's at least one small bug there:
> 
> 	static inline void update_stateid(stateid_t *stateid)
> 	{       
> 	        stateid->si_generation++;
> 	        /* Wraparound recommendation from 3530bis-13 9.1.3.2: */
> 	        if (stateid->si_generation == 0)
> 	                stateid->si_generation = 1;
> 	}
> 
> The si_generation increment isn't atomic, and even if it were the wraparound
> handling definitely wouldn't.  That's a pretty small race.
> 

Yeah, I eyeballed that some time ago and convinced myself it was ok,
but I think you're right that there is a potential race there. That
counter sort of seems like something that ought to use atomics in some
fashion. The wraparound is tricky, but could be done locklessly with
cmpxchg, I think...

> Does it also matter that this si_generation update isn't atomic with respect
> to the actual open and upgrade of the share bits?
> 

I don't think so. If you race with a concurrent OPEN upgrade, the
server will either have what you requested or a superset of that. It's
only OPEN_DOWNGRADE and CLOSE that need full serialization.

> --b.
> 
> > @@ -4819,10 +4826,13 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
> >  		 * revoked delegations are kept only for free_stateid.
> >  		 */
> >  		return nfserr_bad_stateid;
> > +	down_write(&stp->st_rwsem);
> >  	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
> > -	if (status)
> > -		return status;
> > -	return nfs4_check_fh(current_fh, &stp->st_stid);
> > +	if (status == nfs_ok)
> > +		status = nfs4_check_fh(current_fh, &stp->st_stid);
> > +	if (status != nfs_ok)
> > +		up_write(&stp->st_rwsem);
> > +	return status;
> >  }
> >  
> >  /* 
> > @@ -4869,6 +4879,7 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
> >  		return status;
> >  	oo = openowner(stp->st_stateowner);
> >  	if (!(oo->oo_flags & NFS4_OO_CONFIRMED)) {
> > +		up_write(&stp->st_rwsem);
> >  		nfs4_put_stid(&stp->st_stid);
> >  		return nfserr_bad_stateid;
> >  	}
> > @@ -4899,11 +4910,14 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		goto out;
> >  	oo = openowner(stp->st_stateowner);
> >  	status = nfserr_bad_stateid;
> > -	if (oo->oo_flags & NFS4_OO_CONFIRMED)
> > +	if (oo->oo_flags & NFS4_OO_CONFIRMED) {
> > +		up_write(&stp->st_rwsem);
> >  		goto put_stateid;
> > +	}
> >  	oo->oo_flags |= NFS4_OO_CONFIRMED;
> >  	update_stateid(&stp->st_stid.sc_stateid);
> >  	memcpy(&oc->oc_resp_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
> > +	up_write(&stp->st_rwsem);
> >  	dprintk("NFSD: %s: success, seqid=%d stateid=" STATEID_FMT "\n",
> >  		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stid.sc_stateid));
> >  
> > @@ -4982,6 +4996,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
> >  	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
> >  	status = nfs_ok;
> >  put_stateid:
> > +	up_write(&stp->st_rwsem);
> >  	nfs4_put_stid(&stp->st_stid);
> >  out:
> >  	nfsd4_bump_seqid(cstate, status);
> > @@ -5035,6 +5050,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		goto out; 
> >  	update_stateid(&stp->st_stid.sc_stateid);
> >  	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
> > +	up_write(&stp->st_rwsem);
> >  
> >  	nfsd4_close_open_stateid(stp);
> >  
> > @@ -5260,6 +5276,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
> >  	stp->st_access_bmap = 0;
> >  	stp->st_deny_bmap = open_stp->st_deny_bmap;
> >  	stp->st_openstp = open_stp;
> > +	init_rwsem(&stp->st_rwsem);
> >  	list_add(&stp->st_locks, &open_stp->st_locks);
> >  	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
> >  	spin_lock(&fp->fi_lock);
> > @@ -5428,6 +5445,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  					&open_stp, nn);
> >  		if (status)
> >  			goto out;
> > +		up_write(&open_stp->st_rwsem);
> >  		open_sop = openowner(open_stp->st_stateowner);
> >  		status = nfserr_bad_stateid;
> >  		if (!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
> > @@ -5435,6 +5453,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  			goto out;
> >  		status = lookup_or_create_lock_state(cstate, open_stp, lock,
> >  							&lock_stp, &new);
> > +		if (status == nfs_ok)
> > +			down_write(&lock_stp->st_rwsem);
> >  	} else {
> >  		status = nfs4_preprocess_seqid_op(cstate,
> >  				       lock->lk_old_lock_seqid,
> > @@ -5540,6 +5560,8 @@ out:
> >  		    seqid_mutating_err(ntohl(status)))
> >  			lock_sop->lo_owner.so_seqid++;
> >  
> > +		up_write(&lock_stp->st_rwsem);
> > +
> >  		/*
> >  		 * If this is a new, never-before-used stateid, and we are
> >  		 * returning an error, then just go ahead and release it.
> > @@ -5709,6 +5731,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  fput:
> >  	fput(filp);
> >  put_stateid:
> > +	up_write(&stp->st_rwsem);
> >  	nfs4_put_stid(&stp->st_stid);
> >  out:
> >  	nfsd4_bump_seqid(cstate, status);
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index 583ffc13cae2..31bde12feefe 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -534,15 +534,16 @@ struct nfs4_file {
> >   * Better suggestions welcome.
> >   */
> >  struct nfs4_ol_stateid {
> > -	struct nfs4_stid    st_stid; /* must be first field */
> > -	struct list_head              st_perfile;
> > -	struct list_head              st_perstateowner;
> > -	struct list_head              st_locks;
> > -	struct nfs4_stateowner      * st_stateowner;
> > -	struct nfs4_clnt_odstate    * st_clnt_odstate;
> > -	unsigned char                 st_access_bmap;
> > -	unsigned char                 st_deny_bmap;
> > -	struct nfs4_ol_stateid         * st_openstp;
> > +	struct nfs4_stid		st_stid;
> > +	struct list_head		st_perfile;
> > +	struct list_head		st_perstateowner;
> > +	struct list_head		st_locks;
> > +	struct nfs4_stateowner		*st_stateowner;
> > +	struct nfs4_clnt_odstate	*st_clnt_odstate;
> > +	unsigned char			st_access_bmap;
> > +	unsigned char			st_deny_bmap;
> > +	struct nfs4_ol_stateid		*st_openstp;
> > +	struct rw_semaphore		st_rwsem;
> >  };
> >  
> >  static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)
> > -- 
> > 2.4.3


-- 
Jeff Layton <jlayton@poochiereds.net>

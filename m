Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35455 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031AbbKJVxP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Nov 2015 16:53:15 -0500
Date: Tue, 10 Nov 2015 16:53:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Andrew Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v4] nfsd: fix race with open / open upgrade stateids
Message-ID: <20151110215313.GB19379@fieldses.org>
References: <1446774163-44620-1-git-send-email-aweits@rit.edu>
 <20151106063037.27bf2fc8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151106063037.27bf2fc8@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 06, 2015 at 06:30:37AM -0500, Jeff Layton wrote:
> On Thu,  5 Nov 2015 20:42:43 -0500
> Andrew Elble <aweits@rit.edu> wrote:
> 
> > We observed multiple open stateids on the server for files that
> > seemingly should have been closed.
> > 
> > nfsd4_process_open2() tests for the existence of a preexisting
> > stateid. If one is not found, the locks are dropped and a new
> > one is created. The problem is that init_open_stateid(), which
> > is also responsible for hashing the newly initialized stateid,
> > doesn't check to see if another open has raced in and created
> > a matching stateid. This fix is to enable init_open_stateid() to
> > return the matching stateid and have nfsd4_process_open2()
> > swap to that stateid and switch to the open upgrade path.
> > In testing this patch, coverage to the newly created
> > path indicates that the race was indeed happening.
> > 
> > Signed-off-by: Andrew Elble <aweits@rit.edu>
> > ---
> > 
> >  v4: de-nit-ify
> > 
> >  fs/nfsd/nfs4state.c | 78 ++++++++++++++++++++++++++++++++++++-----------------
> >  1 file changed, 53 insertions(+), 25 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 637d1e92c606..8b29c2e1d7af 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3345,6 +3345,27 @@ static const struct nfs4_stateowner_operations openowner_ops = {
> >  	.so_free =	nfs4_free_openowner,
> >  };
> >  
> > +static struct nfs4_ol_stateid *
> > +nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
> > +{
> > +	struct nfs4_ol_stateid *local, *ret = NULL;
> > +	struct nfs4_openowner *oo = open->op_openowner;
> > +
> > +	lockdep_assert_held(&fp->fi_lock);
> > +
> > +	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
> > +		/* ignore lock owners */
> > +		if (local->st_stateowner->so_is_open_owner == 0)
> > +			continue;
> > +		if (local->st_stateowner == &oo->oo_owner) {
> > +			ret = local;
> > +			atomic_inc(&ret->st_stid.sc_count);
> > +			break;
> > +		}
> > +	}
> > +	return ret;
> > +}
> > +
> >  static struct nfs4_openowner *
> >  alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
> >  			   struct nfsd4_compound_state *cstate)
> > @@ -3376,9 +3397,20 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
> >  	return ret;
> >  }
> >  
> > -static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
> > +static struct nfs4_ol_stateid *
> > +init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> > +		struct nfsd4_open *open)
> > +{
> > +
> >  	struct nfs4_openowner *oo = open->op_openowner;
> > +	struct nfs4_ol_stateid *retstp = NULL;
> >  
> > +	spin_lock(&oo->oo_owner.so_client->cl_lock);
> > +	spin_lock(&fp->fi_lock);
> > +
> > +	retstp = nfsd4_find_existing_open(fp, open);
> > +	if (retstp)
> > +		goto out_unlock;
> >  	atomic_inc(&stp->st_stid.sc_count);
> >  	stp->st_stid.sc_type = NFS4_OPEN_STID;
> >  	INIT_LIST_HEAD(&stp->st_locks);
> > @@ -3389,12 +3421,13 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> >  	stp->st_deny_bmap = 0;
> >  	stp->st_openstp = NULL;
> >  	init_rwsem(&stp->st_rwsem);
> > -	spin_lock(&oo->oo_owner.so_client->cl_lock);
> >  	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> > -	spin_lock(&fp->fi_lock);
> >  	list_add(&stp->st_perfile, &fp->fi_stateids);
> > +
> > +out_unlock:
> >  	spin_unlock(&fp->fi_lock);
> >  	spin_unlock(&oo->oo_owner.so_client->cl_lock);
> > +	return retstp;
> >  }
> >  
> >  /*
> > @@ -3805,27 +3838,6 @@ out:
> >  	return nfs_ok;
> >  }
> >  
> > -static struct nfs4_ol_stateid *
> > -nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
> > -{
> > -	struct nfs4_ol_stateid *local, *ret = NULL;
> > -	struct nfs4_openowner *oo = open->op_openowner;
> > -
> > -	spin_lock(&fp->fi_lock);
> > -	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
> > -		/* ignore lock owners */
> > -		if (local->st_stateowner->so_is_open_owner == 0)
> > -			continue;
> > -		if (local->st_stateowner == &oo->oo_owner) {
> > -			ret = local;
> > -			atomic_inc(&ret->st_stid.sc_count);
> > -			break;
> > -		}
> > -	}
> > -	spin_unlock(&fp->fi_lock);
> > -	return ret;
> > -}
> > -
> >  static inline int nfs4_access_to_access(u32 nfs4_access)
> >  {
> >  	int flags = 0;
> > @@ -4189,6 +4201,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
> >  	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
> >  	struct nfs4_file *fp = NULL;
> >  	struct nfs4_ol_stateid *stp = NULL;
> > +	struct nfs4_ol_stateid *swapstp = NULL;
> >  	struct nfs4_delegation *dp = NULL;
> >  	__be32 status;
> >  
> > @@ -4202,7 +4215,9 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
> >  		status = nfs4_check_deleg(cl, open, &dp);
> >  		if (status)
> >  			goto out;
> > +		spin_lock(&fp->fi_lock);
> >  		stp = nfsd4_find_existing_open(fp, open);
> > +		spin_unlock(&fp->fi_lock);
> >  	} else {
> >  		open->op_file = NULL;
> >  		status = nfserr_bad_stateid;
> > @@ -4225,7 +4240,19 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
> >  	} else {
> >  		stp = open->op_stp;
> >  		open->op_stp = NULL;
> > -		init_open_stateid(stp, fp, open);
> > +		swapstp = init_open_stateid(stp, fp, open);
> > +		if (swapstp) {
> > +			nfs4_put_stid(&stp->st_stid);
> > +			stp = swapstp;
> > +			down_read(&stp->st_rwsem);
> > +			status = nfs4_upgrade_open(rqstp, fp, current_fh,
> > +						stp, open);
> > +			if (status) {
> > +				up_read(&stp->st_rwsem);
> > +				goto out;
> > +			}
> > +			goto upgrade_out;
> > +		}
> >  		down_read(&stp->st_rwsem);
> >  		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
> >  		if (status) {
> > @@ -4239,6 +4266,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
> >  		if (stp->st_clnt_odstate == open->op_odstate)
> >  			open->op_odstate = NULL;
> >  	}
> > +upgrade_out:
> >  	nfs4_inc_and_copy_stateid(&open->op_stateid, &stp->st_stid);
> >  	up_read(&stp->st_rwsem);
> >  
> 
> Looks good. My only (minor) nit is that we end up having to take the
> fi_lock twice -- once to search for the existing open and once to add
> the new open stateid when it's not found. Could that be done better?
> Probably tough to do so since we also need the cl_lock to hash the
> thing, but it might be possible to make this a bit less convoluted...
> 
> In any case, this looks like a valid bugfix and any cleanup in that
> area can be done in an incremental patch on top of this:
> 
> Reviewed-by: Jeff Layton <jlayton@poochiereds.net>

Thanks, applying for 4.4--b.

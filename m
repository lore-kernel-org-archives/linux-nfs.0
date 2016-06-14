Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56442 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbcFNPrA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2016 11:47:00 -0400
Date: Tue, 14 Jun 2016 11:46:59 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: Always lock state exclusively.
Message-ID: <20160614154659.GE25973@fieldses.org>
References: <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru>
 <1465781187-824653-1-git-send-email-green@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1465781187-824653-1-git-send-email-green@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 12, 2016 at 09:26:27PM -0400, Oleg Drokin wrote:
> It used to be the case that state had an rwlock that was locked for write
> by downgrades, but for read for upgrades (opens). Well, the problem is
> if there are two competing opens for the same state, they step on
> each other toes potentially leading to leaking file descriptors
> from the state structure, since access mode is a bitmap only set once.
> 
> Extend the holding region around in nfsd4_process_open2() to avoid
> racing entry into nfs4_get_vfs_file().
> Make init_open_stateid() return with locked stateid to be unlocked
> by the caller.
> 
> Now this version held up pretty well in my testing for 24 hours.
> It still does not address the situation if during one of the racing
> nfs4_get_vfs_file() calls we are getting an error from one (first?)
> of them. This is to be addressed in a separate patch after having a
> solid reproducer (potentially using some fault injection).
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  fs/nfsd/nfs4state.c | 47 +++++++++++++++++++++++++++--------------------
>  fs/nfsd/state.h     |  2 +-
>  2 files changed, 28 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f5f82e1..fa5fb5a 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3487,6 +3487,10 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
>  	struct nfs4_openowner *oo = open->op_openowner;
>  	struct nfs4_ol_stateid *retstp = NULL;
>  
> +	/* We are moving these outside of the spinlocks to avoid the warnings */
> +	mutex_init(&stp->st_mutex);
> +	mutex_lock(&stp->st_mutex);

A mutex_init_locked() primitive might also be convenient here.

You could also take the two previous lines from the caller into this
function instead of passing in stp, that might simplify the code.
(Haven't checked.)

--b.

> +
>  	spin_lock(&oo->oo_owner.so_client->cl_lock);
>  	spin_lock(&fp->fi_lock);
>  
> @@ -3502,13 +3506,14 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = 0;
>  	stp->st_openstp = NULL;
> -	init_rwsem(&stp->st_rwsem);
>  	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
>  	list_add(&stp->st_perfile, &fp->fi_stateids);
>  
>  out_unlock:
>  	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&oo->oo_owner.so_client->cl_lock);
> +	if (retstp)
> +		mutex_lock(&retstp->st_mutex);
>  	return retstp;
>  }
>  
> @@ -4335,32 +4340,34 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	 */
>  	if (stp) {
>  		/* Stateid was found, this is an OPEN upgrade */
> -		down_read(&stp->st_rwsem);
> +		mutex_lock(&stp->st_mutex);
>  		status = nfs4_upgrade_open(rqstp, fp, current_fh, stp, open);
>  		if (status) {
> -			up_read(&stp->st_rwsem);
> +			mutex_unlock(&stp->st_mutex);
>  			goto out;
>  		}
>  	} else {
>  		stp = open->op_stp;
>  		open->op_stp = NULL;
> +		/*
> +		 * init_open_stateid() either returns a locked stateid
> +		 * it found, or initializes and locks the new one we passed in
> +		 */
>  		swapstp = init_open_stateid(stp, fp, open);
>  		if (swapstp) {
>  			nfs4_put_stid(&stp->st_stid);
>  			stp = swapstp;
> -			down_read(&stp->st_rwsem);
>  			status = nfs4_upgrade_open(rqstp, fp, current_fh,
>  						stp, open);
>  			if (status) {
> -				up_read(&stp->st_rwsem);
> +				mutex_unlock(&stp->st_mutex);
>  				goto out;
>  			}
>  			goto upgrade_out;
>  		}
> -		down_read(&stp->st_rwsem);
>  		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
>  		if (status) {
> -			up_read(&stp->st_rwsem);
> +			mutex_unlock(&stp->st_mutex);
>  			release_open_stateid(stp);
>  			goto out;
>  		}
> @@ -4372,7 +4379,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	}
>  upgrade_out:
>  	nfs4_inc_and_copy_stateid(&open->op_stateid, &stp->st_stid);
> -	up_read(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  
>  	if (nfsd4_has_session(&resp->cstate)) {
>  		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
> @@ -4977,12 +4984,12 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
>  		 * revoked delegations are kept only for free_stateid.
>  		 */
>  		return nfserr_bad_stateid;
> -	down_write(&stp->st_rwsem);
> +	mutex_lock(&stp->st_mutex);
>  	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
>  	if (status == nfs_ok)
>  		status = nfs4_check_fh(current_fh, &stp->st_stid);
>  	if (status != nfs_ok)
> -		up_write(&stp->st_rwsem);
> +		mutex_unlock(&stp->st_mutex);
>  	return status;
>  }
>  
> @@ -5030,7 +5037,7 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
>  		return status;
>  	oo = openowner(stp->st_stateowner);
>  	if (!(oo->oo_flags & NFS4_OO_CONFIRMED)) {
> -		up_write(&stp->st_rwsem);
> +		mutex_unlock(&stp->st_mutex);
>  		nfs4_put_stid(&stp->st_stid);
>  		return nfserr_bad_stateid;
>  	}
> @@ -5062,12 +5069,12 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	oo = openowner(stp->st_stateowner);
>  	status = nfserr_bad_stateid;
>  	if (oo->oo_flags & NFS4_OO_CONFIRMED) {
> -		up_write(&stp->st_rwsem);
> +		mutex_unlock(&stp->st_mutex);
>  		goto put_stateid;
>  	}
>  	oo->oo_flags |= NFS4_OO_CONFIRMED;
>  	nfs4_inc_and_copy_stateid(&oc->oc_resp_stateid, &stp->st_stid);
> -	up_write(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  	dprintk("NFSD: %s: success, seqid=%d stateid=" STATEID_FMT "\n",
>  		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stid.sc_stateid));
>  
> @@ -5143,7 +5150,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
>  	nfs4_inc_and_copy_stateid(&od->od_stateid, &stp->st_stid);
>  	status = nfs_ok;
>  put_stateid:
> -	up_write(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  	nfs4_put_stid(&stp->st_stid);
>  out:
>  	nfsd4_bump_seqid(cstate, status);
> @@ -5196,7 +5203,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	if (status)
>  		goto out; 
>  	nfs4_inc_and_copy_stateid(&close->cl_stateid, &stp->st_stid);
> -	up_write(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  
>  	nfsd4_close_open_stateid(stp);
>  
> @@ -5422,7 +5429,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = open_stp->st_deny_bmap;
>  	stp->st_openstp = open_stp;
> -	init_rwsem(&stp->st_rwsem);
> +	mutex_init(&stp->st_mutex);
>  	list_add(&stp->st_locks, &open_stp->st_locks);
>  	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
>  	spin_lock(&fp->fi_lock);
> @@ -5591,7 +5598,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  					&open_stp, nn);
>  		if (status)
>  			goto out;
> -		up_write(&open_stp->st_rwsem);
> +		mutex_unlock(&open_stp->st_mutex);
>  		open_sop = openowner(open_stp->st_stateowner);
>  		status = nfserr_bad_stateid;
>  		if (!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
> @@ -5600,7 +5607,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		status = lookup_or_create_lock_state(cstate, open_stp, lock,
>  							&lock_stp, &new);
>  		if (status == nfs_ok)
> -			down_write(&lock_stp->st_rwsem);
> +			mutex_lock(&lock_stp->st_mutex);
>  	} else {
>  		status = nfs4_preprocess_seqid_op(cstate,
>  				       lock->lk_old_lock_seqid,
> @@ -5704,7 +5711,7 @@ out:
>  		    seqid_mutating_err(ntohl(status)))
>  			lock_sop->lo_owner.so_seqid++;
>  
> -		up_write(&lock_stp->st_rwsem);
> +		mutex_unlock(&lock_stp->st_mutex);
>  
>  		/*
>  		 * If this is a new, never-before-used stateid, and we are
> @@ -5874,7 +5881,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  fput:
>  	fput(filp);
>  put_stateid:
> -	up_write(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  	nfs4_put_stid(&stp->st_stid);
>  out:
>  	nfsd4_bump_seqid(cstate, status);
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 986e51e..64053ea 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -535,7 +535,7 @@ struct nfs4_ol_stateid {
>  	unsigned char			st_access_bmap;
>  	unsigned char			st_deny_bmap;
>  	struct nfs4_ol_stateid		*st_openstp;
> -	struct rw_semaphore		st_rwsem;
> +	struct mutex			st_mutex;
>  };
>  
>  static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)
> -- 
> 2.7.4

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34732 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbcFIKNe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 06:13:34 -0400
Received: by mail-yw0-f193.google.com with SMTP id j74so4169379ywg.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2016 03:13:34 -0700 (PDT)
Message-ID: <1465467210.2666.4.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: Always lock state exclusively.
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 09 Jun 2016 06:13:30 -0400
In-Reply-To: <1465440957-417548-1-git-send-email-green@linuxhacker.ru>
References: <1465406560.30890.10.camel@poochiereds.net>
	 <1465440957-417548-1-git-send-email-green@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-06-08 at 22:55 -0400, Oleg Drokin wrote:
> It used to be the case that state had an rwlock that was locked for write
> by downgrades, but for read for upgrades (opens). Well, the problem is
> if there are two competing opens for the same state, they step on
> each other toes potentially leading to leaking file descriptors
> from the state structure, since access mode is a bitmap only set once.
> This patch converts st_rwsem to st_mutex and all users become exclusive,
> no sharing
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
> This holds up well in my testing.
> I'll also try the other approach to see if it's any better.
>  fs/nfsd/nfs4state.c | 40 ++++++++++++++++++++--------------------
>  fs/nfsd/state.h     |  2 +-
>  2 files changed, 21 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f5f82e1..c927d36 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3502,7 +3502,7 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = 0;
>  	stp->st_openstp = NULL;
> -	init_rwsem(&stp->st_rwsem);
> +	mutex_init(&stp->st_mutex);
>  	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
>  	list_add(&stp->st_perfile, &fp->fi_stateids);
>  
> @@ -4335,10 +4335,10 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	 */
>  	if (stp) {
>  		/* Stateid was found, this is an OPEN upgrade */
> -		down_read(&stp->st_rwsem);
> +		mutex_lock(&stp->st_mutex);
>  		status = nfs4_upgrade_open(rqstp, fp, current_fh, stp, open);
>  		if (status) {
> -			up_read(&stp->st_rwsem);
> +			mutex_unlock(&stp->st_mutex);
>  			goto out;
>  		}
>  	} else {
> @@ -4348,19 +4348,19 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  		if (swapstp) {
>  			nfs4_put_stid(&stp->st_stid);
>  			stp = swapstp;
> -			down_read(&stp->st_rwsem);
> +			mutex_lock(&stp->st_mutex);
>  			status = nfs4_upgrade_open(rqstp, fp, current_fh,
>  						stp, open);
>  			if (status) {
> -				up_read(&stp->st_rwsem);
> +				mutex_unlock(&stp->st_mutex);
>  				goto out;
>  			}
>  			goto upgrade_out;
>  		}
> -		down_read(&stp->st_rwsem);
> +		mutex_lock(&stp->st_mutex);
>  		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
>  		if (status) {
> -			up_read(&stp->st_rwsem);
> +			mutex_unlock(&stp->st_mutex);
>  			release_open_stateid(stp);
>  			goto out;
>  		}
> @@ -4372,7 +4372,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	}
>  upgrade_out:
>  	nfs4_inc_and_copy_stateid(&open->op_stateid, &stp->st_stid);
> -	up_read(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  
>  	if (nfsd4_has_session(&resp->cstate)) {
>  		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
> @@ -4977,12 +4977,12 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
>  		 * revoked delegations are kept only for free_stateid.
>  		 */
>  		return nfserr_bad_stateid;
> -	down_write(&stp->st_rwsem);
> +	mutex_lock(&stp->st_mutex);
>  	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
>  	if (status == nfs_ok)
>  		status = nfs4_check_fh(current_fh, &stp->st_stid);
>  	if (status != nfs_ok)
> -		up_write(&stp->st_rwsem);
> +		mutex_unlock(&stp->st_mutex);
>  	return status;
>  }
>  
> @@ -5030,7 +5030,7 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
>  		return status;
>  	oo = openowner(stp->st_stateowner);
>  	if (!(oo->oo_flags & NFS4_OO_CONFIRMED)) {
> -		up_write(&stp->st_rwsem);
> +		mutex_unlock(&stp->st_mutex);
>  		nfs4_put_stid(&stp->st_stid);
>  		return nfserr_bad_stateid;
>  	}
> @@ -5062,12 +5062,12 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	oo = openowner(stp->st_stateowner);
>  	status = nfserr_bad_stateid;
>  	if (oo->oo_flags & NFS4_OO_CONFIRMED) {
> -		up_write(&stp->st_rwsem);
> +		mutex_unlock(&stp->st_mutex);
>  		goto put_stateid;
>  	}
>  	oo->oo_flags |= NFS4_OO_CONFIRMED;
>  	nfs4_inc_and_copy_stateid(&oc->oc_resp_stateid, &stp->st_stid);
> -	up_write(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  	dprintk("NFSD: %s: success, seqid=%d stateid=" STATEID_FMT "\n",
>  		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stid.sc_stateid));
>  
> @@ -5143,7 +5143,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
>  	nfs4_inc_and_copy_stateid(&od->od_stateid, &stp->st_stid);
>  	status = nfs_ok;
>  put_stateid:
> -	up_write(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  	nfs4_put_stid(&stp->st_stid);
>  out:
>  	nfsd4_bump_seqid(cstate, status);
> @@ -5196,7 +5196,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	if (status)
>  		goto out; 
>  	nfs4_inc_and_copy_stateid(&close->cl_stateid, &stp->st_stid);
> -	up_write(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  
>  	nfsd4_close_open_stateid(stp);
>  
> @@ -5422,7 +5422,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = open_stp->st_deny_bmap;
>  	stp->st_openstp = open_stp;
> -	init_rwsem(&stp->st_rwsem);
> +	mutex_init(&stp->st_mutex);
>  	list_add(&stp->st_locks, &open_stp->st_locks);
>  	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
>  	spin_lock(&fp->fi_lock);
> @@ -5591,7 +5591,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  					&open_stp, nn);
>  		if (status)
>  			goto out;
> -		up_write(&open_stp->st_rwsem);
> +		mutex_unlock(&open_stp->st_mutex);
>  		open_sop = openowner(open_stp->st_stateowner);
>  		status = nfserr_bad_stateid;
>  		if (!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
> @@ -5600,7 +5600,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		status = lookup_or_create_lock_state(cstate, open_stp, lock,
>  							&lock_stp, &new);
>  		if (status == nfs_ok)
> -			down_write(&lock_stp->st_rwsem);
> +			mutex_lock(&lock_stp->st_mutex);
>  	} else {
>  		status = nfs4_preprocess_seqid_op(cstate,
>  				       lock->lk_old_lock_seqid,
> @@ -5704,7 +5704,7 @@ out:
>  		    seqid_mutating_err(ntohl(status)))
>  			lock_sop->lo_owner.so_seqid++;
>  
> -		up_write(&lock_stp->st_rwsem);
> +		mutex_unlock(&lock_stp->st_mutex);
>  
>  		/*
>  		 * If this is a new, never-before-used stateid, and we are
> @@ -5874,7 +5874,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  fput:
>  	fput(filp);
>  put_stateid:
> -	up_write(&stp->st_rwsem);
> +	mutex_unlock(&stp->st_mutex);
>  	nfs4_put_stid(&stp->st_stid);
>  out:
>  	nfsd4_bump_seqid(cstate, status);
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 986e51e..64053ea 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -535,7 +535,7 @@ struct nfs4_ol_stateid {
>  	unsigned char			st_access_bmap;
>  	unsigned char			st_deny_bmap;
>  	struct nfs4_ol_stateid		*st_openstp;
> -	struct rw_semaphore		st_rwsem;
> +	struct mutex			st_mutex;
>  };
>  
>  static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)Looks legit. Eventually we might want to turn this back into a rwsem by
fixing and clarifying the locking around the st_access_bmap (and the
deny bmap), but for now I think this is a reasonable fix for the
problem Oleg found.There is the potential for a minor perf hit here when there are racing
OPEN calls for the same inode, but I think that's acceptable for now.
We may also want to go ahead and send this to stable as well.Reviewed-by: Jeff Layton <jlayton@poochiereds.net>

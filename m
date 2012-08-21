Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41239 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048Ab2HUTHP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 15:07:15 -0400
Date: Tue, 21 Aug 2012 15:07:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] knfsd: don't allocate file_locks on the stack
Message-ID: <20120821190707.GG16497@fieldses.org>
References: <1345550612-9744-1-git-send-email-jlayton@redhat.com>
 <20120821180832.GB16497@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120821180832.GB16497@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2012 at 02:08:32PM -0400, J. Bruce Fields wrote:
> Applying for 3.6, thanks.--b.

(Err, I meant 3.7, for this and the other.)

--b.

> 
> On Tue, Aug 21, 2012 at 08:03:32AM -0400, Jeff Layton wrote:
> > struct file_lock is pretty large and really ought not live on the stack.
> > On my x86_64 machine, they're almost 200 bytes each.
> > 
> >     (gdb) p sizeof(struct file_lock)
> >     $1 = 192
> > 
> > ...allocate them dynamically instead.
> > 
> > Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c | 118 +++++++++++++++++++++++++++++++++-------------------
> >  1 file changed, 76 insertions(+), 42 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 6e12fd5..07ded6d 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4046,8 +4046,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	struct nfs4_lockowner *lock_sop = NULL;
> >  	struct nfs4_ol_stateid *lock_stp;
> >  	struct file *filp = NULL;
> > -	struct file_lock file_lock;
> > -	struct file_lock conflock;
> > +	struct file_lock *file_lock = NULL;
> > +	struct file_lock *conflock = NULL;
> >  	__be32 status = 0;
> >  	bool new_state = false;
> >  	int lkflg;
> > @@ -4117,21 +4117,28 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	if (!locks_in_grace(SVC_NET(rqstp)) && lock->lk_reclaim)
> >  		goto out;
> >  
> > -	locks_init_lock(&file_lock);
> > +	file_lock = locks_alloc_lock();
> > +	if (!file_lock) {
> > +		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
> > +		status = nfserr_jukebox;
> > +		goto out;
> > +	}
> > +
> > +	locks_init_lock(file_lock);
> >  	switch (lock->lk_type) {
> >  		case NFS4_READ_LT:
> >  		case NFS4_READW_LT:
> >  			filp = find_readable_file(lock_stp->st_file);
> >  			if (filp)
> >  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
> > -			file_lock.fl_type = F_RDLCK;
> > +			file_lock->fl_type = F_RDLCK;
> >  			break;
> >  		case NFS4_WRITE_LT:
> >  		case NFS4_WRITEW_LT:
> >  			filp = find_writeable_file(lock_stp->st_file);
> >  			if (filp)
> >  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
> > -			file_lock.fl_type = F_WRLCK;
> > +			file_lock->fl_type = F_WRLCK;
> >  			break;
> >  		default:
> >  			status = nfserr_inval;
> > @@ -4141,17 +4148,23 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		status = nfserr_openmode;
> >  		goto out;
> >  	}
> > -	file_lock.fl_owner = (fl_owner_t)lock_sop;
> > -	file_lock.fl_pid = current->tgid;
> > -	file_lock.fl_file = filp;
> > -	file_lock.fl_flags = FL_POSIX;
> > -	file_lock.fl_lmops = &nfsd_posix_mng_ops;
> > -
> > -	file_lock.fl_start = lock->lk_offset;
> > -	file_lock.fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
> > -	nfs4_transform_lock_offset(&file_lock);
> > +	file_lock->fl_owner = (fl_owner_t)lock_sop;
> > +	file_lock->fl_pid = current->tgid;
> > +	file_lock->fl_file = filp;
> > +	file_lock->fl_flags = FL_POSIX;
> > +	file_lock->fl_lmops = &nfsd_posix_mng_ops;
> > +	file_lock->fl_start = lock->lk_offset;
> > +	file_lock->fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
> > +	nfs4_transform_lock_offset(file_lock);
> > +
> > +	conflock = locks_alloc_lock();
> > +	if (!conflock) {
> > +		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
> > +		status = nfserr_jukebox;
> > +		goto out;
> > +	}
> >  
> > -	err = vfs_lock_file(filp, F_SETLK, &file_lock, &conflock);
> > +	err = vfs_lock_file(filp, F_SETLK, file_lock, conflock);
> >  	switch (-err) {
> >  	case 0: /* success! */
> >  		update_stateid(&lock_stp->st_stid.sc_stateid);
> > @@ -4162,7 +4175,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	case (EAGAIN):		/* conflock holds conflicting lock */
> >  		status = nfserr_denied;
> >  		dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
> > -		nfs4_set_lock_denied(&conflock, &lock->lk_denied);
> > +		nfs4_set_lock_denied(conflock, &lock->lk_denied);
> >  		break;
> >  	case (EDEADLK):
> >  		status = nfserr_deadlock;
> > @@ -4177,6 +4190,10 @@ out:
> >  		release_lockowner(lock_sop);
> >  	if (!cstate->replay_owner)
> >  		nfs4_unlock_state();
> > +	if (file_lock)
> > +		locks_free_lock(file_lock);
> > +	if (conflock)
> > +		locks_free_lock(conflock);
> >  	return status;
> >  }
> >  
> > @@ -4205,7 +4222,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	    struct nfsd4_lockt *lockt)
> >  {
> >  	struct inode *inode;
> > -	struct file_lock file_lock;
> > +	struct file_lock *file_lock = NULL;
> >  	struct nfs4_lockowner *lo;
> >  	__be32 status;
> >  	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
> > @@ -4226,15 +4243,21 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		goto out;
> >  
> >  	inode = cstate->current_fh.fh_dentry->d_inode;
> > -	locks_init_lock(&file_lock);
> > +	file_lock = locks_alloc_lock();
> > +	if (!file_lock) {
> > +		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
> > +		status = nfserr_jukebox;
> > +		goto out;
> > +	}
> > +	locks_init_lock(file_lock);
> >  	switch (lockt->lt_type) {
> >  		case NFS4_READ_LT:
> >  		case NFS4_READW_LT:
> > -			file_lock.fl_type = F_RDLCK;
> > +			file_lock->fl_type = F_RDLCK;
> >  		break;
> >  		case NFS4_WRITE_LT:
> >  		case NFS4_WRITEW_LT:
> > -			file_lock.fl_type = F_WRLCK;
> > +			file_lock->fl_type = F_WRLCK;
> >  		break;
> >  		default:
> >  			dprintk("NFSD: nfs4_lockt: bad lock type!\n");
> > @@ -4244,25 +4267,27 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  
> >  	lo = find_lockowner_str(inode, &lockt->lt_clientid, &lockt->lt_owner);
> >  	if (lo)
> > -		file_lock.fl_owner = (fl_owner_t)lo;
> > -	file_lock.fl_pid = current->tgid;
> > -	file_lock.fl_flags = FL_POSIX;
> > +		file_lock->fl_owner = (fl_owner_t)lo;
> > +	file_lock->fl_pid = current->tgid;
> > +	file_lock->fl_flags = FL_POSIX;
> >  
> > -	file_lock.fl_start = lockt->lt_offset;
> > -	file_lock.fl_end = last_byte_offset(lockt->lt_offset, lockt->lt_length);
> > +	file_lock->fl_start = lockt->lt_offset;
> > +	file_lock->fl_end = last_byte_offset(lockt->lt_offset, lockt->lt_length);
> >  
> > -	nfs4_transform_lock_offset(&file_lock);
> > +	nfs4_transform_lock_offset(file_lock);
> >  
> > -	status = nfsd_test_lock(rqstp, &cstate->current_fh, &file_lock);
> > +	status = nfsd_test_lock(rqstp, &cstate->current_fh, file_lock);
> >  	if (status)
> >  		goto out;
> >  
> > -	if (file_lock.fl_type != F_UNLCK) {
> > +	if (file_lock->fl_type != F_UNLCK) {
> >  		status = nfserr_denied;
> > -		nfs4_set_lock_denied(&file_lock, &lockt->lt_denied);
> > +		nfs4_set_lock_denied(file_lock, &lockt->lt_denied);
> >  	}
> >  out:
> >  	nfs4_unlock_state();
> > +	if (file_lock)
> > +		locks_free_lock(file_lock);
> >  	return status;
> >  }
> >  
> > @@ -4272,7 +4297,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  {
> >  	struct nfs4_ol_stateid *stp;
> >  	struct file *filp = NULL;
> > -	struct file_lock file_lock;
> > +	struct file_lock *file_lock = NULL;
> >  	__be32 status;
> >  	int err;
> >  						        
> > @@ -4294,22 +4319,29 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		status = nfserr_lock_range;
> >  		goto out;
> >  	}
> > -	locks_init_lock(&file_lock);
> > -	file_lock.fl_type = F_UNLCK;
> > -	file_lock.fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
> > -	file_lock.fl_pid = current->tgid;
> > -	file_lock.fl_file = filp;
> > -	file_lock.fl_flags = FL_POSIX; 
> > -	file_lock.fl_lmops = &nfsd_posix_mng_ops;
> > -	file_lock.fl_start = locku->lu_offset;
> > -
> > -	file_lock.fl_end = last_byte_offset(locku->lu_offset, locku->lu_length);
> > -	nfs4_transform_lock_offset(&file_lock);
> > +	file_lock = locks_alloc_lock();
> > +	if (!file_lock) {
> > +		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
> > +		status = nfserr_jukebox;
> > +		goto out;
> > +	}
> > +	locks_init_lock(file_lock);
> > +	file_lock->fl_type = F_UNLCK;
> > +	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
> > +	file_lock->fl_pid = current->tgid;
> > +	file_lock->fl_file = filp;
> > +	file_lock->fl_flags = FL_POSIX;
> > +	file_lock->fl_lmops = &nfsd_posix_mng_ops;
> > +	file_lock->fl_start = locku->lu_offset;
> > +
> > +	file_lock->fl_end = last_byte_offset(locku->lu_offset,
> > +						locku->lu_length);
> > +	nfs4_transform_lock_offset(file_lock);
> >  
> >  	/*
> >  	*  Try to unlock the file in the VFS.
> >  	*/
> > -	err = vfs_lock_file(filp, F_SETLK, &file_lock, NULL);
> > +	err = vfs_lock_file(filp, F_SETLK, file_lock, NULL);
> >  	if (err) {
> >  		dprintk("NFSD: nfs4_locku: vfs_lock_file failed!\n");
> >  		goto out_nfserr;
> > @@ -4323,6 +4355,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  out:
> >  	if (!cstate->replay_owner)
> >  		nfs4_unlock_state();
> > +	if (file_lock)
> > +		locks_free_lock(file_lock);
> >  	return status;
> >  
> >  out_nfserr:
> > -- 
> > 1.7.11.4
> > 

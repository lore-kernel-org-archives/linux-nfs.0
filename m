Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:56104 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbaF0UAA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jun 2014 16:00:00 -0400
Received: by mail-qc0-f176.google.com with SMTP id w7so5009416qcr.35
        for <linux-nfs@vger.kernel.org>; Fri, 27 Jun 2014 12:59:59 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 27 Jun 2014 15:59:58 -0400
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 033/117] nfsd: ensure that nfs4_file_get_access
 enforces deny modes
Message-ID: <20140627155958.10a6420d@tlielax.poochiereds.net>
In-Reply-To: <1403810017-16062-34-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<1403810017-16062-34-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 26 Jun 2014 15:12:13 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> The current enforcement of deny modes is both inefficient and scattered.
> The former is a problem now, and the latter problem will mean races once
> the client_mutex is removed.
> 
> First, we address the inefficiency. We (necessarily) track deny modes on
> a per-stateid basis, but when we go to enforce them we have to walk the
> entire list of stateids and check against each one. Instead of doing
> that, maintain a per-nfs4_file deny mode.
> 
> When a file is opened, we simply set any deny bits in that mode that
> were specified in the OPEN call. We can then use that unified deny mode
> to do a simple check to see whether there are any conflicts without
> needing to walk the entire stateid list.
> 
> The only time we'll need to walk the entire list of stateids is when
> a stateid that has a deny mode on it is being released, or one is having
> its deny mode downgraded. In that case, we must walk the entire list
> and recalculate the fi_share_deny field. Since deny modes are pretty
> rare today, this shouldn't happen much under normal workloads.
> 
> To address the potential for races once the client_mutex is removed, we
> first check for conflicting deny modes in nfs4_file_get_access prior to
> opening the file. If it turns out that we need to do a VFS layer open of
> the file, then do so and recheck for conflicting deny modes afterward.
> If there are any, then just put access to the file and return
> nfserr_share_denied.
> 
> Finally, deal with potential races in get_lock_access. Taking an
> fi_access reference must be done under the fi_lock, or that could race
> with a nfs4_file_put_access call. Since we will have just dropped the
> lock after finding a readable or writeable file, add some *_locked
> variants of find_readable_file and find_writeable_file that we can call
> while already holding the fi_lock.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 229 +++++++++++++++++++++++++++++++++++++++-------------
>  fs/nfsd/state.h     |   1 +
>  2 files changed, 172 insertions(+), 58 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0b6cd933eac6..93d175661c8d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -276,27 +276,49 @@ static struct file *__nfs4_get_fd(struct nfs4_file *f, int oflag)
>  	return NULL;
>  }
>  
> -static struct file *find_writeable_file(struct nfs4_file *f)
> +static struct file *find_writeable_file_locked(struct nfs4_file *f)
>  {
>  	struct file *ret;
>  
> -	spin_lock(&f->fi_lock);
> +	lockdep_assert_held(&f->fi_lock);
> +
>  	ret = __nfs4_get_fd(f, O_WRONLY);
>  	if (!ret)
>  		ret = __nfs4_get_fd(f, O_RDWR);
> -	spin_unlock(&f->fi_lock);
>  	return ret;
>  }
>  
> -static struct file *find_readable_file(struct nfs4_file *f)
> +static struct file *find_writeable_file(struct nfs4_file *f)
>  {
>  	struct file *ret;
>  
>  	spin_lock(&f->fi_lock);
> +	ret = find_writeable_file_locked(f);
> +	spin_unlock(&f->fi_lock);
> +
> +	return ret;
> +}
> +
> +static struct file *find_readable_file_locked(struct nfs4_file *f)
> +{
> +	struct file *ret;
> +
> +	lockdep_assert_held(&f->fi_lock);
> +
>  	ret = __nfs4_get_fd(f, O_RDONLY);
>  	if (!ret)
>  		ret = __nfs4_get_fd(f, O_RDWR);
> +	return ret;
> +}
> +
> +static struct file *find_readable_file(struct nfs4_file *f)
> +{
> +	struct file *ret;
> +
> +	spin_lock(&f->fi_lock);
> +	ret = find_readable_file_locked(f);
>  	spin_unlock(&f->fi_lock);
> +
>  	return ret;
>  }
>  
> @@ -362,26 +384,72 @@ static unsigned int file_hashval(struct inode *ino)
>  
>  static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
>  
> -static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
> +static void
> +__nfs4_file_get_access(struct nfs4_file *fp, u32 access)
>  {
> -	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
> -	atomic_inc(&fp->fi_access[oflag]);
> +	int oflag = nfs4_access_to_omode(access);
> +
> +	lockdep_assert_held(&fp->fi_lock);
> +
> +	if (oflag == O_RDWR) {
> +		atomic_inc(&fp->fi_access[O_RDONLY]);
> +		atomic_inc(&fp->fi_access[O_WRONLY]);
> +	} else
> +		atomic_inc(&fp->fi_access[oflag]);
>  }
>  
> -static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
> +static __be32
> +nfs4_file_get_access(struct nfs4_file *fp, u32 access)
>  {
> -	int oflag = nfs4_access_to_omode(access);
> -
>  	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
> -	access &= (NFS4_SHARE_ACCESS_READ|NFS4_SHARE_ACCESS_WRITE);
> +	access &= NFS4_SHARE_ACCESS_BOTH;
> +
> +	/* Does this access mask make sense? */
>  	if (access == 0)
> -		return;
> +		return nfserr_inval;
>  
> -	if (oflag == O_RDWR) {
> -		__nfs4_file_get_access(fp, O_RDONLY);
> -		__nfs4_file_get_access(fp, O_WRONLY);
> -	} else
> -		__nfs4_file_get_access(fp, oflag);
> +	/* Does it conflict with a deny mode already set? */
> +	if ((access & fp->fi_share_deny) != 0)
> +		return nfserr_share_denied;
> +
> +	__nfs4_file_get_access(fp, access);
> +	return nfs_ok;
> +}
> +
> +static __be32 nfs4_file_check_deny(struct nfs4_file *fp, u32 access, u32 deny)
> +{
> +	int rdcnt = 0;
> +	int wrcnt = 0;
> +
> +	lockdep_assert_held(&fp->fi_lock);
> +

We should optimize this function for the vastly common case where
"deny" is 0. Check for that and return nfs_ok immediately if it is.

> +	/*
> +	 * We must take into account any references that were already taken
> +	 * on behalf of this open attempt.
> +	 */
> +	switch (access) {
> +	case NFS4_SHARE_ACCESS_READ:
> +		++rdcnt;
> +		break;
> +	case NFS4_SHARE_ACCESS_WRITE:
> +		++wrcnt;
> +		break;
> +	case NFS4_SHARE_ACCESS_BOTH:
> +		++rdcnt;
> +		++wrcnt;
> +	}
> +
> +	/* Note: relies on NFS4_SHARE_DENY_BOTH == READ|WRITE */
> +	deny &= NFS4_SHARE_DENY_BOTH;
> +	if (deny) {
> +		if ((deny & NFS4_SHARE_DENY_READ) &&
> +		    (atomic_read(&fp->fi_access[O_RDONLY]) - rdcnt) > 0)
> +			return nfserr_share_denied;
> +		if ((deny & NFS4_SHARE_DENY_WRITE) &&
> +		    (atomic_read(&fp->fi_access[O_WRONLY]) - wrcnt) > 0)
> +			return nfserr_share_denied;
> +	}
> +	return nfs_ok;
>  }
>  
>  static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
> @@ -710,17 +778,6 @@ bmap_to_share_mode(unsigned long bmap) {
>  	return access;
>  }
>  
> -static bool
> -test_share(struct nfs4_ol_stateid *stp, struct nfsd4_open *open) {
> -	unsigned int access, deny;
> -
> -	access = bmap_to_share_mode(stp->st_access_bmap);
> -	deny = bmap_to_share_mode(stp->st_deny_bmap);
> -	if ((access & open->op_share_deny) || (deny & open->op_share_access))
> -		return false;
> -	return true;
> -}
> -
>  /* set share access for a given stateid */
>  static inline void
>  set_access(u32 access, struct nfs4_ol_stateid *stp)
> @@ -763,11 +820,31 @@ test_deny(u32 access, struct nfs4_ol_stateid *stp)
>  	return test_bit(access, &stp->st_deny_bmap);
>  }
>  
> +/*
> + * A stateid that had a deny mode associated with it is being released
> + * or downgraded. Recalculate the deny mode on the file.
> + */
> +static void
> +recalculate_deny_mode(struct nfs4_file *fp)
> +{
> +	struct nfs4_ol_stateid *stp;
> +
> +	spin_lock(&fp->fi_lock);
> +	fp->fi_share_deny = 0;
> +	list_for_each_entry(stp, &fp->fi_stateids, st_perfile)
> +		fp->fi_share_deny |= bmap_to_share_mode(stp->st_deny_bmap);
> +	spin_unlock(&fp->fi_lock);
> +}
> +
>  /* release all access and file references for a given stateid */
>  static void
>  release_all_access(struct nfs4_ol_stateid *stp)
>  {
>  	int i;
> +	struct nfs4_file *fp = stp->st_file;
> +
> +	if (fp && stp->st_deny_bmap != 0)
> +		recalculate_deny_mode(fp);
>  
>  	for (i = 1; i < 4; i++) {
>  		if (test_access(i, stp))
> @@ -2760,6 +2837,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
>  	fp->fi_inode = ino;
>  	fp->fi_had_conflict = false;
>  	fp->fi_lease = NULL;
> +	fp->fi_share_deny = 0;
>  	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
>  	memset(fp->fi_access, 0, sizeof(fp->fi_access));
>  	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
> @@ -2988,22 +3066,15 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
>  {
>  	struct inode *ino = current_fh->fh_dentry->d_inode;
>  	struct nfs4_file *fp;
> -	struct nfs4_ol_stateid *stp;
> -	__be32 ret;
> +	__be32 ret = nfs_ok;
>  
>  	fp = find_file(ino);
>  	if (!fp)
> -		return nfs_ok;
> -	ret = nfserr_locked;
> -	/* Search for conflicting share reservations */
> +		return ret;
> +	/* Check for conflicting share reservations */
>  	spin_lock(&fp->fi_lock);
> -	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
> -		if (test_deny(deny_type, stp) ||
> -		    test_deny(NFS4_SHARE_DENY_BOTH, stp))
> -			goto out;
> -	}
> -	ret = nfs_ok;
> -out:
> +	if (fp->fi_share_deny & deny_type)
> +		ret = nfserr_locked;
>  	spin_unlock(&fp->fi_lock);
>  	put_nfs4_file(fp);
>  	return ret;
> @@ -3204,21 +3275,18 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
>  	struct nfs4_ol_stateid *local;
>  	struct nfs4_openowner *oo = open->op_openowner;
>  
> -	spin_lock(&fp->fi_lock);
> +	lockdep_assert_held(&fp->fi_lock);
> +
>  	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
>  		/* ignore lock owners */
>  		if (local->st_stateowner->so_is_open_owner == 0)
>  			continue;
>  		/* remember if we have seen this open owner */
> -		if (local->st_stateowner == &oo->oo_owner)
> +		if (local->st_stateowner == &oo->oo_owner) {
>  			*stpp = local;
> -		/* check for conflicting share reservations */
> -		if (!test_share(local, open)) {
> -			spin_unlock(&fp->fi_lock);
> -			return nfserr_share_denied;
> +			break;
>  		}
>  	}
> -	spin_unlock(&fp->fi_lock);
>  	return nfs_ok;
>  }
>  
> @@ -3257,18 +3325,46 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
>  	int access = nfs4_access_to_access(open->op_share_access);
>  
>  	spin_lock(&fp->fi_lock);
> +	/* Are we trying to set a deny mode that would conflict? */
> +	status = nfs4_file_check_deny(fp, 0, open->op_share_deny);
> +	if (status != nfs_ok) {
> +		spin_unlock(&fp->fi_lock);
> +		goto out;
> +	}
> +
> +	/* Set access to the file */
> +	status = nfs4_file_get_access(fp, open->op_share_access);
> +	if (status != nfs_ok) {
> +		spin_unlock(&fp->fi_lock);
> +		goto out;
> +	}
> +
>  	if (!fp->fi_fds[oflag]) {
>  		spin_unlock(&fp->fi_lock);
>  		status = nfsd_open(rqstp, cur_fh, S_IFREG, access, &filp);
>  		if (status)
> -			goto out;
> +			goto out_put_access;
>  		spin_lock(&fp->fi_lock);
>  		if (!fp->fi_fds[oflag]) {
>  			fp->fi_fds[oflag] = filp;
>  			filp = NULL;
>  		}
> +
> +		/*
> +		 * Recheck: did someone race in and open the file in a way that
> +		 *	    would conflict with our deny bits?
> +		 */
> +		if (nfs4_file_check_deny(fp, open->op_share_access,
> +					 open->op_share_deny)) {
> +			spin_unlock(&fp->fi_lock);
> +			status = nfserr_share_denied;
> +			goto out_put_access;
> +		}
> +
> +		/* Set any new deny bits */
> +		fp->fi_share_deny |= (open->op_share_deny &
> +					NFS4_SHARE_DENY_BOTH);

Oof, I think we have a potential race here. It's possible that we'll
end up setting new bits in fi_share_deny, but then another task comes
along and does a recalculation of it just after the fi_lock is dropped
below. Since the stateid isn't hashed yet, it won't get factored into
the recalculated deny mode and we'll lose those bits.

I think the remedy is probably to go ahead and just hash the stateid
before calling nfs4_get_vfs_file. Then if it returns error, we'll just
have to unhash it and ensure that it's eventually destroyed.

So, this patch will probably need a respin to deal with that.

>  	}
> -	nfs4_file_get_access(fp, open->op_share_access);
>  	spin_unlock(&fp->fi_lock);
>  	if (filp)
>  		fput(filp);
> @@ -3276,13 +3372,11 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
>  	status = nfsd4_truncate(rqstp, cur_fh, open);
>  	if (status)
>  		goto out_put_access;
> -
> -	return nfs_ok;
> -
> -out_put_access:
> -	nfs4_file_put_access(fp, open->op_share_access);
>  out:
>  	return status;
> +out_put_access:
> +	nfs4_file_put_access(fp, open->op_share_access);
> +	goto out;
>  }
>  
>  static __be32
> @@ -3526,7 +3620,12 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	 */
>  	fp = find_or_add_file(ino, open->op_file);
>  	if (fp != open->op_file) {
> -		if ((status = nfs4_check_open(fp, open, &stp)))
> +		spin_lock(&fp->fi_lock);
> +		status = nfs4_file_check_deny(fp, 0, open->op_share_deny);
> +		if (status == nfs_ok)
> +			status = nfs4_check_open(fp, open, &stp);
> +		spin_unlock(&fp->fi_lock);
> +		if (status)
>  			goto out;
>  		status = nfs4_check_deleg(cl, open, &dp);
>  		if (status)
> @@ -4241,10 +4340,16 @@ static void
>  reset_union_bmap_deny(unsigned long deny, struct nfs4_ol_stateid *stp)
>  {
>  	int i;
> +	u32 prev_deny = bmap_to_share_mode(stp->st_deny_bmap);
> +
>  	for (i = 0; i < 4; i++) {
>  		if ((i & deny) != i)
>  			clear_deny(i, stp);
>  	}
> +
> +	/* Downgrade per-file deny mode if this one changed */
> +	if (prev_deny != deny)
> +		recalculate_deny_mode(stp->st_file);
>  }
>  
>  __be32
> @@ -4541,9 +4646,11 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
>  {
>  	struct nfs4_file *fp = lock_stp->st_file;
>  
> +	lockdep_assert_held(&fp->fi_lock);
> +
>  	if (test_access(access, lock_stp))
>  		return;
> -	nfs4_file_get_access(fp, access);
> +	__nfs4_file_get_access(fp, access);
>  	set_access(access, lock_stp);
>  }
>  
> @@ -4595,6 +4702,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	struct file *filp = NULL;
>  	struct file_lock *file_lock = NULL;
>  	struct file_lock *conflock = NULL;
> +	struct nfs4_file *fp;
>  	__be32 status = 0;
>  	bool new_state = false;
>  	int lkflg;
> @@ -4672,20 +4780,25 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		goto out;
>  	}
>  
> +	fp = lock_stp->st_file;
>  	locks_init_lock(file_lock);
>  	switch (lock->lk_type) {
>  		case NFS4_READ_LT:
>  		case NFS4_READW_LT:
> -			filp = find_readable_file(lock_stp->st_file);
> +			spin_lock(&fp->fi_lock);
> +			filp = find_readable_file_locked(fp);
>  			if (filp)
>  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
> +			spin_unlock(&fp->fi_lock);
>  			file_lock->fl_type = F_RDLCK;
>  			break;
>  		case NFS4_WRITE_LT:
>  		case NFS4_WRITEW_LT:
> -			filp = find_writeable_file(lock_stp->st_file);
> +			spin_lock(&fp->fi_lock);
> +			filp = find_writeable_file_locked(fp);
>  			if (filp)
>  				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
> +			spin_unlock(&fp->fi_lock);
>  			file_lock->fl_type = F_WRLCK;
>  			break;
>  		default:
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index dc56ec234df7..561b94181751 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -392,6 +392,7 @@ struct nfs4_file {
>  	 *   + 1 to both of the above if NFS4_SHARE_ACCESS_BOTH is set.
>  	 */
>  	atomic_t		fi_access[2];
> +	u32			fi_share_deny;
>  	struct file		*fi_deleg_file;
>  	struct file_lock	*fi_lease;
>  	atomic_t		fi_delegees;


-- 
Jeff Layton <jlayton@primarydata.com>

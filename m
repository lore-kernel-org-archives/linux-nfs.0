From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: don't call ->copy_lock methods on return of conflicting locks
	[was: Re: stuff]
Date: Fri, 25 Apr 2008 13:12:27 -0400
Message-ID: <20080425171227.GA32104@fieldses.org>
References: <20080424203403.GD18573@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52842 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754020AbYDYRMa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 13:12:30 -0400
In-Reply-To: <20080424203403.GD18573@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And apologies for that subject line.  It was a placeholder I forgot to
replace....

On Thu, Apr 24, 2008 at 04:34:03PM -0400, J. Bruce Fields wrote:
> Trond--you mentioned noticing some locks_copy_locks() abuses; is this
> what you were thinking of?
> 
> --b.
> 
> commit 07c5abe6899d8ab49368604e64894821d4f60bf9
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Thu Apr 24 10:08:22 2008 -0400
> 
>     locks: don't call ->copy_lock methods on return of conflicting locks
>     
>     The file_lock structure is used both as a heavy-weight representation of
>     an active lock, with pointers to reference-counted structures, etc., and
>     as a simple container for parameters that describe a file lock.
>     
>     The conflicting lock returned from __posix_lock_file is an example of
>     the latter; so don't call the filesystem or lock manager callbacks when
>     copying to it.  This also saves the need for an unnecessary
>     locks_init_lock in the nfsv4 server.
>     
>     Thanks to Trond for pointing out the error.
>     
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>     Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 1f122c1..4d81553 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -632,7 +632,7 @@ nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
>  		block->b_flags |= B_TIMED_OUT;
>  	if (conf) {
>  		if (block->b_fl)
> -			locks_copy_lock(block->b_fl, conf);
> +			__locks_copy_lock(block->b_fl, conf);
>  	}
>  }
>  
> diff --git a/fs/locks.c b/fs/locks.c
> index 2e0fa66..e1ea2fe 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -224,7 +224,7 @@ static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
>  /*
>   * Initialize a new lock from an existing file_lock structure.
>   */
> -static void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
> +void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
>  {
>  	new->fl_owner = fl->fl_owner;
>  	new->fl_pid = fl->fl_pid;
> @@ -833,7 +833,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>  			if (!posix_locks_conflict(request, fl))
>  				continue;
>  			if (conflock)
> -				locks_copy_lock(conflock, fl);
> +				__locks_copy_lock(conflock, fl);
>  			error = -EAGAIN;
>  			if (!(request->fl_flags & FL_SLEEP))
>  				goto out;
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 55dfdd7..8799b87 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2712,9 +2712,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	* Note: locks.c uses the BKL to protect the inode's lock list.
>  	*/
>  
> -	/* XXX?: Just to divert the locks_release_private at the start of
> -	 * locks_copy_lock: */
> -	locks_init_lock(&conflock);
>  	err = vfs_lock_file(filp, cmd, &file_lock, &conflock);
>  	switch (-err) {
>  	case 0: /* success! */
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index cc2be2c..6556f2f 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -973,6 +973,7 @@ extern int do_sync_mapping_range(struct address_space *mapping, loff_t offset,
>  /* fs/locks.c */
>  extern void locks_init_lock(struct file_lock *);
>  extern void locks_copy_lock(struct file_lock *, struct file_lock *);
> +extern void __locks_copy_lock(struct file_lock *, const struct file_lock *);
>  extern void locks_remove_posix(struct file *, fl_owner_t);
>  extern void locks_remove_flock(struct file *);
>  extern void posix_test_lock(struct file *, struct file_lock *);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

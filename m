From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: [RFC/PATCH - RESEND] NFS file locking for clustered file systems
Date: Tue, 21 Sep 2004 12:14:43 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040921161443.C7F521BB8C@citi.umich.edu>
References: <Pine.LNX.4.58.0409201720100.17768@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fs.uio.no, okir@suse.de,
	nfs@lists.sourceforge.net, nfsv4@linux-nfs.org, andros@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C9nI5-0001lr-2g
	for nfs@lists.sourceforge.net; Tue, 21 Sep 2004 09:14:53 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1C9nHz-0000YR-VL
	for nfs@lists.sourceforge.net; Tue, 21 Sep 2004 09:14:49 -0700
To: Sridhar Samudrala <sri@us.ibm.com>
In-reply-to: Your message of "Mon, 20 Sep 2004 17:23:22 PDT."
             <Pine.LNX.4.58.0409201720100.17768@localhost.localdomain>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hello sridhar

trond and i were discussing these proposed changes - version 4 nfsd needs a 
way to communicate with the underlying clustered/parallel file system for 
share/deny access, byte-range locking, and delegations, and file handle 
construction.

trond suggested (trond, speak up if i misunderstood you!) that since only the 
server lockd, and nfsd need these operations, extending the struct 
export_operations might be a better place to put this new functionality 
instead of changing the existing f_op->lock behaviour.

it would be great if vfs_lock_file(), and therefore __posix_lock_file() had a 
conflicting lock parameter set only upon discovery of a conflicting lock in 
order to get rid of a race in lockd and nfsd.

svclock.c: nlmsvc_lock()

        if (!(conflock = posix_test_lock(file->f_file, &lock->fl))) {
                error = posix_lock_file(file->f_file, &lock->fl);

in the above code, a conflicting lock could be inserted in between the calls 
to posix_test_lock and posix_lock_file. v4 nfsd has similar code. adding the 
conflicting lock parameter to vfs/posix_lock_file means the call to 
posix_test_lock could be removed.


i'm a bit confused about the use of posix_locks_same. vfs_test_lock() will 
return -ENOLCK with no conf lock set when posix_locks_same() returns 1. yet in 
nlmsvc_testlock() which calls vfs_test_lock, this error is not propagated - 
nlm_granted is returned.

i do like the direction of these patches, i'll spend some more time looking at 
them from the v4 nfsd byte-range locking perspective...


-->Andy



> -------------------------------------------------------------------------------
> 
> Following the recent discussion on NFS file locking for clustered filesystems,
> we have come up with a patch that introduces asynchronous lock request
> mechanism so that the underlying filesystem lock operation can be called
> without blocking lockd.
> 
> Changes to filesystem lock call: f_op->lock()
> ---------------------------------------------
> - The calls to the filesystem will return immediately with 0 or an appropriate
>   error if they can perform the operation without involving any network IO.
> - If the filesystem has to do any network io to perform the operation, it
>   should return EINPROGRESS, start the operation in background and return the
>   result asynchronously using a callback once the operation is completed.
> - The following new callback is added to struct lock_manager_operations
>    int (*fl_vfs_callback)(struct file_lock *fl, struct file_lock *conf_lock,
>                           int result);
> 
> Changes to lock manager:
> ------------------------
> - Replace posix_lock_file() and posix_test_lock() calls in lockd with new
>   routines vfs_lock_file() and vfs_test_lock() that make calls to the
>   underlying filesystem.
> - For a blocking call(F_SETLKW), if the filesystem returns EINPROGRESS, the
>   lock manager will return NLM_LCK_BLOCKED to the client and adds the
>   deferred request to the nlm_blocked list. Once the filesystem completes the
>   asynchronous operation, it invokes fl_vfs_callback() with the appropriate
>   result.  Based on the result, the callback will update the deferred request,
>   moves it to the head of nlm_blocked and wakes up lockd.
>   nlmsvc_retry_blocked() will find the deferred block  and send a GRANTED_MSG
>   to the client with NLM_LCK_GRANTED/NLM_LCK_DENIED when the request is
>   retried.
> - For a non-blocking call(F_SETLK, F_GETLK), if the fileystem returns
>   EINPROGRESS, the lock manager defers the lock request for 7secs and adds it
>   to the nlm_blocked list.  If the callback is not invoked before the deferred
>   duration, NLM_LCK_DENIED is sent to the client when it is revisited. If the
>   callback is invoked before the deferred duration, it updates the blocked
>   request, moves it to the head of nlm_blocked and wakes up lockd.
>   nlmsvc_retry_blocked() will find the deferred block and revists the
>   request causing NLM_LCK_GRANTED/NLM_LCK_DENIED to be sent to the client
>   based on the result.
> 
> I would appreciate any feedback and suggestions for improvements.
> 
> Thanks
> Sridhar
> 
> 
> --- /nas/linux-2.6.8+kdb+nfsv4/fs/locks.c	2004-08-17 14:35:33.000000000 -0700
> +++ /nas/linux-2.6.8-locks/fs/locks.c	2004-09-15 09:29:43.194414976 -0700
> @@ -443,6 +443,8 @@ static void locks_delete_block(struct fi
>  {
>  	lock_kernel();
>  	__locks_delete_block(waiter);
> +	if (waiter->fl_flags & FL_FREE)
> +		kfree(waiter);
>  	unlock_kernel();
>  }
> 
> @@ -554,6 +556,21 @@ static int posix_locks_conflict(struct f
>  	return (locks_conflict(caller_fl, sys_fl));
>  }
> 
> +int posix_locks_same(struct file_lock *caller_fl, struct file_lock *sys_fl)
> +{
> +	/* POSIX locks owned by the same process do not conflict with
> +	 * each other.
> +	 */
> +	if (IS_POSIX(sys_fl) &&
> +	    posix_same_owner(caller_fl, sys_fl) &&
> +	    caller_fl->fl_type == sys_fl->fl_type &&
> +	    caller_fl->fl_start <= sys_fl->fl_start &&
> +	    caller_fl->fl_end >= sys_fl->fl_end)
> +		return 1;
> +	else
> +		return 0;
> +}
> +
>  /* Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
>   * checking before calling the locks_conflict().
>   */
> @@ -614,7 +631,51 @@ posix_test_lock(struct file *filp, struc
>  	return (cfl);
>  }
> 
> +int
> +vfs_test_lock(struct file *filp, struct file_lock *fl, struct file_lock **conf)
> +{
> +	struct file_lock *cfl;
> +	int result = 0;
> +	int samelock = 0;
> +
> +	lock_kernel();
> +	for (cfl = filp->f_dentry->d_inode->i_flock; cfl; cfl = cfl->fl_next) {
> +		if (!IS_POSIX(cfl))
> +			continue;
> +		if (posix_locks_same(cfl, fl))
> +			samelock = 1;
> +		if (posix_locks_conflict(cfl, fl))
> +			break;
> +	}
> +	unlock_kernel();
> +
> +	if (cfl || samelock)
> +		goto out;
> +
> +	if (filp->f_op && filp->f_op->lock) {
> +		struct file_lock fl1;
> +		memcpy(&fl1, fl, sizeof(struct file_lock));
> +		result = filp->f_op->lock(filp, F_GETLK, &fl1);
> +		if (result == 0 && fl1.fl_type != F_UNLCK) {
> +			cfl = (struct file_lock *)kmalloc(sizeof(struct file_lock), GFP_KERNEL);
> +			if (cfl) {
> +				memcpy(cfl, &fl1, sizeof(struct file_lock));
> +				cfl->fl_flags |= FL_FREE;
> +			}
> +		}
> +	}
> +out:
> +	if (cfl) {
> +		*conf = cfl;
> +		return 0;
> +	}
> +	if (result == 0)
> +		return -ENOLCK;
> +	return result;
> +}
> +
>  EXPORT_SYMBOL(posix_test_lock);
> +EXPORT_SYMBOL(vfs_test_lock);
> 
>  /* This function tests for deadlock condition before putting a process to
>   * sleep. The detection scheme is no longer recursive. Recursive was neat,
> @@ -713,6 +774,7 @@ out:
>  }
> 
>  EXPORT_SYMBOL(posix_lock_file);
> +EXPORT_SYMBOL(vfs_lock_file);
> 
>  static int __posix_lock_file(struct inode *inode, struct file_lock *request)
>  {
> @@ -905,6 +967,31 @@ int posix_lock_file(struct file *filp, s
>  	return __posix_lock_file(filp->f_dentry->d_inode, fl);
>  }
> 
> +int vfs_lock_file(struct file *filp, struct file_lock *fl, int wait)
> +{
> +	int rc = 0;
> +	int cmd = F_SETLK;
> +
> +	if (fl->fl_type != F_UNLCK) {
> +		/* Check the underlying filesystem will allow us to lock */
> +		if (filp->f_op && filp->f_op->lock) {
> +			if (wait)
> +				cmd = F_SETLKW;
> +			rc = filp->f_op->lock(filp, cmd, fl);
> +		}
> +		if (rc == 0)
> +			rc = __posix_lock_file(filp->f_dentry->d_inode, fl);
> +	}
> +	else {
> +		rc = __posix_lock_file(filp->f_dentry->d_inode, fl);
> +		/* Check the underlying filesystem will allow us to (un)lock */
> +		if (!rc && filp->f_op && filp->f_op->lock) {
> +			rc = filp->f_op->lock(filp, cmd, fl);
> +		}
> +	}
> +	return rc;
> +}
> +
>  /**
>   * posix_lock_file_wait - Apply a POSIX-style lock to a file
>   * @filp: The file to apply the lock to
> @@ -1761,12 +1848,18 @@ void locks_remove_flock(struct file *fil
>   *	@blocker: the lock which is blocking
>   *	@waiter: the lock which conflicts and has to wait
>   *
> - * lockd needs to block waiting for locks.
> + * This routine is for the use of lockd alone.  It allows lockd to block
> + * waiting for locks by putting the lock in the list of blocking locks
> + * without actually going to sleep itself.
>   */
> -void
> +int
>  posix_block_lock(struct file_lock *blocker, struct file_lock *waiter)
>  {
> -	locks_insert_block(blocker, waiter);
> +	int error;
> +	error = posix_locks_deadlock(waiter, blocker);
> +	if (!error)
> +		locks_insert_block(blocker, waiter);
> +	return error;
>  }
> 
>  EXPORT_SYMBOL(posix_block_lock);
> @@ -1792,7 +1885,7 @@ posix_unblock_lock(struct file *filp, st
>  	} else {
>  		unlock_kernel();
>  		waiter->fl_type = F_UNLCK;
> -		posix_lock_file(filp, waiter);
> +		vfs_lock_file(filp, waiter, 0);
>  	}
>  }
> 
> --- /nas/linux-2.6.8+kdb+nfsv4/fs/lockd/svc.c	2004-08-14 03:55:35.000000000 -0700
> +++ /nas/linux-2.6.8-locks/fs/lockd/svc.c	2004-09-08 21:26:18.000000000 -0700
> @@ -312,6 +312,45 @@ out:
>  	up(&nlmsvc_sema);
>  }
> 
> +int
> +nlmsvc_dispatch(struct svc_rqst *rqstp, u32 *statp)
> +{
> +	u32			*statp;
> +	struct svc_procedure	*procp;
> +	kxdrproc_t		xdr;
> +	struct kvec *		argv = &rqstp->rq_arg.head[0];
> +	struct kvec *		resv = &rqstp->rq_res.head[0];
> +
> +	dprintk("lockd: nlmsvc_dispatch vers %d proc %d\n",
> +				rqstp->rq_vers, rqstp->rq_proc);
> +
> +	procp = rqstp->rq_procinfo;
> +	statp = resv->iov_base +resv->iov_len;
> +
> +	/* Decode arguments */
> +	xdr = procp->pc_decode;
> +
> +	if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp)) {
> +		dprintk("lockd: failed to decode arguments!\n");
> +		*statp = rpc_garbage_args;
> +		return 1;
> +	}
> +	/* Now call the procedure handler, and encode status. */
> +	*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
> +	if (((struct nlm_res  *)(rqstp->rq_resp))->status == EINPROGRESS) {
> +		dprintk("lockd: Deferring request!\n");
> +		return 0;
> +	}
> +	/* Encode reply */
> +	if (*statp == rpc_success && (xdr = procp->pc_encode)
> +	    && !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
> +			dprintk("lockd: failed to encode reply\n");
> +			/* serv->sv_stats->rpcsystemerr++; */
> +			*statp = rpc_system_err;
> +	}
> +	return 1;
> +}
> +
>  /*
>   * Sysctl parameters (same as module parameters, different interface).
>   */
> @@ -444,12 +483,14 @@ static struct svc_version	nlmsvc_version
>  		.vs_vers	= 1,
>  		.vs_nproc	= 17,
>  		.vs_proc	= nlmsvc_procedures,
> +		.vs_dispatch	= nlmsvc_dispatch,
>  		.vs_xdrsize	= NLMSVC_XDRSIZE,
>  };
>  static struct svc_version	nlmsvc_version3 = {
>  		.vs_vers	= 3,
>  		.vs_nproc	= 24,
>  		.vs_proc	= nlmsvc_procedures,
> +		.vs_dispatch	= nlmsvc_dispatch,
>  		.vs_xdrsize	= NLMSVC_XDRSIZE,
>  };
>  #ifdef CONFIG_LOCKD_V4
> @@ -457,6 +498,7 @@ static struct svc_version	nlmsvc_version
>  		.vs_vers	= 4,
>  		.vs_nproc	= 24,
>  		.vs_proc	= nlmsvc_procedures4,
> +		.vs_dispatch	= nlmsvc_dispatch,
>  		.vs_xdrsize	= NLMSVC_XDRSIZE,
>  };
>  #endif
> --- /nas/linux-2.6.8+kdb+nfsv4/fs/lockd/svclock.c	2004-08-17 14:35:33.000000000 -0700
> +++ /nas/linux-2.6.8-locks/fs/lockd/svclock.c	2004-09-15 09:27:17.233604392 -0700
> @@ -237,8 +237,18 @@ nlmsvc_delete_block(struct nlm_block *bl
> 
>  	/* Remove block from list */
>  	nlmsvc_remove_block(block);
> +#if 0
>  	posix_unblock_lock(&file->f_file, fl);
>  	block->b_granted = 0;
> +#else // this fix is from Trond
> +	if (fl->fl_next)
> +		posix_unblock_lock(&file->f_file, fl);
> +	if (unlock) {
> +		fl->fl_type = F_UNLCK;
> +		posix_lock_file(&file->f_file, fl);
> +		block->b_granted = 0;
> +	}
> +#endif
> 
>  	/* If the block is in the middle of a GRANT callback,
>  	 * don't kill it yet. */
> @@ -259,6 +269,8 @@ nlmsvc_delete_block(struct nlm_block *bl
>  	if (block->b_host)
>  		nlm_release_host(block->b_host);
>  	nlmclnt_freegrantargs(&block->b_call);
> +	if (block->b_fl)
> +		kfree(block->b_fl);
>  	kfree(block);
>  }
> 
> @@ -286,6 +298,29 @@ nlmsvc_traverse_blocks(struct nlm_host *
>  }
> 
>  /*
> + * Deferred lock request handling
> + */
> +
> +static u32
> +nlmsvc_defer_lock_rqst(struct svc_rqst *rqstp, struct nlm_block *block)
> +{
> +	u32 status = nlm_lck_denied_nolocks;
> +
> +	block->b_flags |= B_DEFERRED;
> +	block->b_done = 1;
> +	nlmsvc_insert_block(block, 7 * HZ);
> +	block->b_cache_req = &rqstp->rq_chandle;
> +        if (rqstp->rq_chandle.defer) {
> +		block->b_deferred_req = rqstp->rq_chandle.defer(block->b_cache_req);
> +		if (block->b_deferred_req != NULL)
> +			status = EINPROGRESS;
> +	}
> +	dprintk("lockd: nlmsvc_defer_lock_rqst block %p flags %ld status %d\n",
> +						block, block->b_flags, status);
> +	return status;
> +}
> +
> +/*
>   * Attempt to establish a lock, and if it can't be granted, block it
>   * if required.
>   */
> @@ -295,7 +330,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
>  {
>  	struct file_lock	*conflock;
>  	struct nlm_block	*block;
> -	int			error;
> +	u32			error;
> 
>  	dprintk("lockd: nlmsvc_lock(%s/%ld, ty=%d, pi=%d, %Ld-%Ld, bl=%d)\n",
>  				file->f_file.f_dentry->d_inode->i_sb->s_id,
> @@ -315,11 +350,76 @@ again:
>  	/* Lock file against concurrent access */
>  	down(&file->f_sema);
> 
> +	if (block && (block->b_flags & B_DEFERRED)) {
> +		if (block->b_flags & B_WAIT) {		/* blocking */
> +			if (!(block->b_flags & B_GOT_CALLBACK) &&
> +			    !(block->b_flags & B_TOO_LATE)) {
> +				dprintk("lockd: nlmsvc_lock wait block %p flags %ld\n",
> +							block, block->b_flags);
> +				up(&file->f_sema);
> +				return nlm_lck_blocked;
> +			}
> +			if (block->b_flags & B_GOT_LOCK) {
> +				error = nlm_granted;
> +				nlmsvc_delete_block(block, 0);
> +			}
> +			else {
> +				nlmsvc_insert_block(block, 30 * HZ);
> +				error = nlm_lck_blocked;
> +			}
> +			dprintk("lockd: nlmsvc_lock wait block %p error %d\n",
> +								block, -error);
> +			up(&file->f_sema);
> +			return error;
> +		}
> +		else {
> +			if (!(block->b_flags & B_GOT_CALLBACK) &&
> +			    !(block->b_flags & B_TOO_LATE)) {
> +				dprintk("lockd: nlmsvc_lock again block %p flags %ld\n",
> +							block, block->b_flags);
> +				up(&file->f_sema);
> +				return EINPROGRESS;
> +			}
> +			if (block->b_flags & B_GOT_LOCK) {
> +				nlmsvc_delete_block(block, 0);
> +				error = nlm_granted;
> +			}
> +			else {
> +				nlmsvc_delete_block(block, 1);
> +				error = nlm_lck_denied;
> +			}
> +			dprintk("lockd: nlmsvc_lock deferred block %p error %d\n",
> +								block, -error);
> +			up(&file->f_sema);
> +			return error;
> +		}
> +	}
>  	if (!(conflock = posix_test_lock(&file->f_file, &lock->fl))) {
> -		error = posix_lock_file(&file->f_file, &lock->fl);
> +		error = vfs_lock_file(&file->f_file, &lock->fl, wait);
> 
> -		if (block)
> +		/* check for callback on non blocking request */
> +		dprintk("lockd: vfs_lock_file rc %d block %p wait %d\n",
> +			-error, block, wait);
> +		if ((block == NULL) && (error == -EINPROGRESS) && !wait) {
> +			if (!(block = nlmsvc_create_block(rqstp, file, lock, cookie)))
> +				return nlm_lck_denied_nolocks;
> +			error = nlmsvc_defer_lock_rqst(rqstp, block);
> +			up(&file->f_sema);
> +			return error;
> +		}
> +		if ((block == NULL) && (error == -EINPROGRESS) && wait) {
> +			if (!(block = nlmsvc_create_block(rqstp, file, lock, cookie)))
> +				return nlm_lck_denied_nolocks;
> +			block->b_flags |= B_DEFERRED;
> +			block->b_flags |= B_WAIT;
> +			block->b_done = 1;
> +			nlmsvc_insert_block(block, NLM_NEVER);
> +			up(&file->f_sema);
> +			return nlm_lck_blocked;
> +		}
> +		if (block && !(block->b_flags & B_DEFERRED))
>  			nlmsvc_delete_block(block, 0);
> +
>  		up(&file->f_sema);
> 
>  		dprintk("lockd: posix_lock_file returned %d\n", -error);
> @@ -375,10 +475,13 @@ again:
>   * Test for presence of a conflicting lock.
>   */
>  u32
> -nlmsvc_testlock(struct nlm_file *file, struct nlm_lock *lock,
> -				       struct nlm_lock *conflock)
> +nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
> +		struct nlm_lock *lock, struct nlm_lock *conflock,
> +		struct nlm_cookie *cookie)
>  {
>  	struct file_lock	*fl;
> +	struct nlm_block	*block;
> +	u32	error;
> 
>  	dprintk("lockd: nlmsvc_testlock(%s/%ld, ty=%d, %Ld-%Ld)\n",
>  				file->f_file.f_dentry->d_inode->i_sb->s_id,
> @@ -387,7 +490,38 @@ nlmsvc_testlock(struct nlm_file *file, s
>  				(long long)lock->fl.fl_start,
>  				(long long)lock->fl.fl_end);
> 
> -	if ((fl = posix_test_lock(&file->f_file, &lock->fl)) != NULL) {
> +	lock->fl.fl_flags |= FL_LOCKD;
> +
> +	/* Get existing block (in case client is busy-waiting) */
> +	block = nlmsvc_lookup_block(file, lock, 0);
> +
> +	if (block && (block->b_flags & B_DEFERRED)) {
> +		if (!(block->b_flags & B_GOT_CALLBACK) &&
> +		    !(block->b_flags & B_TOO_LATE)) {
> +			dprintk("lockd: nlmsvc_testlock block %p flags %ld\n",
> +							block, block->b_flags);
> +			return EINPROGRESS;
> +		}
> +		fl = block->b_fl;
> +		if (block->b_flags & B_GOT_LOCK && fl != NULL) {
> +			dprintk("lockd: nlmsvc_testlock conflicting lock(ty=%d, %Ld-%Ld)\n",
> +				fl->fl_type, (long long)fl->fl_start,
> +				(long long)fl->fl_end);
> +			conflock->caller = "somehost";	/* FIXME */
> +			conflock->oh.len = 0;	/* don't return OH info */
> +			memcpy(&conflock->fl, fl, sizeof(struct file_lock));
> +			error = nlm_lck_denied;
> +		}
> +		else {
> +			error = nlm_granted;
> +		}
> +		nlmsvc_delete_block(block, 0);
> +		dprintk("lockd: nlmsvc_testlock deferred block %p error %d\n",
> +								block, error);
> +		return error;
> +	}
> +	error = vfs_test_lock(&file->f_file, &lock->fl, &fl);
> +	if (error == 0 && fl) {
>  		dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
>  				fl->fl_type, (long long)fl->fl_start,
>  				(long long)fl->fl_end);
> @@ -396,7 +530,13 @@ nlmsvc_testlock(struct nlm_file *file, s
>  		conflock->fl = *fl;
>  		return nlm_lck_denied;
>  	}
> -
> +	if (error == -EINPROGRESS && block == NULL) {
> +		if (!(block = nlmsvc_create_block(rqstp, file, lock, cookie)))
> +			return nlm_granted;
> +		block->b_flags |= B_TEST;
> +		error = nlmsvc_defer_lock_rqst(rqstp, block);
> +		return error;
> +	}
>  	return nlm_granted;
>  }
> 
> @@ -423,7 +563,8 @@ nlmsvc_unlock(struct nlm_file *file, str
>  	nlmsvc_cancel_blocked(file, lock);
> 
>  	lock->fl.fl_type = F_UNLCK;
> -	error = posix_lock_file(&file->f_file, &lock->fl);
> +	lock->fl.fl_flags |= FL_LOCKD;
> +	error = vfs_lock_file(&file->f_file, &lock->fl, 0);
> 
>  	return (error < 0)? nlm_lck_denied_nolocks : nlm_granted;
>  }
> @@ -478,6 +619,68 @@ nlmsvc_notify_blocked(struct file_lock *
>  	printk(KERN_WARNING "lockd: notification for unknown block!\n");
>  }
> 
> +/*
> + * This is a callback from the filesystem for VFS file lock requests.
> + * It will be used if fl_vfs_callback is defined and the filesystem can not
> + * response to the request immediately.
> + * For GETLK request it will copy the reply to the nlm_block.
> + * For SETLK or SETLKW request it will get the local posix lock.
> + * In all cases it will move the block to the head of nlm_blocked q where
> + * nlmsvc_retry_blocked() can send back a reply for SETLKW or revisit the
> + * deferred rpc for GETLK and SETLK.
> + */
> +static int
> +nlmsvc_vfs_lock_callback(struct file_lock *fl, struct file_lock *conf, int result)
> +{
> +	struct nlm_block	**bp, *block;
> +	struct nlm_file		*file;
> +        int rc = 0;
> +
> +	dprintk("lockd: nlmsvc_vfs_lock_callback for lock %p conf %p result %d\n",
> +							fl, conf, result);
> +	lock_kernel();
> +	for (bp = &nlm_blocked; (block = *bp) != 0; bp = &block->b_next) {
> +		if (nlm_compare_locks(&block->b_call.a_args.lock.fl, fl)) {
> +			if (block->b_flags & B_DEFERRED) {
> +				block->b_flags |= B_GOT_CALLBACK;
> +				if (block->b_flags & B_TOO_LATE) {
> +                        		rc = 1;
> +					break;
> +				}
> +                                if (block->b_flags & B_TEST) {
> +                                	if (result == EBUSY && conf && conf->fl_type != F_UNLCK) {
> +						block->b_fl = (struct file_loc *)
> +							kmalloc(sizeof(*block), GFP_KERNEL);
> +						if (block->b_fl) {
> +							memcpy(block->b_fl, conf,
> +								sizeof(struct file_lock));
> +							block->b_flags |= B_GOT_LOCK;
> +						}
> +					}
> +				}
> +				else {
> +					if (result == 0) {
> +						file = block->b_file;
> +						rc = posix_lock_file(&file->f_file,
> +							&block->b_call.a_args.lock.fl);
> +						if (rc == 0) {
> +							block->b_flags |= B_GOT_LOCK;
> +							block->b_granted = 1;
> +						}
> +					}
> +				}
> +				nlmsvc_insert_block(block, 0);
> +				svc_wake_up(block->b_daemon);
> +				break;
> +			}
> +		}
> +	}
> +	unlock_kernel();
> +	dprintk("lockd: nlmsvc_vfs_lock_callback done block %p flags %ld\n",
> +					block, block ? block->b_flags : 0);
> +	return rc;
> +}
> +
>  static int nlmsvc_same_owner(struct file_lock *fl1, struct file_lock *fl2)
>  {
>  	return fl1->fl_owner == fl2->fl_owner && fl1->fl_pid == fl2->fl_pid;
> @@ -486,6 +689,7 @@ static int nlmsvc_same_owner(struct file
>  struct lock_manager_operations nlmsvc_lock_operations = {
>  	.fl_compare_owner = nlmsvc_same_owner,
>  	.fl_notify = nlmsvc_notify_blocked,
> +	.fl_vfs_callback = nlmsvc_vfs_lock_callback,
>  };
> 
>  /*
> @@ -537,7 +741,7 @@ nlmsvc_grant_blocked(struct nlm_block *b
>  	 * following yields an error, this is most probably due to low
>  	 * memory. Retry the lock in a few seconds.
>  	 */
> -	if ((error = posix_lock_file(&file->f_file, &lock->fl)) < 0) {
> +	if ((error = vfs_lock_file(&file->f_file, &lock->fl, 0)) < 0) {
>  		printk(KERN_WARNING "lockd: unexpected error %d in %s!\n",
>  				-error, __FUNCTION__);
>  		nlmsvc_insert_block(block, 10 * HZ);
> @@ -669,8 +873,27 @@ nlmsvc_retry_blocked(void)
>  			break;
>  		dprintk("nlmsvc_retry_blocked(%p, when=%ld, done=%d)\n",
>  			block, block->b_when, block->b_done);
> -		if (block->b_done)
> -			nlmsvc_delete_block(block, 0);
> +		if (block->b_done) {
> +			if (block->b_flags & B_DEFERRED) {
> +			        if (!(block->b_flags & B_GOT_CALLBACK) &&
> +			            !(block->b_flags & B_WAIT)) {
> +				        block->b_flags |= B_TOO_LATE;
> +			        }
> +			        if (block->b_flags & B_WAIT) {
> +					if (block->b_granted)
> +						nlmsvc_grant_blocked(block);
> +					nlmsvc_delete_block(block, 0);
> +				}
> +				else {
> +				        nlmsvc_insert_block(block, NLM_NEVER);
> +					dprintk("lockd: nlmsvc_retry_blocked revisit block %p flags %ld\n",
> +							block, block->b_flags);
> +					block->b_deferred_req->revisit(block->b_deferred_req, 0);
> +				}
> +			}
> +			else
> +				nlmsvc_delete_block(block, 0);
> +		}
>  		else
>  			nlmsvc_grant_blocked(block);
>  	}
> --- /nas/linux-2.6.8+kdb+nfsv4/fs/lockd/svcproc.c	2004-08-17 14:35:33.000000000 -0700
> +++ /nas/linux-2.6.8-locks/fs/lockd/svcproc.c	2004-09-08 22:23:17.000000000 -0700
> @@ -129,7 +129,9 @@ nlmsvc_proc_test(struct svc_rqst *rqstp,
>  		return rpc_success;
> 
>  	/* Now check for conflicting locks */
> -	resp->status = cast_status(nlmsvc_testlock(file, &argp->lock, &resp->lock));
> +	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie);
> +	if (resp->status != EINPROGRESS)
> +		resp->status = cast_status(resp->status);
> 
>  	dprintk("lockd: TEST          status %d vers %d\n",
>  		ntohl(resp->status), rqstp->rq_vers);
> @@ -172,8 +174,9 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp,
>  #endif
> 
>  	/* Now try to lock the file */
> -	resp->status = cast_status(nlmsvc_lock(rqstp, file, &argp->lock,
> -					       argp->block, &argp->cookie));
> +	resp->status = nlmsvc_lock(rqstp, file, &argp->lock, argp->block, &argp->cookie);
> +	if (resp->status != EINPROGRESS)
> +		resp->status = cast_status(resp->status);
> 
>  	dprintk("lockd: LOCK          status %d\n", ntohl(resp->status));
>  	nlm_release_host(host);
> --- /nas/linux-2.6.8+kdb+nfsv4/fs/lockd/svc4proc.c	2004-08-17 14:35:33.000000000 -0700
> +++ /nas/linux-2.6.8-locks/fs/lockd/svc4proc.c	2004-09-08 20:20:27.000000000 -0700
> @@ -102,7 +102,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
>  		return rpc_success;
> 
>  	/* Now check for conflicting locks */
> -	resp->status = nlmsvc_testlock(file, &argp->lock, &resp->lock);
> +	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie);
> 
>  	dprintk("lockd: TEST4          status %d\n", ntohl(resp->status));
>  	nlm_release_host(host);
> @@ -144,8 +144,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
>  #endif
> 
>  	/* Now try to lock the file */
> -	resp->status = nlmsvc_lock(rqstp, file, &argp->lock,
> -					argp->block, &argp->cookie);
> +	resp->status = nlmsvc_lock(rqstp, file, &argp->lock, argp->block, &argp->cookie);
> 
>  	dprintk("lockd: LOCK          status %d\n", ntohl(resp->status));
>  	nlm_release_host(host);
> --- /nas/linux-2.6.8+kdb+nfsv4/fs/lockd/svcsubs.c	2004-08-17 14:35:33.000000000 -0700
> +++ /nas/linux-2.6.8-locks/fs/lockd/svcsubs.c	2004-09-15 09:29:02.400616576 -0700
> @@ -176,7 +176,7 @@ again:
>  			lock.fl_type  = F_UNLCK;
>  			lock.fl_start = 0;
>  			lock.fl_end   = OFFSET_MAX;
> -			if (posix_lock_file(&file->f_file, &lock) < 0) {
> +			if (vfs_lock_file(&file->f_file, &lock, 0) < 0) {
>  				printk("lockd: unlock failure in %s:%d\n",
>  						__FILE__, __LINE__);
>  				return 1;
> --- /nas/linux-2.6.8+kdb+nfsv4/include/linux/fs.h	2004-08-17 14:35:33.000000000 -0700
> +++ /nas/linux-2.6.8-locks/include/linux/fs.h	2004-09-15 09:25:14.355284736 -0700
> @@ -617,6 +617,7 @@ extern void close_private_file(struct fi
>  #define FL_LEASE	32	/* lease held on this file */
>  #define FL_SLEEP	128	/* A blocking lock */
>  #define FL_NFSD		256	/* lock held by nfsd v4 */
> +#define FL_FREE		512	/* file lock should be freed */
> 
>  /*
>   * The POSIX file lock owner is determined by
> @@ -638,6 +639,7 @@ struct file_lock_operations {
>  struct lock_manager_operations {
>  	int (*fl_compare_owner)(struct file_lock *, struct file_lock *);
>  	void (*fl_notify)(struct file_lock *);	/* unblock callback */
> +	int (*fl_vfs_callback)(struct file_lock *, struct file_lock *, int result);
>  };
> 
>  /* that will die - we need it for nfs_lock_info */
> @@ -697,7 +699,9 @@ extern void locks_remove_flock(struct fi
>  extern struct file_lock *posix_test_lock(struct file *, struct file_lock *);
>  extern int posix_lock_file(struct file *, struct file_lock *);
>  extern int posix_lock_file_wait(struct file *, struct file_lock *);
> -extern void posix_block_lock(struct file_lock *, struct file_lock *);
> +extern int vfs_lock_file(struct file *, struct file_lock *, int);
> +extern int vfs_test_lock(struct file *, struct file_lock *, struct file_lock **);
> +extern int posix_block_lock(struct file_lock *, struct file_lock *);
>  extern void posix_unblock_lock(struct file *, struct file_lock *);
>  extern int posix_locks_deadlock(struct file_lock *, struct file_lock *);
>  extern int __break_lease(struct inode *inode, unsigned int flags);
> --- /nas/linux-2.6.8+kdb+nfsv4/include/linux/lockd/lockd.h	2004-08-17 14:35:33.000000000 -0700
> +++ /nas/linux-2.6.8-locks/include/linux/lockd/lockd.h	2004-09-08 17:09:26.000000000 -0700
> @@ -119,6 +119,16 @@ struct nlm_block {
>  	unsigned char		b_incall;	/* doing callback */
>  	unsigned char		b_done;		/* callback complete */
>  	struct nlm_file *	b_file;		/* file in question */
> +	struct cache_req *	b_cache_req;	/* deferred request handling */
> +	struct file_lock *	b_fl;		/* set for GETLK */
> +	struct cache_deferred_req * b_deferred_req;
> +	unsigned long		b_flags;        /* block flags */
> +#define B_DEFERRED		1  /* Deferred lock */
> +#define B_GOT_LOCK		2  /* Got deferred lock */
> +#define B_TOO_LATE		4  /* Too late for deferred lock */
> +#define B_GOT_CALLBACK		8  /* Got filesystem callback */
> +#define B_WAIT			16 /* Deferred Blocking lock */
> +#define B_TEST			32 /* Deferred Test lock */
>  };
> 
>  /*
> @@ -174,8 +184,8 @@ int		  nlmsvc_async_call(struct nlm_rqst
>  u32		  nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
>  					struct nlm_lock *, int, struct nlm_cookie *);
>  u32		  nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
> -u32		  nlmsvc_testlock(struct nlm_file *, struct nlm_lock *,
> -					struct nlm_lock *);
> +u32		  nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
> +			struct nlm_lock *, struct nlm_lock *, struct nlm_cookie *);
>  u32		  nlmsvc_cancel_blocked(struct nlm_file *, struct nlm_lock *);
>  unsigned long	  nlmsvc_retry_blocked(void);
>  int		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
> 
> 
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
> 




-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

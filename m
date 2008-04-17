From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs: infinite loop in fcntl(F_SETLKW)
Date: Thu, 17 Apr 2008 18:26:20 -0400
Message-ID: <20080417222620.GL9912@fieldses.org>
References: <E1Jk2oI-0007UX-MS@pomaz-ex.szeredi.hu> <1207861339.8180.14.camel@heimdal.trondhjem.org> <1207861661.8180.18.camel@heimdal.trondhjem.org> <1207862436.8180.30.camel@heimdal.trondhjem.org> <20080410215410.GF22324@fieldses.org> <E1JkxZI-0003Bc-9C@pomaz-ex.szeredi.hu> <20080414171909.GE15950@fieldses.org> <E1JlW1p-0006vZ-NW@pomaz-ex.szeredi.hu> <20080415185856.GI32218@fieldses.org> <E1JmAUP-0002VA-9g@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, eshel@almaden.ibm.com, neilb@suse.de,
	akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1JmAUP-0002VA-9g@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 16, 2008 at 06:28:05PM +0200, Miklos Szeredi wrote:
> > > > The behavior of lockd will still depend to some degree on the exact
> > > > error returned from the filesystem--e.g. if you return -EAGAIN from
> > > > ->lock() without later calling ->fl_grant() it will cause some
> > > > unexpected delays.  (Though again clients will eventually give up and
> > > > poll for the lock.)
> > > 
> > > OK, so the semantics of vfs_lock_file() are now:
> > 
> > Not quite; the original idea was that we didn't care about the blocking
> > lock case, since there's already a lock manager callback for that.
> > (It's arguably a minor abuse for us to return NLM_LCK_BLOCKED and then
> > do a grant later even in the case where there's no conflict, but it
> > works.)  So we only changed the nonblocking case.
> > 
> > Which may be sacrificing elegance for expediency, and I'm not opposed to
> > fixing that in whatever way seems best.  As a start, we could document
> > this better.  So:
> > 
> > > 
> > > 1) if !FL_SLEEP, then return 0 if granted, -EAGAIN on contention
> > > 2) if FL_SLEEP and fl_grant == NULL, then return 0 if granted, block on
> > >    contention
> > > 3) if FL_SLEEP and fl_grant != NULL, then return 0 if granted, on
> > >    contention:
> > >    a) either return -EINPROGRESS and call fl_grant when granted
> > >    b) or return -EAGAIN  and call fl_notify when the lock needs retrying
> > 
> > I'd put it this way (after a quick check of the code to convince myself
> > I'm remembering this right...):
> > 
> >   1) If FL_SLEEP, then return 0 if granted, and on contention either:
> >      a) block, or
> >      b) return -EAGAIN, and call fl_notify when the lock should be
> >         retried.
> 
> Gfs2 seems to return -EINPROGRESS regardless of the FL_SLEEP flag:

Oops, you're right; in FL_SLEEP case fs/lockd/svclock.c:nlmsvc_lock() 
returns NLM_LCK_BLOCKED.  I believe it'll get an fl_grant() callback
after that and do a grant call back to the client, but I haven't
checked....

Note, as has been pointed out by Mark Snitzer
(http://article.gmane.org/gmane.linux.nfs/17801/), this limits the kind
of error reporting the filesystem can do--if it needs to block on the
initial lock call, it has to commit to queueing up, and eventually
granting, the lock.

> > OK, but I haven't read your patch yet, apologies....
> 
> No problem.  Here it is again with some cosmetic fixes and testing.

Thanks!  Ping me in a couple days if I haven't made any comments.  From
a quick skim the GFS2 change and the error return change both seem
reasonable.

I need to a real GFS2 testing setup....  (Did you test GFS2 locking
specifically?)

--b.

> 
> Miklos
> --
> 
> 
> Use a special error value FILE_LOCK_DEFERRED to mean that a locking
> operation returned asynchronously.  This is returned by
> 
>   posix_lock_file() for sleeping locks to mean that the lock has been
>   queued on the block list, and will be woken up when it might become
>   available and needs to be retried (either fl_lmops->fl_notify() is
>   called or fl_wait is woken up).
> 
>   f_op->lock() to mean either the above, or that the filesystem will
>   call back with fl_lmops->fl_grant() when the result of the locking
>   operation is known.  The filesystem can do this for sleeping as well
>   as non-sleeping locks.
> 
> This is to make sure, that return values of -EAGAIN and -EINPROGRESS
> by filesystems are not mistaken to mean an asynchronous locking.
> 
> This also makes error handling in fs/locks.c and lockd/svclock.c
> slightly cleaner.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---
>  fs/gfs2/locking/dlm/plock.c |    2 +-
>  fs/lockd/svclock.c          |   13 ++++---------
>  fs/locks.c                  |   28 ++++++++++++++--------------
>  include/linux/fs.h          |    6 ++++++
>  4 files changed, 25 insertions(+), 24 deletions(-)
> 
> Index: linux-2.6/fs/locks.c
> ===================================================================
> --- linux-2.6.orig/fs/locks.c	2008-04-16 17:33:49.000000000 +0200
> +++ linux-2.6/fs/locks.c	2008-04-16 17:38:01.000000000 +0200
> @@ -784,8 +784,10 @@ find_conflict:
>  		if (!flock_locks_conflict(request, fl))
>  			continue;
>  		error = -EAGAIN;
> -		if (request->fl_flags & FL_SLEEP)
> -			locks_insert_block(fl, request);
> +		if (!(request->fl_flags & FL_SLEEP))
> +			goto out;
> +		error = FILE_LOCK_DEFERRED;
> +		locks_insert_block(fl, request);
>  		goto out;
>  	}
>  	if (request->fl_flags & FL_ACCESS)
> @@ -841,7 +843,7 @@ static int __posix_lock_file(struct inod
>  			error = -EDEADLK;
>  			if (posix_locks_deadlock(request, fl))
>  				goto out;
> -			error = -EAGAIN;
> +			error = FILE_LOCK_DEFERRED;
>  			locks_insert_block(fl, request);
>  			goto out;
>    		}
> @@ -1040,7 +1042,7 @@ int posix_lock_file_wait(struct file *fi
>  	might_sleep ();
>  	for (;;) {
>  		error = posix_lock_file(filp, fl, NULL);
> -		if ((error != -EAGAIN) || !(fl->fl_flags & FL_SLEEP))
> +		if (error != FILE_LOCK_DEFERRED)
>  			break;
>  		error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
>  		if (!error)
> @@ -1112,9 +1114,7 @@ int locks_mandatory_area(int read_write,
>  
>  	for (;;) {
>  		error = __posix_lock_file(inode, &fl, NULL);
> -		if (error != -EAGAIN)
> -			break;
> -		if (!(fl.fl_flags & FL_SLEEP))
> +		if (error != FILE_LOCK_DEFERRED)
>  			break;
>  		error = wait_event_interruptible(fl.fl_wait, !fl.fl_next);
>  		if (!error) {
> @@ -1534,7 +1534,7 @@ int flock_lock_file_wait(struct file *fi
>  	might_sleep();
>  	for (;;) {
>  		error = flock_lock_file(filp, fl);
> -		if ((error != -EAGAIN) || !(fl->fl_flags & FL_SLEEP))
> +		if (error != FILE_LOCK_DEFERRED)
>  			break;
>  		error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
>  		if (!error)
> @@ -1719,17 +1719,17 @@ out:
>   * fl_grant is set. Callers expecting ->lock() to return asynchronously
>   * will only use F_SETLK, not F_SETLKW; they will set FL_SLEEP if (and only if)
>   * the request is for a blocking lock. When ->lock() does return asynchronously,
> - * it must return -EINPROGRESS, and call ->fl_grant() when the lock
> + * it must return FILE_LOCK_DEFERRED, and call ->fl_grant() when the lock
>   * request completes.
>   * If the request is for non-blocking lock the file system should return
> - * -EINPROGRESS then try to get the lock and call the callback routine with
> - * the result. If the request timed out the callback routine will return a
> + * FILE_LOCK_DEFERRED then try to get the lock and call the callback routine
> + * with the result. If the request timed out the callback routine will return a
>   * nonzero return code and the file system should release the lock. The file
>   * system is also responsible to keep a corresponding posix lock when it
>   * grants a lock so the VFS can find out which locks are locally held and do
>   * the correct lock cleanup when required.
>   * The underlying filesystem must not drop the kernel lock or call
> - * ->fl_grant() before returning to the caller with a -EINPROGRESS
> + * ->fl_grant() before returning to the caller with a FILE_LOCK_DEFERRED
>   * return code.
>   */
>  int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl, struct file_lock *conf)
> @@ -1806,7 +1806,7 @@ again:
>  	else {
>  		for (;;) {
>  			error = posix_lock_file(filp, file_lock, NULL);
> -			if (error != -EAGAIN || cmd == F_SETLK)
> +			if (error != FILE_LOCK_DEFERRED)
>  				break;
>  			error = wait_event_interruptible(file_lock->fl_wait,
>  					!file_lock->fl_next);
> @@ -1934,7 +1934,7 @@ again:
>  	else {
>  		for (;;) {
>  			error = posix_lock_file(filp, file_lock, NULL);
> -			if (error != -EAGAIN || cmd == F_SETLK64)
> +			if (error != FILE_LOCK_DEFERRED)
>  				break;
>  			error = wait_event_interruptible(file_lock->fl_wait,
>  					!file_lock->fl_next);
> Index: linux-2.6/fs/gfs2/locking/dlm/plock.c
> ===================================================================
> --- linux-2.6.orig/fs/gfs2/locking/dlm/plock.c	2008-04-16 17:33:49.000000000 +0200
> +++ linux-2.6/fs/gfs2/locking/dlm/plock.c	2008-04-16 17:35:46.000000000 +0200
> @@ -108,7 +108,7 @@ int gdlm_plock(void *lockspace, struct l
>  	if (xop->callback == NULL)
>  		wait_event(recv_wq, (op->done != 0));
>  	else
> -		return -EINPROGRESS;
> +		return FILE_LOCK_DEFERRED;
>  
>  	spin_lock(&ops_lock);
>  	if (!list_empty(&op->list)) {
> Index: linux-2.6/fs/lockd/svclock.c
> ===================================================================
> --- linux-2.6.orig/fs/lockd/svclock.c	2008-04-16 17:33:49.000000000 +0200
> +++ linux-2.6/fs/lockd/svclock.c	2008-04-16 17:35:46.000000000 +0200
> @@ -423,8 +423,8 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
>  			goto out;
>  		case -EAGAIN:
>  			ret = nlm_lck_denied;
> -			break;
> -		case -EINPROGRESS:
> +			goto out;
> +		case FILE_LOCK_DEFERRED:
>  			if (wait)
>  				break;
>  			/* Filesystem lock operation is in progress
> @@ -439,10 +439,6 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
>  			goto out;
>  	}
>  
> -	ret = nlm_lck_denied;
> -	if (!wait)
> -		goto out;
> -
>  	ret = nlm_lck_blocked;
>  
>  	/* Append to list of blocked */
> @@ -520,7 +516,7 @@ nlmsvc_testlock(struct svc_rqst *rqstp, 
>  	}
>  
>  	error = vfs_test_lock(file->f_file, &lock->fl);
> -	if (error == -EINPROGRESS) {
> +	if (error == FILE_LOCK_DEFERRED) {
>  		ret = nlmsvc_defer_lock_rqst(rqstp, block);
>  		goto out;
>  	}
> @@ -744,8 +740,7 @@ nlmsvc_grant_blocked(struct nlm_block *b
>  	switch (error) {
>  	case 0:
>  		break;
> -	case -EAGAIN:
> -	case -EINPROGRESS:
> +	case FILE_LOCK_DEFERRED:
>  		dprintk("lockd: lock still blocked error %d\n", error);
>  		nlmsvc_insert_block(block, NLM_NEVER);
>  		nlmsvc_release_block(block);
> Index: linux-2.6/include/linux/fs.h
> ===================================================================
> --- linux-2.6.orig/include/linux/fs.h	2008-04-16 17:33:49.000000000 +0200
> +++ linux-2.6/include/linux/fs.h	2008-04-16 18:17:12.000000000 +0200
> @@ -837,6 +837,12 @@ extern spinlock_t files_lock;
>  #define FL_SLEEP	128	/* A blocking lock */
>  
>  /*
> + * Special return value from posix_lock_file() and vfs_lock_file() for
> + * asynchronous locking.
> + */
> +#define FILE_LOCK_DEFERRED 1
> +
> +/*
>   * The POSIX file lock owner is determined by
>   * the "struct files_struct" in the thread group
>   * (or NULL for no owner - BSD locks).
> 
> 
> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755922Ab3FMPKR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 11:10:17 -0400
Date: Thu, 13 Jun 2013 11:09:33 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v2 07/14] locks: convert to i_lock to protect i_flock
 list
Message-ID: <20130613110933.0e8b17fc@corrin.poochiereds.net>
In-Reply-To: <20130613144140.GA20235@fieldses.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
	<1370948948-31784-8-git-send-email-jlayton@redhat.com>
	<20130613144140.GA20235@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 13 Jun 2013 10:41:40 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jun 11, 2013 at 07:09:01AM -0400, Jeff Layton wrote:
> > Having a global lock that protects all of this code is a clear
> > scalability problem. Instead of doing that, move most of the code to be
> > protected by the i_lock instead.
> > 
> > The exceptions are the global lists that file_lock->fl_link sits on.
> > Those still need a global lock of some sort, so wrap just those accesses
> > in the file_lock_lock().
> > 
> > Note that this patch introduces a potential race in the deadlock
> > detection code which could result in either false positives or missed
> > file_lock loops. The blocked_list management needs to be done atomically
> > with the deadlock detection. This will be fixed in a later patch.
> 
> Actually, the way I think I'd try this:
> 
> 	1. Introduce a new spinlock global_lock_lists_lock and take it
> 	   in all the places we need a global lock.
> 	2. Do the big flock_lock-to-i_lock conversion, deleting flock_lock
> 	   in the process.
> 
> Does that work?
> 
> Yeah, more patch-ordering bike-shedding, but...  I think that would be
> simple and bisectable and for a confusing long-untouched bit of code
> it's worth getting these little steps right if we can.
> 
> 

I don't know...that really sounds more like it'll just add to the
churn without making anything simpler. If we're concerned about
bisectability, I think it'd just be best to merge patches 7 and 8 and
call it a day...

> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  Documentation/filesystems/Locking |   23 +++++--
> >  fs/afs/flock.c                    |    5 +-
> >  fs/ceph/locks.c                   |    2 +-
> >  fs/ceph/mds_client.c              |    8 +-
> >  fs/cifs/cifsfs.c                  |    2 +-
> >  fs/cifs/file.c                    |   13 ++--
> >  fs/gfs2/file.c                    |    2 +-
> >  fs/lockd/svcsubs.c                |   12 ++--
> >  fs/locks.c                        |  110 ++++++++++++++++++++-----------------
> >  fs/nfs/delegation.c               |   11 ++--
> >  fs/nfs/nfs4state.c                |    8 +-
> >  fs/nfsd/nfs4state.c               |    8 +-
> >  include/linux/fs.h                |   11 ----
> >  13 files changed, 113 insertions(+), 102 deletions(-)
> > 
> > diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> > index 0706d32..13f91ab 100644
> > --- a/Documentation/filesystems/Locking
> > +++ b/Documentation/filesystems/Locking
> > @@ -344,7 +344,7 @@ prototypes:
> >  
> >  
> >  locking rules:
> > -			file_lock_lock	may block
> > +			inode->i_lock	may block
> >  fl_copy_lock:		yes		no
> >  fl_release_private:	maybe		no
> >  
> > @@ -357,12 +357,21 @@ prototypes:
> >  	int (*lm_change)(struct file_lock **, int);
> >  
> >  locking rules:
> > -			file_lock_lock	may block
> > -lm_compare_owner:	yes		no
> > -lm_notify:		yes		no
> > -lm_grant:		no		no
> > -lm_break:		yes		no
> > -lm_change		yes		no
> > +
> > +			inode->i_lock	file_lock_lock	may block
> > +lm_compare_owner:	yes		maybe		no
> > +lm_notify:		yes		no		no
> > +lm_grant:		no		no		no
> > +lm_break:		yes		no		no
> > +lm_change		yes		no		no
> > +
> > +	->lm_compare_owner is generally called with *an* inode->i_lock
> > +held. It may not be the i_lock of the inode for either file_lock being
> > +compared! This is the case with deadlock detection, since the code has
> > +to chase down the owners of locks that may be entirely unrelated to the
> > +one on which the lock is being acquired. For deadlock detection however,
> > +the file_lock_lock is also held. The locks primarily ensure that neither
> > +file_lock disappear out from under you while doing the comparison.
> >  
> >  --------------------------- buffer_head -----------------------------------
> >  prototypes:
> > diff --git a/fs/afs/flock.c b/fs/afs/flock.c
> > index 2497bf3..03fc0d1 100644
> > --- a/fs/afs/flock.c
> > +++ b/fs/afs/flock.c
> > @@ -252,6 +252,7 @@ static void afs_defer_unlock(struct afs_vnode *vnode, struct key *key)
> >   */
> >  static int afs_do_setlk(struct file *file, struct file_lock *fl)
> >  {
> > +	struct inode = file_inode(file);
> >  	struct afs_vnode *vnode = AFS_FS_I(file->f_mapping->host);
> >  	afs_lock_type_t type;
> >  	struct key *key = file->private_data;
> > @@ -273,7 +274,7 @@ static int afs_do_setlk(struct file *file, struct file_lock *fl)
> >  
> >  	type = (fl->fl_type == F_RDLCK) ? AFS_LOCK_READ : AFS_LOCK_WRITE;
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  
> >  	/* make sure we've got a callback on this file and that our view of the
> >  	 * data version is up to date */
> > @@ -420,7 +421,7 @@ given_lock:
> >  	afs_vnode_fetch_status(vnode, NULL, key);
> >  
> >  error:
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	_leave(" = %d", ret);
> >  	return ret;
> >  
> > diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
> > index 202dd3d..cd0a664 100644
> > --- a/fs/ceph/locks.c
> > +++ b/fs/ceph/locks.c
> > @@ -194,7 +194,7 @@ void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
> >   * Encode the flock and fcntl locks for the given inode into the pagelist.
> >   * Format is: #fcntl locks, sequential fcntl locks, #flock locks,
> >   * sequential flock locks.
> > - * Must be called with lock_flocks() already held.
> > + * Must be called with inode->i_lock already held.
> >   * If we encounter more of a specific lock type than expected,
> >   * we return the value 1.
> >   */
> > diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
> > index 4f22671..ae621b5 100644
> > --- a/fs/ceph/mds_client.c
> > +++ b/fs/ceph/mds_client.c
> > @@ -2482,13 +2482,13 @@ static int encode_caps_cb(struct inode *inode, struct ceph_cap *cap,
> >  
> >  		ceph_pagelist_set_cursor(pagelist, &trunc_point);
> >  		do {
> > -			lock_flocks();
> > +			spin_lock(&inode->i_lock);
> >  			ceph_count_locks(inode, &num_fcntl_locks,
> >  					 &num_flock_locks);
> >  			rec.v2.flock_len = (2*sizeof(u32) +
> >  					    (num_fcntl_locks+num_flock_locks) *
> >  					    sizeof(struct ceph_filelock));
> > -			unlock_flocks();
> > +			spin_unlock(&inode->i_lock);
> >  
> >  			/* pre-alloc pagelist */
> >  			ceph_pagelist_truncate(pagelist, &trunc_point);
> > @@ -2499,12 +2499,12 @@ static int encode_caps_cb(struct inode *inode, struct ceph_cap *cap,
> >  
> >  			/* encode locks */
> >  			if (!err) {
> > -				lock_flocks();
> > +				spin_lock(&inode->i_lock);
> >  				err = ceph_encode_locks(inode,
> >  							pagelist,
> >  							num_fcntl_locks,
> >  							num_flock_locks);
> > -				unlock_flocks();
> > +				spin_unlock(&inode->i_lock);
> >  			}
> >  		} while (err == -ENOSPC);
> >  	} else {
> > diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> > index 3752b9f..e81655c 100644
> > --- a/fs/cifs/cifsfs.c
> > +++ b/fs/cifs/cifsfs.c
> > @@ -765,7 +765,7 @@ static loff_t cifs_llseek(struct file *file, loff_t offset, int whence)
> >  
> >  static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
> >  {
> > -	/* note that this is called by vfs setlease with lock_flocks held
> > +	/* note that this is called by vfs setlease with i_lock held
> >  	   to protect *lease from going away */
> >  	struct inode *inode = file_inode(file);
> >  	struct cifsFileInfo *cfile = file->private_data;
> > diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> > index 44a4f18..0dd10cd 100644
> > --- a/fs/cifs/file.c
> > +++ b/fs/cifs/file.c
> > @@ -1092,6 +1092,7 @@ struct lock_to_push {
> >  static int
> >  cifs_push_posix_locks(struct cifsFileInfo *cfile)
> >  {
> > +	struct inode *inode = cfile->dentry->d_inode;
> >  	struct cifs_tcon *tcon = tlink_tcon(cfile->tlink);
> >  	struct file_lock *flock, **before;
> >  	unsigned int count = 0, i = 0;
> > @@ -1102,12 +1103,12 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
> >  
> >  	xid = get_xid();
> >  
> > -	lock_flocks();
> > -	cifs_for_each_lock(cfile->dentry->d_inode, before) {
> > +	spin_lock(&inode->i_lock);
> > +	cifs_for_each_lock(inode, before) {
> >  		if ((*before)->fl_flags & FL_POSIX)
> >  			count++;
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  
> >  	INIT_LIST_HEAD(&locks_to_send);
> >  
> > @@ -1126,8 +1127,8 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
> >  	}
> >  
> >  	el = locks_to_send.next;
> > -	lock_flocks();
> > -	cifs_for_each_lock(cfile->dentry->d_inode, before) {
> > +	spin_lock(&inode->i_lock);
> > +	cifs_for_each_lock(inode, before) {
> >  		flock = *before;
> >  		if ((flock->fl_flags & FL_POSIX) == 0)
> >  			continue;
> > @@ -1152,7 +1153,7 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
> >  		lck->offset = flock->fl_start;
> >  		el = el->next;
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  
> >  	list_for_each_entry_safe(lck, tmp, &locks_to_send, llist) {
> >  		int stored_rc;
> > diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> > index acd1676..9e634e0 100644
> > --- a/fs/gfs2/file.c
> > +++ b/fs/gfs2/file.c
> > @@ -889,7 +889,7 @@ out_uninit:
> >   * cluster; until we do, disable leases (by just returning -EINVAL),
> >   * unless the administrator has requested purely local locking.
> >   *
> > - * Locking: called under lock_flocks
> > + * Locking: called under i_lock
> >   *
> >   * Returns: errno
> >   */
> > diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> > index 97e8741..dc5c759 100644
> > --- a/fs/lockd/svcsubs.c
> > +++ b/fs/lockd/svcsubs.c
> > @@ -169,7 +169,7 @@ nlm_traverse_locks(struct nlm_host *host, struct nlm_file *file,
> >  
> >  again:
> >  	file->f_locks = 0;
> > -	lock_flocks(); /* protects i_flock list */
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl; fl = fl->fl_next) {
> >  		if (fl->fl_lmops != &nlmsvc_lock_operations)
> >  			continue;
> > @@ -181,7 +181,7 @@ again:
> >  		if (match(lockhost, host)) {
> >  			struct file_lock lock = *fl;
> >  
> > -			unlock_flocks();
> > +			spin_unlock(&inode->i_lock);
> >  			lock.fl_type  = F_UNLCK;
> >  			lock.fl_start = 0;
> >  			lock.fl_end   = OFFSET_MAX;
> > @@ -193,7 +193,7 @@ again:
> >  			goto again;
> >  		}
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  
> >  	return 0;
> >  }
> > @@ -228,14 +228,14 @@ nlm_file_inuse(struct nlm_file *file)
> >  	if (file->f_count || !list_empty(&file->f_blocks) || file->f_shares)
> >  		return 1;
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl; fl = fl->fl_next) {
> >  		if (fl->fl_lmops == &nlmsvc_lock_operations) {
> > -			unlock_flocks();
> > +			spin_unlock(&inode->i_lock);
> >  			return 1;
> >  		}
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	file->f_locks = 0;
> >  	return 0;
> >  }
> > diff --git a/fs/locks.c b/fs/locks.c
> > index 3fd27f0..d7342a3 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -155,22 +155,9 @@ int lease_break_time = 45;
> >  
> >  static LIST_HEAD(file_lock_list);
> >  static LIST_HEAD(blocked_list);
> > -static DEFINE_SPINLOCK(file_lock_lock);
> > -
> > -/*
> > - * Protects the two list heads above, plus the inode->i_flock list
> > - */
> > -void lock_flocks(void)
> > -{
> > -	spin_lock(&file_lock_lock);
> > -}
> > -EXPORT_SYMBOL_GPL(lock_flocks);
> >  
> > -void unlock_flocks(void)
> > -{
> > -	spin_unlock(&file_lock_lock);
> > -}
> > -EXPORT_SYMBOL_GPL(unlock_flocks);
> > +/* Protects the two list heads above */
> > +static DEFINE_SPINLOCK(file_lock_lock);
> >  
> >  static struct kmem_cache *filelock_cache __read_mostly;
> >  
> > @@ -488,25 +475,33 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
> >  static inline void
> >  locks_insert_global_blocked(struct file_lock *waiter)
> >  {
> > +	spin_lock(&file_lock_lock);
> >  	list_add(&waiter->fl_link, &blocked_list);
> > +	spin_unlock(&file_lock_lock);
> >  }
> >  
> >  static inline void
> >  locks_delete_global_blocked(struct file_lock *waiter)
> >  {
> > +	spin_lock(&file_lock_lock);
> >  	list_del_init(&waiter->fl_link);
> > +	spin_unlock(&file_lock_lock);
> >  }
> >  
> >  static inline void
> >  locks_insert_global_locks(struct file_lock *waiter)
> >  {
> > +	spin_lock(&file_lock_lock);
> >  	list_add_tail(&waiter->fl_link, &file_lock_list);
> > +	spin_unlock(&file_lock_lock);
> >  }
> >  
> >  static inline void
> >  locks_delete_global_locks(struct file_lock *waiter)
> >  {
> > +	spin_lock(&file_lock_lock);
> >  	list_del_init(&waiter->fl_link);
> > +	spin_unlock(&file_lock_lock);
> >  }
> >  
> >  /* Remove waiter from blocker's block list.
> > @@ -523,9 +518,11 @@ static void __locks_delete_block(struct file_lock *waiter)
> >   */
> >  static void locks_delete_block(struct file_lock *waiter)
> >  {
> > -	lock_flocks();
> > +	struct inode *inode = file_inode(waiter->fl_file);
> > +
> > +	spin_lock(&inode->i_lock);
> >  	__locks_delete_block(waiter);
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  }
> >  
> >  /* Insert waiter into blocker's block list.
> > @@ -544,7 +541,7 @@ static void locks_insert_block(struct file_lock *blocker,
> >  /*
> >   * Wake up processes blocked waiting for blocker.
> >   *
> > - * Must be called with the file_lock_lock held!
> > + * Must be called with the inode->i_lock of the blocker held!
> >   */
> >  static void locks_wake_up_blocks(struct file_lock *blocker)
> >  {
> > @@ -649,8 +646,9 @@ void
> >  posix_test_lock(struct file *filp, struct file_lock *fl)
> >  {
> >  	struct file_lock *cfl;
> > +	struct inode *inode = file_inode(filp);
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	for (cfl = file_inode(filp)->i_flock; cfl; cfl = cfl->fl_next) {
> >  		if (!IS_POSIX(cfl))
> >  			continue;
> > @@ -663,7 +661,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
> >  			fl->fl_pid = pid_vnr(cfl->fl_nspid);
> >  	} else
> >  		fl->fl_type = F_UNLCK;
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return;
> >  }
> >  EXPORT_SYMBOL(posix_test_lock);
> > @@ -742,7 +740,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
> >  			return -ENOMEM;
> >  	}
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	if (request->fl_flags & FL_ACCESS)
> >  		goto find_conflict;
> >  
> > @@ -772,9 +770,9 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
> >  	 * give it the opportunity to lock the file.
> >  	 */
> >  	if (found) {
> > -		unlock_flocks();
> > +		spin_unlock(&inode->i_lock);
> >  		cond_resched();
> > -		lock_flocks();
> > +		spin_lock(&inode->i_lock);
> >  	}
> >  
> >  find_conflict:
> > @@ -801,7 +799,7 @@ find_conflict:
> >  	error = 0;
> >  
> >  out:
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	if (new_fl)
> >  		locks_free_lock(new_fl);
> >  	return error;
> > @@ -831,7 +829,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  		new_fl2 = locks_alloc_lock();
> >  	}
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	/*
> >  	 * New lock request. Walk all POSIX locks and look for conflicts. If
> >  	 * there are any, either return error or put the request on the
> > @@ -850,8 +848,14 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  			if (!(request->fl_flags & FL_SLEEP))
> >  				goto out;
> >  			error = -EDEADLK;
> > +			/*
> > +			 * XXX: potential race here. We should be adding the
> > +			 * file_lock to the global list before releasing lock.
> > +			 */
> > +			spin_lock(&file_lock_lock);
> >  			if (posix_locks_deadlock(request, fl))
> >  				goto out;
> > +			spin_unlock(&file_lock_lock);
> >  			error = FILE_LOCK_DEFERRED;
> >  			locks_insert_block(fl, request);
> >  			locks_insert_global_blocked(request);
> > @@ -1004,7 +1008,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  		locks_wake_up_blocks(left);
> >  	}
> >   out:
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	/*
> >  	 * Free any unused locks.
> >  	 */
> > @@ -1079,14 +1083,14 @@ int locks_mandatory_locked(struct inode *inode)
> >  	/*
> >  	 * Search the lock list for this inode for any POSIX locks.
> >  	 */
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
> >  		if (!IS_POSIX(fl))
> >  			continue;
> >  		if (fl->fl_owner != owner)
> >  			break;
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return fl ? -EAGAIN : 0;
> >  }
> >  
> > @@ -1229,7 +1233,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
> >  	if (IS_ERR(new_fl))
> >  		return PTR_ERR(new_fl);
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  
> >  	time_out_leases(inode);
> >  
> > @@ -1279,10 +1283,10 @@ restart:
> >  			break_time++;
> >  	}
> >  	locks_insert_block(flock, new_fl);
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	error = wait_event_interruptible_timeout(new_fl->fl_wait,
> >  						!new_fl->fl_next, break_time);
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	__locks_delete_block(new_fl);
> >  	if (error >= 0) {
> >  		if (error == 0)
> > @@ -1300,7 +1304,7 @@ restart:
> >  	}
> >  
> >  out:
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	locks_free_lock(new_fl);
> >  	return error;
> >  }
> > @@ -1353,9 +1357,10 @@ EXPORT_SYMBOL(lease_get_mtime);
> >  int fcntl_getlease(struct file *filp)
> >  {
> >  	struct file_lock *fl;
> > +	struct inode *inode = file_inode(filp);
> >  	int type = F_UNLCK;
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	time_out_leases(file_inode(filp));
> >  	for (fl = file_inode(filp)->i_flock; fl && IS_LEASE(fl);
> >  			fl = fl->fl_next) {
> > @@ -1364,7 +1369,7 @@ int fcntl_getlease(struct file *filp)
> >  			break;
> >  		}
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return type;
> >  }
> >  
> > @@ -1458,7 +1463,7 @@ static int generic_delete_lease(struct file *filp, struct file_lock **flp)
> >   *	The (input) flp->fl_lmops->lm_break function is required
> >   *	by break_lease().
> >   *
> > - *	Called with file_lock_lock held.
> > + *	Called with inode->i_lock held.
> >   */
> >  int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
> >  {
> > @@ -1527,11 +1532,12 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
> >  
> >  int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
> >  {
> > +	struct inode *inode = file_inode(filp);
> >  	int error;
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	error = __vfs_setlease(filp, arg, lease);
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  
> >  	return error;
> >  }
> > @@ -1549,6 +1555,7 @@ static int do_fcntl_delete_lease(struct file *filp)
> >  static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
> >  {
> >  	struct file_lock *fl, *ret;
> > +	struct inode *inode = file_inode(filp);
> >  	struct fasync_struct *new;
> >  	int error;
> >  
> > @@ -1562,10 +1569,10 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
> >  		return -ENOMEM;
> >  	}
> >  	ret = fl;
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	error = __vfs_setlease(filp, arg, &ret);
> >  	if (error) {
> > -		unlock_flocks();
> > +		spin_unlock(&inode->i_lock);
> >  		locks_free_lock(fl);
> >  		goto out_free_fasync;
> >  	}
> > @@ -1582,7 +1589,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
> >  		new = NULL;
> >  
> >  	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  
> >  out_free_fasync:
> >  	if (new)
> > @@ -2106,7 +2113,7 @@ void locks_remove_flock(struct file *filp)
> >  			fl.fl_ops->fl_release_private(&fl);
> >  	}
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	before = &inode->i_flock;
> >  
> >  	while ((fl = *before) != NULL) {
> > @@ -2124,7 +2131,7 @@ void locks_remove_flock(struct file *filp)
> >   		}
> >  		before = &fl->fl_next;
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  }
> >  
> >  /**
> > @@ -2137,14 +2144,15 @@ void locks_remove_flock(struct file *filp)
> >  int
> >  posix_unblock_lock(struct file *filp, struct file_lock *waiter)
> >  {
> > +	struct inode *inode = file_inode(filp);
> >  	int status = 0;
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	if (waiter->fl_next)
> >  		__locks_delete_block(waiter);
> >  	else
> >  		status = -ENOENT;
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return status;
> >  }
> >  
> > @@ -2261,7 +2269,7 @@ static void *locks_start(struct seq_file *f, loff_t *pos)
> >  {
> >  	loff_t *p = f->private;
> >  
> > -	lock_flocks();
> > +	spin_lock(&file_lock_lock);
> >  	*p = (*pos + 1);
> >  	return seq_list_start(&file_lock_list, *pos);
> >  }
> > @@ -2275,7 +2283,7 @@ static void *locks_next(struct seq_file *f, void *v, loff_t *pos)
> >  
> >  static void locks_stop(struct seq_file *f, void *v)
> >  {
> > -	unlock_flocks();
> > +	spin_unlock(&file_lock_lock);
> >  }
> >  
> >  static const struct seq_operations locks_seq_operations = {
> > @@ -2322,7 +2330,8 @@ int lock_may_read(struct inode *inode, loff_t start, unsigned long len)
> >  {
> >  	struct file_lock *fl;
> >  	int result = 1;
> > -	lock_flocks();
> > +
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
> >  		if (IS_POSIX(fl)) {
> >  			if (fl->fl_type == F_RDLCK)
> > @@ -2339,7 +2348,7 @@ int lock_may_read(struct inode *inode, loff_t start, unsigned long len)
> >  		result = 0;
> >  		break;
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return result;
> >  }
> >  
> > @@ -2362,7 +2371,8 @@ int lock_may_write(struct inode *inode, loff_t start, unsigned long len)
> >  {
> >  	struct file_lock *fl;
> >  	int result = 1;
> > -	lock_flocks();
> > +
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
> >  		if (IS_POSIX(fl)) {
> >  			if ((fl->fl_end < start) || (fl->fl_start > (start + len)))
> > @@ -2377,7 +2387,7 @@ int lock_may_write(struct inode *inode, loff_t start, unsigned long len)
> >  		result = 0;
> >  		break;
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return result;
> >  }
> >  
> > diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> > index 57db324..43ee7f9 100644
> > --- a/fs/nfs/delegation.c
> > +++ b/fs/nfs/delegation.c
> > @@ -73,20 +73,21 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
> >  	if (inode->i_flock == NULL)
> >  		goto out;
> >  
> > -	/* Protect inode->i_flock using the file locks lock */
> > -	lock_flocks();
> > +	/* Protect inode->i_flock using the i_lock */
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
> >  		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
> >  			continue;
> >  		if (nfs_file_open_context(fl->fl_file) != ctx)
> >  			continue;
> > -		unlock_flocks();
> > +		/* FIXME: safe to drop lock here while walking list? */
> > +		spin_unlock(&inode->i_lock);
> >  		status = nfs4_lock_delegation_recall(fl, state, stateid);
> >  		if (status < 0)
> >  			goto out;
> > -		lock_flocks();
> > +		spin_lock(&inode->i_lock);
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  out:
> >  	return status;
> >  }
> > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > index 1fab140..ff10b4a 100644
> > --- a/fs/nfs/nfs4state.c
> > +++ b/fs/nfs/nfs4state.c
> > @@ -1373,13 +1373,13 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
> >  	/* Guard against delegation returns and new lock/unlock calls */
> >  	down_write(&nfsi->rwsem);
> >  	/* Protect inode->i_flock using the BKL */
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
> >  		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
> >  			continue;
> >  		if (nfs_file_open_context(fl->fl_file)->state != state)
> >  			continue;
> > -		unlock_flocks();
> > +		spin_unlock(&inode->i_lock);
> >  		status = ops->recover_lock(state, fl);
> >  		switch (status) {
> >  			case 0:
> > @@ -1406,9 +1406,9 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
> >  				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
> >  				status = 0;
> >  		}
> > -		lock_flocks();
> > +		spin_lock(&inode->i_lock);
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  out:
> >  	up_write(&nfsi->rwsem);
> >  	return status;
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 316ec84..f170518 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -2645,13 +2645,13 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
> >  
> >  	list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
> >  
> > -	/* only place dl_time is set. protected by lock_flocks*/
> > +	/* Only place dl_time is set; protected by i_lock: */
> >  	dp->dl_time = get_seconds();
> >  
> >  	nfsd4_cb_recall(dp);
> >  }
> >  
> > -/* Called from break_lease() with lock_flocks() held. */
> > +/* Called from break_lease() with i_lock held. */
> >  static void nfsd_break_deleg_cb(struct file_lock *fl)
> >  {
> >  	struct nfs4_file *fp = (struct nfs4_file *)fl->fl_owner;
> > @@ -4520,7 +4520,7 @@ check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner)
> >  	struct inode *inode = filp->fi_inode;
> >  	int status = 0;
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	for (flpp = &inode->i_flock; *flpp != NULL; flpp = &(*flpp)->fl_next) {
> >  		if ((*flpp)->fl_owner == (fl_owner_t)lowner) {
> >  			status = 1;
> > @@ -4528,7 +4528,7 @@ check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner)
> >  		}
> >  	}
> >  out:
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return status;
> >  }
> >  
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 94105d2..e2f896d 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1024,8 +1024,6 @@ extern int vfs_setlease(struct file *, long, struct file_lock **);
> >  extern int lease_modify(struct file_lock **, int);
> >  extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
> >  extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
> > -extern void lock_flocks(void);
> > -extern void unlock_flocks(void);
> >  #else /* !CONFIG_FILE_LOCKING */
> >  static inline int fcntl_getlk(struct file *file, struct flock __user *user)
> >  {
> > @@ -1167,15 +1165,6 @@ static inline int lock_may_write(struct inode *inode, loff_t start,
> >  {
> >  	return 1;
> >  }
> > -
> > -static inline void lock_flocks(void)
> > -{
> > -}
> > -
> > -static inline void unlock_flocks(void)
> > -{
> > -}
> > -
> >  #endif /* !CONFIG_FILE_LOCKING */
> >  
> >  
> > -- 
> > 1.7.1
> > 


-- 
Jeff Layton <jlayton@redhat.com>

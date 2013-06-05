Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477Ab3FEAqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 20:46:46 -0400
Date: Tue, 4 Jun 2013 20:46:04 -0400
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
Subject: Re: [PATCH v1 06/11] locks: convert to i_lock to protect i_flock
 list
Message-ID: <20130604204604.4848f3d9@corrin.poochiereds.net>
In-Reply-To: <20130604212208.GC15594@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
	<1370056054-25449-7-git-send-email-jlayton@redhat.com>
	<20130604212208.GC15594@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 4 Jun 2013 17:22:08 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 31, 2013 at 11:07:29PM -0400, Jeff Layton wrote:
> > Having a global lock that protects all of this code is a clear
> > scalability problem. Instead of doing that, move most of the code to be
> > protected by the i_lock instead.
> > 
> > The exceptions are the global lists that file_lock->fl_link sits on.
> > Those still need a global lock of some sort, so wrap just those accesses
> > in the file_lock_lock().
> > 
> > Note that this requires a small change to the /proc/locks code. Instead
> > of walking the fl_block list to look for locks blocked on the current
> > lock, we must instead walk the global blocker list and skip any that
> > aren't blocked on the current lock. Otherwise, we'd need to take the
> > i_lock on each inode as we go and that would create a lock inversion
> > problem.
> 
> locks_insert lock sets fl_nspid after adding to the global list, so in
> theory I think that could leave /proc/locks seeing a garbage fl_nspid
> or fl_pid field.
> 

Well spotted. I think we can simply fix that by ensuring that we do the
insert onto the global list as the last thing in locks_insert_lock and
remove it from the global list first thing in locks_delete_lock. I'll
do that and test it out before I send the next iteration.

> I'm similarly worried about the deadlock detection code using the
> fl_next value before it's set but I'm not sure what the consequences
> are.
> 

This I'm less clear on. We already do the insert onto the global
blocked list after locks_insert_block. Am I missing something here?

> But I think both of those are fixable, and this looks OK otherwise?
> 
> Patch-sequencing nit: it'd be nice to have the big-but-boring
> lock_flocks->spin_lock(&i_lock) search-and-replace in a separate patch
> from the (briefer, but more subtle) deadlock and /proc/locks changes.
> Off the top of my head all I can think of is bulk-replace of
> lock_flocks() by lock_flocks(inode) (which ignores inode argument), then
> change definition of the lock_flocks(inode) in the patch which does the
> other stuff, then bulk replace of lock_flocks(inode) by
> spin_lock(&inode->i_lock), but maybe there's something simpler.
> 

Ok, maybe I can do some of these other changes before we switch to the
i_lock, and then do the big boring change after that. I'll see if I can
cook up a reasonable patch for that for the next iteration.

> --b.
> 
> 
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
> >  fs/locks.c                        |  121 ++++++++++++++++++++-----------------
> >  fs/nfs/delegation.c               |   11 ++--
> >  fs/nfs/nfs4state.c                |    8 +-
> >  fs/nfsd/nfs4state.c               |    8 +-
> >  include/linux/fs.h                |   11 ----
> >  13 files changed, 119 insertions(+), 107 deletions(-)
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
> > index 72e4efe..29952d5 100644
> > --- a/fs/cifs/cifsfs.c
> > +++ b/fs/cifs/cifsfs.c
> > @@ -768,7 +768,7 @@ static loff_t cifs_llseek(struct file *file, loff_t offset, int whence)
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
> > index caca466..055c06c 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -165,22 +165,9 @@ int lease_break_time = 45;
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
> > @@ -498,25 +485,33 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
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
> > @@ -533,9 +528,11 @@ static void __locks_delete_block(struct file_lock *waiter)
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
> > @@ -657,8 +654,9 @@ void
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
> > @@ -671,7 +669,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
> >  			fl->fl_pid = pid_vnr(cfl->fl_nspid);
> >  	} else
> >  		fl->fl_type = F_UNLCK;
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return;
> >  }
> >  EXPORT_SYMBOL(posix_test_lock);
> > @@ -719,14 +717,19 @@ static int posix_locks_deadlock(struct file_lock *caller_fl,
> >  				struct file_lock *block_fl)
> >  {
> >  	int i = 0;
> > +	int ret = 0;
> >  
> > +	spin_lock(&file_lock_lock);
> >  	while ((block_fl = what_owner_is_waiting_for(block_fl))) {
> >  		if (i++ > MAX_DEADLK_ITERATIONS)
> > -			return 0;
> > -		if (posix_same_owner(caller_fl, block_fl))
> > -			return 1;
> > +			break;
> > +		if (posix_same_owner(caller_fl, block_fl)) {
> > +			++ret;
> > +			break;
> > +		}
> >  	}
> > -	return 0;
> > +	spin_unlock(&file_lock_lock);
> > +	return ret;
> >  }
> >  
> >  /* Try to create a FLOCK lock on filp. We always insert new FLOCK locks
> > @@ -750,7 +753,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
> >  			return -ENOMEM;
> >  	}
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	if (request->fl_flags & FL_ACCESS)
> >  		goto find_conflict;
> >  
> > @@ -780,9 +783,9 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
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
> > @@ -809,7 +812,7 @@ find_conflict:
> >  	error = 0;
> >  
> >  out:
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	if (new_fl)
> >  		locks_free_lock(new_fl);
> >  	return error;
> > @@ -839,7 +842,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  		new_fl2 = locks_alloc_lock();
> >  	}
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	/*
> >  	 * New lock request. Walk all POSIX locks and look for conflicts. If
> >  	 * there are any, either return -EAGAIN or put the request on the
> > @@ -1012,7 +1015,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  		locks_wake_up_blocks(left);
> >  	}
> >   out:
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	/*
> >  	 * Free any unused locks.
> >  	 */
> > @@ -1087,14 +1090,14 @@ int locks_mandatory_locked(struct inode *inode)
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
> > @@ -1237,7 +1240,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
> >  	if (IS_ERR(new_fl))
> >  		return PTR_ERR(new_fl);
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  
> >  	time_out_leases(inode);
> >  
> > @@ -1287,10 +1290,10 @@ restart:
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
> > @@ -1308,7 +1311,7 @@ restart:
> >  	}
> >  
> >  out:
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	locks_free_lock(new_fl);
> >  	return error;
> >  }
> > @@ -1361,9 +1364,10 @@ EXPORT_SYMBOL(lease_get_mtime);
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
> > @@ -1372,7 +1376,7 @@ int fcntl_getlease(struct file *filp)
> >  			break;
> >  		}
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return type;
> >  }
> >  
> > @@ -1466,7 +1470,7 @@ static int generic_delete_lease(struct file *filp, struct file_lock **flp)
> >   *	The (input) flp->fl_lmops->lm_break function is required
> >   *	by break_lease().
> >   *
> > - *	Called with file_lock_lock held.
> > + *	Called with inode->i_lock held.
> >   */
> >  int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
> >  {
> > @@ -1535,11 +1539,12 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
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
> > @@ -1557,6 +1562,7 @@ static int do_fcntl_delete_lease(struct file *filp)
> >  static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
> >  {
> >  	struct file_lock *fl, *ret;
> > +	struct inode *inode = file_inode(filp);
> >  	struct fasync_struct *new;
> >  	int error;
> >  
> > @@ -1570,10 +1576,10 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
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
> > @@ -1590,7 +1596,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
> >  		new = NULL;
> >  
> >  	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  
> >  out_free_fasync:
> >  	if (new)
> > @@ -2114,7 +2120,7 @@ void locks_remove_flock(struct file *filp)
> >  			fl.fl_ops->fl_release_private(&fl);
> >  	}
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	before = &inode->i_flock;
> >  
> >  	while ((fl = *before) != NULL) {
> > @@ -2132,7 +2138,7 @@ void locks_remove_flock(struct file *filp)
> >   		}
> >  		before = &fl->fl_next;
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  }
> >  
> >  /**
> > @@ -2145,14 +2151,15 @@ void locks_remove_flock(struct file *filp)
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
> > @@ -2257,8 +2264,10 @@ static int locks_show(struct seq_file *f, void *v)
> >  
> >  	lock_get_status(f, fl, *((loff_t *)f->private), "");
> >  
> > -	list_for_each_entry(bfl, &fl->fl_block, fl_block)
> > -		lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
> > +	list_for_each_entry(bfl, &blocked_list, fl_link) {
> > +		if (bfl->fl_next == fl)
> > +			lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
> > +	}
> >  
> >  	return 0;
> >  }
> > @@ -2267,7 +2276,7 @@ static void *locks_start(struct seq_file *f, loff_t *pos)
> >  {
> >  	loff_t *p = f->private;
> >  
> > -	lock_flocks();
> > +	spin_lock(&file_lock_lock);
> >  	*p = (*pos + 1);
> >  	return seq_list_start(&file_lock_list, *pos);
> >  }
> > @@ -2281,7 +2290,7 @@ static void *locks_next(struct seq_file *f, void *v, loff_t *pos)
> >  
> >  static void locks_stop(struct seq_file *f, void *v)
> >  {
> > -	unlock_flocks();
> > +	spin_unlock(&file_lock_lock);
> >  }
> >  
> >  static const struct seq_operations locks_seq_operations = {
> > @@ -2328,7 +2337,8 @@ int lock_may_read(struct inode *inode, loff_t start, unsigned long len)
> >  {
> >  	struct file_lock *fl;
> >  	int result = 1;
> > -	lock_flocks();
> > +
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
> >  		if (IS_POSIX(fl)) {
> >  			if (fl->fl_type == F_RDLCK)
> > @@ -2345,7 +2355,7 @@ int lock_may_read(struct inode *inode, loff_t start, unsigned long len)
> >  		result = 0;
> >  		break;
> >  	}
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return result;
> >  }
> >  
> > @@ -2368,7 +2378,8 @@ int lock_may_write(struct inode *inode, loff_t start, unsigned long len)
> >  {
> >  	struct file_lock *fl;
> >  	int result = 1;
> > -	lock_flocks();
> > +
> > +	spin_lock(&inode->i_lock);
> >  	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
> >  		if (IS_POSIX(fl)) {
> >  			if ((fl->fl_end < start) || (fl->fl_start > (start + len)))
> > @@ -2383,7 +2394,7 @@ int lock_may_write(struct inode *inode, loff_t start, unsigned long len)
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
> > index ae377e9..ccb44ea 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1012,8 +1012,6 @@ extern int vfs_setlease(struct file *, long, struct file_lock **);
> >  extern int lease_modify(struct file_lock **, int);
> >  extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
> >  extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
> > -extern void lock_flocks(void);
> > -extern void unlock_flocks(void);
> >  #else /* !CONFIG_FILE_LOCKING */
> >  static inline int fcntl_getlk(struct file *file, struct flock __user *user)
> >  {
> > @@ -1155,15 +1153,6 @@ static inline int lock_may_write(struct inode *inode, loff_t start,
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

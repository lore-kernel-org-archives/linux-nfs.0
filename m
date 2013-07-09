Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879Ab3GIOlH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 10:41:07 -0400
Date: Tue, 9 Jul 2013 10:41:04 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 06/12] locks: implement delegations
Message-ID: <20130709144103.GB32574@pad.fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-7-git-send-email-bfields@redhat.com>
 <20130709082300.206bf176@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130709082300.206bf176@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 08:23:00AM -0400, Jeff Layton wrote:
> On Wed,  3 Jul 2013 16:12:30 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Implement NFSv4 delegations at the vfs level using the new FL_DELEG lock
> > type.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/locks.c         |   49 +++++++++++++++++++++++++++++++++++++++----------
> >  include/linux/fs.h |   18 +++++++++++++++---
> >  2 files changed, 54 insertions(+), 13 deletions(-)
> > 
> > diff --git a/fs/locks.c b/fs/locks.c
> > index deec4de..2b56954 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -1176,28 +1176,40 @@ static void time_out_leases(struct inode *inode)
> >  	}
> >  }
> >  
> > +static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
> > +{
> > +	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
> > +		return false;
> > +	return locks_conflict(breaker, lease);
> > +}
> > +
> >  /**
> >   *	__break_lease	-	revoke all outstanding leases on file
> >   *	@inode: the inode of the file to return
> > - *	@mode: the open mode (read or write)
> > + *	@mode: O_RDONLY: break only write leases; O_WRONLY or O_RDWR:
> > + *	    break all leases
> > + *	@type: FL_LEASE: break leases and delegations; FL_DELEG: break
> > + *	    only delegations
> >   *
> >   *	break_lease (inlined for speed) has checked there already is at least
> >   *	some kind of lock (maybe a lease) on this file.  Leases are broken on
> >   *	a call to open() or truncate().  This function can sleep unless you
> >   *	specified %O_NONBLOCK to your open().
> >   */
> > -int __break_lease(struct inode *inode, unsigned int mode)
> > +int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
> >  {
> >  	int error = 0;
> >  	struct file_lock *new_fl, *flock;
> >  	struct file_lock *fl;
> >  	unsigned long break_time;
> >  	int i_have_this_lease = 0;
> > +	bool lease_conflict = false;
> >  	int want_write = (mode & O_ACCMODE) != O_RDONLY;
> >  
> >  	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
> >  	if (IS_ERR(new_fl))
> >  		return PTR_ERR(new_fl);
> > +	new_fl->fl_flags = type;
> >  
> >  	lock_flocks();
> >  
> > @@ -1207,13 +1219,16 @@ int __break_lease(struct inode *inode, unsigned int mode)
> >  	if ((flock == NULL) || !IS_LEASE(flock))
> >  		goto out;
> >  
> > -	if (!locks_conflict(flock, new_fl))
> > +	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
> > +		if (leases_conflict(fl, new_fl)) {
> > +			lease_conflict = true;
> > +			if (fl->fl_owner == current->files)
> > +				i_have_this_lease = 1;
> > +		}
> > +	}
> > +	if (!lease_conflict)
> >  		goto out;
> >  
> > -	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next)
> > -		if (fl->fl_owner == current->files)
> > -			i_have_this_lease = 1;
> > -
> >  	break_time = 0;
> >  	if (lease_break_time > 0) {
> >  		break_time = jiffies + lease_break_time * HZ;
> > @@ -1222,6 +1237,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
> >  	}
> >  
> >  	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
> > +		if (!leases_conflict(fl, new_fl))
> > +			continue;
> >  		if (want_write) {
> >  			if (fl->fl_flags & FL_UNLOCK_PENDING)
> >  				continue;
> > @@ -1263,7 +1280,7 @@ restart:
> >  		 */
> >  		for (flock = inode->i_flock; flock && IS_LEASE(flock);
> >  				flock = flock->fl_next) {
> > -			if (locks_conflict(new_fl, flock))
> > +			if (leases_conflict(new_fl, flock))
> >  				goto restart;
> >  		}
> >  		error = 0;
> > @@ -1343,9 +1360,20 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
> >  	struct file_lock *fl, **before, **my_before = NULL, *lease;
> >  	struct dentry *dentry = filp->f_path.dentry;
> >  	struct inode *inode = dentry->d_inode;
> > +	bool is_deleg = (*flp)->fl_flags & FL_DELEG;
> >  	int error;
> >  
> >  	lease = *flp;
> > +	/*
> > +	 * In the delegation case we need mutual exclusion with
> > +	 * a number of operations that take the i_mutex.  We trylock
> > +	 * because delegations are an optional optimization, and if
> > +	 * there's some chance of a conflict--we'd rather not
> > +	 * bother, maybe that's a sign this just isn't a good file to
> > +	 * hand out a delegation on.
> > +	 */
> > +	if (is_deleg && !mutex_trylock(&inode->i_mutex))
> > +		return -EAGAIN;
> >  
> >  	error = -EAGAIN;
> >  	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
> > @@ -1397,9 +1425,10 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
> >  		goto out;
> >  
> >  	locks_insert_lock(before, lease);
> > -	return 0;
> > -
> > +	error = 0;
> >  out:
> > +	if (is_deleg)
> > +		mutex_unlock(&inode->i_mutex);
> >  	return error;
> >  }
> >  
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 116b3e9..c6cc686 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1006,7 +1006,7 @@ extern int vfs_test_lock(struct file *, struct file_lock *);
> >  extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
> >  extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
> >  extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
> > -extern int __break_lease(struct inode *inode, unsigned int flags);
> > +extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
> >  extern void lease_get_mtime(struct inode *, struct timespec *time);
> >  extern int generic_setlease(struct file *, long, struct file_lock **);
> >  extern int vfs_setlease(struct file *, long, struct file_lock **);
> > @@ -1119,7 +1119,7 @@ static inline int flock_lock_file_wait(struct file *filp,
> >  	return -ENOLCK;
> >  }
> >  
> > -static inline int __break_lease(struct inode *inode, unsigned int mode)
> > +static inline int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
> >  {
> >  	return 0;
> >  }
> > @@ -1951,9 +1951,17 @@ static inline int locks_verify_truncate(struct inode *inode,
> >  static inline int break_lease(struct inode *inode, unsigned int mode)
> >  {
> >  	if (inode->i_flock)
> > -		return __break_lease(inode, mode);
> > +		return __break_lease(inode, mode, FL_LEASE);
> >  	return 0;
> >  }
> > +
> > +static inline int break_deleg(struct inode *inode, unsigned int mode)
> > +{
> > +	if (inode->i_flock)
> > +		return __break_lease(inode, mode, FL_DELEG);
> > +	return 0;
> > +}
> > +
> >  #else /* !CONFIG_FILE_LOCKING */
> >  static inline int locks_mandatory_locked(struct inode *inode)
> >  {
> > @@ -1993,6 +2001,10 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
> >  	return 0;
> >  }
> >  
> > +static inline int break_deleg(struct inode *inode, unsigned int mode)
> > +{
> > +	return 0;
> > +}
> >  #endif /* CONFIG_FILE_LOCKING */
> >  
> >  /* fs/open.c */
> 
> Looks reasonable...
> 
> This (of course) has the same potential race that Al ID'ed a few days
> ago. We'll probably need to reconcile this patch with whatever fix we
> come up with there, but it shouldn't be too difficult.

Note there are currently no users for write delegations.  I'd like to do
study the case more carefully first.

We should probably make that clear: I'll add a WARN and error return for
an attempt to set a write delegation.

--b.

diff --git a/fs/locks.c b/fs/locks.c
index 2b56954..38f6baf 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1375,6 +1375,12 @@ int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 	if (is_deleg && !mutex_trylock(&inode->i_mutex))
 		return -EAGAIN;
 
+	if (is_deleg && arg == F_WRLCK) {
+		/* Write delegations not currently supported. */
+		WARN_ON_ONCE(1);
+		return -EINVAL;
+	}
+
 	error = -EAGAIN;
 	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
 		goto out;

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:40330 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468AbaHZKxp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 06:53:45 -0400
Received: by mail-yh0-f46.google.com with SMTP id a41so11608891yho.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 03:53:44 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 26 Aug 2014 06:53:42 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-fsdevel@vger.kernel.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/10] locks: plumb an "aux" pointer into the setlease
 routines
Message-ID: <20140826065342.1410e5a2@synchrony.poochiereds.net>
In-Reply-To: <20140825202852.GD21957@fieldses.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
	<1408804878-1331-7-git-send-email-jlayton@primarydata.com>
	<20140825202852.GD21957@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 25 Aug 2014 16:28:52 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Aug 23, 2014 at 10:41:14AM -0400, Jeff Layton wrote:
> > In later patches, we're going to add a new lock_manager_operation to
> > finish setting up the lease while still holding the i_lock.  To do
> > this, we'll need to pass a little bit of info in the fcntl setlease
> > case (primarily an fasync structure). Plumb the extra pointer into
> > there in advance of that.
> > 
> > We declare this pointer as a void ** to make it clear that this is
> > auxillary info, and that the caller isn't required to set this unless
> > the lm_setup specifically requires it.
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/cifs/cifsfs.c    |  7 ++++---
> >  fs/gfs2/file.c      |  3 ++-
> >  fs/locks.c          | 33 +++++++++++++++++++++------------
> >  fs/nfs/file.c       |  2 +-
> >  fs/nfs/internal.h   |  2 +-
> >  fs/nfsd/nfs4state.c |  4 ++--
> >  include/linux/fs.h  | 10 +++++-----
> >  7 files changed, 36 insertions(+), 25 deletions(-)
> > 
> > diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> > index 889b98455750..f463d86f097a 100644
> > --- a/fs/cifs/cifsfs.c
> > +++ b/fs/cifs/cifsfs.c
> > @@ -813,7 +813,8 @@ static loff_t cifs_llseek(struct file *file, loff_t offset, int whence)
> >  	return generic_file_llseek(file, offset, whence);
> >  }
> >  
> > -static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
> > +static int
> > +cifs_setlease(struct file *file, long arg, struct file_lock **lease, void **aux)
> >  {
> >  	/*
> >  	 * Note that this is called by vfs setlease with i_lock held to
> > @@ -829,7 +830,7 @@ static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
> >  	if (arg == F_UNLCK ||
> >  	    ((arg == F_RDLCK) && CIFS_CACHE_READ(CIFS_I(inode))) ||
> >  	    ((arg == F_WRLCK) && CIFS_CACHE_WRITE(CIFS_I(inode))))
> > -		return generic_setlease(file, arg, lease);
> > +		return generic_setlease(file, arg, lease, aux);
> >  	else if (tlink_tcon(cfile->tlink)->local_lease &&
> >  		 !CIFS_CACHE_READ(CIFS_I(inode)))
> >  		/*
> > @@ -840,7 +841,7 @@ static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
> >  		 * knows that the file won't be changed on the server by anyone
> >  		 * else.
> >  		 */
> > -		return generic_setlease(file, arg, lease);
> > +		return generic_setlease(file, arg, lease, aux);
> >  	else
> >  		return -EAGAIN;
> >  }
> > diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> > index 26b3f952e6b1..253feff90b4e 100644
> > --- a/fs/gfs2/file.c
> > +++ b/fs/gfs2/file.c
> > @@ -927,7 +927,8 @@ out_uninit:
> >   * Returns: errno
> >   */
> >  
> > -static int gfs2_setlease(struct file *file, long arg, struct file_lock **fl)
> > +static int gfs2_setlease(struct file *file, long arg, struct file_lock **fl,
> > +			 void **aux)
> >  {
> >  	return -EINVAL;
> >  }
> > diff --git a/fs/locks.c b/fs/locks.c
> > index 597e71a1e90f..906e09da115a 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -1297,7 +1297,6 @@ int lease_modify(struct file_lock **before, int arg)
> >  	}
> >  	return 0;
> >  }
> > -
> >  EXPORT_SYMBOL(lease_modify);
> >  
> >  static bool past_time(unsigned long then)
> > @@ -1543,7 +1542,8 @@ check_conflicting_open(const struct dentry *dentry, const long arg)
> >  	return ret;
> >  }
> >  
> > -static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
> > +static int
> > +generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **aux)
> >  {
> >  	struct file_lock *fl, **before, **my_before = NULL, *lease;
> >  	struct dentry *dentry = filp->f_path.dentry;
> > @@ -1607,6 +1607,7 @@ static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp
> >  	}
> >  
> >  	if (my_before != NULL) {
> > +		lease = *my_before;
> 
> What's this doing in this patch?
> 
> --b.
> 

Yeah, it probably doesn't belong here, but it should be harmless. Once
we've found an existing lease in the list we have no need for the one
passed in. I'll move this change into one of the later patches.

> >  		error = lease->fl_lmops->lm_change(my_before, arg);

The main reason for this sort of change is the above wart. It's calling
"lease's" method (which currently points at *flp) on "*my_before",
which is just plain wrong.

> >  		if (!error)
> >  			*flp = *my_before;
> > @@ -1630,11 +1631,14 @@ static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp
> >  	smp_mb();
> >  	error = check_conflicting_open(dentry, arg);
> >  	if (error)
> > -		locks_unlink_lock(before);
> > +		goto out_unlink;
> >  out:
> >  	if (is_deleg)
> >  		mutex_unlock(&inode->i_mutex);
> >  	return error;
> > +out_unlink:
> > +	locks_unlink_lock(before);
> > +	goto out;
> >  }
> >  
> >  static int generic_delete_lease(struct file *filp)
> > @@ -1658,13 +1662,15 @@ static int generic_delete_lease(struct file *filp)
> >   *	@filp: file pointer
> >   *	@arg: type of lease to obtain
> >   *	@flp: input - file_lock to use, output - file_lock inserted
> > + *	@aux: auxillary data for lm_setup
> >   *
> >   *	The (input) flp->fl_lmops->lm_break function is required
> >   *	by break_lease().
> >   *
> >   *	Called with inode->i_lock held.
> >   */
> > -int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
> > +int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
> > +			void **aux)
> >  {
> >  	struct dentry *dentry = filp->f_path.dentry;
> >  	struct inode *inode = dentry->d_inode;
> > @@ -1689,19 +1695,20 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
> >  			WARN_ON_ONCE(1);
> >  			return -ENOLCK;
> >  		}
> > -		return generic_add_lease(filp, arg, flp);
> > +		return generic_add_lease(filp, arg, flp, aux);
> >  	default:
> >  		return -EINVAL;
> >  	}
> >  }
> >  EXPORT_SYMBOL(generic_setlease);
> >  
> > -static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
> > +static int
> > +__vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **aux)
> >  {
> >  	if (filp->f_op->setlease)
> > -		return filp->f_op->setlease(filp, arg, lease);
> > +		return filp->f_op->setlease(filp, arg, lease, aux);
> >  	else
> > -		return generic_setlease(filp, arg, lease);
> > +		return generic_setlease(filp, arg, lease, aux);
> >  }
> >  
> >  /**
> > @@ -1709,6 +1716,7 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
> >   * @filp: file pointer
> >   * @arg: type of lease to obtain
> >   * @lease: file_lock to use when adding a lease
> > + * @aux: auxillary info for lm_setup when adding a lease
> >   *
> >   * Call this to establish a lease on the file. The "lease" argument is not
> >   * used for F_UNLCK requests and may be NULL. For commands that set or alter
> > @@ -1724,13 +1732,14 @@ static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
> >   * this for leases held by processes on this node.
> >   */
> >  
> > -int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
> > +int
> > +vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **aux)
> >  {
> >  	struct inode *inode = file_inode(filp);
> >  	int error;
> >  
> >  	spin_lock(&inode->i_lock);
> > -	error = __vfs_setlease(filp, arg, lease);
> > +	error = __vfs_setlease(filp, arg, lease, aux);
> >  	spin_unlock(&inode->i_lock);
> >  
> >  	return error;
> > @@ -1755,7 +1764,7 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
> >  	}
> >  	ret = fl;
> >  	spin_lock(&inode->i_lock);
> > -	error = __vfs_setlease(filp, arg, &ret);
> > +	error = __vfs_setlease(filp, arg, &ret, NULL);
> >  	if (error)
> >  		goto out_unlock;
> >  	if (ret == fl)
> > @@ -1793,7 +1802,7 @@ out_unlock:
> >  int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
> >  {
> >  	if (arg == F_UNLCK)
> > -		return vfs_setlease(filp, F_UNLCK, NULL);
> > +		return vfs_setlease(filp, F_UNLCK, NULL, NULL);
> >  	return do_fcntl_add_lease(fd, filp, arg);
> >  }
> >  
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 524dd80d1898..7221022232d9 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -895,7 +895,7 @@ EXPORT_SYMBOL_GPL(nfs_flock);
> >   * There is no protocol support for leases, so we have no way to implement
> >   * them correctly in the face of opens by other clients.
> >   */
> > -int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
> > +int nfs_setlease(struct file *file, long arg, struct file_lock **fl, void **aux)
> >  {
> >  	dprintk("NFS: setlease(%pD2, arg=%ld)\n", file, arg);
> >  	return -EINVAL;
> > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> > index 9056622d2230..dcdc83072c10 100644
> > --- a/fs/nfs/internal.h
> > +++ b/fs/nfs/internal.h
> > @@ -346,7 +346,7 @@ int nfs_file_release(struct inode *, struct file *);
> >  int nfs_lock(struct file *, int, struct file_lock *);
> >  int nfs_flock(struct file *, int, struct file_lock *);
> >  int nfs_check_flags(int);
> > -int nfs_setlease(struct file *, long, struct file_lock **);
> > +int nfs_setlease(struct file *, long, struct file_lock **, void **);
> >  
> >  /* inode.c */
> >  extern struct workqueue_struct *nfsiod_workqueue;
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index d0a6e8e022a2..d964a41c9151 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -683,7 +683,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
> >  	if (!fp->fi_deleg_file)
> >  		return;
> >  	if (atomic_dec_and_test(&fp->fi_delegees)) {
> > -		vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL);
> > +		vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL, NULL);
> >  		fput(fp->fi_deleg_file);
> >  		fp->fi_deleg_file = NULL;
> >  	}
> > @@ -3788,7 +3788,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
> >  	}
> >  	fl->fl_file = filp;
> >  	ret = fl;
> > -	status = vfs_setlease(filp, fl->fl_type, &ret);
> > +	status = vfs_setlease(filp, fl->fl_type, &fl, NULL);
> >  	if (status) {
> >  		locks_free_lock(fl);
> >  		goto out_fput;
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 458f733c96bd..2668d054147f 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -982,8 +982,8 @@ extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
> >  extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
> >  extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
> >  extern void lease_get_mtime(struct inode *, struct timespec *time);
> > -extern int generic_setlease(struct file *, long, struct file_lock **);
> > -extern int vfs_setlease(struct file *, long, struct file_lock **);
> > +extern int generic_setlease(struct file *, long, struct file_lock **, void **aux);
> > +extern int vfs_setlease(struct file *, long, struct file_lock **, void **aux);
> >  extern int lease_modify(struct file_lock **, int);
> >  #else /* !CONFIG_FILE_LOCKING */
> >  static inline int fcntl_getlk(struct file *file, unsigned int cmd,
> > @@ -1100,13 +1100,13 @@ static inline void lease_get_mtime(struct inode *inode, struct timespec *time)
> >  }
> >  
> >  static inline int generic_setlease(struct file *filp, long arg,
> > -				    struct file_lock **flp)
> > +				    struct file_lock **flp, void **aux)
> >  {
> >  	return -EINVAL;
> >  }
> >  
> >  static inline int vfs_setlease(struct file *filp, long arg,
> > -			       struct file_lock **lease)
> > +			       struct file_lock **lease, void **aux)
> >  {
> >  	return -EINVAL;
> >  }
> > @@ -1494,7 +1494,7 @@ struct file_operations {
> >  	int (*flock) (struct file *, int, struct file_lock *);
> >  	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
> >  	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
> > -	int (*setlease)(struct file *, long, struct file_lock **);
> > +	int (*setlease)(struct file *, long, struct file_lock **, void **);
> >  	long (*fallocate)(struct file *file, int mode, loff_t offset,
> >  			  loff_t len);
> >  	int (*show_fdinfo)(struct seq_file *m, struct file *f);
> > -- 
> > 1.9.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@primarydata.com>

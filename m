From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH 3/5] locks: rename lease functions to reflect locks.c
 conventions
Date: Sat, 9 Jun 2007 09:56:29 -0700
Message-ID: <OFACAF92E2.7AA61B28-ON882572F5.005CD6AC-882572F5.005CFA2E@us.ibm.com>
References: <11813408954053-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Robert Rappaport <robert.rappaport@gmail.com>,
	David Teigland <teigland@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11813408954053-git-send-email->
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

We need to export vfs_lease so nfsd can call it.
Marc. 

"J. Bruce Fields" <bfields@citi.umich.edu> wrote on 06/08/2007 03:14:53 
PM:

> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> We've been using the convention that vfs_foo is the function that calls
> a filesystem-specific foo method if it exists, or falls back on a
> generic method if it doesn't.
> 
> So rename setlease to vfs_setlease, and __setlease to setlease.  Keep
> setlease exported to allow filesystems to use the generic method in
> addition to doing their own bookkeeping.
> 
> Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> ---
>  fs/locks.c          |   16 ++++++++--------
>  fs/nfsd/nfs4state.c |   10 +++++-----
>  include/linux/fs.h  |    2 +-
>  3 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 8fa4420..82ac90b 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1329,7 +1329,7 @@ int fcntl_getlease(struct file *filp)
>  }
> 
>  /**
> - *   __setlease   -   sets a lease on an open file
> + *   setlease   -   sets a lease on an open file
>   *   @filp: file pointer
>   *   @arg: type of lease to obtain
>   *   @flp: input - file_lock to use, output - file_lock inserted
> @@ -1339,7 +1339,7 @@ int fcntl_getlease(struct file *filp)
>   *
>   *   Called with kernel lock held.
>   */
> -static int __setlease(struct file *filp, long arg, struct file_lock 
**flp)
> +static int setlease(struct file *filp, long arg, struct file_lock 
**flp)
>  {
>     struct file_lock *fl, **before, **my_before = NULL, *lease;
>     struct dentry *dentry = filp->f_path.dentry;
> @@ -1427,8 +1427,10 @@ out:
>     return error;
>  }
> 
> +EXPORT_SYMBOL(setlease);
> +
>   /**
> - *   setlease        -       sets a lease on an open file
> + *   vfs_setlease        -       sets a lease on an open file
>   *   @filp: file pointer
>   *   @arg: type of lease to obtain
>   *   @lease: file_lock to use
> @@ -1437,7 +1439,7 @@ out:
>   *   The fl_lmops fl_break function is required by break_lease
>   */
> 
> -int setlease(struct file *filp, long arg, struct file_lock **lease)
> +int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
>  {
>     int error;
> 
> @@ -1445,14 +1447,12 @@ int setlease(struct file *filp, long arg, 
> struct file_lock **lease)
>     if (filp->f_op && filp->f_op->setlease)
>        error = filp->f_op->setlease(filp, arg, lease);
>          else
> -      error = __setlease(filp, arg, lease);
> +      error = setlease(filp, arg, lease);
>     unlock_kernel();
> 
>     return error;
>  }
> 
> -EXPORT_SYMBOL(setlease);
> -
>  /**
>   *   fcntl_setlease   -   sets a lease on an open file
>   *   @fd: open file descriptor
> @@ -1477,7 +1477,7 @@ int fcntl_setlease(unsigned int fd, struct 
> file *filp, long arg)
> 
>     lock_kernel();
> 
> -   error = setlease(filp, arg, &flp);
> +   error = vfs_setlease(filp, arg, &flp);
>     if (error || arg == F_UNLCK)
>        goto out_unlock;
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3cc8ce4..ed01a77 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -251,7 +251,7 @@ nfs4_close_delegation(struct nfs4_delegation *dp)
>     /* The following nfsd_close may not actually close the file,
>      * but we want to remove the lease in any case. */
>     if (dp->dl_flock)
> -      setlease(filp, F_UNLCK, &dp->dl_flock);
> +      vfs_setlease(filp, F_UNLCK, &dp->dl_flock);
>     nfsd_close(filp);
>  }
> 
> @@ -1396,7 +1396,7 @@ void nfsd_release_deleg_cb(struct file_lock *fl)
>  /*
>   * Set the delegation file_lock back pointer.
>   *
> - * Called from __setlease() with lock_kernel() held.
> + * Called from setlease() with lock_kernel() held.
>   */
>  static
>  void nfsd_copy_lock_deleg_cb(struct file_lock *new, struct file_lock 
*fl)
> @@ -1410,7 +1410,7 @@ void nfsd_copy_lock_deleg_cb(struct file_lock 
> *new, struct file_lock *fl)
>  }
> 
>  /*
> - * Called from __setlease() with lock_kernel() held
> + * Called from setlease() with lock_kernel() held
>   */
>  static
>  int nfsd_same_client_deleg_cb(struct file_lock *onlist, struct 
> file_lock *try)
> @@ -1710,10 +1710,10 @@ nfs4_open_delegation(struct svc_fh *fh, 
> struct nfsd4_open *open, struct nfs4_sta
>     fl.fl_file = stp->st_vfs_file;
>     fl.fl_pid = current->tgid;
> 
> -   /* setlease checks to see if delegation should be handed out.
> +   /* vfs_setlease checks to see if delegation should be handed out.
>      * the lock_manager callbacks fl_mylease and fl_change are used
>      */
> -   if ((status = setlease(stp->st_vfs_file,
> +   if ((status = vfs_setlease(stp->st_vfs_file,
>        flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK, &flp))) {
>        dprintk("NFSD: setlease failed [%d], no delegation\n", status);
>        unhash_delegation(dp);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 6b07c61..cc62bfb 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -865,7 +865,7 @@ extern int vfs_cancel_lock(struct file *filp, 
> struct file_lock *fl);
>  extern int flock_lock_file_wait(struct file *filp, struct file_lock 
*fl);
>  extern int __break_lease(struct inode *inode, unsigned int flags);
>  extern void lease_get_mtime(struct inode *, struct timespec *time);
> -extern int setlease(struct file *, long, struct file_lock **);
> +extern int vfs_setlease(struct file *, long, struct file_lock **);
>  extern int lease_modify(struct file_lock **, int);
>  extern int lock_may_read(struct inode *, loff_t start, unsigned long 
count);
>  extern int lock_may_write(struct inode *, loff_t start, unsigned long 
count);
> -- 
> 1.5.2
> 


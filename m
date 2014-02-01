Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932395AbaBANUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 1 Feb 2014 08:20:31 -0500
Date: Sat, 1 Feb 2014 08:20:20 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v7 1/7] VFS: Introduce new O_DENY* open flags
Message-ID: <20140201082020.117bf3b3@tlielax.poochiereds.net>
In-Reply-To: <1389953232-9428-2-git-send-email-piastry@etersoft.ru>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
	<1389953232-9428-2-git-send-email-piastry@etersoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Jan 2014 14:07:06 +0400
Pavel Shilovsky <piastry@etersoft.ru> wrote:

> This patch adds 3 flags:
> 1) O_DENYREAD that doesn't permit read access,
> 2) O_DENYWRITE that doesn't permit write access,
> 3) O_DENYDELETE that doesn't permit delete or rename.
> 
> Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags -
> this change can benefit cifs and nfs modules as well as Samba and
> NFS file servers that export the same directory for Windows clients,
> or Wine applications that access the same files simultaneously.
> 
> These flags are only take affect for opens on mounts with new sharelock
> option. They are translated to flock's flags:
> 
> !O_DENYREAD  -> LOCK_READ  | LOCK_MAND
> !O_DENYWRITE -> LOCK_WRITE | LOCK_MAND
> 
> and set through flock_lock_file on a file. If the file can't be locked
> due conflicts with another open with O_DENY* flags, a new -ESHAREDENIED
> error code is returned.
> 
> Create codepath is slightly changed to prevent data races on newly
> created files: when open with O_CREAT can return -ESHAREDENIED error
> for successfully created files due to a sharelock set by another task.
> 
> Temporary disable O_DENYDELETE support - will enable it in further
> patches.
> 
> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
> ---
>  arch/alpha/include/uapi/asm/errno.h  |    2 +
>  arch/alpha/include/uapi/asm/fcntl.h  |    3 ++
>  arch/mips/include/uapi/asm/errno.h   |    2 +
>  arch/parisc/include/uapi/asm/errno.h |    2 +
>  arch/parisc/include/uapi/asm/fcntl.h |    3 ++
>  arch/sparc/include/uapi/asm/errno.h  |    2 +
>  arch/sparc/include/uapi/asm/fcntl.h  |    3 ++
>  fs/fcntl.c                           |    5 +-
>  fs/locks.c                           |   97 +++++++++++++++++++++++++++++++---
>  fs/namei.c                           |   53 ++++++++++++++++++-
>  fs/proc_namespace.c                  |    1 +
>  include/linux/fs.h                   |    8 +++
>  include/uapi/asm-generic/errno.h     |    2 +
>  include/uapi/asm-generic/fcntl.h     |   11 ++++
>  include/uapi/linux/fs.h              |    1 +
>  15 files changed, 185 insertions(+), 10 deletions(-)
> 

You might consider breaking this patch into two. One patch that makes
LOCK_MAND locks actually work and that adds MS_SHARELOCK, and one patch
that hooks that up to open(). Given the locking involved with the
i_mutex it would be best to present this as a series of small,
incremental changes.

> diff --git a/arch/alpha/include/uapi/asm/errno.h b/arch/alpha/include/uapi/asm/errno.h
> index 17f92aa..953a6d6 100644
> --- a/arch/alpha/include/uapi/asm/errno.h
> +++ b/arch/alpha/include/uapi/asm/errno.h
> @@ -124,4 +124,6 @@
>  
>  #define EHWPOISON	139	/* Memory page has hardware error */
>  
> +#define ESHAREDENIED	140	/* File is locked with a sharelock */
> +
>  #endif
> diff --git a/arch/alpha/include/uapi/asm/fcntl.h b/arch/alpha/include/uapi/asm/fcntl.h
> index 09f49a6..265344b 100644
> --- a/arch/alpha/include/uapi/asm/fcntl.h
> +++ b/arch/alpha/include/uapi/asm/fcntl.h
> @@ -33,6 +33,9 @@
>  
>  #define O_PATH		040000000
>  #define __O_TMPFILE	0100000000
> +#define O_DENYREAD	0200000000	/* Do not permit read access */
> +#define O_DENYWRITE	0400000000	/* Do not permit write access */
> +#define O_DENYDELETE	01000000000	/* Do not permit delete or rename */
>  
>  #define F_GETLK		7
>  #define F_SETLK		8
> diff --git a/arch/mips/include/uapi/asm/errno.h b/arch/mips/include/uapi/asm/errno.h
> index 02d645d..f1a4068 100644
> --- a/arch/mips/include/uapi/asm/errno.h
> +++ b/arch/mips/include/uapi/asm/errno.h
> @@ -123,6 +123,8 @@
>  
>  #define EHWPOISON	168	/* Memory page has hardware error */
>  
> +#define ESHAREDENIED	169	/* File is locked with a sharelock */
> +
>  #define EDQUOT		1133	/* Quota exceeded */
>  
>  
> diff --git a/arch/parisc/include/uapi/asm/errno.h b/arch/parisc/include/uapi/asm/errno.h
> index f3a8aa5..654c232 100644
> --- a/arch/parisc/include/uapi/asm/errno.h
> +++ b/arch/parisc/include/uapi/asm/errno.h
> @@ -124,4 +124,6 @@
>  
>  #define EHWPOISON	257	/* Memory page has hardware error */
>  
> +#define ESHAREDENIED	258	/* File is locked with a sharelock */
> +
>  #endif
> diff --git a/arch/parisc/include/uapi/asm/fcntl.h b/arch/parisc/include/uapi/asm/fcntl.h
> index 34a46cb..5865964 100644
> --- a/arch/parisc/include/uapi/asm/fcntl.h
> +++ b/arch/parisc/include/uapi/asm/fcntl.h
> @@ -21,6 +21,9 @@
>  
>  #define O_PATH		020000000
>  #define __O_TMPFILE	040000000
> +#define O_DENYREAD	0200000000	/* Do not permit read access */
> +#define O_DENYWRITE	0400000000	/* Do not permit write access */
> +#define O_DENYDELETE	01000000000	/* Do not permit delete or rename */
>  
>  #define F_GETLK64	8
>  #define F_SETLK64	9
> diff --git a/arch/sparc/include/uapi/asm/errno.h b/arch/sparc/include/uapi/asm/errno.h
> index 20423e17..fe339b5 100644
> --- a/arch/sparc/include/uapi/asm/errno.h
> +++ b/arch/sparc/include/uapi/asm/errno.h
> @@ -114,4 +114,6 @@
>  
>  #define EHWPOISON	135	/* Memory page has hardware error */
>  
> +#define ESHAREDENIED	136	/* File is locked with a sharelock */
> +
>  #endif
> diff --git a/arch/sparc/include/uapi/asm/fcntl.h b/arch/sparc/include/uapi/asm/fcntl.h
> index 7e8ace5..ab68170 100644
> --- a/arch/sparc/include/uapi/asm/fcntl.h
> +++ b/arch/sparc/include/uapi/asm/fcntl.h
> @@ -36,6 +36,9 @@
>  
>  #define O_PATH		0x1000000
>  #define __O_TMPFILE	0x2000000
> +#define O_DENYREAD	0x4000000	/* Do not permit read access */
> +#define O_DENYWRITE	0x8000000	/* Do not permit write access */
> +#define O_DENYDELETE	0x10000000	/* Do not permit delete or rename */
>  

It'd probably be best to add O_DENYDELETE in a separate patch, rather
than disabling it temporarily.

>  #define F_GETOWN	5	/*  for sockets. */
>  #define F_SETOWN	6	/*  for sockets. */
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index ef68665..3f85887 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -729,14 +729,15 @@ static int __init fcntl_init(void)
>  	 * Exceptions: O_NONBLOCK is a two bit define on parisc; O_NDELAY
>  	 * is defined as O_NONBLOCK on some platforms and not on others.
>  	 */
> -	BUILD_BUG_ON(20 - 1 /* for O_RDONLY being 0 */ != HWEIGHT32(
> +	BUILD_BUG_ON(23 - 1 /* for O_RDONLY being 0 */ != HWEIGHT32(
>  		O_RDONLY	| O_WRONLY	| O_RDWR	|
>  		O_CREAT		| O_EXCL	| O_NOCTTY	|
>  		O_TRUNC		| O_APPEND	| /* O_NONBLOCK	| */
>  		__O_SYNC	| O_DSYNC	| FASYNC	|
>  		O_DIRECT	| O_LARGEFILE	| O_DIRECTORY	|
>  		O_NOFOLLOW	| O_NOATIME	| O_CLOEXEC	|
> -		__FMODE_EXEC	| O_PATH	| __O_TMPFILE
> +		__FMODE_EXEC	| O_PATH	| __O_TMPFILE	|
> +		O_DENYREAD	| O_DENYWRITE	| O_DENYDELETE
>  		));
>  
>  	fasync_cache = kmem_cache_create("fasync_cache",
> diff --git a/fs/locks.c b/fs/locks.c
> index 92a0f0a..ffde4d4 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -708,20 +708,73 @@ static int posix_locks_conflict(struct file_lock *caller_fl, struct file_lock *s
>  	return (locks_conflict(caller_fl, sys_fl));
>  }
>  
> -/* Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
> - * checking before calling the locks_conflict().
> +static unsigned int
> +deny_flags_to_cmd(unsigned int flags)
> +{
> +	unsigned int cmd = LOCK_MAND;
> +
> +	if (!(flags & O_DENYREAD))
> +		cmd |= LOCK_READ;
> +	if (!(flags & O_DENYWRITE))
> +		cmd |= LOCK_WRITE;
> +
> +	return cmd;
> +}
> +
> +/*
> + * locks_mand_conflict - Determine if there's a share reservation conflict
> + * @caller_fl: lock we're attempting to acquire
> + * @sys_fl: lock already present on system that we're checking against
> + *
> + * Check to see if there's a share_reservation conflict. LOCK_READ/LOCK_WRITE
> + * tell us whether the reservation allows other readers and writers.
> + */
> +static int
> +locks_mand_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
> +{
> +	unsigned char caller_type = caller_fl->fl_type;
> +	unsigned char sys_type = sys_fl->fl_type;
> +	fmode_t caller_fmode = caller_fl->fl_file->f_mode;
> +	fmode_t sys_fmode = sys_fl->fl_file->f_mode;
> +
> +	/* they can only conflict if FS is mounted with MS_SHARELOCK */
> +	if (!IS_SHARELOCK(caller_fl->fl_file->f_path.dentry->d_inode))
> +		return 0;
> +
> +	/* they can only conflict if they're both LOCK_MAND */
> +	if (!(caller_type & LOCK_MAND) || !(sys_type & LOCK_MAND))
> +		return 0;
> +
> +	if (!(caller_type & LOCK_READ) && (sys_fmode & FMODE_READ))
> +		return 1;
> +	if (!(caller_type & LOCK_WRITE) && (sys_fmode & FMODE_WRITE))
> +		return 1;
> +	if (!(sys_type & LOCK_READ) && (caller_fmode & FMODE_READ))
> +		return 1;
> +	if (!(sys_type & LOCK_WRITE) && (caller_fmode & FMODE_WRITE))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +/*
> + * Determine if lock sys_fl blocks lock caller_fl. FLOCK specific checking
> + * before calling the locks_conflict().
>   */
>  static int flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
>  {
> -	/* FLOCK locks referring to the same filp do not conflict with
> +	if (!IS_FLOCK(sys_fl))
> +		return 0;
> +	if ((caller_fl->fl_type & LOCK_MAND) || (sys_fl->fl_type & LOCK_MAND))
> +		return locks_mand_conflict(caller_fl, sys_fl);

nit: Seems like the above could be optimized a little. You know that
locks_mand_conflict is only relevant if both are LOCK_MAND, and one of
the first things that locks_mand_conflict does is to check that both
have that set.

> +	/*
> +	 * FLOCK locks referring to the same filp do not conflict with
>  	 * each other.
>  	 */
> -	if (!IS_FLOCK(sys_fl) || (caller_fl->fl_file == sys_fl->fl_file))
> -		return (0);
> -	if ((caller_fl->fl_type & LOCK_MAND) || (sys_fl->fl_type & LOCK_MAND))
> +	if (caller_fl->fl_file == sys_fl->fl_file)
>  		return 0;
>  
> -	return (locks_conflict(caller_fl, sys_fl));
> +	return locks_conflict(caller_fl, sys_fl);
>  }
>  
>  void
> @@ -888,6 +941,36 @@ out:
>  	return error;
>  }
>  
> +/*
> + * Determine if a file is allowed to be opened with specified access and share
> + * modes. Lock the file and return 0 if checks passed, otherwise return
> + * -ESHAREDENIED.
> + */
> +int
> +sharelock_lock_file(struct file *filp)
> +{
> +	struct file_lock *lock;
> +	int error = 0;
> +
> +	if (!IS_SHARELOCK(filp->f_path.dentry->d_inode))
> +		return error;
> +
> +	/* Disable O_DENYDELETE support for now */
> +	if (filp->f_flags & O_DENYDELETE)
> +		return -EINVAL;
> +
> +	error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
> +	if (error)
> +		return error;
> +
> +	error = flock_lock_file(filp, lock);
> +	if (error == -EAGAIN)
> +		error = -ESHAREDENIED;
> +
> +	locks_free_lock(lock);
> +	return error;
> +}
> +
>  static int __posix_lock_file(struct inode *inode, struct file_lock *request, struct file_lock *conflock)
>  {
>  	struct file_lock *fl;
> diff --git a/fs/namei.c b/fs/namei.c
> index 3531dee..2b741a1 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -2725,9 +2725,14 @@ static int atomic_open(struct nameidata *nd, struct dentry *dentry,
>  		acc_mode = MAY_OPEN;
>  	}
>  	error = may_open(&file->f_path, acc_mode, open_flag);
> -	if (error)
> +	if (error) {
>  		fput(file);
> +		goto out;
> +	}
>  
> +	error = sharelock_lock_file(file);
> +	if (error)
> +		fput(file);
>  out:
>  	dput(dentry);
>  	return error;
> @@ -2919,6 +2924,40 @@ retry_lookup:
>  	}
>  	mutex_lock(&dir->d_inode->i_mutex);
>  	error = lookup_open(nd, path, file, op, got_write, opened);
> +
> +	/*
> +	 * For sharelock mounts if a file was created but not opened, we need
> +	 * to keep parent i_mutex until we finish the open to prevent races when
> +	 * somebody opens newly created by us file and locks it with a sharelock
> +	 * before we open it.
> +	 */
> +	if (IS_SHARELOCK(dir->d_inode) && error > 0 && *opened & FILE_CREATED) {
> +		/* Don't check for write permission, don't truncate */
> +		open_flag &= ~O_TRUNC;
> +		will_truncate = false;
> +		acc_mode = MAY_OPEN;
> +		path_to_nameidata(path, nd);
> +
> +		error = may_open(&nd->path, acc_mode, open_flag);
> +		if (error) {
> +			mutex_unlock(&dir->d_inode->i_mutex);
> +			goto out;
> +		}
> +		file->f_path.mnt = nd->path.mnt;
> +		error = finish_open(file, nd->path.dentry, NULL, opened);
> +		if (error) {
> +			mutex_unlock(&dir->d_inode->i_mutex);
> +			if (error == -EOPENSTALE)
> +				goto stale_open;
> +			goto out;
> +		}
> +		error = sharelock_lock_file(file);
> +		mutex_unlock(&dir->d_inode->i_mutex);
> +		if (error)
> +			goto exit_fput;
> +		goto opened;
> +	}
> +
>  	mutex_unlock(&dir->d_inode->i_mutex);
>  
>  	if (error <= 0) {
> @@ -3034,6 +3073,18 @@ finish_open_created:
>  			goto stale_open;
>  		goto out;
>  	}
> +
> +	if (IS_SHARELOCK(dir->d_inode)) {
> +		/*
> +		 * Lock parent i_mutex to prevent races with sharelocks on
> +		 * newly created files.
> +		 */
> +		mutex_lock(&dir->d_inode->i_mutex);
> +		error = sharelock_lock_file(file);
> +		mutex_unlock(&dir->d_inode->i_mutex);
> +		if (error)
> +			goto exit_fput;
> +	}
>  opened:
>  	error = open_check_o_direct(file);
>  	if (error)
> diff --git a/fs/proc_namespace.c b/fs/proc_namespace.c
> index 439406e..dd374d4 100644
> --- a/fs/proc_namespace.c
> +++ b/fs/proc_namespace.c
> @@ -44,6 +44,7 @@ static int show_sb_opts(struct seq_file *m, struct super_block *sb)
>  		{ MS_SYNCHRONOUS, ",sync" },
>  		{ MS_DIRSYNC, ",dirsync" },
>  		{ MS_MANDLOCK, ",mand" },
> +		{ MS_SHARELOCK, ",sharelock" },
>  		{ 0, NULL }
>  	};
>  	const struct proc_fs_info *fs_infop;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 121f11f..aa061ca 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1029,6 +1029,7 @@ extern int vfs_setlease(struct file *, long, struct file_lock **);
>  extern int lease_modify(struct file_lock **, int);
>  extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
>  extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
> +extern int sharelock_lock_file(struct file *);
>  #else /* !CONFIG_FILE_LOCKING */
>  static inline int fcntl_getlk(struct file *file, struct flock __user *user)
>  {
> @@ -1169,6 +1170,12 @@ static inline int lock_may_write(struct inode *inode, loff_t start,
>  {
>  	return 1;
>  }
> +
> +static inline int sharelock_lock_file(struct file *filp)
> +{
> +	return 0;
> +}
> +
>  #endif /* !CONFIG_FILE_LOCKING */
>  
>  
> @@ -1675,6 +1682,7 @@ struct super_operations {
>  #define IS_PRIVATE(inode)	((inode)->i_flags & S_PRIVATE)
>  #define IS_IMA(inode)		((inode)->i_flags & S_IMA)
>  #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
> +#define IS_SHARELOCK(inode)	__IS_FLG(inode, MS_SHARELOCK)
>  #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
>  
>  /*
> diff --git a/include/uapi/asm-generic/errno.h b/include/uapi/asm-generic/errno.h
> index 1e1ea6e..aff869c 100644
> --- a/include/uapi/asm-generic/errno.h
> +++ b/include/uapi/asm-generic/errno.h
> @@ -110,4 +110,6 @@
>  
>  #define EHWPOISON	133	/* Memory page has hardware error */
>  
> +#define ESHAREDENIED	134	/* File is locked with a sharelock */
> +
>  #endif
> diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
> index 95e46c8..9881cfe 100644
> --- a/include/uapi/asm-generic/fcntl.h
> +++ b/include/uapi/asm-generic/fcntl.h
> @@ -92,6 +92,17 @@
>  #define O_TMPFILE (__O_TMPFILE | O_DIRECTORY)
>  #define O_TMPFILE_MASK (__O_TMPFILE | O_DIRECTORY | O_CREAT)      
>  
> +#ifndef O_DENYREAD
> +#define O_DENYREAD	040000000	/* Do not permit read access */
> +#endif
> +/* FMODE_NONOTIFY	0100000000 */
> +#ifndef O_DENYWRITE
> +#define O_DENYWRITE	0200000000	/* Do not permit write access */
> +#endif
> +#ifndef O_DENYDELETE
> +#define O_DENYDELETE	0400000000	/* Do not permit delete or rename */
> +#endif
> +

One thing to consider: We found with the addition of O_TMPFILE that the
open() api is not particularly helpful when it comes to informing
appications when a flag isn't supported:

    http://lwn.net/Articles/562294/

...having a plan to cope with that here would be best. How can an
application determine at runtime that O_DENY* actually *work*? It may
be best to step back and consider a new syscall for this (open2() ?).

>  #ifndef O_NDELAY
>  #define O_NDELAY	O_NONBLOCK
>  #endif
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index 6c28b61..11f0ecf 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -86,6 +86,7 @@ struct inodes_stat_t {
>  #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
>  #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
>  #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
> +#define MS_SHARELOCK	(1<<25) /* Allow share locks on an FS */
>  
>  /* These sb flags are internal to the kernel */
>  #define MS_NOSEC	(1<<28)


-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58382 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755877Ab3A3WQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2013 17:16:04 -0500
Date: Wed, 30 Jan 2013 17:16:02 -0500
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v2 3/8] vfs: Add O_DENYREAD/WRITE flags support for open
 syscall
Message-ID: <20130130221602.GC15584@fieldses.org>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
 <1358441584-8783-3-git-send-email-piastry@etersoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1358441584-8783-3-git-send-email-piastry@etersoft.ru>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 17, 2013 at 08:52:59PM +0400, Pavel Shilovsky wrote:
> If O_DENYMAND flag is specified, O_DENYREAD/WRITE/MAND flags are
> translated to flock's flags:
> 
> !O_DENYREAD  -> LOCK_READ
> !O_DENYWRITE -> LOCK_WRITE
> O_DENYMAND   -> LOCK_MAND
> 
> and set through flock_lock_file on a file.
> 
> This change only affects opens that use O_DENYMAND flag - all other
> native Linux opens don't care about these flags. It allow us to
> enable this feature for applications that need it (e.g. NFS and
> Samba servers that export the same directory for Windows clients,
> or Wine applications that access the same files simultaneously).

The use of an is_conflict callback seems unnecessarily convoluted.

If we need two different behaviors, let's just use another flag (or an
extra boolean argument if we need to, or something).

The only caller for this new deny_lock_file is in the nfs code--I'm a
little unclear why that is.

--b.

> 
> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
> ---
>  fs/locks.c         | 106 +++++++++++++++++++++++++++++++++++++++++++++++++++--
>  fs/namei.c         |  10 ++++-
>  include/linux/fs.h |   6 +++
>  3 files changed, 118 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 9edfec4..ebe9a30 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -605,12 +605,86 @@ static int posix_locks_conflict(struct file_lock *caller_fl, struct file_lock *s
>  	return (locks_conflict(caller_fl, sys_fl));
>  }
>  
> -/* Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
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
> + *
> + * We only check against other LOCK_MAND locks, so applications that want to
> + * use share mode locking will only conflict against one another. "normal"
> + * applications that open files won't be affected by and won't themselves
> + * affect the share reservations.
> + */
> +static int
> +locks_mand_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
> +{
> +	unsigned char caller_type = caller_fl->fl_type;
> +	unsigned char sys_type = sys_fl->fl_type;
> +	fmode_t caller_fmode = caller_fl->fl_file->f_mode;
> +	fmode_t sys_fmode = sys_fl->fl_file->f_mode;
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
> + * Determine if lock sys_fl blocks lock caller_fl. O_DENY* flags specific
> + * checking before calling the locks_conflict().
> + */
> +static int
> +deny_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
> +{
> +	/*
> +	 * FLOCK locks referring to the same filp do not conflict with
> +	 * each other.
> +	 */
> +	if (!IS_FLOCK(sys_fl))
> +		return 0;
> +	if ((caller_fl->fl_type & LOCK_MAND) || (sys_fl->fl_type & LOCK_MAND))
> +		return locks_mand_conflict(caller_fl, sys_fl);
> +	if (caller_fl->fl_file == sys_fl->fl_file)
> +		return 0;
> +
> +	return locks_conflict(caller_fl, sys_fl);
> +}
> +
> +/*
> + * Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
>   * checking before calling the locks_conflict().
>   */
> -static int flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
> +static int
> +flock_locks_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
>  {
> -	/* FLOCK locks referring to the same filp do not conflict with
> +	/*
> +	 * FLOCK locks referring to the same filp do not conflict with
>  	 * each other.
>  	 */
>  	if (!IS_FLOCK(sys_fl) || (caller_fl->fl_file == sys_fl->fl_file))
> @@ -789,6 +863,32 @@ out:
>  	return error;
>  }
>  
> +/*
> + * Determine if a file is allowed to be opened with specified access and deny
> + * modes. Lock the file and return 0 if checks passed, otherwise return a error
> + * code.
> + */
> +int
> +deny_lock_file(struct file *filp)
> +{
> +	struct file_lock *lock;
> +	int error = 0;
> +
> +	if (!(filp->f_flags & O_DENYMAND))
> +		return error;
> +
> +	error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
> +	if (error)
> +		return error;
> +
> +	error = flock_lock_file(filp, lock, deny_locks_conflict);
> +	if (error == -EAGAIN)
> +		error = -ETXTBSY;
> +
> +	locks_free_lock(lock);
> +	return error;
> +}
> +
>  static int __posix_lock_file(struct inode *inode, struct file_lock *request, struct file_lock *conflock)
>  {
>  	struct file_lock *fl;
> diff --git a/fs/namei.c b/fs/namei.c
> index 5f4cdf3..bf3bb34 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -2569,9 +2569,14 @@ static int atomic_open(struct nameidata *nd, struct dentry *dentry,
>  	 * here.
>  	 */
>  	error = may_open(&file->f_path, acc_mode, open_flag);
> -	if (error)
> +	if (error) {
>  		fput(file);
> +		goto out;
> +	}
>  
> +	error = deny_lock_file(file);
> +	if (error)
> +		fput(file);
>  out:
>  	dput(dentry);
>  	return error;
> @@ -2908,6 +2913,9 @@ opened:
>  		if (error)
>  			goto exit_fput;
>  	}
> +	error = deny_lock_file(file);
> +	if (error)
> +		goto exit_fput;
>  out:
>  	if (got_write)
>  		mnt_drop_write(nd->path.mnt);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 70a766ae..b8ed06e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1004,6 +1004,7 @@ extern int lease_modify(struct file_lock **, int);
>  extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
>  extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
>  extern void locks_delete_block(struct file_lock *waiter);
> +extern int deny_lock_file(struct file *);
>  extern void lock_flocks(void);
>  extern void unlock_flocks(void);
>  #else /* !CONFIG_FILE_LOCKING */
> @@ -1152,6 +1153,11 @@ static inline void locks_delete_block(struct file_lock *waiter)
>  {
>  }
>  
> +static inline int deny_lock_file(struct file *filp)
> +{
> +	return 0;
> +}
> +
>  static inline void lock_flocks(void)
>  {
>  }
> -- 
> 1.8.1.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

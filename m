Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35110 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752822AbdE0J4t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 05:56:49 -0400
Received: by mail-qt0-f195.google.com with SMTP id r58so4091984qtb.2
        for <linux-nfs@vger.kernel.org>; Sat, 27 May 2017 02:56:49 -0700 (PDT)
Message-ID: <1495879004.2881.1.camel@poochiereds.net>
Subject: Re: [PATCH 1/3] fs/locks: Alloc file_lock where practical
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, bfields@fieldses.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 27 May 2017 05:56:44 -0400
In-Reply-To: <1588d987ebffd963a71b0ac23d73d11b34142d15.1495829587.git.bcodding@redhat.com>
References: <cover.1495829587.git.bcodding@redhat.com>
         <1588d987ebffd963a71b0ac23d73d11b34142d15.1495829587.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-26 at 16:14 -0400, Benjamin Coddington wrote:
> Use an allocation it where makes sense to do so.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/locks.c | 83 ++++++++++++++++++++++++++++++++++----------------------------
>  1 file changed, 46 insertions(+), 37 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index af2031a1fcff..54aeacf8dc46 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1293,36 +1293,39 @@ int locks_mandatory_locked(struct file *file)
>  int locks_mandatory_area(struct inode *inode, struct file *filp, loff_t start,
>  			 loff_t end, unsigned char type)
>  {
> -	struct file_lock fl;
> +	struct file_lock *fl;
>  	int error;
>  	bool sleep = false;
>  
> -	locks_init_lock(&fl);
> -	fl.fl_pid = current->tgid;
> -	fl.fl_file = filp;
> -	fl.fl_flags = FL_POSIX | FL_ACCESS;
> +	fl = locks_alloc_lock();
> +	if (fl == NULL)
> +		return -ENOMEM;
> +

I'm fine with allocating these for GETLK, but locks_mandatory_area will
end up getting called on read/write operations if mandatory locking is
in effect.

OTOH, we have been (slowly!) moving away from supporting mandatory
locks, so maybe it's OK to do an extra alloc/free in that case. Meh,
ok...

> +	fl->fl_pid = current->tgid;
> +	fl->fl_file = filp;
> +	fl->fl_flags = FL_POSIX | FL_ACCESS;
>  	if (filp && !(filp->f_flags & O_NONBLOCK))
>  		sleep = true;
> -	fl.fl_type = type;
> -	fl.fl_start = start;
> -	fl.fl_end = end;
> +	fl->fl_type = type;
> +	fl->fl_start = start;
> +	fl->fl_end = end;
>  
>  	for (;;) {
>  		if (filp) {
> -			fl.fl_owner = filp;
> -			fl.fl_flags &= ~FL_SLEEP;
> -			error = posix_lock_inode(inode, &fl, NULL);
> +			fl->fl_owner = filp;
> +			fl->fl_flags &= ~FL_SLEEP;
> +			error = posix_lock_inode(inode, fl, NULL);
>  			if (!error)
>  				break;
>  		}
>  
>  		if (sleep)
> -			fl.fl_flags |= FL_SLEEP;
> -		fl.fl_owner = current->files;
> -		error = posix_lock_inode(inode, &fl, NULL);
> +			fl->fl_flags |= FL_SLEEP;
> +		fl->fl_owner = current->files;
> +		error = posix_lock_inode(inode, fl, NULL);
>  		if (error != FILE_LOCK_DEFERRED)
>  			break;
> -		error = wait_event_interruptible(fl.fl_wait, !fl.fl_next);
> +		error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
>  		if (!error) {
>  			/*
>  			 * If we've been sleeping someone might have
> @@ -1332,10 +1335,10 @@ int locks_mandatory_area(struct inode *inode, struct file *filp, loff_t start,
>  				continue;
>  		}
>  
> -		locks_delete_block(&fl);
> +		locks_delete_block(fl);
>  		break;
>  	}
> -
> +	locks_free_lock(fl);
>  	return error;
>  }
>  
> @@ -2088,10 +2091,13 @@ static void posix_lock_to_flock64(struct flock64 *flock, struct file_lock *fl)
>   */
>  int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock __user *l)
>  {
> -	struct file_lock file_lock;
> +	struct file_lock *fl;
>  	struct flock flock;
>  	int error;
>  
> +	fl = locks_alloc_lock();
> +	if (fl == NULL)
> +		return -ENOMEM;
>  	error = -EFAULT;
>  	if (copy_from_user(&flock, l, sizeof(flock)))
>  		goto out;
> @@ -2099,7 +2105,7 @@ int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock __user *l)
>  	if ((flock.l_type != F_RDLCK) && (flock.l_type != F_WRLCK))
>  		goto out;
>  
> -	error = flock_to_posix_lock(filp, &file_lock, &flock);
> +	error = flock_to_posix_lock(filp, fl, &flock);
>  	if (error)
>  		goto out;
>  
> @@ -2109,26 +2115,25 @@ int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock __user *l)
>  			goto out;
>  
>  		cmd = F_GETLK;
> -		file_lock.fl_flags |= FL_OFDLCK;
> -		file_lock.fl_owner = filp;
> +		fl->fl_flags |= FL_OFDLCK;
> +		fl->fl_owner = filp;
>  	}
>  
> -	error = vfs_test_lock(filp, &file_lock);
> +	error = vfs_test_lock(filp, fl);
>  	if (error)
>  		goto out;
>   
> -	flock.l_type = file_lock.fl_type;
> -	if (file_lock.fl_type != F_UNLCK) {
> -		error = posix_lock_to_flock(&flock, &file_lock);
> +	flock.l_type = fl->fl_type;
> +	if (fl->fl_type != F_UNLCK) {
> +		error = posix_lock_to_flock(&flock, fl);
>  		if (error)
> -			goto rel_priv;
> +			goto out;
>  	}
>  	error = -EFAULT;
>  	if (!copy_to_user(l, &flock, sizeof(flock)))
>  		error = 0;
> -rel_priv:
> -	locks_release_private(&file_lock);
>  out:
> +	locks_free_lock(fl);
>  	return error;
>  }
>  
> @@ -2317,10 +2322,14 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
>   */
>  int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l)
>  {
> -	struct file_lock file_lock;
> +	struct file_lock *fl;
>  	struct flock64 flock;
>  	int error;
>  
> +	fl = locks_alloc_lock();
> +	if (fl == NULL)
> +		return -ENOMEM;
> +
>  	error = -EFAULT;
>  	if (copy_from_user(&flock, l, sizeof(flock)))
>  		goto out;
> @@ -2328,7 +2337,7 @@ int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l)
>  	if ((flock.l_type != F_RDLCK) && (flock.l_type != F_WRLCK))
>  		goto out;
>  
> -	error = flock64_to_posix_lock(filp, &file_lock, &flock);
> +	error = flock64_to_posix_lock(filp, fl, &flock);
>  	if (error)
>  		goto out;
>  
> @@ -2338,24 +2347,24 @@ int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l)
>  			goto out;
>  
>  		cmd = F_GETLK64;
> -		file_lock.fl_flags |= FL_OFDLCK;
> -		file_lock.fl_owner = filp;
> +		fl->fl_flags |= FL_OFDLCK;
> +		fl->fl_owner = filp;
>  	}
>  
> -	error = vfs_test_lock(filp, &file_lock);
> +	error = vfs_test_lock(filp, fl);
>  	if (error)
>  		goto out;
>  
> -	flock.l_type = file_lock.fl_type;
> -	if (file_lock.fl_type != F_UNLCK)
> -		posix_lock_to_flock64(&flock, &file_lock);
> +	flock.l_type = fl->fl_type;
> +	if (fl->fl_type != F_UNLCK)
> +		posix_lock_to_flock64(&flock, fl);
>  
>  	error = -EFAULT;
>  	if (!copy_to_user(l, &flock, sizeof(flock)))
>  		error = 0;
>  
> -	locks_release_private(&file_lock);
>  out:
> +	locks_free_lock(fl);
>  	return error;
>  }
>  

-- 
Jeff Layton <jlayton@poochiereds.net>

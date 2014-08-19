Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:44128 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbaHSUIl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 16:08:41 -0400
Received: by mail-qc0-f173.google.com with SMTP id w7so6802943qcr.32
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 13:08:39 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 19 Aug 2014 16:08:36 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 4/6 v4] locks: Copy fl_lmops information for conflock
 in, locks_copy_conflock()
Message-ID: <20140819160836.1196c8cb@tlielax.poochiereds.net>
In-Reply-To: <53F36C27.7050006@gmail.com>
References: <53BAAAC5.9000106@gmail.com>
	<53E22EA5.70708@gmail.com>
	<20140809065112.700e0ecc@tlielax.poochiereds.net>
	<53E791F1.40802@gmail.com>
	<53ED5093.6000308@gmail.com>
	<53F36C27.7050006@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 Aug 2014 23:24:23 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> Commit d5b9026a67 ([PATCH] knfsd: locks: flag NFSv4-owned locks) using
> fl_lmops field in file_lock for checking nfsd4 lockowner.
> 
> But, commit 1a747ee0cc (locks: don't call ->copy_lock methods on return
> of conflicting locks) causes the fl_lmops of conflock always be NULL.
> 
> Also, commit 0996905f93 (lockd: posix_test_lock() should not call
> locks_copy_lock()) caused the fl_lmops of conflock always be NULL too.
> 
> Make sure copy the private information by fl_copy_lock() in struct
> file_lock_operations, merge __locks_copy_lock() to fl_copy_lock().
> 
> Jeff advice, "Set fl_lmops on conflocks, but don't set fl_ops.
> fl_ops are superfluous, since they are callbacks into the filesystem.
> There should be no need to bother the filesystem at all with info
> in a conflock. But, lock _ownership_ matters for conflocks and that's
> indicated by the fl_lmops. So you really do want to copy the fl_lmops
> for conflocks I think."
> 
> v4: only copy fl_lmops for conflock, don't copy fl_ops
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/locks.c | 36 ++++++++++++++++--------------------
>  1 file changed, 16 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index c376561..0ee775d 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -271,21 +271,6 @@ void locks_init_lock(struct file_lock *fl)
>  
>  EXPORT_SYMBOL(locks_init_lock);
>  
> -static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
> -{
> -	if (fl->fl_ops) {
> -		if (fl->fl_ops->fl_copy_lock)
> -			fl->fl_ops->fl_copy_lock(new, fl);
> -		new->fl_ops = fl->fl_ops;
> -	}
> -
> -	if (fl->fl_lmops) {
> -		if (fl->fl_lmops->lm_get_owner)
> -			fl->fl_lmops->lm_get_owner(new, fl);
> -		new->fl_lmops = fl->fl_lmops;
> -	}
> -}
> -
>  /*
>   * Initialize a new lock from an existing file_lock structure.
>   */
> @@ -298,8 +283,13 @@ void locks_copy_conflock(struct file_lock *new, struct file_lock *fl)
>  	new->fl_type = fl->fl_type;
>  	new->fl_start = fl->fl_start;
>  	new->fl_end = fl->fl_end;
> +	new->fl_lmops = fl->fl_lmops;
>  	new->fl_ops = NULL;
> -	new->fl_lmops = NULL;
> +
> +	if (fl->fl_lmops) {
> +		if (fl->fl_lmops->lm_get_owner)
> +			fl->fl_lmops->lm_get_owner(new, fl);
> +	}
>  }
>  EXPORT_SYMBOL(locks_copy_conflock);
>  
> @@ -309,11 +299,14 @@ void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>  	WARN_ON_ONCE(new->fl_ops);
>  
>  	locks_copy_conflock(new, fl);
> +
>  	new->fl_file = fl->fl_file;
>  	new->fl_ops = fl->fl_ops;
> -	new->fl_lmops = fl->fl_lmops;
>  
> -	locks_copy_private(new, fl);
> +	if (fl->fl_ops) {
> +		if (fl->fl_ops->fl_copy_lock)
> +			fl->fl_ops->fl_copy_lock(new, fl);
> +	}
>  }
>  
>  EXPORT_SYMBOL(locks_copy_lock);
> @@ -1989,11 +1982,13 @@ int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock __user *l)
>  	if (file_lock.fl_type != F_UNLCK) {
>  		error = posix_lock_to_flock(&flock, &file_lock);
>  		if (error)
> -			goto out;
> +			goto rel_priv;
>  	}
>  	error = -EFAULT;
>  	if (!copy_to_user(l, &flock, sizeof(flock)))
>  		error = 0;
> +rel_priv:
> +	locks_release_private(&file_lock);
>  out:
>  	return error;
>  }
> @@ -2214,7 +2209,8 @@ int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l)
>  	error = -EFAULT;
>  	if (!copy_to_user(l, &flock, sizeof(flock)))
>  		error = 0;
> -  
> +
> +	locks_release_private(&file_lock);
>  out:
>  	return error;
>  }

Looks good for the most part. I think there is one small piece missing
though.

There is a vfs_test_lock call in nlmsvc_testlock. The conflock in that
case is embedded inside a nlm_lock and locks_release_private is not
called on it (AFAICT). You're not planning to set these new lmops for
lockd, but someone could in the future.

I think it would be good to go ahead and plumb in a call to
locks_release_private there as well to help ensure that no one will
break this in the future. It'll be a no-op for the time being of course.

-- 
Jeff Layton <jlayton@primarydata.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:62345 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbaHSTqY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 15:46:24 -0400
Received: by mail-qc0-f178.google.com with SMTP id x3so6762399qcv.37
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 12:46:23 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 19 Aug 2014 15:46:20 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/6 v4] locks: Rename __locks_copy_lock() to
 locks_copy_conflock()
Message-ID: <20140819154620.5a8720e5@tlielax.poochiereds.net>
In-Reply-To: <53F36B6F.8000601@gmail.com>
References: <53BAAAC5.9000106@gmail.com>
	<53E22EA5.70708@gmail.com>
	<20140809065112.700e0ecc@tlielax.poochiereds.net>
	<53E791F1.40802@gmail.com>
	<53ED5093.6000308@gmail.com>
	<53F36B6F.8000601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 Aug 2014 23:21:19 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> Jeff advice, " Right now __locks_copy_lock is only used to copy 
> conflocks. It would be good to rename that to something more 
> distinct (i.e.locks_copy_conflock), to make it clear that we're
> generating a conflock there."
> 
> v4: a new patch only rename
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/locks.c         | 10 +++++-----
>  include/linux/fs.h |  4 ++--
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 08342e0..c376561 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -289,7 +289,7 @@ static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
>  /*
>   * Initialize a new lock from an existing file_lock structure.
>   */
> -void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
> +void locks_copy_conflock(struct file_lock *new, struct file_lock *fl)
>  {
>  	new->fl_owner = fl->fl_owner;
>  	new->fl_pid = fl->fl_pid;
> @@ -301,14 +301,14 @@ void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
>  	new->fl_ops = NULL;
>  	new->fl_lmops = NULL;
>  }
> -EXPORT_SYMBOL(__locks_copy_lock);
> +EXPORT_SYMBOL(locks_copy_conflock);
>  
>  void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>  {
>  	/* "new" must be a freshly-initialized lock */
>  	WARN_ON_ONCE(new->fl_ops);
>  
> -	__locks_copy_lock(new, fl);
> +	locks_copy_conflock(new, fl);
>  	new->fl_file = fl->fl_file;
>  	new->fl_ops = fl->fl_ops;
>  	new->fl_lmops = fl->fl_lmops;
> @@ -743,7 +743,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
>  			break;
>  	}
>  	if (cfl) {
> -		__locks_copy_lock(fl, cfl);
> +		locks_copy_conflock(fl, cfl);
>  		if (cfl->fl_nspid)
>  			fl->fl_pid = pid_vnr(cfl->fl_nspid);
>  	} else
> @@ -949,7 +949,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>  			if (!posix_locks_conflict(request, fl))
>  				continue;
>  			if (conflock)
> -				__locks_copy_lock(conflock, fl);
> +				locks_copy_conflock(conflock, fl);
>  			error = -EAGAIN;
>  			if (!(request->fl_flags & FL_SLEEP))
>  				goto out;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 6829340..3b07ce2 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -968,7 +968,7 @@ void locks_free_lock(struct file_lock *fl);
>  extern void locks_init_lock(struct file_lock *);
>  extern struct file_lock * locks_alloc_lock(void);
>  extern void locks_copy_lock(struct file_lock *, struct file_lock *);
> -extern void __locks_copy_lock(struct file_lock *, const struct file_lock *);
> +extern void locks_copy_conflock(struct file_lock *, struct file_lock *);
>  extern void locks_remove_posix(struct file *, fl_owner_t);
>  extern void locks_remove_file(struct file *);
>  extern void locks_release_private(struct file_lock *);
> @@ -1028,7 +1028,7 @@ static inline void locks_init_lock(struct file_lock *fl)
>  	return;
>  }
>  
> -static inline void __locks_copy_lock(struct file_lock *new, struct file_lock *fl)
> +static inline void locks_copy_conflock(struct file_lock *new, struct file_lock *fl)
>  {
>  	return;
>  }

Reviewed-by: Jeff Layton <jlayton@primarydata.com>

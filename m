Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33046 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaHOLOw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 07:14:52 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so2065957qgf.21
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 04:14:52 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 15 Aug 2014 07:14:50 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/5 v3] locks: Copy all infomation for conflock
Message-ID: <20140815071450.498949d8@tlielax.poochiereds.net>
In-Reply-To: <53ED4F30.4060308@gmail.com>
References: <53BAAAC5.9000106@gmail.com>
	<53E22EA5.70708@gmail.com>
	<20140809065112.700e0ecc@tlielax.poochiereds.net>
	<53E791F1.40802@gmail.com>
	<53ED4F30.4060308@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 15 Aug 2014 08:07:12 +0800
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
> v3: Update based on Joe and Jeff's patch.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/locks.c         | 24 +++++++-----------------
>  include/linux/fs.h |  6 ------
>  2 files changed, 7 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index cb66fb0..fe52abb 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -281,33 +281,23 @@ static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
>  /*
>   * Initialize a new lock from an existing file_lock structure.
>   */
> -void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
> +void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>  {
> +	/* "new" must be a freshly-initialized lock */
> +	WARN_ON_ONCE(new->fl_ops);
> +
>  	new->fl_owner = fl->fl_owner;
>  	new->fl_pid = fl->fl_pid;
> -	new->fl_file = NULL;
> +	new->fl_file = fl->fl_file;
>  	new->fl_flags = fl->fl_flags;
>  	new->fl_type = fl->fl_type;
>  	new->fl_start = fl->fl_start;
>  	new->fl_end = fl->fl_end;
>  	new->fl_ops = NULL;
>  	new->fl_lmops = NULL;
> -}
> -EXPORT_SYMBOL(__locks_copy_lock);
> -
> -void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
> -{
> -	/* "new" must be a freshly-initialized lock */
> -	WARN_ON_ONCE(new->fl_ops);
> -
> -	__locks_copy_lock(new, fl);
> -	new->fl_file = fl->fl_file;
> -	new->fl_ops = fl->fl_ops;
> -	new->fl_lmops = fl->fl_lmops;
>  
>  	locks_copy_private(new, fl);
>  }
> -
>  EXPORT_SYMBOL(locks_copy_lock);
>  
>  static inline int flock_translate_cmd(int cmd) {
> @@ -735,7 +725,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
>  			break;
>  	}
>  	if (cfl) {
> -		__locks_copy_lock(fl, cfl);
> +		locks_copy_lock(fl, cfl);
>  		if (cfl->fl_nspid)
>  			fl->fl_pid = pid_vnr(cfl->fl_nspid);
>  	} else
> @@ -941,7 +931,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>  			if (!posix_locks_conflict(request, fl))
>  				continue;
>  			if (conflock)
> -				__locks_copy_lock(conflock, fl);
> +				locks_copy_lock(conflock, fl);
>  			error = -EAGAIN;
>  			if (!(request->fl_flags & FL_SLEEP))
>  				goto out;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 908af4f..a383a30 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -966,7 +966,6 @@ void locks_free_lock(struct file_lock *fl);
>  extern void locks_init_lock(struct file_lock *);
>  extern struct file_lock * locks_alloc_lock(void);
>  extern void locks_copy_lock(struct file_lock *, struct file_lock *);
> -extern void __locks_copy_lock(struct file_lock *, const struct file_lock *);
>  extern void locks_remove_posix(struct file *, fl_owner_t);
>  extern void locks_remove_file(struct file *);
>  extern void locks_release_private(struct file_lock *);
> @@ -1026,11 +1025,6 @@ static inline void locks_init_lock(struct file_lock *fl)
>  	return;
>  }
>  
> -static inline void __locks_copy_lock(struct file_lock *new, struct file_lock *fl)
> -{
> -	return;
> -}
> -
>  static inline void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>  {
>  	return;

I'm not sure this is really what you want to do. Calling fl_copy_lock
for a conflock looks relatively harmless for nfs and nlm. AFS though
seems to add the lock to a list associated with the inode. That seems a
little suspicious for a conflock and could be problematic. It may be
best to avoid dealing with fl_ops for a conflock.

Also in the case of fcntl_getlk, the struct file_lock lives on the
stack, and locks_release_private is never called on it. You'll need to
audit all of the current callers of __locks_copy_lock to ensure that
any resources you end up taking references on when copying the conflock
are eventually released.

-- 
Jeff Layton <jlayton@primarydata.com>

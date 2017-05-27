Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33178 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755134AbdE0KBC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 06:01:02 -0400
Received: by mail-qt0-f195.google.com with SMTP id a46so4110535qte.0
        for <linux-nfs@vger.kernel.org>; Sat, 27 May 2017 03:01:02 -0700 (PDT)
Message-ID: <1495879259.2881.4.camel@poochiereds.net>
Subject: Re: [PATCH 2/3] fs/locks: Set fl_nspid at file_lock allocation
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, bfields@fieldses.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 27 May 2017 06:00:59 -0400
In-Reply-To: <b4a55cb32bc843bae76fc10cf7ff9378a2a29822.1495829587.git.bcodding@redhat.com>
References: <cover.1495829587.git.bcodding@redhat.com>
         <b4a55cb32bc843bae76fc10cf7ff9378a2a29822.1495829587.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-26 at 16:14 -0400, Benjamin Coddington wrote:
> Since commit c69899a17ca4 "NFSv4: Update of VFS byte range lock must be
> atomic with the stateid update", NFSv4 has been inserting locks in rpciod
> worker context.  The result is that the file_lock's fl_nspid is the
> kworker's pid instead of the original userspace pid.  We can fix that up by
> setting fl_nspid in locks_allocate_lock, and tranfer it to the file_lock
> that's eventually recorded.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/locks.c | 29 ++++++++++++++++++++---------
>  1 file changed, 20 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 54aeacf8dc46..270ae50247db 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -249,7 +249,9 @@ locks_dump_ctx_list(struct list_head *list, char *list_type)
>  	struct file_lock *fl;
>  
>  	list_for_each_entry(fl, list, fl_list) {
> -		pr_warn("%s: fl_owner=%p fl_flags=0x%x fl_type=0x%x fl_pid=%u\n", list_type, fl->fl_owner, fl->fl_flags, fl->fl_type, fl->fl_pid);
> +		pr_warn("%s: fl_owner=%p fl_flags=0x%x fl_type=0x%x fl_pid=%u fl_nspid=%u\n",
> +			list_type, fl->fl_owner, fl->fl_flags, fl->fl_type,
> +			fl->fl_pid, pid_vnr(fl->fl_nspid));
>  	}
>  }
>  
> @@ -294,8 +296,10 @@ struct file_lock *locks_alloc_lock(void)
>  {
>  	struct file_lock *fl = kmem_cache_zalloc(filelock_cache, GFP_KERNEL);
>  
> -	if (fl)
> +	if (fl) {
>  		locks_init_lock_heads(fl);
> +		fl->fl_nspid = get_pid(task_tgid(current));
> +	}
>  
>  	return fl;
>  }
> @@ -328,6 +332,8 @@ void locks_free_lock(struct file_lock *fl)
>  	BUG_ON(!hlist_unhashed(&fl->fl_link));
>  
>  	locks_release_private(fl);
> +	if (fl->fl_nspid)
> +		put_pid(fl->fl_nspid);
>  	kmem_cache_free(filelock_cache, fl);
>  }
>  EXPORT_SYMBOL(locks_free_lock);
> @@ -357,8 +363,15 @@ EXPORT_SYMBOL(locks_init_lock);
>   */
>  void locks_copy_conflock(struct file_lock *new, struct file_lock *fl)
>  {
> +	struct pid *replace_pid = new->fl_nspid;
> +
>  	new->fl_owner = fl->fl_owner;
>  	new->fl_pid = fl->fl_pid;
> +	if (fl->fl_nspid) {
> +		new->fl_nspid = get_pid(fl->fl_nspid);
> +		if (replace_pid)
> +			put_pid(replace_pid);
> +	}
>  	new->fl_file = NULL;
>  	new->fl_flags = fl->fl_flags;
>  	new->fl_type = fl->fl_type;
> @@ -733,7 +746,6 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
>  static void
>  locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
>  {
> -	fl->fl_nspid = get_pid(task_tgid(current));
>  	list_add_tail(&fl->fl_list, before);
>  	locks_insert_global_locks(fl);
>  }
> @@ -743,10 +755,6 @@ locks_unlink_lock_ctx(struct file_lock *fl)
>  {
>  	locks_delete_global_locks(fl);
>  	list_del_init(&fl->fl_list);
> -	if (fl->fl_nspid) {
> -		put_pid(fl->fl_nspid);
> -		fl->fl_nspid = NULL;
> -	}
>  	locks_wake_up_blocks(fl);
>  }
>  
> @@ -823,8 +831,6 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
>  	list_for_each_entry(cfl, &ctx->flc_posix, fl_list) {
>  		if (posix_locks_conflict(fl, cfl)) {
>  			locks_copy_conflock(fl, cfl);
> -			if (cfl->fl_nspid)
> -				fl->fl_pid = pid_vnr(cfl->fl_nspid);
>  			goto out;
>  		}
>  	}
> @@ -2492,6 +2498,7 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
>  	lock.fl_end = OFFSET_MAX;
>  	lock.fl_owner = owner;
>  	lock.fl_pid = current->tgid;
> +	lock.fl_nspid = get_pid(task_tgid(current));
>  	lock.fl_file = filp;
>  	lock.fl_ops = NULL;
>  	lock.fl_lmops = NULL;
> @@ -2500,6 +2507,7 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
>  
>  	if (lock.fl_ops && lock.fl_ops->fl_release_private)
>  		lock.fl_ops->fl_release_private(&lock);
> +	put_pid(lock.fl_nspid);
>  	trace_locks_remove_posix(inode, &lock, error);
>  }
>  
> @@ -2522,6 +2530,8 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
>  	if (list_empty(&flctx->flc_flock))
>  		return;
>  
> +	fl.fl_nspid = get_pid(task_tgid(current));
> +
>  	if (filp->f_op->flock && is_remote_lock(filp))
>  		filp->f_op->flock(filp, F_SETLKW, &fl);
>  	else
> @@ -2529,6 +2539,7 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
>  
>  	if (fl.fl_ops && fl.fl_ops->fl_release_private)
>  		fl.fl_ops->fl_release_private(&fl);
> +	put_pid(fl.fl_nspid);

Maybe we should make a new helper function that does fl_release_private
and put_pid? That can be done in a later cleanup patch though. This
looks fine in the meantime.

>  }
>  
>  /* The i_flctx must be valid when calling into here */

-- 
Jeff Layton <jlayton@poochiereds.net>

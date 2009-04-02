From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: call locks_release_private to cleanup
	per-filesystem state
Date: Thu, 2 Apr 2009 18:46:01 -0400
Message-ID: <20090402224601.GF18195@fieldses.org>
References: <1238530376-28013-1-git-send-email-felixb@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Felix Blyakher <felixb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:49481 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856AbZDBWqE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:46:04 -0400
In-Reply-To: <1238530376-28013-1-git-send-email-felixb@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2009 at 03:12:56PM -0500, Felix Blyakher wrote:
> For every lock request lockd creates a new file_lock object
> in nlmsvc_setgrantargs() by copying the passed in file_lock with
> locks_copy_lock(). A filesystem can attach it's own lock_operations
> vector to the file_lock. It has to be cleaned up at the end of the
> file_lock's life. However, lockd doesn't do it today, yet it
> asserts in nlmclnt_release_lockargs() that the per-filesystem
> state is clean.
> This patch fixes it by exporting locks_release_private() and adding
> it to nlmsvc_freegrantargs(), to be symmetrical to creating a
> file_lock in nlmsvc_setgrantargs().

On a quick skim your diagnosis and fix both look correct to me, thanks.
I need to take another look and then I'll pass it along.  How did you
originally notice this, and has this bug always existed, or was there a
previous kernel version where this worked?

--b.

> 
> Signed-off-by: Felix Blyakher <felixb@sgi.com>
> ---
>  fs/lockd/svclock.c |    2 ++
>  fs/locks.c         |    3 ++-
>  include/linux/fs.h |    1 +
>  3 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 763b78a..865504a 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -326,6 +326,8 @@ static void nlmsvc_freegrantargs(struct nlm_rqst *call)
>  {
>  	if (call->a_args.lock.oh.data != call->a_owner)
>  		kfree(call->a_args.lock.oh.data);
> +
> +	locks_release_private(&call->a_args.lock.fl);
>  }
>  
>  /*
> diff --git a/fs/locks.c b/fs/locks.c
> index ec3deea..5b745dc 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -151,7 +151,7 @@ static struct file_lock *locks_alloc_lock(void)
>  	return kmem_cache_alloc(filelock_cache, GFP_KERNEL);
>  }
>  
> -static void locks_release_private(struct file_lock *fl)
> +void locks_release_private(struct file_lock *fl)
>  {
>  	if (fl->fl_ops) {
>  		if (fl->fl_ops->fl_release_private)
> @@ -165,6 +165,7 @@ static void locks_release_private(struct file_lock *fl)
>  	}
>  
>  }
> +EXPORT_SYMBOL(locks_release_private);
>  
>  /* Free a lock which is not in use. */
>  static void locks_free_lock(struct file_lock *fl)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 92734c0..3aa4ff6 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1047,6 +1047,7 @@ extern void locks_copy_lock(struct file_lock *, struct file_lock *);
>  extern void __locks_copy_lock(struct file_lock *, const struct file_lock *);
>  extern void locks_remove_posix(struct file *, fl_owner_t);
>  extern void locks_remove_flock(struct file *);
> +extern void locks_release_private(struct file_lock *);
>  extern void posix_test_lock(struct file *, struct file_lock *);
>  extern int posix_lock_file(struct file *, struct file_lock *, struct file_lock *);
>  extern int posix_lock_file_wait(struct file *, struct file_lock *);
> -- 
> 1.5.4.rc3
> 

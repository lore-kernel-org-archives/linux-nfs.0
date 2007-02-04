From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH 9/14] lockd: handle fl_notify callbacks
Date: Sat, 03 Feb 2007 16:40:05 -0800
Message-ID: <1170549605.5749.5.camel@lade.trondhjem.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email->
	 <11704808502512-git-send-email-> <11704808513862-git-send-email->
	 <1170480851972-git-send-email-> <11704808513070-git-send-email->
	 <117048085185-git-send-email-> <11704808513263-git-send-email->
	 <11704808513185-git-send-email->
	 <6f2a40ca33ea2b58e3f515bea9be1e0fa8cda6aa.1170479265.git.bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <6f2a40ca33ea2b58e3f515bea9be1e0fa8cda6aa.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 2007-02-03 at 00:34 -0500, J. Bruce Fields wrote:
> From: Marc Eshel <eshel@almaden.ibm.com> - unquoted
> 
> Add code to handle file system callback when the lock is finally granted.
> 
> Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/lockd/svclock.c |   78 ++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 files changed, 72 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 00e657a..a558360 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -261,6 +261,8 @@ static void nlmsvc_free_block(struct kref *kref)
>  	nlmsvc_freegrantargs(block->b_call);
>  	nlm_release_call(block->b_call);
>  	nlm_release_file(block->b_file);
> +	if (block->b_fl)
> +		kfree(block->b_fl);
>  	kfree(block);
>  }
>  
> @@ -525,6 +527,32 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
>  }
>  
>  /*
> + * This is a callback from the filesystem for VFS file lock requests.
> + * It will be used if fl_notify is defined and the filesystem can not
> + * respond to the request immediately.
> + * For GETLK request it will copy the reply to the nlm_block.
> + * For SETLK or SETLKW request it will get the local posix lock.
> + * In all cases it will move the block to the head of nlm_blocked q where
> + * nlmsvc_retry_blocked() can send back a reply for SETLKW or revisit the
> + * deferred rpc for GETLK and SETLK.
> + */
> +static void
> +nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
> +			     int result)
> +{
> +	block->b_flags |= B_GOT_CALLBACK;
> +	if (result == 0)
> +		block->b_granted = 1;
> +	else
> +		block->b_flags |= B_TOO_LATE;
> +	if (conf) {
> +		block->b_fl = kzalloc(sizeof(struct file_lock), GFP_KERNEL);
> +		if (block->b_fl)
> +			locks_copy_lock(block->b_fl, conf);
> +	}
> +}
> +
> +/*
>   * Unblock a blocked lock request. This is a callback invoked from the
>   * VFS layer when a lock on which we blocked is removed.
>   *
> @@ -535,18 +563,33 @@ static int
>  nlmsvc_notify_blocked(struct file_lock *fl, struct file_lock *conf, int result)
>  {
>  	struct nlm_block	*block;
> +	int rc = -ENOENT;
>  
>  	dprintk("lockd: nlmsvc_notify_blocked lock %p conf %p result %d\n",
>  							fl, conf, result);
> +	lock_kernel();
>  	list_for_each_entry(block, &nlm_blocked, b_list) {
>  		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
> +			dprintk("lockd: nlmsvc_notify_blocked block %p flags %d\n",
> +							block, block->b_flags);
> +			if (block->b_flags & B_QUEUED) {
> +				if (block->b_flags & B_TOO_LATE) {
> +					rc = -ENOLCK;
> +					break;
> +				}
> +				nlmsvc_update_deferred_block(block, conf, result);

but nlmsvc_update_deferred_block() can sleep! How are you protecting
against races with notification? Also, how are you guaranteeing that the
block queue won't change underneath you when you lose the BKL.

> +			}
>  			nlmsvc_insert_block(block, 0);
>  			svc_wake_up(block->b_daemon);
> -			return;
> +			rc = 0;
> +			break;
>  		}
>  	}
> +	unlock_kernel();
>  
> -	printk(KERN_WARNING "lockd: notification for unknown block!\n");
> +	if (rc == -ENOENT)
> +		printk(KERN_WARNING "lockd: notification for unknown block!\n");
> +	return rc;
>  }
>  
>  static int nlmsvc_same_owner(struct file_lock *fl1, struct file_lock *fl2)
> @@ -579,6 +622,8 @@ nlmsvc_grant_blocked(struct nlm_block *block)
>  
>  	dprintk("lockd: grant blocked lock %p\n", block);
>  
> +	kref_get(&block->b_count);
> +
>  	/* Unlink block request from list */
>  	nlmsvc_unlink_block(block);
>  
> @@ -601,11 +646,13 @@ nlmsvc_grant_blocked(struct nlm_block *block)
>  	case -EAGAIN:
>  		dprintk("lockd: lock still blocked\n");
>  		nlmsvc_insert_block(block, NLM_NEVER);
> +		nlmsvc_release_block(block);
>  		return;
>  	default:
>  		printk(KERN_WARNING "lockd: unexpected error %d in %s!\n",
>  				-error, __FUNCTION__);
>  		nlmsvc_insert_block(block, 10 * HZ);
> +		nlmsvc_release_block(block);
>  		return;
>  	}
>  
> @@ -618,7 +665,6 @@ callback:
>  	nlmsvc_insert_block(block, 30 * HZ);
>  
>  	/* Call the client */
> -	kref_get(&block->b_count);
>  	if (nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG,
>  						&nlmsvc_grant_ops) < 0)
>  		nlmsvc_release_block(block);
> @@ -693,6 +739,23 @@ nlmsvc_grant_reply(struct nlm_cookie *cookie, __be32 status)
>  	nlmsvc_release_block(block);
>  }
>  
> +/* Helper function to handle retry of a deferred block.
> + * If it is a blocking lock, call grant_blocked.
> + * For a non-blocking lock or test lock, revisit the request.
> + */
> +static void
> +retry_deferred_block(struct nlm_block *block)
> +{
> +	if (!(block->b_flags & B_GOT_CALLBACK))
> +		block->b_flags |= B_TOO_LATE;
> +	nlmsvc_insert_block(block, NLM_TIMEOUT);
> +	dprintk("revisit block %p flags %d\n",	block, block->b_flags);
> +	if (block->b_deferred_req) {
> +		block->b_deferred_req->revisit(block->b_deferred_req, 0);
> +		block->b_deferred_req = NULL;
> +	}
> +}
> +
>  /*
>   * Retry all blocked locks that have been notified. This is where lockd
>   * picks up locks that can be granted, or grant notifications that must
> @@ -716,9 +779,12 @@ nlmsvc_retry_blocked(void)
>  
>  		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
>  			block, block->b_when);
> -		kref_get(&block->b_count);
> -		nlmsvc_grant_blocked(block);
> -		nlmsvc_release_block(block);
> +		if (block->b_flags & B_QUEUED) {
> +			dprintk("nlmsvc_retry_blocked delete block (%p, granted=%d, flags=%d)\n",
> +				block, block->b_granted, block->b_flags);
> +			retry_deferred_block(block);
> +		} else
> +			nlmsvc_grant_blocked(block);
>  	}
>  
>  	return timeout;


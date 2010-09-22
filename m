Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53210 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104Ab0IVTQ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 15:16:28 -0400
Date: Wed, 22 Sep 2010 15:14:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] lockd: Mostly remove BKL from the server
Message-ID: <20100922191459.GG26903@fieldses.org>
References: <4C9917B4.1010607@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C9917B4.1010607@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 21, 2010 at 04:38:12PM -0400, Bryan Schumaker wrote:
> lockd: Mostly remove BKL from the server

I wish I had better file-locking tests: testing of cross-node gfs2
conflicts would be especially useful.  This all looks right, though.
Applying.

--b.

> 
> This patch removes all but one call to lock_kernel() from the server.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> index 031c656..a336e83 100644
> --- a/fs/lockd/svc4proc.c
> +++ b/fs/lockd/svc4proc.c
> @@ -230,9 +230,7 @@ static void nlm4svc_callback_exit(struct rpc_task *task, void *data)
>  
>  static void nlm4svc_callback_release(void *data)
>  {
> -	lock_kernel();
>  	nlm_release_call(data);
> -	unlock_kernel();
>  }
>  
>  static const struct rpc_call_ops nlm4svc_callback_ops = {
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 84055d3..6f1ef00 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -52,12 +52,13 @@ static const struct rpc_call_ops nlmsvc_grant_ops;
>   * The list of blocked locks to retry
>   */
>  static LIST_HEAD(nlm_blocked);
> +static DEFINE_SPINLOCK(nlm_blocked_lock);
>  
>  /*
>   * Insert a blocked lock into the global list
>   */
>  static void
> -nlmsvc_insert_block(struct nlm_block *block, unsigned long when)
> +nlmsvc_insert_block_locked(struct nlm_block *block, unsigned long when)
>  {
>  	struct nlm_block *b;
>  	struct list_head *pos;
> @@ -87,6 +88,13 @@ nlmsvc_insert_block(struct nlm_block *block, unsigned long when)
>  	block->b_when = when;
>  }
>  
> +static void nlmsvc_insert_block(struct nlm_block *block, unsigned long when)
> +{
> +	spin_lock(&nlm_blocked_lock);
> +	nlmsvc_insert_block_locked(block, when);
> +	spin_unlock(&nlm_blocked_lock);
> +}
> +
>  /*
>   * Remove a block from the global list
>   */
> @@ -94,7 +102,9 @@ static inline void
>  nlmsvc_remove_block(struct nlm_block *block)
>  {
>  	if (!list_empty(&block->b_list)) {
> +		spin_lock(&nlm_blocked_lock);
>  		list_del_init(&block->b_list);
> +		spin_unlock(&nlm_blocked_lock);
>  		nlmsvc_release_block(block);
>  	}
>  }
> @@ -651,7 +661,7 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
>  	struct nlm_block *block;
>  	int rc = -ENOENT;
>  
> -	lock_kernel();
> +	spin_lock(&nlm_blocked_lock);
>  	list_for_each_entry(block, &nlm_blocked, b_list) {
>  		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
>  			dprintk("lockd: nlmsvc_notify_blocked block %p flags %d\n",
> @@ -665,13 +675,13 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
>  			} else if (result == 0)
>  				block->b_granted = 1;
>  
> -			nlmsvc_insert_block(block, 0);
> +			nlmsvc_insert_block_locked(block, 0);
>  			svc_wake_up(block->b_daemon);
>  			rc = 0;
>  			break;
>  		}
>  	}
> -	unlock_kernel();
> +	spin_unlock(&nlm_blocked_lock);
>  	if (rc == -ENOENT)
>  		printk(KERN_WARNING "lockd: grant for unknown block\n");
>  	return rc;
> @@ -803,7 +813,7 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
>  
>  	dprintk("lockd: GRANT_MSG RPC callback\n");
>  
> -	lock_kernel();
> +	spin_lock(&nlm_blocked_lock);
>  	/* if the block is not on a list at this point then it has
>  	 * been invalidated. Don't try to requeue it.
>  	 *
> @@ -825,19 +835,20 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
>  		/* Call was successful, now wait for client callback */
>  		timeout = 60 * HZ;
>  	}
> -	nlmsvc_insert_block(block, timeout);
> +	nlmsvc_insert_block_locked(block, timeout);
>  	svc_wake_up(block->b_daemon);
>  out:
> -	unlock_kernel();
> +	spin_unlock(&nlm_blocked_lock);
>  }
>  
> +/*
> + * FIXME: nlmsvc_release_block() grabs a mutex.  This is not allowed for an
> + * .rpc_release rpc_call_op
> + */
>  static void nlmsvc_grant_release(void *data)
>  {
>  	struct nlm_rqst		*call = data;
> -
> -	lock_kernel();
>  	nlmsvc_release_block(call->a_block);
> -	unlock_kernel();
>  }
>  
>  static const struct rpc_call_ops nlmsvc_grant_ops = {
> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
> index 0f2ab74..c3069f3 100644
> --- a/fs/lockd/svcproc.c
> +++ b/fs/lockd/svcproc.c
> @@ -260,9 +260,7 @@ static void nlmsvc_callback_exit(struct rpc_task *task, void *data)
>  
>  static void nlmsvc_callback_release(void *data)
>  {
> -	lock_kernel();
>  	nlm_release_call(data);
> -	unlock_kernel();
>  }
>  
>  static const struct rpc_call_ops nlmsvc_callback_ops = {

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks
	(RFC)
Date: Tue, 16 Dec 2008 14:38:06 -0500
Message-ID: <20081216193806.GC18928@fieldses.org>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com> <20081122011555.GA28485@fieldses.org> <20081124103313.0c779324@tleilax.poochiereds.net> <20081124170653.GF17862@fieldses.org> <20081213074042.2e8223c3@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, teigland@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53111 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312AbYLPTiI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 14:38:08 -0500
In-Reply-To: <20081213074042.2e8223c3-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 13, 2008 at 07:40:42AM -0500, Jeff Layton wrote:
> Any thoughts on the patch? I had figured this to be a relatively rare
> situation, but I've had a couple of people ask me about it recently.
> Some KDE/QT apps do this sort of locking in home dirs, so it's
> apparently a real-world problem.

If you knew of a simple description of the locking they're doing (and
why), I'd be really interested.

> The most current patch follows...

Thanks. sorry for the delay responding.  This deserves a closer look
than I've been able to give it so far:

>  /*
> + * Would granting this block cause a conflict with one already granted? Check
> + * by walking the f_blocks list for the file.
> + */
> +static bool
> +nlmsvc_check_overlap(struct nlm_block *block)
> +{
> +	struct nlm_block *fblock, *next;
> +
> +	list_for_each_entry_safe(fblock, next, &block->b_file->f_blocks,
> +				 b_flist) {
> +		/* skip myself */
> +		if (fblock == block)
> +			continue;
> +
> +		/* skip any locks that aren't granted */
> +		if (!fblock->b_granted)
> +			continue;
> +
> +		/* do block and fblock have any overlap in their ranges? */
> +		if (nlm_overlapping_locks(&block->b_call->a_args.lock.fl,
> +					  &fblock->b_call->a_args.lock.fl))
> +			return true;
> +	}
> +
> +	/* no conflicts found */
> +	return false;
> +}
> +
> +/*
>   * This is a callback from the filesystem for VFS file lock requests.
>   * It will be used if fl_grant is defined and the filesystem can not
>   * respond to the request immediately.
>   * For GETLK request it will copy the reply to the nlm_block.
>   * For SETLK or SETLKW request it will get the local posix lock.
> - * In all cases it will move the block to the head of nlm_blocked q where
> + * It will generally will move the block to the head of nlm_blocked q where
>   * nlmsvc_retry_blocked() can send back a reply for SETLKW or revisit the
> - * deferred rpc for GETLK and SETLK.
> + * deferred rpc for GETLK and SETLK. The exception is in the case where the
> + * block is not granted.
>   */
> -static void
> +static bool
>  nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
>  			     int result)
>  {
> +	bool requeue = true;
> +
>  	block->b_flags |= B_GOT_CALLBACK;
> -	if (result == 0)
> -		block->b_granted = 1;
> -	else
> +	if (result == 0) {
> +		if (nlmsvc_check_overlap(block))
> +			requeue = false;

So these check_overlap()'s are in attempt to ensure that grants for
overlapping ranges get sent back to the client in some given order?
What order is that exactly?  (Do we know that the existing order is
right?)

This can never be perfect, since we can't for example guarantee the
grant rpc's get received on the client in the right order.  I'm inclined
not to bother, but perhaps I'm missing the point.

Maybe it would help to walk through of an example that demonstrates the
problem.

> +		else
> +			block->b_granted = 1;

Also, shouldn't we be granting in this case?  Or are you counting on a
later overlapping grant that will cover this one as well?

> +	} else
>  		block->b_flags |= B_TIMED_OUT;
>  	if (conf) {
>  		if (block->b_fl)
>  			__locks_copy_lock(block->b_fl, conf);
>  	}
> +
> +	return requeue;
>  }
>  
>  static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
> @@ -643,22 +680,27 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
>  
>  	lock_kernel();
>  	list_for_each_entry(block, &nlm_blocked, b_list) {
> -		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
> -			dprintk("lockd: nlmsvc_notify_blocked block %p flags %d\n",
> -							block, block->b_flags);
> +		if (nlm_lock_in_range(&block->b_call->a_args.lock.fl, fl)) {
> +			dprintk("lockd: nlmsvc_notify_blocked block %p flags "
> +				"%d\n", block, block->b_flags);
> +
>  			if (block->b_flags & B_QUEUED) {
>  				if (block->b_flags & B_TIMED_OUT) {
> -					rc = -ENOLCK;
> -					break;
> +					if (rc == -ENOENT)
> +						rc = -ENOLCK;

I don't think the conditional is necessary.

> +					continue;
>  				}
> -				nlmsvc_update_deferred_block(block, conf, result);
> -			} else if (result == 0)
> -				block->b_granted = 1;
> +				if (!nlmsvc_update_deferred_block(block, conf,
> +								  result))
> +					continue;

Don't we still want the svc_wake_up in this case?

I'm sorry this is so hairy.... Thanks very much for looking into it.

--b.

> +			} else if (result == 0) {
> +				if (!nlmsvc_check_overlap(block))
> +					block->b_granted = 1;
> +			}
>  
>  			nlmsvc_insert_block(block, 0);
>  			svc_wake_up(block->b_daemon);
>  			rc = 0;
> -			break;
>  		}
>  	}
>  	unlock_kernel();
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index f7146e6..4a5406c 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -385,6 +385,41 @@ static inline int nlm_compare_locks(const struct file_lock *fl1,
>  	     &&(fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);
>  }
>  
> +/*
> + * Compare two NLM locks.
> + * When the second lock is of type F_UNLCK, this acts like a wildcard.
> + * Similar to nlm_compare_locks, but also return true as long as fl1's range
> + * is completely covered by fl2.
> + */
> +static inline int nlm_lock_in_range(const struct file_lock *fl1,
> +				    const struct file_lock *fl2)
> +{
> +	return	fl1->fl_pid   == fl2->fl_pid
> +	     && fl1->fl_owner == fl2->fl_owner
> +	     && fl1->fl_start >= fl2->fl_start
> +	     && fl1->fl_end   <= fl2->fl_end
> +	     && (fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);
> +}
> +
> +static inline int nlm_overlapping_locks(const struct file_lock *fl1,
> +					const struct file_lock *fl2)
> +{
> +	/* does fl1 completely cover fl2? */
> +	if (fl1->fl_start <= fl2->fl_start && fl1->fl_end >= fl2->fl_end)
> +		return 1;
> +
> +	/* does fl2 completely cover fl1 */
> +	if (fl2->fl_start <= fl1->fl_start && fl2->fl_end >= fl1->fl_end)
> +		return 1;
> +
> +	/* does the start or end of fl1 sit inside of fl2? */
> +	if ((fl1->fl_start >= fl2->fl_start && fl1->fl_start <= fl2->fl_end) ||
> +	    (fl1->fl_end >= fl2->fl_start && fl1->fl_end <= fl2->fl_end))
> +		return 1;
> +
> +	return 0;
> +}
> +
>  extern struct lock_manager_operations nlmsvc_lock_operations;
>  
>  #endif /* __KERNEL__ */
> -- 
> 1.5.5.1
> 

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks
	(RFC)
Date: Fri, 21 Nov 2008 20:15:55 -0500
Message-ID: <20081122011555.GA28485@fieldses.org>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, teigland@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35172 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755682AbYKVBQA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Nov 2008 20:16:00 -0500
In-Reply-To: <1227130623-31607-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 19, 2008 at 04:37:03PM -0500, Jeff Layton wrote:
> Dave Teigland opened a bug stating that he was having some problems with
> DLM and lockd. Essentially, the problem boiled down to the fact that
> when you do a posix lock of a region that touches another lock, the VFS
> will coalesce the locks and return a lock that encompasses the whole
> range.
> 
> The problem here is that DLM then does a fl_grant callback to lockd with
> the new coalesced lock. The fl_grant callback then looks through all
> of the blocks and eventually returns -ENOENT since none match the
> coalesced lock.

Ugh.

> I'm having a very hard time tracking down info about how the fl_grant
> callback is supposed to work. Is it OK to send an fl_grant callback
> with a lock that's larger than the one requested? If so, then lockd
> needs to account for that possibility. Also, what exactly is the
> purpose of the second arg on fl_grant ("conf" in nlmsvc_grant_deferred)?

It's only used in the case the lock failed, and it can optionally be set
to a copy of the conflicting lock.

> What follows is a patch that changes nlmsvc_grant_deferred to account
> for the possibility that it may receive an fl_grant that has already
> been coalesced. It changes nlmsvc_grant_deferred to walk the entire
> list of blocks and grant any blocks that are covered by the range of
> the lock in the grant callback, if doing so will not conflict with an
> earlier grant.

Hm.  That might work.

> The patch is still very rough and is probably broken in subtle (and
> maybe overt) ways, but it fixes the reproducer that Dave provided. It's
> just intended as a starting point for discussion. Can anyone clarify how
> fl_grant is supposed to work? Who's wrong here? DLM or NLM?

I think this wasn't thought through, apologies.  (It was my
responsibility to make sure it was!)

I also occasionally think that it would be better to keep any actual
lock application the caller's responsibility, to the extent that's
possible--so fl_grant would just be a notification, and it would be up
to lockd to try the lock again and check the result.  That's more or
less the way it always worked before, and it seems a simpler model.

Some work in the filesystem would be required to make sure it would be
ready to return an answer on that second request.

I also think there's a problem with lock cancelling in the current code.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/lockd/svclock.c          |   58 ++++++++++++++++++++++++++++++++++---------
>  include/linux/lockd/lockd.h |   35 ++++++++++++++++++++++++++
>  2 files changed, 81 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 6063a8e..5ecd1db 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -611,6 +611,35 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
>  }
>  
>  /*
> + * Would granting this block cause a conflict with one already granted? Check
> + * by walking the f_blocks list for the file.
> + */
> +static int
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
> +			return 1;
> +	}
> +
> +	/* no conflicts found */
> +	return 0;
> +}
> +
> +/*
>   * This is a callback from the filesystem for VFS file lock requests.
>   * It will be used if fl_grant is defined and the filesystem can not
>   * respond to the request immediately.
> @@ -625,9 +654,10 @@ nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
>  			     int result)
>  {
>  	block->b_flags |= B_GOT_CALLBACK;
> -	if (result == 0)
> -		block->b_granted = 1;
> -	else
> +	if (result == 0) {
> +		if (!nlmsvc_check_overlap(block))
> +			block->b_granted = 1;
> +	} else
>  		block->b_flags |= B_TIMED_OUT;
>  	if (conf) {
>  		if (block->b_fl)
> @@ -643,22 +673,26 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
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
> +					continue;
>  				}
> -				nlmsvc_update_deferred_block(block, conf, result);
> -			} else if (result == 0)
> -				block->b_granted = 1;
> +				nlmsvc_update_deferred_block(block, conf,
> +							     result);
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
> index b56d5aa..aa38d47 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -367,6 +367,41 @@ static inline int nlm_compare_locks(const struct file_lock *fl1,
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

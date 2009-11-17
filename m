From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Potential lockd bug can cause orphaned locks
Date: Tue, 17 Nov 2009 16:39:40 -0500
Message-ID: <20091117213940.GD5121@fieldses.org>
References: <4B00858E.7090400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44128 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027AbZKQVjI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Nov 2009 16:39:08 -0500
In-Reply-To: <4B00858E.7090400@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 15, 2009 at 03:49:50PM -0700, Rob Gardner wrote:
>
> I've discovered some behavior in lockd that I think is questionable. In
> conjunction with file systems that provide their own locking functions
> (ie, file->f_op->lock()), lockd seems to handle cancel requests
> inconsistently, with the result that a file may be left with a byte
> range lock on it but with no owner.
>
> There are several scenarios in which lockd would like to cancel a lock
> request:
> 1. Client sends explicit unlock or cancel request
> 2. A non-blocking lock request times out
> 3. A 'cleanup' type request, ie, client reboot and subsequent SM_NOTIFY
> which attempts to clear all locks and requests for that client
>
> In all scenarios, lockd believes that the locks and lock requests for
> the file have been cleaned up, and it closes the file and releases
> references to the file.
>
> In the first scenario, lockd calls vfs_cancel_lock to alert the file
> system that it would like to cancel the lock request; Then,
> nlmsvc_unlink_block() calls posix_unblock_lock() which cancels any
> outstanding posix lock request.
>
> But in the other two scenarios, vfs_cancel_lock() is never called, only
> posix_unblock_lock().

Yes, I agree that this is a bug, thanks for the description.

> It seems to me that scenarios 2 and 3 are perfectly good "cancel lock"
> situations and lockd should call vfs_cancel_lock() in both cases to
> reduce the possibility of a future grant for a file no longer opened by
> lockd. Depending on the vague and ambiguous advice in the locks.c
> comment seems very dangerous; Releasing a lock may not result in the
> same state as canceling the lock request that caused the grant so it
> should always be preferable to cancel a lock if possible, rather than
> waiting for a grant then unlocking it.

That suggests there are other races between a grant and a cancel that
we're not addressing here.

...
> Possible code change (not tested):
>
> --- svclock.c.linux-2.6.32-rc6    2009-11-15 13:54:03.000000000 -0700
> +++ svclock.c    2009-11-15 13:57:15.000000000 -0700
> @@ -288,8 +288,9 @@
>        if (list_empty(&block->b_list))
>            continue;
>        kref_get(&block->b_count);
>        mutex_unlock(&file->f_mutex);
> +        vfs_cancel_lock(block->b_file->f_file,
> +              &block->b_call->a_args.lock.fl);
>        nlmsvc_unlink_block(block);
>        nlmsvc_release_block(block);
>        goto restart;
>    }
> @@ -399,8 +400,9 @@
>            ret = nlm_granted;
>            goto out;
>        }
>        if (block->b_flags & B_TIMED_OUT) {
> +            vfs_cancel_lock(block->b_file->f_file,
> +                  &block->b_call->a_args.lock.fl);
>            nlmsvc_unlink_block(block);
>            ret = nlm_lck_denied;
>            goto out;
>        }

Seems reasonable, though it is a bit annoying trying to determine which
of these should be called where, so...

> Another possibility is to change nlmsvc_unlink_block() to make the call to
> vfs_cancel_lock() and then remove the call to vfs_cancel_lock in
> nlmsvc_cancel_blocked(). But I don't really like this as most other
> calls to nlmsvc_unlink_block() do not require a call to vfs_cancel_lock().

..yes, I understand why the ideal initially appeals, but don't have a
better suggestion.

--b.

>
> I am interested in hearing opinions on this... is there a better  
> solution? Or is it not really a problem because of something else?
>
>
> Rob Gardner
>
>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

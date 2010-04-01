From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: lockd and lock cancellation
Date: Thu, 01 Apr 2010 13:40:59 +0100
Message-ID: <4BB4945B.4040106@hp.com>
References: <1270124202.3354.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"eshel@almaden.ibm.com" <eshel@almaden.ibm.com>
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:23782 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653Ab0DAMkZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 08:40:25 -0400
In-Reply-To: <1270124202.3354.40.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steven Whitehouse wrote:
> Hi,
>
> I'm trying to find my way around the lockd code and I'm currently a bit
> stumped by the code relating to lock cancellation. There is only one
> call to vfs_cancel_lock() in lockd/svclock.c and its return value isn't
> checked.
>
> It is used in combination with nlmsvc_unlink_block() which
> unconditionally calls posix_unblock_lock(). There are also other places
> where the code also calls nlmsvc_unlink_block() without first canceling
> the lock. The way in which vfs_cancel_lock() is used suggests that
> canceling a lock is a synchronous operation, and that it must succeed
> before returning.
>
> I'd have expected to see (pseudo code) something more like the
> following:
>
> ret = vfs_cancel_lock();
> if (ret == -ENOENT) /* never had the lock in the first place */
>     do_something_appropriate();
> else if (ret == -EINVAL) /* we raced with a grant */
>     unlock_lock();
> else /* lock successfully canceled */
>     nlmsvc_unlink_block();
>
> Is there a reason why that is not required? and indeed, is there a
> reason why its safe to call nlmsvc_unlink_block() in the cases where the
> lock isn't canceled first? I'm trying to work out how the underlying fs
> can tell that a lock has gone away in those particular cases,
>   

Steve,

I noticed the missing cancel scenario some time ago and reported on it 
here. Bruce agreed that it was a bug, but I regret that I haven't had 
time to follow up on it. The problem was that vfs_cancel_lock was not 
being called in all cases where it should be, possibly resulting in an 
orphaned lock in the filesystem. See attached message for more detail. 
(Or http://marc.info/?l=linux-nfs&m=125849395630496&w=2)

By the way, if a lock grant wins a race with a cancel, I do not think it 
is "safe" to simply unlock the lock at that point.

Rob Gardner


*List:       linux-nfs <http://marc.info/?l=linux-nfs&r=1&w=2>
Subject:    Re: Potential lockd bug can cause orphaned locks <http://marc.info/?t=125832556700002&r=1&w=2>
From:       "J. Bruce Fields" <bfields () fieldses ! org> <http://marc.info/?a=100577513600008&r=1&w=2>
Date:       2009-11-17 21:39:40 <http://marc.info/?l=linux-nfs&r=1&w=2&b=200911>
Message-ID: 20091117213940.GD5121 () fieldses ! org <http://marc.info/?i=20091117213940.GD5121%20%28%29%20fieldses%20%21%20org>*

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



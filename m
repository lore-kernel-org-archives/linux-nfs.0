Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab3FQPzh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 11:55:37 -0400
Date: Mon, 17 Jun 2013 11:55:08 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org,
        dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: Re: [PATCH v3 07/13] locks: avoid taking global lock if possible
 when waking up blocked waiters
Message-ID: <20130617115508.4db5e5f9@tlielax.poochiereds.net>
In-Reply-To: <1371482036-15958-8-git-send-email-jlayton@redhat.com>
References: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
	<1371482036-15958-8-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 17 Jun 2013 11:13:50 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> Since we always hold the i_lock when inserting a new waiter onto the
> fl_block list, we can avoid taking the global lock at all if we find
> that it's empty when we go to wake up blocked waiters.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/locks.c |   17 ++++++++++++++---
>  1 files changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 8f56651..a8f3b33 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -532,7 +532,10 @@ static void locks_delete_block(struct file_lock *waiter)
>   * the order they blocked. The documentation doesn't require this but
>   * it seems like the reasonable thing to do.
>   *
> - * Must be called with file_lock_lock held!
> + * Must be called with both the i_lock and file_lock_lock held. The fl_block
> + * list itself is protected by the file_lock_list, but by ensuring that the
> + * i_lock is also held on insertions we can avoid taking the file_lock_lock
> + * in some cases when we see that the fl_block list is empty.
>   */
>  static void __locks_insert_block(struct file_lock *blocker,
>  					struct file_lock *waiter)
> @@ -560,8 +563,16 @@ static void locks_insert_block(struct file_lock *blocker,
>   */
>  static void locks_wake_up_blocks(struct file_lock *blocker)
>  {
> +	/*
> +	 * Avoid taking global lock if list is empty. This is safe since new
> +	 * blocked requests are only added to the list under the i_lock, and
> +	 * the i_lock is always held here.
> +	 */
> +	if (list_empty(&blocker->fl_block))
> +		return;
> +


Ok, potential race here. We hold the i_lock when we check list_empty()
above, but it's possible for the fl_block list to become empty between
that check and when we take the spinlock below. locks_delete_block does
not require that you hold the i_lock, and some callers don't hold it.

This is trivially fixable by just keeping this as a while() loop. We'll
do the list_empty() check twice in that case, but that shouldn't change
the performance here much.

I'll fix that in my tree and it'll be in the next resend. Sorry for the
noise...

>  	spin_lock(&file_lock_lock);
> -	while (!list_empty(&blocker->fl_block)) {
> +	do {

>  		struct file_lock *waiter;
>  
>  		waiter = list_first_entry(&blocker->fl_block,
> @@ -571,7 +582,7 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
>  			waiter->fl_lmops->lm_notify(waiter);
>  		else
>  			wake_up(&waiter->fl_wait);
> -	}
> +	} while (!list_empty(&blocker->fl_block));
>  	spin_unlock(&file_lock_lock);
>  }
>  


-- 
Jeff Layton <jlayton@redhat.com>

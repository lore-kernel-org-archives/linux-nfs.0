From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH 4/4] NLM: don't requeue block if it was invalidated while GRANT_MSG was in flight
Date: Fri, 14 Mar 2008 17:41:39 -0400
Message-ID: <170fa0d20803141441n34c5c0cdv383a0028a63b2268@mail.gmail.com>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-2-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-3-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-4-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-5-git-send-email-jlayton@redhat.com>
	 <170fa0d20803141255k41e8e2a3t6a53f4f812a15d7b@mail.gmail.com>
	 <20080314170120.790f99a9@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:37962 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548AbYCNVll (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 17:41:41 -0400
Received: by wr-out-0506.google.com with SMTP id c48so3369220wra.1
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2008 14:41:40 -0700 (PDT)
In-Reply-To: <20080314170120.790f99a9-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/14/08, Jeff Layton <jlayton@redhat.com> wrote:
> On Fri, 14 Mar 2008 15:55:38 -0400
>  "Mike Snitzer" <snitzer@gmail.com> wrote:
>
>  > On 2/6/08, Jeff Layton <jlayton@redhat.com> wrote:
>  > > It's possible for lockd to catch a SIGKILL while a GRANT_MSG callback
>  > >  is in flight. If this happens we don't want lockd to insert the block
>  > >  back into the nlm_blocked list.
>  > >
>  > >  This helps that situation, but there's still a possible race. Fixing
>  > >  that will mean adding real locking for nlm_blocked.
>  > >
>  > >  Signed-off-by: Jeff Layton <jlayton@redhat.com>
>  > >  ---
>  > >   fs/lockd/svclock.c |   11 +++++++++++
>  > >   1 files changed, 11 insertions(+), 0 deletions(-)
>  > >
>  > >  diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
>  > >  index 82db7b3..fe9bdb4 100644
>  > >  --- a/fs/lockd/svclock.c
>  > >  +++ b/fs/lockd/svclock.c
>  > >  @@ -795,6 +795,17 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
>  > >
>  > >         dprintk("lockd: GRANT_MSG RPC callback\n");
>  > >
>  > >  +       /* if the block is not on a list at this point then it has
>  > >  +        * been invalidated. Don't try to requeue it.
>  > >  +        *
>  > >  +        * FIXME: it's possible that the block is removed from the list
>  > >  +        * after this check but before the nlmsvc_insert_block. In that
>  > >  +        * case it will be added back. Perhaps we need better locking
>  > >  +        * for nlm_blocked?
>  > >  +        */
>  > >  +       if (list_empty(&block->b_list))
>  > >  +               return;
>  > >  +
>  > >         /* Technically, we should down the file semaphore here. Since we
>  > >          * move the block towards the head of the queue only, no harm
>  > >          * can be done, though. */
>  > >
>  >
>  > Hi Jeff,
>  >
>  > Would the following patch take care of this race?  Two questions I have:
>  > 1) Does my patch address your FIXME?  I believe it should.
>
>
> I don't think so. I think you'd have to have nlmsvc_grant_callback()
>  take and hold your nlm_blocked_mutex over the whole function.

OK.

>  > 2) Can I get rid of the BKL in nlmsvc_grant_deferred() given this
>  > nlm_blocked serialization?  It is unclear to me if
>  > nlmsvc_grant_deferred() is taking the BKL purely to protect
>  > nlm_blocked.
>  >
>
>
> I'm not at all clear on why we have so much of this done under the BKL.
>  I'm not sure that anyone does. If you could figure it out and document
>  it, you'd be my hero. My understanding was that it had more to do with
>  VFS locking, but I could certainly be wrong on this.

OK, yes.. I was hoping someone else could be my hero ;)

>  Now that you mention it though, it does look like we do rpc_call_done
>  under the BKL. So you may be right that that's actually protecting
>  nlm_blocked here. My FIXME may be bogus.
>
>  The main user of nlm_blocked is lockd itself. I don't think anything
>  else generally touches that list. Since lockd is single-threaded by
>  design, locking the list may be unnecessary. The exception is the grant
>  callback here, which runs from rpciod. But if that's protected by the
>  BKL, it may not be a problem.

Correct, nlm_blocked is local to svclock.c
I'm concerned precisely with the ->fl_grant callback and it's access
of nlm_blocked.

>  > As an aside, I'm not convinced that the SIGKILL-only assertion you're
>  > making about the block not being on the list is valid considering it
>  > looks to me like there is a race in nlmsvc_lock().
>  >
>  > The block isn't added to nlm_blocked until after there is an opening
>  > for the FS to callback via fl_grant().  Whereby causing
>  > nlmsvc_grant_callback() to not find the block on the list.
>  >
>
>
> I'm not sure I see this race. nlmsvc_grant_callback() won't get called
>  until after nlmsvc_grant_blocked() has does the RPC call. That doesn't
>  happen until the block has been added to the list. Can you elaborate on
>  the race you're seeing?

I'm sorry I meant nlmsvc_grant_deferred() (aka ->fl_grant) not
nlmsvc_grant_blocked().

The race appears to be that the BKL is not always held on entry into
nlmsvc_lock() and the call to vfs_lock_file() is made.  If
vfs_lock_file() returns -EINPROGRESS for a F_SETLK request the block
will get added to nlm_blocked.

But there is a distinct possibility that ->fl_grant() can race against
vfs_lock_file() returning and nlmsvc_lock() adding the block to
nlm_blocked.

This would be a non-issue if both nlmsvc_lock() and
nlmsvc_grant_deferred() are _always_ called with the BKL.  But again,
it seems nlmsvc_lock() didn't reliably have the BKL.

Mike

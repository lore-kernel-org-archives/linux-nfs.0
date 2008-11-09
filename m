From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/5] rpc: Use separate spinlock for cred locking in
	auth_gss.c
Date: Sun, 9 Nov 2008 15:46:21 -0500
Message-ID: <20081109204621.GD27376@fieldses.org>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu> <1213397442-15611-2-git-send-email-bfields@citi.umich.edu> <1213397442-15611-3-git-send-email-bfields@citi.umich.edu> <1213459135.7149.7.camel@localhost> <20080614174528.GF27041@fieldses.org> <1213467387.7149.30.camel@localhost> <20080617205159.GA5387@fieldses.org> <1213738487.7288.66.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52397 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987AbYKIUqY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 15:46:24 -0500
In-Reply-To: <1213738487.7288.66.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 17, 2008 at 05:34:47PM -0400, Trond Myklebust wrote:
> On Tue, 2008-06-17 at 16:51 -0400, J. Bruce Fields wrote:
> > On Sat, Jun 14, 2008 at 02:16:27PM -0400, Trond Myklebust wrote:
> > > On Sat, 2008-06-14 at 13:45 -0400, J. Bruce Fields wrote:
> > > > > NACK. I deliberately ripped out the old struct gss_auth spinlock in
> > > > > order to allow multiple gss_auth per inode (I believe Kevin was asking
> > > > > for this).
> > > > 
> > > > OK, makes sense.  So what will be the scope of a cred lookup--an rpc
> > > > client?
> > > 
> > > That should normally be the case, but why do you need to change the
> > > locking here in the first place? Is there ever going to be a case where
> > > the same rpc_cred has upcalls on several different pipes? I can't see
> > > how that could be justified.
> > 
> > If you allow changing the upcall version over the life of the kernel,
> > then it's difficult to avoid.  You can insist that noone have both the
> > new and old version opened simultaneously, for example, but it's harder
> > to know when there are no longer messages sitting around that have been
> > unhashed but are still lying around waiting for a process to wake up and
> > examine their results.
> 
> AFAIK, there are two cases when the dying rpc.gssd closes the pipe:
> 
>      1. gss_cred->gc_upcall is set. In this case, the gss_cred has a
>         full reference to the gss_msg, so it has no trouble locating the
>         message and figuring out if it needs to resend (rpc_purge_list()
>         will ensure that the error field is set to EAGAIN) or if the
>         call completed before gssd died. If you are worried about the
>         fact that gss_upcall_callback uses gss_msg->auth to access the
>         inode in order to do the locking, then just add a pointer to the
>         inode to gss_msg: it is not as if a gss_msg can migrate from one
>         upcall queue to another.
>      2. gss_cred->gc_upcall is not set. In this case the call to
>         rpc_purge_list() in rpc_pipe_release() will ensure that the
>         message gets immediately released.
> 
> In other words, I can't see that keeping the current behaviour will
> cause you to have more than one upcall at a time even if you do restart
> rpc.gssd.

OK, sorry for the delay.  I believe there is still a race here in the
presence of two pipes that take upcalls, something like:

	task 1				task 2
	------				------

	Create upcall message on
	old pipe using refresh_upcall

		---- gssd closes old pipe, destroys message ----
		---- new gssd opens new pipe ----

	close of old pipe wakes up
	this rpc task; upcall_callback
	called.
					gss_refresh__callback creates new
					upcall on new pipe for the same cred;
					sets gc_upcall.
	gc_upcall := NULL
					woken up later, upcall_callback
					dereferences NULL gc_upcall.

The problem being that access to gc_upcall isn't correctly serialized,
since it's protected here by two different i_lock's (task 1 is using the
old pipe's i_lock, task 2 the new pipe's i_lock).

Anyway, rather than fooling with the basic data structures I figured
it's easiest just to add a separate lock which just controls the change
of version and to forbid changing the version while there are still any
upcalls lying around.  I'll send patches.

--b.

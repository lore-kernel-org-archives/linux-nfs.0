From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: lockd and lock cancellation
Date: Thu, 01 Apr 2010 14:13:50 +0100
Message-ID: <1270127630.3354.52.camel@localhost>
References: <1270124202.3354.40.camel@localhost>  <4BB4945B.4040106@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"eshel@almaden.ibm.com" <eshel@almaden.ibm.com>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758335Ab0DAQiG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 12:38:06 -0400
In-Reply-To: <4BB4945B.4040106@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Thanks for the fast response...

On Thu, 2010-04-01 at 13:40 +0100, Rob Gardner wrote:
> Steven Whitehouse wrote:
> > Hi,
> >
> > I'm trying to find my way around the lockd code and I'm currently a bit
> > stumped by the code relating to lock cancellation. There is only one
> > call to vfs_cancel_lock() in lockd/svclock.c and its return value isn't
> > checked.
> >
> > It is used in combination with nlmsvc_unlink_block() which
> > unconditionally calls posix_unblock_lock(). There are also other places
> > where the code also calls nlmsvc_unlink_block() without first canceling
> > the lock. The way in which vfs_cancel_lock() is used suggests that
> > canceling a lock is a synchronous operation, and that it must succeed
> > before returning.
> >
> > I'd have expected to see (pseudo code) something more like the
> > following:
> >
> > ret = vfs_cancel_lock();
> > if (ret == -ENOENT) /* never had the lock in the first place */
> >     do_something_appropriate();
> > else if (ret == -EINVAL) /* we raced with a grant */
> >     unlock_lock();
> > else /* lock successfully canceled */
> >     nlmsvc_unlink_block();
> >
> > Is there a reason why that is not required? and indeed, is there a
> > reason why its safe to call nlmsvc_unlink_block() in the cases where the
> > lock isn't canceled first? I'm trying to work out how the underlying fs
> > can tell that a lock has gone away in those particular cases,
> >   
> 
> Steve,
> 
> I noticed the missing cancel scenario some time ago and reported on it 
> here. Bruce agreed that it was a bug, but I regret that I haven't had 
> time to follow up on it. The problem was that vfs_cancel_lock was not 
> being called in all cases where it should be, possibly resulting in an 
> orphaned lock in the filesystem. See attached message for more detail. 
> (Or http://marc.info/?l=linux-nfs&m=125849395630496&w=2)
> 
I have one question relating to that message (see below)

> By the way, if a lock grant wins a race with a cancel, I do not think it 
> is "safe" to simply unlock the lock at that point.
> 
Why not? If the cancel has failed, then we are left holding the lock
just as if we'd requested it and no cancel had been issued. Or another
way to ask the same question, if that does occur, what would be the
correct way to dispose of the unwanted lock?

[snip]
> 
> Seems reasonable, though it is a bit annoying trying to determine which
> of these should be called where, so...
> 
> > Another possibility is to change nlmsvc_unlink_block() to make the call to
> > vfs_cancel_lock() and then remove the call to vfs_cancel_lock in
> > nlmsvc_cancel_blocked(). But I don't really like this as most other
> > calls to nlmsvc_unlink_block() do not require a call to vfs_cancel_lock().
> 
> ..yes, I understand why the ideal initially appeals, but don't have a
> better suggestion.
> 
> --b.
> 

Can we not use a flag to figure out when a cancel needs to be sent? We
could set the flag when an async request was sent to the underlying fs
and clear it when the reply arrives. It would thus only be valid to send
a vfs_cancel_lock() request when the flag was set.

My other thought is whether or not posix_unblock_lock() could be merged
into vfs_cancel_lock() or whether there are really cases where that
needs to be called without a cancellation having taken place,

Steve.




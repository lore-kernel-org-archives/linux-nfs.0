Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932391Ab3CMPRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Mar 2013 11:17:43 -0400
Date: Wed, 13 Mar 2013 11:17:27 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Tejun Heo <tj@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Oleg Nesterov <oleg@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-cifs@vger.kernel.org
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130313111727.63391672@tlielax.poochiereds.net>
In-Reply-To: <20130306214016.GQ1227@htj.dyndns.org>
References: <20130305140312.243cb094@tlielax.poochiereds.net>
	<20130305190923.GI12795@htj.dyndns.org>
	<20130305183941.19ff39ce@tlielax.poochiereds.net>
	<20130305234700.GE1227@htj.dyndns.org>
	<20130306181608.GA18687@redhat.com>
	<20130306185304.GM1227@htj.dyndns.org>
	<CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
	<20130306212452.GO1227@htj.dyndns.org>
	<CA+55aFy49AWptMcvEzJxg95ikf-dC+-vcCPq-cnaCCwje3tyoQ@mail.gmail.com>
	<20130306213636.GP1227@htj.dyndns.org>
	<20130306214016.GQ1227@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 6 Mar 2013 13:40:16 -0800
Tejun Heo <tj@kernel.org> wrote:

> On Wed, Mar 06, 2013 at 01:36:36PM -0800, Tejun Heo wrote:
> > On Wed, Mar 06, 2013 at 01:31:10PM -0800, Linus Torvalds wrote:
> > > So I do agree that we probably have *too* many of the stupid "let's
> > > check if we can freeze", and I suspect that the NFS code should get
> > > rid of the "freezable_schedule()" that is causing this warning
> > > (because I also agree that you should *not* freeze while holding
> > > locks, because it really can cause deadlocks), but I do suspect that
> > > network filesystems do need to have a few places where they check for
> > > freezing on their own... Exactly because freezing isn't *quite* like a
> > > signal.
> > 
> > Well, I don't really know much about nfs so I can't really tell, but
> > for most other cases, dealing with freezing like a signal should work
> > fine from what I've seen although I can't be sure before actually
> > trying.  Trond, Bruce, can you guys please chime in?
> 
> So, I think the question here would be, in nfs, how many of the
> current freezer check points would be difficult to conver to signal
> handling model after excluding the ones which are performed while
> holding some locks which we need to get rid of anyway?
> 

I think we can do this, but it isn't trivial. Here's what I'd envision,
but there are still many details that would need to be worked out...

Basically what we'd need is a way to go into TASK_KILLABLE sleep, but
still allow the freezer to wake these processes up. I guess that likely
means we need a new sleep state (TASK_FREEZABLE?).

We'd also need a way to return an -ERESTARTSYS like error (-EFREEZING?)
that tells the upper syscall handling layers to freeze the task and
then restart the syscall after waking back up. Maybe we don't need a
new error at all and -ERESTARTSYS is fine here? We also need to
consider the effects vs. audit code here, but that may be OK with the
overhaul that Al merged a few months ago.

Assuming we have those, then we need to fix up the NFS and RPC layers
to use this stuff:

1/ Prior to submitting a new RPC, we'd look and see whether "current"
is being frozen. If it is, then return -EFREEZING immediately without
doing anything.

2/ We might also need to retrofit certain stages in the RPC FSM to
return -EFREEZING too if it's a synchronous RPC and the task is being
frozen.

3/ A task is waiting for an RPC reply on an async RPC, we'd need to use
this new sleep state. If the process wakes up because something wants
it to freeze, then have it go back to sleep for a short period of time
to try and wait for the reply (up to 15s or so?). If we get the reply,
great -- return to userland and freeze the task there. If the reply
never comes in, give up on it and just return -EFREEZE and hope for the
best.

We might have to make this latter behavior contingent on a new mount
option (maybe "-o slushy" like Trond recommended). The current "hard"
and "soft" semantics don't really fit this situation correctly.

Of course, this is all a lot of work, and not something we can shove
into the kernel for 3.9 at this point. In the meantime, while Mandeep's
warning is correctly pointing out a problem, I think we ought to back
it out until we can fix this properly.

We're already getting a ton of reports on the mailing lists and in the
fedora bug tracker for this warning. Part of the problem is the
verbiage -- "BUG" makes people think "Oops", but this is really just a
warning.

We should also note that this is a problem too in the CIFS code since
it uses a similar mechanism for allowing the kernel to suspend while
waiting on SMB replies.

-- 
Jeff Layton <jlayton@redhat.com>

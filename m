Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:56109 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3CFVY6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 16:24:58 -0500
Date: Wed, 6 Mar 2013 13:24:52 -0800
From: Tejun Heo <tj@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306212452.GO1227@htj.dyndns.org>
References: <20130305082308.6607d4db@tlielax.poochiereds.net>
 <20130305174648.GF12795@htj.dyndns.org>
 <20130305174954.GG12795@htj.dyndns.org>
 <20130305140312.243cb094@tlielax.poochiereds.net>
 <20130305190923.GI12795@htj.dyndns.org>
 <20130305183941.19ff39ce@tlielax.poochiereds.net>
 <20130305234700.GE1227@htj.dyndns.org>
 <20130306181608.GA18687@redhat.com>
 <20130306185304.GM1227@htj.dyndns.org>
 <CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Linus.

On Wed, Mar 06, 2013 at 01:00:02PM -0800, Linus Torvalds wrote:
> > Oh yeah, we don't need another signal.  We just need sigpending state
> > and a wakeup.  I wasn't really going into details.  The important
> > point is that for code paths outside signal/ptrace, freezing could
> > look and behave about the same as signal delivery.
> 
> Don't we already do that? The whole "try_to_freeze()" in
> get_signal_to_deliver() is about exactly this. See
> fake_signal_wake_up().

Yeap, that was what I had in mind too.  Maybe we'll need to modify it
slightly but we already have most of the basic stuff.

> You still have kernel threads (that don't do signals) to worry about,
> so it doesn't make things go away. And you still have issues with
> latency of disk wait, which is, I think, the reason for that
> "freezable_schedule()" in the NFS code to begin with.

I haven't thought about it for quite some time so things are hazy, but
here's what I can recall now.

With syscall paths out of the way, the surface is reduced a lot.
Another part is converting most freezable kthread users to freezable
workqueue which provides natural resource boundaries (the duration of
work item execution).  kthread is already difficult to get the
synchronization completely right and significant number of freezable +
should_stop users are subtly broken the last time I went over the
freezer users.  I think we would be much better off converting most
over to freezable workqueues which is easier to get right and likely
to be less expensive.  Freezing happens at work item boundary which in
most cases could be made to coincide with the original freezer check
point.

There could be kthreads which can't be converted to workqueue for
whatever reason (there shouldn't be many at this point) but most
freezer usages in kthreads are pretty simple.  It's usually single or
a couple freezer check points in the main loop.  While we may still
need special handling for them, I don't think they're likely to have
implications on issues like this.

We probably would want to handle restart for freezable kthreads
calling syscalls.  Haven't thought about this one too much yet.  Maybe
freezable kthreads doing syscalls just need to be ready for
-ERESTARTSYS?

I'm not sure I follow the disk wait latency part.  Are you saying that
switching to jobctl trap based freezer implementation wouldn't help
them?  If so, right, it doesn't in itself.  It's just changing the
infrastructure used for freezing and can't make the underlying
synchronization issues just disappear but at least it becomes the same
problem as being responsive to SIGKILL rather than a completely
separate problem.

Thanks.

-- 
tejun

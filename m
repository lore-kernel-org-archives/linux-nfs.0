Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932455Ab3CGLmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Mar 2013 06:42:05 -0500
Date: Thu, 7 Mar 2013 06:41:40 -0500
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
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130307064140.71c0936b@tlielax.poochiereds.net>
In-Reply-To: <20130306213636.GP1227@htj.dyndns.org>
References: <20130305174954.GG12795@htj.dyndns.org>
	<20130305140312.243cb094@tlielax.poochiereds.net>
	<20130305190923.GI12795@htj.dyndns.org>
	<20130305183941.19ff39ce@tlielax.poochiereds.net>
	<20130305234700.GE1227@htj.dyndns.org>
	<20130306181608.GA18687@redhat.com>
	<20130306185304.GM1227@htj.dyndns.org>
	<CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
	<20130306212452.GO1227@htj.dyndns.org>
	<CA+55aFy49AWptMcvEzJxg95ikf-dC+-vcCPq-cnaCCwje3tyoQ@mail.gmail.com>
	<20130306213636.GP1227@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 6 Mar 2013 13:36:36 -0800
Tejun Heo <tj@kernel.org> wrote:

> On Wed, Mar 06, 2013 at 01:31:10PM -0800, Linus Torvalds wrote:
> > So I do agree that we probably have *too* many of the stupid "let's
> > check if we can freeze", and I suspect that the NFS code should get
> > rid of the "freezable_schedule()" that is causing this warning
> > (because I also agree that you should *not* freeze while holding
> > locks, because it really can cause deadlocks), but I do suspect that
> > network filesystems do need to have a few places where they check for
> > freezing on their own... Exactly because freezing isn't *quite* like a
> > signal.
> 
> Well, I don't really know much about nfs so I can't really tell, but
> for most other cases, dealing with freezing like a signal should work
> fine from what I've seen although I can't be sure before actually
> trying.  Trond, Bruce, can you guys please chime in?
> 
> Thanks.
> 

(hopefully this isn't tl;dr)

It's not quite that simple...

The problem (as Trond already mentioned) is non-idempotent operations.
You can't just restart certain operations from scratch once you reach a
certain point. Here's an example:

Suppose I call unlink("somefile"); on an NFS mount. We take all of the
VFS locks, go down into the NFS layer. That marshals up the UNLINK
call, sends it off to the server, and waits for the reply. While we're
waiting, a freeze event comes in and we start returning from the
kernel with our new -EFREEZE return code that works sort of like
-ERESTARTSYS. Meanwhile, the server is processing the UNLINK call and
removes the file. A little while later we wake up the machine and it
goes to try and pick up where it left off.

What do we do now?

Suppose we pretend we never sent the call in the first place, marshal
up a new RPC and send it again. This is problematic -- the server will
probably send back the equivalent of ENOENT. How do we know whether the
file never existed in the first place, or whether the server processed
the original call and removed the file then?

Do we instead try and keep track of whether the RPC has been sent and
just wait for the reply on the original call? That's tricky too -- it
means adding an extra codepath to check for these sorts of restarts in
a bunch of different ops vectors into the filesystem. We also have to
somehow keep track of this state too (I guess by hanging something off
the task_struct).

Note too that the above is the simple case. We're dropping the parent's
i_mutex during the freeze. Suppose when we restart the call that the
parent directory has changed in such a way that the original lookup we
did to do the original RPC is no longer valid?

I think Trond may be on the right track. We probably need some
mechanism to quiesce the filesystem ahead of any sort of freezer
event. That quiesce could simply wait on any in flight RPCs to come
back, and not allow any new ones to go out. On syscalls where the RPC
didn't go out, we'd just return -EFREEZE or whatever and let the upper
layers restart the call after waking back up. Writeback would be
tricky, but that can be handled too.

The catch here is that it's quite possible that when we need to quiesce
that we've lost communications with the server. We don't want to hold
up the freezer at that point so the wait for replies has to be bounded
in time somehow. If that times out, we probably just have to return all
calls with our new -EFREEZE return and hope for the best when the
machine wakes back up.

-- 
Jeff Layton <jlayton@redhat.com>

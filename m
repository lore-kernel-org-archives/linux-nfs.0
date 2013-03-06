Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755838Ab3CFMBG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Mar 2013 07:01:06 -0500
Date: Wed, 6 Mar 2013 07:00:48 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
        "Mandeep Singh Baines" <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306070048.083c8022@tlielax.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B1246@sacexcmbx05-prd.hq.netapp.com>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
	<20130304092310.1d21100c@tlielax.poochiereds.net>
	<CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
	<20130304205307.GA13527@redhat.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
	<20130305082308.6607d4db@tlielax.poochiereds.net>
	<20130305174648.GF12795@htj.dyndns.org>
	<20130305174954.GG12795@htj.dyndns.org>
	<20130305140312.243cb094@tlielax.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286B1246@sacexcmbx05-prd.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 6 Mar 2013 01:10:07 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-03-05 at 14:03 -0500, Jeff Layton wrote:
> > On Tue, 5 Mar 2013 09:49:54 -0800
> > Tejun Heo <tj@kernel.org> wrote:
> > 
> > > On Tue, Mar 05, 2013 at 09:46:48AM -0800, Tejun Heo wrote:
> > > > So, I think this is why implementing freezer as a separate blocking
> > > > mechanism isn't such a good idea.  We're effectively introducing a
> > > > completely new waiting state to a lot of unsuspecting paths which
> > > > generates a lot of risks and eventually extra complexity to work
> > > > around those.  I think we really should update freezer to re-use the
> > > > blocking points we already have - the ones used for signal delivery
> > > > and ptracing.  That way, other code paths don't have to worry about an
> > > > extra stop state and we can confine most complexities to freezer
> > > > proper.
> > > 
> > > Also, consolidating those wait states means that we can solve the
> > > event-to-response latency problem for all three cases - signal, ptrace
> > > and freezer, rather than adding separate backing-out strategy for
> > > freezer.
> > > 
> > 
> > Sounds intriguing...
> > 
> > I'm not sure what this really means for something like NFS though. How
> > would you envision this working when we have long running syscalls that
> > might sit waiting in the kernel indefinitely?
> > 
> > Here's my blue-sky, poorly-thought-out idea...
> > 
> > We could add a signal (e.g. SIGFREEZE) that allows the sleeps in
> > NFS/RPC layer to be interrupted. Those would return back toward
> > userland with a particular type of error (sort of like ERESTARTSYS).
> > 
> > Before returning from the kernel though, we could freeze the process.
> > When it wakes up, then we could go back down and retry the call again
> > (much like an ERESTARTSYS kind of thing).
> 
> Two (three?) show stopper words for you: "non-idempotent operations".
> 
> Not all RPC calls can just be interrupted and restarted. Something like
> an exclusive file create, unlink, file locking attempt, etc may give
> rise to different results when replayed in the above scenario.
> Interrupting an RPC call is not equivalent to cancelling its effects...
> 

Right -- that's the part where we have to take great care to save the
state of the syscall at the time we returned back up toward userland on
a freeze event. I suppose we'd need to hang something off the
task_struct to keep track of that.

In most cases, it would be sufficient to keep track of whether an RPC
had been sent during the call for non-idempotent operations. If it was
sent, then we'd just re-enter the wait for the reply. If it wasn't then
we'd go ahead and send the call.

Still, I'm sure there are details I'm overlooking here. The whole point
of holding these mutexes is to ensure that operations that the
directories don't change while we're doing these operations. If we
release the locks in order to go to sleep, then there's no guarantee
that things haven't changed when we reacquire them.

Maybe it's best to give up and just tell people that suspending your
laptop with a NFS mount is not allowed :P

-- 
Jeff Layton <jlayton@redhat.com>

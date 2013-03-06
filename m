Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50577 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755692Ab3CFBKW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 20:10:22 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
        "Mandeep Singh Baines" <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Date: Wed, 6 Mar 2013 01:10:07 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B1246@sacexcmbx05-prd.hq.netapp.com>
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
In-Reply-To: <20130305140312.243cb094@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-03-05 at 14:03 -0500, Jeff Layton wrote:
> On Tue, 5 Mar 2013 09:49:54 -0800
> Tejun Heo <tj@kernel.org> wrote:
> 
> > On Tue, Mar 05, 2013 at 09:46:48AM -0800, Tejun Heo wrote:
> > > So, I think this is why implementing freezer as a separate blocking
> > > mechanism isn't such a good idea.  We're effectively introducing a
> > > completely new waiting state to a lot of unsuspecting paths which
> > > generates a lot of risks and eventually extra complexity to work
> > > around those.  I think we really should update freezer to re-use the
> > > blocking points we already have - the ones used for signal delivery
> > > and ptracing.  That way, other code paths don't have to worry about an
> > > extra stop state and we can confine most complexities to freezer
> > > proper.
> > 
> > Also, consolidating those wait states means that we can solve the
> > event-to-response latency problem for all three cases - signal, ptrace
> > and freezer, rather than adding separate backing-out strategy for
> > freezer.
> > 
> 
> Sounds intriguing...
> 
> I'm not sure what this really means for something like NFS though. How
> would you envision this working when we have long running syscalls that
> might sit waiting in the kernel indefinitely?
> 
> Here's my blue-sky, poorly-thought-out idea...
> 
> We could add a signal (e.g. SIGFREEZE) that allows the sleeps in
> NFS/RPC layer to be interrupted. Those would return back toward
> userland with a particular type of error (sort of like ERESTARTSYS).
> 
> Before returning from the kernel though, we could freeze the process.
> When it wakes up, then we could go back down and retry the call again
> (much like an ERESTARTSYS kind of thing).

Two (three?) show stopper words for you: "non-idempotent operations".

Not all RPC calls can just be interrupted and restarted. Something like
an exclusive file create, unlink, file locking attempt, etc may give
rise to different results when replayed in the above scenario.
Interrupting an RPC call is not equivalent to cancelling its effects...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

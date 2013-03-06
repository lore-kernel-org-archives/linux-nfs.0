Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15891 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753845Ab3CFShb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 13:37:31 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Mandeep Singh Baines <msb@chromium.org>, Ingo Molnar <mingo@kernel.org>,
        Tejun Heo <tj@kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Oleg Nesterov" <oleg@redhat.com>, Ming Lei <ming.lei@canonical.com>,
        "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Thomas Gleixner <tglx@linutronix.de>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Date: Wed, 6 Mar 2013 18:37:16 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B3C74@sacexcmbx05-prd.hq.netapp.com>
References: <20130304205307.GA13527@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
	 <20130305082308.6607d4db@tlielax.poochiereds.net>
	 <20130305174648.GF12795@htj.dyndns.org>
	 <20130305174954.GG12795@htj.dyndns.org>
	 <20130305231110.GK15816@fieldses.org>
	 <CACBanvo+JDCFVRQeTQwnwRRxr8bdqxdsgeEr8fqgJhGQJEEQ-Q@mail.gmail.com>
	 <20130306010507.GL15816@fieldses.org>
	 <20130306011623.GG1227@htj.dyndns.org>
	 <CACBanvqVpi45TVNGXgXXO0BCSRuPEDsiNuHj0OBsvgr2UXZfsg@mail.gmail.com>
	 <20130306090914.GA6030@gmail.com>
	 <20130306070631.0f326014@tlielax.poochiereds.net>
	 <CACBanvo77MrvcWgVJqFjjj-7wL6BHxaoQcQ5YRfjeCtjaOeqAw@mail.gmail.com>
	 <20130306132322.52f47d7b@tlielax.poochiereds.net>
In-Reply-To: <20130306132322.52f47d7b@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-03-06 at 13:23 -0500, Jeff Layton wrote:
> On Wed, 6 Mar 2013 07:59:01 -0800
> Mandeep Singh Baines <msb@chromium.org> wrote:
> > In general, holding a lock and freezing can cause a deadlock if:
> > 
> > 1) you froze via the cgroup_freezer subsystem and a task in another
> > cgroup tried to acquire the same lock
> > 2) the lock was needed later is suspend/hibernate. For example, if the
> > lock was needed in dpm_suspend by one of the device callbacks. For
> > hibernate, you also need to worry about any locks that need to be
> > acquired in order to write to the swap device.
> > 3) another freezing task blocked on this lock and held other locks
> > needed later in suspend. If that task were skipped by the freezer, you
> > would deadlock
> > 
> > You will block/prevent suspend if:
> > 
> > 4) another freezing task blocked on this lock and was unable to freeze
> > 
> > I think 1) and 4) can happen for the NFS/RPC case. Case 1) requires
> > cgroup freezer. Case 4) while not causing a deadlock could prevent
> > your laptop/phone from sleeping and end up burning all your battery.
> > If suspend is initiated via lid close you won't even know about the
> > failure.
> > 
> 
> We're aware of #4. That was the intent of adding try_to_freeze() into
> this codepath in the first place. It's not a great solution for obvious
> reasons, but we don't have another at the moment.
> 
> For #1 I'm not sure what to do. I'm that familiar with cgroups or how
> the freezer works.
> 
> The bottom line is that we have a choice -- we can either rip out this
> new lockdep warning, or rip out the code that causes it to fire.
> 
> If we rip out the warning we may miss some legit cases where we might
> possibly have hit a deadlock.
> 
> If we rip out the code that causes it to fire, then we exacerbate the
> #4 problem above. That will effectively make it so that you can't
> suspend the host whenever NFS is doing anything moderately active.

#4 is probably the only case where we might want to freeze.

Unless we're in a situation where the network is going down, we can
usually always make progress with completing the RPC call and finishing
the system call. So in the case of cgroup_freezer, we only care if the
freezing cgroup also owns the network device (or net namespace) that NFS
is using to talk to the server.

As I said, the alternative is to notify NFS that the device is going
down, and to give it a chance to quiesce itself before that happens.
This is also the only way to ensure that processes which own locks on
the server (e.g. posix file locks) have a chance to release them before
being suspended.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

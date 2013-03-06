Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hydra.sisk.pl ([212.160.235.94]:55540 "EHLO hydra.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753616Ab3CEXzw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 18:55:52 -0500
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tejun Heo <tj@kernel.org>, Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Date: Wed, 06 Mar 2013 01:02:46 +0100
Message-ID: <5144293.t44nDELk4d@vostro.rjw.lan>
In-Reply-To: <20130305231110.GK15816@fieldses.org>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com> <20130305174954.GG12795@htj.dyndns.org> <20130305231110.GK15816@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday, March 05, 2013 06:11:10 PM J. Bruce Fields wrote:
> On Tue, Mar 05, 2013 at 09:49:54AM -0800, Tejun Heo wrote:
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
> 
> Meanwhile, as none of this sounds likely to be done this time
> around--are we backing out the new lockdep warnings?

I think we should do that.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

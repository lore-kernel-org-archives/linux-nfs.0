Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754827Ab3CGVnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Mar 2013 16:43:22 -0500
Date: Thu, 7 Mar 2013 16:43:03 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130307164303.74edf4dd@tlielax.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B5452@sacexcmbx05-prd.hq.netapp.com>
References: <20130305174954.GG12795@htj.dyndns.org>
	<20130305190923.GI12795@htj.dyndns.org>
	<20130305183941.19ff39ce@tlielax.poochiereds.net>
	<20130305234700.GE1227@htj.dyndns.org>
	<20130306181608.GA18687@redhat.com>
	<20130306185304.GM1227@htj.dyndns.org>
	<CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
	<20130306212452.GO1227@htj.dyndns.org>
	<CA+55aFy49AWptMcvEzJxg95ikf-dC+-vcCPq-cnaCCwje3tyoQ@mail.gmail.com>
	<20130306213636.GP1227@htj.dyndns.org>
	<20130307064140.71c0936b@tlielax.poochiereds.net>
	<CA+55aFxe1_x8wvVYciiX8tuee+VsmXGKqEbONQdFM4s4W2iuPg@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286B511E@sacexcmbx05-prd.hq.netapp.com>
	<CA+55aFySyBP8q5AvPrt-s_ZPdgamfoX-dERw4EJ21EcsDLBjYA@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286B52F1@sacexcmbx05-prd.hq.netapp.com>
	<CA+55aFwB4Pjki8zg9idwbQbE-TOtTdD5o8d_r1=NY3veVqmPHg@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286B5452@sacexcmbx05-prd.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 7 Mar 2013 17:16:12 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-03-07 at 09:03 -0800, Linus Torvalds wrote:
> > On Thu, Mar 7, 2013 at 8:45 AM, Myklebust, Trond
> > <Trond.Myklebust@netapp.com> wrote:
> > >
> > > The problem there is that we get into the whole 'hard' vs 'soft' mount
> > > problem. We're supposed to guarantee data integrity for 'hard' mounts,
> > > so no funny business is allowed. OTOH, 'soft' mounts time out and return
> > > EIO to the application anyway, and so shouldn't be a problem.
> > >
> > > Perhaps we could add a '-oslushy' mount option :-) that guarantees data
> > > integrity for all situations _except_ ENETDOWN/ENETUNREACH?
> > 
> > I do think we are probably over-analyzing this. It's not like people
> > who want freezing to work usually use flaky NFS. There's really two
> > main groups:
> > 
> >  - the "freezer as a snapshot mechanism" that might use NFS because
> > they are in a server environment.
> > 
> >  - the "freeezer for suspend/resume on a laptop"
> > 
> > The first one does use NFS, and cares about it, and probably would
> > prefer the freeze event to take longer and finish for all ongoing IO
> > operations. End result: just ditch the "freezable_schedule()"
> > entirely.
> > 
> > The second one is unlikely to really use NFS anyway. End result:
> > ditching the freezable_schedule() is probably perfectly fine, even if
> > it would cause suspend failures if the network is being troublesome.
> > 
> > So for now, why not just replace freezable_schedule() with plain
> > schedule() in the NFS code, and ignore it until somebody actually
> > complains about it, and then aim to try to do something more targeted
> > for that particular complaint?
> 
> We _have_ had complaints about the laptop suspension problem; that was
> why Jeff introduced freezable_schedule() in the first place. We've never
> had complaints about any problems involvinf cgroup_freeze. This is why
> our focus tends to be on the former, and why I'm more worried about
> laptop suspend regressions for any short term fixes.
> 

Right. I don't know of anyone using the cgroup_freeze stuff. OTOH, I've
seen *many* reports of people who complained because their machine
didn't suspend because of a busy NFS mount.

In fact, the problem is still not fully "solved" with the
freezable_schedule stuff we have so far anyway. Even after this
(admittedly crappy) solution went in, we still had reports of machines
that failed to suspend because other tasks were stuck in
wait_on_page_writeback() for NFS pages.

So, in principle I think we need to abandon the current approach. The
question is what should replace it.

-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13615 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754358Ab3CGRQP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2013 12:16:15 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Jeff Layton <jlayton@redhat.com>, Tejun Heo <tj@kernel.org>,
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
Date: Thu, 7 Mar 2013 17:16:12 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B5452@sacexcmbx05-prd.hq.netapp.com>
References: <20130305174954.GG12795@htj.dyndns.org>
	 <20130305140312.243cb094@tlielax.poochiereds.net>
	 <20130305190923.GI12795@htj.dyndns.org>
	 <20130305183941.19ff39ce@tlielax.poochiereds.net>
	 <20130305234700.GE1227@htj.dyndns.org> <20130306181608.GA18687@redhat.com>
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
In-Reply-To: <CA+55aFwB4Pjki8zg9idwbQbE-TOtTdD5o8d_r1=NY3veVqmPHg@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-07 at 09:03 -0800, Linus Torvalds wrote:
> On Thu, Mar 7, 2013 at 8:45 AM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
> >
> > The problem there is that we get into the whole 'hard' vs 'soft' mount
> > problem. We're supposed to guarantee data integrity for 'hard' mounts,
> > so no funny business is allowed. OTOH, 'soft' mounts time out and return
> > EIO to the application anyway, and so shouldn't be a problem.
> >
> > Perhaps we could add a '-oslushy' mount option :-) that guarantees data
> > integrity for all situations _except_ ENETDOWN/ENETUNREACH?
> 
> I do think we are probably over-analyzing this. It's not like people
> who want freezing to work usually use flaky NFS. There's really two
> main groups:
> 
>  - the "freezer as a snapshot mechanism" that might use NFS because
> they are in a server environment.
> 
>  - the "freeezer for suspend/resume on a laptop"
> 
> The first one does use NFS, and cares about it, and probably would
> prefer the freeze event to take longer and finish for all ongoing IO
> operations. End result: just ditch the "freezable_schedule()"
> entirely.
> 
> The second one is unlikely to really use NFS anyway. End result:
> ditching the freezable_schedule() is probably perfectly fine, even if
> it would cause suspend failures if the network is being troublesome.
> 
> So for now, why not just replace freezable_schedule() with plain
> schedule() in the NFS code, and ignore it until somebody actually
> complains about it, and then aim to try to do something more targeted
> for that particular complaint?

We _have_ had complaints about the laptop suspension problem; that was
why Jeff introduced freezable_schedule() in the first place. We've never
had complaints about any problems involvinf cgroup_freeze. This is why
our focus tends to be on the former, and why I'm more worried about
laptop suspend regressions for any short term fixes.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

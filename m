Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6471 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755155Ab3CGQpV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2013 11:45:21 -0500
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
Date: Thu, 7 Mar 2013 16:45:17 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B52F1@sacexcmbx05-prd.hq.netapp.com>
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
In-Reply-To: <CA+55aFySyBP8q5AvPrt-s_ZPdgamfoX-dERw4EJ21EcsDLBjYA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-07 at 08:25 -0800, Linus Torvalds wrote:
> On Thu, Mar 7, 2013 at 7:59 AM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
> >
> > It _shouldn't_ be an interruption unless the filesystem can't make
> > progress.
> 
> So how can we tell? Calling "freezable_schedule()" if you're not ready
> to be frozen is not good. And nobody but the NFS code can know.
> 
> You might want to introduce some counter that counts number of
> outstanding non-interruptible events, and only call the "freezable"
> version if that counter is zero.
> 
> A better alternative might be to *never* call the freezable version.
> Because those freezable_*() things are really quite disgusting, and
> are wrong - they don't actually freeze the process, they say "I don't
> care if you freeze me while I sleep", and you might actually wake up
> *while* the system is being frozen. I think the whole concept is
> broken. Rafaei - comments? The function really is crap, regardless of
> any unrelated NFS problems.
> 
> So what NFS could do instead is actually check the "do I need to
> freeze" flag, and if you need to freeze you consider it an abort - and
> do *not* try to continue. Just freeze, and then act as if the machine
> got rebooted as far as NFS was concerned. That should work anyway, no?
> 
> That does sound a lot more complex, though.

The problem there is that we get into the whole 'hard' vs 'soft' mount
problem. We're supposed to guarantee data integrity for 'hard' mounts,
so no funny business is allowed. OTOH, 'soft' mounts time out and return
EIO to the application anyway, and so shouldn't be a problem.

Perhaps we could add a '-oslushy' mount option :-) that guarantees data
integrity for all situations _except_ ENETDOWN/ENETUNREACH?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

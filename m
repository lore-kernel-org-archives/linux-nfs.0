Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:55264 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209Ab3CGP7b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2013 10:59:31 -0500
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
Date: Thu, 7 Mar 2013 15:59:27 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B511E@sacexcmbx05-prd.hq.netapp.com>
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
In-Reply-To: <CA+55aFxe1_x8wvVYciiX8tuee+VsmXGKqEbONQdFM4s4W2iuPg@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-07 at 07:55 -0800, Linus Torvalds wrote:
> On Thu, Mar 7, 2013 at 3:41 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >
> > I think Trond may be on the right track. We probably need some
> > mechanism to quiesce the filesystem ahead of any sort of freezer
> > event.
> 
> No, guys. That cannot work. It's a completely moronic idea. Let me
> count the way:
> 
>  (a) it's just another form of saying "lock". But since other things
> are (by definition) going on when it happens, it will just cause
> deadlocks.
> 
>  (b) the freeze event might not even be system-global. So *some*
> processes (a cgroup) might freeze, others would not. You can't shut
> off the filesystem just because some processes migth freeze.

That's the whole bloody problem in a nutshell.

We only want to freeze the filesystem when the network goes down, and in
that case we want time to clean up first. That's why it needs to be
initiated by something like NetworkManager _before_ the network is shut
down.

>  (c) it just moves the same issue somewhere else. If you have some
> operation that must be done under the lock, then such an operation
> must be completed before you've quiesced the filesystem, which is your
> whole point of that "quiesce" event. BUT THAT'S THE EXACT SAME ISSUE
> AS NOT ALLOWING THE FREEZE TO HAPPEN DURING THAT TIME.
> 
> In other words, that suggestion not only introduces new problems (a),
> it's fundamentally broken anyway (b) *AND* it doesn't even solve
> anything, it just moves it around.
> 
> The solution is damn simple: if you're in some kind of "atomic
> region", then you cannot freeze. Seriously. SO DON'T CALL
> "freezable_schedule()", FOR CHRISSAKE! You clearly aren't freezable!
> 
> Which is exactly what the new lockdep warning was all about. Don't try
> to move the problem around, when it's quite clear where the problem
> is. If you need to do something uninterruptible, you do not say "oh,
> I'm freezable". Because freezing is by definition an interruption.
> Seriously, it's that simple.

It _shouldn't_ be an interruption unless the filesystem can't make
progress.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

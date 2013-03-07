Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:60585 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab3CGPzl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2013 10:55:41 -0500
MIME-Version: 1.0
In-Reply-To: <20130307064140.71c0936b@tlielax.poochiereds.net>
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
	<20130307064140.71c0936b@tlielax.poochiereds.net>
Date: Thu, 7 Mar 2013 07:55:39 -0800
Message-ID: <CA+55aFxe1_x8wvVYciiX8tuee+VsmXGKqEbONQdFM4s4W2iuPg@mail.gmail.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 7, 2013 at 3:41 AM, Jeff Layton <jlayton@redhat.com> wrote:
>
> I think Trond may be on the right track. We probably need some
> mechanism to quiesce the filesystem ahead of any sort of freezer
> event.

No, guys. That cannot work. It's a completely moronic idea. Let me
count the way:

 (a) it's just another form of saying "lock". But since other things
are (by definition) going on when it happens, it will just cause
deadlocks.

 (b) the freeze event might not even be system-global. So *some*
processes (a cgroup) might freeze, others would not. You can't shut
off the filesystem just because some processes migth freeze.

 (c) it just moves the same issue somewhere else. If you have some
operation that must be done under the lock, then such an operation
must be completed before you've quiesced the filesystem, which is your
whole point of that "quiesce" event. BUT THAT'S THE EXACT SAME ISSUE
AS NOT ALLOWING THE FREEZE TO HAPPEN DURING THAT TIME.

In other words, that suggestion not only introduces new problems (a),
it's fundamentally broken anyway (b) *AND* it doesn't even solve
anything, it just moves it around.

The solution is damn simple: if you're in some kind of "atomic
region", then you cannot freeze. Seriously. SO DON'T CALL
"freezable_schedule()", FOR CHRISSAKE! You clearly aren't freezable!

Which is exactly what the new lockdep warning was all about. Don't try
to move the problem around, when it's quite clear where the problem
is. If you need to do something uninterruptible, you do not say "oh,
I'm freezable". Because freezing is by definition an interruption.
Seriously, it's that simple.

                Linus

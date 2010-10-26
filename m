Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59315 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754836Ab0JZVot (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 17:44:49 -0400
Date: Tue, 26 Oct 2010 17:44:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Bryan Schumaker <bjschuma@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101026214441.GC1842@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <201010262218.36940.arnd@arndb.de>
 <4CC73BA6.1090407@netapp.com>
 <201010262255.40481.arnd@arndb.de>
 <AANLkTimPBqafDPxYpZjuym8+-yk4vKYTU15Js-Ux_e6Z@mail.gmail.com>
 <20101026212433.GB1842@fieldses.org>
 <AANLkTinOd9pDVRYDQ5+dqn8LPf4yoOW=j8NxyCfCQAB6@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTinOd9pDVRYDQ5+dqn8LPf4yoOW=j8NxyCfCQAB6@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 02:37:26PM -0700, Linus Torvalds wrote:
> On Tue, Oct 26, 2010 at 2:24 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > I did a couple connectathon runs just now with no obvious ill effects
> > except for some sleep-within-spinlock warnings in the lease code.
> 
> Hmm. Those sleep-within-spinlock warnings are very likely serious
> bugs.

Yeah, didn't mean to belittle them.

> Can you quote the whole warning with stack trace?

It's just obvious allocations in setlease:

BUG: sleeping function called from invalid context at mm/slab.c:3101
in_atomic(): 1, irqs_disabled(): 0, pid: 4345, name: lease_tests
1 lock held by lease_tests/4345:
 #0:  (file_lock_lock){+.+.+.}, at: [<ffffffff81128be5>] lock_flocks+0x15/0x20
Pid: 4345, comm: lease_tests Not tainted 2.6.36-05858-gbd5e20b #1028
Call Trace:
 [<ffffffff8103141d>] __might_sleep+0x10d/0x140
 [<ffffffff810e3ad3>] kmem_cache_alloc+0x1f3/0x230
 [<ffffffff8112a4d2>] generic_setlease+0x112/0x2c0
 [<ffffffff8112a6b5>] __vfs_setlease+0x35/0x40
 [<ffffffff8112acfe>] fcntl_setlease+0xce/0x180
 [<ffffffff810f7c2e>] sys_fcntl+0x2fe/0x630
 [<ffffffff81961999>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81002658>] system_call_fastpath+0x16/0x1b

I'm testing a patch.

--b.

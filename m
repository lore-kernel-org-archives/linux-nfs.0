Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:37322 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbaFBWmF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 18:42:05 -0400
Received: by mail-vc0-f180.google.com with SMTP id hq11so3841756vcb.25
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jun 2014 15:42:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALAqxLVmRdv3eVaf_ue-NutDmjxJA2NNAXnH-Tm4a6ud2U7Q4g@mail.gmail.com>
References: <20140602104948.4faf0bc2@tlielax.poochiereds.net>
	<CAHQdGtRR6SvEhXiqWo24hoUh9AU9cL82Z8Z-d8-7u951F_d+5g@mail.gmail.com>
	<CALAqxLVmRdv3eVaf_ue-NutDmjxJA2NNAXnH-Tm4a6ud2U7Q4g@mail.gmail.com>
Date: Mon, 2 Jun 2014 18:42:03 -0400
Message-ID: <CAHQdGtSn9RwdgaFgEDQXjrxSA_Bg=rNWux+96-5f43dyUwXLRw@mail.gmail.com>
Subject: Re: nfs4_do_reclaim lockdep pop in v3.15.0-rc1
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: John Stultz <john.stultz@linaro.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 2, 2014 at 6:12 PM, John Stultz <john.stultz@linaro.org> wrote:
> On Mon, Jun 2, 2014 at 9:02 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Mon, Jun 2, 2014 at 10:49 AM, Jeff Layton
>> <jeff.layton@primarydata.com> wrote:
>>> I've been working on the patchset to break up the client_mutex in nfsd.
>>> While doing some debugging, I had mounted my kernel git tree with
>>> NFSv4.1, and was running crash on the vmlinux image in it.
>>>
>>> A little while later, I saw the following lockdep inversion pop.
>>> Unfortunately, I couldn't get the whole log, but I think it's enough to
>>> show that there's a potential problem?
>>>
>>> I've not had time to give it a hard look yet, but thought I'd post it
>>> here in the hopes that it might look familiar to someone:
>>>
>>> [ 2581.104687] ======================================================
>>> [ 2581.104716] [ INFO: possible circular locking dependency detected ]
>>> [ 2581.104716] 3.15.0-rc1.jlayton.1+ #2 Tainted: G           OE
>>> [ 2581.104716] -------------------------------------------------------
>>> [ 2581.104716] 2001:470:8:d63:/5622 is trying to acquire lock:
>>> [ 2581.104716]  (&(&sp->so_lock)->rlock){+.+...}, at: [<ffffffffa036dbdd>] nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
>>> [ 2581.104716]
>>> [ 2581.104716] but task is already holding lock:
>>> [ 2581.104716]  (&sp->so_reclaim_seqcount){+.+...}, at: [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
>>> [ 2581.104716]
>>> [ 2581.104716] which lock already depends on the new lock.
>>> [ 2581.104716]
>>> [ 2581.104716]
>>> [ 2581.104716] the existing dependency chain (in reverse order) is:
>>> [ 2581.104716]
>>> -> #1 (&sp->so_reclaim_seqcount){+.+...}:
>>> [ 2581.104716]        [<ffffffff810f9aa2>] lock_acquire+0xa2/0x1d0
>>> [ 2581.104716]        [<ffffffffa036d8b0>] nfs4_do_reclaim+0x290/0x7f0 [nfsv4]
>>> [ 2581.104716]        [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
>>> [ 2581.104716]        [<ffffffff810c260f>] kthread+0xff/0x120
>>> [ 2581.104716]        [<ffffffff817e6bfc>] ret_from_fork+0x7c/0xb0
>>> [ 2581.104716]
>>> -> #0 (&(&sp->so_lock)->rlock){+.+...}:
>>> [ 2581.104716]        [<ffffffff810f919f>] __lock_acquire+0x1b8f/0x1ca0
>>> [ 2581.104716]        [<ffffffff810f9aa2>] lock_acquire+0xa2/0x1d0
>>> [ 2581.104716]        [<ffffffff817dbdae>] _raw_spin_lock+0x3e/0x80
>>> [ 2581.104716]        [<ffffffffa036dbdd>] nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
>>> [ 2581.104716]        [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
>>> [ 2581.104716]        [<ffffffff810c260f>] kthread+0xff/0x120
>>> [ 2581.104716]        [<ffffffff817e6bfc>] ret_from_fork+0x7c/0xb0
>>> [ 2581.104716]
>>> [ 2581.104716] other info that might help us debug this:
>>> [ 2581.104716]
>>> [ 2581.104716]  Possible unsafe locking scenario:
>>> [ 2581.104716]
>>> [ 2581.104716]        CPU0                    CPU1
>>> [ 2581.104716]        ----                    ----
>>> [ 2581.104716]   lock(&sp->so_reclaim_seqcount);
>>> [ 2581.104716]                                lock(&(&sp->so_lock)->rlock);
>>> [ 2581.104716]                                lock(&sp->so_reclaim_seqcount);
>>> [ 2581.104716]   lock(&(&sp->so_lock)->rlock);
>>> [ 2581.104716]
>>> [ 2581.104716]  *** DEADLOCK ***
>>> [ 2581.104716]
>>> [ 2581.104716] 1 lock held by 2001:470:8:d63:/5622:
>>> [ 2581.104716]  #0:  (&sp->so_reclaim_seqcount){+.+...}, at: [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
>>> [ 2581.104716]
>>> [ 2581.104716] stack backtrace:
>>> [ 2581.104716] CPU: 2 PID: 5622 Comm: 2001:470:8:d63: Tainted: G           OE 3.15.0-rc1.jlayton.1+ #2
>>> [ 2581.104716] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>>> [ 2581.104716]  0000000000000000 00000000d29e16c4 ffff8800d8d8fba8 ffffffff817d318e
>>> [ 2581.104716]  ffffffff8262d5e0 ffff8800d8d8fbe8 ffffffff817ce525 ffff8800d8d8fc40
>>> [ 2581.104716]  ffff8800362a8b98 ffff8800362a8b98 0000000000000001 ffff8800362a8000
>>> [ 2581.104716] Call Trace:
>>> [ 2581.104716]  [<ffffffff817d318e>] dump_stack+0x4d/0x66
>>> [ 2581.104716]  [<ffffffff817ce525>] print_circular_bug+0x201/0x20f
>>> [ 2581.104716]  [<ffffffff810f919f>] __lock_acquire+0x1b8f/0x1ca0
>>> [ 2581.104716]  [<ffffffff813dbe9e>] ? debug_check_no_obj_freed+0x17e/0x270
>>> [ 2581.104716]  [<ffffffff810f9aa2>] lock_acquire+0xa2/0x1d0
>>> [ 2581.104716]  [<ffffffffa036dbdd>] ? nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
>>> [ 2581.104716]  [<ffffffff817dbdae>] _raw_spin_lock+0x3e/0x80
>>> [ 2581.104716]  [<ffffffffa036dbdd>] ? nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
>>> [ 2581.104716]  [<ffffffffa036dbdd>] nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
>>> [ 2581.104716]  [<ffffffffa036e5fe>] ? nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
>>> [ 2581.104716]  [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
>>> [ 2581.104716]  [<ffffffffa036de10>] ? nfs4_do_reclaim+0x7f0/0x7f0 [nfsv4]
>>> [ 2581.104716]  [<ffffffff810c260f>] kthread+0xff/0x120
>>> [ 2581.104716]  [<ffffffff810c2510>] ? insert_kthread_work+0x80/0x80
>>> [ 2581.104716]  [<ffffffff817e6bfc>] ret_from_fork+0x7c/0xb0
>>> [ 2581.104716]  [<ffffffff810c2510>] ? insert_kthread_work+0x80/0x80
>>
>> OK. So now that lockdep has been added to raw_seqcount_begin() (commit
>> 1ca7d67cf5d5a), exactly what are we supposed to use when we DON'T want
>> lockdep to "sanity check" our locking here?
>
> So raw_write_seqcount_*  provides the lockdep-disabled methods.
>
>> As far as we're concerned, the above check is completely bogus, and
>> there is no deadlock. At best it would be a livelock, and it would be
>> because the server is rebooting over and over again (in which case the
>> client behaviour of retrying is _correct_).
>
> I've not been able to totally trace the locking path there, but having
> a seqlock writes and spinlock ABBA deadlock seems problematic.... at
> least at first glance.
>
> So if I'm reading this right...  nfs4_reclaim_open_state() takes a
> spinlock on so_lock, then the write on the so_reclaim_seqcount, then
> drops the so_lock and calls nfs4_put_open_state which reaquires the
> so_lock.
>
> And lockdep is worried there may be another thread which called into
> nfs4_reclaim_open_state() and took the so_lock while it was
> momentarily free, and is blocking waiting on the so_reclaim_seqcount.
> This would cause the first threads requisition of the so_lock to
> potentially deadlock.
>
> And your point is that this isn't a concern since no other threads can
> call nfs4_reclaim_open_state() or any other code path that acquires
> those two locks in order?  If you're going to disable the lockdep
> checks here, you might want to make this restriction really clear in a
> comment so no one accidentally breaks that rule.
>

It's a general rule in the NFSv4 client that the only thread that is
allowed to call state recovery functions (after a server reboot or a
long-lived network partition) is the state manager thread. That
applies to _all_ state, not just open state.

The so_reclaim_seqcount only exists in order to tell the other threads
that they may need to replay file open or file lock requests that have
raced with state recovery (because those threads got scheduled out
after their RPC calls ran, but before they managed to set up the
tracking of the new state). It is basically an edge condition
killer...

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

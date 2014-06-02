Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:42914 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbaFBQC3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 12:02:29 -0400
Received: by mail-vc0-f179.google.com with SMTP id ij19so868047vcb.10
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jun 2014 09:02:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140602104948.4faf0bc2@tlielax.poochiereds.net>
References: <20140602104948.4faf0bc2@tlielax.poochiereds.net>
Date: Mon, 2 Jun 2014 12:02:28 -0400
Message-ID: <CAHQdGtRR6SvEhXiqWo24hoUh9AU9cL82Z8Z-d8-7u951F_d+5g@mail.gmail.com>
Subject: Re: nfs4_do_reclaim lockdep pop in v3.15.0-rc1
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>,
        John Stultz <john.stultz@linaro.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 2, 2014 at 10:49 AM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
> I've been working on the patchset to break up the client_mutex in nfsd.
> While doing some debugging, I had mounted my kernel git tree with
> NFSv4.1, and was running crash on the vmlinux image in it.
>
> A little while later, I saw the following lockdep inversion pop.
> Unfortunately, I couldn't get the whole log, but I think it's enough to
> show that there's a potential problem?
>
> I've not had time to give it a hard look yet, but thought I'd post it
> here in the hopes that it might look familiar to someone:
>
> [ 2581.104687] ======================================================
> [ 2581.104716] [ INFO: possible circular locking dependency detected ]
> [ 2581.104716] 3.15.0-rc1.jlayton.1+ #2 Tainted: G           OE
> [ 2581.104716] -------------------------------------------------------
> [ 2581.104716] 2001:470:8:d63:/5622 is trying to acquire lock:
> [ 2581.104716]  (&(&sp->so_lock)->rlock){+.+...}, at: [<ffffffffa036dbdd>] nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
> [ 2581.104716]
> [ 2581.104716] but task is already holding lock:
> [ 2581.104716]  (&sp->so_reclaim_seqcount){+.+...}, at: [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
> [ 2581.104716]
> [ 2581.104716] which lock already depends on the new lock.
> [ 2581.104716]
> [ 2581.104716]
> [ 2581.104716] the existing dependency chain (in reverse order) is:
> [ 2581.104716]
> -> #1 (&sp->so_reclaim_seqcount){+.+...}:
> [ 2581.104716]        [<ffffffff810f9aa2>] lock_acquire+0xa2/0x1d0
> [ 2581.104716]        [<ffffffffa036d8b0>] nfs4_do_reclaim+0x290/0x7f0 [nfsv4]
> [ 2581.104716]        [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
> [ 2581.104716]        [<ffffffff810c260f>] kthread+0xff/0x120
> [ 2581.104716]        [<ffffffff817e6bfc>] ret_from_fork+0x7c/0xb0
> [ 2581.104716]
> -> #0 (&(&sp->so_lock)->rlock){+.+...}:
> [ 2581.104716]        [<ffffffff810f919f>] __lock_acquire+0x1b8f/0x1ca0
> [ 2581.104716]        [<ffffffff810f9aa2>] lock_acquire+0xa2/0x1d0
> [ 2581.104716]        [<ffffffff817dbdae>] _raw_spin_lock+0x3e/0x80
> [ 2581.104716]        [<ffffffffa036dbdd>] nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
> [ 2581.104716]        [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
> [ 2581.104716]        [<ffffffff810c260f>] kthread+0xff/0x120
> [ 2581.104716]        [<ffffffff817e6bfc>] ret_from_fork+0x7c/0xb0
> [ 2581.104716]
> [ 2581.104716] other info that might help us debug this:
> [ 2581.104716]
> [ 2581.104716]  Possible unsafe locking scenario:
> [ 2581.104716]
> [ 2581.104716]        CPU0                    CPU1
> [ 2581.104716]        ----                    ----
> [ 2581.104716]   lock(&sp->so_reclaim_seqcount);
> [ 2581.104716]                                lock(&(&sp->so_lock)->rlock);
> [ 2581.104716]                                lock(&sp->so_reclaim_seqcount);
> [ 2581.104716]   lock(&(&sp->so_lock)->rlock);
> [ 2581.104716]
> [ 2581.104716]  *** DEADLOCK ***
> [ 2581.104716]
> [ 2581.104716] 1 lock held by 2001:470:8:d63:/5622:
> [ 2581.104716]  #0:  (&sp->so_reclaim_seqcount){+.+...}, at: [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
> [ 2581.104716]
> [ 2581.104716] stack backtrace:
> [ 2581.104716] CPU: 2 PID: 5622 Comm: 2001:470:8:d63: Tainted: G           OE 3.15.0-rc1.jlayton.1+ #2
> [ 2581.104716] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [ 2581.104716]  0000000000000000 00000000d29e16c4 ffff8800d8d8fba8 ffffffff817d318e
> [ 2581.104716]  ffffffff8262d5e0 ffff8800d8d8fbe8 ffffffff817ce525 ffff8800d8d8fc40
> [ 2581.104716]  ffff8800362a8b98 ffff8800362a8b98 0000000000000001 ffff8800362a8000
> [ 2581.104716] Call Trace:
> [ 2581.104716]  [<ffffffff817d318e>] dump_stack+0x4d/0x66
> [ 2581.104716]  [<ffffffff817ce525>] print_circular_bug+0x201/0x20f
> [ 2581.104716]  [<ffffffff810f919f>] __lock_acquire+0x1b8f/0x1ca0
> [ 2581.104716]  [<ffffffff813dbe9e>] ? debug_check_no_obj_freed+0x17e/0x270
> [ 2581.104716]  [<ffffffff810f9aa2>] lock_acquire+0xa2/0x1d0
> [ 2581.104716]  [<ffffffffa036dbdd>] ? nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
> [ 2581.104716]  [<ffffffff817dbdae>] _raw_spin_lock+0x3e/0x80
> [ 2581.104716]  [<ffffffffa036dbdd>] ? nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
> [ 2581.104716]  [<ffffffffa036dbdd>] nfs4_do_reclaim+0x5bd/0x7f0 [nfsv4]
> [ 2581.104716]  [<ffffffffa036e5fe>] ? nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
> [ 2581.104716]  [<ffffffffa036e5fe>] nfs4_run_state_manager+0x7ee/0xc00 [nfsv4]
> [ 2581.104716]  [<ffffffffa036de10>] ? nfs4_do_reclaim+0x7f0/0x7f0 [nfsv4]
> [ 2581.104716]  [<ffffffff810c260f>] kthread+0xff/0x120
> [ 2581.104716]  [<ffffffff810c2510>] ? insert_kthread_work+0x80/0x80
> [ 2581.104716]  [<ffffffff817e6bfc>] ret_from_fork+0x7c/0xb0
> [ 2581.104716]  [<ffffffff810c2510>] ? insert_kthread_work+0x80/0x80

OK. So now that lockdep has been added to raw_seqcount_begin() (commit
1ca7d67cf5d5a), exactly what are we supposed to use when we DON'T want
lockdep to "sanity check" our locking here?

As far as we're concerned, the above check is completely bogus, and
there is no deadlock. At best it would be a livelock, and it would be
because the server is rebooting over and over again (in which case the
client behaviour of retrying is _correct_).

Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

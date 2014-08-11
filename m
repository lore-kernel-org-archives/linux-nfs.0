Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:59303 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbaHKLuP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 07:50:15 -0400
Received: by mail-qc0-f182.google.com with SMTP id i8so1483609qcq.27
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2014 04:50:15 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 11 Aug 2014 07:50:13 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/3] nfs4: queue free_lock_state job submission to
 nfsiod
Message-ID: <20140811075013.77e0a29e@tlielax.poochiereds.net>
In-Reply-To: <20140811104253.GA4747@infradead.org>
References: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
	<1398940127-31150-3-git-send-email-jlayton@poochiereds.net>
	<20140811104253.GA4747@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Aug 2014 03:42:53 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> This seems to introduce a fairly easily reproducible oops, which I can
> reproduce when running xfstests against a Linux NFSv4.1 server:
> 
> generic/089 242s ...[ 2187.041239] general protection fault: 0000 [#1]
> SMP 
> [ 2187.042899] Modules linked in:
> [ 2187.044000] CPU: 0 PID: 11913 Comm: kworker/0:1 Not tainted 3.16.0-rc6+ #1151
> [ 2187.044287] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [ 2187.044287] Workqueue: nfsiod free_lock_state_work
> [ 2187.044287] task: ffff880072b50cd0 ti: ffff88007a4ec000 task.ti: ffff88007a4ec000
> [ 2187.044287] RIP: 0010:[<ffffffff81361ca6>]  [<ffffffff81361ca6>] free_lock_state_work+0x16/0x30
> [ 2187.044287] RSP: 0018:ffff88007a4efd58  EFLAGS: 00010296
> [ 2187.044287] RAX: 6b6b6b6b6b6b6b6b RBX: ffff88007a947ac0 RCX: 8000000000000000
> [ 2187.044287] RDX: ffffffff826af9e0 RSI: ffff88007b093c00 RDI: ffff88007b093db8
> [ 2187.044287] RBP: ffff88007a4efd58 R08: ffffffff832d3e10 R09: 000001c40efc0000
> [ 2187.044287] R10: 0000000000000000 R11: 0000000000059e30 R12: ffff88007fc13240
> [ 2187.044287] R13: ffff88007fc18b00 R14: ffff88007b093db8 R15: 0000000000000000
> [ 2187.044287] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
> [ 2187.044287] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 2187.044287] CR2: 00007f93ec33fb80 CR3: 0000000079dc2000 CR4: 00000000000006f0
> [ 2187.044287] Stack:
> [ 2187.044287]  ffff88007a4efdd8 ffffffff810cc877 ffffffff810cc80d ffff88007fc13258
> [ 2187.044287]  000000007a947af0 0000000000000000 ffffffff8353ccc8 ffffffff82b6f3d0
> [ 2187.044287]  0000000000000000 ffffffff82267679 ffff88007a4efdd8 ffff88007fc13240
> [ 2187.044287] Call Trace:
> [ 2187.044287]  [<ffffffff810cc877>] process_one_work+0x1c7/0x490
> [ 2187.044287]  [<ffffffff810cc80d>] ? process_one_work+0x15d/0x490
> [ 2187.044287]  [<ffffffff810cd569>] worker_thread+0x119/0x4f0
> [ 2187.044287]  [<ffffffff810fbbad>] ? trace_hardirqs_on+0xd/0x10
> [ 2187.044287]  [<ffffffff810cd450>] ? init_pwq+0x190/0x190
> [ 2187.044287]  [<ffffffff810d3c6f>] kthread+0xdf/0x100
> [ 2187.044287]  [<ffffffff810d3b90>] ? __init_kthread_worker+0x70/0x70
> [ 2187.044287]  [<ffffffff81d9873c>] ret_from_fork+0x7c/0xb0
> [ 2187.044287]  [<ffffffff810d3b90>] ? __init_kthread_worker+0x70/0x70
> [ 2187.044287] Code: 0f 1f 44 00 00 31 c0 5d c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8d b7 48 fe ff ff 48 8b 87 58 fe ff ff 48 89 e5 48 8b 40 30 <48> 8b 00 48 8b 10 48 89 c7 48 8b 92 90 03 00 00 ff 52 28 5d c3 
> [ 2187.044287] RIP  [<ffffffff81361ca6>] free_lock_state_work+0x16/0x30
> [ 2187.044287]  RSP <ffff88007a4efd58>
> [ 2187.103626] ---[ end trace 0f11326d28e5d8fa ]---
> 
> seems like this happens when trying to derefence the state owner in
> the work queue:
> 
> (gdb) l *(free_lock_state_work+0x16)
> 0xffffffff81361ca6 is in free_lock_state_work (fs/nfs/nfs4state.c:808).
> 803	free_lock_state_work(struct work_struct *work)
> 804	{
> 805		struct nfs4_lock_state *lsp = container_of(work,
> 806						struct nfs4_lock_state,
> ls_release);
> 807		struct nfs4_state *state = lsp->ls_state;
> 808		struct nfs_server *server = state->owner->so_server;
> 809		struct nfs_client *clp = server->nfs_client;
> 810	
> 811		clp->cl_mvops->free_lock_state(server, lsp);
> 812	}
> 

Thanks for the report, Christoph.

I suspect what's happening is that the lock state is outliving the open
state that it's associated with. That does look to be possible now that
we're queueing ->free_lock_state to a workqueue.

It looks like the simplest fix would be to have a lock state hold a
reference to the open state, but that could be problematic too. The
open stateid holds an inode reference, but not necessarily one to the
superblock. I think you could end up closing a file and unmounting
before the work runs.

Mostly we just need the server pointer which implies that we need to
pin the superblock somehow until the workqueue job is done. Should we
just add a sb pointer to nfs4_lock_state, and call nfs_sb_active before
queueing the work and then call nfs_sb_deactive on completion?

-- 
Jeff Layton <jlayton@primarydata.com>

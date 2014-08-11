Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55109 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692AbaHKPJZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 11:09:25 -0400
Date: Mon, 11 Aug 2014 08:09:24 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/3] nfs4: queue free_lock_state job submission to
 nfsiod
Message-ID: <20140811150924.GA3683@infradead.org>
References: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
 <1398940127-31150-3-git-send-email-jlayton@poochiereds.net>
 <20140811104253.GA4747@infradead.org>
 <20140811075013.77e0a29e@tlielax.poochiereds.net>
 <20140811090417.0287b32b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140811090417.0287b32b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I managed to hit a similar but different issue with your patch applied (note
the slab poisoning pattern in rax):

generic/089 409s ...[  399.057379] general protection fault: 0000 [#1]
SMP 
[  399.059137] Modules linked in:
[  399.060089] CPU: 2 PID: 4367 Comm: kworker/2:2 Not tainted 3.16.0-rc6+ #1153
[  399.060617] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  399.060617] Workqueue: nfsiod free_lock_state_work
[  399.060617] task: ffff88007ab68810 ti: ffff88007c3b4000 task.ti: ffff88007c3b4000
[  399.060617] RIP: 0010:[<ffffffff8134e5bb>]  [<ffffffff8134e5bb>] nfs41_free_lock_state+0x2b/0x70
[  399.060617] RSP: 0018:ffff88007c3b7d18  EFLAGS: 00010286
[  399.060617] RAX: 6b6b6b6b6b6b6b6b RBX: ffff88007cdd3800 RCX: 0000000000000000
[  399.060617] RDX: ffffffff81e04c60 RSI: ffff88007cdd39a0 RDI: ffff880079e5a000
[  399.060617] RBP: ffff88007c3b7d38 R08: ffffffff832df6d0 R09: 000001c90f100000
[  399.060617] R10: 0000000000000000 R11: 00000000000656f0 R12: ffff880079e5a000
[  399.060617] R13: ffff88007fd18b00 R14: ffff88007cdd39c0 R15: 0000000000000000
[  399.060617] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
[  399.060617] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  399.060617] CR2: 00007f5ac2f56800 CR3: 000000007a95b000 CR4: 00000000000006e0
[  399.060617] Stack:
[  399.060617]  000000007fd13240 ffff88007a8f7800 ffff88007fd13240 ffff88007fd18b00
[  399.060617]  ffff88007c3b7d58 ffffffff813621ae ffff88007cdd39c0 ffff88007a4d0c40
[  399.060617]  ffff88007c3b7dd8 ffffffff810cc877 ffffffff810cc80d ffff88007fd13258
[  399.060617] Call Trace:
[  399.060617]  [<ffffffff813621ae>] free_lock_state_work+0x2e/0x40
[  399.060617]  [<ffffffff810cc877>] process_one_work+0x1c7/0x490
[  399.060617]  [<ffffffff810cc80d>] ? process_one_work+0x15d/0x490
[  399.060617]  [<ffffffff810cd569>] worker_thread+0x119/0x4f0
[  399.060617]  [<ffffffff810fbbad>] ? trace_hardirqs_on+0xd/0x10
[  399.060617]  [<ffffffff810cd450>] ? init_pwq+0x190/0x190
[  399.060617]  [<ffffffff810d3c6f>] kthread+0xdf/0x100
[  399.060617]  [<ffffffff810d3b90>] ? __init_kthread_worker+0x70/0x70
[  399.060617]  [<ffffffff81d9873c>] ret_from_fork+0x7c/0xb0
[  399.060617]  [<ffffffff810d3b90>] ? __init_kthread_worker+0x70/0x70

(gdb) l *(nfs41_free_lock_state+0x2b)
0xffffffff8134e5bb is in nfs41_free_lock_state (fs/nfs/nfs4proc.c:8313).
8308	nfs41_free_lock_state(struct nfs_server *server, struct
nfs4_lock_state *lsp)
8309	{
8310		struct rpc_task *task;
8311		struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
8312	
8313		task = _nfs41_free_stateid(server, &lsp->ls_stateid,
cred, false);
8314		nfs4_free_lock_state(server, lsp);
8315		if (IS_ERR(task))
8316			return;
8317		rpc_put_task(task);


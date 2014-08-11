Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:39160 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914AbaHKPgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 11:36:00 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so7707071qaq.38
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2014 08:35:59 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 11 Aug 2014 11:35:57 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/3] nfs4: queue free_lock_state job submission to
 nfsiod
Message-ID: <20140811113557.692d408b@tlielax.poochiereds.net>
In-Reply-To: <20140811150924.GA3683@infradead.org>
References: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
	<1398940127-31150-3-git-send-email-jlayton@poochiereds.net>
	<20140811104253.GA4747@infradead.org>
	<20140811075013.77e0a29e@tlielax.poochiereds.net>
	<20140811090417.0287b32b@tlielax.poochiereds.net>
	<20140811150924.GA3683@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Aug 2014 08:09:24 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> 
> I managed to hit a similar but different issue with your patch applied (note
> the slab poisoning pattern in rax):
> 
> generic/089 409s ...[  399.057379] general protection fault: 0000 [#1]
> SMP 
> [  399.059137] Modules linked in:
> [  399.060089] CPU: 2 PID: 4367 Comm: kworker/2:2 Not tainted 3.16.0-rc6+ #1153
> [  399.060617] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [  399.060617] Workqueue: nfsiod free_lock_state_work
> [  399.060617] task: ffff88007ab68810 ti: ffff88007c3b4000 task.ti: ffff88007c3b4000
> [  399.060617] RIP: 0010:[<ffffffff8134e5bb>]  [<ffffffff8134e5bb>] nfs41_free_lock_state+0x2b/0x70
> [  399.060617] RSP: 0018:ffff88007c3b7d18  EFLAGS: 00010286
> [  399.060617] RAX: 6b6b6b6b6b6b6b6b RBX: ffff88007cdd3800 RCX: 0000000000000000
> [  399.060617] RDX: ffffffff81e04c60 RSI: ffff88007cdd39a0 RDI: ffff880079e5a000
> [  399.060617] RBP: ffff88007c3b7d38 R08: ffffffff832df6d0 R09: 000001c90f100000
> [  399.060617] R10: 0000000000000000 R11: 00000000000656f0 R12: ffff880079e5a000
> [  399.060617] R13: ffff88007fd18b00 R14: ffff88007cdd39c0 R15: 0000000000000000
> [  399.060617] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
> [  399.060617] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  399.060617] CR2: 00007f5ac2f56800 CR3: 000000007a95b000 CR4: 00000000000006e0
> [  399.060617] Stack:
> [  399.060617]  000000007fd13240 ffff88007a8f7800 ffff88007fd13240 ffff88007fd18b00
> [  399.060617]  ffff88007c3b7d58 ffffffff813621ae ffff88007cdd39c0 ffff88007a4d0c40
> [  399.060617]  ffff88007c3b7dd8 ffffffff810cc877 ffffffff810cc80d ffff88007fd13258
> [  399.060617] Call Trace:
> [  399.060617]  [<ffffffff813621ae>] free_lock_state_work+0x2e/0x40
> [  399.060617]  [<ffffffff810cc877>] process_one_work+0x1c7/0x490
> [  399.060617]  [<ffffffff810cc80d>] ? process_one_work+0x15d/0x490
> [  399.060617]  [<ffffffff810cd569>] worker_thread+0x119/0x4f0
> [  399.060617]  [<ffffffff810fbbad>] ? trace_hardirqs_on+0xd/0x10
> [  399.060617]  [<ffffffff810cd450>] ? init_pwq+0x190/0x190
> [  399.060617]  [<ffffffff810d3c6f>] kthread+0xdf/0x100
> [  399.060617]  [<ffffffff810d3b90>] ? __init_kthread_worker+0x70/0x70
> [  399.060617]  [<ffffffff81d9873c>] ret_from_fork+0x7c/0xb0
> [  399.060617]  [<ffffffff810d3b90>] ? __init_kthread_worker+0x70/0x70
> 
> (gdb) l *(nfs41_free_lock_state+0x2b)
> 0xffffffff8134e5bb is in nfs41_free_lock_state (fs/nfs/nfs4proc.c:8313).
> 8308	nfs41_free_lock_state(struct nfs_server *server, struct
> nfs4_lock_state *lsp)
> 8309	{
> 8310		struct rpc_task *task;
> 8311		struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
> 8312	
> 8313		task = _nfs41_free_stateid(server, &lsp->ls_stateid,
> cred, false);
> 8314		nfs4_free_lock_state(server, lsp);
> 8315		if (IS_ERR(task))
> 8316			return;
> 8317		rpc_put_task(task);
> 

Oof -- right. Same problem, just in a different spot. So there, we need
the openowner. We don't have a pointer directly to that, so we're
probably best off just holding a reference to the open stateid, and
pinning the superblock too.

Maybe something like this instead? I'm also running xfstests on a VM
now to see if I can reproduce this and verify the fix:

---------------------[snip]-----------------------

[PATCH] nfs: pin superblock and open state when running free_lock_state operations

Christoph reported seeing this oops when running xfstests on a v4.1 client:

generic/089 242s ...[ 2187.041239] general protection fault: 0000 [#1] SMP
[ 2187.042899] Modules linked in:
[ 2187.044000] CPU: 0 PID: 11913 Comm: kworker/0:1 Not tainted 3.16.0-rc6+ #1151
[ 2187.044287] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[ 2187.044287] Workqueue: nfsiod free_lock_state_work
[ 2187.044287] task: ffff880072b50cd0 ti: ffff88007a4ec000 task.ti: ffff88007a4ec000
[ 2187.044287] RIP: 0010:[<ffffffff81361ca6>]  [<ffffffff81361ca6>] free_lock_state_work+0x16/0x30
[ 2187.044287] RSP: 0018:ffff88007a4efd58  EFLAGS: 00010296
[ 2187.044287] RAX: 6b6b6b6b6b6b6b6b RBX: ffff88007a947ac0 RCX: 8000000000000000
[ 2187.044287] RDX: ffffffff826af9e0 RSI: ffff88007b093c00 RDI: ffff88007b093db8
[ 2187.044287] RBP: ffff88007a4efd58 R08: ffffffff832d3e10 R09: 000001c40efc0000
[ 2187.044287] R10: 0000000000000000 R11: 0000000000059e30 R12: ffff88007fc13240
[ 2187.044287] R13: ffff88007fc18b00 R14: ffff88007b093db8 R15: 0000000000000000
[ 2187.044287] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[ 2187.044287] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2187.044287] CR2: 00007f93ec33fb80 CR3: 0000000079dc2000 CR4: 00000000000006f0
[ 2187.044287] Stack:
[ 2187.044287]  ffff88007a4efdd8 ffffffff810cc877 ffffffff810cc80d ffff88007fc13258
[ 2187.044287]  000000007a947af0 0000000000000000 ffffffff8353ccc8 ffffffff82b6f3d0
[ 2187.044287]  0000000000000000 ffffffff82267679 ffff88007a4efdd8 ffff88007fc13240
[ 2187.044287] Call Trace:
[ 2187.044287]  [<ffffffff810cc877>] process_one_work+0x1c7/0x490
[ 2187.044287]  [<ffffffff810cc80d>] ? process_one_work+0x15d/0x490
[ 2187.044287]  [<ffffffff810cd569>] worker_thread+0x119/0x4f0
[ 2187.044287]  [<ffffffff810fbbad>] ? trace_hardirqs_on+0xd/0x10
[ 2187.044287]  [<ffffffff810cd450>] ? init_pwq+0x190/0x190
[ 2187.044287]  [<ffffffff810d3c6f>] kthread+0xdf/0x100
[ 2187.044287]  [<ffffffff810d3b90>] ? __init_kthread_worker+0x70/0x70
[ 2187.044287]  [<ffffffff81d9873c>] ret_from_fork+0x7c/0xb0
[ 2187.044287]  [<ffffffff810d3b90>] ? __init_kthread_worker+0x70/0x70
[ 2187.044287] Code: 0f 1f 44 00 00 31 c0 5d c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 8d b7 48 fe ff ff 48 8b 87 58 fe ff ff 48 89 e5 48 8b 40 30 <48> 8b 00 48 8b 10 48 89 c7 48 8b 92 90 03 00 00 ff 52 28 5d c3
[ 2187.044287] RIP  [<ffffffff81361ca6>] free_lock_state_work+0x16/0x30
[ 2187.044287]  RSP <ffff88007a4efd58>
[ 2187.103626] ---[ end trace 0f11326d28e5d8fa ]---

It appears that the lock state outlived the open state with which it
was associated.

Fix this by pinning down the open stateid and the superblock prior to
queueing the workqueue job, and then releasing putting those references
once the RPC task has been queued.

Reported-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfs/nfs4state.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a770c8e469a7..fb29c7cbe8e3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -804,11 +804,14 @@ free_lock_state_work(struct work_struct *work)
 {
 	struct nfs4_lock_state *lsp = container_of(work,
 					struct nfs4_lock_state, ls_release);
-	struct nfs4_state *state = lsp->ls_state;
-	struct nfs_server *server = state->owner->so_server;
+	struct nfs4_state *osp = lsp->ls_state;
+	struct super_block *sb = osp->inode->i_sb;
+	struct nfs_server *server = NFS_SB(sb);
 	struct nfs_client *clp = server->nfs_client;
 
 	clp->cl_mvops->free_lock_state(server, lsp);
+	nfs4_put_open_state(osp);
+	nfs_sb_deactive(sb);
 }
 
 /*
@@ -896,9 +899,11 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 	if (list_empty(&state->lock_states))
 		clear_bit(LK_STATE_IN_USE, &state->flags);
 	spin_unlock(&state->state_lock);
-	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags))
+	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
+		atomic_inc(&lsp->ls_state->count);
+		nfs_sb_active(lsp->ls_state->inode->i_sb);
 		queue_work(nfsiod_workqueue, &lsp->ls_release);
-	else {
+	} else {
 		server = state->owner->so_server;
 		nfs4_free_lock_state(server, lsp);
 	}
-- 
1.9.3


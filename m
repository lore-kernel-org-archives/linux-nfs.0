Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:51707 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630AbaIHM0J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 08:26:09 -0400
Received: by mail-qa0-f43.google.com with SMTP id cm18so14052806qab.30
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 05:26:08 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] nfs: revert "nfs4: queue free_lock_state job submission to nfsiod"
Date: Mon,  8 Sep 2014 08:26:01 -0400
Message-Id: <1410179161-18418-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <20140907153534.GA7026@infradead.org>
References: <20140907153534.GA7026@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 49a4bda22e186c4d0eb07f4a36b5b1a378f9398d.

Christoph reported an oops due to the above commit:

generic/089 242s ...[ 2187.041239] general protection fault: 0000 [#1]
SMP
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

The original reason for this patch was because the fl_release_private
operation couldn't sleep. With commit ed9814d85810 (locks: defer freeing
locks in locks_delete_lock until after i_lock has been dropped), this is
no longer a problem so we can revert this patch.

Reported-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfs/nfs4_fs.h   | 13 ++++++-------
 fs/nfs/nfs4state.c | 24 ++++++------------------
 2 files changed, 12 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 92193eddb41d..a8b855ab4e22 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -130,16 +130,15 @@ enum {
  */
 
 struct nfs4_lock_state {
-	struct list_head		ls_locks;   /* Other lock stateids */
-	struct nfs4_state *		ls_state;   /* Pointer to open state */
+	struct list_head	ls_locks;	/* Other lock stateids */
+	struct nfs4_state *	ls_state;	/* Pointer to open state */
 #define NFS_LOCK_INITIALIZED 0
 #define NFS_LOCK_LOST        1
-	unsigned long			ls_flags;
+	unsigned long		ls_flags;
 	struct nfs_seqid_counter	ls_seqid;
-	nfs4_stateid			ls_stateid;
-	atomic_t			ls_count;
-	fl_owner_t			ls_owner;
-	struct work_struct		ls_release;
+	nfs4_stateid		ls_stateid;
+	atomic_t		ls_count;
+	fl_owner_t		ls_owner;
 };
 
 /* bits for nfs4_state->flags */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a043f618cd5a..22fe35104c0c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -799,18 +799,6 @@ __nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
 	return NULL;
 }
 
-static void
-free_lock_state_work(struct work_struct *work)
-{
-	struct nfs4_lock_state *lsp = container_of(work,
-					struct nfs4_lock_state, ls_release);
-	struct nfs4_state *state = lsp->ls_state;
-	struct nfs_server *server = state->owner->so_server;
-	struct nfs_client *clp = server->nfs_client;
-
-	clp->cl_mvops->free_lock_state(server, lsp);
-}
-
 /*
  * Return a compatible lock_state. If no initialized lock_state structure
  * exists, return an uninitialized one.
@@ -832,7 +820,6 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	if (lsp->ls_seqid.owner_id < 0)
 		goto out_free;
 	INIT_LIST_HEAD(&lsp->ls_locks);
-	INIT_WORK(&lsp->ls_release, free_lock_state_work);
 	return lsp;
 out_free:
 	kfree(lsp);
@@ -896,12 +883,13 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 	if (list_empty(&state->lock_states))
 		clear_bit(LK_STATE_IN_USE, &state->flags);
 	spin_unlock(&state->state_lock);
-	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags))
-		queue_work(nfsiod_workqueue, &lsp->ls_release);
-	else {
-		server = state->owner->so_server;
+	server = state->owner->so_server;
+	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
+		struct nfs_client *clp = server->nfs_client;
+
+		clp->cl_mvops->free_lock_state(server, lsp);
+	} else
 		nfs4_free_lock_state(server, lsp);
-	}
 }
 
 static void nfs4_fl_copy_lock(struct file_lock *dst, struct file_lock *src)
-- 
1.9.3


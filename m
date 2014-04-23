Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:35239 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757008AbaDWSZL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 14:25:11 -0400
Received: by mail-qa0-f46.google.com with SMTP id i13so1187915qae.5
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 11:25:10 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] nfs4: queue free_lock_state job submission to nfsiod
Date: Wed, 23 Apr 2014 14:24:59 -0400
Message-Id: <1398277500-31575-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1398277500-31575-1-git-send-email-jlayton@redhat.com>
References: <1398277500-31575-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We got a report of the following warning in Fedora:

BUG: sleeping function called from invalid context at mm/slub.c:969
in_atomic(): 1, irqs_disabled(): 0, pid: 533, name: bash
3 locks held by bash/533:
 #0:  (&sp->so_delegreturn_mutex){+.+...}, at: [<ffffffffa033da62>] nfs4_proc_lock+0x262/0x910 [nfsv4]
 #1:  (&nfsi->rwsem){.+.+.+}, at: [<ffffffffa033da6a>] nfs4_proc_lock+0x26a/0x910 [nfsv4]
 #2:  (&sb->s_type->i_lock_key#23){+.+...}, at: [<ffffffff812998dc>] flock_lock_file_wait+0x8c/0x3a0
CPU: 0 PID: 533 Comm: bash Not tainted 3.15.0-0.rc1.git1.1.fc21.x86_64 #1
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 0000000000000000 00000000d664ff3c ffff880078b69a70 ffffffff817e82e0
 0000000000000000 ffff880078b69a98 ffffffff810cf1a4 0000000000000050
 0000000000000050 ffff88007cc01a00 ffff880078b69ad8 ffffffff8121449e
Call Trace:
 [<ffffffff817e82e0>] dump_stack+0x4d/0x66
 [<ffffffff810cf1a4>] __might_sleep+0x184/0x240
 [<ffffffff8121449e>] kmem_cache_alloc_trace+0x4e/0x330
 [<ffffffffa0331124>] ? nfs4_release_lockowner+0x74/0x110 [nfsv4]
 [<ffffffffa0331124>] nfs4_release_lockowner+0x74/0x110 [nfsv4]
 [<ffffffffa0352340>] nfs4_put_lock_state+0x90/0xb0 [nfsv4]
 [<ffffffffa0352375>] nfs4_fl_release_lock+0x15/0x20 [nfsv4]
 [<ffffffff81297515>] locks_free_lock+0x45/0x90
 [<ffffffff8129996c>] flock_lock_file_wait+0x11c/0x3a0
 [<ffffffffa033da6a>] ? nfs4_proc_lock+0x26a/0x910 [nfsv4]
 [<ffffffffa033301e>] do_vfs_lock+0x1e/0x30 [nfsv4]
 [<ffffffffa033da79>] nfs4_proc_lock+0x279/0x910 [nfsv4]
 [<ffffffff810dbb26>] ? local_clock+0x16/0x30
 [<ffffffff810f5a3f>] ? lock_release_holdtime.part.28+0xf/0x200
 [<ffffffffa02f820c>] do_unlk+0x8c/0xc0 [nfs]
 [<ffffffffa02f85c5>] nfs_flock+0xa5/0xf0 [nfs]
 [<ffffffff8129a6f6>] locks_remove_file+0xb6/0x1e0
 [<ffffffff812159d8>] ? kfree+0xd8/0x2d0
 [<ffffffff8123bc63>] __fput+0xd3/0x210
 [<ffffffff8123bdee>] ____fput+0xe/0x10
 [<ffffffff810bfb6d>] task_work_run+0xcd/0xf0
 [<ffffffff81019cd1>] do_notify_resume+0x61/0x90
 [<ffffffff817fbea2>] int_signal+0x12/0x17

The problem is that NFSv4 is trying to do an allocation from
fl_release_private (in order to send a RELEASE_LOCKOWNER call). That
function can be called while holding the inode->i_lock, and it's
currently set up to do __GFP_WAIT allocations. v4.1 code has a
similar problem.

This patch adds a work_struct to the nfs4_lock_state and has the code
queue the free_lock_state operation to nfsiod.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4_fs.h   | 13 +++++++------
 fs/nfs/nfs4state.c | 24 ++++++++++++++++++------
 2 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3888dd0b43a1..75aadf8c0429 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -130,15 +130,16 @@ enum {
  */
 
 struct nfs4_lock_state {
-	struct list_head	ls_locks;	/* Other lock stateids */
-	struct nfs4_state *	ls_state;	/* Pointer to open state */
+	struct list_head		ls_locks;   /* Other lock stateids */
+	struct nfs4_state *		ls_state;   /* Pointer to open state */
 #define NFS_LOCK_INITIALIZED 0
 #define NFS_LOCK_LOST        1
-	unsigned long		ls_flags;
+	unsigned long			ls_flags;
 	struct nfs_seqid_counter	ls_seqid;
-	nfs4_stateid		ls_stateid;
-	atomic_t		ls_count;
-	fl_owner_t		ls_owner;
+	nfs4_stateid			ls_stateid;
+	atomic_t			ls_count;
+	fl_owner_t			ls_owner;
+	struct work_struct		ls_release;
 };
 
 /* bits for nfs4_state->flags */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 102cd4b4f07e..7b0b113e3c37 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -799,6 +799,18 @@ __nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_p
 	return NULL;
 }
 
+static void
+free_lock_state_work(struct work_struct *work)
+{
+	struct nfs4_lock_state *lsp = container_of(work,
+					struct nfs4_lock_state, ls_release);
+	struct nfs4_state *state = lsp->ls_state;
+	struct nfs_server *server = state->owner->so_server;
+	struct nfs_client *clp = server->nfs_client;
+
+	clp->cl_mvops->free_lock_state(server, lsp);
+}
+
 /*
  * Return a compatible lock_state. If no initialized lock_state structure
  * exists, return an uninitialized one.
@@ -820,6 +832,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	if (lsp->ls_seqid.owner_id < 0)
 		goto out_free;
 	INIT_LIST_HEAD(&lsp->ls_locks);
+	INIT_WORK(&lsp->ls_release, free_lock_state_work);
 	return lsp;
 out_free:
 	kfree(lsp);
@@ -883,13 +896,12 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 	if (list_empty(&state->lock_states))
 		clear_bit(LK_STATE_IN_USE, &state->flags);
 	spin_unlock(&state->state_lock);
-	server = state->owner->so_server;
-	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
-		struct nfs_client *clp = server->nfs_client;
-
-		clp->cl_mvops->free_lock_state(server, lsp);
-	} else
+	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags))
+		queue_work(nfsiod_workqueue, &lsp->ls_release);
+	else {
+		server = state->owner->so_server;
 		nfs4_free_lock_state(server, lsp);
+	}
 }
 
 static void nfs4_fl_copy_lock(struct file_lock *dst, struct file_lock *src)
-- 
1.9.0


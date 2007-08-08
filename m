From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS fixes for 2.6.23-rc2 regressions
Date: Wed, 08 Aug 2007 13:19:44 -0400
Message-ID: <1186593584.6699.30.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIpCj-000695-Nu
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 10:20:17 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIpCn-000073-6j
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 10:20:21 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/delegation.c            |   21 ++++++++++----
 fs/nfs/inode.c                 |   24 +++++-----------
 fs/nfs/namespace.c             |    6 +---
 fs/nfs/nfs4proc.c              |   16 +++++------
 fs/nfs/nfs4renewd.c            |    5 +--
 fs/nfs/nfs4state.c             |    5 +---
 include/linux/nfs_fs.h         |    2 +-
 net/sunrpc/auth_gss/auth_gss.c |    9 ++++--
 net/sunrpc/cache.c             |    3 +-
 net/sunrpc/rpc_pipe.c          |    3 +-
 net/sunrpc/sched.c             |   57 ++++++++++++++++-----------------------
 11 files changed, 67 insertions(+), 84 deletions(-)

commit 4011cd97886dd04b90fef8b671b9936cd39ab983
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Aug 7 15:33:01 2007 -0400

    SUNRPC: Replace flush_workqueue() with cancel_work_sync() and friends
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3d39c691ff486142dd9aaeac12f553f4476b7a62
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Aug 7 15:28:33 2007 -0400

    NFS: Replace flush_scheduled_work with cancel_work_sync() and friends
    
    This will avoid deadlocks of the form:
    
    stack backtrace:
     [<c0104fda>] show_trace_log_lvl+0x1a/0x30
     [<c0105c02>] show_trace+0x12/0x20
     [<c0105d15>] dump_stack+0x15/0x20
     [<c013ee42>] __lock_acquire+0xc22/0x1030
     [<c013f2b1>] lock_acquire+0x61/0x80
     [<c012edd9>] flush_workqueue+0x49/0x70
     [<c012ee0d>] flush_scheduled_work+0xd/0x10
     [<dcf55c0c>] nfs_release_automount_timer+0x2c/0x30 [nfs]
     [<dcf45d8e>] nfs_free_server+0x9e/0xd0 [nfs]
     [<dcf4e626>] nfs_kill_super+0x16/0x20 [nfs]
     [<c017b38d>] deactivate_super+0x7d/0xa0
     [<c018f94b>] mntput_no_expire+0x4b/0x80
     [<c018fd94>] expire_mount_list+0xe4/0x140
     [<c0191219>] mark_mounts_for_expiry+0x99/0xb0
     [<dcf55d1d>] nfs_expire_automounts+0xd/0x40 [nfs]
     [<c012e61b>] run_workqueue+0x12b/0x1e0
     [<c012f05b>] worker_thread+0x9b/0x100
     [<c0131c72>] kthread+0x42/0x70
     [<c0104c0f>] kernel_thread_helper+0x7/0x18
     =======================
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a4deb81ba8ece75af5560d40d9bb8d242c48a111
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Aug 6 12:21:13 2007 -0400

    SUNRPC: Don't call gss_delete_sec_context() from an rcu context
    
    Doing so may not be safe...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 905f8d16e32fd48499e3f8b9a2d9f746af3e0949
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Aug 6 12:18:34 2007 -0400

    NFSv4: Don't call put_rpccred() from an rcu callback
    
    Doing so would require us to introduce bh-safe locks into put_rpccred().
    This patch fixes the lockdep complaint reported by Marc Dietrich:
    
    inconsistent {softirq-on-W} -> {in-softirq-W} usage.
    swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
     (rpc_credcache_lock){-+..}, at: [<c01dc487>]
    _atomic_dec_and_lock+0x17/0x60
    {softirq-on-W} state was registered at:
      [<c013e870>] __lock_acquire+0x650/0x1030
      [<c013f2b1>] lock_acquire+0x61/0x80
      [<c02db9ac>] _spin_lock+0x2c/0x40
      [<c01dc487>] _atomic_dec_and_lock+0x17/0x60
      [<dced55fd>] put_rpccred+0x5d/0x100 [sunrpc]
      [<dced56c1>] rpcauth_unbindcred+0x21/0x60 [sunrpc]
      [<dced3fd4>] a0 [sunrpc]
      [<dcecefe0>] rpc_call_sync+0x30/0x40 [sunrpc]
      [<dcedc73b>] rpcb_register+0xdb/0x180 [sunrpc]
      [<dced65b3>] svc_register+0x93/0x160 [sunrpc]
      [<dced6ebe>] __svc_create+0x1ee/0x220 [sunrpc]
      [<dced7053>] svc_create+0x13/0x20 [sunrpc]
      [<dcf6d722>] nfs_callback_up+0x82/0x120 [nfs]
      [<dcf48f36>] nfs_get_client+0x176/0x390 [nfs]
      [<dcf49181>] nfs4_set_client+0x31/0x190 [nfs]
      [<dcf49983>] nfs4_create_server+0x63/0x3b0 [nfs]
      [<dcf52426>] nfs4_get_sb+0x346/0x5b0 [nfs]
      [<c017b444>] vfs_kern_mount+0x94/0x110
      [<c0190a62>] do_mount+0x1f2/0x7d0
      [<c01910a6>] sys_mount+0x66/0xa0
      [<c0104046>] syscall_call+0x7/0xb
      [<ffffffff>] 0xffffffff
    irq event stamp: 5277830
    hardirqs last  enabled at (5277830): [<c017530a>] kmem_cache_free+0x8a/0xc0
    hardirqs last disabled at (5277829): [<c01752d2>] kmem_cache_free+0x52/0xc0
    softirqs last  enabled at (5277798): [<c0124173>] __do_softirq+0xa3/0xc0
    softirqs last disabled at (5277817): [<c01241d7>] do_softirq+0x47/0x50
    
    other info that might help us debug this:
    no locks held by swapper/0.
    
    stack backtrace:
     [<c0104fda>] show_trace_log_lvl+0x1a/0x30
     [<c0105c02>] show_trace+0x12/0x20
     [<c0105d15>] dump_stack+0x15/0x20
     [<c013ccc3>] print_usage_bug+0x153/0x160
     [<c013d8b9>] mark_lock+0x449/0x620
     [<c013e824>] __lock_acquire+0x604/0x1030
     [<c013f2b1>] lock_acquire+0x61/0x80
     [<c02db9ac>] _spin_lock+0x2c/0x40
     [<c01dc487>] _atomic_dec_and_lock+0x17/0x60
     [<dced55fd>] put_rpccred+0x5d/0x100 [sunrpc]
     [<dcf6bf83>] nfs_free_delegation_callback+0x13/0x20 [nfs]
     [<c012f9ea>] __rcu_process_callbacks+0x6a/0x1c0
     [<c012fb52>] rcu_process_callbacks+0x12/0x30
     [<c0124218>] tasklet_action+0x38/0x80
     [<c0124125>] __do_softirq+0x55/0xc0
     [<c01241d7>] do_softirq+0x47/0x50
     [<c0124605>] irq_exit+0x35/0x40
     [<c0112463>] smp_apic_timer_interrupt+0x43/0x80
     [<c0104a77>] apic_timer_interrupt+0x33/0x38
     [<c02690df>] cpuidle_idle_call+0x6f/0x90
     [<c01023c3>] cpu_idle+0x43/0x70
     [<c02d8c27>] rest_init+0x47/0x50
     [<c03bcb6a>] start_kernel+0x22a/0x2b0
     [<00000000>] 0x0
     =======================
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 45328c354e8ae16b67cb3adb72ab57459f9e5fd6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 26 17:47:34 2007 -0400

    NFS: Fix NFSv4 open stateid regressions
    
    Do not allow cached open for O_RDONLY or O_WRONLY unless the file has been
    previously opened in these modes.
    
    Also Fix the calculation of the mode in nfs4_close_prepare. We should only
    issue an OPEN_DOWNGRADE if we're sure that we will still be holding the
    correct open modes. This may not be the case if we've been doing delegated
    opens.
    
    Finally, there is no need to adjust the open mode bit flags in
    nfs4_close_done(): that has already been done in nfs4_close_prepare().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ba683031fae115d61c6b5f4c675cc27f6e9576d2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jul 27 10:23:05 2007 -0400

    NFSv4: Fix a locking regression in nfs4_set_mode_locked()
    
    We don't really need to clear &state->inode_states inside
    nfs4_set_mode_locked, and doing so without holding the inode->i_lock would
    in any case be a bug...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5e11934d13c9a3bcb0cadad6c7a7de5c32660422
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 26 12:06:17 2007 -0400

    NFS: Fix put_nfs_open_context
    
    We need to grab the inode->i_lock atomically with the last reference put in
    order to remove the open context that is being freed from the
    nfsi->open_files list.
    
    Fix by converting the kref to a standard atomic counter and then using
    atomic_dec_and_lock()...
    
    Thanks to Arnd Bergmann for pointing out the problem.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b247bbf1da69ce376aa1ceb8057331214589e366
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 19 16:32:20 2007 -0400

    SUNRPC: Fix a race in rpciod_down()
    
    The commit 4ada539ed77c7a2bbcb75cafbbd7bd8d2b9bef7b lead to the unpleasant
    possibility of an asynchronous rpc_task being required to call
    rpciod_down() when it is complete. This again means that the rpciod
    workqueue may get to call destroy_workqueue on itself -> hang...
    
    Change rpciod_up/rpciod_down to just get/put the module, and then
    create/destroy the workqueues on module load/unload.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 20ac403..c55a761 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -20,10 +20,8 @@
 #include "delegation.h"
 #include "internal.h"
 
-static void nfs_free_delegation(struct nfs_delegation *delegation)
+static void nfs_do_free_delegation(struct nfs_delegation *delegation)
 {
-	if (delegation->cred)
-		put_rpccred(delegation->cred);
 	kfree(delegation);
 }
 
@@ -31,7 +29,18 @@ static void nfs_free_delegation_callback(struct rcu_head *head)
 {
 	struct nfs_delegation *delegation = container_of(head, struct nfs_delegation, rcu);
 
-	nfs_free_delegation(delegation);
+	nfs_do_free_delegation(delegation);
+}
+
+static void nfs_free_delegation(struct nfs_delegation *delegation)
+{
+	struct rpc_cred *cred;
+
+	cred = rcu_dereference(delegation->cred);
+	rcu_assign_pointer(delegation->cred, NULL);
+	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
+	if (cred)
+		put_rpccred(cred);
 }
 
 static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state)
@@ -166,7 +175,7 @@ static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *
 	int res = 0;
 
 	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid);
-	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
+	nfs_free_delegation(delegation);
 	return res;
 }
 
@@ -448,7 +457,7 @@ restart:
 		spin_unlock(&clp->cl_lock);
 		rcu_read_unlock();
 		if (delegation != NULL)
-			call_rcu(&delegation->rcu, nfs_free_delegation_callback);
+			nfs_free_delegation(delegation);
 		goto restart;
 	}
 	rcu_read_unlock();
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bca6cdc..71a49c3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -468,7 +468,7 @@ static struct nfs_open_context *alloc_nfs_open_context(struct vfsmount *mnt, str
 		ctx->lockowner = current->files;
 		ctx->error = 0;
 		ctx->dir_cookie = 0;
-		kref_init(&ctx->kref);
+		atomic_set(&ctx->count, 1);
 	}
 	return ctx;
 }
@@ -476,21 +476,18 @@ static struct nfs_open_context *alloc_nfs_open_context(struct vfsmount *mnt, str
 struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 {
 	if (ctx != NULL)
-		kref_get(&ctx->kref);
+		atomic_inc(&ctx->count);
 	return ctx;
 }
 
-static void nfs_free_open_context(struct kref *kref)
+void put_nfs_open_context(struct nfs_open_context *ctx)
 {
-	struct nfs_open_context *ctx = container_of(kref,
-			struct nfs_open_context, kref);
+	struct inode *inode = ctx->path.dentry->d_inode;
 
-	if (!list_empty(&ctx->list)) {
-		struct inode *inode = ctx->path.dentry->d_inode;
-		spin_lock(&inode->i_lock);
-		list_del(&ctx->list);
-		spin_unlock(&inode->i_lock);
-	}
+	if (!atomic_dec_and_lock(&ctx->count, &inode->i_lock))
+		return;
+	list_del(&ctx->list);
+	spin_unlock(&inode->i_lock);
 	if (ctx->state != NULL)
 		nfs4_close_state(&ctx->path, ctx->state, ctx->mode);
 	if (ctx->cred != NULL)
@@ -500,11 +497,6 @@ static void nfs_free_open_context(struct kref *kref)
 	kfree(ctx);
 }
 
-void put_nfs_open_context(struct nfs_open_context *ctx)
-{
-	kref_put(&ctx->kref, nfs_free_open_context);
-}
-
 /*
  * Ensure that mmap has a recent RPC credential for use when writing out
  * shared pages
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 7f86e65..aea76d0 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -175,10 +175,8 @@ static void nfs_expire_automounts(struct work_struct *work)
 
 void nfs_release_automount_timer(void)
 {
-	if (list_empty(&nfs_automount_list)) {
-		cancel_delayed_work(&nfs_automount_task);
-		flush_scheduled_work();
-	}
+	if (list_empty(&nfs_automount_list))
+		cancel_delayed_work_sync(&nfs_automount_task);
 }
 
 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6ca2795..62b3ae2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -332,11 +332,9 @@ static int can_open_cached(struct nfs4_state *state, int mode)
 	switch (mode & (FMODE_READ|FMODE_WRITE|O_EXCL)) {
 		case FMODE_READ:
 			ret |= test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0;
-			ret |= test_bit(NFS_O_RDWR_STATE, &state->flags) != 0;
 			break;
 		case FMODE_WRITE:
 			ret |= test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0;
-			ret |= test_bit(NFS_O_RDWR_STATE, &state->flags) != 0;
 			break;
 		case FMODE_READ|FMODE_WRITE:
 			ret |= test_bit(NFS_O_RDWR_STATE, &state->flags) != 0;
@@ -1260,7 +1258,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	nfs_increment_open_seqid(task->tk_status, calldata->arg.seqid);
 	switch (task->tk_status) {
 		case 0:
-			nfs_set_open_stateid(state, &calldata->res.stateid, calldata->arg.open_flags);
+			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
 			renew_lease(server, calldata->timestamp);
 			break;
 		case -NFS4ERR_STALE_STATEID:
@@ -1286,23 +1284,19 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		.rpc_cred = state->owner->so_cred,
 	};
 	int clear_rd, clear_wr, clear_rdwr;
-	int mode;
 
 	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		return;
 
-	mode = FMODE_READ|FMODE_WRITE;
 	clear_rd = clear_wr = clear_rdwr = 0;
 	spin_lock(&state->owner->so_lock);
 	/* Calculate the change in open mode */
 	if (state->n_rdwr == 0) {
 		if (state->n_rdonly == 0) {
-			mode &= ~FMODE_READ;
 			clear_rd |= test_and_clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 			clear_rdwr |= test_and_clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		}
 		if (state->n_wronly == 0) {
-			mode &= ~FMODE_WRITE;
 			clear_wr |= test_and_clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 			clear_rdwr |= test_and_clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		}
@@ -1314,9 +1308,13 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	nfs_fattr_init(calldata->res.fattr);
-	if (mode != 0)
+	if (test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0) {
 		msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
-	calldata->arg.open_flags = mode;
+		calldata->arg.open_flags = FMODE_READ;
+	} else if (test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0) {
+		msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
+		calldata->arg.open_flags = FMODE_WRITE;
+	}
 	calldata->timestamp = jiffies;
 	rpc_call_setup(task, &msg, 0);
 }
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 0505ca1..3ea352d 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -127,16 +127,15 @@ nfs4_schedule_state_renewal(struct nfs_client *clp)
 void
 nfs4_renewd_prepare_shutdown(struct nfs_server *server)
 {
-	flush_scheduled_work();
+	cancel_delayed_work(&server->nfs_client->cl_renewd);
 }
 
 void
 nfs4_kill_renewd(struct nfs_client *clp)
 {
 	down_read(&clp->cl_sem);
-	cancel_delayed_work(&clp->cl_renewd);
+	cancel_delayed_work_sync(&clp->cl_renewd);
 	up_read(&clp->cl_sem);
-	flush_scheduled_work();
 }
 
 /*
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e9662ba..3e4adf8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -341,8 +341,6 @@ nfs4_state_set_mode_locked(struct nfs4_state *state, mode_t mode)
 		else
 			list_move_tail(&state->open_states, &state->owner->so_states);
 	}
-	if (mode == 0)
-		list_del_init(&state->inode_states);
 	state->state = mode;
 }
 
@@ -415,8 +413,7 @@ void nfs4_put_open_state(struct nfs4_state *state)
 	if (!atomic_dec_and_lock(&state->count, &owner->so_lock))
 		return;
 	spin_lock(&inode->i_lock);
-	if (!list_empty(&state->inode_states))
-		list_del(&state->inode_states);
+	list_del(&state->inode_states);
 	list_del(&state->open_states);
 	spin_unlock(&inode->i_lock);
 	spin_unlock(&owner->so_lock);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9ba4aec..157dcb0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -71,7 +71,7 @@ struct nfs_access_entry {
 
 struct nfs4_state;
 struct nfs_open_context {
-	struct kref kref;
+	atomic_t count;
 	struct path path;
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4bbc59c..53995af 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -736,9 +736,6 @@ gss_do_free_ctx(struct gss_cl_ctx *ctx)
 {
 	dprintk("RPC:       gss_free_ctx\n");
 
-	if (ctx->gc_gss_ctx)
-		gss_delete_sec_context(&ctx->gc_gss_ctx);
-
 	kfree(ctx->gc_wire_ctx.data);
 	kfree(ctx);
 }
@@ -753,7 +750,13 @@ gss_free_ctx_callback(struct rcu_head *head)
 static void
 gss_free_ctx(struct gss_cl_ctx *ctx)
 {
+	struct gss_ctx *gc_gss_ctx;
+
+	gc_gss_ctx = rcu_dereference(ctx->gc_gss_ctx);
+	rcu_assign_pointer(ctx->gc_gss_ctx, NULL);
 	call_rcu(&ctx->gc_rcu, gss_free_ctx_callback);
+	if (gc_gss_ctx)
+		gss_delete_sec_context(&gc_gss_ctx);
 }
 
 static void
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 01c3c41..ebe344f 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -371,8 +371,7 @@ int cache_unregister(struct cache_detail *cd)
 	}
 	if (list_empty(&cache_list)) {
 		/* module must be being unloaded so its safe to kill the worker */
-		cancel_delayed_work(&cache_cleaner);
-		flush_scheduled_work();
+		cancel_delayed_work_sync(&cache_cleaner);
 	}
 	return 0;
 }
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 650af06..669e12a 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -132,8 +132,7 @@ rpc_close_pipes(struct inode *inode)
 		rpci->nwriters = 0;
 		if (ops->release_pipe)
 			ops->release_pipe(inode);
-		cancel_delayed_work(&rpci->queue_timeout);
-		flush_workqueue(rpciod_workqueue);
+		cancel_delayed_work_sync(&rpci->queue_timeout);
 	}
 	rpc_inode_setowner(inode, NULL);
 	mutex_unlock(&inode->i_mutex);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index b5723c2..954d7ec 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -50,8 +50,6 @@ static RPC_WAITQ(delay_queue, "delayq");
 /*
  * rpciod-related stuff
  */
-static DEFINE_MUTEX(rpciod_mutex);
-static atomic_t rpciod_users = ATOMIC_INIT(0);
 struct workqueue_struct *rpciod_workqueue;
 
 /*
@@ -961,60 +959,49 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 	spin_unlock(&clnt->cl_lock);
 }
 
+int rpciod_up(void)
+{
+	return try_module_get(THIS_MODULE) ? 0 : -EINVAL;
+}
+
+void rpciod_down(void)
+{
+	module_put(THIS_MODULE);
+}
+
 /*
- * Start up the rpciod process if it's not already running.
+ * Start up the rpciod workqueue.
  */
-int
-rpciod_up(void)
+static int rpciod_start(void)
 {
 	struct workqueue_struct *wq;
-	int error = 0;
-
-	if (atomic_inc_not_zero(&rpciod_users))
-		return 0;
-
-	mutex_lock(&rpciod_mutex);
 
-	/* Guard against races with rpciod_down() */
-	if (rpciod_workqueue != NULL)
-		goto out_ok;
 	/*
 	 * Create the rpciod thread and wait for it to start.
 	 */
 	dprintk("RPC:       creating workqueue rpciod\n");
-	error = -ENOMEM;
 	wq = create_workqueue("rpciod");
-	if (wq == NULL)
-		goto out;
-
 	rpciod_workqueue = wq;
-	error = 0;
-out_ok:
-	atomic_inc(&rpciod_users);
-out:
-	mutex_unlock(&rpciod_mutex);
-	return error;
+	return rpciod_workqueue != NULL;
 }
 
-void
-rpciod_down(void)
+static void rpciod_stop(void)
 {
-	if (!atomic_dec_and_test(&rpciod_users))
-		return;
+	struct workqueue_struct *wq = NULL;
 
-	mutex_lock(&rpciod_mutex);
+	if (rpciod_workqueue == NULL)
+		return;
 	dprintk("RPC:       destroying workqueue rpciod\n");
 
-	if (atomic_read(&rpciod_users) == 0 && rpciod_workqueue != NULL) {
-		destroy_workqueue(rpciod_workqueue);
-		rpciod_workqueue = NULL;
-	}
-	mutex_unlock(&rpciod_mutex);
+	wq = rpciod_workqueue;
+	rpciod_workqueue = NULL;
+	destroy_workqueue(wq);
 }
 
 void
 rpc_destroy_mempool(void)
 {
+	rpciod_stop();
 	if (rpc_buffer_mempool)
 		mempool_destroy(rpc_buffer_mempool);
 	if (rpc_task_mempool)
@@ -1048,6 +1035,8 @@ rpc_init_mempool(void)
 						      rpc_buffer_slabp);
 	if (!rpc_buffer_mempool)
 		goto err_nomem;
+	if (!rpciod_start())
+		goto err_nomem;
 	return 0;
 err_nomem:
 	rpc_destroy_mempool();

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 28/69] NFSv4: Remove nfs_client->cl_sem
Date: Tue, 23 Dec 2008 18:02:13 -0500
Message-ID: <20081223230213.13743.53419.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332AbYLWXXt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:49 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFv006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:43 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we're using the flags to indicate state that needs to be
recovered, as well as having implemented proper refcounting and spinlocking
on the state and open_owners, we can get rid of nfs_client->cl_sem. The
only remaining case that was dubious was the file locking, and that case is
now covered by the nfsi->rwsem.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |    1 -
 fs/nfs/delegation.c       |    5 -----
 fs/nfs/nfs4proc.c         |   20 +-------------------
 fs/nfs/nfs4renewd.c       |    3 ---
 fs/nfs/nfs4state.c        |   17 -----------------
 include/linux/nfs_fs_sb.h |    6 ------
 6 files changed, 1 insertions(+), 51 deletions(-)


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 70b6d9e..b643f0e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -143,7 +143,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_proto = cl_init->proto;
 
 #ifdef CONFIG_NFS_V4
-	init_rwsem(&clp->cl_sem);
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 646ba3e..ebc06f2 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -243,16 +243,13 @@ static void nfs_msync_inode(struct inode *inode)
  */
 static int __nfs_inode_return_delegation(struct inode *inode, struct nfs_delegation *delegation)
 {
-	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	nfs_msync_inode(inode);
-	down_read(&clp->cl_sem);
 	/* Guard against new delegated open calls */
 	down_write(&nfsi->rwsem);
 	nfs_delegation_claim_opens(inode, &delegation->stateid);
 	up_write(&nfsi->rwsem);
-	up_read(&clp->cl_sem);
 	nfs_msync_inode(inode);
 
 	return nfs_do_return_delegation(inode, delegation, 1);
@@ -425,7 +422,6 @@ static int recall_thread(void *data)
 	daemonize("nfsv4-delegreturn");
 
 	nfs_msync_inode(inode);
-	down_read(&clp->cl_sem);
 	down_write(&nfsi->rwsem);
 	spin_lock(&clp->cl_lock);
 	delegation = nfs_detach_delegation_locked(nfsi, args->stateid);
@@ -437,7 +433,6 @@ static int recall_thread(void *data)
 	complete(&args->started);
 	nfs_delegation_claim_opens(inode, args->stateid);
 	up_write(&nfsi->rwsem);
-	up_read(&clp->cl_sem);
 	nfs_msync_inode(inode);
 
 	if (delegation != NULL)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aec4e47..26dcd77 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -207,12 +207,8 @@ static int nfs4_wait_clnt_recover(struct nfs_client *clp)
 
 	might_sleep();
 
-	rwsem_acquire(&clp->cl_sem.dep_map, 0, 0, _RET_IP_);
-
 	res = wait_on_bit(&clp->cl_state, NFS4CLNT_STATE_RECOVER,
 			nfs4_wait_bit_killable, TASK_KILLABLE);
-
-	rwsem_release(&clp->cl_sem.dep_map, 1, _RET_IP_);
 	return res;
 }
 
@@ -1135,7 +1131,6 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, int flags, struct
 	struct nfs4_state_owner  *sp;
 	struct nfs4_state     *state = NULL;
 	struct nfs_server       *server = NFS_SERVER(dir);
-	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_opendata *opendata;
 	int status;
 
@@ -1150,11 +1145,10 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, int flags, struct
 		goto err_put_state_owner;
 	if (path->dentry->d_inode != NULL)
 		nfs4_return_incompatible_delegation(path->dentry->d_inode, flags & (FMODE_READ|FMODE_WRITE));
-	down_read(&clp->cl_sem);
 	status = -ENOMEM;
 	opendata = nfs4_opendata_alloc(path, sp, flags, sattr);
 	if (opendata == NULL)
-		goto err_release_rwsem;
+		goto err_put_state_owner;
 
 	if (path->dentry->d_inode != NULL)
 		opendata->state = nfs4_get_open_state(path->dentry->d_inode, sp);
@@ -1172,13 +1166,10 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, int flags, struct
 		goto err_opendata_put;
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
-	up_read(&clp->cl_sem);
 	*res = state;
 	return 0;
 err_opendata_put:
 	nfs4_opendata_put(opendata);
-err_release_rwsem:
-	up_read(&clp->cl_sem);
 err_put_state_owner:
 	nfs4_put_state_owner(sp);
 out_err:
@@ -3099,7 +3090,6 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	struct nfs4_lock_state *lsp;
 	int status;
 
-	down_read(&clp->cl_sem);
 	arg.lock_owner.clientid = clp->cl_clientid;
 	status = nfs4_set_lock_state(state, request);
 	if (status != 0)
@@ -3116,7 +3106,6 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	}
 	request->fl_ops->fl_release_private(request);
 out:
-	up_read(&clp->cl_sem);
 	return status;
 }
 
@@ -3273,7 +3262,6 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 
 static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs_client *clp = state->owner->so_client;
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs_seqid *seqid;
 	struct nfs4_lock_state *lsp;
@@ -3284,15 +3272,12 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	status = nfs4_set_lock_state(state, request);
 	/* Unlock _before_ we do the RPC call */
 	request->fl_flags |= FL_EXISTS;
-	down_read(&clp->cl_sem);
 	down_read(&nfsi->rwsem);
 	if (do_vfs_lock(request->fl_file, request) == -ENOENT) {
 		up_read(&nfsi->rwsem);
-		up_read(&clp->cl_sem);
 		goto out;
 	}
 	up_read(&nfsi->rwsem);
-	up_read(&clp->cl_sem);
 	if (status != 0)
 		goto out;
 	/* Is this a delegated lock? */
@@ -3518,7 +3503,6 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
 
 static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs_client *clp = state->owner->so_client;
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	unsigned char fl_flags = request->fl_flags;
 	int status;
@@ -3531,7 +3515,6 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	status = do_vfs_lock(request->fl_file, request);
 	if (status < 0)
 		goto out;
-	down_read(&clp->cl_sem);
 	down_read(&nfsi->rwsem);
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
 		/* Yes: cache locks! */
@@ -3549,7 +3532,6 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __func__);
 out_unlock:
 	up_read(&nfsi->rwsem);
-	up_read(&clp->cl_sem);
 out:
 	request->fl_flags = fl_flags;
 	return status;
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 9fe8640..6101f95 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -65,7 +65,6 @@ nfs4_renew_state(struct work_struct *work)
 	long lease, timeout;
 	unsigned long last, now;
 
-	down_read(&clp->cl_sem);
 	dprintk("%s: start\n", __func__);
 	/* Are there any active superblocks? */
 	if (list_empty(&clp->cl_superblocks))
@@ -101,11 +100,9 @@ nfs4_renew_state(struct work_struct *work)
 	schedule_delayed_work(&clp->cl_renewd, timeout);
 	spin_unlock(&clp->cl_lock);
 out:
-	up_read(&clp->cl_sem);
 	dprintk("%s: done\n", __func__);
 }
 
-/* Must be called with clp->cl_sem locked for writes */
 void
 nfs4_schedule_state_renewal(struct nfs_client *clp)
 {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 16c9fbd..ec0cbe0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -305,10 +305,6 @@ nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 	}
 }
 
-/*
- * Note: must be called with clp->cl_sem held in order to prevent races
- *       with reboot recovery!
- */
 struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server, struct rpc_cred *cred)
 {
 	struct nfs_client *clp = server->nfs_client;
@@ -337,10 +333,6 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server, struct
 	return sp;
 }
 
-/*
- * Must be called with clp->cl_sem held in order to avoid races
- * with state recovery...
- */
 void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 {
 	struct nfs_client *clp = sp->so_client;
@@ -442,10 +434,6 @@ out:
 	return state;
 }
 
-/*
- * Beware! Caller must be holding exactly one
- * reference to clp->cl_sem!
- */
 void nfs4_put_open_state(struct nfs4_state *state)
 {
 	struct inode *inode = state->inode;
@@ -578,7 +566,6 @@ static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
  * Return a compatible lock_state. If no initialized lock_state structure
  * exists, return an uninitialized one.
  *
- * The caller must be holding clp->cl_sem
  */
 static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_owner_t owner)
 {
@@ -1127,7 +1114,6 @@ static int reclaimer(void *ptr)
 	allow_signal(SIGKILL);
 
 	/* Ensure exclusive access to NFSv4 state */
-	down_write(&clp->cl_sem);
 	while (!list_empty(&clp->cl_superblocks)) {
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
 			/* We're going to have to re-establish a clientid */
@@ -1149,7 +1135,6 @@ static int reclaimer(void *ptr)
 
 		/* First recover reboot state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
-			/* Note: list is protected by exclusive lock on cl->cl_sem */
 			status = nfs4_do_reclaim(clp, &nfs4_reboot_recovery_ops);
 			if (status == -NFS4ERR_STALE_CLIENTID)
 				continue;
@@ -1159,7 +1144,6 @@ static int reclaimer(void *ptr)
 
 		/* Now recover expired state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state)) {
-			/* Note: list is protected by exclusive lock on cl->cl_sem */
 			status = nfs4_do_reclaim(clp, &nfs4_nograce_recovery_ops);
 			if (status < 0) {
 				set_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state);
@@ -1175,7 +1159,6 @@ static int reclaimer(void *ptr)
 		break;
 	}
 out:
-	up_write(&clp->cl_sem);
 	if (test_and_clear_bit(NFS4CLNT_CB_PATH_DOWN, &clp->cl_state))
 		nfs_handle_cb_pathdown(clp);
 	nfs4_clear_recover_bit(clp);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4e477ae..9bb81ae 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -42,12 +42,6 @@ struct nfs_client {
 	struct rb_root		cl_openowner_id;
 	struct rb_root		cl_lockowner_id;
 
-	/*
-	 * The following rwsem ensures exclusive access to the server
-	 * while we recover the state following a lease expiration.
-	 */
-	struct rw_semaphore	cl_sem;
-
 	struct list_head	cl_delegations;
 	struct rb_root		cl_state_owners;
 	spinlock_t		cl_lock;


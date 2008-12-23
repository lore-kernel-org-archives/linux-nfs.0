From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 21/69] NFSv4: Fix state recovery when the client runs over
 the grace period
Date: Tue, 23 Dec 2008 18:02:11 -0500
Message-ID: <20081223230211.13743.58021.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217AbYLWXXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:44 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7U021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client for some reason is not able to recover all its state within
the time allotted for the grace period, and the server reboots again, the
client is not allowed to recover the state that was 'lost' using reboot
recovery.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4_fs.h   |    8 ++
 fs/nfs/nfs4proc.c  |    7 +-
 fs/nfs/nfs4state.c |  189 ++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 155 insertions(+), 49 deletions(-)


diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 0ac6bbb..1c6fbd1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -40,6 +40,9 @@ struct idmap;
 enum nfs4_client_state {
 	NFS4CLNT_STATE_RECOVER  = 0,
 	NFS4CLNT_LEASE_EXPIRED,
+	NFS4CLNT_RECLAIM_REBOOT,
+	NFS4CLNT_RECLAIM_NOGRACE,
+	NFS4CLNT_CB_PATH_DOWN,
 };
 
 /*
@@ -128,6 +131,8 @@ enum {
 	NFS_O_RDONLY_STATE,		/* OPEN stateid has read-only state */
 	NFS_O_WRONLY_STATE,		/* OPEN stateid has write-only state */
 	NFS_O_RDWR_STATE,		/* OPEN stateid has read/write state */
+	NFS_STATE_RECLAIM_REBOOT,	/* OPEN stateid server rebooted */
+	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
 };
 
 struct nfs4_state {
@@ -160,6 +165,7 @@ struct nfs4_exception {
 };
 
 struct nfs4_state_recovery_ops {
+	int state_flag_bit;
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
 };
@@ -187,7 +193,7 @@ extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
 
 extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
-extern struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops;
+extern struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops;
 
 extern const u32 nfs4_fattr_bitmap[2];
 extern const u32 nfs4_statfs_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d53aa2d..279ab36 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -984,7 +984,7 @@ static int nfs4_recover_expired_lease(struct nfs_server *server)
 		ret = nfs4_wait_clnt_recover(server->client, clp);
 		if (ret != 0)
 			return ret;
-		if (!test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
+		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 			break;
 		nfs4_schedule_state_recovery(clp);
 	}
@@ -2942,7 +2942,6 @@ static int _nfs4_proc_setclientid_confirm(struct nfs_client *clp, struct rpc_cre
 		spin_lock(&clp->cl_lock);
 		clp->cl_lease_time = fsinfo.lease_time * HZ;
 		clp->cl_last_renewal = now;
-		clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 		spin_unlock(&clp->cl_lock);
 	}
 	return status;
@@ -3690,11 +3689,13 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 }
 
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
+	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
 	.recover_open	= nfs4_open_reclaim,
 	.recover_lock	= nfs4_lock_reclaim,
 };
 
-struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops = {
+struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops = {
+	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
 	.recover_open	= nfs4_open_expired,
 	.recover_lock	= nfs4_lock_expired,
 };
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 300faba..e5cd8ca 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -821,6 +821,27 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 		nfs4_recover_state(clp);
 }
 
+static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
+{
+
+	set_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
+	/* Don't recover state that expired before the reboot */
+	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags)) {
+		clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
+		return 0;
+	}
+	set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
+	return 1;
+}
+
+static int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state)
+{
+	set_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
+	clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
+	set_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state);
+	return 1;
+}
+
 static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_recovery_ops *ops)
 {
 	struct inode *inode = state->inode;
@@ -869,6 +890,8 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 	 * server that doesn't support a grace period.
 	 */
 	list_for_each_entry(state, &sp->so_states, open_states) {
+		if (!test_and_clear_bit(ops->state_flag_bit, &state->flags))
+			continue;
 		if (state->state == 0)
 			continue;
 		status = ops->recover_open(sp, state);
@@ -888,8 +911,7 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 				printk(KERN_ERR "%s: unhandled error %d. Zeroing state\n",
 						__func__, status);
 			case -ENOENT:
-			case -NFS4ERR_RECLAIM_BAD:
-			case -NFS4ERR_RECLAIM_CONFLICT:
+			case -ESTALE:
 				/*
 				 * Open state on this file cannot be recovered
 				 * All we can do is revert to using the zero stateid.
@@ -899,8 +921,13 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 				/* Mark the file as being 'closed' */
 				state->state = 0;
 				break;
+			case -NFS4ERR_RECLAIM_BAD:
+			case -NFS4ERR_RECLAIM_CONFLICT:
+				nfs4_state_mark_reclaim_nograce(sp->so_client, state);
+				break;
 			case -NFS4ERR_EXPIRED:
 			case -NFS4ERR_NO_GRACE:
+				nfs4_state_mark_reclaim_nograce(sp->so_client, state);
 			case -NFS4ERR_STALE_CLIENTID:
 				goto out_err;
 		}
@@ -910,12 +937,26 @@ out_err:
 	return status;
 }
 
-static void nfs4_state_mark_reclaim(struct nfs_client *clp)
+static void nfs4_clear_open_state(struct nfs4_state *state)
+{
+	struct nfs4_lock_state *lock;
+
+	clear_bit(NFS_DELEGATED_STATE, &state->flags);
+	clear_bit(NFS_O_RDONLY_STATE, &state->flags);
+	clear_bit(NFS_O_WRONLY_STATE, &state->flags);
+	clear_bit(NFS_O_RDWR_STATE, &state->flags);
+	list_for_each_entry(lock, &state->lock_states, ls_locks) {
+		lock->ls_seqid.counter = 0;
+		lock->ls_seqid.flags = 0;
+		lock->ls_flags &= ~NFS_LOCK_INITIALIZED;
+	}
+}
+
+static void nfs4_state_mark_reclaim_helper(struct nfs_client *clp, int (*mark_reclaim)(struct nfs_client *clp, struct nfs4_state *state))
 {
 	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
 	struct nfs4_state *state;
-	struct nfs4_lock_state *lock;
 
 	/* Reset all sequence ids to zero */
 	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
@@ -924,20 +965,60 @@ static void nfs4_state_mark_reclaim(struct nfs_client *clp)
 		sp->so_seqid.flags = 0;
 		spin_lock(&sp->so_lock);
 		list_for_each_entry(state, &sp->so_states, open_states) {
-			clear_bit(NFS_DELEGATED_STATE, &state->flags);
-			clear_bit(NFS_O_RDONLY_STATE, &state->flags);
-			clear_bit(NFS_O_WRONLY_STATE, &state->flags);
-			clear_bit(NFS_O_RDWR_STATE, &state->flags);
-			list_for_each_entry(lock, &state->lock_states, ls_locks) {
-				lock->ls_seqid.counter = 0;
-				lock->ls_seqid.flags = 0;
-				lock->ls_flags &= ~NFS_LOCK_INITIALIZED;
-			}
+			if (mark_reclaim(clp, state))
+				nfs4_clear_open_state(state);
 		}
 		spin_unlock(&sp->so_lock);
 	}
 }
 
+static void nfs4_state_start_reclaim_reboot(struct nfs_client *clp)
+{
+	/* Mark all delegations for reclaim */
+	nfs_delegation_mark_reclaim(clp);
+	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_reboot);
+}
+
+static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
+{
+	struct nfs4_state_owner *sp;
+	struct rb_node *pos;
+	struct nfs4_state *state;
+
+	if (!test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
+		return;
+
+	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
+		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
+		spin_lock(&sp->so_lock);
+		list_for_each_entry(state, &sp->so_states, open_states) {
+			if (!test_and_clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags))
+				continue;
+			nfs4_state_mark_reclaim_nograce(clp, state);
+		}
+		spin_unlock(&sp->so_lock);
+	}
+
+	nfs_delegation_reap_unclaimed(clp);
+}
+
+static void nfs_delegation_clear_all(struct nfs_client *clp)
+{
+	nfs_delegation_mark_reclaim(clp);
+	nfs_delegation_reap_unclaimed(clp);
+}
+
+static void nfs4_state_start_reclaim_nograce(struct nfs_client *clp)
+{
+	nfs_delegation_clear_all(clp);
+	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_nograce);
+}
+
+static void nfs4_state_end_reclaim_nograce(struct nfs_client *clp)
+{
+	clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state);
+}
+
 static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recovery_ops *ops)
 {
 	struct rb_node *pos;
@@ -964,11 +1045,25 @@ static int nfs4_check_lease(struct nfs_client *clp)
 		/* Yes there are: try to renew the old lease */
 		status = nfs4_proc_renew(clp, cred);
 		put_rpccred(cred);
+		switch (status) {
+			case -NFS4ERR_CB_PATH_DOWN:
+				set_bit(NFS4CLNT_CB_PATH_DOWN, &clp->cl_state);
+				break;
+			case -NFS4ERR_STALE_CLIENTID:
+			case -NFS4ERR_LEASE_MOVED:
+				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+				nfs4_state_start_reclaim_reboot(clp);
+				break;
+			case -NFS4ERR_EXPIRED:
+				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+				nfs4_state_start_reclaim_nograce(clp);
+		}
 		return status;
 	}
 
 	/* "reboot" to ensure we clear all state on the server */
 	clp->cl_boot_time = CURRENT_TIME;
+	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 	return status;
 }
 
@@ -993,7 +1088,6 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 static int reclaimer(void *ptr)
 {
 	struct nfs_client *clp = ptr;
-	const struct nfs4_state_recovery_ops *ops;
 	int status = 0;
 
 	allow_signal(SIGKILL);
@@ -1001,47 +1095,51 @@ static int reclaimer(void *ptr)
 	/* Ensure exclusive access to NFSv4 state */
 	down_write(&clp->cl_sem);
 	while (!list_empty(&clp->cl_superblocks)) {
-		ops = &nfs4_network_partition_recovery_ops;
 		status = nfs4_check_lease(clp);
-		switch (status) {
-			case 0:
-			case -NFS4ERR_CB_PATH_DOWN:
-				goto out;
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_LEASE_MOVED:
-				ops = &nfs4_reboot_recovery_ops;
-		}
 
-		/* We're going to have to re-establish a clientid */
-		nfs4_state_mark_reclaim(clp);
+		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
+			/* We're going to have to re-establish a clientid */
+			status = nfs4_reclaim_lease(clp);
+			if (status) {
+				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+				if (status == -EAGAIN)
+					continue;
+				goto out_error;
+			}
+		}
 
-		status = nfs4_reclaim_lease(clp);
-		if (status) {
-			if (status == -EAGAIN)
+		/* First recover reboot state... */
+		if (test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
+			/* Note: list is protected by exclusive lock on cl->cl_sem */
+			status = nfs4_do_reclaim(clp, &nfs4_reboot_recovery_ops);
+			if (status == -NFS4ERR_STALE_CLIENTID) {
+				set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
 				continue;
-			goto out_error;
+			}
+			nfs4_state_end_reclaim_reboot(clp);
+			continue;
 		}
 
-		/* Mark all delegations for reclaim */
-		nfs_delegation_mark_reclaim(clp);
-		/* Note: list is protected by exclusive lock on cl->cl_sem */
-		status = nfs4_do_reclaim(clp, ops);
-		if (status < 0) {
-			if (status == -NFS4ERR_NO_GRACE) {
-				ops = &nfs4_network_partition_recovery_ops;
-				status = nfs4_do_reclaim(clp, ops);
-			}
-			if (status == -NFS4ERR_STALE_CLIENTID)
-				continue;
-			if (status == -NFS4ERR_EXPIRED)
-				continue;
+		/* Now recover expired state... */
+		if (test_and_clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state)) {
+			/* Note: list is protected by exclusive lock on cl->cl_sem */
+			status = nfs4_do_reclaim(clp, &nfs4_nograce_recovery_ops);
+			if (status < 0) {
+				set_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state);
+				if (status == -NFS4ERR_STALE_CLIENTID)
+					continue;
+				if (status == -NFS4ERR_EXPIRED)
+					continue;
+				goto out_error;
+			} else
+				nfs4_state_end_reclaim_nograce(clp);
+			continue;
 		}
-		nfs_delegation_reap_unclaimed(clp);
 		break;
 	}
 out:
 	up_write(&clp->cl_sem);
-	if (status == -NFS4ERR_CB_PATH_DOWN)
+	if (test_and_clear_bit(NFS4CLNT_CB_PATH_DOWN, &clp->cl_state))
 		nfs_handle_cb_pathdown(clp);
 	nfs4_clear_recover_bit(clp);
 	nfs_put_client(clp);
@@ -1050,7 +1148,8 @@ out:
 out_error:
 	printk(KERN_WARNING "Error: state recovery failed on NFSv4 server %s"
 			" with error %d\n", clp->cl_hostname, -status);
-	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+	if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
+		nfs4_state_end_reclaim_reboot(clp);
 	goto out;
 }
 


From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 19/69] NFSv4: Clean up for the state loss reclaimer
Date: Tue, 23 Dec 2008 18:02:11 -0500
Message-ID: <20081223230210.13743.12056.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752294AbYLWXXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:48 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFp006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:42 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |  130 ++++++++++++++++++++++++++++++++--------------------
 1 files changed, 81 insertions(+), 49 deletions(-)


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 401ef8b..99182b3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -811,7 +811,7 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 		nfs4_recover_state(clp);
 }
 
-static int nfs4_reclaim_locks(struct nfs4_state_recovery_ops *ops, struct nfs4_state *state)
+static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_recovery_ops *ops)
 {
 	struct inode *inode = state->inode;
 	struct file_lock *fl;
@@ -844,7 +844,7 @@ out_err:
 	return status;
 }
 
-static int nfs4_reclaim_open_state(struct nfs4_state_recovery_ops *ops, struct nfs4_state_owner *sp)
+static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs4_state_recovery_ops *ops)
 {
 	struct nfs4_state *state;
 	struct nfs4_lock_state *lock;
@@ -863,15 +863,15 @@ static int nfs4_reclaim_open_state(struct nfs4_state_recovery_ops *ops, struct n
 			continue;
 		status = ops->recover_open(sp, state);
 		if (status >= 0) {
-			status = nfs4_reclaim_locks(ops, state);
-			if (status < 0)
-				goto out_err;
-			list_for_each_entry(lock, &state->lock_states, ls_locks) {
-				if (!(lock->ls_flags & NFS_LOCK_INITIALIZED))
-					printk("%s: Lock reclaim failed!\n",
+			status = nfs4_reclaim_locks(state, ops);
+			if (status >= 0) {
+				list_for_each_entry(lock, &state->lock_states, ls_locks) {
+					if (!(lock->ls_flags & NFS_LOCK_INITIALIZED))
+						printk("%s: Lock reclaim failed!\n",
 							__func__);
+				}
+				continue;
 			}
-			continue;
 		}
 		switch (status) {
 			default:
@@ -928,45 +928,45 @@ static void nfs4_state_mark_reclaim(struct nfs_client *clp)
 	}
 }
 
-static int reclaimer(void *ptr)
+static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recovery_ops *ops)
 {
-	struct nfs_client *clp = ptr;
-	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
-	struct nfs4_state_recovery_ops *ops;
-	struct rpc_cred *cred;
 	int status = 0;
 
-	allow_signal(SIGKILL);
+	/* Note: list is protected by exclusive lock on cl->cl_sem */
+	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
+		struct nfs4_state_owner *sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
+		status = nfs4_reclaim_open_state(sp, ops);
+		if (status < 0)
+			break;
+	}
+	return status;
+}
+
+static int nfs4_check_lease(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+	int status = -NFS4ERR_EXPIRED;
 
-	/* Ensure exclusive access to NFSv4 state */
-	down_write(&clp->cl_sem);
-	/* Are there any NFS mounts out there? */
-	if (list_empty(&clp->cl_superblocks))
-		goto out;
-restart_loop:
-	ops = &nfs4_network_partition_recovery_ops;
 	/* Are there any open files on this volume? */
 	cred = nfs4_get_renew_cred(clp);
 	if (cred != NULL) {
 		/* Yes there are: try to renew the old lease */
 		status = nfs4_proc_renew(clp, cred);
 		put_rpccred(cred);
-		switch (status) {
-			case 0:
-			case -NFS4ERR_CB_PATH_DOWN:
-				goto out;
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_LEASE_MOVED:
-				ops = &nfs4_reboot_recovery_ops;
-		}
-	} else {
-		/* "reboot" to ensure we clear all state on the server */
-		clp->cl_boot_time = CURRENT_TIME;
+		return status;
 	}
-	/* We're going to have to re-establish a clientid */
-	nfs4_state_mark_reclaim(clp);
-	status = -ENOENT;
+
+	/* "reboot" to ensure we clear all state on the server */
+	clp->cl_boot_time = CURRENT_TIME;
+	return status;
+}
+
+static int nfs4_reclaim_lease(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+	int status = -ENOENT;
+
 	cred = nfs4_get_setclientid_cred(clp);
 	if (cred != NULL) {
 		status = nfs4_init_client(clp, cred);
@@ -974,29 +974,61 @@ restart_loop:
 		/* Handle case where the user hasn't set up machine creds */
 		if (status == -EACCES && cred == clp->cl_machine_cred) {
 			nfs4_clear_machine_cred(clp);
-			goto restart_loop;
+			status = -EAGAIN;
 		}
 	}
-	if (status)
-		goto out_error;
-	/* Mark all delegations for reclaim */
-	nfs_delegation_mark_reclaim(clp);
-	/* Note: list is protected by exclusive lock on cl->cl_sem */
-	for (pos = rb_first(&clp->cl_state_owners); pos != NULL; pos = rb_next(pos)) {
-		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
-		status = nfs4_reclaim_open_state(ops, sp);
+	return status;
+}
+
+static int reclaimer(void *ptr)
+{
+	struct nfs_client *clp = ptr;
+	const struct nfs4_state_recovery_ops *ops;
+	int status = 0;
+
+	allow_signal(SIGKILL);
+
+	/* Ensure exclusive access to NFSv4 state */
+	down_write(&clp->cl_sem);
+	while (!list_empty(&clp->cl_superblocks)) {
+		ops = &nfs4_network_partition_recovery_ops;
+		status = nfs4_check_lease(clp);
+		switch (status) {
+			case 0:
+			case -NFS4ERR_CB_PATH_DOWN:
+				goto out;
+			case -NFS4ERR_STALE_CLIENTID:
+			case -NFS4ERR_LEASE_MOVED:
+				ops = &nfs4_reboot_recovery_ops;
+		}
+
+		/* We're going to have to re-establish a clientid */
+		nfs4_state_mark_reclaim(clp);
+
+		status = nfs4_reclaim_lease(clp);
+		if (status) {
+			if (status == -EAGAIN)
+				continue;
+			goto out_error;
+		}
+
+		/* Mark all delegations for reclaim */
+		nfs_delegation_mark_reclaim(clp);
+		/* Note: list is protected by exclusive lock on cl->cl_sem */
+		status = nfs4_do_reclaim(clp, ops);
 		if (status < 0) {
 			if (status == -NFS4ERR_NO_GRACE) {
 				ops = &nfs4_network_partition_recovery_ops;
-				status = nfs4_reclaim_open_state(ops, sp);
+				status = nfs4_do_reclaim(clp, ops);
 			}
 			if (status == -NFS4ERR_STALE_CLIENTID)
-				goto restart_loop;
+				continue;
 			if (status == -NFS4ERR_EXPIRED)
-				goto restart_loop;
+				continue;
 		}
+		nfs_delegation_reap_unclaimed(clp);
+		break;
 	}
-	nfs_delegation_reap_unclaimed(clp);
 out:
 	up_write(&clp->cl_sem);
 	if (status == -NFS4ERR_CB_PATH_DOWN)


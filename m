From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 32/69] NFSv4: Rename the state reclaimer thread
Date: Tue, 23 Dec 2008 18:02:15 -0500
Message-ID: <20081223230214.13743.75348.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396AbYLWXXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:46 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7c021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is really a more general purpose state management thread at this point.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |    2 +-
 fs/nfs/nfs4_fs.h    |    2 +-
 fs/nfs/nfs4proc.c   |    4 ++--
 fs/nfs/nfs4state.c  |   49 ++++++++++++++++++++++++++++---------------------
 4 files changed, 32 insertions(+), 25 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index ff2c158..4692fdc 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -360,7 +360,7 @@ static int nfs_do_expire_all_delegations(void *ptr)
 
 	allow_signal(SIGKILL);
 
-	if (test_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) != 0)
+	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 		goto out;
 	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0)
 		goto out;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 84a4f52..b7a12e7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -38,7 +38,7 @@ struct idmap;
  ((err) != NFSERR_NOFILEHANDLE))
 
 enum nfs4_client_state {
-	NFS4CLNT_STATE_RECOVER  = 0,
+	NFS4CLNT_MANAGER_RUNNING  = 0,
 	NFS4CLNT_CHECK_LEASE,
 	NFS4CLNT_LEASE_EXPIRED,
 	NFS4CLNT_RECLAIM_REBOOT,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8a2dee9..2a347d4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -207,7 +207,7 @@ static int nfs4_wait_clnt_recover(struct nfs_client *clp)
 
 	might_sleep();
 
-	res = wait_on_bit(&clp->cl_state, NFS4CLNT_STATE_RECOVER,
+	res = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
 			nfs4_wait_bit_killable, TASK_KILLABLE);
 	return res;
 }
@@ -2861,7 +2861,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_EXPIRED:
 			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 			nfs4_schedule_state_recovery(clp);
-			if (test_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) == 0)
+			if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
 				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
 			task->tk_status = 0;
 			return -EAGAIN;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2894502..83f3dd3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -767,32 +767,34 @@ unlock:
 	return status;
 }
 
-static int reclaimer(void *);
+static int nfs4_run_state_manager(void *);
 
-static inline void nfs4_clear_recover_bit(struct nfs_client *clp)
+static void nfs4_clear_state_manager_bit(struct nfs_client *clp)
 {
 	smp_mb__before_clear_bit();
-	clear_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state);
+	clear_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state);
 	smp_mb__after_clear_bit();
-	wake_up_bit(&clp->cl_state, NFS4CLNT_STATE_RECOVER);
+	wake_up_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING);
 	rpc_wake_up(&clp->cl_rpcwaitq);
 }
 
 /*
- * State recovery routine
+ * Schedule the nfs_client asynchronous state management routine
  */
-static void nfs4_recover_state(struct nfs_client *clp)
+static void nfs4_schedule_state_manager(struct nfs_client *clp)
 {
 	struct task_struct *task;
 
+	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
+		return;
 	__module_get(THIS_MODULE);
 	atomic_inc(&clp->cl_count);
-	task = kthread_run(reclaimer, clp, "%s-reclaim",
+	task = kthread_run(nfs4_run_state_manager, clp, "%s-manager",
 				rpc_peeraddr2str(clp->cl_rpcclient,
 							RPC_DISPLAY_ADDR));
 	if (!IS_ERR(task))
 		return;
-	nfs4_clear_recover_bit(clp);
+	nfs4_clear_state_manager_bit(clp);
 	nfs_put_client(clp);
 	module_put(THIS_MODULE);
 }
@@ -806,8 +808,7 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 		return;
 	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
-	if (test_and_set_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) == 0)
-		nfs4_recover_state(clp);
+	nfs4_schedule_state_manager(clp);
 }
 
 static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
@@ -1106,13 +1107,10 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 	return status;
 }
 
-static int reclaimer(void *ptr)
+static void nfs4_state_manager(struct nfs_client *clp)
 {
-	struct nfs_client *clp = ptr;
 	int status = 0;
 
-	allow_signal(SIGKILL);
-
 	/* Ensure exclusive access to NFSv4 state */
 	while (!list_empty(&clp->cl_superblocks)) {
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
@@ -1161,19 +1159,28 @@ static int reclaimer(void *ptr)
 			nfs_client_return_marked_delegations(clp);
 			continue;
 		}
+
+		nfs4_clear_state_manager_bit(clp);
 		break;
 	}
-out:
-	nfs4_clear_recover_bit(clp);
-	nfs_put_client(clp);
-	module_put_and_exit(0);
-	return 0;
+	return;
 out_error:
-	printk(KERN_WARNING "Error: state recovery failed on NFSv4 server %s"
+	printk(KERN_WARNING "Error: state manager failed on NFSv4 server %s"
 			" with error %d\n", clp->cl_hostname, -status);
 	if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
 		nfs4_state_end_reclaim_reboot(clp);
-	goto out;
+	nfs4_clear_state_manager_bit(clp);
+}
+
+static int nfs4_run_state_manager(void *ptr)
+{
+	struct nfs_client *clp = ptr;
+
+	allow_signal(SIGKILL);
+	nfs4_state_manager(clp);
+	nfs_put_client(clp);
+	module_put_and_exit(0);
+	return 0;
 }
 
 /*


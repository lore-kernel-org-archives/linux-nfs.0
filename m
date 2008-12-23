From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 35/69] NFSv4: Clean up nfs_expire_all_delegations()
Date: Tue, 23 Dec 2008 18:02:15 -0500
Message-ID: <20081223230215.13743.93444.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520AbYLWXXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:46 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsg006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let the actual delegreturn stuff be run in the state manager thread rather
than allocating a separate kthread.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   31 +++++--------------------------
 fs/nfs/nfs4_fs.h    |    1 +
 fs/nfs/nfs4renewd.c |   16 +++++++++-------
 fs/nfs/nfs4state.c  |    2 +-
 4 files changed, 16 insertions(+), 34 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 4692fdc..21eda6c 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -354,37 +354,16 @@ static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
 	rcu_read_unlock();
 }
 
-static int nfs_do_expire_all_delegations(void *ptr)
+static void nfs_delegation_run_state_manager(struct nfs_client *clp)
 {
-	struct nfs_client *clp = ptr;
-
-	allow_signal(SIGKILL);
-
-	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
-		goto out;
-	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0)
-		goto out;
-	nfs_client_mark_return_all_delegations(clp);
-	nfs_client_return_marked_delegations(clp);
-out:
-	nfs_put_client(clp);
-	module_put_and_exit(0);
+	if (test_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state))
+		nfs4_schedule_state_manager(clp);
 }
 
 void nfs_expire_all_delegations(struct nfs_client *clp)
 {
-	struct task_struct *task;
-
-	__module_get(THIS_MODULE);
-	atomic_inc(&clp->cl_count);
-	task = kthread_run(nfs_do_expire_all_delegations, clp,
-				"%s-delegreturn",
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_ADDR));
-	if (!IS_ERR(task))
-		return;
-	nfs_put_client(clp);
-	module_put(THIS_MODULE);
+	nfs_client_mark_return_all_delegations(clp);
+	nfs_delegation_run_state_manager(clp);
 }
 
 /*
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b7a12e7..ee5f51e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -227,6 +227,7 @@ extern void nfs4_close_state(struct path *, struct nfs4_state *, mode_t);
 extern void nfs4_close_sync(struct path *, struct nfs4_state *, mode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, mode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
+extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 6101f95..ca557e6 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -77,16 +77,18 @@ nfs4_renew_state(struct work_struct *work)
 	/* Are we close to a lease timeout? */
 	if (time_after(now, last + lease/3)) {
 		cred = nfs4_get_renew_cred_locked(clp);
+		spin_unlock(&clp->cl_lock);
 		if (cred == NULL) {
-			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-			spin_unlock(&clp->cl_lock);
+			if (list_empty(&clp->cl_delegations)) {
+				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+				goto out;
+			}
 			nfs_expire_all_delegations(clp);
-			goto out;
+		} else {
+			/* Queue an asynchronous RENEW. */
+			nfs4_proc_async_renew(clp, cred);
+			put_rpccred(cred);
 		}
-		spin_unlock(&clp->cl_lock);
-		/* Queue an asynchronous RENEW. */
-		nfs4_proc_async_renew(clp, cred);
-		put_rpccred(cred);
 		timeout = (2 * lease) / 3;
 		spin_lock(&clp->cl_lock);
 	} else
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6dc36a0..cd16b30 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -781,7 +781,7 @@ static void nfs4_clear_state_manager_bit(struct nfs_client *clp)
 /*
  * Schedule the nfs_client asynchronous state management routine
  */
-static void nfs4_schedule_state_manager(struct nfs_client *clp)
+void nfs4_schedule_state_manager(struct nfs_client *clp)
 {
 	struct task_struct *task;
 


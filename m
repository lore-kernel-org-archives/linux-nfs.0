From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 1/1] nfs: fix race between renewd, umount, and the state manager in V4.1
Date: Thu, 21 Jan 2010 20:51:11 -0800
Message-ID: <1264135871-13083-1-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43177 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753833Ab0AVExx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 23:53:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/client.c    |   38 ++++++++++----------------------------
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    3 +++
 fs/nfs/nfs4state.c |   17 ++++++++++++++++-
 4 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d0b060a..3efde50 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -164,19 +164,6 @@ error_0:
 	return ERR_PTR(err);
 }
 
-static void nfs4_shutdown_client(struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4
-	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
-		nfs4_kill_renewd(clp);
-	BUG_ON(!RB_EMPTY_ROOT(&clp->cl_state_owners));
-	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
-		nfs_idmap_delete(clp);
-
-	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
-#endif
-}
-
 /*
  * Destroy the NFS4 callback service
  */
@@ -188,22 +175,18 @@ static void nfs4_destroy_callback(struct nfs_client *clp)
 #endif /* CONFIG_NFS_V4 */
 }
 
-/*
- * Clears/puts all minor version specific parts from an nfs_client struct
- * reverting it to minorversion 0.
- */
-static void nfs4_clear_client_minor_version(struct nfs_client *clp)
+static void nfs4_shutdown_client(struct nfs_client *clp)
 {
-#ifdef CONFIG_NFS_V4_1
-	if (nfs4_has_session(clp)) {
-		nfs4_destroy_session(clp->cl_session);
-		clp->cl_session = NULL;
-	}
-
-	clp->cl_call_sync = _nfs4_call_sync;
-#endif /* CONFIG_NFS_V4_1 */
-
+#ifdef CONFIG_NFS_V4
+	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
+		nfs4_kill_renewd(clp);
+	nfs4_clear_session(clp);
 	nfs4_destroy_callback(clp);
+	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
+		nfs_idmap_delete(clp);
+
+	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+#endif
 }
 
 /*
@@ -213,7 +196,6 @@ static void nfs_free_client(struct nfs_client *clp)
 {
 	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
 
-	nfs4_clear_client_minor_version(clp);
 	nfs4_shutdown_client(clp);
 
 	nfs_fscache_release_client_cookie(clp);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index cd93dfc..fbeec98 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -263,6 +263,7 @@ extern void nfs4_renew_state(struct work_struct *);
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
+void nfs4_clear_session(struct nfs_client *clp);
 #if defined(CONFIG_NFS_V4_1)
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ec9f075..a99c7d3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5004,6 +5004,9 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_client *clp = (struct nfs_client *)data;
 
+	if (!nfs4_has_session(clp))
+		return;
+
 	nfs41_sequence_done(clp, task->tk_msg.rpc_resp, task->tk_status);
 
 	if (task->tk_status < 0) {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 069dcb3..dc3cfbf 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -199,6 +199,16 @@ struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp)
 	return cred;
 }
 
+void nfs4_clear_session(struct nfs_client *clp)
+{
+	if (nfs4_has_session(clp)) {
+		nfs4_begin_drain_session(clp);
+		nfs4_destroy_session(clp->cl_session);
+		clp->cl_session = NULL;
+	}
+	clp->cl_call_sync = _nfs4_call_sync;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
@@ -878,7 +888,11 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
 	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 		return;
 	__module_get(THIS_MODULE);
-	atomic_inc(&clp->cl_count);
+	if (!atomic_inc_not_zero(&clp->cl_count)) {
+		nfs4_clear_state_manager_bit(clp);
+		module_put(THIS_MODULE);
+		return;
+	}
 	task = kthread_run(nfs4_run_state_manager, clp, "%s-manager",
 				rpc_peeraddr2str(clp->cl_rpcclient,
 							RPC_DISPLAY_ADDR));
@@ -1336,6 +1350,7 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
 static int nfs4_end_drain_session(struct nfs_client *clp) { return 0; }
+void nfs4_clear_session(struct nfs_client *clp) { return 0; }
 static int nfs4_recall_slot(struct nfs_client *clp) { return 0; }
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.6.2.5


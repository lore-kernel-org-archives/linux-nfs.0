Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21205 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754625Ab0ANAMM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jan 2010 19:12:12 -0500
From: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 1/1] nfs: fix race between renewd, umount, and the state manager in V4.1
Date: Wed, 13 Jan 2010 16:15:31 -0800
Message-Id: <1263428131-2161-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/client.c    |   27 +++++++++++++--------------
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    4 ++++
 fs/nfs/nfs4state.c |    8 ++++++--
 4 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d0b060a..6c7d407 100644
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
@@ -206,6 +193,19 @@ static void nfs4_clear_client_minor_version(struct nfs_client *clp)
 	nfs4_destroy_callback(clp);
 }
 
+static void nfs4_shutdown_client(struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4
+	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
+		nfs4_kill_renewd(clp);
+	nfs4_clear_client_minor_version(clp);
+	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
+		nfs_idmap_delete(clp);
+
+	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+#endif
+}
+
 /*
  * Destroy a shared client record
  */
@@ -213,7 +213,6 @@ static void nfs_free_client(struct nfs_client *clp)
 {
 	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
 
-	nfs4_clear_client_minor_version(clp);
 	nfs4_shutdown_client(clp);
 
 	nfs_fscache_release_client_cookie(clp);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 865265b..783c986 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -262,6 +262,7 @@ extern void nfs4_renew_state(struct work_struct *);
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
+int nfs4_begin_drain_session(struct nfs_client *clp);
 #if defined(CONFIG_NFS_V4_1)
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a4b7d69..f424b1a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4728,6 +4728,7 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 
 void nfs4_destroy_session(struct nfs4_session *session)
 {
+	nfs4_begin_drain_session(session->clp);
 	nfs4_proc_destroy_session(session);
 	dprintk("%s Destroy backchannel for xprt %p\n",
 		__func__, session->clp->cl_rpcclient->cl_xprt);
@@ -4996,6 +4997,9 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_client *clp = (struct nfs_client *)data;
+
+	if (!nfs4_has_session(clp))
+		return;
 
 	nfs41_sequence_done(clp, task->tk_msg.rpc_resp, task->tk_status);
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6d263ed..09f4402 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -156,7 +156,7 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 	}
 }
 
-static int nfs4_begin_drain_session(struct nfs_client *clp)
+int nfs4_begin_drain_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
 	struct nfs4_slot_table *tbl = &ses->fc_slot_table;
@@ -878,7 +878,11 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
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
-- 
1.6.2.5


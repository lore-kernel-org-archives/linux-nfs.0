Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:37427 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755487Ab3ETRRs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 May 2013 13:17:48 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] NFSv4.1: Ensure that reclaim_complete uses the right credential
Date: Mon, 20 May 2013 13:17:04 -0400
Message-Id: <1369070227-40671-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369070227-40671-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to use the same credential for reclaim_complete as we used
for the exchange_id call.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |  2 +-
 fs/nfs/nfs4proc.c  |  4 +++-
 fs/nfs/nfs4state.c | 13 ++++++++++---
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a1dd768..e64a00c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -194,7 +194,7 @@ struct nfs4_state_recovery_ops {
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
 	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
 	struct rpc_cred * (*get_clid_cred)(struct nfs_client *);
-	int (*reclaim_complete)(struct nfs_client *);
+	int (*reclaim_complete)(struct nfs_client *, struct rpc_cred *);
 	int (*detect_trunking)(struct nfs_client *, struct nfs_client **,
 		struct rpc_cred *);
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2956973..9d90f57 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6159,12 +6159,14 @@ static const struct rpc_call_ops nfs4_reclaim_complete_call_ops = {
 /*
  * Issue a global reclaim complete.
  */
-static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
+static int nfs41_proc_reclaim_complete(struct nfs_client *clp,
+		struct rpc_cred *cred)
 {
 	struct nfs4_reclaim_complete_data *calldata;
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RECLAIM_COMPLETE],
+		.rpc_cred = cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clp->cl_rpcclient,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 300d17d..30b9ba1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1564,11 +1564,12 @@ static void nfs4_state_start_reclaim_reboot(struct nfs_client *clp)
 }
 
 static void nfs4_reclaim_complete(struct nfs_client *clp,
-				 const struct nfs4_state_recovery_ops *ops)
+				 const struct nfs4_state_recovery_ops *ops,
+				 struct rpc_cred *cred)
 {
 	/* Notify the server we're done reclaiming our state */
 	if (ops->reclaim_complete)
-		(void)ops->reclaim_complete(clp);
+		(void)ops->reclaim_complete(clp, cred);
 }
 
 static void nfs4_clear_reclaim_server(struct nfs_server *server)
@@ -1613,9 +1614,15 @@ static int nfs4_state_clear_reclaim_reboot(struct nfs_client *clp)
 
 static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 {
+	const struct nfs4_state_recovery_ops *ops;
+	struct rpc_cred *cred;
+
 	if (!nfs4_state_clear_reclaim_reboot(clp))
 		return;
-	nfs4_reclaim_complete(clp, clp->cl_mvops->reboot_recovery_ops);
+	ops = clp->cl_mvops->reboot_recovery_ops;
+	cred = ops->get_clid_cred(clp);
+	nfs4_reclaim_complete(clp, ops, cred);
+	put_rpccred(cred);
 }
 
 static void nfs_delegation_clear_all(struct nfs_client *clp)
-- 
1.8.1.4


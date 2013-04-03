Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27013 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761880Ab3DCXdc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 19:33:32 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/4] NFSv4: Clean up nfs_expire_all_delegations
Date: Wed,  3 Apr 2013 19:33:26 -0400
Message-Id: <1365032007-59876-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365032007-59876-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1365032007-59876-1-git-send-email-Trond.Myklebust@netapp.com>
 <1365032007-59876-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c | 43 +++++++++++++++++++++++++++----------------
 1 file changed, 27 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 213f1bb..60e2e6e 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -514,6 +514,33 @@ static bool nfs_server_mark_return_all_delegations(struct nfs_server *server)
 	return ret;
 }
 
+static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
+{
+	struct nfs_server *server;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+		nfs_server_mark_return_all_delegations(server);
+	rcu_read_unlock();
+}
+
+static void nfs_delegation_run_state_manager(struct nfs_client *clp)
+{
+	if (test_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state))
+		nfs4_schedule_state_manager(clp);
+}
+
+/**
+ * nfs_expire_all_delegations
+ * @clp: client to process
+ *
+ */
+void nfs_expire_all_delegations(struct nfs_client *clp)
+{
+	nfs_client_mark_return_all_delegations(clp);
+	nfs_delegation_run_state_manager(clp);
+}
+
 /**
  * nfs_super_return_all_delegations - return delegations for one superblock
  * @sb: sb to process
@@ -561,12 +588,6 @@ static void nfs_client_mark_return_all_delegation_types(struct nfs_client *clp,
 	rcu_read_unlock();
 }
 
-static void nfs_delegation_run_state_manager(struct nfs_client *clp)
-{
-	if (test_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state))
-		nfs4_schedule_state_manager(clp);
-}
-
 void nfs_remove_bad_delegation(struct inode *inode)
 {
 	struct nfs_delegation *delegation;
@@ -591,16 +612,6 @@ void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags)
 	nfs_delegation_run_state_manager(clp);
 }
 
-/**
- * nfs_expire_all_delegations
- * @clp: client to process
- *
- */
-void nfs_expire_all_delegations(struct nfs_client *clp)
-{
-	nfs_expire_all_delegation_types(clp, FMODE_READ|FMODE_WRITE);
-}
-
 static void nfs_mark_return_unreferenced_delegations(struct nfs_server *server)
 {
 	struct nfs_delegation *delegation;
-- 
1.8.1.4


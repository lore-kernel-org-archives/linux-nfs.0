Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47834 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab2CJRW0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Mar 2012 12:22:26 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.0: Re-establish the callback channel on NFS4ERR_CB_PATHDOWN
Date: Sat, 10 Mar 2012 12:22:15 -0500
Message-Id: <1331400135-17242-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the NFSv4.0 server tells us that it can no-longer talk to us
on the callback channel, we should attempt a new SETCLIENTID in
order to re-transmit the callback channel information.

Note that as long as we do not change the boot verifier, this is
a safe procedure; the server is required to keep our state.

Also move the function nfs_handle_cb_pathdown to fs/nfs/nfs4state.c,
and change the name in order to mark it as being specific to NFSv4.0.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c |   17 -----------------
 fs/nfs/delegation.h |    1 -
 fs/nfs/nfs4state.c  |   18 ++++++++++++++++--
 3 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index e27c097..12de883 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -453,11 +453,6 @@ static void nfs_client_mark_return_all_delegation_types(struct nfs_client *clp,
 	rcu_read_unlock();
 }
 
-static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
-{
-	nfs_client_mark_return_all_delegation_types(clp, FMODE_READ|FMODE_WRITE);
-}
-
 static void nfs_delegation_run_state_manager(struct nfs_client *clp)
 {
 	if (test_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state))
@@ -498,18 +493,6 @@ void nfs_expire_all_delegations(struct nfs_client *clp)
 	nfs_expire_all_delegation_types(clp, FMODE_READ|FMODE_WRITE);
 }
 
-/**
- * nfs_handle_cb_pathdown - return all delegations after NFS4ERR_CB_PATH_DOWN
- * @clp: client to process
- *
- */
-void nfs_handle_cb_pathdown(struct nfs_client *clp)
-{
-	if (clp == NULL)
-		return;
-	nfs_client_mark_return_all_delegations(clp);
-}
-
 static void nfs_mark_return_unreferenced_delegations(struct nfs_server *server)
 {
 	struct nfs_delegation *delegation;
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index e193012..cd6a7a8 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -42,7 +42,6 @@ void nfs_super_return_all_delegations(struct super_block *sb);
 void nfs_expire_all_delegations(struct nfs_client *clp);
 void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags);
 void nfs_expire_unreferenced_delegations(struct nfs_client *clp);
-void nfs_handle_cb_pathdown(struct nfs_client *clp);
 int nfs_client_return_marked_delegations(struct nfs_client *clp);
 int nfs_delegations_present(struct nfs_client *clp);
 void nfs_remove_bad_delegation(struct inode *inode);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index de44804..5fa43cd 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1097,9 +1097,23 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_lease_recovery);
 
+/*
+ * nfs40_handle_cb_pathdown - return all delegations after NFS4ERR_CB_PATH_DOWN
+ * @clp: client to process
+ *
+ * Set the NFS4CLNT_LEASE_EXPIRED state in order to force a
+ * resend of the SETCLIENTID and hence re-establish the
+ * callback channel. Then return all existing delegations.
+ */
+static void nfs40_handle_cb_pathdown(struct nfs_client *clp)
+{
+	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+	nfs_expire_all_delegations(clp);
+}
+
 void nfs4_schedule_path_down_recovery(struct nfs_client *clp)
 {
-	nfs_handle_cb_pathdown(clp);
+	nfs40_handle_cb_pathdown(clp);
 	nfs4_schedule_state_manager(clp);
 }
 
@@ -1444,7 +1458,7 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 		case 0:
 			break;
 		case -NFS4ERR_CB_PATH_DOWN:
-			nfs_handle_cb_pathdown(clp);
+			nfs40_handle_cb_pathdown(clp);
 			break;
 		case -NFS4ERR_NO_GRACE:
 			nfs4_state_end_reclaim_reboot(clp);
-- 
1.7.7.6


From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 31/69] NFSv4: Clean up NFS4ERR_CB_PATH_DOWN error
 management...
Date: Tue, 23 Dec 2008 18:02:14 -0500
Message-ID: <20081223230214.13743.71023.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304AbYLWXXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:46 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7a021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a delegation cleanup phase to the state management loop, and do the
NFS4ERR_CB_PATH_DOWN recovery there.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   14 ++++++++------
 fs/nfs/delegation.h |    1 +
 fs/nfs/nfs4_fs.h    |    2 +-
 fs/nfs/nfs4state.c  |    9 ++++++---
 4 files changed, 16 insertions(+), 10 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index bc9d4f9..ff2c158 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -258,7 +258,7 @@ static int __nfs_inode_return_delegation(struct inode *inode, struct nfs_delegat
 /*
  * Return all delegations that have been marked for return
  */
-static void nfs_client_return_marked_delegations(struct nfs_client *clp)
+void nfs_client_return_marked_delegations(struct nfs_client *clp)
 {
 	struct nfs_delegation *delegation;
 	struct inode *inode;
@@ -342,15 +342,16 @@ void nfs_super_return_all_delegations(struct super_block *sb)
 	nfs_client_return_marked_delegations(clp);
 }
 
-static void nfs_client_return_all_delegations(struct nfs_client *clp)
+static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
 {
 	struct nfs_delegation *delegation;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list)
+	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
 		set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
+		set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+	}
 	rcu_read_unlock();
-	nfs_client_return_marked_delegations(clp);
 }
 
 static int nfs_do_expire_all_delegations(void *ptr)
@@ -363,7 +364,8 @@ static int nfs_do_expire_all_delegations(void *ptr)
 		goto out;
 	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0)
 		goto out;
-	nfs_client_return_all_delegations(clp);
+	nfs_client_mark_return_all_delegations(clp);
+	nfs_client_return_marked_delegations(clp);
 out:
 	nfs_put_client(clp);
 	module_put_and_exit(0);
@@ -392,7 +394,7 @@ void nfs_handle_cb_pathdown(struct nfs_client *clp)
 {
 	if (clp == NULL)
 		return;
-	nfs_client_return_all_delegations(clp);
+	nfs_client_mark_return_all_delegations(clp);
 }
 
 struct recall_threadargs {
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index c772bab..56f3eb5 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -40,6 +40,7 @@ struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs
 void nfs_super_return_all_delegations(struct super_block *sb);
 void nfs_expire_all_delegations(struct nfs_client *clp);
 void nfs_handle_cb_pathdown(struct nfs_client *clp);
+void nfs_client_return_marked_delegations(struct nfs_client *clp);
 
 void nfs_delegation_mark_reclaim(struct nfs_client *clp);
 void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 46cbc0c..84a4f52 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -43,7 +43,7 @@ enum nfs4_client_state {
 	NFS4CLNT_LEASE_EXPIRED,
 	NFS4CLNT_RECLAIM_REBOOT,
 	NFS4CLNT_RECLAIM_NOGRACE,
-	NFS4CLNT_CB_PATH_DOWN,
+	NFS4CLNT_DELEGRETURN,
 };
 
 /*
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3d78706..2894502 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1027,7 +1027,7 @@ static void nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 {
 	switch (error) {
 		case -NFS4ERR_CB_PATH_DOWN:
-			set_bit(NFS4CLNT_CB_PATH_DOWN, &clp->cl_state);
+			nfs_handle_cb_pathdown(clp);
 			break;
 		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_LEASE_MOVED:
@@ -1156,11 +1156,14 @@ static int reclaimer(void *ptr)
 				nfs4_state_end_reclaim_nograce(clp);
 			continue;
 		}
+
+		if (test_and_clear_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state)) {
+			nfs_client_return_marked_delegations(clp);
+			continue;
+		}
 		break;
 	}
 out:
-	if (test_and_clear_bit(NFS4CLNT_CB_PATH_DOWN, &clp->cl_state))
-		nfs_handle_cb_pathdown(clp);
 	nfs4_clear_recover_bit(clp);
 	nfs_put_client(clp);
 	module_put_and_exit(0);


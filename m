Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34175 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757562AbcHaCMR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 22:12:17 -0400
Received: by mail-it0-f65.google.com with SMTP id e124so1141084ith.1
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 19:12:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] NFSv4.1: Test delegation stateids when server declares "some state revoked"
Date: Tue, 30 Aug 2016 22:11:42 -0400
Message-Id: <1472609504-69094-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472609504-69094-5-git-send-email-trond.myklebust@primarydata.com>
References: <1472609504-69094-1-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-2-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-3-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-4-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to RFC5661, if any of the SEQUENCE status bits
SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED, SEQ4_STATUS_ADMIN_STATE_REVOKED,
or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need to use
TEST_STATEID to figure out which stateids have been revoked, so we
can acknowledge the loss of state using FREE_STATEID.

While we already do this for open and lock state, we have not been doing
so for all the delegations.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/delegation.h |  4 +++
 fs/nfs/nfs4_fs.h    |  3 ++
 fs/nfs/nfs4proc.c   |  9 +++++
 fs/nfs/nfs4state.c  | 17 +++++-----
 5 files changed, 121 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 76dc11ecdedd..ff0c1a0feb9d 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -802,8 +802,15 @@ static void nfs_delegation_mark_reclaim_server(struct nfs_server *server)
 {
 	struct nfs_delegation *delegation;
 
-	list_for_each_entry_rcu(delegation, &server->delegations, super_list)
+	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
+		/*
+		 * If the delegation may have been admin revoked, then we
+		 * cannot reclaim it.
+		 */
+		if (test_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags))
+			continue;
 		set_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
+	}
 }
 
 /**
@@ -867,6 +874,94 @@ restart:
 	rcu_read_unlock();
 }
 
+static void nfs_mark_test_expired_delegation(struct nfs_server *server,
+	    struct nfs_delegation *delegation)
+{
+	clear_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
+	set_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags);
+	set_bit(NFS4CLNT_DELEGATION_EXPIRED, &server->nfs_client->cl_state);
+}
+
+static void nfs_delegation_mark_test_expired_server(struct nfs_server *server)
+{
+	struct nfs_delegation *delegation;
+
+	list_for_each_entry_rcu(delegation, &server->delegations, super_list)
+		nfs_mark_test_expired_delegation(server, delegation);
+}
+
+/**
+ * nfs_mark_test_expired_all_delegations - mark all delegations for testing
+ * @clp: nfs_client to process
+ *
+ * Iterates through all the delegations associated with this server and
+ * marks them as needing to be checked for validity.
+ */
+void nfs_mark_test_expired_all_delegations(struct nfs_client *clp)
+{
+	struct nfs_server *server;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+		nfs_delegation_mark_test_expired_server(server);
+	rcu_read_unlock();
+}
+
+/**
+ * nfs_reap_expired_delegations - reap expired delegations
+ * @clp: nfs_client to process
+ *
+ * Iterates through all the delegations associated with this server and
+ * checks if they have may have been revoked. This function is usually
+ * expected to be called in cases where the server may have lost its
+ * lease.
+ */
+void nfs_reap_expired_delegations(struct nfs_client *clp)
+{
+	const struct nfs4_minor_version_ops *ops = clp->cl_mvops;
+	struct nfs_delegation *delegation;
+	struct nfs_server *server;
+	struct inode *inode;
+	struct rpc_cred *cred;
+	nfs4_stateid stateid;
+
+restart:
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		list_for_each_entry_rcu(delegation, &server->delegations,
+								super_list) {
+			if (test_bit(NFS_DELEGATION_RETURNING,
+						&delegation->flags))
+				continue;
+			if (test_bit(NFS_DELEGATION_TEST_EXPIRED,
+						&delegation->flags) == 0)
+				continue;
+			if (!nfs_sb_active(server->super))
+				continue;
+			inode = nfs_delegation_grab_inode(delegation);
+			if (inode == NULL) {
+				rcu_read_unlock();
+				nfs_sb_deactive(server->super);
+				goto restart;
+			}
+			cred = get_rpccred_rcu(delegation->cred);
+			nfs4_stateid_copy(&stateid, &delegation->stateid);
+			clear_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags);
+			rcu_read_unlock();
+			if (cred != NULL &&
+			    ops->test_and_free_expired(server, &stateid, cred) < 0) {
+				nfs_revoke_delegation(inode, &stateid);
+				nfs_inode_find_state_and_recover(inode, &stateid);
+			}
+			put_rpccred(cred);
+			iput(inode);
+			nfs_sb_deactive(server->super);
+			goto restart;
+		}
+	}
+	rcu_read_unlock();
+}
+
 /**
  * nfs_delegations_present - check for existence of delegations
  * @clp: client state handle
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index d40827af5913..1442e3b1521d 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -32,6 +32,7 @@ enum {
 	NFS_DELEGATION_REFERENCED,
 	NFS_DELEGATION_RETURNING,
 	NFS_DELEGATION_REVOKED,
+	NFS_DELEGATION_TEST_EXPIRED,
 };
 
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
@@ -52,6 +53,9 @@ void nfs_remove_bad_delegation(struct inode *inode, const nfs4_stateid *stateid)
 void nfs_delegation_mark_reclaim(struct nfs_client *clp);
 void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
 
+void nfs_mark_test_expired_all_delegations(struct nfs_client *clp);
+void nfs_reap_expired_delegations(struct nfs_client *clp);
+
 /* NFSv4 delegation-related procedures */
 int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync);
 int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid, fmode_t type);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f230aa62ca59..13db43912f51 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -39,6 +39,7 @@ enum nfs4_client_state {
 	NFS4CLNT_BIND_CONN_TO_SESSION,
 	NFS4CLNT_MOVED,
 	NFS4CLNT_LEASE_MOVED,
+	NFS4CLNT_DELEGATION_EXPIRED,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
@@ -57,6 +58,8 @@ struct nfs4_minor_version_ops {
 			struct nfs_fsinfo *);
 	void	(*free_lock_state)(struct nfs_server *,
 			struct nfs4_lock_state *);
+	int	(*test_and_free_expired)(struct nfs_server *,
+			nfs4_stateid *, struct rpc_cred *);
 	struct nfs_seqid *
 		(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
 	const struct rpc_call_ops *call_sync_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e980117b7973..412f1daf1515 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2405,6 +2405,13 @@ static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 	return nfs4_open_expired(sp, state);
 }
 
+static int nfs40_test_and_free_expired_stateid(struct nfs_server *server,
+		nfs4_stateid *stateid,
+		struct rpc_cred *cred)
+{
+	return -NFS4ERR_BAD_STATEID;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 static int nfs41_test_and_free_expired_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
@@ -8848,6 +8855,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
 	.free_lock_state = nfs4_release_lockowner,
+	.test_and_free_expired = nfs40_test_and_free_expired_stateid,
 	.alloc_seqid = nfs_alloc_seqid,
 	.call_sync_ops = &nfs40_call_sync_ops,
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
@@ -8875,6 +8883,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
+	.test_and_free_expired = nfs41_test_and_free_expired_stateid,
 	.alloc_seqid = nfs_alloc_no_seqid,
 	.call_sync_ops = &nfs41_call_sync_ops,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cada00aa5096..c696514106d8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1656,15 +1656,9 @@ static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 	put_rpccred(cred);
 }
 
-static void nfs_delegation_clear_all(struct nfs_client *clp)
-{
-	nfs_delegation_mark_reclaim(clp);
-	nfs_delegation_reap_unclaimed(clp);
-}
-
 static void nfs4_state_start_reclaim_nograce(struct nfs_client *clp)
 {
-	nfs_delegation_clear_all(clp);
+	nfs_mark_test_expired_all_delegations(clp);
 	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_nograce);
 }
 
@@ -2195,7 +2189,7 @@ static void nfs41_handle_all_state_revoked(struct nfs_client *clp)
 
 static void nfs41_handle_some_state_revoked(struct nfs_client *clp)
 {
-	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_nograce);
+	nfs4_state_start_reclaim_nograce(clp);
 	nfs4_schedule_state_manager(clp);
 
 	dprintk("%s: state revoked on server %s\n", __func__, clp->cl_hostname);
@@ -2410,6 +2404,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			nfs4_state_end_reclaim_reboot(clp);
 		}
 
+		/* Detect expired delegations... */
+		if (test_and_clear_bit(NFS4CLNT_DELEGATION_EXPIRED, &clp->cl_state)) {
+			section = "detect expired delegations";
+			nfs_reap_expired_delegations(clp);
+			continue;
+		}
+
 		/* Now recover expired state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state)) {
 			section = "reclaim nograce";
-- 
2.7.4


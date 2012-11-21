Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6115 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218Ab2KVSme (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:42:34 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 19/20] NFSv4.1: Remove the state manager code to resize the slot table
Date: Wed, 21 Nov 2012 17:43:18 -0500
Message-Id: <1353537799-60488-20-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-19-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-18-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-19-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The state manager no longer needs any special machinery to stop the
session flow and resize the slot table. It is all done on the fly by
the SEQUENCE op code now.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |  1 -
 fs/nfs/nfs4_fs.h       |  4 ----
 fs/nfs/nfs4proc.c      | 17 -----------------
 fs/nfs/nfs4state.c     | 33 ---------------------------------
 4 files changed, 55 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a0546ec..8610bd1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -570,7 +570,6 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	status = htonl(NFS4_OK);
 
 	nfs41_set_target_slotid(fc_tbl, args->crsa_target_highest_slotid);
-	nfs41_handle_recall_slot(cps->clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 856bc49..fa1a055 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -21,7 +21,6 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_SESSION_RESET,
-	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_LEASE_CONFIRM,
 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
 	NFS4CLNT_PURGE_STATE,
@@ -260,8 +259,6 @@ extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 
 extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
 		u32 target_highest_slotid);
-extern int nfs4_resize_slot_table(struct nfs4_slot_table *tbl,
-		u32 max_reqs, u32 ivalue);
 
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
@@ -358,7 +355,6 @@ extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
-extern void nfs41_handle_recall_slot(struct nfs_client *clp);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index adedcfa..ec2b034 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5831,23 +5831,6 @@ out:
 	return ret;
 }
 
-int nfs4_resize_slot_table(struct nfs4_slot_table *tbl,
-		 u32 max_reqs, u32 ivalue)
-{
-	int ret;
-
-	if (max_reqs > NFS4_MAX_SLOT_TABLE)
-		max_reqs = NFS4_MAX_SLOT_TABLE;
-	ret = nfs4_grow_slot_table(tbl, max_reqs, ivalue);
-	if (ret)
-		return ret;
-	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_shrink_slot_table(tbl, max_reqs);
-	tbl->max_slotid = max_reqs - 1;
-	spin_unlock(&tbl->slot_tbl_lock);
-	return 0;
-}
-
 /* Destroy the slot table */
 static void nfs4_destroy_slot_tables(struct nfs4_session *session)
 {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c14b2c7..3940cd4 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -302,7 +302,6 @@ static void nfs41_finish_session_reset(struct nfs_client *clp)
 	clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 	clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 	/* create_session negotiated new slot table */
-	clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
 	clear_bit(NFS4CLNT_BIND_CONN_TO_SESSION, &clp->cl_state);
 	nfs41_setup_state_renewal(clp);
 }
@@ -1905,14 +1904,6 @@ void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_session_recovery);
 
-void nfs41_handle_recall_slot(struct nfs_client *clp)
-{
-	set_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
-	dprintk("%s: scheduling slot recall for server %s\n", __func__,
-			clp->cl_hostname);
-	nfs4_schedule_state_manager(clp);
-}
-
 static void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
@@ -2022,20 +2013,6 @@ out:
 	return status;
 }
 
-static int nfs4_recall_slot(struct nfs_client *clp)
-{
-	struct nfs4_slot_table *fc_tbl;
-	u32 new_size;
-
-	if (!nfs4_has_session(clp))
-		return 0;
-	nfs4_begin_drain_session(clp);
-
-	fc_tbl = &clp->cl_session->fc_slot_table;
-	new_size = fc_tbl->server_highest_slotid + 1;
-	return nfs4_resize_slot_table(fc_tbl, new_size, 1);
-}
-
 static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
@@ -2066,7 +2043,6 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
 static int nfs4_end_drain_session(struct nfs_client *clp) { return 0; }
-static int nfs4_recall_slot(struct nfs_client *clp) { return 0; }
 
 static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 {
@@ -2126,15 +2102,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
-		/* Recall session slots */
-		if (test_and_clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state)) {
-			section = "recall slot";
-			status = nfs4_recall_slot(clp);
-			if (status < 0)
-				goto out_error;
-			continue;
-		}
-
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			section = "reclaim reboot";
-- 
1.7.11.7


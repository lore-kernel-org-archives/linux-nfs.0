Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755974Ab2KZURM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:12 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 23/28] NFSv4.1: Clean up session draining
Date: Mon, 26 Nov 2012 15:16:40 -0500
Message-Id: <1353961005-63874-24-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-23-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-19-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-20-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-21-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-22-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-23-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Coalesce nfs4_check_drain_bc_complete and nfs4_check_drain_fc_complete
into a single function that can be called when the slot table is known
to be empty, then change nfs4_callback_free_slot() and nfs4_free_slot()
to use it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback.h     |  2 --
 fs/nfs/callback_xdr.c |  2 +-
 fs/nfs/nfs4_fs.h      |  8 ++++++++
 fs/nfs/nfs4proc.c     | 38 ++++++--------------------------------
 fs/nfs/nfs4state.c    | 10 ++++++++++
 5 files changed, 25 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index e75631e..efd54f0 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -167,8 +167,6 @@ extern __be32 nfs4_callback_layoutrecall(
 	struct cb_layoutrecallargs *args,
 	void *dummy, struct cb_process_state *cps);
 
-extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
-
 struct cb_devicenotifyitem {
 	uint32_t		cbd_notify_type;
 	uint32_t		cbd_layout_type;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 81e8c7d..ea6a7b1 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -762,7 +762,7 @@ static void nfs4_callback_free_slot(struct nfs4_session *session)
 	 * A single slot, so highest used slotid is either 0 or -1
 	 */
 	tbl->highest_used_slotid = NFS4_NO_SLOT;
-	nfs4_check_drain_bc_complete(session);
+	nfs4_session_drain_complete(session, tbl);
 	spin_unlock(&tbl->slot_tbl_lock);
 }
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 0a109ec..16b1937 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -335,6 +335,14 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **, struct rpc_cred *);
 extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
 extern void nfs41_server_notify_target_slotid_update(struct nfs_client *clp);
+
+extern void nfs4_session_drain_complete(struct nfs4_session *session,
+		struct nfs4_slot_table *tbl);
+
+static inline bool nfs4_session_draining(struct nfs4_session *session)
+{
+	return !!test_bit(NFS4_SESSION_DRAINING, &session->session_state);
+}
 #else
 static inline void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5f78c8c..45c5d7b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -445,8 +445,10 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
 		u32 new_max = find_last_bit(tbl->used_slots, slotid);
 		if (new_max < slotid)
 			tbl->highest_used_slotid = new_max;
-		else
+		else {
 			tbl->highest_used_slotid = NFS4_NO_SLOT;
+			nfs4_session_drain_complete(tbl->session, tbl);
+		}
 	}
 	dprintk("%s: slotid %u highest_used_slotid %d\n", __func__,
 		slotid, tbl->highest_used_slotid);
@@ -458,36 +460,6 @@ bool nfs4_set_task_privileged(struct rpc_task *task, void *dummy)
 	return true;
 }
 
-/*
- * Signal state manager thread if session fore channel is drained
- */
-static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
-{
-	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
-		rpc_wake_up_first(&ses->fc_slot_table.slot_tbl_waitq,
-				nfs4_set_task_privileged, NULL);
-		return;
-	}
-
-	if (ses->fc_slot_table.highest_used_slotid != NFS4_NO_SLOT)
-		return;
-
-	dprintk("%s COMPLETE: Session Fore Channel Drained\n", __func__);
-	complete(&ses->fc_slot_table.complete);
-}
-
-/*
- * Signal state manager thread if session back channel is drained
- */
-void nfs4_check_drain_bc_complete(struct nfs4_session *ses)
-{
-	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state) ||
-	    ses->bc_slot_table.highest_used_slotid != NFS4_NO_SLOT)
-		return;
-	dprintk("%s COMPLETE: Session Back Channel Drained\n", __func__);
-	complete(&ses->bc_slot_table.complete);
-}
-
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
@@ -505,7 +477,9 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 
 	spin_lock(&tbl->slot_tbl_lock);
 	nfs4_free_slot(tbl, res->sr_slot);
-	nfs4_check_drain_fc_complete(session);
+	if (!nfs4_session_draining(tbl->session))
+		rpc_wake_up_first(&tbl->slot_tbl_waitq,
+				nfs4_set_task_privileged, NULL);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 55a3e8c..4a4c896 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -271,6 +271,16 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 	}
 }
 
+/*
+ * Signal state manager thread if session fore channel is drained
+ */
+void nfs4_session_drain_complete(struct nfs4_session *session,
+		struct nfs4_slot_table *tbl)
+{
+	if (nfs4_session_draining(session))
+		complete(&tbl->complete);
+}
+
 static int nfs4_wait_on_slot_tbl(struct nfs4_slot_table *tbl)
 {
 	spin_lock(&tbl->slot_tbl_lock);
-- 
1.7.11.7


From: andros@netapp.com
Subject: [PATCH 10/11] nfs41: nfs41: fix state manager deadlock in session reset
Date: Fri,  4 Dec 2009 15:25:45 -0500
Message-ID: <1259958347-9031-11-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
 <1259958347-9031-3-git-send-email-andros@netapp.com>
 <1259958347-9031-4-git-send-email-andros@netapp.com>
 <1259958347-9031-5-git-send-email-andros@netapp.com>
 <1259958347-9031-6-git-send-email-andros@netapp.com>
 <1259958347-9031-7-git-send-email-andros@netapp.com>
 <1259958347-9031-8-git-send-email-andros@netapp.com>
 <1259958347-9031-9-git-send-email-andros@netapp.com>
 <1259958347-9031-10-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757229AbZLDU0B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:26:01 -0500
In-Reply-To: <1259958347-9031-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

If the session is reset during state recovery, the state manager thread can
sleep on the slot_tbl_waitq causing a deadlock.

Add a completion framework to the session.  Have the state manager thread set
a new session state (NFS4CLNT_SESSION_DRAINING) and wait for the session slot
table to drain.

Signal the state manager thread in nfs41_sequence_free_slot when the
NFS4CLNT_SESSION_DRAINING bit is set and the session is drained.

Reported-by: Trond Myklebust <trond@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h          |    1 +
 fs/nfs/nfs4proc.c         |   26 +++++++++++++++++---------
 fs/nfs/nfs4state.c        |   15 +++++++++++++++
 include/linux/nfs_fs_sb.h |    1 +
 4 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e9ecd6b..5c77401 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -45,6 +45,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_SESSION_RESET,
+	NFS4CLNT_SESSION_DRAINING,
 };
 
 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 637cd3f..8b5b5f0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -354,6 +354,16 @@ void nfs41_sequence_free_slot(const struct nfs_client *clp,
 	}
 	nfs4_free_slot(tbl, res->sr_slotid);
 	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+
+	/* Signal state manager thread if session is drained */
+	if (test_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state)) {
+		spin_lock(&tbl->slot_tbl_lock);
+		if (tbl->highest_used_slotid == -1) {
+			dprintk("%s COMPLETE: Session Drained\n", __func__);
+			complete(&clp->cl_session->complete);
+		}
+		spin_unlock(&tbl->slot_tbl_lock);
+	}
 }
 
 static void nfs41_sequence_done(struct nfs_client *clp,
@@ -450,15 +460,11 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 
 	spin_lock(&tbl->slot_tbl_lock);
 	if (test_bit(NFS4CLNT_SESSION_RESET, &session->clp->cl_state)) {
-		if (tbl->highest_used_slotid != -1) {
-			rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-			spin_unlock(&tbl->slot_tbl_lock);
-			dprintk("<-- %s: Session reset: draining\n", __func__);
-			return -EAGAIN;
-		}
-
-		/* The slot table is empty; start the reset thread */
-		dprintk("%s Session Reset\n", __func__);
+		/*
+		 * The state manager will wait until the slot table is empty.
+		 * Schedule the reset thread
+		 */
+		dprintk("%s Schedule Session Reset\n", __func__);
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 		nfs4_schedule_state_manager(session->clp);
 		spin_unlock(&tbl->slot_tbl_lock);
@@ -4487,6 +4493,7 @@ static int nfs4_reset_slot_tables(struct nfs4_session *session)
 			1);
 	if (status)
 		return status;
+	init_completion(&session->complete);
 
 	status = nfs4_reset_slot_table(&session->bc_slot_table,
 			session->bc_attrs.max_reqs,
@@ -4589,6 +4596,7 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	 * nfs_client struct
 	 */
 	clp->cl_cons_state = NFS_CS_SESSION_INITING;
+	init_completion(&session->complete);
 
 	tbl = &session->fc_slot_table;
 	spin_lock_init(&tbl->slot_tbl_lock);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 91726bc..2a05d62 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1175,8 +1175,23 @@ static void nfs4_session_recovery_handle_error(struct nfs_client *clp, int err)
 
 static int nfs4_reset_session(struct nfs_client *clp)
 {
+	struct nfs4_session *ses = clp->cl_session;
+	struct nfs4_slot_table *tbl = &ses->fc_slot_table;
 	int status;
 
+	INIT_COMPLETION(ses->complete);
+	spin_lock(&tbl->slot_tbl_lock);
+	if (tbl->highest_used_slotid != -1) {
+		set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
+		spin_unlock(&tbl->slot_tbl_lock);
+		status = wait_for_completion_interruptible(&ses->complete);
+		clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
+		if (status) /* -ERESTARTSYS */
+			goto out;
+	} else {
+		spin_unlock(&tbl->slot_tbl_lock);
+	}
+
 	status = nfs4_proc_destroy_session(clp->cl_session);
 	if (status && status != -NFS4ERR_BADSESSION &&
 	    status != -NFS4ERR_DEADSESSION) {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 320569e..34fc6be 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -209,6 +209,7 @@ struct nfs4_session {
 	unsigned long			session_state;
 	u32				hash_alg;
 	u32				ssv_len;
+	struct completion		complete;
 
 	/* The fore and back channel */
 	struct nfs4_channel_attrs	fc_attrs;
-- 
1.6.0.6


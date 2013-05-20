Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36997 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757664Ab3ETSN5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 May 2013 14:13:57 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 Fix a pNFS session draining deadlock
Date: Mon, 20 May 2013 14:13:50 -0400
Message-Id: <1369073630-7193-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

On a CB_RECALL the callback service thread flushes the inode using
filemap_flush prior to scheduling the state manager thread to return the
delegation. When pNFS is used and I/O has not yet gone to the data server
servicing the inode, a LAYOUTGET can preceed the I/O. Unlike the async
filemap_flush call, the LAYOUTGET must proceed to completion.

If the state manager starts to recover data while the inode flush is sending
the LAYOUTGET, a deadlock occurs as the callback service thread holds the
single callback session slot until the flushing is done which blocks the state
manager thread, and the state manager thread has set the session draining bit
which puts the inode flush LAYOUTGET RPC to sleep on the forechannel slot
table waitq.

Separate the draining of the back channel from the draining of the fore channel
by moving the NFS4_SESSION_DRAINING bit from session scope into the fore
and back slot tables.  Drain the back channel first allowing the LAYOUTGET
call to proceed (and fail) so the callback service thread frees the callback
slot. Then proceed with draining the forechannel.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |  2 +-
 fs/nfs/callback_xdr.c  |  2 +-
 fs/nfs/nfs4proc.c      |  2 +-
 fs/nfs/nfs4session.c   |  6 ++++--
 fs/nfs/nfs4session.h   | 13 ++++++++-----
 fs/nfs/nfs4state.c     | 15 +++++++--------
 6 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a13d26e..0bc2768 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -414,7 +414,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 
 	spin_lock(&tbl->slot_tbl_lock);
 	/* state manager is resetting the session */
-	if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->session_state)) {
+	if (test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state)) {
 		spin_unlock(&tbl->slot_tbl_lock);
 		status = htonl(NFS4ERR_DELAY);
 		/* Return NFS4ERR_BADSESSION if we're draining the session
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 59461c9..a35582c 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -763,7 +763,7 @@ static void nfs4_callback_free_slot(struct nfs4_session *session)
 	 * A single slot, so highest used slotid is either 0 or -1
 	 */
 	tbl->highest_used_slotid = NFS4_NO_SLOT;
-	nfs4_session_drain_complete(session, tbl);
+	nfs4_slot_tbl_drain_complete(tbl);
 	spin_unlock(&tbl->slot_tbl_lock);
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8fbc100..4e2fe71 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -572,7 +572,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	task->tk_timeout = 0;
 
 	spin_lock(&tbl->slot_tbl_lock);
-	if (test_bit(NFS4_SESSION_DRAINING, &session->session_state) &&
+	if (test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state) &&
 	    !args->sa_privileged) {
 		/* The state manager will wait until the slot table is empty */
 		dprintk("%s session is draining\n", __func__);
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index ebda5f4..7ecfb75 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -73,7 +73,7 @@ void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
 			tbl->highest_used_slotid = new_max;
 		else {
 			tbl->highest_used_slotid = NFS4_NO_SLOT;
-			nfs4_session_drain_complete(tbl->session, tbl);
+			nfs4_slot_tbl_drain_complete(tbl);
 		}
 	}
 	dprintk("%s: slotid %u highest_used_slotid %d\n", __func__,
@@ -226,7 +226,7 @@ static bool nfs41_assign_slot(struct rpc_task *task, void *pslot)
 	struct nfs4_slot *slot = pslot;
 	struct nfs4_slot_table *tbl = slot->table;
 
-	if (nfs4_session_draining(tbl->session) && !args->sa_privileged)
+	if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
 		return false;
 	slot->generation = tbl->generation;
 	args->sa_slot = slot;
@@ -395,12 +395,14 @@ int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	/* Fore channel */
 	tbl = &ses->fc_slot_table;
 	tbl->session = ses;
+	tbl->slot_tbl_state = 0;
 	status = nfs4_realloc_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
 	if (status) /* -ENOMEM */
 		return status;
 	/* Back channel */
 	tbl = &ses->bc_slot_table;
 	tbl->session = ses;
+	tbl->slot_tbl_state = 0;
 	status = nfs4_realloc_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
 	if (status && tbl->slots == NULL)
 		/* Fore and back channel share a connection so get
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 6f3cb39..ff7d9f0 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -25,6 +25,10 @@ struct nfs4_slot {
 };
 
 /* Sessions */
+enum nfs4_slot_tbl_state {
+	NFS4_SLOT_TBL_DRAINING,
+};
+
 #define SLOT_TABLE_SZ DIV_ROUND_UP(NFS4_MAX_SLOT_TABLE, 8*sizeof(long))
 struct nfs4_slot_table {
 	struct nfs4_session *session;		/* Parent session */
@@ -43,6 +47,7 @@ struct nfs4_slot_table {
 	unsigned long	generation;		/* Generation counter for
 						   target_highest_slotid */
 	struct completion complete;
+	unsigned long	slot_tbl_state;
 };
 
 /*
@@ -68,7 +73,6 @@ struct nfs4_session {
 
 enum nfs4_session_state {
 	NFS4_SESSION_INITING,
-	NFS4_SESSION_DRAINING,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -88,12 +92,11 @@ extern void nfs4_destroy_session(struct nfs4_session *session);
 extern int nfs4_init_session(struct nfs_server *server);
 extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
 
-extern void nfs4_session_drain_complete(struct nfs4_session *session,
-		struct nfs4_slot_table *tbl);
+extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
 
-static inline bool nfs4_session_draining(struct nfs4_session *session)
+static inline bool nfs4_slot_tbl_draining(struct nfs4_slot_table *tbl)
 {
-	return !!test_bit(NFS4_SESSION_DRAINING, &session->session_state);
+	return !!test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
 }
 
 bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 300d17d..1fab140 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -241,7 +241,7 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 	if (ses == NULL)
 		return;
 	tbl = &ses->fc_slot_table;
-	if (test_and_clear_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
+	if (test_and_clear_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state)) {
 		spin_lock(&tbl->slot_tbl_lock);
 		nfs41_wake_slot_table(tbl);
 		spin_unlock(&tbl->slot_tbl_lock);
@@ -251,15 +251,15 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 /*
  * Signal state manager thread if session fore channel is drained
  */
-void nfs4_session_drain_complete(struct nfs4_session *session,
-		struct nfs4_slot_table *tbl)
+void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl)
 {
-	if (nfs4_session_draining(session))
+	if (nfs4_slot_tbl_draining(tbl))
 		complete(&tbl->complete);
 }
 
-static int nfs4_wait_on_slot_tbl(struct nfs4_slot_table *tbl)
+static int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
 {
+	set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
 	spin_lock(&tbl->slot_tbl_lock);
 	if (tbl->highest_used_slotid != NFS4_NO_SLOT) {
 		INIT_COMPLETION(tbl->complete);
@@ -275,13 +275,12 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 	struct nfs4_session *ses = clp->cl_session;
 	int ret = 0;
 
-	set_bit(NFS4_SESSION_DRAINING, &ses->session_state);
 	/* back channel */
-	ret = nfs4_wait_on_slot_tbl(&ses->bc_slot_table);
+	ret = nfs4_drain_slot_tbl(&ses->bc_slot_table);
 	if (ret)
 		return ret;
 	/* fore channel */
-	return nfs4_wait_on_slot_tbl(&ses->fc_slot_table);
+	return nfs4_drain_slot_tbl(&ses->fc_slot_table);
 }
 
 static void nfs41_finish_session_reset(struct nfs_client *clp)
-- 
1.7.11.7


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 58/67] nfs41: schedule async session reset
Date: Thu,  2 Apr 2009 16:58:48 +0300
Message-ID: <1238680728-15216-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31622 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756977AbZDBN7d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:59:33 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Define a new session reset state which is set upon a sequence operation error
in both the sync and async error handlers.

Place all new requests and all but the last outstanding rpc on the
slot_tbl_waitq. Spawn the recovery thread when the last slot is free.
Call nfs4_proc_destroy_session, reinitialize the session, call
nfs4_proc_create_session, clear the session reset state, and wake up the next
task on the slot_tbl_waitq.

Return the nfs4_proc_destroy_session status to the session reclaimer and
check for NFS4ERR_BADSESSION and NFS4ERR_DEADSESSION. Other destroy session
errors should be handled in nfs4_proc_destroy_session where the call can
be retried with adjusted arguments.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
nfs41: make nfs4_wait_bit_killable public]
    nfs4_wait_bit_killable to be used by NFSv4.1 session recover logic.
Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: have create_session work on nfs_client]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: trigger the state manager for session reset]
    Replace the session reset state with the NFS4CLNT_SESSION_SETUP cl_state.
    Place all rpc tasks to sleep on the slot table waitqueue until the slot
    table is drained, then schedule state recovery and wait for it to complete.
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: remove nfs41_session_recovery [ch]
Replaced by using the nfs4_state_manager.
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: nfs4_wait_bit_killable only used locally]
[nfs41: keep nfs4_wait_bit_killable static]
[nfs41: keep const nfs_server in nfs4_handle_exception]
[nfs41: remove session parameter from nfs4_find_slot]
Signed-off-by: Andy Adamson <andros@netapp.com
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: resset the session from nfs41_setup_sequence]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a9c5b00..3b3d1df 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -423,6 +423,22 @@ out:
 	return ret_id;
 }
 
+static int nfs4_recover_session(struct nfs4_session *session)
+{
+	struct nfs_client *clp = session->clp;
+	int ret;
+
+	for (;;) {
+		ret = nfs4_wait_clnt_recover(clp);
+		if (ret != 0)
+				return ret;
+		if (!test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state))
+			break;
+		nfs4_schedule_state_manager(clp);
+	}
+	return 0;
+}
+
 static int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
@@ -431,6 +447,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 {
 	struct nfs4_slot *slot;
 	struct nfs4_slot_table *tbl;
+	int status = 0;
 	u8 slotid;
 
 	dprintk("--> %s\n", __func__);
@@ -443,6 +460,23 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	tbl = &session->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
+	if (test_bit(NFS4CLNT_SESSION_SETUP, &session->clp->cl_state)) {
+		if (tbl->highest_used_slotid != -1) {
+			rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+			spin_unlock(&tbl->slot_tbl_lock);
+			dprintk("<-- %s: Session reset: draining\n", __func__);
+			return -EAGAIN;
+		}
+
+		/* The slot table is empty; start the reset thread */
+		dprintk("%s Session Reset\n", __func__);
+		spin_unlock(&tbl->slot_tbl_lock);
+		status = nfs4_recover_session(session);
+		if (status)
+			return status;
+		spin_lock(&tbl->slot_tbl_lock);
+	}
+
 	slotid = nfs4_find_slot(tbl, task);
 	if (slotid == NFS4_MAX_SLOT_TABLE) {
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
-- 
1.6.2.1


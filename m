From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/15] NFSv41: Don't store session state in the nfs_client->cl_state
Date: Mon, 14 Jun 2010 17:51:32 -0400
Message-ID: <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756784Ab0FNVvp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:45 -0400
In-Reply-To: <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    5 ++++-
 fs/nfs/nfs4proc.c  |    4 ++--
 fs/nfs/nfs4state.c |    6 ++++--
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9c0aa81..bb1e955 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -45,10 +45,13 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_SESSION_RESET,
-	NFS4CLNT_SESSION_DRAINING,
 	NFS4CLNT_RECALL_SLOT,
 };
 
+enum nfs4_session_state {
+	NFS4_SESSION_DRAINING,
+};
+
 /*
  * struct rpc_sequence ensures that RPC calls are sent in the exact
  * order that they appear on the list.
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 60ea066..7e0483c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -356,7 +356,7 @@ static void nfs41_check_drain_session_complete(struct nfs4_session *ses)
 {
 	struct rpc_task *task;
 
-	if (!test_bit(NFS4CLNT_SESSION_DRAINING, &ses->clp->cl_state)) {
+	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
 		task = rpc_wake_up_next(&ses->fc_slot_table.slot_tbl_waitq);
 		if (task)
 			rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
@@ -489,7 +489,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	tbl = &session->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
-	if (test_bit(NFS4CLNT_SESSION_DRAINING, &session->clp->cl_state) &&
+	if (test_bit(NFS4_SESSION_DRAINING, &session->session_state) &&
 	    !rpc_task_has_priority(task, RPC_PRIORITY_PRIVILEGED)) {
 		/*
 		 * The state manager will wait until the slot table is empty.
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 34acf59..4538c56 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -145,7 +145,9 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 	struct nfs4_session *ses = clp->cl_session;
 	int max_slots;
 
-	if (test_and_clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state)) {
+	if (ses == NULL)
+		return;
+	if (test_and_clear_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
 		spin_lock(&ses->fc_slot_table.slot_tbl_lock);
 		max_slots = ses->fc_slot_table.max_slots;
 		while (max_slots--) {
@@ -167,7 +169,7 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 	struct nfs4_slot_table *tbl = &ses->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
-	set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
+	set_bit(NFS4_SESSION_DRAINING, &ses->session_state);
 	if (tbl->highest_used_slotid != -1) {
 		INIT_COMPLETION(ses->complete);
 		spin_unlock(&tbl->slot_tbl_lock);
-- 
1.7.0.1


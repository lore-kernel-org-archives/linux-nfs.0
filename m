Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33482 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab2BLRyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Feb 2012 12:54:12 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 7 1/3] NFS4.1 clean up nfs4_alloc_session
Date: Sun, 12 Feb 2012 12:52:54 -0500
Message-Id: <1329069176-8349-2-git-send-email-andros@netapp.com>
In-Reply-To: <1329069176-8349-1-git-send-email-andros@netapp.com>
References: <1329069176-8349-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   39 ++++++++++++++++++++-------------------
 1 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d202e04..18b095a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5061,9 +5061,9 @@ static void nfs4_destroy_slot_tables(struct nfs4_session *session)
 }
 
 /*
- * Initialize slot table
+ * Set the initial slot table slots with CREATE_SESSION negotiated values
  */
-static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
+static int nfs4_set_slot_table(struct nfs4_slot_table *tbl,
 		int max_slots, int ivalue)
 {
 	struct nfs4_slot *slot;
@@ -5091,7 +5091,7 @@ out:
 }
 
 /*
- * Initialize or reset the forechannel and backchannel tables
+ * Set or reset the forechannel and backchannel tables
  */
 static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 {
@@ -5102,7 +5102,7 @@ static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	/* Fore channel */
 	tbl = &ses->fc_slot_table;
 	if (tbl->slots == NULL) {
-		status = nfs4_init_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
+		status = nfs4_set_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
 		if (status) /* -ENOMEM */
 			return status;
 	} else {
@@ -5113,7 +5113,7 @@ static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	/* Back channel */
 	tbl = &ses->bc_slot_table;
 	if (tbl->slots == NULL) {
-		status = nfs4_init_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
+		status = nfs4_set_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
 		if (status)
 			/* Fore and back channel share a connection so get
 			 * both slot tables or neither */
@@ -5123,29 +5123,30 @@ static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 	return status;
 }
 
+void nfs4_init_slot_table(struct nfs4_slot_table *tbl, bool forechannel)
+{
+	spin_lock_init(&tbl->slot_tbl_lock);
+	if (forechannel)
+		rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq,
+					     "ForeChannel Slot table");
+	else
+		rpc_init_wait_queue(&tbl->slot_tbl_waitq,
+				    "BackChannel Slot table");
+	tbl->highest_used_slotid = -1;	/* for drain session to work */
+	init_completion(&tbl->complete);
+}
+
 struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 {
 	struct nfs4_session *session;
-	struct nfs4_slot_table *tbl;
 
 	session = kzalloc(sizeof(struct nfs4_session), GFP_NOFS);
 	if (!session)
 		return NULL;
 
-	tbl = &session->fc_slot_table;
-	tbl->highest_used_slotid = -1;
-	spin_lock_init(&tbl->slot_tbl_lock);
-	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
-	init_completion(&tbl->complete);
-
-	tbl = &session->bc_slot_table;
-	tbl->highest_used_slotid = -1;
-	spin_lock_init(&tbl->slot_tbl_lock);
-	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
-	init_completion(&tbl->complete);
-
+	nfs4_init_slot_table(&session->fc_slot_table, true);
+	nfs4_init_slot_table(&session->bc_slot_table, false);
 	session->session_state = 1<<NFS4_SESSION_INITING;
-
 	session->clp = clp;
 	return session;
 }
-- 
1.7.6.4


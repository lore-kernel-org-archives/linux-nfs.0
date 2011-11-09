Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13796 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595Ab1KIS67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Nov 2011 13:58:59 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 2/7] NFSv4.1: cleanup init and reset of session slot tables
Date: Wed,  9 Nov 2011 13:58:21 -0500
Message-Id: <1320865106-1791-2-git-send-email-andros@netapp.com>
In-Reply-To: <1320865106-1791-1-git-send-email-andros@netapp.com>
References: <1320865106-1791-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We are either initializing or resetting a session. Initialize or reset
the session slot tables accordingly.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   59 +++++++++++++++++++---------------------------------
 1 files changed, 22 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b60fddf..ef098a8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5014,23 +5014,6 @@ out:
 	return ret;
 }
 
-/*
- * Reset the forechannel and backchannel slot tables
- */
-static int nfs4_reset_slot_tables(struct nfs4_session *session)
-{
-	int status;
-
-	status = nfs4_reset_slot_table(&session->fc_slot_table,
-			session->fc_attrs.max_reqs, 1);
-	if (status)
-		return status;
-
-	status = nfs4_reset_slot_table(&session->bc_slot_table,
-			session->bc_attrs.max_reqs, 0);
-	return status;
-}
-
 /* Destroy the slot table */
 static void nfs4_destroy_slot_tables(struct nfs4_session *session)
 {
@@ -5076,29 +5059,35 @@ out:
 }
 
 /*
- * Initialize the forechannel and backchannel tables
+ * Initialize or reset the forechannel and backchannel tables
  */
-static int nfs4_init_slot_tables(struct nfs4_session *session)
+static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 {
 	struct nfs4_slot_table *tbl;
-	int status = 0;
+	int status;
 
-	tbl = &session->fc_slot_table;
+	dprintk("--> %s\n", __func__);
+	/* Fore channel */
+	tbl = &ses->fc_slot_table;
 	if (tbl->slots == NULL) {
-		status = nfs4_init_slot_table(tbl,
-				session->fc_attrs.max_reqs, 1);
+		status = nfs4_init_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
+		if (status) /* -ENOMEM */
+			return status;
+	} else {
+		status = nfs4_reset_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
 		if (status)
 			return status;
 	}
-
-	tbl = &session->bc_slot_table;
+	/* Back channel */
+	tbl = &ses->bc_slot_table;
 	if (tbl->slots == NULL) {
-		status = nfs4_init_slot_table(tbl,
-				session->bc_attrs.max_reqs, 0);
+		status = nfs4_init_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
 		if (status)
-			nfs4_destroy_slot_tables(session);
-	}
-
+			/* Fore and back channel share a connection so get
+			 * both slot tables or neither */
+			nfs4_destroy_slot_tables(ses);
+	} else
+		status = nfs4_reset_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
 	return status;
 }
 
@@ -5286,13 +5275,9 @@ int nfs4_proc_create_session(struct nfs_client *clp)
 	if (status)
 		goto out;
 
-	/* Init and reset the fore channel */
-	status = nfs4_init_slot_tables(session);
-	dprintk("slot table initialization returned %d\n", status);
-	if (status)
-		goto out;
-	status = nfs4_reset_slot_tables(session);
-	dprintk("slot table reset returned %d\n", status);
+	/* Init or reset the session slot tables */
+	status = nfs4_setup_session_slot_tables(session);
+	dprintk("slot table setup returned %d\n", status);
 	if (status)
 		goto out;
 
-- 
1.7.6.4


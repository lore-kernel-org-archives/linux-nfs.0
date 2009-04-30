From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 37/39] nfs41: Backchannel: Add a backchannel slot table to the session
Date: Fri,  1 May 2009 02:25:34 +0300
Message-ID: <1241133934-1523-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29018 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759565AbZD3XZk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:25:40 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Defines a new 'struct nfs4_slot_table' in the 'struct nfs4_session'
for use by the backchannel.  Initializes, resets, and destroys the backchannel
slot table in the same manner the forechannel slot table is initialized,
reset, and destroyed.

The sequenceid for each slot in the backchannel slot table is initialized
to 0, whereas the forechannel slotid's sequenceid is set to 1.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c         |   48 +++++++++++++++++++++++++++++++++-----------
 include/linux/nfs_fs_sb.h |    2 +-
 2 files changed, 37 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index da544b8..07b5f19 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4417,9 +4417,30 @@ static int nfs4_reset_slot_tables(struct nfs4_session *session)
 			session->fc_attrs.max_reqs,
 			session->fc_slot_table.max_slots,
 			1);
+	if (status)
+		return status;
+
+	status = nfs4_reset_slot_table(&session->bc_slot_table,
+			session->bc_attrs.max_reqs,
+			session->bc_slot_table.max_slots,
+			0);
 	return status;
 }
 
+/* Destroy the slot table */
+static void nfs4_destroy_slot_tables(struct nfs4_session *session)
+{
+	if (session->fc_slot_table.slots != NULL) {
+		kfree(session->fc_slot_table.slots);
+		session->fc_slot_table.slots = NULL;
+	}
+	if (session->bc_slot_table.slots != NULL) {
+		kfree(session->bc_slot_table.slots);
+		session->bc_slot_table.slots = NULL;
+	}
+	return;
+}
+
 /*
  * Initialize slot table
  */
@@ -4473,17 +4494,15 @@ static int nfs4_init_slot_tables(struct nfs4_session *session)
 
 	status = nfs4_init_slot_table(&session->fc_slot_table,
 			session->fc_attrs.max_reqs, 1);
-	return status;
-}
+	if (status)
+		return status;
 
-/* Destroy the slot table */
-static void nfs4_destroy_slot_table(struct nfs4_session *session)
-{
-	if (session->fc_slot_table.slots == NULL)
-		return;
-	kfree(session->fc_slot_table.slots);
-	session->fc_slot_table.slots = NULL;
-	return;
+	status = nfs4_init_slot_table(&session->bc_slot_table,
+			session->bc_attrs.max_reqs, 0);
+	if (status)
+		nfs4_destroy_slot_tables(session);
+
+	return status;
 }
 
 struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
@@ -4506,7 +4525,12 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 
 	tbl = &session->fc_slot_table;
 	spin_lock_init(&tbl->slot_tbl_lock);
-	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "Slot table");
+	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
+
+	tbl = &session->bc_slot_table;
+	spin_lock_init(&tbl->slot_tbl_lock);
+	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
+
 	session->clp = clp;
 	return session;
 }
@@ -4518,7 +4542,7 @@ void nfs4_destroy_session(struct nfs4_session *session)
 		__func__, session->clp->cl_rpcclient->cl_xprt);
 	xprt_destroy_backchannel(session->clp->cl_rpcclient->cl_xprt,
 				NFS41_BC_MIN_CALLBACKS);
-	nfs4_destroy_slot_table(session);
+	nfs4_destroy_slot_tables(session);
 	kfree(session);
 }
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d0902cc..19fe15d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -205,7 +205,7 @@ struct nfs4_session {
 	struct nfs4_channel_attrs	fc_attrs;
 	struct nfs4_slot_table		fc_slot_table;
 	struct nfs4_channel_attrs	bc_attrs;
-					/* back channel has one slot */
+	struct nfs4_slot_table		bc_slot_table;
 	struct nfs_client		*clp;
 };
 
-- 
1.6.2.1


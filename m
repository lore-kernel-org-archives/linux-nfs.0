From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 35/39] nfs41: Backchannel: Refactor nfs4_reset_slot_table()
Date: Fri,  1 May 2009 02:25:20 +0300
Message-ID: <1241133920-1456-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31566 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758985AbZD3XZ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:25:27 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Generalize nfs4_reset_slot_table() so it can be used to reset the
backchannel slot table in addition to the forechannel slot table.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   38 +++++++++++++++++++++++++++-----------
 1 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 485c279..7b18787 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4373,19 +4373,21 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	return status;
 }
 
-/* Reset a slot table */
-static int nfs4_reset_slot_table(struct nfs4_session *session)
+/*
+ * Reset a slot table
+ */
+static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, int max_slots,
+		int old_max_slots, int ivalue)
 {
-	struct nfs4_slot_table *tbl = &session->fc_slot_table;
-	int i, max_slots = session->fc_attrs.max_reqs;
-	int old_max_slots = session->fc_slot_table.max_slots;
+	int i;
 	int ret = 0;
 
-	dprintk("--> %s: max_reqs=%u, tbl %p\n", __func__,
-		session->fc_attrs.max_reqs, tbl);
+	dprintk("--> %s: max_reqs=%u, tbl %p\n", __func__, max_slots, tbl);
 
-	/* Until we have dynamic slot table adjustment, insist
-	 * upon the same slot table size */
+	/*
+	 * Until we have dynamic slot table adjustment, insist
+	 * upon the same slot table size
+	 */
 	if (max_slots != old_max_slots) {
 		dprintk("%s reset slot table does't match old\n",
 			__func__);
@@ -4394,7 +4396,7 @@ static int nfs4_reset_slot_table(struct nfs4_session *session)
 	}
 	spin_lock(&tbl->slot_tbl_lock);
 	for (i = 0; i < max_slots; ++i)
-		tbl->slots[i].seq_nr = 1;
+		tbl->slots[i].seq_nr = ivalue;
 	tbl->highest_used_slotid = -1;
 	spin_unlock(&tbl->slot_tbl_lock);
 	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
@@ -4405,6 +4407,20 @@ out:
 }
 
 /*
+ * Reset the forechannel and backchannel slot tables
+ */
+static int nfs4_reset_slot_tables(struct nfs4_session *session)
+{
+	int status;
+
+	status = nfs4_reset_slot_table(&session->fc_slot_table,
+			session->fc_attrs.max_reqs,
+			session->fc_slot_table.max_slots,
+			1);
+	return status;
+}
+
+/*
  * Initialize slot table
  */
 static int nfs4_init_slot_table(struct nfs4_session *session)
@@ -4642,7 +4658,7 @@ int nfs4_proc_create_session(struct nfs_client *clp, int reset)
 
 	/* Init or reset the fore channel */
 	if (reset)
-		status = nfs4_reset_slot_table(session);
+		status = nfs4_reset_slot_tables(session);
 	else
 		status = nfs4_init_slot_table(session);
 	dprintk("fore channel slot table initialization returned %d\n", status);
-- 
1.6.2.1


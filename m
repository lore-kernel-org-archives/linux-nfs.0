From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 36/39] nfs41: Backchannel: Refactor nfs4_init_slot_table()
Date: Fri,  1 May 2009 02:25:27 +0300
Message-ID: <1241133927-1491-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:4341 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758629AbZD3XZe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:25:34 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Generalize nfs4_init_slot_table() so it can be used to initialize the
backchannel slot table in addition to the forechannel slot table.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7b18787..da544b8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4423,23 +4423,22 @@ static int nfs4_reset_slot_tables(struct nfs4_session *session)
 /*
  * Initialize slot table
  */
-static int nfs4_init_slot_table(struct nfs4_session *session)
+static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
+		int max_slots, int ivalue)
 {
-	struct nfs4_slot_table *tbl = &session->fc_slot_table;
-	int i, max_slots = session->fc_attrs.max_reqs;
+	int i;
 	struct nfs4_slot *slot;
 	int ret = -ENOMEM;
 
 	BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
 
-	dprintk("--> %s: max_reqs=%u\n", __func__,
-		session->fc_attrs.max_reqs);
+	dprintk("--> %s: max_reqs=%u\n", __func__, max_slots);
 
 	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_KERNEL);
 	if (!slot)
 		goto out;
 	for (i = 0; i < max_slots; ++i)
-		slot[i].seq_nr = 1;
+		slot[i].seq_nr = ivalue;
 	ret = 0;
 
 	spin_lock(&tbl->slot_tbl_lock);
@@ -4459,11 +4458,24 @@ static int nfs4_init_slot_table(struct nfs4_session *session)
 out:
 	dprintk("<-- %s: return %d\n", __func__, ret);
 	return ret;
+
 out_free:
 	kfree(slot);
 	goto out;
 }
 
+/*
+ * Initialize the forechannel and backchannel tables
+ */
+static int nfs4_init_slot_tables(struct nfs4_session *session)
+{
+	int status;
+
+	status = nfs4_init_slot_table(&session->fc_slot_table,
+			session->fc_attrs.max_reqs, 1);
+	return status;
+}
+
 /* Destroy the slot table */
 static void nfs4_destroy_slot_table(struct nfs4_session *session)
 {
@@ -4660,7 +4672,7 @@ int nfs4_proc_create_session(struct nfs_client *clp, int reset)
 	if (reset)
 		status = nfs4_reset_slot_tables(session);
 	else
-		status = nfs4_init_slot_table(session);
+		status = nfs4_init_slot_tables(session);
 	dprintk("fore channel slot table initialization returned %d\n", status);
 	if (status)
 		goto out;
-- 
1.6.2.1


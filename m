From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 52/67] nfs41: reset the session slot table
Date: Thu,  2 Apr 2009 16:58:09 +0300
Message-ID: <1238680689-15028-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2022 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756742AbZDBN6g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:36 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separated from nfs41: schedule async session reset

Do not kfree the session slot table upon session reset, just re-initialize it.
Add a boolean to nfs4_proc_create_session to inidicate if this is a
session reset or a session initialization.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   44 +++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e1b942e..ba68d43 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4292,6 +4292,37 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	return status;
 }
 
+/* Reset a slot table */
+static int nfs4_reset_slot_table(struct nfs4_session *session)
+{
+	struct nfs4_slot_table *tbl = &session->fc_slot_table;
+	int i, max_slots = session->fc_attrs.max_reqs;
+	int old_max_slots = session->fc_slot_table.max_slots;
+	int ret = 0;
+
+	dprintk("--> %s: max_reqs=%u, tbl %p\n", __func__,
+		session->fc_attrs.max_reqs, tbl);
+
+	/* Until we have dynamic slot table adjustment, insist
+	 * upon the same slot table size */
+	if (max_slots != old_max_slots) {
+		dprintk("%s reset slot table does't match old\n",
+			__func__);
+		ret = -EINVAL; /*XXX NFS4ERR_REQ_TOO_BIG ? */
+		goto out;
+	}
+	spin_lock(&tbl->slot_tbl_lock);
+	for (i = 0; i < max_slots; ++i)
+		tbl->slots[i].seq_nr = 1;
+	tbl->highest_used_slotid = -1;
+	spin_unlock(&tbl->slot_tbl_lock);
+	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
+		tbl, tbl->slots, tbl->max_slots);
+out:
+	dprintk("<-- %s: return %d\n", __func__, ret);
+	return ret;
+}
+
 /*
  * Initialize slot table
  */
@@ -4500,7 +4531,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp)
  * It is the responsibility of the caller to verify the session is
  * expired before calling this routine.
  */
-int nfs4_proc_create_session(struct nfs_client *clp)
+int nfs4_proc_create_session(struct nfs_client *clp, int reset)
 {
 	int status;
 	unsigned *ptr;
@@ -4513,8 +4544,11 @@ int nfs4_proc_create_session(struct nfs_client *clp)
 	if (status)
 		goto out;
 
-	/* Init the fore channel */
-	status = nfs4_init_slot_table(session);
+	/* Init or reset the fore channel */
+	if (reset)
+		status = nfs4_reset_slot_table(session);
+	else
+		status = nfs4_init_slot_table(session);
 	dprintk("fore channel slot table initialization returned %d\n", status);
 	if (status)
 		goto out;
@@ -4523,6 +4557,10 @@ int nfs4_proc_create_session(struct nfs_client *clp)
 	dprintk("%s client>seqid %d sessionid %u:%u:%u:%u\n", __func__,
 		clp->cl_seqid, ptr[0], ptr[1], ptr[2], ptr[3]);
 
+	if (reset)
+		/* Lease time is aleady set */
+		goto out;
+
 	/* Get the lease time */
 	status = nfs4_proc_get_lease_time(clp, &fsinfo);
 	if (status == 0) {
-- 
1.6.2.1


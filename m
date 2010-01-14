From: andros@netapp.com
Subject: [PATCH 7/7] nfs41: resize slot table in reset
Date: Thu, 14 Jan 2010 17:45:10 -0500
Message-ID: <1263509110-3097-8-git-send-email-andros@netapp.com>
References: <1263509110-3097-1-git-send-email-andros@netapp.com>
 <1263509110-3097-2-git-send-email-andros@netapp.com>
 <1263509110-3097-3-git-send-email-andros@netapp.com>
 <1263509110-3097-4-git-send-email-andros@netapp.com>
 <1263509110-3097-5-git-send-email-andros@netapp.com>
 <1263509110-3097-6-git-send-email-andros@netapp.com>
 <1263509110-3097-7-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20512 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757130Ab0ANWpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 17:45:22 -0500
In-Reply-To: <1263509110-3097-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When session is reset, client can renegotiate slot table size.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   40 +++++++++++++++++++++-------------------
 1 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 198d51d..eabe09e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4573,26 +4573,32 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 /*
  * Reset a slot table
  */
-static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, int max_slots,
-		int old_max_slots, int ivalue)
+static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
+				 int ivalue)
 {
+	struct nfs4_slot *new = NULL;
 	int i;
 	int ret = 0;
 
-	dprintk("--> %s: max_reqs=%u, tbl %p\n", __func__, max_slots, tbl);
+	dprintk("--> %s: max_reqs=%u, tbl->max_slots %d\n", __func__,
+		max_reqs, tbl->max_slots);
 
-	/*
-	 * Until we have dynamic slot table adjustment, insist
-	 * upon the same slot table size
-	 */
-	if (max_slots != old_max_slots) {
-		dprintk("%s reset slot table does't match old\n",
-			__func__);
-		ret = -EINVAL; /*XXX NFS4ERR_REQ_TOO_BIG ? */
-		goto out;
+	/* Does the newly negotiated max_reqs match the existing slot table? */
+	if (max_reqs != tbl->max_slots) {
+		ret = -ENOMEM;
+		new = kmalloc(max_reqs * sizeof(struct nfs4_slot),
+			      GFP_KERNEL);
+		if (!new)
+			goto out;
+		ret = 0;
+		kfree(tbl->slots);
 	}
 	spin_lock(&tbl->slot_tbl_lock);
-	for (i = 0; i < max_slots; ++i)
+	if (new) {
+		tbl->slots = new;
+		tbl->max_slots = max_reqs;
+	}
+	for (i = 0; i < tbl->max_slots; ++i)
 		tbl->slots[i].seq_nr = ivalue;
 	spin_unlock(&tbl->slot_tbl_lock);
 	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
@@ -4610,16 +4616,12 @@ static int nfs4_reset_slot_tables(struct nfs4_session *session)
 	int status;
 
 	status = nfs4_reset_slot_table(&session->fc_slot_table,
-			session->fc_attrs.max_reqs,
-			session->fc_slot_table.max_slots,
-			1);
+			session->fc_attrs.max_reqs, 1);
 	if (status)
 		return status;
 
 	status = nfs4_reset_slot_table(&session->bc_slot_table,
-			session->bc_attrs.max_reqs,
-			session->bc_slot_table.max_slots,
-			0);
+			session->bc_attrs.max_reqs, 0);
 	return status;
 }
 
-- 
1.6.5.2


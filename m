From: andros@netapp.com
Subject: [PATCH 4/7] nfs41: prepare for back channel drc
Date: Thu, 14 Jan 2010 17:45:07 -0500
Message-ID: <1263509110-3097-5-git-send-email-andros@netapp.com>
References: <1263509110-3097-1-git-send-email-andros@netapp.com>
 <1263509110-3097-2-git-send-email-andros@netapp.com>
 <1263509110-3097-3-git-send-email-andros@netapp.com>
 <1263509110-3097-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20512 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756978Ab0ANWpS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 17:45:18 -0500
In-Reply-To: <1263509110-3097-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Make all cb_sequence arguments available to verify_seqid which will make
replay decisions.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index defa9b4..7f92b6d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -153,34 +153,34 @@ int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const n
  * a single outstanding callback request at a time.
  */
 static int
-validate_seqid(struct nfs4_slot_table *tbl, u32 slotid, u32 seqid)
+validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 {
 	struct nfs4_slot *slot;
 
 	dprintk("%s enter. slotid %d seqid %d\n",
-		__func__, slotid, seqid);
+		__func__, args->csa_slotid, args->csa_sequenceid);
 
-	if (slotid > NFS41_BC_MAX_CALLBACKS)
+	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS)
 		return htonl(NFS4ERR_BADSLOT);
 
-	slot = tbl->slots + slotid;
+	slot = tbl->slots + args->csa_slotid;
 	dprintk("%s slot table seqid: %d\n", __func__, slot->seq_nr);
 
 	/* Normal */
-	if (likely(seqid == slot->seq_nr + 1)) {
+	if (likely(args->csa_sequenceid == slot->seq_nr + 1)) {
 		slot->seq_nr++;
 		return htonl(NFS4_OK);
 	}
 
 	/* Replay */
-	if (seqid == slot->seq_nr) {
+	if (args->csa_sequenceid == slot->seq_nr) {
 		dprintk("%s seqid %d is a replay - no DRC available\n",
-			__func__, seqid);
+			__func__, args->csa_sequenceid);
 		return htonl(NFS4_OK);
 	}
 
 	/* Wraparound */
-	if (seqid == 1 && (slot->seq_nr + 1) == 0) {
+	if (args->csa_sequenceid == 1 && (slot->seq_nr + 1) == 0) {
 		slot->seq_nr = 1;
 		return htonl(NFS4_OK);
 	}
@@ -241,8 +241,7 @@ unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
 	if (clp == NULL)
 		goto out;
 
-	status = validate_seqid(&clp->cl_session->bc_slot_table,
-				args->csa_slotid, args->csa_sequenceid);
+	status = validate_seqid(&clp->cl_session->bc_slot_table, args);
 	if (status)
 		goto out_putclient;
 
-- 
1.6.5.2


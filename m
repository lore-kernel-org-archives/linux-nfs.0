From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 03/44] nfsd41: change check_slot_seqid parameters
Date: Tue, 16 Jun 2009 04:19:20 +0300
Message-ID: <1245115160-6898-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2555
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752387AbZFPBTU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:20 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For separation of session slot and clientid slot processing.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d5caf2a..c22ec9b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1313,26 +1313,26 @@ error:
 }
 
 static int
-check_slot_seqid(u32 seqid, struct nfsd4_slot *slot)
+check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse)
 {
-	dprintk("%s enter. seqid %d slot->sl_seqid %d\n", __func__, seqid,
-		slot->sl_seqid);
+	dprintk("%s enter. seqid %d slot_seqid %d\n", __func__, seqid,
+		slot_seqid);
 
 	/* The slot is in use, and no response has been sent. */
-	if (slot->sl_inuse) {
-		if (seqid == slot->sl_seqid)
+	if (slot_inuse) {
+		if (seqid == slot_seqid)
 			return nfserr_jukebox;
 		else
 			return nfserr_seq_misordered;
 	}
 	/* Normal */
-	if (likely(seqid == slot->sl_seqid + 1))
+	if (likely(seqid == slot_seqid + 1))
 		return nfs_ok;
 	/* Replay */
-	if (seqid == slot->sl_seqid)
+	if (seqid == slot_seqid)
 		return nfserr_replay_cache;
 	/* Wraparound */
-	if (seqid == 1 && (slot->sl_seqid + 1) == 0)
+	if (seqid == 1 && (slot_seqid + 1) == 0)
 		return nfs_ok;
 	/* Misordered replay or misordered new request */
 	return nfserr_seq_misordered;
@@ -1355,7 +1355,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (conf) {
 		slot = &conf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
+					  slot->sl_inuse);
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
 				slot->sl_seqid);
@@ -1380,7 +1381,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 
 		slot = &unconf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
+					  slot->sl_inuse);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
@@ -1481,7 +1483,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	slot = &session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
 
-	status = check_slot_seqid(seq->seqid, slot);
+	status = check_slot_seqid(seq->seqid, slot->sl_seqid, slot->sl_inuse);
 	if (status == nfserr_replay_cache) {
 		cstate->slot = slot;
 		cstate->session = session;
-- 
1.6.3


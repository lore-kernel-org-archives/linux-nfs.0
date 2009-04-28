From: andros@netapp.com
Subject: [PATCH 02/31] nfsd41: change check_slot_seqid parameters
Date: Tue, 28 Apr 2009 12:59:36 -0400
Message-ID: <1240938005-23778-2-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50923 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760328AbZD1RBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:01:03 -0400
In-Reply-To: <1240938005-23778-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For separation of session slot and clientid slot processing.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 42ebcb3..43c821f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1310,26 +1310,26 @@ error:
 }
 
 static int
-check_slot_seqid(u32 seqid, struct nfsd4_slot *slot)
+check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse )
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
@@ -1352,7 +1352,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (conf) {
 		slot = &conf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
+					  slot->sl_inuse);
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
 				slot->sl_seqid);
@@ -1377,7 +1378,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 
 		slot = &unconf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
+					  slot->sl_inuse);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
@@ -1487,7 +1489,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	slot = &session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
 
-	status = check_slot_seqid(seq->seqid, slot);
+	status = check_slot_seqid(seq->seqid, slot->sl_seqid, slot->sl_inuse);
 	if (status == nfserr_replay_cache) {
 		cstate->slot = slot;
 		cstate->session = session;
-- 
1.5.4.3


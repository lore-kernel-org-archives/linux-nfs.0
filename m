From: andros@netapp.com
Subject: [PATCH 06/14] nfsd41: change check_slot_seqid parameters
Date: Wed, 24 Jun 2009 15:37:50 -0400
Message-ID: <1245872278-18743-7-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759784AbZFXTiB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:01 -0400
In-Reply-To: <1245872278-18743-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For separation of session slot and clientid slot processing.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dc91544..0eab5e2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1315,26 +1315,26 @@ error:
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
@@ -1357,7 +1357,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (conf) {
 		slot = &conf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
+					  slot->sl_inuse);
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
 				slot->sl_seqid);
@@ -1382,7 +1383,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 
 		slot = &unconf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
+					  slot->sl_inuse);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
@@ -1483,7 +1485,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	slot = &session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
 
-	status = check_slot_seqid(seq->seqid, slot);
+	status = check_slot_seqid(seq->seqid, slot->sl_seqid, slot->sl_inuse);
 	if (status == nfserr_replay_cache) {
 		cstate->slot = slot;
 		cstate->session = session;
-- 
1.5.4.3


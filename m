From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 46/51] nfsd41: nfsd nfsd4_sequence DRC logic
Date: Mon, 10 Nov 2008 22:56:30 +0200
Message-ID: <1226350590-11846-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57467 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbYKJU4m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:56:42 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Create a new internal error nfserr_replay_cache for the nfs41 DRC.

Refactor nfsd4_sequence processing to enforce error and replay behaviour.

Move seqid logic into check_slot_seqid
In preparation for use with create session slot table.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c       |   84 ++++++++++++++++++++------------------------
 include/linux/nfs.h       |    1 +
 include/linux/nfsd/nfsd.h |    1 +
 3 files changed, 40 insertions(+), 46 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 230ce1d..a1a9e0a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1222,6 +1222,32 @@ error:
 	return status;
 }
 
+static int
+check_slot_seqid(u32 seqid, struct nfs41_slot *slot)
+{
+	dprintk("%s enter. seqid %d slot->sl_seqid %d\n", __func__, seqid,
+		slot->sl_seqid);
+
+	/* The slot is in use, and no response has been sent. */
+	if (nfs41_get_slot_state(slot) == NFS4_SLOT_INPROGRESS) {
+		if (seqid == slot->sl_seqid)
+			return nfserr_jukebox;
+		else
+			return nfserr_seq_misordered;
+	}
+	/* Normal */
+	if (likely(seqid == slot->sl_seqid + 1))
+		return nfs_ok;
+	/* Replay */
+	if (seqid == slot->sl_seqid)
+		return nfserr_replay_cache;
+	/* Wraparound */
+	if (seqid == 1 && (slot->sl_seqid + 1) == 0)
+		return nfs_ok;
+	/* Misordered replay or misordered new request */
+	return nfserr_seq_misordered;
+}
+
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
@@ -1337,24 +1363,6 @@ out:
 	return status;
 }
 
-static int
-check_slot_seqid(u32 seqid, struct nfs41_slot *slot)
-{
-	dprintk("%s enter. seqid %d slot->sl_seqid %d\n", __func__, seqid,
-		slot->sl_seqid);
-	/* Normal */
-	if (likely(seqid == slot->sl_seqid + 1))
-		return nfs_ok;
-	/* Replay */
-	if (seqid == slot->sl_seqid)
-		return NFSERR_REPLAY_ME;
-	/* Wraparound */
-	if (seqid == 1 && (slot->sl_seqid + 1) == 0)
-		return nfs_ok;
-	/* Misordered replay or misordered new request */
-	return nfserr_seq_misordered;
-}
-
 __be32
 nfsd4_sequence(struct svc_rqst *r,
 	       struct nfsd4_compound_state *cstate,
@@ -1381,31 +1389,26 @@ nfsd4_sequence(struct svc_rqst *r,
 	slot = &elem->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
 
-	/* Server post op_sequence compound processing had an upcall which
-	 * resulted in replaying the compound processing including the
-	 * already processed op_sequence. Set current_session
-	 * but don't bump slot->sl_seqid which was incremented in successful
-	 * op_sequence processing prior to upcall.
-	 */
-	if (nfs41_get_slot_state(slot) == NFS4_SLOT_INPROGRESS) {
-		dprintk("%s: NFS4_SLOT_INPROGRESS. set current_session\n",
-			__func__);
-		goto set_curr_ses;
-	}
-
 	status = check_slot_seqid(seq->seqid, slot);
-	if (status == NFSERR_REPLAY_ME)
-		goto replay;
-	else if (status)
+	if (status == nfserr_replay_cache)
+		goto replay_cache;
+	if (status)
 		goto out;
 
-	/* Success! bump slot seqid and renew clientid */
+	/* Success! bump slot seqid */
 	slot->sl_seqid = seq->seqid;
+
+	/* FIXME: for now just initialize target_highest_slotid and flags
+	 * response fields */
+	seq->target_maxslots = seq->maxslots;
+	seq->status_flags = 0;
+
+replay_cache:
+	/* renew the clientid on success and on replay */
 	renew_client(elem->se_client);
 	dprintk("%s: set NFS4_SLOT_INPROGRESS\n", __func__);
 	nfs41_set_slot_state(slot, NFS4_SLOT_INPROGRESS);
 
-set_curr_ses:
 	/* Set current_session. hold reference until done processing compound.
 	 * nfs41_put_session called only if cs_slot is set
 	 */
@@ -1414,21 +1417,10 @@ set_curr_ses:
 	c_ses->cs_slot = slot;
 	nfs41_get_session(slot->sl_session);
 
-	/* FIXME: for now just initialize target_highest_slotid and flags
-	 * response fields */
-	seq->target_maxslots = seq->maxslots;
-	seq->status_flags = 0;
-
-	status = nfs_ok;
 out:
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	nfs4_unlock_state();
 	return status;
-replay:
-	dprintk("%s: REPLAY - AKKKK! no code yet! return BAD SESSION\n",
-		__func__);
-	status = nfserr_badsession;
-	goto out;
 }
 #endif /* CONFIG_NFSD_V4_1 */
 
diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index 4dd83f2..b148b16 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -127,6 +127,7 @@
 	NFSERR_SEQUENCE_POS = 10064,		/* v4.1 */
 
 	NFSERR_REPLAY_ME = 11001,	/* linux internal */
+	NFSERR_REPLAY_CACHE = 11002,		/* v4.1 linux internal */
 };
 
 /* NFSv2 file types - beware, these are not the same in NFSv3 */
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2e763eb..c8bbe94 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -255,6 +255,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_locked		__constant_htonl(NFSERR_LOCKED)
 #define	nfserr_wrongsec		__constant_htonl(NFSERR_WRONGSEC)
 #define	nfserr_replay_me	__constant_htonl(NFSERR_REPLAY_ME)
+#define	nfserr_replay_cache	__constant_htonl(NFSERR_REPLAY_CACHE)
 #define	nfserr_badiomode	__constant_htonl(NFSERR_BADIOMODE)
 #define	nfserr_badlayout	__constant_htonl(NFSERR_BADLAYOUT)
 #define nfserr_bad_session_digest	__constant_htonl(NFSERR_BAD_SESSION_DIGEST)
-- 
1.6.0.2


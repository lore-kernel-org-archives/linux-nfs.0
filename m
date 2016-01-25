Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34529 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbcAYOJz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 09:09:55 -0500
Received: by mail-io0-f182.google.com with SMTP id 1so152305430ion.1
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2016 06:09:54 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4.x: Fix wraparound issues when validing the callback sequence id
Date: Mon, 25 Jan 2016 09:09:15 -0500
Message-Id: <1453730956-5325-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1453730956-5325-4-git-send-email-trond.myklebust@primarydata.com>
References: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-2-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-3-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to make sure that we don't allow args->csa_sequenceid == 0.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 43 +++++++++++++++++--------------------------
 1 file changed, 17 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 345df6309017..79c93b3bbfec 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -354,23 +354,15 @@ out:
  * a single outstanding callback request at a time.
  */
 static __be32
-validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
+validate_seqid(const struct nfs4_slot_table *tbl, const struct nfs4_slot *slot,
+		const struct cb_sequenceargs * args)
 {
-	struct nfs4_slot *slot;
-
-	dprintk("%s enter. slotid %u seqid %u\n",
-		__func__, args->csa_slotid, args->csa_sequenceid);
+	dprintk("%s enter. slotid %u seqid %u, slot table seqid: %u\n",
+		__func__, args->csa_slotid, args->csa_sequenceid, slot->seq_nr);
 
 	if (args->csa_slotid > tbl->server_highest_slotid)
 		return htonl(NFS4ERR_BADSLOT);
 
-	slot = tbl->slots + args->csa_slotid;
-	dprintk("%s slot table seqid: %u\n", __func__, slot->seq_nr);
-
-	/* Normal */
-	if (likely(args->csa_sequenceid == slot->seq_nr + 1))
-		goto out_ok;
-
 	/* Replay */
 	if (args->csa_sequenceid == slot->seq_nr) {
 		dprintk("%s seqid %u is a replay\n",
@@ -386,16 +378,14 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	}
 
 	/* Wraparound */
-	if (args->csa_sequenceid == 1 && (slot->seq_nr + 1) == 0) {
-		slot->seq_nr = 1;
-		goto out_ok;
-	}
+	if (unlikely(slot->seq_nr == 0xFFFFFFFFU)) {
+		if (args->csa_sequenceid == 1)
+			return htonl(NFS4_OK);
+	} else if (likely(args->csa_sequenceid == slot->seq_nr + 1))
+		return htonl(NFS4_OK);
 
 	/* Misordered request */
 	return htonl(NFS4ERR_SEQ_MISORDERED);
-out_ok:
-	tbl->highest_used_slotid = args->csa_slotid;
-	return htonl(NFS4_OK);
 }
 
 /*
@@ -486,6 +476,13 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 		goto out_unlock;
 	}
 
+	status = validate_seqid(tbl, slot, args);
+	if (status)
+		goto out_unlock;
+
+	cps->slotid = args->csa_slotid;
+	tbl->highest_used_slotid = args->csa_slotid;
+
 	memcpy(&res->csr_sessionid, &args->csa_sessionid,
 	       sizeof(res->csr_sessionid));
 	res->csr_sequenceid = args->csa_sequenceid;
@@ -493,12 +490,6 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	res->csr_highestslotid = tbl->server_highest_slotid;
 	res->csr_target_highestslotid = tbl->target_highest_slotid;
 
-	status = validate_seqid(tbl, args);
-	if (status)
-		goto out_unlock;
-
-	cps->slotid = args->csa_slotid;
-
 	/* The ca_maxresponsesize_cached is 0 with no DRC */
 	if (args->csa_cachethis != 0)
 		return htonl(NFS4ERR_REP_TOO_BIG_TO_CACHE);
@@ -518,7 +509,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	 * If CB_SEQUENCE returns an error, then the state of the slot
 	 * (sequence ID, cached reply) MUST NOT change.
 	 */
-	slot->seq_nr++;
+	slot->seq_nr = args->csa_sequenceid;
 out_unlock:
 	spin_unlock(&tbl->slot_tbl_lock);
 
-- 
2.5.0


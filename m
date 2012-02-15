Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36748 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757340Ab2BOAmu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 19:42:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] nfsd4: rearrange struct nfsd4_slot
Date: Tue, 14 Feb 2012 19:42:45 -0500
Message-Id: <1329266566-8977-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1329266566-8977-1-git-send-email-bfields@redhat.com>
References: <1329266566-8977-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Combine two booleans into a single flag field, move the smaller fields
to the end.

(In practice this doesn't make the struct any smaller.  But we'll be
adding another flag here soon.)

Remove some debugging code that doesn't look useful, while we're in the
neighborhood.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   13 ++++++-------
 fs/nfsd/nfs4xdr.c   |    5 ++---
 fs/nfsd/state.h     |    7 ++++---
 fs/nfsd/xdr4.h      |    3 ++-
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2095dbb..e0e706f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1374,15 +1374,12 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 	struct nfsd4_op *op;
 	struct nfsd4_slot *slot = resp->cstate.slot;
 
-	dprintk("--> %s resp->opcnt %d cachethis %u \n", __func__,
-		resp->opcnt, resp->cstate.slot->sl_cachethis);
-
 	/* Encode the replayed sequence operation */
 	op = &args->ops[resp->opcnt - 1];
 	nfsd4_encode_operation(resp, op);
 
 	/* Return nfserr_retry_uncached_rep in next operation. */
-	if (args->opcnt > 1 && slot->sl_cachethis == 0) {
+	if (args->opcnt > 1 && !(slot->sl_flags & NFSD4_SLOT_CACHETHIS)) {
 		op = &args->ops[resp->opcnt++];
 		op->status = nfserr_retry_uncached_rep;
 		nfsd4_encode_operation(resp, op);
@@ -1916,7 +1913,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	 * sr_highest_slotid and the sr_target_slot id to maxslots */
 	seq->maxslots = session->se_fchannel.maxreqs;
 
-	status = check_slot_seqid(seq->seqid, slot->sl_seqid, slot->sl_inuse);
+	status = check_slot_seqid(seq->seqid, slot->sl_seqid,
+					slot->sl_flags & NFSD4_SLOT_INUSE);
 	if (status == nfserr_replay_cache) {
 		cstate->slot = slot;
 		cstate->session = session;
@@ -1933,9 +1931,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	conn = NULL;
 
 	/* Success! bump slot seqid */
-	slot->sl_inuse = true;
 	slot->sl_seqid = seq->seqid;
-	slot->sl_cachethis = seq->cachethis;
+	slot->sl_flags = NFSD4_SLOT_INUSE;
+	if (seq->cachethis)
+		slot->sl_flags |= NFSD4_SLOT_CACHETHIS;
 
 	cstate->slot = slot;
 	cstate->session = session;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0ec5a1b..279a705 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3532,7 +3532,7 @@ int nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 	if (length > session->se_fchannel.maxresp_sz)
 		return nfserr_rep_too_big;
 
-	if (slot->sl_cachethis == 1 &&
+	if ((slot->sl_flags & NFSD4_SLOT_CACHETHIS) &&
 	    length > session->se_fchannel.maxresp_cached)
 		return nfserr_rep_too_big_to_cache;
 
@@ -3656,8 +3656,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	if (nfsd4_has_session(cs)) {
 		if (cs->status != nfserr_replay_cache) {
 			nfsd4_store_cache_entry(resp);
-			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
-			cs->slot->sl_inuse = false;
+			cs->slot->sl_flags &= ~NFSD4_SLOT_INUSE;
 		}
 		/* Renew the clientid on success and on replay */
 		release_session_client(cs->session);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ffb5df1..122217f 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -128,12 +128,13 @@ static inline struct nfs4_delegation *delegstateid(struct nfs4_stid *s)
 		(NFSD_CACHE_SIZE_SLOTS_PER_SESSION * NFSD_SLOT_CACHE_SIZE)
 
 struct nfsd4_slot {
-	bool	sl_inuse;
-	bool	sl_cachethis;
-	u16	sl_opcnt;
 	u32	sl_seqid;
 	__be32	sl_status;
 	u32	sl_datalen;
+	u16	sl_opcnt;
+#define NFSD4_SLOT_INUSE	(1 << 0)
+#define NFSD4_SLOT_CACHETHIS	(1 << 1)
+	u8	sl_flags;
 	char	sl_data[];
 };
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2364747..21dccdf 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -503,7 +503,8 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 
 static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
 {
-	return !resp->cstate.slot->sl_cachethis || nfsd4_is_solo_sequence(resp);
+	return !(resp->cstate.slot->sl_flags & NFSD4_SLOT_CACHETHIS)
+		|| nfsd4_is_solo_sequence(resp);
 }
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
-- 
1.7.5.4


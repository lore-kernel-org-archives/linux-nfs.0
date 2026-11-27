Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795801297;
	b=4uJ8smCKuvLr1RmVM2nXYWh3axUlzHDSV8dKIRbY5ttvPYOrxa+cbp2HmeZS7Zo/ODu5
	 T5zyPQbzwdaE1OFwIesUKCxutaRj/dRpj7BZ1OJbkBz5e6fRvLdCHlPlUkzCwsR8VgfSE
	 kJbND5jKF2X772ABejA4ndNlJAj3C7aaGUAMvGvm7qysX31pUDhUEqzkUX8pxMD4X51+v
	 z8AWbe951j3FAZMAxidBVdBi0qlj7E4+3YTMfoaizDRAtr7E4HMnS0AScYqfOgKSjpoMB
	 Aw8iSdpRT3Z/E2pxCDsdmCOzyUONswUdjVDkpxaAUlqSM++E80vUjEfeEpS2Gepc6iA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795801297;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=NVTXQ7N/gEp0/G7gjjvIfdJXgtdsU5BYxgzcTaJjNCE=;
	b=KxTet+vx6UsOOLevvIHkmjFSM/1dQxQbpb5WmWOZbYQilhffmjGqYdk6j+mLYaOhvtDC
	 LkcjpW9poDzR7U00Wtq5Nn1wfvtipmN6G+VebhK01UvtVmnTZ0roiOfkQpGovyajSEND6
	 W3unXA46Dal4fIe3ArC5iNuFvkUmLcQfzWnrHDAOih56+cGyWmrsgYJevonRZzL6Tm/SS
	 Cwqtg+1dBwNsfM06j8rdaLbwdquVOqKVUsQ4pxBSJBv5AYNTp54X4DJx3Wi5AIRWUqCDa
	 7A9xirYKrOYvEQ2tGANf/rcqgVo3SzUFhmOmBhpTjj81i3DuDQIFr7oK7tPa9lVLS2w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W0SMfuig;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A0C6606A321
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 17:41:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W0SMfuig
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 601B41F000C1;
	Fri, 27 Nov 2026 17:41:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795801296;
	bh=NVTXQ7N/gEp0/G7gjjvIfdJXgtdsU5BYxgzcTaJjNCE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=W0SMfuigXwkFYvglA8i7W0G3LF9obH+9+Jp0rbr1MM4jJKo/fzChyKpM5ZuWgnONy
	 IbaYTSzFzLy1qYRdXjqMla0QP3f3wadJvqefmGyAjFvE72+r/j8QzKx4rqXt8DJaZ6
	 +B6f/Bi1aNrFMakJab+ZdMydGqG2FiJXvsq3DbG1I1jqOLiYGLsYhjFoUSSDx7x6Wr
	 2+4qM90UMWd8r3Gbm+mv8bJJJ5gq5vvglBkyFNSmUUiUdwKIYCyHByEQmAfARN/sge
	 V6sfsrdjSqmvIENd2QMD124x2y7DQdMsb/gY73K6jEP1SnfofXKp1sKH+Z/Pz8SpMI
	 J5nbSMisraOEg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 27 Nov 2026 12:41:27 -0500
Subject: [PATCH RFC 5/5] NFSD: Remove the dead session slot retirement code
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261127-nfsd-slot-retire-v1-5-d9f6636cc713@kernel.org>
References: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
In-Reply-To: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: Chuck Lever <cel@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=8910; i=cel@kernel.org;
 h=from:subject:message-id; bh=ZGRqpELXCY1ZGXsWA+byCsm45ssp8j/eJrwsaKiy3bQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrCcDKFG5oagjY/W9EXNQr6GVioiqQc2Av5Kx+B
 QuPW3IFu2uJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawnAygAKCRAzarMzb2Z/
 l+8UD/9QvIVpXb2Ps/dlbpk6tvseAyTqHcv8tkvJR6WmGH2ITvuollHeNGdvRruYk7g8Og9mH/1
 AaDvvVSAPA/sxhPzUk7Hwks2WwDP+67N3Fpe1N844r+tFOb7mQyQgUXBZxiXhjCga4/eBw4XNrS
 vqY1Y8/9pDggxMTo2x8frWbJWhWYZ45wRN4GADjLXHLlVj4rUrh/8GXC4CV1Uzdu2Cbb+MmyUEJ
 YQqa/fRkkrn7SA+qK+I2nocnflOxAFxdOYP+zX4ojiTNFxRLbCozRy3yqy2P7vbUl3D3AtvuzSg
 gou3Q1b8PYJgtpsfL/mBrHImjNO1sr2/9RmjZbwF6VI5X+UCsSiqmdreFb5GYb7p5vgOiZUMkSL
 KSkToasP77MFEsm9ciaEtjpOlHYbRZY1cqj1qvvNbjXX7lVH5iguhDMp64NxlNEVK7S0OO4YAnm
 DqxsxzTgz4k/1Juk8dqJfZVOlM5vkUJ7Q1Rw0flUkLpGtOXJUuR77PQLRNMbkvIecafS4ZS5jqA
 0wNwEfjjADdKjLbs8aDVEmVsiem7UepqbM7f39kQuvMeeB/QRuSrEHalBwgOayAAzNqyPBEhsBi
 qP1MGaHuEhHYW+6eYQJKaYaoE6o73AIsx438iQU/oXqmyCzwZzsHlnFw4dAi6cMG6EFjGAHcQXB
 hmxmmNymhIdDtPg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_sequence() frees the slots beyond the first se_target_maxslots
once it takes a request as the client's acknowledgment of the lower
target. Only the session slot shrinker lowered se_target_maxslots. With
the shrinker gone, the target always equals se_fchannel.maxreqs, and
the freeing block cannot run.

Remove the block and the state only it used: the sequence IDs saved
for freed slots, NFSD4_SLOT_REUSED, and the slot generation counters.
free_session_slots() now runs only when a session is freed.

se_target_maxslots now duplicates se_fchannel.maxreqs, so remove it
as well. SEQUENCE and the clients info file report
se_fchannel.maxreqs as the target slot count.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 73 ++++++-----------------------------------------------
 fs/nfsd/state.h     |  4 ---
 fs/nfsd/trace.h     |  3 +--
 3 files changed, 9 insertions(+), 71 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9662b3f1fca4..6ddb35f5ae5a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2373,29 +2373,16 @@ gen_sessionid(struct nfsd4_session *ses, u64 rand)
 #define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
 
 static void
-free_session_slots(struct nfsd4_session *ses, int from)
+free_session_slots(struct nfsd4_session *ses)
 {
 	int i;
 
-	if (from >= ses->se_fchannel.maxreqs)
-		return;
-
-	for (i = from; i < ses->se_fchannel.maxreqs; i++) {
+	for (i = 0; i < ses->se_fchannel.maxreqs; i++) {
 		struct nfsd4_slot *slot = xa_load(&ses->se_slots, i);
 
-		/*
-		 * Save the seqid in case we reactivate this slot.
-		 * This will never require a memory allocation so GFP
-		 * flag is irrelevant
-		 */
-		xa_store(&ses->se_slots, i, xa_mk_value(slot->sl_seqid), 0);
 		free_svc_cred(&slot->sl_cred);
 		kfree(slot);
 	}
-	ses->se_fchannel.maxreqs = from;
-	/* Retain one slot so the session can make forward progress. */
-	if (ses->se_target_maxslots > from)
-		ses->se_target_maxslots = from ?: 1;
 }
 
 static struct nfsd4_slot *nfsd4_alloc_slot(struct nfsd4_channel_attrs *fattrs,
@@ -2447,7 +2434,6 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fattrs,
 	}
 	fattrs->maxreqs = i;
 	memcpy(&new->se_fchannel, fattrs, sizeof(struct nfsd4_channel_attrs));
-	new->se_target_maxslots = i;
 	new->se_cb_slot_avail = ~0U;
 	new->se_cb_highest_slot = min(battrs->maxreqs - 1,
 				      NFSD_BC_SLOT_TABLE_SIZE - 1);
@@ -2561,7 +2547,7 @@ static void nfsd4_del_conns(struct nfsd4_session *s)
 
 static void __free_session(struct nfsd4_session *ses)
 {
-	free_session_slots(ses, 0);
+	free_session_slots(ses);
 	xa_destroy(&ses->se_slots);
 	kfree_rcu(ses, rcu_head);
 }
@@ -3346,7 +3332,7 @@ static int client_info_show(struct seq_file *m, void *v)
 		seq_printf(m, " %u", ses->se_fchannel.maxreqs);
 	seq_printf(m, "\nsession target slots:");
 	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt)
-		seq_printf(m, " %u", ses->se_target_maxslots);
+		seq_printf(m, " %u", ses->se_fchannel.maxreqs);
 	spin_unlock(&clp->cl_lock);
 	seq_puts(m, "\n");
 
@@ -4613,8 +4599,6 @@ static __be32 check_slot_seqid(u32 seqid, u32 slot_seqid, u8 flags)
 	/* Note unsigned 32-bit arithmetic handles wraparound: */
 	if (likely(seqid == slot_seqid + 1))
 		return nfs_ok;
-	if ((flags & NFSD4_SLOT_REUSED) && seqid == 1)
-		return nfs_ok;
 	if (seqid == slot_seqid)
 		return nfserr_replay_cache;
 	return nfserr_seq_misordered;
@@ -5136,9 +5120,9 @@ static void nfsd4_construct_sequence_response(struct nfsd4_session *session,
 {
 	struct nfs4_client *clp = session->se_client;
 
-	seq->maxslots_response = max(session->se_target_maxslots,
+	seq->maxslots_response = max(session->se_fchannel.maxreqs,
 				     seq->maxslots);
-	seq->target_maxslots = session->se_target_maxslots;
+	seq->target_maxslots = session->se_fchannel.maxreqs;
 
 	switch (clp->cl_cb_state) {
 	case NFSD4_CB_DOWN:
@@ -5156,19 +5140,6 @@ static void nfsd4_construct_sequence_response(struct nfsd4_session *session,
 		seq->status_flags |= SEQ4_STATUS_ADMIN_STATE_REVOKED;
 }
 
-static bool nfsd4_slots_inuse(struct nfsd4_session *ses, int from)
-{
-	int i;
-
-	for (i = from; i < ses->se_fchannel.maxreqs; i++) {
-		struct nfsd4_slot *slot = xa_load(&ses->se_slots, i);
-
-		if (slot->sl_flags & NFSD4_SLOT_INUSE)
-			return true;
-	}
-	return false;
-}
-
 __be32
 nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		union nfsd4_op_u *u)
@@ -5181,7 +5152,6 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_client *clp;
 	struct nfsd4_slot *slot;
 	struct nfsd4_conn *conn;
-	bool retired = false;
 	__be32 status;
 	int buflen;
 	u32 maxlen, respsize;
@@ -5249,16 +5219,6 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out_put_session;
 
-	if (session->se_target_maxslots < session->se_fchannel.maxreqs &&
-	    slot->sl_generation == session->se_slot_gen &&
-	    seq->maxslots <= session->se_target_maxslots &&
-	    seq->slotid < session->se_target_maxslots &&
-	    !nfsd4_slots_inuse(session, session->se_target_maxslots)) {
-		/* Client acknowledged our reduce maxreqs */
-		free_session_slots(session, session->se_target_maxslots);
-		retired = true;
-	}
-
 	buflen = (seq->cachethis) ?
 			session->se_fchannel.maxresp_cached :
 			session->se_fchannel.maxresp_sz;
@@ -5286,9 +5246,7 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs_ok;
 	/* Success! accept new slot seqid */
 	slot->sl_seqid = seq->seqid;
-	slot->sl_flags &= ~NFSD4_SLOT_REUSED;
 	slot->sl_flags |= NFSD4_SLOT_INUSE;
-	slot->sl_generation = session->se_slot_gen;
 	if (seq->cachethis)
 		slot->sl_flags |= NFSD4_SLOT_CACHETHIS;
 	else
@@ -5312,23 +5270,14 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * another's slots; a shared budget would let idle sessions
 	 * pin an active client small.  Compare against the
 	 * configured maximum, not the running thread count, so a
-	 * client resuming from idle can grow back before the pool
+	 * client resuming from idle can grow before the pool
 	 * scales up.
-	 *
-	 * Do not grow the table in the call that retired slots.  A
-	 * rebuilt slot has no cached reply, so a retransmit on it
-	 * is executed again or fails with SEQ_MISORDERED.  Left
-	 * retired, the slot returns BADSLOT, which the client
-	 * recovers from.
 	 */
-	if (!retired &&
-	    seq->slotid == session->se_fchannel.maxreqs - 1 &&
-	    session->se_target_maxslots >= session->se_fchannel.maxreqs) {
+	if (seq->slotid == session->se_fchannel.maxreqs - 1) {
 		int s = session->se_fchannel.maxreqs;
 		int ceiling = min_t(int, NFSD_MAX_SLOTS_PER_SESSION,
 				    svc_serv_maxthreads(rqstp->rq_server));
 		int cnt = min(DIV_ROUND_UP(s, 5), ceiling - s);
-		void *prev_slot;
 
 		while (cnt-- > 0) {
 			/*
@@ -5340,16 +5289,10 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 						GFP_NOWAIT);
 			if (!slot)
 				break;
-			prev_slot = xa_load(&session->se_slots, s);
-			if (xa_is_value(prev_slot)) {
-				slot->sl_seqid = xa_to_value(prev_slot);
-				slot->sl_flags |= NFSD4_SLOT_REUSED;
-			}
 			if (!xa_is_err(xa_store(&session->se_slots, s, slot,
 						GFP_NOWAIT))) {
 				s += 1;
 				session->se_fchannel.maxreqs = s;
-				session->se_target_maxslots = s;
 			} else {
 				kfree(slot);
 				break;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b3c1a6486df9..7f2c63cd3bf8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -400,12 +400,10 @@ struct nfsd4_slot {
 	u32	sl_index;
 	u32	sl_datalen;
 	u16	sl_opcnt;
-	u16	sl_generation;
 #define NFSD4_SLOT_INUSE	(1 << 0)
 #define NFSD4_SLOT_CACHETHIS	(1 << 1)
 #define NFSD4_SLOT_INITIALIZED	(1 << 2)
 #define NFSD4_SLOT_CACHED	(1 << 3)
-#define NFSD4_SLOT_REUSED	(1 << 4)
 	u8	sl_flags;
 	char	sl_data[];
 };
@@ -487,9 +485,7 @@ struct nfsd4_session {
 	struct list_head	se_conns;
 	u32			se_cb_seq_nr[NFSD_BC_SLOT_TABLE_SIZE];
 	struct xarray		se_slots;	/* forward channel slots */
-	u16			se_slot_gen;
 	bool			se_dead;
-	u32			se_target_maxslots;
 	struct rcu_head		rcu_head;
 };
 
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 45a5db9def39..6497a96320fc 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1039,8 +1039,7 @@ DEFINE_CS_SLOT_EVENT(slot_seqid_unconf);
 		{ NFSD4_SLOT_INUSE,		"INUSE" },		\
 		{ NFSD4_SLOT_CACHETHIS,		"CACHETHIS" },		\
 		{ NFSD4_SLOT_INITIALIZED,	"INITIALIZED" },	\
-		{ NFSD4_SLOT_CACHED,		"CACHED" },		\
-		{ NFSD4_SLOT_REUSED,		"REUSED" })
+		{ NFSD4_SLOT_CACHED,		"CACHED" })
 
 TRACE_EVENT(nfsd_slot_seqid_sequence,
 	TP_PROTO(

-- 
2.56.0


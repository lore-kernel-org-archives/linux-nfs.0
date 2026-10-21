Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792544586;
	b=Bv1mQC752gMgWW5BoAnkyogtLy5tyHq9xqkBpIqGENfQerFxeew9LOeobCCnzHZJrLXD
	 +STIM2H3ofkaTmVzIH6dkCT8R/BcMtIIYtQ34EfbveU2qdYIUuvt1nLpcL5EG7KSJAN+w
	 vhOWTOd8gDWrzJLddZYTs6927bpNchv1BIj9+tRmVxTrh56GTMDEJQqbVGZYTWZp4FTFU
	 Fqtc8AWABein0ccC1XYTYILGco29zzWQ5pewPPdn8iI1acWvvcNBDd8RbUT1jzz/R0MCa
	 HEQ2rfl9de1tgimVxd0e9thFOSPYQdhwOvDqNyJULYcDrIPEFmIC8GYX0DCAA/ivuNA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792544586;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=ZlnvUHDwkjxP2Tsft5ngVTUhp+k9A8Q4gjAO6rLkhDQ=;
	b=oUxPA1hdJMAeBfT2ZpnbaL4bo4zXRAZlVqD1TwYWKYiO03cfxBM2ef81AbIujF1FgVRQ
	 rrni2j9iqbZi5FGY2cKnojq6PYDpDgW3wyn4Ku8K/wG754LZ7V+AnAd4jsWt4FaW7Amjq
	 h5RfZocQevMzhZ1NPlmJYn69Fw2aKomjQ5bJl/QJRqQgJ28EU0WE56lplZCnN9aAbwEAy
	 t1YKlMKBh6mAJlci9cguH2zb9nLai0jG1H1gJX//R1TwQArwFQThhMhrZv+1ujJlX0m1h
	 4hl/np2aTKI++c3ezvoGQKhu1LvIWrM5qN58T5WP/Qr2Qp3P4HvWePPbWYsVL9X0OJg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hEcL5s2U;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5A66606A31E;
	Wed, 21 Oct 2026 01:03:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hEcL5s2U
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1792544585;
	b=en40+YYgJoP3d0j5pUID/Ca2QGXlNQcPy47kp66ssqIeIbnmHbVb01Nxbk781POmiCxp
	 Uc74QlKrG0xDewB3wfD1DJTkZSm8cYay9xzRje1WJ6ESuxvvT4f0MrZsbQ0r/7c74gQjD
	 r3ZRqyfrHI5TGgfjT7pxzGFK7/SZPVzGwZLGcEu1W5X+eYln63mcFO9T56il/29uYCRwb
	 9w4xhGyHXmuY4uyllSne4gPCcDChX+mzbZY5N/WjTpEwkn+KYE53rq1uWXOYczqcCoryY
	 8uX3qwtRDWbeOYXv3Cj5YixWDV2LzgxJsSQQK8ip5nvYI223ef1nfLv0XCWdhufIAUw==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1792544585;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=ZlnvUHDwkjxP2Tsft5ngVTUhp+k9A8Q4gjAO6rLkhDQ=;
	b=UTM26evLSc7UHFuA9wp8krt5EolmUQRRLJoq9+ALX9FzDiwAX5ej08HsFDC701hTATeX
	 SnvFWlqgiVBlPODX/DO5l8Cz2Od+be2H40p5Rn5zTyB8m+nuhpLh/rfeihyfQzS1abcOW
	 4jBC1ISMNNywhrFGDX7bqyStyS2M26Aa/6GxS3BqCjqudrndVWigmY+/AHP+LrMbukVvP
	 8gkWZd30clfl2bnO3gVFXVffcll/5etzjAadgggFmCUn2hASo2AERBN4Mzxr5eiQvQXvX
	 iYudT+E0ju6SgGCbyTFqAREvrtwFn/p88RvYgbDIqp5lMz5ivM/m1nIL0oYhnP6JiNg==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 0A3C51F000CD;
	Wed, 21 Oct 2026 01:03:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792544585;
	bh=ZlnvUHDwkjxP2Tsft5ngVTUhp+k9A8Q4gjAO6rLkhDQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To;
	b=hEcL5s2UeUpeDy9xNra/4mDSjlO7yFTHup904LLYvK3+sElRdF4DhLAl8SjKduKR0
	 iOjIJaBUQ3JbQnVaWDnfplTwTx8Q2Fk1GPQREDujzNRfCwr2EZwr/KYEBrdKSHrs1X
	 Om8QswY/0lpR3vcbdTnT7bKItxiqUo8jnYIMtI04YNE//zupzgKtpBt5nNTRUREi3j
	 B73POBeX+jEGqeQROq2haLaltcsAI53hb1nmvhteEbfM44kMVyVH3qfqyFsSXVQbFV
	 FaRA9smldWlABXuuJrTwZz4yJEMlgqb81BDjlmSrI9CU6l7w6t2uP5F4M++rD6DRXX
	 wDXbh7AziTL4g==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 664804326F;
	Wed, 21 Oct 2026 01:03:03 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Wed, 21 Oct 2026 10:03:03 +0900
Subject: [PATCH 1/4] nfsd: share the grant slot record between delegations
 and layouts
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
Message-Id: <20261021-nfsd-layout-refcall-v1-1-797096b92377@samsung.com>
References: <20261021-nfsd-layout-refcall-v1-0-797096b92377@samsung.com>
In-Reply-To: <20261021-nfsd-layout-refcall-v1-0-797096b92377@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792544582; l=10984;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=QxHRB7614mP6+oETtTBuCFRB1KVGlQKvj8Q12/DfSdI=;
 b=eKim2/0cJbVCijvaBHTQfuyw/RRyVLn9IZvHZ7bpaa1a+B6KPv0UmgFwr7mK7AZ3GcZImktni
 ylRI18fak0CChCTj1q4GrhhmU7Nc7D2dDt4IQ8tgNXCVTtepODp/UgJ
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com
Content-Transfer-Encoding: 7bit

From: Daejun Park <daejun7.park@samsung.com>

The delegation code remembers the forward-channel slot that carried the
request that granted a delegation (dl_recall_grant), tests whether the
client has retired that slot since (nfsd4_recall_grant_slot_retired()),
and names the request as a referring call in the CB_SEQUENCE of a
recall. The next two patches need the same for layouts.

Make the record a type of its own, struct nfsd4_grant_slot, and move the
code that fills it in, the slot test and the code that adds the
referring call into nfsd41_record_grant_slot(),
nfsd41_grant_slot_retired() and nfsd41_cb_referring_grant(), named for
the session machinery they depend on. The flag that was part of the
delegation's record stays with the delegation, as
dl_recall_retired_at_send.

No change in behavior.

Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4state.c | 115 ++++++++++++++++++++++++++++++++++++----------------
 fs/nfsd/state.h     |  24 +++++++----
 2 files changed, 96 insertions(+), 43 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f2b52ba901..735eaa4b7f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1291,7 +1291,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 	dp->dl_recalled = false;
 	dp->dl_recall_rejected = false;
 	dp->dl_recall_grant.valid = false;
-	dp->dl_recall_grant.retired_at_send = false;
+	dp->dl_recall_retired_at_send = false;
 	get_nfs4_file(fp);
 	dp->dl_stid.sc_file = fp;
 	nfsd4_init_cb(&dp->dl_recall, dp->dl_stid.sc_client,
@@ -6251,37 +6251,49 @@ bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode)
  * gen_sessionid() composes a sessionid from the client's clientid and a
  * sequence counter, so the sequence alone identifies the granting session.
  */
-static void nfsd4_recall_grant_sessionid(const struct nfs4_delegation *dp,
-					 struct nfsd4_sessionid *sid)
+static void nfsd41_grant_slot_sessionid(struct nfs4_client *clp,
+					const struct nfsd4_grant_slot *grant,
+					struct nfsd4_sessionid *sid)
 {
-	sid->clientid = dp->dl_stid.sc_client->cl_clientid;
-	sid->sequence = dp->dl_recall_grant.sessionid_seq;
+	sid->clientid = clp->cl_clientid;
+	sid->sequence = grant->sessionid_seq;
 	sid->reserved = 0;
 }
 
-static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
+/**
+ * nfsd41_grant_slot_retired - has the client seen the reply to a grant?
+ * @clp: client that sent the granting request
+ * @grant: forward-channel slot that carried the request
+ *
+ * Context: Takes nn->client_lock.
+ *
+ * Return: true if the client has gone on to use the slot for a later
+ * request, or has given the slot up, so that it must have received the
+ * reply. False if that cannot be shown, and if @grant is not valid.
+ */
+bool nfsd41_grant_slot_retired(struct nfs4_client *clp,
+			       const struct nfsd4_grant_slot *grant)
 {
-	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfsd4_session *ses;
 	struct nfsd4_sessionid sid;
 	bool retired = false;
 	void *entry;
 
-	if (!dp->dl_recall_grant.valid)
+	if (!grant->valid)
 		return false;
 
-	nfsd4_recall_grant_sessionid(dp, &sid);
+	nfsd41_grant_slot_sessionid(clp, grant, &sid);
 
 	/*
-	 * A missing session does not prove the client saw the grant: a
+	 * A missing session does not prove the client saw the reply: a
 	 * DESTROY_SESSION unhashes its own session before the reply to
 	 * that compound is encoded.
 	 */
 	spin_lock(&nn->client_lock);
 	ses = __find_in_sessionid_hashtbl((struct nfs4_sessionid *)&sid,
 					  clp->net);
-	entry = ses ? xa_load(&ses->se_slots, dp->dl_recall_grant.slotid) : NULL;
+	entry = ses ? xa_load(&ses->se_slots, grant->slotid) : NULL;
 	if (xa_is_value(entry)) {
 		/*
 		 * A slot is freed only once the client has acknowledged
@@ -6294,18 +6306,49 @@ static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
 
 		/*
 		 * A reactivated slot was freed and rebuilt, so the same
-		 * acknowledgment applies. The seqid test errs toward
-		 * revoking: a rebuilt slot restarting at seqid 1 matches
-		 * an old grant.
+		 * acknowledgment applies. The seqid test errs toward "not
+		 * retired", the side on which the callers do not take the
+		 * client's answer at once: a rebuilt slot restarting at
+		 * seqid 1 matches an old grant.
 		 */
 		retired = (slot->sl_flags & NFSD4_SLOT_REUSED) ||
 			  ((slot->sl_flags & NFSD4_SLOT_INITIALIZED) &&
-			   slot->sl_seqid != dp->dl_recall_grant.seqid);
+			   slot->sl_seqid != grant->seqid);
 	}
 	spin_unlock(&nn->client_lock);
 	return retired;
 }
 
+/**
+ * nfsd41_cb_referring_grant - name a granting request as referring call
+ * @cb: callback that refers to state the request created
+ * @clp: client that sent the request
+ * @grant: forward-channel slot that carried the request
+ *
+ * Does nothing if @grant is not valid.
+ *
+ * Context: May sleep. Caller serializes access to @cb, as for
+ * nfsd41_cb_referring_call().
+ */
+void nfsd41_cb_referring_grant(struct nfsd4_callback *cb,
+			       struct nfs4_client *clp,
+			       const struct nfsd4_grant_slot *grant)
+{
+	struct nfsd4_sessionid sid;
+
+	if (!grant->valid)
+		return;
+	nfsd41_grant_slot_sessionid(clp, grant, &sid);
+	nfsd41_cb_referring_call(cb, (struct nfs4_sessionid *)&sid,
+				 grant->slotid, grant->seqid);
+}
+
+static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
+{
+	return nfsd41_grant_slot_retired(dp->dl_stid.sc_client,
+					 &dp->dl_recall_grant);
+}
+
 /*
  * ->prepare does not run on every send: nfsd4_run_cb_work() skips it
  * on a requeue, and a retry via rpc_restart_call_prepare() re-enters
@@ -6315,9 +6358,9 @@ static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
  */
 static void nfsd4_refresh_recall_grant(struct nfs4_delegation *dp)
 {
-	dp->dl_recall_grant.retired_at_send =
+	dp->dl_recall_retired_at_send =
 			nfsd4_recall_grant_slot_retired(dp);
-	if (dp->dl_recall_grant.retired_at_send)
+	if (dp->dl_recall_retired_at_send)
 		nfsd41_cb_destroy_referring_call_list(&dp->dl_recall);
 }
 
@@ -6345,15 +6388,9 @@ static bool nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 
 	nfsd4_refresh_recall_grant(dp);
 
-	if (dp->dl_recall_grant.valid && !dp->dl_recall_grant.retired_at_send) {
-		struct nfsd4_sessionid sid;
-
-		nfsd4_recall_grant_sessionid(dp, &sid);
-		nfsd41_cb_referring_call(&dp->dl_recall,
-					 (struct nfs4_sessionid *)&sid,
-					 dp->dl_recall_grant.slotid,
-					 dp->dl_recall_grant.seqid);
-	}
+	if (!dp->dl_recall_retired_at_send)
+		nfsd41_cb_referring_grant(&dp->dl_recall, dp->dl_stid.sc_client,
+					  &dp->dl_recall_grant);
 	return true;
 }
 
@@ -6405,7 +6442,7 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
 		 * the grant. Trust the rejection only if the slot had
 		 * retired when this recall was sent.
 		 */
-		if (dp->dl_recall_grant.retired_at_send) {
+		if (dp->dl_recall_retired_at_send) {
 			nfsd4_deleg_recall_rejected(dp);
 			return 1;
 		}
@@ -7014,19 +7051,25 @@ static bool nfsd4_want_read_deleg(const struct nfsd4_open *open)
 		OPEN4_SHARE_ACCESS_WANT_READ_DELEG;
 }
 
-static void
-nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
-				 const struct nfsd4_compound_state *cstate)
+/**
+ * nfsd41_record_grant_slot - remember the slot that carries a request
+ * @grant: record to fill in
+ * @cstate: compound state of the request
+ *
+ * Leaves @grant alone for a request without a session (NFSv4.0).
+ */
+void nfsd41_record_grant_slot(struct nfsd4_grant_slot *grant,
+			      const struct nfsd4_compound_state *cstate)
 {
 	const struct nfsd4_sessionid *sid;
 
 	if (!cstate->session)
 		return;
 	sid = (struct nfsd4_sessionid *)cstate->session->se_sessionid.data;
-	dp->dl_recall_grant.sessionid_seq = sid->sequence;
-	dp->dl_recall_grant.slotid = cstate->slot->sl_index;
-	dp->dl_recall_grant.seqid = cstate->slot->sl_seqid;
-	dp->dl_recall_grant.valid = true;
+	grant->sessionid_seq = sid->sequence;
+	grant->slotid = cstate->slot->sl_index;
+	grant->seqid = cstate->slot->sl_seqid;
+	grant->valid = true;
 }
 
 static struct nfs4_delegation *
@@ -7135,7 +7178,7 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	 * visible to lease breakers. A conflicting open can drive
 	 * CB_RECALL to completion from that point on.
 	 */
-	nfs4_delegation_record_grant_slot(dp, cstate);
+	nfsd41_record_grant_slot(&dp->dl_recall_grant, cstate);
 
 	if (stp->st_stid.sc_export)
 		dp->dl_stid.sc_export = exp_get(stp->st_stid.sc_export);
@@ -10771,7 +10814,7 @@ nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
 	dp = alloc_init_dir_deleg(clp, fp);
 	if (!dp)
 		goto out_delegees;
-	nfs4_delegation_record_grant_slot(dp, cstate);
+	nfsd41_record_grant_slot(&dp->dl_recall_grant, cstate);
 	if (cstate->current_fh.fh_export)
 		dp->dl_stid.sc_export =
 			exp_get(cstate->current_fh.fh_export);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5f43668486..2c00b334c3 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -276,6 +276,14 @@ struct nfsd4_cb_notify {
 	struct nfsd4_callback		ncn_cb;		// notify4 callback
 };
 
+/* Forward-channel slot that carried a request which created state */
+struct nfsd4_grant_slot {
+	u32			sessionid_seq;
+	u32			slotid;
+	u32			seqid;
+	bool			valid;
+};
+
 /*
  * Represents a delegation stateid. The nfs4_client holds references to these
  * and they are put when it is being destroyed or when the delegation is
@@ -315,13 +323,8 @@ struct nfs4_delegation {
 	bool			dl_setattr;
 
 	/* Forward-channel slot that carried the granting request */
-	struct {
-		u32			sessionid_seq;
-		u32			slotid;
-		u32			seqid;
-		bool			valid;
-		bool			retired_at_send;
-	} dl_recall_grant;
+	struct nfsd4_grant_slot	dl_recall_grant;
+	bool			dl_recall_retired_at_send;
 
 	union {
 		/* for CB_GETATTR */
@@ -949,6 +952,13 @@ extern void nfsd41_cb_referring_call(struct nfsd4_callback *cb,
 				     struct nfs4_sessionid *sessionid,
 				     u32 slotid, u32 seqno);
 extern void nfsd41_cb_destroy_referring_call_list(struct nfsd4_callback *cb);
+extern void nfsd41_record_grant_slot(struct nfsd4_grant_slot *grant,
+				     const struct nfsd4_compound_state *cstate);
+extern bool nfsd41_grant_slot_retired(struct nfs4_client *clp,
+				      const struct nfsd4_grant_slot *grant);
+extern void nfsd41_cb_referring_grant(struct nfsd4_callback *cb,
+				      struct nfs4_client *clp,
+				      const struct nfsd4_grant_slot *grant);
 extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 		const struct nfsd4_callback_ops *ops, enum nfsd4_cb_op op);
 extern bool nfsd4_run_cb(struct nfsd4_callback *cb);

-- 
2.43.0



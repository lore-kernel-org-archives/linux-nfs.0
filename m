Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792721425;
	b=kGlXoM6sNE/747V8o+kMNk6c9Kn+faD3vB7Rz4DWJWwK8fcePqLZKJX8f50P74QcYJHQ
	 s2W2Qwjh0h4/9qG0ok95KLKqbPtEBgmshoH5cuPiG+Dugbv9h5x0cxMNo7mI1knILia6n
	 ixDzqyvCQAgGJHF+ZrwMc2l5pJMhGIDaFa3v16lX32cn8LuB44xjP84GsjJGwj0x92u9y
	 /FlDUC/yllVR3QNnHPrroJK2sD1wvAfk/Vit6a3OkomL+dXlF/c7gF0OCBmnpi+yA93oV
	 o7vt+wa32hCSCxzuhdMGH/1IYiKZFLkUdGNPWvmajgGrTEeBF2PljUW87uXyFS1J9KA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792721425;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=ZlnvUHDwkjxP2Tsft5ngVTUhp+k9A8Q4gjAO6rLkhDQ=;
	b=nr5/iGlcNV6i5MdakKt2HG1lcaV2PdRnrYecGBnsp0BBN+3qqMyXlYlzbnENTCsLMYFr
	 QsiUjm7mxbEddS0G2zsZGlsZM0uquXfWIla0pWzxrq5ypKSRao1QYrFj+IoOC1GuzVdNv
	 wu5d+fbsaU2vn1CTpWEbtHw1brhPCmJbd2iuWklw7fajoe2oevLsPq7dGlisCrljEjPj7
	 tWm8e9MxqUlhto4LnySgm7SOvPqd3ea5cvk98sDEBrd3YXc9V16JShSGxl2F2zEJJu6ak
	 ZRBNH2Ur1SlGqSI73yP0VTi3oWpibl5mw9tVI49LVKrxGPwM2vxbJtCwhx3WWyvMatg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=V3nUeMnt;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3F77606A328;
	Fri, 23 Oct 2026 02:10:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=V3nUeMnt
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1792721424;
	b=RUjaWOoJzfVmdHRLd7YVckjFPKPBW/7RpXfyeAjBoIE+Vg9JKClq7Pn95lBXNctAqQam
	 L0UTvAKhj8YJ23F066xuEmPb/sl2d11ySEZzS2WHBdTzUzhVEO+Xoi5l/lK8MLIBP8fif
	 6QuagR+rvsV2Sse6cMM/lbwdyGsNKPf8YZ+QCt6QWaDTisD3fwCQJsNCn9bFI0Ya8BRNL
	 Y50sMZNCWE5+Q6dvhPCGOb9Z1SNKR7o44Ybt1TKxMGLLBuwcd/+dshW+sGC7yDKQSCx+/
	 oQPXA9HIrPeC/ZLRgcXemdhtpZ10WsVaVCUrklXTSOlg0RYI4sBpQlR/A5qVTgwVqhw==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1792721424;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=ZlnvUHDwkjxP2Tsft5ngVTUhp+k9A8Q4gjAO6rLkhDQ=;
	b=fJ7gq47SwcrzY3uV+2THR/6cUI4+AWseEOdoxNZuecSt5GRHdIdgrWCSMnHqNU9ZUGy2
	 mxO3EHMtTubz9goHZPNE8W3kokIXgDHKV0oWCEHqrL983IyK3ExHbnmhe1npzSr/G612G
	 /jJ5an48TilIvq6gpqLjJXoLGTx1fBK1PB2zIiasBee/LSt6XigBmBUE4BMDwtl1XiTGo
	 ryJXTzS40Ad+jttk9sIMnn7YZ5RxFjJekds+iBseZD+Ak7x2IUgm6XkP7pryM2QVwvBud
	 FEEQ0nCut6qwDQa91S9GcKFu6bdQuP60Ux5XMEUTDBgyODlonbT719FMDDnShiAlbwg==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id D40F41F01829;
	Fri, 23 Oct 2026 02:10:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792721424;
	bh=ZlnvUHDwkjxP2Tsft5ngVTUhp+k9A8Q4gjAO6rLkhDQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To;
	b=V3nUeMnt1lpFpHYtSuN/zxttIpZVW8nF54/E/j5BeQU3dK4a91F1ZEVpZnlFcenxL
	 PG3mOO0DFMh29AX77n6tUOZ0bcdxqlda7j4dbqnMfym1ykR5mQQggt7VRKTs8i8rF+
	 fK2wLrhVt7L+oKOCCAeiIa0yCcvSSE31DCXTPYpLpi7lDEr64veNSGbbiDkOxIAF/Z
	 70d+kCQP2TiXt3kbn4vOWdON+C8Dk67TN1AMb+TcSU4gGitNzpb3Wuc++7Xjodr1Ij
	 m42xu/Q7zYCCiTmds2OIrSgvt2cFLK9j8M6jZDfGbfQb6pgFWtnxmgmTPIL5Mv9tUK
	 yQRi9yFB4jXuQ==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 408C542194;
	Fri, 23 Oct 2026 02:10:21 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Fri, 23 Oct 2026 11:10:22 +0900
Subject: [PATCH v2 1/4] nfsd: share the grant slot record between
 delegations and layouts
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
Message-Id: <20261023-nfsd-layout-refcall-v2-1-2160bddced0c@samsung.com>
References: <20261023-nfsd-layout-refcall-v2-0-2160bddced0c@samsung.com>
In-Reply-To: <20261023-nfsd-layout-refcall-v2-0-2160bddced0c@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792721421; l=10984;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=QxHRB7614mP6+oETtTBuCFRB1KVGlQKvj8Q12/DfSdI=;
 b=i9FJEuH2Uv6+d6KTY6L9PHRBUOL+a4YIb3twxCRgzupw10ETrvoPGcdJ9aMHvdQGjW7sUGGuX
 srwN+5zlXMbAQk6nH7857iEEjCEVpv/S5DaKxLbZpEC+tEhAY26ayEu
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



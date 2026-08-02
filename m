Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46D1C3C2BA2;
	Sun,  2 Aug 2026 17:04:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690294; cv=none; b=PcFXKyzQFbWxakkhgFA7h6K9Kx9G3Gox7lz1m8PTxHR7KWDMZFAjIgBSWvwQWPOX52gktM4lC8VWFXYXAhMx/t9T5S4vwuxLm7qTwpztupts4hjHnbTEN4Fd5Tf1uP7G2iBZBhu28Gcwmn+OD40PNy0SPCq8h72qFMc2Un6DWuA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690294; c=relaxed/simple;
	bh=90YakG4lzXxb9Wy7V8cv1ZFaEESbqSTvL+aC4zwKqdI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=WtOtm5edDMIE5q3a8Ju8fLJIqPd1HvE2HoznCbDBD8NCQrbIC/UXJalKr2YT7ADZ2SchNYkloI4PEGXVlNwipzU283dUQ1qHxNdpRkhjQ9UFiPysVUsWUnyUKhnTDAd2fPa+WwppSf+33zzjkG0Eh73kgXyh11+WlCZYT/7kCpM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=h/PpG6VX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="h/PpG6VX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B933C1F00A3E;
	Sun,  2 Aug 2026 17:04:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690289;
	bh=IOCAXr4mRkP4SYMA9QL5Ojta2vj6DssKw4XgWnuyGX8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=h/PpG6VXQJSY3RHG+DhCtuOQN0Kfsy3YawzwM3UNIseteGUbiBqrYPXoqCpqVMV7f
	 rPUz7wZu3qh4X+v60vV428Vyp1UbLHWbLGNYpRdc+EuTsJrlBIq4S1Znh1ssklrK76
	 cM3Xp7ykPAbb8BZ/2/vmpasZy2Ljq5I+J8SGgqgUcZS+sSo4t6R/onjZ2iYwyJLx4e
	 t76CAr0o9yv8uc9Y1EHuV5oQbmjV4df4JYkZU5hPZKqOBr+4JHoO/CXAAGTxH5n2Df
	 BSkMSyWTKbRpEf/Ar7mommiH+5EdCZjly0PE9OSysh/xpQDVWoQveXyvpasfXzJUhI
	 qUoZincWAn/vA==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:35 -0400
Subject: [PATCH 8/9] NFSD: Destroy a recalled delegation the client does
 not hold
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-8-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=14365; i=cel@kernel.org;
 h=from:subject:message-id; bh=90YakG4lzXxb9Wy7V8cv1ZFaEESbqSTvL+aC4zwKqdI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3iqV9QXgOlsX497YvharJ8xerB99hx3UTZ8V
 7W+1+w3xNOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qgAKCRAzarMzb2Z/
 l56WEACKClH/u2rD7YBAe3KEhj/Y5A4tc0cpGHUZDzLHlZZOCJVVBx5BMcaIVcJHIPv68oPGA97
 j7lE8eEx0QOXZ72VoCynZ5hk034NhaeTV+2ZFi1zn6ofzo/SU8xc5M7el6nhr7PSj4S+zhu68Ku
 DGlTkf+Zlx3DU0TntLbGRNI+8RL5o5Q2o7C4rHm6OG9umClKhSYjCAtFuqyc2o8QMbcfY4TEo3r
 1qVb48L7ezaVQsICthCnhaAh3iYoHyMuQE/5/U+z3HAKfpFFaI5pALkJPDlfGUiU4vx8qOZpWSz
 5p3UwgwyRqcnbhOd/zNW1pjQZW29nMgmEMQJ/hj08MpGUOWjeJC/xgmLreNboiQfhBNh8cWad/4
 nYBNbbEP6aqNgLIsXrbyDUoh3PHapQBRQbmEKahOyvTmRkB2+M0nOviXEObp9m8jxGNnsJbAEs/
 rU2uD3BQoSYPq22IYvdEwbyKI5zYDRA0kUEhNBOLEIyJu4IhCuTo/9KozBp/ekbEVpZy/FV+B8v
 WxKhlVZRtIvvxiiQy52vvUON1RNRCQqKHOv/0U+a5zAqVi0TqRtueqxxcJopU/SB6RuOlefJW7w
 azyeAWyYCI1sWXNZIpbtnhsuXKyfDphLQDGKboxpAlElOU+CmGfgBfdNdToun5/CwAqfLDaSHdd
 ovWTQ/NT8xBQQjw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A client that answers CB_RECALL with NFS4ERR_BADHANDLE or
NFS4ERR_BAD_STATEID has no record of the delegation, so the
FREE_STATEID that clears it from cl_revoked never arrives. Every later
SEQUENCE reply carries SEQ4_STATUS_RECALLABLE_STATE_REVOKED, and the
client loops issuing TEST_STATEID.

Destroy such a delegation when it is reaped rather than revoking it
onto cl_revoked. RFC 8881 Section 20.2.4 completes the recall at the
reply when its status is neither NFS4_OK nor NFS4ERR_DELAY, so a
rejected recall leaves nothing to revoke. An administrative revoke
keeps that path, since NFS4ERR_ADMIN_REVOKED reports it. A destroyed
stateid returns NFS4ERR_BAD_STATEID instead of NFS4ERR_DELEG_REVOKED. A
client that rejects the recall but still holds the delegation gets no
notice that its state was revoked.

CB_RECALL can outrun the reply that granted the delegation, so honor
a rejection only once the client has seen that grant. Per RFC 8881
Section 2.10.6.3, retirement of the slot that carried the grant is that
proof; retry until then, and revoke when the retries lapse.

Fixes: 3bd64a5ba171 ("nfsd4: implement SEQ4_STATUS_RECALLABLE_STATE_REVOKED")
Cc: <stable@vger.kernel.org> # 6.14.x
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 198 +++++++++++++++++++++++++++++++++++++++++++---------
 fs/nfsd/state.h     |  13 +++-
 2 files changed, 178 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d93672e6fa26..5774c7a1b3de 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -94,6 +94,8 @@ static void nfsd4_end_grace(struct nfsd_net *nn);
 static void _free_cpntf_state_locked(struct nfsd_net *nn, struct nfs4_cpntf_state *cps);
 static void nfsd4_file_hash_remove(struct nfs4_file *fi);
 static void deleg_reaper(struct nfsd_net *nn);
+static void nfsd4_drop_revoked_stid(struct nfs4_stid *s)
+	__releases(&s->sc_client->cl_lock);
 
 static const struct lease_manager_operations nfsd_lease_mng_ops;
 
@@ -1281,6 +1283,9 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 	dp->dl_type = dl_type;
 	dp->dl_retries = 1;
 	dp->dl_recalled = false;
+	dp->dl_recall_rejected = false;
+	dp->dl_recall_grant.valid = false;
+	dp->dl_recall_grant.retired_at_send = false;
 	get_nfs4_file(fp);
 	dp->dl_stid.sc_file = fp;
 	nfsd4_init_cb(&dp->dl_recall, dp->dl_stid.sc_client,
@@ -1565,27 +1570,22 @@ static void destroy_delegation(struct nfs4_delegation *dp)
 }
 
 /**
- * revoke_delegation - perform nfs4 delegation structure cleanup
- * @dp: pointer to the delegation
+ * revoke_delegation - dispose of a delegation the server has revoked
+ * @dp: delegation to dispose of
  *
- * This function assumes that it's called either from the administrative
- * interface (nfsd4_revoke_states()) that's revoking a specific delegation
- * stateid or it's called from a laundromat thread (nfsd4_landromat()) that
- * determined that this specific state has expired and needs to be revoked
- * (both mark state with the appropriate stid sc_status mode). It is also
- * assumed that a reference was taken on the @dp state. This function
- * consumes that reference.
+ * The caller holds a reference on @dp, which this function consumes.
+ * On NFSv4.1 and newer, @dp's sc_status must already carry
+ * SC_STATUS_REVOKED or SC_STATUS_ADMIN_REVOKED.
  *
- * If this function finds that the @dp state is SC_STATUS_FREED it means
- * that a FREE_STATEID operation for this stateid has been processed and
- * we can proceed to removing it from recalled list. However, if @dp state
- * isn't marked SC_STATUS_FREED, it means we need place it on the cl_revoked
- * list and wait for the FREE_STATEID to arrive from the client. At the same
- * time, we need to mark it as SC_STATUS_FREEABLE to indicate to the
- * nfsd4_free_stateid() function that this stateid has already been added
- * to the cl_revoked list and that nfsd4_free_stateid() is now responsible
- * for removing it from the list. Inspection of where the delegation state
- * in the revocation process is protected by the clp->cl_lock.
+ * @dp is parked on the client's cl_revoked list to await a FREE_STATEID.
+ * Where none can arrive, @dp is destroyed here instead: FREE_STATEID has
+ * already freed it, or the client rejected the recall with
+ * NFS4ERR_BADHANDLE or NFS4ERR_BAD_STATEID and holds no record of the
+ * delegation. NFS4ERR_ADMIN_REVOKED still prompts one, so an
+ * administrative revoke waits on cl_revoked.
+ *
+ * Context: Takes and releases the client's cl_lock; may sleep after
+ *          dropping it.
  */
 static void revoke_delegation(struct nfs4_delegation *dp)
 {
@@ -1603,6 +1603,19 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 		list_del_init(&dp->dl_recall_lru);
 		goto out;
 	}
+	if (dp->dl_recall_rejected &&
+	    !(dp->dl_stid.sc_status & SC_STATUS_ADMIN_REVOKED)) {
+		/*
+		 * SC_STATUS_CLOSED, set under cl_lock, makes a racing
+		 * FREE_STATEID bail out rather than drop this reference
+		 * too. The put releases what cl_revoked would have held.
+		 */
+		dp->dl_stid.sc_status |= SC_STATUS_CLOSED;
+		spin_unlock(&clp->cl_lock);
+		nfs4_put_stid(&dp->dl_stid);
+		destroy_unhashed_deleg(dp);
+		return;
+	}
 	list_add(&dp->dl_recall_lru, &clp->cl_revoked);
 	dp->dl_stid.sc_status |= SC_STATUS_FREEABLE;
 out:
@@ -2897,11 +2910,18 @@ __destroy_client(struct nfs4_client *clp)
 		list_del_init(&dp->dl_recall_lru);
 		destroy_unhashed_deleg(dp);
 	}
+	/*
+	 * A CB_RECALL reply can release revoked delegations concurrently:
+	 * nfsd4_shutdown_callback() has not run yet.
+	 */
+	spin_lock(&clp->cl_lock);
 	while (!list_empty(&clp->cl_revoked)) {
 		dp = list_entry(clp->cl_revoked.next, struct nfs4_delegation, dl_recall_lru);
-		list_del_init(&dp->dl_recall_lru);
-		nfs4_put_stid(&dp->dl_stid);
+		/* this function drops ->cl_lock */
+		nfsd4_drop_revoked_stid(&dp->dl_stid);
+		spin_lock(&clp->cl_lock);
 	}
+	spin_unlock(&clp->cl_lock);
 	while (!list_empty(&clp->cl_openowners)) {
 		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
 		nfs4_get_stateowner(&oo->oo_owner);
@@ -6071,6 +6091,60 @@ bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode)
 	return timeo > 0;
 }
 
+static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
+{
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfsd4_session *ses;
+	struct nfsd4_sessionid sid;
+	bool retired = false;
+	void *entry;
+
+	if (!dp->dl_recall_grant.valid)
+		return false;
+
+	/*
+	 * gen_sessionid() composes a sessionid from the client's clientid
+	 * and a sequence counter, so the sequence alone identifies the
+	 * granting session.
+	 */
+	sid.clientid = clp->cl_clientid;
+	sid.sequence = dp->dl_recall_grant.sessionid_seq;
+	sid.reserved = 0;
+
+	/*
+	 * A missing session does not prove the client saw the grant: a
+	 * DESTROY_SESSION unhashes its own session before the reply to
+	 * that compound is encoded.
+	 */
+	spin_lock(&nn->client_lock);
+	ses = __find_in_sessionid_hashtbl((struct nfs4_sessionid *)&sid,
+					  clp->net);
+	entry = ses ? xa_load(&ses->se_slots, dp->dl_recall_grant.slotid) : NULL;
+	if (xa_is_value(entry)) {
+		/*
+		 * A slot is freed only once the client has acknowledged
+		 * the smaller slot table, which it cannot do while a
+		 * request on that slot is outstanding.
+		 */
+		retired = true;
+	} else if (entry) {
+		struct nfsd4_slot *slot = entry;
+
+		/*
+		 * A reactivated slot was freed and rebuilt, so the same
+		 * acknowledgment applies. The seqid test errs toward
+		 * revoking: a rebuilt slot restarting at seqid 1 matches
+		 * an old grant.
+		 */
+		retired = (slot->sl_flags & NFSD4_SLOT_REUSED) ||
+			  ((slot->sl_flags & NFSD4_SLOT_INITIALIZED) &&
+			   slot->sl_seqid != dp->dl_recall_grant.seqid);
+	}
+	spin_unlock(&nn->client_lock);
+	return retired;
+}
+
 static bool nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 {
 	struct nfs4_delegation *dp = cb_to_delegation(cb);
@@ -6092,9 +6166,37 @@ static bool nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
 	}
 	spin_unlock(&nn->deleg_lock);
+
+	dp->dl_recall_grant.retired_at_send =
+			nfsd4_recall_grant_slot_retired(dp);
 	return true;
 }
 
+/*
+ * cl_lock orders this against a laundromat reaping @dp: either
+ * revoke_delegation() observes dl_recall_rejected and destroys @dp, or
+ * it reached cl_revoked first and @dp is released here instead.
+ */
+static void nfsd4_deleg_recall_rejected(struct nfs4_delegation *dp)
+{
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
+
+	spin_lock(&clp->cl_lock);
+	if (dp->dl_stid.sc_status & (SC_STATUS_CLOSED | SC_STATUS_FREED |
+				     SC_STATUS_ADMIN_REVOKED)) {
+		spin_unlock(&clp->cl_lock);
+		return;
+	}
+	if (dp->dl_stid.sc_status & SC_STATUS_FREEABLE) {
+		dp->dl_stid.sc_status |= SC_STATUS_CLOSED;
+		/* this function drops ->cl_lock */
+		nfsd4_drop_revoked_stid(&dp->dl_stid);
+		return;
+	}
+	dp->dl_recall_rejected = true;
+	spin_unlock(&clp->cl_lock);
+}
+
 static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
 		struct rpc_task *task)
 {
@@ -6102,27 +6204,33 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
 
 	trace_nfsd_cb_recall_done(&dp->dl_stid.sc_stateid, task);
 
-	if (dp->dl_stid.sc_status)
-		/* CLOSED or REVOKED */
-		return 1;
-
 	switch (task->tk_status) {
 	case 0:
 		return 1;
 	case -NFS4ERR_DELAY:
+		if (dp->dl_stid.sc_status)
+			/* CLOSED or REVOKED */
+			return 1;
 		rpc_delay(task, 2 * HZ);
 		return 0;
 	case -EBADHANDLE:
 	case -NFS4ERR_BAD_STATEID:
 		/*
-		 * Race: client probably got cb_recall before open reply
-		 * granting delegation.
+		 * Retirement of the granting slot proves the client saw
+		 * the grant. Trust the rejection only if the slot had
+		 * retired when this recall was sent.
 		 */
-		if (dp->dl_retries--) {
+		if (dp->dl_recall_grant.retired_at_send) {
+			nfsd4_deleg_recall_rejected(dp);
+			return 1;
+		}
+		if (!dp->dl_stid.sc_status && dp->dl_retries--) {
+			dp->dl_recall_grant.retired_at_send =
+					nfsd4_recall_grant_slot_retired(dp);
 			rpc_delay(task, 2 * HZ);
 			return 0;
 		}
-		fallthrough;
+		return 1;
 	default:
 		return 1;
 	}
@@ -6716,9 +6824,25 @@ static bool nfsd4_want_deleg_timestamps(const struct nfsd4_open *open)
 	return open->op_deleg_want & OPEN4_SHARE_ACCESS_WANT_DELEG_TIMESTAMPS;
 }
 
+static void
+nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
+				 const struct nfsd4_compound_state *cstate)
+{
+	const struct nfsd4_sessionid *sid;
+
+	if (!cstate->session)
+		return;
+	sid = (struct nfsd4_sessionid *)cstate->session->se_sessionid.data;
+	dp->dl_recall_grant.sessionid_seq = sid->sequence;
+	dp->dl_recall_grant.slotid = cstate->slot->sl_index;
+	dp->dl_recall_grant.seqid = cstate->slot->sl_seqid;
+	dp->dl_recall_grant.valid = true;
+}
+
 static struct nfs4_delegation *
-nfs4_set_delegation(struct nfsd4_open *open, struct nfs4_ol_stateid *stp,
-		    struct svc_fh *parent)
+nfs4_set_delegation(struct nfsd4_open *open,
+		    const struct nfsd4_compound_state *cstate,
+		    struct nfs4_ol_stateid *stp, struct svc_fh *parent)
 {
 	bool deleg_ts = nfsd4_want_deleg_timestamps(open);
 	struct nfs4_client *clp = stp->st_stid.sc_client;
@@ -6808,6 +6932,14 @@ nfs4_set_delegation(struct nfsd4_open *open, struct nfs4_ol_stateid *stp,
 	dp = alloc_init_deleg(clp, fp, odstate, dl_type);
 	if (!dp)
 		goto out_delegees;
+
+	/*
+	 * Record the granting slot before kernel_setlease() makes @dp
+	 * visible to lease breakers. A conflicting open can drive
+	 * CB_RECALL to completion from that point on.
+	 */
+	nfs4_delegation_record_grant_slot(dp, cstate);
+
 	if (stp->st_stid.sc_export)
 		dp->dl_stid.sc_export = exp_get(stp->st_stid.sc_export);
 
@@ -6972,6 +7104,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		     struct nfs4_ol_stateid *stp, struct svc_fh *currentfh,
 		     struct svc_fh *fh)
 {
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_openowner *oo = openowner(stp->st_stateowner);
 	bool deleg_ts = nfsd4_want_deleg_timestamps(open);
 	struct nfs4_client *clp = stp->st_stid.sc_client;
@@ -7008,7 +7141,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		default:
 			goto out_no_deleg;
 	}
-	dp = nfs4_set_delegation(open, stp, parent);
+	dp = nfs4_set_delegation(open, &resp->cstate, stp, parent);
 	if (IS_ERR(dp))
 		goto out_no_deleg;
 
@@ -10302,6 +10435,7 @@ nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
 	dp = alloc_init_dir_deleg(clp, fp);
 	if (!dp)
 		goto out_delegees;
+	nfs4_delegation_record_grant_slot(dp, cstate);
 	if (cstate->current_fh.fh_export)
 		dp->dl_stid.sc_export =
 			exp_get(cstate->current_fh.fh_export);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 42d3320622eb..ff1c9fa731aa 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -292,7 +292,8 @@ struct nfsd4_cb_notify {
  * If the server attempts to recall a delegation and the client doesn't do so
  * before a timeout, the server may also revoke the delegation. In that case,
  * the object will either be destroyed (v4.0) or moved to a per-client list of
- * revoked delegations (v4.1+).
+ * revoked delegations (v4.1+). A v4.1+ client that rejects the recall holds
+ * no record of the delegation, so the object is destroyed rather than listed.
  *
  * This object is a superset of the nfs4_stid.
  */
@@ -308,9 +309,19 @@ struct nfs4_delegation {
 	int			dl_retries;
 	struct nfsd4_callback	dl_recall;
 	bool			dl_recalled;
+	bool			dl_recall_rejected;
 	bool			dl_written;
 	bool			dl_setattr;
 
+	/* Forward-channel slot that carried the granting request */
+	struct {
+		u32			sessionid_seq;
+		u32			slotid;
+		u32			seqid;
+		bool			valid;
+		bool			retired_at_send;
+	} dl_recall_grant;
+
 	union {
 		/* for CB_GETATTR */
 		struct nfs4_cb_fattr    dl_cb_fattr;

-- 
2.54.0


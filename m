Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332671;
	b=kJtCqnKp6xcusCjgUwbRvtBkdcY4HuVx5fYFoxp07Ww2raeVfoMxUrWGPEDucWZeCNOQ
	 21oGgN+KzImU6IY+H06CUsQwW5u+cthTt+d8v4wE6NX+uVuGfaBTsmKqqkIUgSWTTCjUB
	 NGrMphXiWMdqust9dDC3xBuR6G/bn5LMKDh+cQpi0Wz61GlYdKlAoGu+OlJac7XbPqM/B
	 Pn/AdnwuCfqfIyRHRAMGQjP804Ifb4FlV7sEbam4lBBER4YEkEOipc3eMOhkQlTf+KZ5e
	 pLyrOG6BSswQmOrLBwdadMzI6ffV0z2SOvP9EfNzfNb+AXvc9ITfOC3/TE6sKNxjWuw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332671;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=3klt652QmEXe+/usMyh47NNNqp88+GTBOzYwSbpuIOk=;
	b=QY4QzcsZQmv7DqB9eEKaZI07MKZ4mwbJiyp66baicBJyOlJbGqaB6tUin3h3UIc7PsJ9
	 EV4b8SXIY4nRyE3Z2/cNvQCp7I3Ia8CbpA+YL5xcjr3Sw5+ZhPWXFrBhELxzAW+MMUxnv
	 gtlmcl96uqd4xXd9u3EuAQwqYWqzLUD+S7MmJNcL0zfE/KCYwWnUy8PEEj0TLY0E67gz1
	 nIpu4Z9I1CTQ3N7jj/Fa+hIdOncPSnqDPasSwCXpo+4V/2SB7a/7ogYcLlFCrn8TUocVd
	 fwHvk3QltnCC8Jxn727vVawkIRqKQF+IrOtZsOegRS4HmkpO/Fbv7t8N5JPGa/VgsSg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DQB1Uywo;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E35EC606A334
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DQB1Uywo
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE6DA1F00904;
	Tue, 10 Nov 2026 17:44:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332670;
	bh=3klt652QmEXe+/usMyh47NNNqp88+GTBOzYwSbpuIOk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DQB1UywoltnKAXABIg8xjjTrMLW0lGyxM9Yn5eE2g6Ok1roHK45nuKcxc5OXN6ORi
	 r3DW4xS8roPuEi6POXC3kKOSPQt2Qx0Arrm9bumt4g8XtPo/t3O4NkGCtZxTM6wVIW
	 V+iOi+spzU5MBvpAp8SXLgPD9dJ9haAF2Ls5cOhTXL5tMIKaTOcHUk4gLzHDveNF4A
	 j3jEIYDnodqbzyHf4tuEpRF7R5XBEADLUVV4ki3o3/UCvhlEy3H3/b+OyO4qlu9Qg3
	 2XIwMtu16hMyeFkfPPaESMNa1xajaHa9GOY9lkp7oHTLr7u4rdInbL9PPBw5xf5klJ
	 6LNtR5Q+dtn3Q==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:16 -0500
Subject: [PATCH v2 09/10] NFSD: Fill the session ID's sequence and reserved
 words at random
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
Message-Id: <20261110-random-stateids-v2-9-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=7912; i=cel@kernel.org;
 h=from:subject:message-id; bh=Q2bmvu3gQPQaZpemDmM8Iy5/kglR2Nz+fo6Cup+1f4Q=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f0A56VQ4ODuT4bBh3HkMFEYUHFOjIL/zGb3
 ypxAyxqAWqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 l9JkEACxSXudss/c9Cd9vFDRDsjqsOXdZ+sJ/Nwwhr7gAyOFXaNGD9Ju3jcZtTcbkU6nus3tLiF
 +tbWsZIWXY92sZARGBbWxeDhPrvg19tFypgqwGcDZeuFbE4Kp0oqupep00C88/MQEcZqre+OUq8
 Wt0q4m45gUCCn6WmsHq4DN1TJ0yHVVJvJO2Uf1sWvSqh8JH3PRAdqY4vs7s17pjlCHmOGKaZevA
 OzS8GHGXjGzfsjNN5csP2BzD3T32OKU2/5EE8ggX1NaMAN4ey9oWHaM2ITmAD5bD6QzoAcnwIO5
 9BCSwwO47bRYAXd3C8hHElFycUUPRbQ/9IPwq9zHYIGtDpzcf6lL58Un2TQFPXyVWrzWhKz0+Gi
 Zrc9PDKmv2VcIBzFj5x3S0rfmZqcatBw0xjL9kr4+qdwe8mOxh+BPGHzTPQJc/t26v1AV9Pc0HF
 eVzzfALwvaBeVFheSvbQHdNcm/t8c0jicD3H4h9QQqAHAXRPVEqFc3mV+ZgNZ2kcV6hL8MBJlXI
 9kNGXms28Vtm80AylaKNCLA/sgi+6d+WVWhBa1ry1fobz7Gm1PjgxKaDYOMbxpDwiEKd8Ettph0
 3RIIYZeketEb21wT0G3orRrBp6L578RPNs/QSBwyfvd2U5PqVWEZ5bY5KgH2w3Gf2gY49Clsv7v
 WM+OXrKeOChiEhg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

gen_sessionid() fills a session ID's sequence word from a file-scope
counter that counts every CREATE_SESSION across all netns, and zeroes
the reserved word. Under SP4_NONE, which the Linux client requests by
default, the session ID is a bearer token: nfsd4_sequence() checks no
credential and nfsd4_destroy_session() succeeds for any requester
holding the ID. A requester that knows a client's clientid reads the
counter from its own CREATE_SESSION reply and reaches the victim's
session within a few hundred SEQUENCE probes, after which it can
poison the victim's reply cache, drive OPEN and LOCK against the
victim's owners, or destroy the session. RFC 8881 Section 2.10.8.3
offers only SP4_MACH_CRED and SP4_SSV against this attack.

Fill the two words with one 64-bit random value. RFC 8881
places no uniqueness, reuse, or ordering rule on session IDs, so the
only uniqueness NFSD needs is that no two live sessions share one:
nfsd4_assign_sessionid_locked() rejects a value that matches a hashed
session and returns NFS4ERR_DELAY after NFSD4_RANDOM_RETRIES misses.

Generating the ID cannot stay in init_session(), which runs after
nfsd4_create_session() has expired the replaced client and confirmed
the new one. nfsd4_create_session() generates the ID at the end of
Phase 2, after check_slot_seqid() has ruled out a replay, and on
exhaustion takes the out_expired_error path so NFS4ERR_DELAY stays
out of the reply cache.

nfsd4_sequence() returns NFS4ERR_BADSESSION for a wrong clientid and
a wrong sequence alike, so a requester that knows the clientid still
faces a 2^64 search.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 59 +++++++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/state.h     | 15 +++++++++++++-
 2 files changed, 60 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3170c6a48c7f..77a73246c0f4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -92,8 +92,6 @@ static const stateid_t close_stateid = {
 	.si_generation = 0xffffffffU,
 };
 
-static u64 current_sessionid = 1;
-
 bool nfsd_delegts_enabled __read_mostly = true;
 
 #define ZERO_STATEID(stateid) (!memcmp((stateid), &zero_stateid, sizeof(stateid_t)))
@@ -2300,15 +2298,14 @@ void nfsd4_bump_seqid(struct nfsd4_compound_state *cstate, __be32 nfserr)
 }
 
 static void
-gen_sessionid(struct nfsd4_session *ses)
+gen_sessionid(struct nfsd4_session *ses, u64 rand)
 {
 	struct nfs4_client *clp = ses->se_client;
 	struct nfsd4_sessionid *sid;
 
 	sid = (struct nfsd4_sessionid *)ses->se_sessionid.data;
 	sid->clientid = clp->cl_clientid;
-	sid->sequence = current_sessionid++;
-	sid->reserved = 0;
+	nfsd4_sessionid_set_rand(sid, rand);
 }
 
 /*
@@ -2633,13 +2630,15 @@ nfsd_slot_shrinker_scan(struct shrinker *s, struct shrink_control *sc)
 	return freed;
 }
 
-static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4_client *clp, struct nfsd4_create_session *cses)
+static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new,
+			 struct nfs4_client *clp,
+			 struct nfsd4_create_session *cses, u64 sessionid_rand)
 {
 	int idx;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	new->se_client = clp;
-	gen_sessionid(new);
+	gen_sessionid(new, sessionid_rand);
 
 	INIT_LIST_HEAD(&new->se_conns);
 
@@ -2700,6 +2699,29 @@ __find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
 	return NULL;
 }
 
+/* A candidate need only differ from the ID of every live session. */
+static __be32 nfsd4_assign_sessionid_locked(struct net *net,
+					    const clientid_t *clid, u64 *rand)
+{
+	struct nfs4_sessionid candidate __aligned(4);
+	struct nfsd4_sessionid *sid = (struct nfsd4_sessionid *)candidate.data;
+	int i;
+
+	sid->clientid = *clid;
+	for (i = 0; i < NFSD4_RANDOM_RETRIES; i++) {
+		u64 value = get_random_u64();
+
+		nfsd4_sessionid_set_rand(sid, value);
+		if (!__find_in_sessionid_hashtbl(&candidate, net)) {
+			*rand = value;
+			return nfs_ok;
+		}
+	}
+	pr_warn_ratelimited("NFSD: no unused session ID after %d tries\n",
+			    NFSD4_RANDOM_RETRIES);
+	return nfserr_jukebox;
+}
+
 static struct nfsd4_session *
 find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net,
 		__be32 *ret)
@@ -4752,6 +4774,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	struct nfs4_client *old = NULL;
 	struct nfsd4_session *new;
 	struct nfsd4_conn *conn;
+	u64 sessionid_rand;
 	__be32 status = 0;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
@@ -4808,6 +4831,16 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		goto out_cache_error;
 	}
 
+	/*
+	 * Assign the session ID before Phase 3 so a failure expires and
+	 * confirms nothing.
+	 */
+	status = nfsd4_assign_sessionid_locked(SVC_NET(rqstp),
+					       &cr_ses->clientid,
+					       &sessionid_rand);
+	if (status)
+		goto out_expired_error;
+
 	/* RFC 8881 Section 18.36.4 Phase 3: Client ID confirmation. */
 	if (conf) {
 		status = nfserr_wrong_cred;
@@ -4843,7 +4876,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	/* Report the correct number of backchannel slots */
 	cr_ses->back_channel.maxreqs = new->se_cb_highest_slot + 1;
 
-	init_session(rqstp, new, conf, cr_ses);
+	init_session(rqstp, new, conf, cr_ses, sessionid_rand);
 	nfsd4_get_session_locked(new);
 
 	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
@@ -6370,15 +6403,15 @@ bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode)
 }
 
 /*
- * gen_sessionid() composes a sessionid from the client's clientid and a
- * sequence counter, so the sequence alone identifies the granting session.
+ * gen_sessionid() composes a sessionid from the client's clientid and
+ * a 64-bit random value, so the random half alone identifies the
+ * granting session.
  */
 static void nfsd4_recall_grant_sessionid(const struct nfs4_delegation *dp,
 					 struct nfsd4_sessionid *sid)
 {
 	sid->clientid = dp->dl_stid.sc_client->cl_clientid;
-	sid->sequence = dp->dl_recall_grant.sessionid_seq;
-	sid->reserved = 0;
+	nfsd4_sessionid_set_rand(sid, dp->dl_recall_grant.sessionid_rand);
 }
 
 static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
@@ -7145,7 +7178,7 @@ nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
 	if (!cstate->session)
 		return;
 	sid = (struct nfsd4_sessionid *)cstate->session->se_sessionid.data;
-	dp->dl_recall_grant.sessionid_seq = sid->sequence;
+	dp->dl_recall_grant.sessionid_rand = nfsd4_sessionid_rand(sid);
 	dp->dl_recall_grant.slotid = cstate->slot->sl_index;
 	dp->dl_recall_grant.seqid = cstate->slot->sl_seqid;
 	dp->dl_recall_grant.valid = true;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4ed417bf2262..d9aecef95bae 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -316,7 +316,7 @@ struct nfs4_delegation {
 
 	/* Forward-channel slot that carried the granting request */
 	struct {
-		u32			sessionid_seq;
+		u64			sessionid_rand;
 		u32			slotid;
 		u32			seqid;
 		bool			valid;
@@ -500,6 +500,19 @@ struct nfsd4_sessionid {
 	u32		reserved;
 };
 
+/* The sequence and reserved words together hold one 64-bit random value */
+static inline void nfsd4_sessionid_set_rand(struct nfsd4_sessionid *sid,
+					    u64 rand)
+{
+	sid->sequence = lower_32_bits(rand);
+	sid->reserved = upper_32_bits(rand);
+}
+
+static inline u64 nfsd4_sessionid_rand(const struct nfsd4_sessionid *sid)
+{
+	return ((u64)sid->reserved << 32) | sid->sequence;
+}
+
 /*
  *       State                Meaning                  Where set
  * --------------------------------------------------------------------------

-- 
2.56.0


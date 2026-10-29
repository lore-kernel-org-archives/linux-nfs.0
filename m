Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281284;
	b=kL2txpPrz5bCWmAJBFzSlN5D2Ra9ERP+M1dj7RQnNoW7p4YVXB8K5nUdVIBKkieHXRXx
	 uuwHhlGCa33/mou3alp4s/tamCS8ObKHaCVKElWWG80UjdLIpX1eqpk6WO450mGAe85vG
	 zaLug2O0KgocnSSh+aXT8qAwcsk/SJTJSTMBbQLg8HjS2ybs7HYyHNpxZG3hFsCOSAmvU
	 INV+aMGreYkKWDd67E18rTeN8OEiaoThjh+1hRBpE/FDsnbhNCYPKx71kjK+X9OiroLYl
	 cbvPcpHPgRIPFHuIra0qY7y20BSXuivRQtTMpcyJuNnl5utXf2V1Zm3pfycaFN2Ks4w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281284;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=TU5CX+6BvbAKGdtJo9CZUQuqDYjuV+hDEt39g1ed288=;
	b=YttyD+nunwcKF3w9PP94IfQYuA7BrQiSrIkkpk/OaBuGEDY8KrDq7iQUh2IqOYT9oQhH
	 tPkJfaOfnWkmkZfZYnt/dPrwRe67UAvhClaMRqGFVlXA7GNuxNxPjp5Cnwj/5xSZ2T+2E
	 SfETFFw7ZU/X8yA7pNIfqAfQd3bI7dCeO501Tz0cmyeYBeYLAFDXjuQFRku6B9DdgK6c6
	 GcO02oho5HjmwojVqQW+dY0M/GJ1YPJdGYOoVs6nnlXQcP+axOQwD9o0/WOEsMYya8unc
	 WoHMcoUfDvrt2+DOOqGAwUmrK89uS6aDqc/4W8TtOoC2ugnmWLTlgJdTsMQozMStYWQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LwO8iGaA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A38CF606A325
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LwO8iGaA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF33C1F031E5;
	Thu, 29 Oct 2026 13:41:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281283;
	bh=TU5CX+6BvbAKGdtJo9CZUQuqDYjuV+hDEt39g1ed288=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LwO8iGaAmqOGeOy2WIuxTP24cyGi8HwlcgUC82kFAKrMnlZ110eeNlXbxwMEg9C9d
	 Jc6zpc51MwbA6DFyTHEn8VcjvDveGSnM6yplFsocaXUMqmTZzB+PSv4yswsGLkUJX4
	 P3bMHo+6iP0bXyDJqfkUpG9Xikmj4gOsHpB2xwf8cvQmjHKO/oSbsjxvHH7qMcTZlN
	 bjehzPogDqvuYuI7OacmrvzZS67TSKVo8JJI4hSNdhdU1oJxf1Tsl/LDXOCCDHZslw
	 klXC5At6cY5x+PbBFSRWiCpqdDPyBUXh/z5UnLnxt9xMBfzrSgERJAWo5GN3XBSzY1
	 Kr7TS1Y6j39XA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 09:41:07 -0400
Subject: [PATCH 09/10] NFSD: Fill the session ID's sequence and reserved
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
Message-Id: <20261029-random-stateids-v1-9-8648878fec8c@kernel.org>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
In-Reply-To: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=7865; i=cel@kernel.org;
 h=from:subject:message-id; bh=G8vQOpoCX7TySiYmKyWFEQ5MYcDxT/QZTkM5bePzfWg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq40z3vwliCVmeWURJIekDUk2tntQuSMKlGB9St
 hkGoAcnFfGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM9wAKCRAzarMzb2Z/
 l8V3EACRKiBNHXRX7srE/8NeEyStfiM5dLyXL7ERd8OmMK9mPLsEmpy6A43+NslgttTy7uYbbRP
 T2cd17pQtLOUpMNMp+9Jcpphp7bZMALgHX++ugUPUc0ZzARKALqZRJkj2lLAgUCjUTZkfUyIs4A
 /gEGItSaa9xgxN4GzfndCtizS+jxSCFuzt98KGS0EuPjOmiu4wTqTQa7xo3ai0p4XBl+Kmzj+a1
 70xko5UgjIQBC6s+wLnNWy6kJvM9wONes4uUvGvd6NSPfJsaZOIv6ZV0kWosdKh8OtyAC6f3/h8
 I4GsAoeg0QlfAlkBJTxJpnnX+FMAPwJ4yCpoGuzwSVAmnokrtRRwO4sGnC1vUIjPnX9gAillXye
 5dRHRNwoY2pNEo1FSVbjfrOREs9RZq4JvADlYr77QIAm9SM69kRf4ZXCSYDWzfNDdZlahdmMvtc
 vNpy8Z10mm57l/RvkZuKFaFVKPqzfakjhpcWFCXvBuJ2ifDl4aA15T/JAzd9A3hR6eJYrc9MB2T
 xhWP2ntXBGnKFtGFqiQN8kB00TR32ZvDkduJB2eXLHROrSvw0zFf6ntiDYMacxNSKbTyqUCUWKM
 Nw7nokh5fdDqvr/Kfyy3QrjzXvngpetd+ACAJURpxb4481EaSmwLcm0XzyUUlSCxNlNDO7i4/0/
 UAB5r3gjlnhqVKw==
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

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 59 +++++++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/state.h     | 15 +++++++++++++-
 2 files changed, 60 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a2189a5a3dc2..de8950c7ad90 100644
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
@@ -6360,15 +6393,15 @@ bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode)
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
@@ -7135,7 +7168,7 @@ nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
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


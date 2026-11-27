Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795801295;
	b=ILow70BahB1h0jFp0PIp6ImEqE855mKlnkxizZgXJfWKledmkbWCRKXXziUF2hMdHJsF
	 yOgcEyeUztegVugduHREsS0MrSczFohOWRJWJXre3YwHzGjwnwnh++RFspeyQNYy20PUA
	 yFImU6vem/zeDERbCnKPZWZYu8gdv0tpUXp648sJzznFskn70qr7CMh9G56RR/dp826Yz
	 50nxIFu02XdtQsyC34yKQhFT4I4TA1HtJvIYzIwZu2940763NgRPhgrl6dzuhZNIpo5ZM
	 WM9/bTIFO6cjmkjxP32gexQmnczidhegOvOq2ZDcPDs7ZygMXZGME23fahguKJ/uqyA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795801295;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=5E5cz96U9feotO4EW5n25iSPmPmLvfkRPaO1D++GyjM=;
	b=feqKaZwZe38FDmL9Q1i6kek5JZkfD9R1X0qgVUXb7xIjlhEtWNLlWggaW6gj6GRXGaG6
	 GGvcHUsF6InUae7sIl0P9biRv6es6WTRnVhxyKTNWnDojnj/aFSR4tEy4WDGOJ+vB4KNz
	 a96IVEK5oF21xnqms27+tj8pC7MFXQIDrQDs4qtzewNdU2zeXymwmmjFTMFjw1lgZZmQ5
	 WIAz2/dk97qLtzWG1pPI8fkmXaaxRoLpd6XUBOAb4YThHhkJDsR6EAWH5mfXcdvNkHkBo
	 f6zZpIiVhuVMG0QSsHZaC7NmK50/k0vRPDlxL6E25PMEh+6e+XcoX4aHPKNtIK5mNIg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oGAVKaSl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C3E1606A321
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 17:41:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oGAVKaSl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9A9E51F00898;
	Fri, 27 Nov 2026 17:41:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795801294;
	bh=5E5cz96U9feotO4EW5n25iSPmPmLvfkRPaO1D++GyjM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oGAVKaSlNjgG+M4tkd8Mut5UhZ8vSwikAFC43HT4BEcfv77LPbYzpAAwvyn6As4tn
	 wbhD7mG+0jKBQXWB46wU0BXfUPMdlmbj6VoRzihTwTvpDoupCis2AbmqenJybEW2Is
	 5pmPnOUxu+mkcrl5+94+jrY1zfhKslTOZyWpYRCFsn2s4aLWsZgd2cDhwR4FSttGHU
	 0NBbvFGMzB2OQZd2oqO1t1mXgqSJx3Hsc2tFBYjW701AhG+0Ga8hiE4IZjmMFPNVEF
	 UB3HrDY8blMfs5IRcYhut1czUdfC2NQt46VZAzBuCKYnlAEomgN60U1pRScON/WtCK
	 frCAM7qcjHCsQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 27 Nov 2026 12:41:25 -0500
Subject: [PATCH RFC 3/5] NFSD: Simplify the recall-grant slot check
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
Message-Id: <20261127-nfsd-slot-retire-v1-3-d9f6636cc713@kernel.org>
References: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
In-Reply-To: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: Chuck Lever <cel@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=4034; i=cel@kernel.org;
 h=from:subject:message-id; bh=ybr9jNgu+xOdtqEgToYNShw7V3/ofOLN5MdQdy4Cnh0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrCcDKYMkSZaQXULq1fyQtx7vWptx1f+Hvh81oX
 qN9Yf4ufsaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawnAygAKCRAzarMzb2Z/
 lxy7D/948GcGyiS3wIQACY2coZNJQWdDA3R4h/8emECo+65wEKxFPTLVCrtOnPR2uTPiZBPdd6B
 4WNbHcZ+L9ho1Y7y6DrGSA04ZKXAqeey+REiEB3+hCSTjkO/qQktRHNJfIV9kmSRHNd4sh5/UwW
 TEwL41q83KBJQPP2FDOfEIKgFEpGLu47pRciBKxYWIl+uw/BAe++KdpFrrVktoU8kXWvPVlpNde
 P+kjJKOD6XKSwWDwtdx6ghTNa02LFsOZuRquDBz3Q7zKdhsYGCaTmIvF7yoOM46f4inpSamB1Lp
 HedrAlF7oSmYDmX24VXM11RSZxUoa8RzPEzPi1LtrFmQYV1sBiTtdbtyEsNQqqRfKOaLZjzhgvp
 qdIbe061K4JD2wHMUbQ8licwwtO5qRC5cPUVUpP7dtKuI62qubwiOzPpCEyxZtejjRuNqOIhDg9
 TdXpw93nn5TRSc2ByzAAXykYG3yz4YykXAzlft2ngPxRF3su/NKX+zHMGlYdzHgU+h4zlsFTfCm
 wDQCiLwQmbsJwoOi2dDcWWR1yOP206HAZrsG0oaZZrtVoA7dXyk8RiiYBUMmrD3IJkiFCNok+ff
 bYxMKzDnBYf4g3yn5fBR/afrpioZJyCfgrLrqBNy6lniDZbHs8DX8jfuxfpxHQddbLQRg47p9dH
 QwSWFuX/1mYUe4g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_recall_grant_slot_retired() treats a freed slot, or a slot
rebuilt after it was freed, as proof that the client has seen the
reply that granted a delegation. With the session slot shrinker gone,
NFSD frees a session's slots only when it frees the session. Neither
case arises, because se_slots never holds a saved sequence ID and no
slot carries NFSD4_SLOT_REUSED.

Remove both tests. The NFSD4_SLOT_INITIALIZED test goes as well. The
granting compound sets that flag before its slot can accept another
sequence ID, so only a rebuilt slot could fail the test.

The test that remains is the retirement rule of RFC 8881 Section
2.10.6.1: the granting request is retired once its slot moves to a
new sequence ID. The slot itself stays in service, so rename the
function to nfsd4_recall_grant_retired().

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 40 +++++++++++++---------------------------
 1 file changed, 13 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 80c2fb487ffe..12d06ffc7a4e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6414,14 +6414,18 @@ static void nfsd4_recall_grant_sessionid(const struct nfs4_delegation *dp,
 	nfsd4_sessionid_set_rand(sid, dp->dl_recall_grant.sessionid_rand);
 }
 
-static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
+/*
+ * RFC 8881 Section 2.10.6.1: the granting request is retired once
+ * its slot accepts a new sequence ID.
+ */
+static bool nfsd4_recall_grant_retired(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfsd4_session *ses;
 	struct nfsd4_sessionid sid;
+	struct nfsd4_slot *slot;
 	bool retired = false;
-	void *entry;
 
 	if (!dp->dl_recall_grant.valid)
 		return false;
@@ -6436,27 +6440,9 @@ static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
 	spin_lock(&nn->client_lock);
 	ses = __find_in_sessionid_hashtbl((struct nfs4_sessionid *)&sid,
 					  clp->net);
-	entry = ses ? xa_load(&ses->se_slots, dp->dl_recall_grant.slotid) : NULL;
-	if (xa_is_value(entry)) {
-		/*
-		 * A slot is freed only once the client has acknowledged
-		 * the smaller slot table, which it cannot do while a
-		 * request on that slot is outstanding.
-		 */
-		retired = true;
-	} else if (entry) {
-		struct nfsd4_slot *slot = entry;
-
-		/*
-		 * A reactivated slot was freed and rebuilt, so the same
-		 * acknowledgment applies. The seqid test errs toward
-		 * revoking: a rebuilt slot restarting at seqid 1 matches
-		 * an old grant.
-		 */
-		retired = (slot->sl_flags & NFSD4_SLOT_REUSED) ||
-			  ((slot->sl_flags & NFSD4_SLOT_INITIALIZED) &&
-			   slot->sl_seqid != dp->dl_recall_grant.seqid);
-	}
+	slot = ses ? xa_load(&ses->se_slots, dp->dl_recall_grant.slotid) : NULL;
+	if (slot)
+		retired = slot->sl_seqid != dp->dl_recall_grant.seqid;
 	spin_unlock(&nn->client_lock);
 	return retired;
 }
@@ -6471,7 +6457,7 @@ static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
 static void nfsd4_refresh_recall_grant(struct nfs4_delegation *dp)
 {
 	dp->dl_recall_grant.retired_at_send =
-			nfsd4_recall_grant_slot_retired(dp);
+			nfsd4_recall_grant_retired(dp);
 	if (dp->dl_recall_grant.retired_at_send)
 		nfsd41_cb_destroy_referring_call_list(&dp->dl_recall);
 }
@@ -6556,9 +6542,9 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
 	case -EBADHANDLE:
 	case -NFS4ERR_BAD_STATEID:
 		/*
-		 * Retirement of the granting slot proves the client saw
-		 * the grant. Trust the rejection only if the slot had
-		 * retired when this recall was sent.
+		 * Retirement of the granting request proves the client
+		 * saw the grant. Trust the rejection only if the request
+		 * had retired when this recall was sent.
 		 */
 		if (dp->dl_recall_grant.retired_at_send) {
 			nfsd4_deleg_recall_rejected(dp);

-- 
2.56.0


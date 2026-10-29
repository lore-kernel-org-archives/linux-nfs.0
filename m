Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281283;
	b=ICOcLeO3n7tEceD8H6grWAP/RsjSuAIdwm2pZXNTleMKwnAZJq25CRnHPyBvfv57J+IU
	 M8hUf+2ryTZNdRSG/nzElWPpcK4RftubJRHhZ3hjim+iCIEnf9vgvIaolY++RecpGROhU
	 323t+PrJG6Pswg3KaXtJaqel25kTpFrdA39LGz3+8w02ckLC+kFlwXINtbdB9UTQuE+le
	 vRfQkk5lBSx9CmiM5p2g8ZF2pi59SrijIDK1qUILslP8n6JmG2MbhdFCSGwNxm/p8sxlw
	 TeZFGZiMGXUXnDIEKm+m4As/ljUnnr6308pIYEm2jB8e7mgLVziUi0CfuWUDBfYs2tA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281283;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ft8m/yed1mb7bWrRxpRJTs7eGR8hHZqBo2Aak2nQTv0=;
	b=oDbjDW7yVIKU4tCR82KKlhpKLjLEq/tfRCSzXNk1Y4Csj8w/FltxWBuhtHwVPKkequU+
	 +a258wPs+3cy96b68ggzsdeh4W8hwSqDRq4qouyD52F30BNkd3LHAvGxsZTOwNbDkSoio
	 x9Wm5Z8A88NjxYLzYFgrPikQo5Asfj1Ni0PVLrnaC3OqVZARIS97ZXnXTk0fvs4JNOT4v
	 OJdiL3iCkIEhrIzb3Pv5kvfWYAnyPCg8FcXv4/6QBuRvVjc8wKgDViaZ+eubsb6CIrA4H
	 kkAt81/gkE3N2dYVl8K1c6BG9OdYXE2AfSXIqvmuBYs5RLVqVirlswFwxn96hwiorsA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ApxV01xr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A738D606A325
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ApxV01xr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C05FF1F01829;
	Thu, 29 Oct 2026 13:41:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281282;
	bh=ft8m/yed1mb7bWrRxpRJTs7eGR8hHZqBo2Aak2nQTv0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ApxV01xrqBhGmSCqs85JC9P8SlDqODLeuKs+qZ6PHwT6oqklYkbXdVXWyC5jcDyk9
	 RberkUUxnTW9SAs7ZZLoDwvBnYGDpbYch21OZ5PFYEhT9J+sVqjr32fy+r/zvUleyo
	 KOMjJX9tczohzVZ+vHRonS48S3V1d3SGcHx8H+isIoNR5qMhXzwY6aLP31bhseZyfE
	 C5I6SFjIkNyjq54owtTjKFIeBOkBdGaP+agF/91tgzXGRF0ogOrbByMwwjNG1W2pHs
	 57pXhby7w92UViyAFL7jER7G9HI6nJ04xYXocJ2JIlmr6iAdKP/Dv0U6rsPz/t+PR2
	 c7xaUqJumVLuw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 09:41:06 -0400
Subject: [PATCH 08/10] NFSD: Put a random word in each COPY_NOTIFY stateid
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
Message-Id: <20261029-random-stateids-v1-8-8648878fec8c@kernel.org>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
In-Reply-To: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=5125; i=cel@kernel.org;
 h=from:subject:message-id; bh=fn/sZyna3fWgqGo0xX7b0a50rKmEeAANobU83tA96WY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq40z33DWBgYIjhOwlAuc2tGf+XlHfXom4q0gvp
 r1CqPeJJHOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM9wAKCRAzarMzb2Z/
 l/cnEACm8WX2rN7mURo944mN9VZHs9Vs19+0uz9aJ1RWZSJbEAPZlLSfwQ7PQrOIk+4lSI7e8vG
 Y14khQZvtVi7Qmbkuez+66sXQckrNGI1Mu/bGoHj3ok3yOF5bVwq5qUmTws0+WLyddKydNZ7Rd1
 fOiGgAnWJkGwR68CjyKPGVVfNWe/M21a6lECWAn0eCIghrMKCSQca1E7He0lfjrmiWterotEbRw
 vx0TRg8DvM4g2wcmOSoB1YRjx78RqTHoaNXktarPglAuXM91Rp7F/EsO1BMyaSOTdT07SBC69Fm
 GGmooDoRIHbEolXQA97LhtWYxRkH5RKjlx24pVqGR39W/A4cgtWl+Qy/fujLH+p38JusxJ/WfzM
 lltLh4C6Q4OGLvpw1seTqCx4/MG83kPg3jK3ULjJ92Ghzjc4KJtKelb4Sz9tkuotrJyu0TGFJbx
 Gg+/8cobhaUkiLkdbFXyiqLEaOiauiFmL9LvdIYSs39ADQQf4Utz/KfD3hShZETaAYWGoB1PAJW
 SxW6uxpyuOrW1qczw3xd3ae6pNdkhirAaYBHfNHkzqtaYI285Ed6LubrAo19x/BmjdWqc6X8OHC
 gcqUl0ee/wSBqdCzr2Y5MBLaq2nwqkcU0IA2zrVpS+151rojB98tihuzym+omCKiPmuDLnkCkYM
 OefHWTVTrfSsXJg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfs4_init_cp_state() allocates the nn->s2s_cp_stateids key with
idr_alloc_cyclic() from 0, so a COPY_NOTIFY stateid's so_id counts up
across the netns and is guessable. Its cl_id word is a fixed sentinel
and manage_cpntf_state() does not check the generation, so within one
NFSD instance the so_id is the whole of the token.

Fill the cl_id word from get_random_u32() at creation and have
manage_cpntf_state() compare the presented word with the stored one
after the so_id lookup. The key stays cyclic: a random key would carry
the same secret, but spread over a 2^31 key space each entry would
occupy about 1.1 KB of radix nodes shared with no neighbor, against
under 10 bytes for consecutive keys, with no cap on COPY_NOTIFY states
per client.

The token's clientid must still never name a live client. nfsd4_read()
and nfsd4_seek() try the IDR only after the per-client lookup fails
with NFS4ERR_BAD_STATEID. A token word equal to the session client's
cl_id, with the so_id landing on one of its stateids, would be handled
as that stateid or rejected with NFS4ERR_OLD_STATEID. Keep the two
spaces disjoint with one bit: nfs4_init_cp_state() sets bit 31 of the
token word and nfsd4_assign_clid_locked() clears it in every clientid.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/netns.h     |  6 +-----
 fs/nfsd/nfs4state.c | 31 ++++++++++++++++---------------
 2 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 2677d746e77a..217dfdb3d738 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -179,11 +179,7 @@ struct nfsd_net {
 	struct completion nfsd_net_confirm_done;
 	struct completion nfsd_net_free_done;
 
-	/*
-	 * clientid and stateid data for construction of net unique COPY
-	 * stateids.
-	 */
-	u32		s2s_cp_cl_id;
+	/* stateid data for construction of net unique COPY stateids */
 	struct idr	s2s_cp_stateids;
 	spinlock_t	s2s_cp_lock;
 	atomic_t	pending_async_copies;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 78f69a188d34..a2189a5a3dc2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -70,6 +70,13 @@
  */
 #define NFSD4_RANDOM_RETRIES	16
 
+/*
+ * Set in every COPY_NOTIFY token's cl_id word and cleared in every
+ * clientid, so the per-client stateid lookup never resolves a token
+ * before the IDR lookup runs.
+ */
+#define NFSD4_CPNTF_CLID_BIT	BIT(31)
+
 #define all_ones {{ ~0, ~0}, ~0}
 static const stateid_t one_stateid = {
 	.si_generation = ~0,
@@ -1000,7 +1007,9 @@ static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
 	int new_id;
 
 	stid->cs_stid.si_opaque.so_clid.cl_boot = (u32)nn->boot_time;
-	stid->cs_stid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
+	/* so_id is cyclic, so this word carries the token's secret. */
+	stid->cs_stid.si_opaque.so_clid.cl_id = get_random_u32() |
+						NFSD4_CPNTF_CLID_BIT;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&nn->s2s_cp_lock);
@@ -3226,9 +3235,7 @@ static __be32 nfsd4_assign_clid_locked(struct nfs4_client *clp,
 		return nfs_ok;
 
 	for (i = 0; i < NFSD4_RANDOM_RETRIES; i++) {
-		id = get_random_u32();
-		if (id == nn->s2s_cp_cl_id)
-			continue;
+		id = get_random_u32() & ~NFSD4_CPNTF_CLID_BIT;
 		if (!cl_id_in_use_locked(nn, id)) {
 			clp->cl_clientid.cl_id = id;
 			return nfs_ok;
@@ -5822,8 +5829,6 @@ nfsd4_init_leases_net(struct nfsd_net *nn)
 	nn->nfsd4_lease = 90;	/* default lease time */
 	nn->nfsd4_grace = 90;
 	nn->clverifier_counter = get_random_u32();
-	/* The COPY_NOTIFY sentinel clientid used by nfs4_init_cp_state() */
-	nn->s2s_cp_cl_id = 0;
 	/* So the first client directory in a fresh netns is named 2. */
 	atomic_set(&nn->client_display_counter, 1);
 
@@ -8630,18 +8635,15 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 	copy_stateid_t *cps_t;
 	struct nfs4_cpntf_state *state = NULL;
 
-	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
-		return nfserr_bad_stateid;
-	/*
-	 * With a fixed sentinel clientid, the all-zero stateid and a token
-	 * from a previous nfsd instance both match cl_id, so cl_boot has
-	 * to carry the check.
-	 */
+	/* A token from a previous NFSD instance can name a live key. */
 	if (st->si_opaque.so_clid.cl_boot != (u32)nn->boot_time)
 		return nfserr_bad_stateid;
 	spin_lock(&nn->s2s_cp_lock);
 	/* s2s_cp_stateids holds only COPY_NOTIFY stateids */
 	cps_t = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
+	if (cps_t && cps_t->cs_stid.si_opaque.so_clid.cl_id !=
+		     st->si_opaque.so_clid.cl_id)
+		cps_t = NULL;
 	if (cps_t) {
 		state = container_of(cps_t, struct nfs4_cpntf_state,
 				     cp_stateid);
@@ -8651,8 +8653,7 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 				  sizeof(clientid_t))) {
 			/*
 			 * OFFLOAD_CANCEL: only the creating client may cancel.
-			 * so_id is guessable, so without this check any client
-			 * could free another's cpntf state.
+			 * The destination server holds the token too.
 			 */
 			state = NULL;
 			goto unlock;

-- 
2.56.0


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332670;
	b=jEy0K7Qv1riKXbXJtkR4UDlhUcLVtlvAj/QpYldevdlpX3PSR/VjdhNp/oJ7A7A73d1a
	 hj1CydCHnyPUKi0DisEmdBXTrMCieEY1xA1764JaWHeTtDw8FEvZ/Bbd6mZBHNCd0Wi6h
	 rBwW4CgxS8B0JwpSwXz48P0fWJNIs2i+vkv+9zuDXsWBIUBQRns+r1BJxctkDS4b21quE
	 73PHDQyk5UdD6+JjeKkXM9gwdkxUpLctmlAyijLeDQY6vd31lztJHWRyGTuV0Oa8BscZO
	 mqeZ8gVbGKcx9sQ4xMbE9+CJzwwkldu6Rv03D4Li5f8emnDVz1Avt0YiGJRdig6wYrg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332670;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=JKz1+PIgyDKjxGZw1vFQjL0t5u1/oYXF+AH8KG5uuM4=;
	b=HEWdE+Gg5gL2Ser787GTzdWwt5PwOlvM6buRuaVJYYb4kXRrXQMI9kVrfmZJS/UlkqZ/
	 VQMLyh3hQ7l6WFGTZp3xsOo5auJHN6jQfjZvTF16tkLljJIQA4hRqPGyTZWNDPoNavV6t
	 Ux6wNPOKVun90yBg6RrazPY3bliXrPA5lOLTperiWYx+aaForQWzWfKReFnhgF4dfeejb
	 SISX3c1Oy592PqUNFU9AYMzJpTkVv8dAaonfjYByl6WjWIdLhpsw7AIoNUlJdh1jwQc9G
	 B+ECuLFO8hZ5IptQxM/IvxXbGozAVIq/cbtdYIdLrOujcoHHQQjED65Ju5oZJ5/jt4Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dp+rNh7N;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C88EA60A260E
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dp+rNh7N
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2081B1F00902;
	Tue, 10 Nov 2026 17:44:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332669;
	bh=JKz1+PIgyDKjxGZw1vFQjL0t5u1/oYXF+AH8KG5uuM4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dp+rNh7NNotz0azz4/H0IVKM0wNmOOPmnKXEWtCXhvploc8KnWIXf9ZmCHIcF5rX/
	 Blh7YbDNSotYZrMVV8VjbajRGVR9Q6X27Zazfne6QKYqzsOyInOyY6GIrIib1iW0K5
	 et+EbC3KPTTIkUR0RTVn8KBZeHvH39NKPC0Ecg7cApxRU9Gp67bUlZrvpiupa7VQ/0
	 fN0HfnaGTqiT7mDVomHudTDzNXW6AOb1XmJ/s0kjZST4NnMxzkgjyRxjsUrj7aKf7x
	 Ci0p4KXgTeVRH6pcO99xTbdPtwTpijRgI9kSe98p5yYfQKHU0LdNXdigK90Yzv3sHH
	 2R3FHdczrxHRA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:15 -0500
Subject: [PATCH v2 08/10] NFSD: Put a random word in each COPY_NOTIFY
 stateid
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
Message-Id: <20261110-random-stateids-v2-8-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=5172; i=cel@kernel.org;
 h=from:subject:message-id; bh=5yMh1hoLIUTiI/pgg/hvWjZZYYvYj0tLual899vJp/8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f0+HpM/8nqLhBF00oD4R433kVH6RTmnTYIx
 h9cap7fGbWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 lzceD/9W0QwUWsmLD3jS3CJaj52m+p9gYK+GC7oQJiDn/ibyUQgOLHbEaLzlsZ8t/2iCuMT9LHo
 9ZL2oAhJiayCRexiU1NdRl039IdcnHT/nbf5CVdkKKbF/jdKb7TNLOVuja/Ub+lavfHFPVZqSIh
 2hE0CX6GhKXSJVZxN8OHb2BaEsVqUWXh3zU0rRSnrL9cnipxGJpY9bo5fYFRmIoRjS53/tMZkXQ
 5sNJ/oKZ0mw732oN9OonaiicdrfR/gDZMB0EJY2o3KMAqvEux3FmXtTKNfyUoCdV5tdj6NWX7D1
 R4D+3NsL9Ds8do3OHIrbsLBSQd37rvgkaygbOU32wJlfGI76Ur+OtYOQkVRSu5hqc+Gz2b0C4u3
 +qnPOThapiF7FnFr/ElUBZV8CWesbugqwEtQKcCnk4nTuPwU1oi7BvYwB0KmIKcNr0s+EbJLITA
 4JbmLmS0VK2OSg84u9EZvs7BF9zoFHETbbHqjFhpzp4JnipBkIAYGANzIQX2nNONrMpyXoHiv94
 qdbvuRf9PB8rLb/OPKiahZGk3yeZ7EnE8iwFmZub2HuO/YGiFtQPiFJqON2RmZgJxzHBeTYRVzc
 wZtQEfIH5npS/wFSK0XgkEZ/uxZoR3mOOHva8Kl1MBFVCUpjo6lv8CWRgVKPsgUv36P2GLuFzgT
 1fmzHLcNueBN9gw==
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

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/netns.h     |  6 +-----
 fs/nfsd/nfs4state.c | 31 ++++++++++++++++---------------
 2 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index dc4b319b194d..16be473f2c04 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -185,11 +185,7 @@ struct nfsd_net {
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
index 960a1eda2249..3170c6a48c7f 100644
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
@@ -5832,8 +5839,6 @@ nfsd4_init_leases_net(struct nfsd_net *nn)
 	nn->nfsd4_lease = 90;	/* default lease time */
 	nn->nfsd4_grace = 90;
 	nn->clverifier_counter = get_random_u32();
-	/* The COPY_NOTIFY sentinel clientid used by nfs4_init_cp_state() */
-	nn->s2s_cp_cl_id = 0;
 	/* So the first client directory in a fresh netns is named 2. */
 	atomic_set(&nn->client_display_counter, 1);
 
@@ -8640,18 +8645,15 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
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
@@ -8661,8 +8663,7 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
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


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332667;
	b=ejSg7Yr3XUqToUmGQL5RUCUZXskwmQVIDtSa09OSucx5PdIAfg78qI3gzV6PEEgXGVuX
	 b6urKdISYXL/trOSn8/lGZrmwhNG6c43oQEOAle3HysfZc5/zDGwPXE0mi7m1fR710PJd
	 48+xf60WokgTkkUw//UDXsz1Y6lsY2ZFfG70b80B4QBqA2qlIuiPT+WilUEPp9PsfebOu
	 oY905RVxgW3T2R0bT4ofbb0neAjL+yIcd8XouxGLbeUYnrDZihrxsB8W32e4/umefZ5Vh
	 wE3GgQTgA0vlifS/dwP1BfZiqGlxpHvOrqvSIQJRVdv3WcTGv15T5fsfAdqp1iEzCyg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332667;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9ocnBCEQn0LZwOmpJ/XRorRWnRPRqbWWq5NfjCXbCXw=;
	b=Vqg1xrBR459b7X5mkBQG7C4IE3wiwWKTN+B2Jn7HUxKTIz0UG7UWcISgCNY4ZEdYZwfw
	 3s7ad1S8SX1aPcpbRj57UEmQFwBLJRIO/DgBGK412RfELezhCCIsVnKtzaMfRjeQPWbM8
	 0/z2vpShXN35etQdfLiNfSPjLMUC3UFuxUyagC2aZIXBWsqK9QqlUPXf8oXSPNWqhghLt
	 pYCRF+OIYSkxSPT6shSivF+bFlEY8sLT8z45f8lOwqohRrFE4NTdDLDjAdpgI/wz97f5p
	 En3u6ST994x+Po/BcqszMs/ctsuaFyU8TiyaFhqxE5suw+GxWZ3dp7zgzH+pesXE39Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Dms4wRuo;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F74E60A260A
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Dms4wRuo
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 696F51F008A5;
	Tue, 10 Nov 2026 17:44:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332667;
	bh=9ocnBCEQn0LZwOmpJ/XRorRWnRPRqbWWq5NfjCXbCXw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Dms4wRuoosIburq2iIKAfRyt1gMxfmbZmQfY6TIkGboTowtQ62JJBoewgOTQb0IHl
	 OwPrCkG49VHMknmCj6MwpstpVfZJzozv9/VHXfB+CAkZu3pBaG1LuKCbaZyNzPygft
	 jfObPaUKzCR6gPVvp51cY5hM0+PF/dI+oYSFeDO9GmKIErJAXc35t77vUlCbMvADfX
	 zK0LYceJv67sX2qzIjdsR6cemzwkbbpmiSLY5fW5veDQUtSOyq80w/ygXUcSG2Poyn
	 4rHlO495RVd8VhShPICkYzpknBuFofGXKi+L/fzX4ASfJ4+Sf8rtKbM8qhf0DLohH5
	 HwiIP5KzHOwEg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:12 -0500
Subject: [PATCH v2 05/10] NFSD: Generate the clientid at random instead of
 from a counter
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
Message-Id: <20261110-random-stateids-v2-5-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=10078; i=cel@kernel.org;
 h=from:subject:message-id; bh=8vfj/dbAg/XjnRFhippAhf/WoR3uyCkFiTuT4rCcfhc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f0gQmwaE98DF5DuaQgx2iT9ONiyBykyOp5o
 j5YU/FiZmOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 l7D/EACVlEskIun/JrXvbm1QDiL5GFLYmB7jat5if65OWi8X5NwNgGHOFWauZ2C0+Bwq75q9KqD
 UzFXL6dlMN9uLOuBNkzp9Y5wUK7L2D+UTO3DfdLDqVkttm5AjcxlYDTakQ/4U5vJlruXmqjFdmr
 jLse9yBK+kLgLPrzNJc9FGCoKUhY4aOKHJubwGTcHkCeIlo/mZLR2Po9w7V0aIhJUx2XKMCoMxs
 qWr+dhEpaCeQ2A+LIfsi0uh1e8+qEdUM9eFkyyxP3tFi9RQz7baeBolc2fk82Epz2WTTVYjr55S
 5falMdD0ZNS7lvQ1+Uqix8eCNMIz3oKD7Fy7IIiO5N9w3bqYPcG5ThGihIumQosoIsNaGjffOu/
 ZbFKY7ZSo7xHHtAUeAOi0SBGl41P/BXLAD5u3HURdnWJH3Myi/2Ac9DP+nbjAyVBT7dJ5uC0UbI
 sLjBiBjhFaQGFYnTAmNViLreinaCt6Cd8mOXnmAkaXMHaoUgW1CXOGRCphgt+0i20lp5rAhuwWL
 XFQtQufCcC1YjwquVk7KbAPvEhhrdnVooQSoV8n7DlCnr/xmF8PuDqZpgNuOCNsIaoNq/bLejrZ
 qppxOVOpV7EuYo6sfUqKzSKYj3m4WlMbV286AZNESIW/KgwaADvKPSCfJOoqFKcBQJ79BbP+Z+e
 K5T074Uc5lKMScA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

gen_clid() assigns cl_id from nn->clientid_counter++, so each client's
clientid sits one step from the clientid issued just before it. The
"other" field of every stateid embeds the clientid, and NFSv4.0
resolves a presented stateid against the client named inside it rather
than the caller, so a guessed clientid is the first half of locating
another client's state. A reporter enumerated a neighbor's clientid in
tens of probes by counting outward from their own.

Fill cl_id from get_random_u32() instead. A collision retries
NFSD4_RANDOM_RETRIES times before NFS4ERR_DELAY. Generating the id
moves into each caller's nn->client_lock section, so the generation,
the uniqueness scan, and the add_to_unconfirmed() insert run under one
hold of the lock. The generation also runs before any
mark_client_expired_locked() or unhash_client_locked(), so exhausting
the retries returns NFS4ERR_DELAY with every prior record still
hashed.

nn->s2s_cp_cl_id becomes the fixed value 0. The first key
idr_alloc_cyclic() hands out is also 0, so without a further check an
OFFLOAD_CANCEL carrying the all-zero stateid would revoke the caller's
first COPY_NOTIFY state. Add a cl_boot check to manage_cpntf_state()
that rejects any boot value but the current one with
NFS4ERR_BAD_STATEID.

A random cl_id requires "NFSD: Make nn->boot_time strictly increase
across state starts", so a same-second restart cannot reissue a prior
instance's id, and "NFSD: Give each client a display id independent
of cl_id", since cl_id is still 0 when the client directory is
created.

A random cl_id collides with one of the K ids retired earlier this
boot with probability about K / 2^32 per client, about 0.2% at K = 10
million. On such a collision, a stateid that an expired NFSv4.0 client
retries can resolve to the new client's state, if the so_id,
generation, and filehandle also match. NFSv4.1 is not exposed, since
SEQUENCE binds the clientid to the session.

Guessing remains feasible. Locating a live clientid costs about
2^32 / C probes for C confirmed clients, and a LOCK or LOCKT denial
still discloses a holder's clientid outright. "NFSD: Stop disclosing
the conflicting lock holder in a lock denial" removes that path.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/netns.h     |   2 -
 fs/nfsd/nfs4state.c | 108 ++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 100 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index da39d064f5e9..dc4b319b194d 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -165,8 +165,6 @@ struct nfsd_net {
 	 */
 	unsigned int max_blksize;
 
-	u32 clientid_base;
-	u32 clientid_counter;
 	u32 clverifier_counter;
 	atomic_t client_display_counter;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 845ded94f81f..81f82837dc73 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -63,6 +63,13 @@
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
+/*
+ * Bound the cl_id retries so a stuck random source cannot spin under
+ * client_lock. A random id collides about N times in 2^32 for N hashed
+ * clients, so the bound is not reached in practice.
+ */
+#define NFSD4_RANDOM_RETRIES	16
+
 #define all_ones {{ ~0, ~0}, ~0}
 static const stateid_t one_stateid = {
 	.si_generation = ~0,
@@ -3174,10 +3181,64 @@ static void gen_confirm(struct nfs4_client *clp, struct nfsd_net *nn)
 static void gen_clid(struct nfs4_client *clp, struct nfsd_net *nn)
 {
 	clp->cl_clientid.cl_boot = (u32)nn->boot_time;
-	clp->cl_clientid.cl_id = nn->clientid_counter++;
 	gen_confirm(clp, nn);
 }
 
+/*
+ * Unlike find_client_in_id_table(), compare cl_id alone: a random id
+ * that matches a hashed client of another minor version, or one marked
+ * expired but not yet unhashed, is still a collision.
+ */
+static bool cl_id_in_use_locked(struct nfsd_net *nn, u32 id)
+{
+	unsigned int idhashval = clientid_hashval(id);
+	struct nfs4_client *clp;
+
+	lockdep_assert_held(&nn->client_lock);
+
+	list_for_each_entry(clp, &nn->conf_id_hashtbl[idhashval], cl_idhash)
+		if (clp->cl_clientid.cl_id == id)
+			return true;
+	list_for_each_entry(clp, &nn->unconf_id_hashtbl[idhashval], cl_idhash)
+		if (clp->cl_clientid.cl_id == id)
+			return true;
+	return false;
+}
+
+/*
+ * The caller inserts @clp with add_to_unconfirmed() under the same
+ * hold of client_lock, so no other client can take the chosen id
+ * first. When @conf holds a verifier matching @verf, SETCLIENTID fills
+ * cl_id from @conf with copy_clid() instead, so no random id is
+ * assigned.
+ */
+static __be32 nfsd4_assign_clid_locked(struct nfs4_client *clp,
+				       struct nfsd_net *nn,
+				       struct nfs4_client *conf,
+				       nfs4_verifier *verf)
+{
+	u32 id;
+	int i;
+
+	lockdep_assert_held(&nn->client_lock);
+
+	if (conf && same_verf(&conf->cl_verifier, verf))
+		return nfs_ok;
+
+	for (i = 0; i < NFSD4_RANDOM_RETRIES; i++) {
+		id = get_random_u32();
+		if (id == nn->s2s_cp_cl_id)
+			continue;
+		if (!cl_id_in_use_locked(nn, id)) {
+			clp->cl_clientid.cl_id = id;
+			return nfs_ok;
+		}
+	}
+	pr_warn_ratelimited("NFSD: no unused clientid after %d tries\n",
+			    NFSD4_RANDOM_RETRIES);
+	return nfserr_jukebox;
+}
+
 static struct nfs4_stid *
 find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 {
@@ -3252,12 +3313,20 @@ static int client_info_show(struct seq_file *m, void *v)
 	struct inode *inode = file_inode(m->file);
 	struct nfsd4_session *ses;
 	struct nfs4_client *clp;
+	struct nfsd_net *nn;
 	u64 clid;
 
 	clp = get_nfsdfs_clp(inode);
 	if (!clp)
 		return -ENXIO;
+	/*
+	 * create_client() publishes this file before cl_id is assigned
+	 * under client_lock.
+	 */
+	nn = net_generic(clp->net, nfsd_net_id);
+	spin_lock(&nn->client_lock);
 	memcpy(&clid, &clp->cl_clientid, sizeof(clid));
+	spin_unlock(&nn->client_lock);
 	seq_printf(m, "clientid: 0x%llx\n", clid);
 	seq_printf(m, "address: \"%pISpc\"\n", (struct sockaddr *)&clp->cl_addr);
 
@@ -4331,6 +4400,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_client *conf, *new;
 	struct nfs4_client *unconf = NULL;
 	__be32 status;
+	bool			fresh = false;
 	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
@@ -4438,6 +4508,9 @@ nfsd4_exchange_id(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				trace_nfsd_clid_cred_mismatch(conf, rqstp);
 				goto out;
 			}
+			status = nfsd4_assign_clid_locked(new, nn, NULL, NULL);
+			if (status)
+				goto out;
 			goto out_new;
 		}
 		if (verfs_match) { /* case 2 */
@@ -4447,6 +4520,9 @@ nfsd4_exchange_id(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		}
 		/* case 5, client reboot */
 		trace_nfsd_clid_verf_mismatch(conf, rqstp, &verf);
+		status = nfsd4_assign_clid_locked(new, nn, NULL, NULL);
+		if (status)
+			goto out;
 		conf = NULL;
 		goto out_new;
 	}
@@ -4456,12 +4532,16 @@ nfsd4_exchange_id(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
+	status = nfsd4_assign_clid_locked(new, nn, NULL, NULL);
+	if (status)
+		goto out;
+
 	unconf = find_unconfirmed_client_by_name(&exid->clname, nn);
 	if (unconf) /* case 4, possible retry or client restart */
 		unhash_client_locked(unconf);
 
 	/* case 1, new owner ID */
-	trace_nfsd_clid_fresh(new);
+	fresh = true;
 
 out_new:
 	if (conf) {
@@ -4478,6 +4558,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	new->cl_cs_slot.sl_status = nfserr_seq_misordered;
 
 	add_to_unconfirmed(new);
+	if (fresh)
+		trace_nfsd_clid_fresh(new);
 	swap(new, conf);
 out_copy:
 	exid->clientid.cl_boot = conf->cl_clientid.cl_boot;
@@ -5421,6 +5503,9 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		}
 	}
+	status = nfsd4_assign_clid_locked(new, nn, conf, &clverifier);
+	if (status)
+		goto out;
 	unconf = find_unconfirmed_client_by_name(&clname, nn);
 	if (unconf)
 		unhash_client_locked(unconf);
@@ -5431,11 +5516,12 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		} else
 			trace_nfsd_clid_verf_mismatch(conf, rqstp,
 						      &clverifier);
-	} else
-		trace_nfsd_clid_fresh(new);
+	}
 	new->cl_minorversion = 0;
-	gen_callback(new, setclid, rqstp);
 	add_to_unconfirmed(new);
+	gen_callback(new, setclid, rqstp);
+	if (!conf)
+		trace_nfsd_clid_fresh(new);
 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
 	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
 	memcpy(setclid->se_confirm.data, new->cl_confirm.data, sizeof(setclid->se_confirm.data));
@@ -5746,9 +5832,8 @@ nfsd4_init_leases_net(struct nfsd_net *nn)
 	nn->nfsd4_lease = 90;	/* default lease time */
 	nn->nfsd4_grace = 90;
 	nn->clverifier_counter = get_random_u32();
-	nn->clientid_base = get_random_u32();
-	nn->clientid_counter = nn->clientid_base + 1;
-	nn->s2s_cp_cl_id = nn->clientid_counter++;
+	/* The COPY_NOTIFY sentinel clientid used by nfs4_init_cp_state() */
+	nn->s2s_cp_cl_id = 0;
 	/* So the first client directory in a fresh netns is named 2. */
 	atomic_set(&nn->client_display_counter, 1);
 
@@ -8557,6 +8642,13 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 
 	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
 		return nfserr_bad_stateid;
+	/*
+	 * With a fixed sentinel clientid, the all-zero stateid and a token
+	 * from a previous nfsd instance both match cl_id, so cl_boot has
+	 * to carry the check.
+	 */
+	if (st->si_opaque.so_clid.cl_boot != (u32)nn->boot_time)
+		return nfserr_bad_stateid;
 	spin_lock(&nn->s2s_cp_lock);
 	/* s2s_cp_stateids holds only COPY_NOTIFY stateids */
 	cps_t = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);

-- 
2.56.0


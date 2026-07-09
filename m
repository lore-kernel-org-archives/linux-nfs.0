Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8E653CCA02;
	Thu,  9 Jul 2026 18:48:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783622883; cv=none; b=HaeYeNB9wqXlzJ8gzTmT4HpI71lAO9wYavmvAIY/l6j5vjFb8I7jeUjM+DGdWS7Bved62CRCUa9TJcyQ7n56+tvAoS5p9+aqhbDsSJpXViJL7SQR5mXdACjRkr51TuiGbp/6/6h3C3sj+fNroRhpwoWZJvw6V+Hb+U+htWedupw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783622883; c=relaxed/simple;
	bh=aHCKfzD2q1dc1GZoucJcJPXcFmmWH6iHCuJvENp8jL4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=MmEIM3TzwXLdALLXOPxIgQAXUnrUdckTknMjkzjve82HOy3l7x1G+zyUuSyZXj9bvcwkLxDyiMHceRAGBGoOyrfljShk7vq1NQsUOHznKRaZXkzheyrfmTPlhV4SvmNQe1Jye0fHIuIJwGlMoQ/BhBA0gBVtuF8k9AxFJ1UW3To=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bS/4j2en; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bS/4j2en"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC7C31F00A3E;
	Thu,  9 Jul 2026 18:48:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783622881;
	bh=oBC0RxvRzyQ2OSTnXGcbWDGMDoGQ8FAlY6/e6RXZ8Kg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bS/4j2enr1dFkmkPzp5y1B1Rr0LilpgyqHoRZjYqwFG2o4FbUo+x8XYlGn12Y6mkO
	 KMV0FO29t2Kme0b0cXd2iNacXM72IiBrGz63vHLXGx0ofHCgnFXu/sBrjODIjYxJCk
	 4Fmr2ha83+ficzneWXw511shdyjscgDRCQYBLSe/3HDJYNcwIXVEpbt384xsXQculV
	 NtW0MtwaGo54CcnNUpJuGbTzu0EFqDAmjN7r1bnaCwzunTA484A/MfWa6fMqMV2UNG
	 CHEULvaDm0w4cpgGVEaUJXjUe5syTRNhC9JuAvZzagQmQY5cCVGQHEPcZwzyC2q+6S
	 K5of2TB2gneIQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 09 Jul 2026 14:47:47 -0400
Subject: [PATCH v2 10/10] nfsd: drop dead COPY-vs-COPYNOTIFY type handling
 from s2s stateid IDR
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260709-nfsd-testing-v2-10-0a1ba233bf87@kernel.org>
References: <20260709-nfsd-testing-v2-0-0a1ba233bf87@kernel.org>
In-Reply-To: <20260709-nfsd-testing-v2-0-0a1ba233bf87@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Andy Adamson <andros@netapp.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4635; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=aHCKfzD2q1dc1GZoucJcJPXcFmmWH6iHCuJvENp8jL4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqT+zWcdrFrvtoNGWNrKNt2zlOL+M1dNmTsK35m
 CLvoswjr1qJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCak/s1gAKCRAADmhBGVaC
 FdGqEADWWkvc8cB6+InoklGniM4NqruaWjELlIbDUVvBVPnuKOoedQUjfyiMmAdGGQLv4W70Rmx
 z/C+ezm2aUduzBOYTDBRvQ6fPiZfHLbyhSiq1kXmt56p5yalvGX8FtXH4BEWcF+3TonkktrWeMQ
 9SHd0N1Z75EsMfx92JEa8WW/gsizLUEzRlFlmRWMaxNavCI4OGxNI13fa3A7BtiarTgfl4ki3PM
 Cwaj9ps+qSVNjBrq15DULnLTPv/PxHXJl4ZsEorDDz2x3tXepF5d3PqpLvhoEdSfLu97IsNUgIm
 1mJ/PL7QvV7h7qDRF3ApEZYqrHFvqGV0sBvcvA8dNsNacNWK1JNB9uYPumF0PgKbpjElEAuFbKB
 gwefVKNUk/NeR+MQziBmhPYwiqB4PZk1IMZPgke89LHZqHNaxM03ZLXwU5IaawhX1wHAihyBKR7
 u+fpLI7PQAzkyEc2DpQbMsHCeVLKuwWMRwCT+CL3RnM0XL6Xas5l4hAMMSlrQqx9MbGAlBXXbdl
 QZ1BxxF+zPsMmoICL1zUi83IabyzBKHLnaxAwb9aga3eDLUAATdhqUqI6sdAfN2V9KXv1GI4KWx
 qZQXtDOJmz5MbvvET0X8Pficip5L8pUKLDTw2ISC1x2aj1EipOuGaL1Tl5VgOQGk9UmV/Fxhoju
 +jv68at/vm6hUgw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Now that the COPY offload stateid is a first-class nfs4_stid,
nn->s2s_cp_stateids holds COPY_NOTIFY stateids exclusively (its only
inserter, nfs4_init_cp_state(), runs only from
nfs4_alloc_init_cpntf_state()). The type-distinguishing machinery is dead:

  - remove the unreferenced NFS4_COPY_STID definition;

  - drop nfs4_init_cp_state()'s cs_type argument (hardcode
    NFS4_COPYNOTIFY_STID) and its now-always-true "if (p_stid)" guard;

  - remove the cs_type == NFS4_COPYNOTIFY_STID gates in
    manage_cpntf_state() and the laundromat, which can no longer be false.

copy_stateid_t.cs_type is retained for the WARN_ON_ONCE() sanity checks on
the free paths. No functional change.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 31 +++++++++++++------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8ac76db31fbb..380214e90f44 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -942,10 +942,12 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 }
 
 /*
- * Create a unique stateid_t to represent each COPY.
+ * Publish a COPY_NOTIFY stateid in nn->s2s_cp_stateids and link it onto the
+ * parent stid's sc_cp_list. s2s_cp_stateids holds only COPY_NOTIFY stateids;
+ * the COPY offload stateid is a first-class nfs4_stid in cl_stateids.
  */
 static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
-			      unsigned char cs_type, struct nfs4_stid *p_stid)
+			      struct nfs4_stid *p_stid)
 {
 	int new_id;
 
@@ -956,6 +958,9 @@ static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
 	spin_lock(&nn->s2s_cp_lock);
 	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, stid, 0, 0, GFP_NOWAIT);
 	if (new_id >= 0) {
+		struct nfs4_cpntf_state *cps =
+			container_of(stid, struct nfs4_cpntf_state, cp_stateid);
+
 		stid->cs_stid.si_opaque.so_id = new_id;
 		stid->cs_stid.si_generation = 1;
 		/*
@@ -967,14 +972,8 @@ static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
 		 * fully linked cp_list, so list_del_init() in
 		 * _free_cpntf_state_locked() is always well-defined.
 		 */
-		stid->cs_type = cs_type;
-		if (p_stid) {
-			struct nfs4_cpntf_state *cps =
-				container_of(stid, struct nfs4_cpntf_state,
-					     cp_stateid);
-
-			list_add(&cps->cp_list, &p_stid->sc_cp_list);
-		}
+		stid->cs_type = NFS4_COPYNOTIFY_STID;
+		list_add(&cps->cp_list, &p_stid->sc_cp_list);
 	}
 	spin_unlock(&nn->s2s_cp_lock);
 	idr_preload_end();
@@ -1048,8 +1047,7 @@ struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
 	memcpy(&cps->cp_p_clid, &p_stid->sc_client->cl_clientid,
 	       sizeof(clientid_t));
 	refcount_set(&cps->cp_stateid.cs_count, 2);
-	if (!nfs4_init_cp_state(nn, &cps->cp_stateid, NFS4_COPYNOTIFY_STID,
-				p_stid))
+	if (!nfs4_init_cp_state(nn, &cps->cp_stateid, p_stid))
 		goto out_free;
 	return cps;
 out_free:
@@ -7590,10 +7588,10 @@ nfs4_laundromat(struct nfsd_net *nn)
 	nfsd4_end_grace(nn);
 
 	spin_lock(&nn->s2s_cp_lock);
+	/* s2s_cp_stateids holds only COPY_NOTIFY stateids */
 	idr_for_each_entry(&nn->s2s_cp_stateids, cps_t, i) {
 		cps = container_of(cps_t, struct nfs4_cpntf_state, cp_stateid);
-		if (cps->cp_stateid.cs_type == NFS4_COPYNOTIFY_STID &&
-				state_expired(&lt, cps->cpntf_time))
+		if (state_expired(&lt, cps->cpntf_time))
 			revoke_cpntf_state_locked(nn, cps);
 	}
 	spin_unlock(&nn->s2s_cp_lock);
@@ -8005,14 +8003,11 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
 		return nfserr_bad_stateid;
 	spin_lock(&nn->s2s_cp_lock);
+	/* s2s_cp_stateids holds only COPY_NOTIFY stateids */
 	cps_t = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
 	if (cps_t) {
 		state = container_of(cps_t, struct nfs4_cpntf_state,
 				     cp_stateid);
-		if (state->cp_stateid.cs_type != NFS4_COPYNOTIFY_STID) {
-			state = NULL;
-			goto unlock;
-		}
 		if (!clp) {
 			refcount_inc(&state->cp_stateid.cs_count);
 		} else if (memcmp(&clp->cl_clientid, &state->cp_p_clid,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5dc4a473246e..ee5c429edfa2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -59,7 +59,6 @@ typedef struct {
 
 typedef struct {
 	stateid_t		cs_stid;
-#define NFS4_COPY_STID 1
 #define NFS4_COPYNOTIFY_STID 2
 	unsigned char		cs_type;
 	refcount_t		cs_count;

-- 
2.55.0


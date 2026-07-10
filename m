Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 547503438A1;
	Fri, 10 Jul 2026 14:00:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783692032; cv=none; b=aynxUkkLZX9u01/9CgwydR+HmdXyApFzrYdpzt+UeH6PLEdwM1/cBs6+WFl4d7g3x6IySsYY2BN9yleAotQ7hR75BXoQzHHNOSUq+u9Xe7Ojh3mC13g5exPA4f64Kxjvphe3bTT7q4Z5iPKe8D0H5Uazi/jTWOAn6F3ikvVKTbo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783692032; c=relaxed/simple;
	bh=Sga81Kimikjr+kwgIUUvTtwBBbRLoMCsR7tQ0oLuX2I=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=jJdGZzhMWma9N8SPIfiJcuyCRm2frHkt2WnE7VwZeUX2556FnacBZar3PAFwi6tJ0e/dzd6CBQtPe+4satJYRXJG6iEa1kl2b5nug31OMvbzbu0hFmXeVHV1EsIiJ9hcUNwhMjXgMyp5wlLzQDO5YLwVci7VK0r4yZOcufaYOSw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iKtwByym; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iKtwByym"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D7071F00A3F;
	Fri, 10 Jul 2026 14:00:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783692031;
	bh=GeNytnrG6l3gkhfe5n7ALlNpmmqVV9wSs5W0D9akW7k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iKtwByym//0N4pkRhsfbrvvrlp4cpE+Me3T0bMZjNqwP0DoqkjhatbNMFqTBxtmXh
	 uVnwW3fuRX1wAMkiwfvATNchR5ZNUMOsXikx0V15Qr7ZwQVgt0Gv8h40tD4KRD/ErA
	 GWAM2msXvo4P1u9tgm0Rf1CMSsJj3XDVdf4d56UMe+0yv7NaDZeGZoxHzeICACQ54x
	 CKfQynCcNwHpaeZ3poSTVRiiSc7RHVGP0yPSGnL2RkY1yfP9pOgyAMuwee1wKK4spp
	 GZHLN6cciFhEVgxR1lS/deSb05XFf2BVR9ZwRbiX9TuzNCs7zGIsF4cIYuYX1eKnIs
	 4L5Iyyh/A3zig==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 10 Jul 2026 10:00:14 -0400
Subject: [PATCH v3 10/10] nfsd: drop dead COPY-vs-COPYNOTIFY type handling
 from s2s stateid IDR
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260710-nfsd-testing-v3-10-a0ff7db6aa3e@kernel.org>
References: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
In-Reply-To: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4523; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Sga81Kimikjr+kwgIUUvTtwBBbRLoMCsR7tQ0oLuX2I=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqUPr1RYwZ8X5GKYHgCXeYQnpxHtPDlKJXK8Zn2
 3qafWMyQUmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCalD69QAKCRAADmhBGVaC
 FfooD/kBCQiDXIKgIquZ12yMysX/CUUB8Gas4zKOatQrZQOKbY8stXIo4XzSath+ihStzmzi18l
 qJ5QVd7VwVjTL2+5zxc9lfqRLkGors1mPIXf4enqIvWuv/kHNwD5UfNJE9NzKvwz90uUCh5mu9A
 RKUK+L1ST7jhFu2NcEXafEPHO2R9Iw1rwvkBy41mvlDKxvcSoFkcd2bJhtP5VunbHhLySmNOGFL
 QJgw8Dt50LLDMWIfQM36rMuIXWb5QF7FEi/b2Ug5o5RdLRDKFkoUMu24TqQ+diN2katQFvX+WIa
 6ctu3Eu7ZBYNAP1Lj0Lj/Wc3XXvLB0giDXCmCJP/g31Cfkk69ZaR9CrgeGGtCuz7WmFvDNuABie
 lLBkRNIL0a7yUU/wXtoJ6XflsXYfgKGJ4W9zvOlbVR7Em/yr6A4qzBMY2/pVxrxz0ALSmCEaz3i
 LsclnJEwKfnAK1tvBUKaCnB1xXIOwWPh1QasMdwuvPR8tlaAnGOUxFM4vCd9iu5xXPuUP6saH3q
 ff0/FyRKrTJlIupevAXETnu3M2EjJ09vAKSmLJ26ir9SfzzJcPmYIKtMll11BdRtTcFfF0ClNjs
 SAYkZR879cdV29JPMBnMRl0NbUiRvfZ6SjgXX02wQShWDDeB0SPaZ/eIICUOLiNA44sHqlZfPCL
 kftsZitrsKQEqlg==
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
 fs/nfsd/nfs4state.c | 30 ++++++++++++------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 900aca361413..b9dd50f39757 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -942,10 +942,11 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 }
 
 /*
- * Create a unique stateid_t to represent each COPY.
+ * Publish a COPY_NOTIFY stateid in nn->s2s_cp_stateids and link it onto the
+ * parent's sc_cp_list. That IDR holds only COPY_NOTIFY stateids.
  */
 static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
-			      unsigned char cs_type, struct nfs4_stid *p_stid)
+			      struct nfs4_stid *p_stid)
 {
 	int new_id;
 
@@ -956,6 +957,9 @@ static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
 	spin_lock(&nn->s2s_cp_lock);
 	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, stid, 0, 0, GFP_NOWAIT);
 	if (new_id >= 0) {
+		struct nfs4_cpntf_state *cps =
+			container_of(stid, struct nfs4_cpntf_state, cp_stateid);
+
 		stid->cs_stid.si_opaque.so_id = new_id;
 		stid->cs_stid.si_generation = 1;
 		/*
@@ -964,14 +968,8 @@ static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
 		 * manage_cpntf_state() sees either no entry or a fully
 		 * linked cp_list.
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
@@ -1031,8 +1029,7 @@ struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
 	memcpy(&cps->cp_p_clid, &p_stid->sc_client->cl_clientid,
 	       sizeof(clientid_t));
 	refcount_set(&cps->cp_stateid.cs_count, 2);
-	if (!nfs4_init_cp_state(nn, &cps->cp_stateid, NFS4_COPYNOTIFY_STID,
-				p_stid))
+	if (!nfs4_init_cp_state(nn, &cps->cp_stateid, p_stid))
 		goto out_free;
 	return cps;
 out_free:
@@ -7556,10 +7553,10 @@ nfs4_laundromat(struct nfsd_net *nn)
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
@@ -7971,14 +7968,11 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
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


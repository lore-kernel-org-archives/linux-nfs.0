Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE3BD2E737D;
	Fri, 10 Jul 2026 14:00:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783692025; cv=none; b=TZmlRdVsV0my4w8+SmbLjIUJCAH8yUH7qpJMXIoisoiFriGn16i2EBIX6zO7c9jpVCTFvIj90N1y+eDMj+UhCNIWfdVxe1nZL9vWqfyjLRKyxG7dFqZ+0/gfoJ9EdSld9gajiYTQxrjOC4YBBw8NQftLJunrSgXaEYRUuW8HLGA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783692025; c=relaxed/simple;
	bh=0uwhy/RiiEPzdI8zBwJ661GrYPmXfXDw4kHWDXe+aFc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=no18ZslTqLw6hRjl0sfKY5sNAXx+LJ83NMkQo51a2USbvE2DRuI6Ka8qGjDJPz7TXcikEzWq9H1iEL8UdsUFUMg0oAPGNelaDb5P4rRgNZOEjheJuRLTZkPu4AFspT1koYcdsG508Sy1xfb1YNx0LEfpcn9F6DSn9RcpHnyVQu4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SMXVyg5/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SMXVyg5/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6DEEB1F00A3D;
	Fri, 10 Jul 2026 14:00:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783692023;
	bh=Jag53DCfZhjz9zup7kqf3WqxAeZYGKw0TPMdGztZ/+Q=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SMXVyg5/tQhbhHCEebiUM3fdbH5sf6Hs170VGrpFR+/zX3Org2TSYu0I4zR4BFCiv
	 pu6s8Bzqh9CPM/dokhKxS8vUfoQkDN30qFiZ+HKsGAPtQ57LxMI7fuWZHEaUoRZCja
	 GNVZpa1v0xuHfnqJfF/19g/v/bw+w2DYNNArgPAdrhmgwuqhXCf87YcLlNPRssN3Oo
	 8qTCjiXIztCCCJxw1eiATg5OKVHD/cATlz/sqDkwfDVpizOWX3gMQCV/51PZDv0CwR
	 /qMmov3Mmj7rnm5uHV4x2flTP6gzRUkK7lUNldUn6Pl6GLyRn5gZ5J+ndQtB1zP2Md
	 suT1Qc4ERbYRQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 10 Jul 2026 10:00:05 -0400
Subject: [PATCH v3 01/10] nfsd: fix cpntf publish race in
 nfs4_init_cp_state
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260710-nfsd-testing-v3-1-a0ff7db6aa3e@kernel.org>
References: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
In-Reply-To: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4124; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=I/ZB1x92w1R31EbXV6PYwa3Zzf0dTEOEA09nUqFj1gQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqUPry3Npdja8BKKYfIYAnBNWAkGqAlcBaTitOf
 17xX4B8q2uJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCalD68gAKCRAADmhBGVaC
 FZDBEACZV/n7gGCp7PI+2a0RL/dqOWS3JJA/oZ+mGYoW8tkFxPC5DI5dWsTlHySOrWKeieu5ACq
 8N5VR5KSmcOOAhTwA+auIafMeLgOTc/t/9KkWkBM91820X4D404Dp9IvQ94ahjW5F78WcSDsEp3
 iv9XdvX9I+w1X/EglC8kXAeQP1kf4YkghmlwgAsBKb8MBwNhpKOJE9zILVLaGfqheGwuhqDQXj2
 G57VtAUJvudF/6+OB97yTVE8axTISYfi6MLqhZQPZiCSV75W9gNJakIpqGkyKkG2HX5f1z182Gs
 IGubkgzDSMzWxZMPX6ZCw6e+vxvEMHMRqRSDtdLr7+rGKdxIjmMnlqqPdONuQPaLq6B8ck5GeAI
 qfH9PgMRv+MredLI+LM83RKlhAsUnzo+fLwGrjTqFbluFa3x8imGSQH3sr/2pvFxZ/6A3sopLMv
 1cb+Sn66yaP1niXjY9uH48dlWvaluw1oYuXRn9LslDlaRQOmQf8VwhHTDBgCWu1ir9pFC123Q2f
 yebODbiy0CQFXyg9pJyJU9b7n+p65T7AXeAQ80B7UVaeX7sF6cuFdw9nBv1SK3AoA1J1XRLa04I
 tKDLnYvtWU9gmRww2uiuK9n5YoyATkKwpplPSqIKNe0VPzt0BWMTyDizAWK/pJTmYWCu1RhMgyI
 giDG9zOu/h4s/qQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

From: Chris Mason <clm@meta.com>

nfs4_alloc_init_cpntf_state() published the new cpntf entry into the
s2s_cp_stateids IDR (with cs_type set) in one s2s_cp_lock section, then
took the lock again to list_add() it onto p_stid->sc_cp_list. In the gap
the entry is reachable by so_id but cp_list is still {NULL,NULL} from
kzalloc. A racing OFFLOAD_CANCEL (so_id is echoed to the client as
cnr_stateid, so any NFSv4.2 client can drive it) reaches
manage_cpntf_state() -> _free_cpntf_state_locked() and does list_del() on
the zeroed list_head, oopsing the server.

Fold the cs_type assignment and the list_add() into the same critical
section as idr_alloc_cyclic(), so a concurrent lookup either misses the
entry or sees a fully linked cp_list. INIT_LIST_HEAD() the entry after
allocation and switch _free_cpntf_state_locked() to list_del_init() so a
stale unlink is a no-op. nfs4_init_copy_state() passes NULL p_stid and
skips the list_add, preserving NFS4_COPY_STID semantics.

Fixes: 624322f1adc5 ("NFSD add COPY_NOTIFY operation")
Assisted-by: kres:claude-opus-4-7
Signed-off-by: Chris Mason <clm@meta.com>
---
 fs/nfsd/nfs4state.c | 35 +++++++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a4398dc861a5..3f83c5107e28 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -944,7 +944,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
  * Create a unique stateid_t to represent each COPY.
  */
 static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
-			      unsigned char cs_type)
+			      unsigned char cs_type, struct nfs4_stid *p_stid)
 {
 	int new_id;
 
@@ -954,19 +954,34 @@ static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
 	idr_preload(GFP_KERNEL);
 	spin_lock(&nn->s2s_cp_lock);
 	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, stid, 0, 0, GFP_NOWAIT);
-	stid->cs_stid.si_opaque.so_id = new_id;
-	stid->cs_stid.si_generation = 1;
+	if (new_id >= 0) {
+		stid->cs_stid.si_opaque.so_id = new_id;
+		stid->cs_stid.si_generation = 1;
+		/*
+		 * Set cs_type and link onto sc_cp_list under the same lock
+		 * that installed the IDR entry, so a concurrent
+		 * manage_cpntf_state() sees either no entry or a fully
+		 * linked cp_list.
+		 */
+		stid->cs_type = cs_type;
+		if (p_stid) {
+			struct nfs4_cpntf_state *cps =
+				container_of(stid, struct nfs4_cpntf_state,
+					     cp_stateid);
+
+			list_add(&cps->cp_list, &p_stid->sc_cp_list);
+		}
+	}
 	spin_unlock(&nn->s2s_cp_lock);
 	idr_preload_end();
 	if (new_id < 0)
 		return 0;
-	stid->cs_type = cs_type;
 	return 1;
 }
 
 int nfs4_init_copy_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
 {
-	return nfs4_init_cp_state(nn, &copy->cp_stateid, NFS4_COPY_STID);
+	return nfs4_init_cp_state(nn, &copy->cp_stateid, NFS4_COPY_STID, NULL);
 }
 
 struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
@@ -977,13 +992,13 @@ struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
 	cps = kzalloc_obj(struct nfs4_cpntf_state);
 	if (!cps)
 		return NULL;
+	/* So a stale list_del_init() before linking is a no-op. */
+	INIT_LIST_HEAD(&cps->cp_list);
 	cps->cpntf_time = ktime_get_boottime_seconds();
 	refcount_set(&cps->cp_stateid.cs_count, 1);
-	if (!nfs4_init_cp_state(nn, &cps->cp_stateid, NFS4_COPYNOTIFY_STID))
+	if (!nfs4_init_cp_state(nn, &cps->cp_stateid, NFS4_COPYNOTIFY_STID,
+				p_stid))
 		goto out_free;
-	spin_lock(&nn->s2s_cp_lock);
-	list_add(&cps->cp_list, &p_stid->sc_cp_list);
-	spin_unlock(&nn->s2s_cp_lock);
 	return cps;
 out_free:
 	kfree(cps);
@@ -7854,7 +7869,7 @@ _free_cpntf_state_locked(struct nfsd_net *nn, struct nfs4_cpntf_state *cps)
 	WARN_ON_ONCE(cps->cp_stateid.cs_type != NFS4_COPYNOTIFY_STID);
 	if (!refcount_dec_and_test(&cps->cp_stateid.cs_count))
 		return;
-	list_del(&cps->cp_list);
+	list_del_init(&cps->cp_list);
 	idr_remove(&nn->s2s_cp_stateids,
 		   cps->cp_stateid.cs_stid.si_opaque.so_id);
 	kfree(cps);

-- 
2.55.0


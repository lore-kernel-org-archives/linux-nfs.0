Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B851D2E54B6
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015333; cv=none; b=CAknow9Y7gR5d39sgRdnn0J33DJGTzSCZi4WLqXMS0atbBQGkYE89MXiFtXY4KLKDfQ4rGcl7ammNoSuMstZgkaKVBLCKSs4EoyGNF4s0M29kZlzG1KUU9wbGCdSbkxLy2Lt6wZ34duevWgEulzIqRHCo+6wj4QExPnp6iguJyM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015333; c=relaxed/simple;
	bh=6gxEda1bs/KRoQALu90aDCby3CKqfUsNFvbZ25kwX4w=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=GtH5ieur8oDnfoahCkgG0V4pI5XM8yC4e7yZZKvAzyO94VjTpq0L2x7KhYJwQEQNNjSyz/XSo/VJOI5+c/cZdwBD8Fyfsc8P2H7jSk6V2kUq0UDHL/K2Yb3ZYd1Um2E5HycvFwX0T+oJuc+xWKgDPHHjI47RAfEXw9oYo0rqSng=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=evNjvl7q; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="evNjvl7q"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1B1DA1F00A3E;
	Tue, 18 Aug 2026 01:08:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015330;
	bh=RahMs4vn3aH/kioWRL7QEaIjgwqJei0EssjGjceUJno=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=evNjvl7qMMVr65IRO6+huv4QlhiUkUk0M1sZqzulcEoYOtnKyb6W7x01lEiVZUAVw
	 qdoNxFZNCmz9TfoLWD/qj0nE4UIbEVDJJXArmOvbmhbU/5gCgsEvMwGKaNDSuNIi7C
	 v6w0bihCMwQP0jSPFelNh8frN5mVgNV8smw+ZxgCrLWG2K2Cqm844VrVEoR+9nOsII
	 o+MXucdGFmpBYnBYG2vPnbOIJFM2uvJ1OJbsISjpPMCrPLUaNyghIlFPqN8XId9fZj
	 doTjn8hPISxh0jg9+TVo8YNiPfWJbqf3pbN+eBjF4N4WeqXlsFuVGFejXFD0JNycTx
	 Gl6F7q+uo7j5w==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 21:08:40 -0400
Subject: [PATCH v5 5/8] NFSD: Count delegations per network namespace
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-recall-any-keep-count-v5-5-3b2cffce701e@kernel.org>
References: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
In-Reply-To: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3338; i=cel@kernel.org;
 h=from:subject:message-id; bh=6gxEda1bs/KRoQALu90aDCby3CKqfUsNFvbZ25kwX4w=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg7Cd7/VEOJZjNWlJYvz9dDmzek13pqYDQaNys
 RWwogUsQoWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOwnQAKCRAzarMzb2Z/
 l5DbD/9nzbk5nTj6xroH4sNuEGXCi+xSghibMw++0jpqBRMBSlC8Qno+FTjDte67KsT+ipwhKHu
 EYPu91cobtHlVid4oLO66RAMi4UT+sVgxG/obOg4GwEBl4gVb4iPL/2nKWLEJNgDdF32pIrMJtF
 QATbGszI7N43m6lp8D2sfxKpQmQ1mAlkyBp/pUSAWr3tbD1vV0yV4fk0LA5cT9Rws9KBteAL7kt
 ku1Od0ht/xNurm55103eZYZDsQyU0WbVg0pMVwL6JHzlQrpbeOh8PbNlUGMRXIFTBHPPECAneEM
 igupsIgTBnezamA45f9sGzqHvuRpwCqIJXg8P+sj4nAX91uA65OLpu1m1wHy4E6w54fYkfG/ME3
 x4qGDYYs/xRsWLp3ThQasJN7tK3isOb4K2ztq960GGYf38F+U8KIpuvyYYaqjI1WwCENPtn8bW+
 1fHVB+iYxM3H2JMmco2QiUFxoB1vQP5IaC9k5LJwc2pke6gnrPDFztkrDM14Eq8Zy8iep0XNtLK
 /5VsFU9scYjPyWfdv0ENH+7VJ5t8ZU36UxbuJzX52+1/mmOwKzYuG1cWUCa5GdXlr4g5m9IlvNH
 19WxkMo7nnZ4YbZ1CxwjfvIL7T0iGOLzHJsyldlkc8khO2U3z6pPVHBogUNPcZ2cNjCCbvOIqb9
 2dMtAC6yXJq5cNQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The state shrinker is allocated per network namespace, but
nfsd4_state_shrinker_count() reports num_delegations, which counts
the delegations held by the whole host. Every namespace therefore
reports every delegation on the server. Reclaim sees the
population multiplied by the number of namespaces running NFSD. A
namespace holding no delegations of its own still reports a
nonzero count and queues its reaper, which then finds nothing to
recall.

Count the delegations in each namespace and report that instead.
num_delegations stays for the admission check in
__alloc_init_deleg() and the ceiling check in nfs4_laundromat().
Both compare against max_delegations, which is sized from host
memory and so remains a host-wide limit.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/netns.h     | 2 ++
 fs/nfsd/nfs4state.c | 7 ++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 71eebfea020d..bb62d19430bc 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -238,6 +238,8 @@ struct nfsd_net {
 	int			nfs4_max_clients;
 
 	atomic_t		nfsd_courtesy_clients;
+	/* per-namespace; num_delegations in nfs4state.c is host-wide */
+	atomic_long_t		nfsd_delegations;
 	struct shrinker		*nfsd_client_shrinker;
 	struct work_struct	nfsd_shrinker_work;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5c2dd6657fac..2c169bfabfbe 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1161,6 +1161,7 @@ static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
  */
 static void nfs4_free_deleg(struct nfs4_stid *stid)
 {
+	struct nfsd_net *nn = net_generic(stid->sc_client->net, nfsd_net_id);
 	struct nfs4_delegation *dp = delegstateid(stid);
 
 	WARN_ON_ONCE(!list_empty(&stid->sc_cp_list));
@@ -1171,6 +1172,7 @@ static void nfs4_free_deleg(struct nfs4_stid *stid)
 	nfsd41_cb_destroy_referring_call_list(&dp->dl_recall);
 	kmem_cache_free(deleg_slab, stid);
 	atomic_long_dec(&num_delegations);
+	atomic_long_dec(&nn->nfsd_delegations);
 }
 
 /*
@@ -1255,6 +1257,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 		   struct nfs4_clnt_odstate *odstate, u32 dl_type,
 		   void (*sc_free)(struct nfs4_stid *))
 {
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfs4_delegation *dp;
 	struct nfs4_stid *stid;
 	long n;
@@ -1263,6 +1266,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 		return NULL;
 
 	n = atomic_long_inc_return(&num_delegations);
+	atomic_long_inc(&nn->nfsd_delegations);
 	if (n < 0 || n > max_delegations)
 		goto out_dec;
 
@@ -1295,6 +1299,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 	return dp;
 out_dec:
 	atomic_long_dec(&num_delegations);
+	atomic_long_dec(&nn->nfsd_delegations);
 	return NULL;
 }
 
@@ -5564,7 +5569,7 @@ nfsd4_state_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
 
 	count = atomic_read(&nn->nfsd_courtesy_clients);
 	if (!count)
-		count = atomic_long_read(&num_delegations);
+		count = atomic_long_read(&nn->nfsd_delegations);
 	if (count)
 		queue_work(laundry_wq, &nn->nfsd_shrinker_work);
 	return (unsigned long)count;

-- 
2.54.0


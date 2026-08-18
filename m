Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AD922C0303
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015334; cv=none; b=P0EPNJmRg+znrm6u0NWr0qCku/kQaVc8oO3CUCUX6YBcLLjuCiXL/ZiKYmAO2YIc9U5FPdpIcANPumalliljy0cAhSrbc7cy6FInnTs0YwWBTsV34BMI7yCfqQ1Z6y3tutQ+i4PdAcd0JX/1Bo8VO/tchXHeHPmWQ6Ha5I2jTC0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015334; c=relaxed/simple;
	bh=fscP4V1brgbpmiXDDPnLxZykbBAKg/vArpBDuGddpX0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=lGtCKyt59HWntyXkgxDWRtitYWJ4Dbw8gvUCVGwBGeK0VCi8TcNIH2Xd8JRXxI6hGXDEL8lvfpdaUmQhA8C9mEOKE/5KiS8eFM64VHa+ENLpc2igo086lWli+njV/Z35ihCstw44VBTdQlqy+7rrzrvVSKGHH5UzrBSiEfgUSVc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cQ4unnDC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cQ4unnDC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 73F271F00AC4;
	Tue, 18 Aug 2026 01:08:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015333;
	bh=hlXM3WVAOmqf9wTtK65yVj9FPyG7IgIT2PeN095cXas=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cQ4unnDCVGQNNDTv/jkEz5bJwhSSeM02zr9J6B2a9y59+9MfpdARE2jfzgzKzX4NO
	 I8pKsMPrYVo3dcbaXA89wbZ9i04SpitbTfgW94BLPDruFfHfyp7cEfwginyCumNLU0
	 SWhj+V0Hhb1rqDoOHEkd2mtWc7x5zAQPO/aZBi50jGHuASOH4H+Yw+ZcgFScGsk5gO
	 5UHo6w7FHBzYeEpvoCbnP1YGQij+yPQ20W37xeJwx0KTfLsmUGuDHJZy9YmZ5EKGl2
	 Vw85bhuy0qjjHTgO7zLy1WQY2/qVFZXAI21ZuGja4C6L9AUQe3TZDIGU8MhOS292WU
	 bAwlipE7GoqNA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 21:08:43 -0400
Subject: [PATCH v5 8/8] NFSD: Apportion CB_RECALL_ANY recalls among clients
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-recall-any-keep-count-v5-8-3b2cffce701e@kernel.org>
References: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
In-Reply-To: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=9939; i=cel@kernel.org;
 h=from:subject:message-id; bh=fscP4V1brgbpmiXDDPnLxZykbBAKg/vArpBDuGddpX0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg7Ce+kJMq2nWuo6QdMFD7f56R+NoTN6lJ6YKL
 pISL7F3rYSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOwngAKCRAzarMzb2Z/
 l4vnEACBUBGXAwIt/umx/BthdiTI8TBAs1m32lSpcFOsBPwX4E842pnxhDsbE9o0vskhDxQDx0A
 iFk05i3yGJmVK2CQV9OpVHhN5CmzWdoL4jQ9Qj2RnkTh1Ez1DXAr/p7fMR/wp+rgFrnR8+RHj7w
 X5Gzq4LeEBRmZdEImzgDDTl66YKpYZcv8ipfKc/1CVtMnIqrw9nRonozyYRPUT/5prKjKIqqsrM
 xkDTIcExp1qW1nK8r0YhYMGKVb/d4dzGlNagd+BLFQe3XoYa70NOycyxwHjwoNOMSlbViOJt4MK
 t/tC7KkkcpH+xoM9ghPEO1D+z4bKFdZYcHHycjU7xM/Kr2t8hy/qh6bG+eI6ahigenscdIsWino
 xZnCro8/vlEi7M/K7iWjNzjclol3UQGfhXL0Zbe4yKTuzYzHbz2Th0mSGJXR8dzI8POuf2Gbg1E
 WJlOEYEADNUPs27BjeFSoruH1hqTjjIv83nRCaya2EJrCupo7X3RW0+evZ333lHS91jmVXZDBs7
 p0ktLSnm2t+PqLS2S8pRny8I3Qt7duRMdBazm17IEu95P/siHaO2b8SduEvtAfw4CFUCdsIVBHP
 RUCVtismxYwAeXWfZrKE44kFp9RsF6Y/wgaie7zBZr09wbYeYdtJMqAU9WEmpVTUyy7txyHCWNa
 sm3IMiPnVP63jwA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

deleg_reaper() asks each eligible client to return one delegation
whenever it runs, whether or not anything needs the memory. A
delegation returned before it is needed costs the client an OPEN
when it next touches the file. Nothing sizes the request either.
The delegation scan callback discards nr_to_scan, which is reclaim's
statement of how many objects it wants back.

Record each delegation scan request in nfsd_deleg_backlog and pass
the accumulated total to deleg_reaper(). Handing that total to
every client would ask for it once per client, so scale it by each
client's share of the delegations this sweep can reach. The count
callback reports what is left after the outstanding requests, so
concurrent reclaimers do not each ask for the same delegations.
cl_ra_time keeps the next sweep from returning to the clients this
one reached.

Nothing is recalled until a scan arrives. nfs4_laundromat() is the
exception. It has no scan request to pass, so it computes what must
go for num_delegations to fall below max_delegations, and passes
only this namespace's share.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/netns.h     |   3 ++
 fs/nfsd/nfs4state.c | 131 ++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 109 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 23923cc4aa47..0ce7da20aba3 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -248,6 +248,9 @@ struct nfsd_net {
 	/* courtesy scan requests the reaper has not retired yet */
 	atomic_long_t		nfsd_shrink_backlog;
 
+	/* delegation scan requests the reaper has not retired yet */
+	atomic_long_t		nfsd_deleg_backlog;
+
 	/* when deleg_reaper() last swept the client list */
 	time64_t		nfsd_last_recall_any;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1e71bb7a29c8..2d10137fa71d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -93,7 +93,7 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid);
 static void nfsd4_end_grace(struct nfsd_net *nn);
 static void _free_cpntf_state_locked(struct nfsd_net *nn, struct nfs4_cpntf_state *cps);
 static void nfsd4_file_hash_remove(struct nfs4_file *fi);
-static void deleg_reaper(struct nfsd_net *nn);
+static void deleg_reaper(struct nfsd_net *nn, unsigned long backlog);
 static void nfsd4_drop_revoked_stid(struct nfs4_stid *s)
 	__releases(&s->sc_client->cl_lock);
 
@@ -5586,7 +5586,7 @@ nfsd4_deleg_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct nfsd_net *nn = shrink->private_data;
 	time64_t elapsed;
-	long count;
+	long backlog, count;
 
 	count = atomic_long_read(&nn->nfsd_delegations);
 	if (!count)
@@ -5603,8 +5603,14 @@ nfsd4_deleg_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
 	if (elapsed < NFSD_RECALL_ANY_COOLDOWN_SECS)
 		return 0;
 
-	queue_work(laundry_wq, &nn->nfsd_deleg_work);
-	return count;
+	/*
+	 * Unlike the courtesy shrinker, this one queues no work.
+	 * Nothing is recalled until a scan request arrives. Subtract
+	 * the requests already recorded, or concurrent reclaimers
+	 * each see the whole namespace and stack a scan on top of it.
+	 */
+	backlog = atomic_long_read(&nn->nfsd_deleg_backlog);
+	return count > backlog ? count - backlog : 0;
 }
 
 static unsigned long
@@ -5628,6 +5634,7 @@ nfsd4_deleg_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct nfsd_net *nn = shrink->private_data;
 
+	atomic_long_add(sc->nr_to_scan, &nn->nfsd_deleg_backlog);
 	queue_work(laundry_wq, &nn->nfsd_deleg_work);
 
 	/*
@@ -7877,6 +7884,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	struct nfs4_cpntf_state *cps;
 	struct nfs4_client *clp;
 	copy_stateid_t *cps_t;
+	long held, host, n;
 	int i;
 
 	if (clients_still_reclaiming(nn)) {
@@ -7990,8 +7998,22 @@ nfs4_laundromat(struct nfsd_net *nn)
 	/* service the server-to-server copy delayed unmount list */
 	nfsd4_ssc_expire_umount(nn);
 #endif
-	if (atomic_long_read(&num_delegations) >= max_delegations)
-		deleg_reaper(nn);
+	/*
+	 * set_max_delegations() computes a zero max_delegations on a
+	 * server with very little memory. @host is a divisor below.
+	 */
+	host = atomic_long_read(&num_delegations);
+	if (host && host >= max_delegations) {
+		/*
+		 * max_delegations bounds the host, but the laundromat
+		 * runs once per network namespace. Requesting the whole
+		 * overage in each would multiply the request, so take
+		 * only this namespace's share.
+		 */
+		held = atomic_long_read(&nn->nfsd_delegations);
+		n = host - max_delegations + 1;
+		deleg_reaper(nn, DIV64_U64_ROUND_UP((u64)n * held, host));
+	}
 out:
 	return max_t(time64_t, lt.new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
 }
@@ -8019,27 +8041,58 @@ courtesy_client_reaper(struct nfsd_net *nn)
 	nfs4_process_client_reaplist(&reaplist);
 }
 
+/* The two passes in deleg_reaper() must agree on which clients are asked. */
+static bool
+deleg_reaper_eligible(const struct nfs4_client *clp, time64_t now)
+{
+	if (clp->cl_minorversion == 0)
+		return false;
+	if (clp->cl_state != NFSD4_ACTIVE)
+		return false;
+	if (atomic_read(&clp->cl_delegs_in_recall))
+		return false;
+	if (test_bit(NFSD4_CALLBACK_RUNNING, &clp->cl_ra->ra_cb.cb_flags))
+		return false;
+	if (now - clp->cl_ra_time < NFSD_RECALL_ANY_COOLDOWN_SECS)
+		return false;
+	if (clp->cl_cb_state != NFSD4_CB_UP)
+		return false;
+	return true;
+}
+
 static void
-deleg_reaper(struct nfsd_net *nn)
+deleg_reaper(struct nfsd_net *nn, unsigned long backlog)
 {
 	struct list_head *pos, *next;
 	struct nfs4_client *clp;
+	unsigned long remaining, share, total;
 	unsigned int count;
+	time64_t now;
+
+	/*
+	 * Recalling a delegation before it is needed costs the client
+	 * an OPEN when it next touches the file. Leave
+	 * nfsd_last_recall_any unstamped so the next sweep is not
+	 * delayed.
+	 */
+	if (!backlog)
+		return;
+	now = ktime_get_boottime_seconds();
 
 	spin_lock(&nn->client_lock);
-	list_for_each_safe(pos, next, &nn->client_lru) {
+
+	/*
+	 * Only the clients this sweep asks contribute to the
+	 * apportionment. Dividing the request among holders that are
+	 * skipped under-serves it, and the shortfall goes nowhere:
+	 * nfsd4_deleg_shrinker_worker() has already cleared
+	 * nfsd_deleg_backlog.
+	 */
+	total = 0;
+	list_for_each(pos, &nn->client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 
-		if (clp->cl_minorversion == 0)
-			continue;
-		if (clp->cl_state != NFSD4_ACTIVE)
-			continue;
-		if (atomic_read(&clp->cl_delegs_in_recall))
-			continue;
-		if (ktime_get_boottime_seconds() - clp->cl_ra_time <
-				NFSD_RECALL_ANY_COOLDOWN_SECS)
-			continue;
-		if (clp->cl_cb_state != NFSD4_CB_UP)
+		if (!deleg_reaper_eligible(clp, now))
 			continue;
 		/*
 		 * This read races with hash_delegation_locked() and
@@ -8047,6 +8100,25 @@ deleg_reaper(struct nfsd_net *nn)
 		 * count only skews the keep value; the next
 		 * laundromat pass sees a more current one.
 		 */
+		total += data_race(READ_ONCE(clp->cl_deleg_count));
+	}
+	if (!total)
+		goto out;
+
+	/*
+	 * Reclaim asks in batches and is not bound by what the count
+	 * callback reported, so the backlog can exceed what these
+	 * clients hold. Cap it to keep each share within the client's
+	 * own count.
+	 */
+	backlog = min(backlog, total);
+	remaining = backlog;
+
+	list_for_each_safe(pos, next, &nn->client_lru) {
+		clp = list_entry(pos, struct nfs4_client, cl_lru);
+
+		if (!deleg_reaper_eligible(clp, now))
+			continue;
 		count = data_race(READ_ONCE(clp->cl_deleg_count));
 		if (!count)
 			continue;
@@ -8055,26 +8127,34 @@ deleg_reaper(struct nfsd_net *nn)
 
 		/* release in nfsd4_cb_recall_any_release */
 		kref_get(&clp->cl_nfsdfs.cl_ref);
-		clp->cl_ra_time = ktime_get_boottime_seconds();
+		clp->cl_ra_time = now;
 		/*
-		 * Ask for a single delegation. Recalling one before it
-		 * is needed costs the client an OPEN when it next
-		 * touches the file.
+		 * Rounding up guarantees every holder gives up at least
+		 * one. The round-up can overshoot @backlog, so stop
+		 * once the request is met. client_lru is ordered by
+		 * last renewal, so the least active clients are asked
+		 * first.
 		 */
-		clp->cl_ra->ra_keep = count - 1;
+		share = DIV64_U64_ROUND_UP((u64)backlog * count, total);
+		share = min(share, remaining);
+		remaining -= share;
+		clp->cl_ra->ra_keep = count - share;
 		clp->cl_ra->ra_bmval[0] = BIT(RCA4_TYPE_MASK_RDATA_DLG) |
 						BIT(RCA4_TYPE_MASK_WDATA_DLG) |
 						BIT(RCA4_TYPE_MASK_DIR_DLG);
 		trace_nfsd_cb_recall_any(clp->cl_ra);
 		nfsd4_run_cb(&clp->cl_ra->ra_cb);
+		if (!remaining)
+			break;
 	}
+out:
 	spin_unlock(&nn->client_lock);
 
 	/*
 	 * Stamp the sweep even when no recall went out. A sweep that
 	 * found nothing eligible finds nothing on an immediate retry.
 	 */
-	WRITE_ONCE(nn->nfsd_last_recall_any, ktime_get_boottime_seconds());
+	WRITE_ONCE(nn->nfsd_last_recall_any, now);
 }
 
 static void
@@ -8100,7 +8180,7 @@ nfsd4_deleg_shrinker_worker(struct work_struct *work)
 	struct nfsd_net *nn = container_of(work, struct nfsd_net,
 				nfsd_deleg_work);
 
-	deleg_reaper(nn);
+	deleg_reaper(nn, atomic_long_xchg(&nn->nfsd_deleg_backlog, 0));
 }
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stid *stp)
@@ -10065,6 +10145,7 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_WORK(&nn->nfsd_courtesy_work, nfsd4_courtesy_shrinker_worker);
 	INIT_WORK(&nn->nfsd_deleg_work, nfsd4_deleg_shrinker_worker);
 	atomic_long_set(&nn->nfsd_shrink_backlog, 0);
+	atomic_long_set(&nn->nfsd_deleg_backlog, 0);
 	nn->nfsd_last_recall_any = 0;
 	get_net(net);
 

-- 
2.54.0


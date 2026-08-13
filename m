Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9584D485CF2
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646456; cv=none; b=CNh7By5JVBTNq3Ka7sTQWaVF3VSH47Q4EvgcXGiYa7poq0d1Q1z1x+dWZBMe0qmNJSiRtDek6Afu2UYN8N7B1KZh5CbBFwzCdxWwdV0UUgOv/erAeP5R5ZgCbL3ugIPEz1z7EVUHmkX+SpMovxK29uCRNOtiTK0GoPTc5Esf/Nc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646456; c=relaxed/simple;
	bh=qZyMi60jKJ0l5Vn+mbu3XiSM81rI/nB+GqWct0x8EQE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=QKY8SY5igrb1Layrfoq8wn4C5Az7WTX1cHqa2Feq7MSjQdPM6PrNmDCLjpG+3QqvN6/hF/M4Ru7cGOfB+crHjKJX5AeKfEUZRmPyLlwSNpuMpnU1+BoqAq+t6rKafOIHsRzw8urXT+SG1FC+2kYrOqOKSg7kfzir13b9hdhS25Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OQ992gdT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OQ992gdT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EC95C1F00A3E;
	Thu, 13 Aug 2026 18:40:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646455;
	bh=gcKeAb//cApTIHGcdm0bxgAFed+Rems4UFuw3e6V8Xc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OQ992gdTvlEzj2l6jLdvG00yWrrO1BnLPrgl0h9PiFa0U9f0afTOZrt/5BtDSZHs8
	 IQWBvnLaDvE4VqdBIO6OTS6Gnpzku7ZkXigGN67oaN/ezzX+UNg7AVx3YyicG6zXu/
	 BhEU02VC8mvmJL6++Si1bzrTmlE4GSlLIRwS00EXih95iORKEzXp1QcyVtZVU7B9ZL
	 yGrH56AOA3Etiqmox2NTzxrumQpVybXx09sauUJ0S6ktSdGu7a9uxztgKfnsb1HA9q
	 t6QpFhL0asXfGC8XpmJvdfYYDK0ER/F9fD1MMFNecuGXl41csHuLwTdfA1I3PevZNl
	 CcAnu6+fl/Yaw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 13 Aug 2026 14:40:36 -0400
Subject: [PATCH v3 7/8] NFSD: Pace the state shrinker's scan requests
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260813-recall-any-keep-count-v3-7-a96d243c0b13@kernel.org>
References: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
In-Reply-To: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=7253; i=cel@kernel.org;
 h=from:subject:message-id; bh=qZyMi60jKJ0l5Vn+mbu3XiSM81rI/nB+GqWct0x8EQE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfg+xn0YT2catT4qDSTkqlsmVZDQWLRl53sbTI
 atxhWYeTYaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCan4PsQAKCRAzarMzb2Z/
 l5okD/oD0AMGqYuOCkL86Xpfxb4hJwboCstYdiIAIz8GdYagkwtKXqLmkCtN1G0AXDuNbfhLstG
 kYUNWGGDCUEAXRuE19901a37M7TiEla5UOUpU2azz0A9CpSvODqnHhT01CmfqHtTE0+thupW3d2
 gZZRM+zwF3N3sUT4n6a8NBaFr0GWev/WIEuhLS5UgAEv6z1xn1tKOxNzJMOq+MpUQh6WSAoByeW
 a0E67eLYf08GpxsoFyxIAP6ZLljHdukHj31T+1yskUHB3eVKUoTknkpMjl5Ati0U6qvVli+880D
 DqH9X02FKF4Mn6kA+/aeyTA6J/i6mKrN6h+Yv0LBZOdCXZbhOIk7386JqyLpy3++tMepyOTWCwx
 WK4fMM8Wfby2nHdGsKstYR0hbk4TQjtZXTe1Zz5BWhWjQegynCRvm3oGvoFoAKTn4pt6wXEAhwj
 agka74/x1au66STHkHfN4mtTFGsXBVQNMvQaWzbQEcLrCmx+ILZRACIqKJQ/+11vuvRIhZwjjwo
 SIU6hrhekOXoYXbC9VwWxsLDUTuOxQrX9oMt74AKOMyH3fyQK4iyHiHCf+H+UtU6BgK6gmRZQjf
 DI9xbU0WwrwcrPx1JoaFMCK6drJWcIQcZAF9z2OdLV7FRZxyPgY6YLK7RwWGp6rq8hIW/BIEWJD
 43zx3aBfVZAeS7Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Currently, neither of the scan callback functions records anything
before returning SHRINK_STOP, so the size of each scan request is
discarded. That size is the only real measure NFSD gets of reclaim
pressure. Both count callbacks report their population whether or
not the reaper is already queued to reclaim it, so reclaim asks
again for work that is pending.

Accumulate each courtesy scan request in nfsd_shrink_backlog and
subtract the backlog from what that count callback reports. The
worker retires the backlog once courtesy_client_reaper() has run.
That reaper expires the clients synchronously, so the discount
covers exactly the interval the work is pending.

Delegations need a different bound. This is because deleg_reaper()
only sends CB_RECALL_ANY and does not track how many delegations
were actually returned by the targeted client.

Report the delegations only once NFSD_RECALL_ANY_COOLDOWN_SECS have
passed since the last sweep. deleg_reaper() skips any client it
recalled from within that window, so an earlier scan request cannot
produce another recall.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/netns.h     |  6 ++++
 fs/nfsd/nfs4state.c | 92 +++++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 85 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index ef01a1cf72ac..23923cc4aa47 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -245,6 +245,12 @@ struct nfsd_net {
 	struct work_struct	nfsd_courtesy_work;
 	struct work_struct	nfsd_deleg_work;
 
+	/* courtesy scan requests the reaper has not retired yet */
+	atomic_long_t		nfsd_shrink_backlog;
+
+	/* when deleg_reaper() last swept the client list */
+	time64_t		nfsd_last_recall_any;
+
 	/* last time an admin-revoke happened for NFSv4.0 */
 	time64_t		nfs40_last_revoke;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d38fccb42e61..2b3056ffe08c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5563,41 +5563,88 @@ nfsd4_init_slabs(void)
 	return -ENOMEM;
 }
 
+#define NFSD_RECALL_ANY_COOLDOWN_SECS	5
+
 static unsigned long
 nfsd4_courtesy_shrinker_count(struct shrinker *shrink,
 			      struct shrink_control *sc)
 {
 	struct nfsd_net *nn = shrink->private_data;
-	long count;
+	long backlog, count;
 
 	count = atomic_read(&nn->nfsd_courtesy_clients);
-	if (count)
-		queue_work(laundry_wq, &nn->nfsd_courtesy_work);
-	return (unsigned long)count;
+	if (!count)
+		return 0;
+
+	queue_work(laundry_wq, &nn->nfsd_courtesy_work);
+
+	/* Work already queued is not available to reclaim again. */
+	backlog = atomic_long_read(&nn->nfsd_shrink_backlog);
+	return count > backlog ? count - backlog : 0;
 }
 
 static unsigned long
 nfsd4_deleg_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct nfsd_net *nn = shrink->private_data;
+	time64_t elapsed;
 	long count;
 
 	count = atomic_long_read(&nn->nfsd_delegations);
-	if (count)
-		queue_work(laundry_wq, &nn->nfsd_deleg_work);
-	return (unsigned long)count;
+	if (!count)
+		return 0;
+
+	/*
+	 * Delegations the last sweep reached stay unreclaimable until
+	 * deleg_reaper()'s cooldown expires. CB_RECALL_ANY leaves the
+	 * choice of delegations to the client, so there is no return
+	 * to wait on instead.
+	 */
+	elapsed = ktime_get_boottime_seconds() -
+			READ_ONCE(nn->nfsd_last_recall_any);
+	if (elapsed < NFSD_RECALL_ANY_COOLDOWN_SECS)
+		return 0;
+
+	queue_work(laundry_wq, &nn->nfsd_deleg_work);
+	return count;
 }
 
 static unsigned long
-nfsd4_state_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
+nfsd4_courtesy_shrinker_scan(struct shrinker *shrink,
+			     struct shrink_control *sc)
 {
+	struct nfsd_net *nn = shrink->private_data;
+
+	atomic_long_add(sc->nr_to_scan, &nn->nfsd_shrink_backlog);
+	queue_work(laundry_wq, &nn->nfsd_courtesy_work);
+
+	/*
+	 * The reaper runs from laundry_wq. Report no progress rather
+	 * than claim memory that is not free yet.
+	 */
+	return SHRINK_STOP;
+}
+
+static unsigned long
+nfsd4_deleg_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
+{
+	struct nfsd_net *nn = shrink->private_data;
+
+	queue_work(laundry_wq, &nn->nfsd_deleg_work);
+
+	/*
+	 * The reaper sends CB_RECALL_ANY, so nothing is free when
+	 * this returns.
+	 */
 	return SHRINK_STOP;
 }
 
 static struct shrinker *
 nfsd4_alloc_state_shrinker(struct nfsd_net *nn, const char *name,
 			   unsigned long (*count)(struct shrinker *,
-						  struct shrink_control *))
+						  struct shrink_control *),
+			   unsigned long (*scan)(struct shrinker *,
+						 struct shrink_control *))
 {
 	struct shrinker *shrink;
 
@@ -5606,7 +5653,7 @@ nfsd4_alloc_state_shrinker(struct nfsd_net *nn, const char *name,
 		return NULL;
 
 	shrink->count_objects = count;
-	shrink->scan_objects = nfsd4_state_shrinker_scan;
+	shrink->scan_objects = scan;
 	shrink->private_data = nn;
 
 	shrinker_register(shrink);
@@ -7991,7 +8038,8 @@ deleg_reaper(struct nfsd_net *nn)
 			continue;
 		if (atomic_read(&clp->cl_delegs_in_recall))
 			continue;
-		if (ktime_get_boottime_seconds() - clp->cl_ra_time < 5)
+		if (ktime_get_boottime_seconds() - clp->cl_ra_time <
+				NFSD_RECALL_ANY_COOLDOWN_SECS)
 			continue;
 		if (clp->cl_cb_state != NFSD4_CB_UP)
 			continue;
@@ -8023,6 +8071,12 @@ deleg_reaper(struct nfsd_net *nn)
 		nfsd4_run_cb(&clp->cl_ra->ra_cb);
 	}
 	spin_unlock(&nn->client_lock);
+
+	/*
+	 * Stamp the sweep even when no recall went out. A sweep that
+	 * found nothing eligible finds nothing on an immediate retry.
+	 */
+	WRITE_ONCE(nn->nfsd_last_recall_any, ktime_get_boottime_seconds());
 }
 
 static void
@@ -8030,8 +8084,16 @@ nfsd4_courtesy_shrinker_worker(struct work_struct *work)
 {
 	struct nfsd_net *nn = container_of(work, struct nfsd_net,
 				nfsd_courtesy_work);
+	long backlog;
 
+	/*
+	 * Retire only the requests sampled here, so that requests
+	 * arriving while the reaper runs are still discounted by
+	 * nfsd4_courtesy_shrinker_count().
+	 */
+	backlog = atomic_long_read(&nn->nfsd_shrink_backlog);
 	courtesy_client_reaper(nn);
+	atomic_long_sub(backlog, &nn->nfsd_shrink_backlog);
 }
 
 static void
@@ -10004,17 +10066,21 @@ static int nfs4_state_create_net(struct net *net)
 	disable_delayed_work(&nn->laundromat_work);
 	INIT_WORK(&nn->nfsd_courtesy_work, nfsd4_courtesy_shrinker_worker);
 	INIT_WORK(&nn->nfsd_deleg_work, nfsd4_deleg_shrinker_worker);
+	atomic_long_set(&nn->nfsd_shrink_backlog, 0);
+	nn->nfsd_last_recall_any = 0;
 	get_net(net);
 
 	nn->nfsd_courtesy_shrinker =
 		nfsd4_alloc_state_shrinker(nn, "nfsd-courtesy",
-					   nfsd4_courtesy_shrinker_count);
+					   nfsd4_courtesy_shrinker_count,
+					   nfsd4_courtesy_shrinker_scan);
 	if (!nn->nfsd_courtesy_shrinker)
 		goto err_shrinker;
 
 	nn->nfsd_deleg_shrinker =
 		nfsd4_alloc_state_shrinker(nn, "nfsd-delegation",
-					   nfsd4_deleg_shrinker_count);
+					   nfsd4_deleg_shrinker_count,
+					   nfsd4_deleg_shrinker_scan);
 	if (!nn->nfsd_deleg_shrinker)
 		goto err_deleg_shrinker;
 

-- 
2.54.0


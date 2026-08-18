Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9221B21CC5C
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015333; cv=none; b=aaeyg5eN6C7UUeO3IJZeYRjQP5esg7ydY9+9Rj+ckVhjsjszMB2KYH5W5yzUG61YfQtmc/gjr9xlmAsV9OlqAz0DHdVeZ8MieUmF5gPxJvaq53ZIJklU8vAhJOY+kHTfxEt+fQeLdz03HY564XrRnSIvKseqVx2ciG1C+m+wbSo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015333; c=relaxed/simple;
	bh=2lvR+c2siVB3fe7roDMEx7YaIFbmhaq82QX20NrJGAc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Bf3olhoWmu8qTCwue9vATIRds9vc/XDZgXdPKXMJNUcB5uYiKW1HGnDAbx9LNOlJo3dHguV79rrhOKBuxEvW7K76FYqdOhupBWmhVKZFncWo8eEipdDzdKYOB3jI8ODM6kwnxyHTQR1KQU/0lYF8LosFlNah0aZCNbLZF3627Hg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TWCX4Yb3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TWCX4Yb3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A2DAB1F00A3F;
	Tue, 18 Aug 2026 01:08:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015332;
	bh=wbvwrUHA/k3wZ6aV4pBeVnzzDQzjmUmrUSpVVa0+KAs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TWCX4Yb3B+Nq9h+3ZduhwEhyzMrWH3oWwOkR716u0orI03KdpVsT4eXuoJU0MG+w4
	 WzcL/1IyX9TZhdW6EeUIHmm9XwnjjelO8jh6+1xz0DXLsizqbIq4tDGYOTmxFW0ofA
	 mYy87hqBqEEJWc5hPlecv1VXsD4xfYxmCTxxWNgC1COduXCDm14kRvWt22km7QD6RX
	 UzpH98iTDCHjDrFDmQn0gFX8/5AA2Ydod6iuhf1qC/jbNEnTBsKn3M9TEu+dGLBo1T
	 OyBbehRqS2k+nRyc5O0Q7NMYkhGZQvG0teTH5Kk4USlj86ZUHqA+h68JckoqYyMXKb
	 gFxrN+7gJeeOA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 21:08:42 -0400
Subject: [PATCH v5 7/8] NFSD: Pace the state shrinker's scan requests
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-recall-any-keep-count-v5-7-3b2cffce701e@kernel.org>
References: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
In-Reply-To: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=7300; i=cel@kernel.org;
 h=from:subject:message-id; bh=2lvR+c2siVB3fe7roDMEx7YaIFbmhaq82QX20NrJGAc=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGqDsJ3IBPiAvHBhdFXgI5qCGNBUd4fZak9NBh6K9bQrVWSA6
 4kCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJqg7CdAAoJEDNqszNvZn+X0DgQAISg
 nGtiXn8SUC4gp+YTaIwPwpIuuM3V2vVuY5TqdhrebJLMnuqb42ORLuZWh+VNFTn3F3MKcR7tS8l
 wCjN7x/5TTBTeD+S29XRqJOJA7BDAPvj18/HKYZp4AblhbZeQcJKZAIgiUxzmauI1ZeFdM8P4f8
 dgIgk2T3cEJ4J+BU8cmzlaFi1TqQgy5ec3YJR7ea5j6ZFZtdDfOWwzg5G7BVWwIHK4HnkzUSfag
 kUBrKgss6LDG9+95fOxlna48zHbsVvVitXxALseifa2mgah4pfort4VFQrrGS+eDvD/BqHfYXdM
 yYDKib+XDvgBzwhVYzNsxeHZmW3tm+TPdTCaNsJ8YBb02VaT4CEw3SkeL04WjvOf/jYdIqhi+YG
 QaRd5WcqtRg7gmv46yz5xEEgdOWeU/VDLJ3rgY/q2I17wFvi/0ztVIljkmwcHvG3Zht+6S7PkwT
 1clYlNmkxHIq76rwoaKfnv0LwpGrnGawBcRoNV5Ojs2jUzWsyWchQ0m5eikRbxsVWkN1/+uaAdr
 4q49UdbFPoS6Z5/Jp98QwSbZXmrUcDiWurdFqx+uoSB0TBmCkp36EVFZxRWQDlaBV6pua9N6V3j
 KVkxYhTQEfodw25VgMFyaF+1f/ki++Sq6c5XBZCSBNL+lETnnUAA7nP8jx/SjEJI2gZ9qoYhqoY
 rdnf4
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
Reviewed-by: Jeff Layton <jlayton@kernel.org>
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
index 2dbc49a6dcaa..1e71bb7a29c8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5561,41 +5561,88 @@ nfsd4_init_slabs(void)
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
 
@@ -5604,7 +5651,7 @@ nfsd4_alloc_state_shrinker(struct nfsd_net *nn, const char *name,
 		return NULL;
 
 	shrink->count_objects = count;
-	shrink->scan_objects = nfsd4_state_shrinker_scan;
+	shrink->scan_objects = scan;
 	shrink->private_data = nn;
 
 	shrinker_register(shrink);
@@ -7989,7 +8036,8 @@ deleg_reaper(struct nfsd_net *nn)
 			continue;
 		if (atomic_read(&clp->cl_delegs_in_recall))
 			continue;
-		if (ktime_get_boottime_seconds() - clp->cl_ra_time < 5)
+		if (ktime_get_boottime_seconds() - clp->cl_ra_time <
+				NFSD_RECALL_ANY_COOLDOWN_SECS)
 			continue;
 		if (clp->cl_cb_state != NFSD4_CB_UP)
 			continue;
@@ -8021,6 +8069,12 @@ deleg_reaper(struct nfsd_net *nn)
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
@@ -8028,8 +8082,16 @@ nfsd4_courtesy_shrinker_worker(struct work_struct *work)
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
@@ -10002,17 +10064,21 @@ static int nfs4_state_create_net(struct net *net)
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


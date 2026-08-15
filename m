Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B99FD424D75
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 16:39:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811945; cv=none; b=a6K0uRZVVkctZrw0HKiZm70QCc3DIFvijUiHFec4yIze6WYdnx9TISXPDX2upovwswXqwCC/c2bT9aB51z/MFv+GB/AZ5Jw7KwdO9/t4umk+hfy58SKM4wPTQQB/glBWVLYOvig7oeOgy+uNKrcrerXQYnC2tP2PZTYMLrBYVBI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811945; c=relaxed/simple;
	bh=oMoS8c4l1yoGMgOEiGPYo5oy00J44zIwmenHClzUOA8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=k41OWPnbHfCLLC2563FRovaIowit1EB54ahtPEHWX9zjgK+/rb80Y6GCvDg7aw51K3Yh2l8AkHaqJFoffZJMX4Qpw1wrVClpq4z+124Oe9wmpuG3sBlsBbYMLgNNYCxt18hE2ycj/mEFWL8xzu3fOsxU8iYflSorZVVkH8r6cj8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E9Mv4Oqx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E9Mv4Oqx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 256AF1F00A3A;
	Sat, 15 Aug 2026 16:39:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811943;
	bh=lQzJCuZ4HsspDsRIJ+VsiUwvWmC7M1Q+o3RLp2oCtEI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E9Mv4Oqxx6FV3CWksTDskZF2RbUBWaCrZ+++c2LS3Ppg6FOP1k19MaMRFQLgkl2Qh
	 1pIrcBp3kaD/Don5w4Nxct7vqSd4wAmG655xY1HQy/znyvjxVZ5HtGXOLw1Y517kT/
	 L7kBhixOR2wH3CMJ7iHcJ9wnutfBztiGsl6CZptQ+q5eXJIiFUf0uk9ombZRwRtNpq
	 Fv0CSNqSSExMMArDifcIIPlP2fcA9Bex1ygdlMj25men+RulRKFV/n/FDw97PGq6sc
	 eFanoonQqpp7UzdsPwOcXuY4U/Gd9aAqbhhwo99irySiS9E5/3zBzn6fK2pK944dbQ
	 NIvUF8JXqYOaQ==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 15 Aug 2026 12:38:54 -0400
Subject: [PATCH v4 6/8] NFSD: Give delegations their own state shrinker
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260815-recall-any-keep-count-v4-6-bfb5b83d6cb1@kernel.org>
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
In-Reply-To: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6204; i=cel@kernel.org;
 h=from:subject:message-id; bh=oMoS8c4l1yoGMgOEiGPYo5oy00J44zIwmenHClzUOA8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqgJYimM37xwAuHH5iWVHTlwxhG6IFr7gkforHd
 l5FmB5KY5uJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoCWIgAKCRAzarMzb2Z/
 l57gD/wPNXMi26SxvhOE9Y4b1DP3XU5vwnSFHEkF/rSEv5xp3LJjxcMO73bALsiZYRoCCxfjzCD
 MPYPsxel8+Q92CG90gOmduugtsuWkgRQPGSncn3NaWn4wyWpLgebYu2dPfDZYsZlPrWYpzlwsv/
 o/pnRZDGusB0Q+DGgqurhizpafAeFUB55pDF28UpVRXnElPuoDDYSfZG7x8NKnrifuKLFsFf2+X
 324MOkFzRvJryKdAWinZKb7494CdlKLGAyKRc12DiZkE1qlKkbXP3+LJ5IsIzeFA/hc+BmlBjKd
 SSW1MeRwjANiXwxzdqZQiLEmFH7TcE3VMM+g5e0RESF2R5rRRHiJPg+ySM7iy9p+8Jlt1OsJVP8
 Jdn5Y4JjmTtAz6iVu33cZKLykmIPaWh+wjAib76hqxbaC1Fr4t24/Gr5aujQM4f2+OjXdLtHho7
 V9toHaQV/sg177d/DU3rWtgKTbxKBLDMfWckcuIIxZJoicosGU5DKY2l0WYxV7zxbP5YO0ioZwA
 ZcF6jNW+C8oyoXNb5bnGyW98fAAHXlLbNJhbGqAVVipNaDNuaRok4zuRbYeqofh/hJtG1AReJnM
 6Yt1QPGReU2uxOR8PgwcIkflz5EvAeLTPS4ijzBlkxS7LYfU3uKBOJC2A4JnqrgDFZukVGTVWVQ
 ov14+qBbh8M0r3w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Since commit 44df6f439a17 ("NFSD: add delegation reaper to react to
low memory condition"), nfsd_client_shrinker has managed two
unrelated populations of objects.

One population is courtesy clients. Shrinking that population can
be done synchronously and without risk of deadlock. The shrinker
callback could return a precise count of the number of objects
that were released.

The other population is delegations. Shrinking that population
requires sending a CB_RECALL_ANY; clients are not obligated to
return any delegation. The shrinker callback is structurally
unable to report progress.

What's more, the single shrinker callback falls back to
delegation reaping only when there are no courtesy clients left to
reclaim. A single courtesy client is enough to keep a namespace's
delegations out of the count it reports.

To begin to resolve these issues, refactor the existing state
shrinker into two: one for courtesy clients and one for reaping
delegations. Each manages the size of its own population, and the
shrinker names become namespace-specific.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/netns.h     |  6 +++--
 fs/nfsd/nfs4state.c | 77 ++++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 65 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index bb62d19430bc..ef01a1cf72ac 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -240,8 +240,10 @@ struct nfsd_net {
 	atomic_t		nfsd_courtesy_clients;
 	/* per-namespace; num_delegations in nfs4state.c is host-wide */
 	atomic_long_t		nfsd_delegations;
-	struct shrinker		*nfsd_client_shrinker;
-	struct work_struct	nfsd_shrinker_work;
+	struct shrinker		*nfsd_courtesy_shrinker;
+	struct shrinker		*nfsd_deleg_shrinker;
+	struct work_struct	nfsd_courtesy_work;
+	struct work_struct	nfsd_deleg_work;
 
 	/* last time an admin-revoke happened for NFSv4.0 */
 	time64_t		nfs40_last_revoke;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2c169bfabfbe..2dbc49a6dcaa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5562,16 +5562,27 @@ nfsd4_init_slabs(void)
 }
 
 static unsigned long
-nfsd4_state_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
+nfsd4_courtesy_shrinker_count(struct shrinker *shrink,
+			      struct shrink_control *sc)
 {
 	struct nfsd_net *nn = shrink->private_data;
 	long count;
 
 	count = atomic_read(&nn->nfsd_courtesy_clients);
-	if (!count)
-		count = atomic_long_read(&nn->nfsd_delegations);
 	if (count)
-		queue_work(laundry_wq, &nn->nfsd_shrinker_work);
+		queue_work(laundry_wq, &nn->nfsd_courtesy_work);
+	return (unsigned long)count;
+}
+
+static unsigned long
+nfsd4_deleg_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
+{
+	struct nfsd_net *nn = shrink->private_data;
+	long count;
+
+	count = atomic_long_read(&nn->nfsd_delegations);
+	if (count)
+		queue_work(laundry_wq, &nn->nfsd_deleg_work);
 	return (unsigned long)count;
 }
 
@@ -5581,6 +5592,25 @@ nfsd4_state_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
 	return SHRINK_STOP;
 }
 
+static struct shrinker *
+nfsd4_alloc_state_shrinker(struct nfsd_net *nn, const char *name,
+			   unsigned long (*count)(struct shrinker *,
+						  struct shrink_control *))
+{
+	struct shrinker *shrink;
+
+	shrink = shrinker_alloc(0, "%s:%s", name, nn->nfsd_name);
+	if (!shrink)
+		return NULL;
+
+	shrink->count_objects = count;
+	shrink->scan_objects = nfsd4_state_shrinker_scan;
+	shrink->private_data = nn;
+
+	shrinker_register(shrink);
+	return shrink;
+}
+
 void
 nfsd4_init_leases_net(struct nfsd_net *nn)
 {
@@ -7994,12 +8024,20 @@ deleg_reaper(struct nfsd_net *nn)
 }
 
 static void
-nfsd4_state_shrinker_worker(struct work_struct *work)
+nfsd4_courtesy_shrinker_worker(struct work_struct *work)
 {
 	struct nfsd_net *nn = container_of(work, struct nfsd_net,
-				nfsd_shrinker_work);
+				nfsd_courtesy_work);
 
 	courtesy_client_reaper(nn);
+}
+
+static void
+nfsd4_deleg_shrinker_worker(struct work_struct *work)
+{
+	struct nfsd_net *nn = container_of(work, struct nfsd_net,
+				nfsd_deleg_work);
+
 	deleg_reaper(nn);
 }
 
@@ -9962,21 +10000,26 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_DELAYED_WORK(&nn->laundromat_work, laundromat_main);
 	/* Make sure this cannot run until client tracking is initialised */
 	disable_delayed_work(&nn->laundromat_work);
-	INIT_WORK(&nn->nfsd_shrinker_work, nfsd4_state_shrinker_worker);
+	INIT_WORK(&nn->nfsd_courtesy_work, nfsd4_courtesy_shrinker_worker);
+	INIT_WORK(&nn->nfsd_deleg_work, nfsd4_deleg_shrinker_worker);
 	get_net(net);
 
-	nn->nfsd_client_shrinker = shrinker_alloc(0, "nfsd-client");
-	if (!nn->nfsd_client_shrinker)
+	nn->nfsd_courtesy_shrinker =
+		nfsd4_alloc_state_shrinker(nn, "nfsd-courtesy",
+					   nfsd4_courtesy_shrinker_count);
+	if (!nn->nfsd_courtesy_shrinker)
 		goto err_shrinker;
 
-	nn->nfsd_client_shrinker->scan_objects = nfsd4_state_shrinker_scan;
-	nn->nfsd_client_shrinker->count_objects = nfsd4_state_shrinker_count;
-	nn->nfsd_client_shrinker->private_data = nn;
-
-	shrinker_register(nn->nfsd_client_shrinker);
+	nn->nfsd_deleg_shrinker =
+		nfsd4_alloc_state_shrinker(nn, "nfsd-delegation",
+					   nfsd4_deleg_shrinker_count);
+	if (!nn->nfsd_deleg_shrinker)
+		goto err_deleg_shrinker;
 
 	return 0;
 
+err_deleg_shrinker:
+	shrinker_free(nn->nfsd_courtesy_shrinker);
 err_shrinker:
 	put_net(net);
 	kfree(nn->sessionid_hashtbl);
@@ -10077,8 +10120,10 @@ nfs4_state_shutdown_net(struct net *net)
 	struct list_head *pos, *next, reaplist;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	shrinker_free(nn->nfsd_client_shrinker);
-	cancel_work_sync(&nn->nfsd_shrinker_work);
+	shrinker_free(nn->nfsd_courtesy_shrinker);
+	shrinker_free(nn->nfsd_deleg_shrinker);
+	cancel_work_sync(&nn->nfsd_courtesy_work);
+	cancel_work_sync(&nn->nfsd_deleg_work);
 	disable_delayed_work_sync(&nn->laundromat_work);
 	locks_end_grace(&nn->nfsd4_manager);
 

-- 
2.54.0


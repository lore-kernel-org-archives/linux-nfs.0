Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EF892E7387
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015332; cv=none; b=dKpRmNmXDebC8/FlhElA7o0r0RFM3CLkFz3FiLlbzQBKyhOl1WtSSKqjr00Nfa+UwJBQWe8ssltVJY/6lQbu+ovRrAiCOE5Lm0D4++Ab6gbmSSK+c/4Eg0mbalgi6UT0dOPvgOMCCwIJQ728AO3I/GPKAjuNnJe7VV9ZwdJ7TwI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015332; c=relaxed/simple;
	bh=oMoS8c4l1yoGMgOEiGPYo5oy00J44zIwmenHClzUOA8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=MTpMm/6MCo/TQGJiYJxKAPCyA+zAfKDwki1jhEnVpLpyuyHexSzze9lMZQvbv0+IUSUZgm7JDQHxveyuR1VR/xHWn0/BJtvynxohAi94H78yyOU7owSjiXI0MGUE6nSG566pDxMz5/Grdq99ct1YFGjyTnCRUuT7PQ4dQmq1N+M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fr30Te1L; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fr30Te1L"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D98C01F00A3A;
	Tue, 18 Aug 2026 01:08:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015331;
	bh=lQzJCuZ4HsspDsRIJ+VsiUwvWmC7M1Q+o3RLp2oCtEI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fr30Te1LP+O1i6CNeC+cLTZcNg5P8pzni+FdcAmPPhIC1ja4yGsINz85Vl46b7LNW
	 oLpKQkf4FIeqjTUSDrrlBYRvjDpOMqjXQZ/Cyoio+r5HThAiYiqFD8er3pYOP4rAFr
	 yAJ5GBhEMViYA3fpwpi0lF0T31mKviK5pBo6q1158fYmJahUf/84p4dzcb3xvrvdUR
	 oIrh41UjnDVKASMMPu8KVGHo2xLzZTA/Wcd97idx06yznXteR2HcNYM/b6PZm254NY
	 XyOB/nyMafmICUP8wfidYkJTj5NByNM95qV/LX0eRUndi5+Y84XbFxYW6ThNjFDGx9
	 Q2k9fX7jaTbFQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 21:08:41 -0400
Subject: [PATCH v5 6/8] NFSD: Give delegations their own state shrinker
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-recall-any-keep-count-v5-6-3b2cffce701e@kernel.org>
References: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
In-Reply-To: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6204; i=cel@kernel.org;
 h=from:subject:message-id; bh=oMoS8c4l1yoGMgOEiGPYo5oy00J44zIwmenHClzUOA8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg7CdnxFELybNURKnjhKRfjSNycVPKFDexysOD
 Ak5irBw5Y+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOwnQAKCRAzarMzb2Z/
 lxxgD/9JGtLBSZe7gYL4B6iX0DDNWc3DurkngKJA7ZfFjZF41NBK1j9+XGdZU6agCi3q9HzbkwJ
 lnmw3zHrBQHRN52m7wfyU826eyq6O2SsTXjcdFPJavYJpKzogweag39C5847x1dMKz5Fdtsj5Z1
 AJSbHFZ/52YcukW1LFRaVKhlx1CsFqugB+yz7xDJt/aDKQQxrtMWHLUh0nP0DmZwmvjT4Uvy+9n
 i8cw6d4StfhqqSQmVIkJYK6Q1ps/Q+7bXh4VAKePx2w4V9OOEGWQbEiS5kIoiaF/Gq0nwPvA3St
 UEugT5i2q6a2NqmybbRLDi5/0IYvRABqI98nYgBQQbA5VeDnU3HnVoeJM3EQoqL0SCnPYXhd60t
 AbxoJnBVSwRmM8jcFHbeS9pRqkwL2BZ6n/EOpRj01t3yOznOpJoJMwm+PuQFUiWjXW2iv0/vSs9
 /AceTz6lr7IE/FfvJ1AxTJK8tR0vPtpPzdgYC9iT3mSeLMCslA7/+z1aL845ZCbVt9kfCZuM5AJ
 DnN5WpSZgsFJZDDsHPFHs8DMA7QkOtsAVi6EOpDw6rx55yTqGeDyqtPyuLJO75BssdclYai49qz
 sEoh/eo8y2/XsCE23CMiiw0wjKFr5JvPwPJ6YtUsLnVTpUXSKh2zPGkrBJyTTnixiWSK9AhP1g8
 unn13z7awuOf5hw==
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


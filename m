Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA4E448425A
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646456; cv=none; b=C/koOCowHwBekpr7iWvwpTwwzyf9mD1HG9ACb7T29NyQMeyUqNNH3c8HGwuozd8vLAHfQhuUtgmiYRWOas/dsK+QzVKehQ7nRQRpKCyfrY0ucb6dURne7Iecqfjhhq8lfgc25Kj5Qo46YvU9ipOnTBqqwOng8L3SLinZl5fPHEc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646456; c=relaxed/simple;
	bh=GwQ/DGoePjGx7R/tMlONFlADTnKCq8hY6X/KcV7zltk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=qwF77Jvgilh3g9NhfW+2Vs03+2Dn/eZCifOVCsOmP7MtV4yHWnG/aVjfhFNQvgglreSyL4VAK7yDYdJJT+LcNSnUycIabJuiC0x7GjCmbsc/xnw7+YgYOTBK5D6b7R5xh0eY+yINbuvJ+q+Fjmi7QmVoMuooZRRaKqItpPE6Zi8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=H5knb9E/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="H5knb9E/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E1A41F000E9;
	Thu, 13 Aug 2026 18:40:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646454;
	bh=Y372niizHeFWiBC5soq1Ar2mSGfI9Tl4XJnEJIPz0SM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=H5knb9E/nz2FZWLCoeEbOUw0c7n39enxTQEMXrBI4mo4c1j/LCPUSqksDng3fS3dc
	 W3DWw9TM9sDUUYeaxR4YNknFqB4nei5A77gbUYkTIy5r34+BJkq/osm3qRQSfj4SLW
	 /+h+/QKFDfN9zoF1R1tZRBMzbgVchHLCB66MP+L/45Olo/5t4d8sXb7O9iLSzVr2wt
	 EnCXzLTgh5lCtKcjoLCS35+kN95cAIEu7yz/6QgQcQkIbCjJVIiMtO0te9/uHwlmkN
	 xWYUUNx2rvZDTfdDSA5mxe2hocU2DddR//PKfYOysXO1P6jbEu0szmS0oQhpsFcXfl
	 NxsjqrOdgpjCg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 13 Aug 2026 14:40:35 -0400
Subject: [PATCH v3 6/8] NFSD: Give delegations their own state shrinker
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260813-recall-any-keep-count-v3-6-a96d243c0b13@kernel.org>
References: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
In-Reply-To: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6157; i=cel@kernel.org;
 h=from:subject:message-id; bh=GwQ/DGoePjGx7R/tMlONFlADTnKCq8hY6X/KcV7zltk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfg+xR03ozjvJZiAbJxWtAgEpW2RKXnqrkQaIm
 TsRm5b1nIGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCan4PsQAKCRAzarMzb2Z/
 lxhIEAC3rN5XHAlv8vvztSwuaTm3B59PXjgjnsquhpthOdUf8pf5oicFt1pRAinQoq7thHbpDC9
 ANVb5q+iuadGn7l8VtLtux91QXMaB52J2fOLr89V/wPlG+iCWJm5KBzhi1AUT3rq1W6ttgZw713
 GwBkObceocckgGsnL83vvlvKROCfNdPQ6Yn1OPW4tL3Hkvj5XMLFTmyZHRoE+te0jbeFzXZkJLy
 P34lsMH9vnXK+F6PBMogPR2y/zmbjaKR9QihaUDmhMe0oXhz+t2SqMXp0dfhOYbeFlHzjaNmYLL
 UrbAjx+wclCAph/8NyxwN3lt16nvhWVBIRpXcF603okKGM8HYXD0IFKX1pNYH3pLdoZSTCvJ6VM
 ph4jSXk28wrf2DmU6H34HCrGoYmh3k/Wpwe/DIErJsh0Iysvud04jWO80k2gCeFxQw0dbknACqs
 eGnKQl5oZcIozcRUAvH9qrQ+/OzwyljSp1HWUhz/z61HWR5qVavnuwidvTfy24k18KHIfg2XJl0
 HRvkcGO2sznAMmoS+rOdmf/l8qVTHmcOZs1GAxjVo21M4VO+Bc4z4ETMzrxystbNHVgqFJLL0rg
 wIh0V+alVvDdXonQjVfZx6VveVlzx/my90YtxZwcikEXwfGD2UrJcy2YYeJutBRjWrB7B1VOl1w
 tuMGYqQG6lQfBsw==
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
index f818e8a60099..d38fccb42e61 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5564,16 +5564,27 @@ nfsd4_init_slabs(void)
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
 
@@ -5583,6 +5594,25 @@ nfsd4_state_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
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
@@ -7996,12 +8026,20 @@ deleg_reaper(struct nfsd_net *nn)
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
 
@@ -9964,21 +10002,26 @@ static int nfs4_state_create_net(struct net *net)
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
@@ -10079,8 +10122,10 @@ nfs4_state_shutdown_net(struct net *net)
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


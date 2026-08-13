Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E4023EA66
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646457; cv=none; b=eFOuWfhkiPR8iLoK4MywQSDA8kQ/uhjT6ZyQAuQEH/lsluRuHdRxhEDD0VDiJurUnvYQYsNlKTTA6R3P/DMWg4QbsqW9tTC5PRQLch9b4UxBTixb7QG+RwER0EgxVp8Bti6qJ/cPBaGn+eAtnXJUS3Kj6Vq59emrhfI/dpUdQb8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646457; c=relaxed/simple;
	bh=jp0NEgSq1J79ubDFXwIxprQsdoCPnlI27eyJlZ8ba6w=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=qHJZYo89cyN5LP91F6Yvb7lncflnvj573RmNmAcC1y4sP+71sjy+N3orFLe4/dkRffb62u1O5xRWE0VsJliDdnXx/RXt57JIHLe4/ilI18Lp3ZMHEswGz32p+7E/QSVBDTRC3766NZJh8ZLl4N9n/roDEqueXJ8fCkvdm+9PFnU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ONlV3CC6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ONlV3CC6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B8CCB1F00A3A;
	Thu, 13 Aug 2026 18:40:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646456;
	bh=FwoSbYAaCGAPkcPPXSM3w6HjNnJZSeoKAwr3BcVFJpY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ONlV3CC6p+GzQo9K528LO9e485OyDMvO3ZOUao0DSla+Rv8nhBIDnO6AnWTQ2TpIx
	 3p3hxr4iLss9bBfQZkv68IMMpQP8CVuxz6Jah/sS6y+mxMlwt1IYKKmQFmM1dtuHI7
	 diJ73cBtAQAvwg9RgNQYUxeahN0ZIfp9BaHZLOSOndUVKdPVJ3NZCRMkZaM/Rn6N15
	 eSEEDt5MgBycBACS0dp09viuiSfPR4/+edOIcN466OUx1dhEG1pfNsQi7lNUbWGyG3
	 2Bwz72NWvgXPh0UV9EQXsFjMDtQiOObH46EA/tBD58WoebXqZloyxFxBqBnZo6BOCP
	 e3HJPgKpa2rRQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 13 Aug 2026 14:40:37 -0400
Subject: [PATCH v3 8/8] NFSD: Apportion CB_RECALL_ANY recalls among clients
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260813-recall-any-keep-count-v3-8-a96d243c0b13@kernel.org>
References: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
In-Reply-To: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6798; i=cel@kernel.org;
 h=from:subject:message-id; bh=jp0NEgSq1J79ubDFXwIxprQsdoCPnlI27eyJlZ8ba6w=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfg+xXpMjNdAedrdKd9NdXYEMwbenm+0+uIN1A
 NRWqwyOAlqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCan4PsQAKCRAzarMzb2Z/
 l9FdD/0Z+uLJOyfgTVJqd7o9qCsNvo/dRX5vYMt3wcXRVUP3BEFcjx0V2QmiPk7Pmo6VeAu5CS3
 PvPtTC73e95x++hIiyEdJ9lsfXC0KgY+OUJ07asxPCestNyTpQ77BjqPYtl3k+zOU3ZJFVlnofi
 RaeN7EJUbmSxupYLGT6y2ulqeWUumy7rih6t43FnhXekcxafr/YE/swMy65iLFkxP4Xx31sKRr+
 B6T4hnbDbSKux2WOvWZ4kXm4+HLn+LnDuGBF4TnQVDRUY8Wjxqm6om+tdD94eHjtdMQ1ZZ9SbNX
 DNN+gV7lcLt9uCny0eB6HbUF1Aruwx8dLPwL7IusitPv2jNRLqQyoBaAMtBSfRyA95sXzOcGlVN
 JEl6TM+K8r9twOnU0F2MnjUtAyy1XcuInStdy4erRN0A+4dipJx3ruav6pN5z1Pqfp5hiGx0qVw
 owqxEuUr7rI7G+QmPKEdThrFYK2I5pfJLu618rADoRFLrjFnFt2K/7vBQHvikV6t5D0ct1Qrx6L
 Ue6wPKXLOxWwcfBwM9kXLBE9P+wtvt69qSeIxTQZ84a8ULcq99+4M/M6XBR6ja9+YM2VvtLPSGU
 NHpTbGSVR9owPEqD76QiESKAKOaDfM8veDEDGcOdnXzFKIh23tS7GaDbpBpddwkESPsuT0FpGvv
 4Y2qeuYBd+jWnQA==
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
client's share of nn->nfsd_delegations. cl_ra_time keeps the next
sweep from returning to the clients this one reached.

Nothing is recalled until a scan arrives. nfs4_laundromat() is the
exception. It has no scan request to pass, so it computes what must
go for num_delegations to fall below max_delegations, and passes
only this namespace's share.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/netns.h     |  3 +++
 fs/nfsd/nfs4state.c | 63 ++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 56 insertions(+), 10 deletions(-)

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
index 2b3056ffe08c..9897c4831016 100644
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
 
@@ -5605,7 +5605,10 @@ nfsd4_deleg_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
 	if (elapsed < NFSD_RECALL_ANY_COOLDOWN_SECS)
 		return 0;
 
-	queue_work(laundry_wq, &nn->nfsd_deleg_work);
+	/*
+	 * Unlike the courtesy shrinker, this one queues no work.
+	 * Nothing is recalled until a scan request arrives.
+	 */
 	return count;
 }
 
@@ -5630,6 +5633,7 @@ nfsd4_deleg_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct nfsd_net *nn = shrink->private_data;
 
+	atomic_long_add(sc->nr_to_scan, &nn->nfsd_deleg_backlog);
 	queue_work(laundry_wq, &nn->nfsd_deleg_work);
 
 	/*
@@ -7879,6 +7883,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	struct nfs4_cpntf_state *cps;
 	struct nfs4_client *clp;
 	copy_stateid_t *cps_t;
+	long held, host, n;
 	int i;
 
 	if (clients_still_reclaiming(nn)) {
@@ -7992,8 +7997,18 @@ nfs4_laundromat(struct nfsd_net *nn)
 	/* service the server-to-server copy delayed unmount list */
 	nfsd4_ssc_expire_umount(nn);
 #endif
-	if (atomic_long_read(&num_delegations) >= max_delegations)
-		deleg_reaper(nn);
+	host = atomic_long_read(&num_delegations);
+	if (host >= max_delegations) {
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
@@ -8022,12 +8037,32 @@ courtesy_client_reaper(struct nfsd_net *nn)
 }
 
 static void
-deleg_reaper(struct nfsd_net *nn)
+deleg_reaper(struct nfsd_net *nn, unsigned long backlog)
 {
 	struct list_head *pos, *next;
 	struct nfs4_client *clp;
+	unsigned long remaining, share, total;
 	unsigned int count;
 
+	/*
+	 * Recalling a delegation before it is needed costs the client
+	 * an OPEN when it next touches the file. @total is also the
+	 * apportionment's divisor. Leave nfsd_last_recall_any
+	 * unstamped so the next sweep is not delayed.
+	 */
+	total = atomic_long_read(&nn->nfsd_delegations);
+	if (!backlog || !total)
+		return;
+
+	/*
+	 * Reclaim asks in batches and is not bound by what the count
+	 * callback reported, so the backlog can exceed what this
+	 * namespace holds. Cap it to keep each share within the
+	 * client's own count.
+	 */
+	backlog = min(backlog, total);
+	remaining = backlog;
+
 	spin_lock(&nn->client_lock);
 	list_for_each_safe(pos, next, &nn->client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
@@ -8059,16 +8094,23 @@ deleg_reaper(struct nfsd_net *nn)
 		kref_get(&clp->cl_nfsdfs.cl_ref);
 		clp->cl_ra_time = ktime_get_boottime_seconds();
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
 	spin_unlock(&nn->client_lock);
 
@@ -8102,7 +8144,7 @@ nfsd4_deleg_shrinker_worker(struct work_struct *work)
 	struct nfsd_net *nn = container_of(work, struct nfsd_net,
 				nfsd_deleg_work);
 
-	deleg_reaper(nn);
+	deleg_reaper(nn, atomic_long_xchg(&nn->nfsd_deleg_backlog, 0));
 }
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stid *stp)
@@ -10067,6 +10109,7 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_WORK(&nn->nfsd_courtesy_work, nfsd4_courtesy_shrinker_worker);
 	INIT_WORK(&nn->nfsd_deleg_work, nfsd4_deleg_shrinker_worker);
 	atomic_long_set(&nn->nfsd_shrink_backlog, 0);
+	atomic_long_set(&nn->nfsd_deleg_backlog, 0);
 	nn->nfsd_last_recall_any = 0;
 	get_net(net);
 

-- 
2.54.0


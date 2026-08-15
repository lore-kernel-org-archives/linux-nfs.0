Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4753741D626
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 16:39:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811946; cv=none; b=QoSEQN0S9aBNd0iQljSQOu+I8iiaDNwA2IyKu1rNXZHHecC5R18w6fqb4V57ahYbK/FVWV4mpquocWO2PDcBaLBCZti60y/0/FwhN2uCQplAK1UHrOgWu8DMpmy+fOV4zVmim94ssly9cQDepexAZMm48RbZfK7WRusyrYagG0Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811946; c=relaxed/simple;
	bh=E3QjzKTDT7JOIhgOSiKkq6MR/Y1c5XCmHm5uUCH5sbo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=MDn02qCMq7pACxuaxy8wUyeVy0QSJqAyW0ZfUZRuiDAjHegOypjR3a5tPXLDZDwKY3eLcfB61jHBQ6BfiDb+hmuYdlh2wKJIWFpl/+1iuNwcL/WZHawansgcqbp2VvA3agk2Z4lQamj7/s+dBrz7MUK4NVKuEEjeMaCtV+lsVmI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NOkgqCdB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NOkgqCdB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A26251F000E9;
	Sat, 15 Aug 2026 16:39:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811945;
	bh=bGwis7msDbHdBsNXCTwPZWWfBkBdmuf0vw6yaebNUdQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NOkgqCdBkVbzYNLp+DTiQQ7emCB2AHrIvldZrwFpm3hMpvrelKIZV77Cz+zEEX/NP
	 KQo8NMcHA/tcI3GIXK7MDKxaMWkLH6UPFYsx0Gw/uLsF6spAjiau2lFsuE385ttZ9X
	 +57vpQbdZx+1mcMD9x1M0A2zIckC9A1a6+Z6uOXJNFTFNxx9X61mTC2p3yX6z2azFA
	 dki4en/MBnDwLjTx7HwrC7sO7Hrwwx5zeIp3uoMcDkCcy3mVBzAbe/l0YEQtHAAVYa
	 LXgm4A//6N+xex/GYoDSLS4goV/tBC9SyXAi2skFL/QZ31hTNSOnCA75az8i8Wf7Y6
	 Hqy6iWsXC6+tw==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 15 Aug 2026 12:38:56 -0400
Subject: [PATCH v4 8/8] NFSD: Apportion CB_RECALL_ANY recalls among clients
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260815-recall-any-keep-count-v4-8-bfb5b83d6cb1@kernel.org>
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
In-Reply-To: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6995; i=cel@kernel.org;
 h=from:subject:message-id; bh=E3QjzKTDT7JOIhgOSiKkq6MR/Y1c5XCmHm5uUCH5sbo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqgJYiYo23MaYnksktSaIB5yaJuJBCW4/yLlo3p
 uSSX0tWZw+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoCWIgAKCRAzarMzb2Z/
 l6PQD/sEDCiBEUO+K7C9RRieZrIpXePqe0qzyxnMlzgdtnyNdoIHOEKQV2QHcG3hHQzFDPNLnMx
 E7BC11utzQwYbuUNQipGVYht/Os1P60SyyeqMyuxlD4X0zVTeV7f7olo1D3uMPfgiVlnFc3IiKo
 hUe1gWf/quYGrc4j5h0AMYaJ31eTBAHIe2B49HpxrChX9bDKiNUg18o6V9fmmUGYFDkNuF/gevA
 JiF+fsFQnHRYtvycDb3EvdDE+2gh9M7kRmEwMsGkX8fVirHj1tyYydBe7SkqgyIJX9docOPxQG6
 tf7mt5trX0xRqZY9NssPyPK3xBSBYK6muz67Fk0C5d/v659dQISB4+ICYEOqDDC9XewyocNen8F
 XHbGCp9DkcYvuilbPniQdy4d6gzCL8kGBq8Mz/EFFG+95n9O6WYqNEgaXTKWGSOC9Lym3ZYlvWr
 LnXGgQS2JYTi7+BPg0QT+1lyzQEFkN/O+9Ct0NutfVOAzD8AKzBLhwzy8pvTi8VRoW80rj9kDxF
 2oQdP/Tk85Tl64+RYG2Pi8qZU+ttk2bSfsham2tgFTRP36+USN1DHIIn+o8IWCK46n3FyN3N+Ag
 HUYZKG41/wP14SDYY7AVYGrtHmFI8Z+3lyIY+8EzjUW+mVdLIETZd0kRuvlG/IORHx/pUfwWVuJ
 pkXr7LUHQXWMwBw==
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
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/netns.h     |  3 +++
 fs/nfsd/nfs4state.c | 67 +++++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 60 insertions(+), 10 deletions(-)

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
index 1e71bb7a29c8..8a22b0658979 100644
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
 
@@ -5603,7 +5603,10 @@ nfsd4_deleg_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
 	if (elapsed < NFSD_RECALL_ANY_COOLDOWN_SECS)
 		return 0;
 
-	queue_work(laundry_wq, &nn->nfsd_deleg_work);
+	/*
+	 * Unlike the courtesy shrinker, this one queues no work.
+	 * Nothing is recalled until a scan request arrives.
+	 */
 	return count;
 }
 
@@ -5628,6 +5631,7 @@ nfsd4_deleg_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct nfsd_net *nn = shrink->private_data;
 
+	atomic_long_add(sc->nr_to_scan, &nn->nfsd_deleg_backlog);
 	queue_work(laundry_wq, &nn->nfsd_deleg_work);
 
 	/*
@@ -7877,6 +7881,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	struct nfs4_cpntf_state *cps;
 	struct nfs4_client *clp;
 	copy_stateid_t *cps_t;
+	long held, host, n;
 	int i;
 
 	if (clients_still_reclaiming(nn)) {
@@ -7990,8 +7995,22 @@ nfs4_laundromat(struct nfsd_net *nn)
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
@@ -8020,12 +8039,32 @@ courtesy_client_reaper(struct nfsd_net *nn)
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
@@ -8057,16 +8096,23 @@ deleg_reaper(struct nfsd_net *nn)
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
 
@@ -8100,7 +8146,7 @@ nfsd4_deleg_shrinker_worker(struct work_struct *work)
 	struct nfsd_net *nn = container_of(work, struct nfsd_net,
 				nfsd_deleg_work);
 
-	deleg_reaper(nn);
+	deleg_reaper(nn, atomic_long_xchg(&nn->nfsd_deleg_backlog, 0));
 }
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stid *stp)
@@ -10065,6 +10111,7 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_WORK(&nn->nfsd_courtesy_work, nfsd4_courtesy_shrinker_worker);
 	INIT_WORK(&nn->nfsd_deleg_work, nfsd4_deleg_shrinker_worker);
 	atomic_long_set(&nn->nfsd_shrink_backlog, 0);
+	atomic_long_set(&nn->nfsd_deleg_backlog, 0);
 	nn->nfsd_last_recall_any = 0;
 	get_net(net);
 

-- 
2.54.0


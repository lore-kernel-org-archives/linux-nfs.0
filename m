Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4CABA3769E8
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 16:18:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787933889; cv=none; b=IlghwDa0R61ufIZLMjCpyYQPgzvHS2t3ufLWr2ckQVi1x7kekofCvnE/wKb4dPDEHG1OLe7fdO3pv1QXRsIvC0WbzFq8eXjxNACGNLVKukX699dCx3qSGXJWELJCEzpB+4JnewtFimB0ilpfXh/jH97Urs/9m8Qv+1pPh/H8YEE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787933889; c=relaxed/simple;
	bh=p7iXkh2L8YMKANJvyjXuWA4HSmaifwt+u+vUXWfoqNg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=B/W5igdTs4xDqHZA5y9I+YNrgHwqhf7REP2O+dvpZRmRLqXaT7xSjND3ezGqvjwMBtEuts6kszhjJ/pEqIAooZICsXB6kcCu55UUHVy2vsxfAqp1EKVpapoy3IhgBDfiObQKbQIS1cQThO8nVwJH7pjWlK/++mP4QD75Tj+enZ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LK0SqMan; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LK0SqMan"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 94F721F000E9;
	Fri, 28 Aug 2026 16:18:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787933888;
	bh=y5bxGrBH38ScsP0Tccy6ACwNRbfjrG3QVwVEN7JLXs8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LK0SqManY+t1K5tmc9WIKRQDw8WwtGvtDZchx6BEg/LM3lLcqjO0XKb4TnzS1psQN
	 DgrI8DyGm2JyEFQJKQ/kISNZFpPoeVNR8EhwL4UkzocYhlf42eJnqSSnrLudyy/KJV
	 TYJNdplV0Ga46o8cbL0umhWkdNsRrzqWWQTqm4W3M65P+Y9GShsObjscSrFYTa8PVI
	 HUQ6PWlfScot2WqIe1ylnEPZ6idIsmyqnBdDLD7FrIm/+9GbOlvUA/Mib9qAaeXnVU
	 qiFEiNFi0wnFQaFmFFvVtKMoScaOB4udmt4BLqws+i8SSmFR1IUJsWWL8p333KwffB
	 d23HUBRqMdNfg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 28 Aug 2026 12:17:57 -0400
Subject: [PATCH v2 5/7] NFSD: Evict completed DRC entries via implied ACK
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-duplicate-reply-cache-v2-5-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
In-Reply-To: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6756; i=cel@kernel.org;
 h=from:subject:message-id; bh=p7iXkh2L8YMKANJvyjXuWA4HSmaifwt+u+vUXWfoqNg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqkbS79TEPzgHyDMLMskhj7WYOlZwIbKJlsatc2
 sqiNg24HN6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapG0uwAKCRAzarMzb2Z/
 l2rFEAC9cmkZ3nvvQsxL4vV6l77Vlzo0OK2mLwnTaiOh4bp3+fvunLEoJRhV6d0wR5onaf8WBZg
 apk712HsB8sw1uRTdZE6EmCTY19lz/EFDDSQ230yWpBzxzRvrW1yen25irSPHS7KnSWbrGGRDvP
 V0AXvQiniH/fuW6bGdZNyXVK8t8UXdT21e7hmzcJxg5jsMkBVGeEz9LOMVkyDuaVKrjzHKzj8g+
 dyqFqY5S0rJMBW2+QzgzHtbnyyem4yuOHtCFMSw/56+UPcUmTx7wzPdv9idX1NgyZp6eMAyTjEQ
 DgjwcNZqbzvl9iNF3cRSn9UCECitjOBapMaY/Go8cwYMsVmXu/uwB/7MWQCIW2dXdDh8frU4ib5
 77gPKjXjc9hUOSbMqZd3V95gSAoWWFmHHZneTOCWmpOnMyh9PHQYt1QRQ0nTpX/dLT9ausqacaY
 OWAUBy8k9x0922KSyPWufyfcHCuxpiHe1uIcJKkU6Is8xiD1xosX1o1wJmrUAd4Bch2u3G+pGy7
 4LrKBuR9B1G9rfB2DQMjTMsGw2KV6gvduTeq64KFQ6kHgjVz0BZZAJnYT4XGD5L03DnY+s197sk
 ++L7JTBQSOsou9hL/osnOWBzC+tvg07yMvDGqzi0ExgGaisR2aoNCFC41DLsv9ykWeGa1vS8lf2
 vIoVbusohwmR3jA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A completed DRC entry stays in its bucket until RC_EXPIRE elapses or
the cache exceeds max_drc_entries. Entries whose replies the client
already holds lengthen the bucket and slow every lookup that hashes
there.

RFC 1813 Section 4.5 observes that on a connection-oriented transport
a duplicate request arises from reconnection, not from within a live
connection. A fresh request on a live TCP or RDMA connection therefore
means the client is not retransmitting an earlier one. UDP clients
retransmit on timeout over a shared svc_xprt, so eviction is
restricted to transports marked XPT_ORDERED. Even there the evidence
is not conclusive, since a client with several requests outstanding
sends the next before the previous reply arrives. The cache is
advisory: a premature eviction costs a miss and re-execution, the same
outcome memory pressure and RC_EXPIRE already produce.

During bucket pruning, compare each RC_DONE entry's c_timestamp
against xpt_last_recv on the transport the current request arrived
on, and evict the entry when a later request has arrived. Only that
transport is consulted, because it is the one the pruning thread holds
a reference to. Entries recorded on other transports wait for a later
lookup or a shrinker pass.

Implied ACK does not evict in age order, so the loop can no longer
stop at the first non-evictable entry. A client controls its XIDs and
the bucket is chosen by an XID hash, so an unbounded scan lets it pack
one bucket and turn every miss into a walk of the whole bucket under
cache_lock. Bound the work per call to four times the eviction limit.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 78 +++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 66 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index b25b4f9e92f7..7a09a79a2d6e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -87,6 +87,34 @@ nfsd_hashsize(unsigned int limit)
 	return roundup_pow_of_two(limit / TARGET_BUCKET_SIZE);
 }
 
+/*
+ * A later request on @xprt is taken as evidence that the client received
+ * @rp's reply. Only XPT_ORDERED transports qualify: a client does not
+ * retransmit within a live connection, but a UDP client retransmits on
+ * timeout and shares one svc_xprt with every other UDP peer, so a
+ * datagram from any of them would evict another client's reply.
+ *
+ * The evidence is not conclusive: a pipelined client sends its next
+ * request before @rp's reply arrives. The cache is advisory, so acting
+ * early costs no more than a miss and re-execution.
+ *
+ * c_timestamp is set after xpt_last_recv was recorded for @rp's own
+ * request, so a newer xpt_last_recv means a later request arrived.
+ */
+static bool nfsd_cacherep_implied_ack(struct svc_xprt *xprt,
+				      struct nfsd_cacherep *rp)
+{
+	unsigned long last_req;
+
+	if (!xprt || rp->c_xprt != xprt->xpt_id)
+		return false;
+	if (!test_bit(XPT_ORDERED, &xprt->xpt_flags))
+		return false;
+
+	last_req = READ_ONCE(xprt->xpt_last_recv);
+	return time_after(last_req, rp->c_timestamp);
+}
+
 static struct nfsd_cacherep *
 nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		    struct nfsd_net *nn)
@@ -257,29 +285,55 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net *nn)
 }
 
 /*
- * Remove and return no more than @max expired entries in bucket @b.
- * If @max is zero, do not limit the number of removed entries.
+ * Remove and return no more than @max evictable entries in bucket @b. If
+ * @max is zero, do not limit the number of removed entries.
+ *
+ * @xprt is the transport the current request arrived on, or NULL when the
+ * caller has none.
  */
 static void
 nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
-			 unsigned int max, struct list_head *dispose)
+			 unsigned int max, struct list_head *dispose,
+			 struct svc_xprt *xprt)
 {
 	unsigned long expiry = jiffies - RC_EXPIRE;
 	struct nfsd_cacherep *rp, *tmp;
-	unsigned int freed = 0;
+	unsigned int freed = 0, visited = 0;
 
 	lockdep_assert_held(&b->cache_lock);
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
-		if (atomic_read(&nn->num_drc_entries) <= nn->max_drc_entries &&
-		    time_before(expiry, rp->c_timestamp))
+		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
+			goto evict;
+		if (time_before_eq(rp->c_timestamp, expiry))
+			goto evict;
+		if (rp->c_state == RC_DONE &&
+		    nfsd_cacherep_implied_ack(xprt, rp))
+			goto evict;
+		/*
+		 * Only implied ACK evicts out of age order, and only on an
+		 * ordered transport; otherwise the first non-evictable entry
+		 * ends the scan.
+		 */
+		if (!xprt || !test_bit(XPT_ORDERED, &xprt->xpt_flags))
 			break;
+		goto next;
 
+evict:
 		nfsd_cacherep_unlink_locked(nn, b, rp);
 		list_add(&rp->c_lru, dispose);
+		freed++;
 
-		if (max && ++freed >= max)
+next:
+		/*
+		 * A client controls its XIDs, so it can pack one bucket with
+		 * entries that are not yet evictable and turn each miss into
+		 * a full-bucket walk under cache_lock. Cap the work per call;
+		 * a skipped entry is reclaimed on a later prune, under
+		 * pressure, or at RC_EXPIRE.
+		 */
+		if (max && (freed >= max || ++visited >= max * 4))
 			break;
 	}
 }
@@ -307,9 +361,9 @@ nfsd_reply_cache_count(struct shrinker *shrink, struct shrink_control *sc)
  * @shrink: our registered shrinker context
  * @sc: garbage collection parameters
  *
- * Free expired entries on each bucket's LRU list until we've released
- * nr_to_scan freed objects. Nothing will be released if the cache
- * has not exceeded it's max_drc_entries limit.
+ * Free entries on each bucket's LRU list until nr_to_scan objects have been
+ * released. Entries are evicted when they have expired or the cache exceeds
+ * its max_drc_entries limit.
  *
  * Returns the number of entries released by this call.
  */
@@ -328,7 +382,7 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 			continue;
 
 		spin_lock(&b->cache_lock);
-		nfsd_prune_bucket_locked(nn, b, 0, &dispose);
+		nfsd_prune_bucket_locked(nn, b, 0, &dispose, NULL);
 		spin_unlock(&b->cache_lock);
 
 		freed += nfsd_cacherep_dispose(&dispose);
@@ -501,7 +555,7 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 		goto found_entry;
 	*cacherep = rp;
 	rp->c_state = RC_INPROG;
-	nfsd_prune_bucket_locked(nn, b, 3, &dispose);
+	nfsd_prune_bucket_locked(nn, b, 3, &dispose, rqstp->rq_xprt);
 	spin_unlock(&b->cache_lock);
 
 	nfsd_cacherep_dispose(&dispose);

-- 
2.55.0


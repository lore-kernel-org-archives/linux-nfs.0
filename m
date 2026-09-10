Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A15B490C02
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048501; cv=none; b=S5V3Ypc4BmZN0G96zPE4gz2ekKf6NVPEeqxgtC9HZOchBRLZnKUFuGkIBqswJGjifdOVR7HPEqcNk5ZDzA9+/UJ4SeTnUFeYJln2AywQQdjNfhp4C3ZFDr7TsvzIRX6O+G061f2NxGXhp0pLpdiqP2iRhZCJ4AYpZ9cd2IOfCKw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048501; c=relaxed/simple;
	bh=BSysMztAlfbUAGHTolHJQyE5tkMIGli22wP0R/PwwUI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=csK6HmRP14XWuWEv7kqxVipJJuyMTQqsmQQnk8Abiv1+o6IVR7HYq3Px83eUMgfToScOTEb+cPAvccGk0JsZr6f4QmWUHxF5LKkgOVYszSmk+oajyBCTV9JWgUR9dDk4UoXwzlxA6PEIN1ANmT0+33/S4gWaEIxAo9F7BPKDhnU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hHzk6ZG7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hHzk6ZG7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5E2861F000FF;
	Thu, 10 Sep 2026 13:54:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048500;
	bh=1Z3rRexKvvaIDFc2PihMMQEqnq6yc6IMHP+3fMmb6Ws=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hHzk6ZG78aKxsf81VQLzWt/LjEPEY+1MrE634uoQi5Ne/l4xhYfkRYzEuEdlD/73m
	 JscvQMXeLhTYwpu+Ed8BgVnpmcH/qh2U/goD7smiV8LI5Kea71lHxkKat4iVtGnztg
	 JIprIzh6q2dktyYBrdgXOjuvm26W17n/eSBw0WdqigpARnNc/nKFx7FVnCSu2FkU7f
	 ofIkXZRgeYx1C0zOXgXp2TMrmCUyMX7C063OKlUqaU8g9GpZGl1dNJ5e4nOgYy/PIo
	 J7aFwR31TEcvK/hCfG5cvvOq5EfuUb7kEJ63ghTvcevSIw6rdFhinQXKQS6cmadwpn
	 INXs/mKQh41sg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:43 -0400
Subject: [PATCH v3 03/12] NFSD: Prepare bucket pruning for out-of-order
 eviction
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-3-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3793; i=cel@kernel.org;
 h=from:subject:message-id; bh=BSysMztAlfbUAGHTolHJQyE5tkMIGli22wP0R/PwwUI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqoravIkAo4+soTITDaasFMDomVDnWcWDzy5WZV
 Ac+j5CFoXGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2rwAKCRAzarMzb2Z/
 l4F8D/9AGr75Ks6j6G08P86jpL6x8q1blfHEVJIa/0PlJnaXA9IIBwNl6R+7/RlWBUL6GUdZXDg
 wOP42dNbBvwxBT/OlYMHTyGreuHVDy8cnPBy1vnkRTfDkpruoj9sldLjx8x1gZZ5/5J3wWonMVP
 od2yzFg0Pdgbj7qmO7LRz99sRjKt6oBMIdDq6Gpi0fgA2s4URg39Ua2QJCSgsY2CxGg2V8XDb6D
 JABho4Iyn3KRQygxeNGaYX/+BsCvPCY8t7cs4xetKuAdfi4gcudRuHvnjSSup1/cVMvQ3e/TA2N
 ir890opq1l/ZcyAn71m7VFOUf6KVuadlOnK6RsGZ5x+LitA1oa2P44tgdHKj9Kj5Lmnr467pYJ5
 wfXxgMG4nXnemB2OKqWPJCnoi4hafMPg2YCgkNdsDEayzERsg2zMOdw1VlMekJ/uuq3u+kqOdOH
 sMBqs2FwB7RENtgrYBY06RWljLSeIgBSkq4ke0rX2cmgEB/y8uK95sTS/RtZK0ZlriRCtBviqpO
 hJFAel/UIINhjQWEH60bHKCKdas+lO6EKmsjARQ/R7MLvXHHIg1c4axtAzMlfPWAofuc86ZjW2l
 0K83r4ACPEvrqFgc2iqQCl7ff6zOM73GwqKAPTPO0tEPlPkZJdRww7IQXzpkAlWyAFQaqom4xEf
 zC0haL9S715yWQQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_prune_bucket_locked() evicts for memory pressure and RC_EXPIRE.
Both reasons hold for every entry older than the first one they hold
for, so the walk stops at the first entry it cannot evict. An
eviction reason that applies to one entry but not to an older one,
such as confirmation that a particular reply reached the client,
cannot be added to that loop.

Restructure the loop so each reason is a separate test that jumps
to a shared eviction label, and continue past an entry no reason
applies to. The restructured scan no longer stops at the first
entry it cannot evict, so bound the work per call to four times the
eviction limit. Pass the shrinker's remaining nr_to_scan budget as
that limit, bounding its walk of each bucket the same way.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 36 ++++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index b25b4f9e92f7..e6504e192dfa 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -257,8 +257,8 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net *nn)
 }
 
 /*
- * Remove and return no more than @max expired entries in bucket @b.
- * If @max is zero, do not limit the number of removed entries.
+ * Remove and return no more than @max evictable entries in bucket @b,
+ * visiting at most 4 * @max entries. @max must not be zero.
  */
 static void
 nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
@@ -266,20 +266,31 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
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
-			break;
+		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
+			goto evict;
+		if (time_before_eq(rp->c_timestamp, expiry))
+			goto evict;
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
+		 * a full-bucket walk under cache_lock. A skipped entry is
+		 * left for a later prune.
+		 */
+		if (freed >= max || ++visited >= max * 4)
 			break;
 	}
 }
@@ -307,9 +318,9 @@ nfsd_reply_cache_count(struct shrinker *shrink, struct shrink_control *sc)
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
@@ -328,11 +339,12 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 			continue;
 
 		spin_lock(&b->cache_lock);
-		nfsd_prune_bucket_locked(nn, b, 0, &dispose);
+		nfsd_prune_bucket_locked(nn, b, sc->nr_to_scan - freed,
+					 &dispose);
 		spin_unlock(&b->cache_lock);
 
 		freed += nfsd_cacherep_dispose(&dispose);
-		if (freed > sc->nr_to_scan)
+		if (freed >= sc->nr_to_scan)
 			break;
 	}
 	return freed;

-- 
2.55.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3F374825A5
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397148; cv=none; b=ASPggWtdwjl/exf4/YJbTTI2/4rBECaFsR0nurb0l0VENjELd/j3rojquYh+vllcjItWQhRfsIj9V71Y76jqGy2zuwJ2YUGpU/9DjzQFVpM9WZJ5Gc291qxNC3dLvkRVmxf4/i/KeDHU1PrEcxDIUIqsYV/TeuL2Mc3r+6ayx8o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397148; c=relaxed/simple;
	bh=Xm/Aeds6biHxvWISLUJVl/54HEa4o+fcF78y3792wnA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Co7xOYmGkEs6IoVsVuimGAhpJrJ5ACdISLgr8wJJXLhMSPbhL2Zwshc0xITC/r/MgVGoh5Ofq1ipBAVOWQ1mRqK9IwOTw6JdRpFABK0YZkD/uAgIz1G2uhKFQJ5xoJyCHMxT5NWOCGz40Ft22H9OKJSK10eXAjvQnU1+f+i+mdI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iox2PrZ3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iox2PrZ3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E9DA61F00899;
	Mon, 14 Sep 2026 14:45:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397146;
	bh=f3SyxinprMu13hKpBX+hyR/FKQXVmc1s73VRszawaf4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iox2PrZ3QGrcisIOQqd7QvUT1iaQnIM/ncZl/fub6pG4F0H5pFcO/FsuEuMiyfxiC
	 hZW9mbPBQxMxSoztz1TwlouMWePnDhX81C6BBh3iutM4/+xMxoaKdBZEghGpZb4U9n
	 HAA7c/T+y0CbfMx/U14Ty0FL1NJvIZ1Z3IlVaCXcOPNUXbi/y8ee+8h0RwD+0s6sUW
	 N6nkOR39km1hB6Qo3O3XetagFWOKGxEk5Ie5fi5o4ybCzPGVMUzaEwg17h8iOcjtiq
	 bFJlNCro1dmxgpOwhYkwZBgxPSv4nkZ+A/kqlBHYzh/sn+GJAKB93YLBPHkuUX4E1F
	 tVogs8+jPMnjw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:33 -0400
Subject: [PATCH v4 03/11] NFSD: Prepare bucket pruning for out-of-order
 eviction
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-3-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3597; i=cel@kernel.org;
 h=from:subject:message-id; bh=Xm/Aeds6biHxvWISLUJVl/54HEa4o+fcF78y3792wnA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiWs4TPLUnExa3nVWd3pJluurXt6fQc47NQm
 GlS9H1xoWiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIlgAKCRAzarMzb2Z/
 l3MlD/4o+Zt5f5iRyl05+XOxFIL0LzO7GQMzZMc3K0qdLlYQAz71j0pW9Tfmua0Av04GgyH3ofK
 3KNW/FgOgfQuK0vI5v8xBTlbdNC8LK7UAY4qEoKAX1eolIbEQ27cG0KKMMiH0cdFJDWzjot2IdM
 aH9v6F9ecaQVpYCgcrr+J5SyiyU1SHytZLpo+JldNCzW/qw/dE00h+o38eizvT4FE2Q87pbayMN
 vtL5UFDZC0V1kSpMP14aRNjnbM8ByNOPN+YCCz+Dtys3iVOVg7psOjfeZvLFLlN6/ZDPFrcnxgF
 HD2actFm8m8aRS10NvFsKmz73Zh6PZbgydQgAE5QqB/WJ2bXcGhKSYZW3om3Bt4uqUrb3kxtgpG
 vpVNVXP9DquzsZCxImNZyKgWbi9u7XZJ7nepdZkpmsou8cbijkTZpepHfMb7ncBoRLzCNj3CnbW
 RC1QudEkOzQZtShR2PU8LALv9mBhhE+vOLt73Gopk4oLA8kNf4hcSAkmAw1A3gWFCLhC/aoWTXr
 tt8oNyQj/Zl8dMexJEsBoTjTFuvsK2AVsZoMZM/cMKrswOpUYRwN80/EzQPD5zdAdgGP9rEvr5Q
 rI/L9H0x7ku4eVxNpEdLUFkgpH/zRi4OdBVZutZrDYaLxh9bdz8DFFArDQ4glHVKsJhtVF1gL3I
 xdpJp2k+e6N9GxA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_prune_bucket_locked() evicts for memory pressure and RC_EXPIRE.
Each reason, once it holds for an entry, holds for every older one,
so the walk stops at the first entry it cannot evict. A reason that
applies to one entry but not to an older one, such as confirmation
that a particular reply reached the client, cannot be added to that
loop.

Continue the walk past an entry no reason applies to. The scan no
longer stops at the first entry it cannot evict, so bound the work
per call to four times the eviction limit, and pass the shrinker's
remaining nr_to_scan budget as that limit.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index b25b4f9e92f7..716605dbc788 100644
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
@@ -266,20 +266,30 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
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
+		 * a full-bucket walk under cache_lock.
+		 */
+		if (freed >= max || ++visited >= max * 4)
 			break;
 	}
 }
@@ -307,9 +317,9 @@ nfsd_reply_cache_count(struct shrinker *shrink, struct shrink_control *sc)
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
@@ -328,11 +338,12 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
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


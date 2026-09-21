Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CC1D49DBB1
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996962; cv=none; b=AncJBOPKe2WemOC8kpmaByYHPLNF2+5TKz0KHBFT5a9oVAeXdmfRg+QcvSDiTX/hmejJkqV59dREQdH7nUotu2aHTW7wcm1hzxZeMwYOKJSp3nM9M2o6l+xy/6ce9pMZJSBj5KYugHWdCeyl0c/Db6htwDqblRPbM6nR+q+HKeA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996962; c=relaxed/simple;
	bh=CrNMEiSlJAPYU07Bt+yxWbPYmo+qtcsUYkSVimnUVPI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=QCNUUdmGTeNOgM9/Nhy+dLl05iALCFjDEhyqGheWOJ1VFQeVUezefiFN41oPS25h5ljAUj0EcxX/LSimlAG/MPFoQdTna+ha25iUqGSC1A+RFDzLzAB/lBOjzPahDK8PZWZO7FQ6A8T4yCEKKNBaKmVJDsBhFEH0+TUgajZQl5I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PsZkkN5u; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PsZkkN5u"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 674271F00898;
	Mon, 21 Sep 2026 13:22:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996961;
	bh=XgN4aAlpv8PUxnjgO4dLE6+wVPsQga7qjjMHCUOFhwk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PsZkkN5u5/qb2tx5OjI884xCWDcQiLsFGwH58oluSOcFCB30UuwGRost8ELUAQE6r
	 O7qfiSqW7vpSpKfxmf0qG741djqn4WkbC0j+FzFSKUlrv9Lh3nIMLrur72jFq2Jccy
	 p4tmhkrj/46CNPdYWO8OoYPLyxC3c+Pyj3mTR57ohGpjx2D/WnzJsYJ6mY/8uXOyPc
	 iy3dUEfg2bqW46OKEirEmm02TRYsNuHfaBS7dxSkeb6kWZNTDZwo3o8tRHC+T2+I2N
	 H1dv3Jqt8/5/RKTYd8clA/TdkEbH97LZN0cDiVGsP/iEL3tU5M8gxFdIaomwAh7NU7
	 KuUOVa0dfFcgw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:28 -0400
Subject: [PATCH v6 02/12] NFSD: Remove hard cap on duplicate reply cache
 size
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-2-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3326; i=cel@kernel.org;
 h=from:subject:message-id; bh=CrNMEiSlJAPYU07Bt+yxWbPYmo+qtcsUYkSVimnUVPI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+diIP5T1tdeofR5WWDKfPXg/gpkWh3k5gf5
 ljgyUYSijuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvnQAKCRAzarMzb2Z/
 l1OhD/9UcMkXiKE0ELClgyq5+xGsbxFLS2HFS3gj9NE/1XrDNoSJrLauaAGnh8zYjXyRMzNWAUz
 aINB6dLks/TqGgGmXAGsMW8iQmJcoKAvMbdJsylLjezdkIdtGyxL5jfLLGw7P/ZkmK5YxLdYqBM
 C9dJmxYvyEOuQQNhuciKoDhyFjkYTJk5kUar0JDI9RN0H7mGEZ8YWuNpKthKI9hr3yGq2MbIUgI
 lQ85mvZMDTWMRgPNrmzZXfS1WhN0r+YCwkpyjucA5U9TYdPxZyWce/5BH0s+GDexuHpJvu3vwFi
 Pu1FlovIJZyBnokBp7dGEroEBprx1Kf2KC11Fq0M5O8TMMT7v/Ba5LGRAaPgXEbpLjGwAzUl6og
 +ogr0aj4z8D6Z8prE8I0h0C8xOF+PvewuRAwMPRZDZBVK1AG5xChQoaxaM031jssB0HvrkPInXU
 znqYTTiRXG6GA73v8y80IUEdDmIKrm7p2rzpjS1bzxGfMG0mKma1/LZh6Z8AKejnPsRu+R2m+jA
 QJWEia35Dl705+0Opck3vlbWIrbVhkQoYuMYtpyb/kqpPqrP1ltomMu+lKcxuX+Xy3VWoFCYimt
 CwQqXA06zO0vbxa4i5s6WyRED1B6KkmSorM8P5KLaPb8Sow9yb8KUHFvKIK0hDGnfngq6abYpqw
 mZIhD5VeJ7fz9gA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_cache_size_limit() scales the DRC entry limit with the square
root of low memory, then clamps the result at 256k entries. The
clamp binds on any host with more than 64 GB of low memory. Once
the cache reaches max_drc_entries, nfsd_prune_bucket_locked()
evicts oldest-first regardless of age, so on such a host the cap
governs retention rather than RC_EXPIRE. A server that completes
more than about 2200 calls per second fills 256k entries inside
the 120 second RC_EXPIRE window, and from then on entries are
evicted before they expire. Those are the entries a retransmit
could still hit.

Commit 0338dd157282 ("nfsd: dynamically allocate DRC entries")
added the clamp in 2013, when the formula's worst case of 1 KB
per entry made 256 MB a reasonable ceiling for the hosts of the
day. The formula was already sized to memory; the clamp froze it
at that generation of hardware.

Remove the cap and let the square-root formula govern sizing. It
scales sub-linearly with memory, and the hash table already uses
kvzalloc, so larger sizes need no physical contiguity. The limit is
unchanged at 64 GB and below. At 1 TB the formula yields 1048576
entries, four times the old cap. Even at 1 KB per entry, the worst
case the old comment assumed, a full cache is 1 GB, 0.1% of that
host's memory. That memory is not reclaimable: the shrinker frees
only entries older than RC_EXPIRE, and each net namespace sizes its
own cache.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index b43b276a92b3..36afe5fbdac5 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -47,8 +47,8 @@ static unsigned long nfsd_reply_cache_scan(struct shrinker *shrink,
 					   struct shrink_control *sc);
 
 /*
- * Put a cap on the size of the DRC based on the amount of available
- * low memory in the machine.
+ * Size the DRC by the amount of low memory in the machine. The
+ * limit scales with the square root of available memory:
  *
  *  64MB:    8192
  * 128MB:   11585
@@ -59,22 +59,24 @@ static unsigned long nfsd_reply_cache_scan(struct shrinker *shrink,
  *   4GB:   65536
  *   8GB:   92681
  *  16GB:  131072
+ *  32GB:  185363
+ *  64GB:  262144
+ * 128GB:  370727
+ * 256GB:  524288
+ * 512GB:  741455
+ *   1TB: 1048576
  *
- * ...with a hard cap of 256k entries. In the worst case, each entry will be
- * ~1k, so the above numbers should give a rough max of the amount of memory
- * used in k.
- *
- * XXX: these limits are per-container, so memory used will increase
- * linearly with number of containers.  Maybe that's OK.
+ * These limits are per-net-namespace, so memory used increases
+ * linearly with the number of namespaces. The shrinker frees only
+ * entries older than RC_EXPIRE, so a cache below its limit is not
+ * reclaimable under memory pressure.
  */
 static unsigned int
 nfsd_cache_size_limit(void)
 {
-	unsigned int limit;
 	unsigned long low_pages = totalram_pages() - totalhigh_pages();
 
-	limit = int_sqrt(low_pages << PAGE_SHIFT);
-	return min_t(unsigned int, limit, 256*1024);
+	return int_sqrt(low_pages << PAGE_SHIFT);
 }
 
 /*

-- 
2.55.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B7903AE706
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752096; cv=none; b=DAl/3jMLCNg746+Ag1inRTPPZcYko8Qvg4eyXbZ2z3vaQkCl+i32eBoZddsiKZB62WWAFkfoGxpEFsVVzEOh2RSK7bQZzBALHSFgLVBbrku7IJUCKXL1vDvHuS1/VLvztzP1be/GL/ZPvbQaZ9FPWVEzeuLj2V2kQtp0Ufo1XDk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752096; c=relaxed/simple;
	bh=ZAC9n34yoKnPqH5sM4Pi658cSdhozawzsX6DFY9ulvs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=X4lbAEnFfNvQUUiCeIiLFFzzT2+KvIJH0WC38SvA2bLTLMt3zLQnK5L1aeKf/PUkA5PKlAHFvCvoFtKV1MVRA7T2ReF1KzshTz3shhTwGNHu0Apm5OFiL8kSYViP48yqIbCA3liRh6+Zc9m0O7gm49CS1z88t3KDjCAlFKo36So=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oWZenCWx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oWZenCWx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F26F11F0089A;
	Fri, 18 Sep 2026 17:21:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752088;
	bh=IH3NxIiFncnWP7jE1VW9PkKwV7CUqC5ZQQfw8AL5uCE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oWZenCWxwc2Tv7j3lrMyZDk2PXAhFrvW8a1DNRzX8MRirFwBSEL60dsb9Le2HmGrX
	 Mot2EQIjxnxXfpBZqy+to7RTZ0Ud1AD6kvfmxpDRhpp1awbzr9h+CRTEL2QmTINHnd
	 aLBVIwUUGtkm+eLjFhyOp5ytOJf5ktm/jXy5eDKURw/51BB4ezptXccA+n3zA8h+kt
	 BdLsCcQ84fg94s5Nw7pV8P3MQ1o6qn8mc+UdN3Kpym+WTdJZ/sVh++Lkv2d7uS1QrF
	 CTocmW230mthiNz20U5pK0g/mzNH0yuur/SYvv0IJfjMnfxAlJzeJN5SutWuKtwRZG
	 8vwpQG+E8z+bg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:13 -0400
Subject: [PATCH v5 01/11] NFSD: Remove hard cap on duplicate reply cache
 size
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-1-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3455; i=cel@kernel.org;
 h=from:subject:message-id; bh=ZAC9n34yoKnPqH5sM4Pi658cSdhozawzsX6DFY9ulvs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMWl7KoVomtJNlLSOL6EuX5GdO5sQKsvL7WU
 j8V8MBcrO6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 l165EACBDbZ6JZMol5RGk5eHjrNnF3Jx2MR53bHDhIsd4HsWOutQFw70uCu17nxLTF0q0q6JADo
 wM1VC+8W3A8zjqOfrPluSAqNY51KQv26msoHIAeoJMNig1U7EzAfixvxkb23ZJUOSBAhSLF70Ow
 KugUODxvZ+kSdJKka6LxfKAI43GiudvAQv3gmOEnkBpDj9xuRrDWiLixUDMp65u4Bj2L4Ze0LJU
 eQscouPeOKmwZOJmey6JiEnZ7oMGkTgt+wM7lIa0FCWtoInEf+KB+mOlhkBFaH1KFstt3ET85QN
 z42TDXzx1/5jVR3vHYXMXDThWsUVefnwv22yF0cnLai2tw7yKm00zGltDvbcPeBhYylfnIZfKEZ
 CWqMwyCxEVIh1qS5xXAFE6h5rO+274Ed14OuQnb1pAOR1u77eIJCoPFlTiwGPqURAZaw3fGiXKM
 /WNoIMMk6pgbvBZWsd9vr97YjmXtAxbuSd+7I7B8f4Mr4+cyJzutYM6xN2aYAPlVt8OP8zwv/Gf
 BipcGe0EQlaAo1z2IFLDgk+9xWd9luy0wC3ZXE3afgaEX7s4bMzo52iphA3B3mTUw1/oBkruu5h
 WFeBC479Ro/NM6XZdPbjsPiFOXjR/EHinoqEckqVG0lRf8mw8uCPr/xNjCu4yycl046YBWl/rzT
 ZQjMJ8LRZcI6k9w==
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
 fs/nfsd/nfscache.c | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 80364b91331a..d0f65cc9c07a 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -47,34 +47,37 @@ static unsigned long nfsd_reply_cache_scan(struct shrinker *shrink,
 					   struct shrink_control *sc);
 
 /*
- * Put a cap on the size of the DRC based on the amount of available
- * low memory in the machine.
+ * Size the DRC by the amount of low memory in the machine. The
+ * limit scales with the square root of available pages; with 4 KB
+ * pages:
  *
  *  64MB:    8192
- * 128MB:   11585
+ * 128MB:   11584
  * 256MB:   16384
- * 512MB:   23170
+ * 512MB:   23168
  *   1GB:   32768
- *   2GB:   46340
+ *   2GB:   46336
  *   4GB:   65536
- *   8GB:   92681
+ *   8GB:   92672
  *  16GB:  131072
+ *  32GB:  185344
+ *  64GB:  262144
+ * 128GB:  370688
+ * 256GB:  524288
+ * 512GB:  741440
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
 
-	limit = (16 * int_sqrt(low_pages)) << (PAGE_SHIFT-10);
-	return min_t(unsigned int, limit, 256*1024);
+	return (16 * int_sqrt(low_pages)) << (PAGE_SHIFT - 10);
 }
 
 /*

-- 
2.55.0


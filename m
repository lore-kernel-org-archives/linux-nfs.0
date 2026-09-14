Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E32092264A7
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397157; cv=none; b=JLWCFYaYpJccFCP7cOKCQXyUhl2kDkrrEzTE4dJ2fD01OjdlwcXAQ4T6+U+epeazkhPN7T0dC0Xe5SLLBdoKoWn+Ag7dL7PTGo3uMznGL3USu9Vk3N2m8Lgsb3KM8ea3fpK1rpV4gdhvg++vm+UotACHe3nV+LrAx0/LYPdDAyk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397157; c=relaxed/simple;
	bh=tJxAxKay1MgjciCxcMXQpJiYOvqL9w2lsRW9KhAl7aY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=k+rZLnlbUsYE3JsNRDi3rbBVa0LSgvHAeihstlDnLbm66E4p+aGoknqtSTxSetqCBeCRok/9G/EBU8S7rRx5aVyN71dDya6iky4D/qG0RczHrOJu6gPxaPguThEtbttxloIeO4B3yClBvkn5Jm7ld0c4ck8tp9MT6IzOZTiVX6E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FFAhYT9e; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FFAhYT9e"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A08331F00899;
	Mon, 14 Sep 2026 14:45:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397153;
	bh=f28CVtOhLknQoB2HBBNA2uIEdAmslBJaR3pp1+XoYHs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FFAhYT9ey7/w2Rzic5E5luKhsZ1+hDOzmhInzhtQWMoEbfzn1WhivuKwFOULjzr/k
	 RCuOMi4clmQU5xRkVqSQ0F7BFbk6IkXtMmTUUG3a+w7JeNP8r0o8LAt0Ae0Cqzkhay
	 AWr1ty22JRNweJEA+QbzaihFEvfd1sw36xxwHkBcUjPeZ0lxnF3JIJ3DjDtLwobiCX
	 5lDi7tVxHvqq5zil/nX8FEhSwwy6ZWuuYwNfH0d/jsAde2rofwPEL+CLzqluWd+zoe
	 M8BP7kNFSOeQ0paBqTfJQSnxiKyGiiKuy+/WPHgBJFv+vdt4sofE5UYniE/q7k08ST
	 u9dOCBs7/3XxQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:41 -0400
Subject: [PATCH v4 11/11] NFSD: Remove hard cap on duplicate reply cache
 size
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-11-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3643; i=cel@kernel.org;
 h=from:subject:message-id; bh=tJxAxKay1MgjciCxcMXQpJiYOvqL9w2lsRW9KhAl7aY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiXzPPxZRM+/01gw4XL1eLoEXeMXn8ou5MAp
 oXFyD8EwnGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIlwAKCRAzarMzb2Z/
 l/nZD/49MQxdkAlGZ+Ph2AEDjfbYRI/QHES/xgmIWXqD9+dni6EaDL+CtAHCNiN2Hh5ahz1BP8p
 sGYteaXn0mdX3NegnD7TYhKnfoA43X+FjMGMnqIvVSKV9S19PixDaAN/CekySpSkwbMLwvgBcqw
 FT2f87Xl8b2uiH8I4aS/VmkrsuocHABrb5HuZNm+rniuEeMijLWVvl1QRXTSfEW5rjpjn2mgO0t
 ce0O4LfsPAH+I3bu+Hs9G3KFbN5n60bq08cSyK/nRVhZiwzrkDBQDub2kpJ+G6q0+DgbZJ+G+LJ
 Gs8CEbI/g87cpbhPe0MxHKbDbclYGw72F2GctEzcfGAFaKNHWO4XpjdgiZYYHchNZfygoLlJFLl
 8sqajorMuCPkalrNj7geGkwkUBmE/T/iqEglWSImScAil33tuvGd0CwutLapPMLcfrJATY7cK9K
 5gM+/1CNTzm5dPlplGM/9SJMxZv24fn0EoMd8csQrYwmFLCCfgJ6fAHlFqI6JSyWr4rR9AehZlp
 /r0gVuR0RHiQLEkrdXMekMPRIFpmOZhvBjlH4H2b6xXZNCtMPtp9DrrRwlCLomq3KW0mWkNRAYQ
 eK/VWEfe95IFqZusiTcgtDn4Yvde0xGbm4pixPJPsh7bNEJVBc3ahNfVuA9zLS22Bm+RZPdw6K2
 qkivfhmx3P2sDqA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC matters most during a network partition, when clients cannot
receive replies and NFSD must hold them for retransmission after
reconnect. Acknowledgment-based eviction is inactive then, leaving
only RC_EXPIRE, and a 256k entry ceiling can be too small for a
large client cohort through a long partition.

During normal operation over TCP and RDMA, acknowledgment-based
eviction is bucket-local. A lookup evicts acknowledged entries only
from the bucket it lands in, and only those that arrived on its own
connection. Each active connection keeps about one entry per bucket
resident, the calls it issued since it last visited that bucket,
which is an eighth of the maximum. With more than a handful of busy
connections the maximum governs in normal operation as well, and
pressure eviction then removes oldest-first entries that are already
acknowledged. The cap bounds memory in normal operation and starves
the partition case. The formula's maximum serves both. UDP entries
wait out RC_EXPIRE as before, and the maximum bounds a UDP workload
as it always has.

Remove the cap and let the square-root formula govern sizing. It
scales sub-linearly with memory, and the hash table already uses
kvzalloc, so larger sizes need no physical contiguity. The limit is
unchanged at 16 GB and below. At 1 TB the formula yields 1048576
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
index f1e6dc0fa95f..0d11cbf1cb05 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -45,34 +45,37 @@ static unsigned long nfsd_reply_cache_scan(struct shrinker *shrink,
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


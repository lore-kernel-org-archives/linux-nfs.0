Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297184;
	b=A7Jzf0AXIseZSorFs5Nw6KD3v8qKjUeHssJwE1LAygEHf8KuPe3OiFxTb4dmgqiq8t3F
	 26s25BUCkBMK6nz/v6uN71JFUScKo9UT8y5T+xTbGCFTJtwZDEY97IqlxYALAYcnWn0cl
	 WVCqa1nocl/19RmImq6caMMffhC4nox/L+9gc/YteBnOF1V/1t/Su6yp7SGdawjuNVnIb
	 cr6r4fWNKiLCrQUioKzaL6Qdz/+ZM9pPXI1Hvsrkf3YvOlUXLqN+xgMSEYalV2Eu2VJzs
	 T3KafTs4QZWuTj6D1TkR8tExwJH0xrFpARwCYTXJgmTtyt0jflTIUevwwlViufl4xSg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297184;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=UkbAoayPHXNJTN3X+ypuydmPhScOTUhfky1PN8gZq3A=;
	b=T2aeESL9zaWspsxFxi43h2tNBxkxn1UZu5ON/eYbABDZIZwp8kk0X40cIKaY4GXQN0ex
	 PioqMljUi2cyr9hKvhtUqteRWF3KSxSYQKPl1HrTjCzS/nuL+aou1i7NM7qe+0N08aNNz
	 dNsP9YyGt87XNC1v0Xkb/WvtjzxkxgvHzjsg+nTYapJI96K8p4dBiwAeSkizLy3uPYsl7
	 RNFi51ungUQePhwmNyAm13yie8+h+PKpKF8sZ4CHiozSbcWBL8NXThC9zO8B+4239ypOm
	 guHrWZgcY7xlPExCmiaOOj3IIe6pDTC/RZAQN42pJnhZOVUFmWuxuv7KGzJu3ECmGZw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JU8PTFTc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24396606A323
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JU8PTFTc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4EC871F01826;
	Thu, 29 Oct 2026 18:06:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297183;
	bh=UkbAoayPHXNJTN3X+ypuydmPhScOTUhfky1PN8gZq3A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JU8PTFTc7LC8EH76aexo4gPCRgbAc+U00i47AMoAStnXL97TBMRq35rZmFhA+8d//
	 8Eba4CoUkrfjziD27LaFpu0vii/ZKoAv5Lua2aAsSzCs61vrr+dEbL1qEcZUlGGOVc
	 XXlgt2LjBrxTb15GoYOuEF8NFTDY4UHlqqYqtpGWykGQqJA+YTWstvEyo1JL2ilFtd
	 Gf0WtC+iTQ5WCMJUr8WitJeArtXUp8mdKWO6hQKw1dOZKGlnXX9CbJpslBgCycShlU
	 vft4iWJoZ3PZpcLcYQJpm61bz+X9pMmTlPSZJFwcDPZSmYUaqVlG7kYjN19ZrCKFiJ
	 /aG6vlcxECm9A==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:08 -0400
Subject: [PATCH v7 02/13] NFSD: Remove hard cap on duplicate reply cache
 size
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261029-duplicate-reply-cache-v7-2-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3503; i=cel@kernel.org;
 h=from:subject:message-id; bh=7rEdU5StlvUusTHzHhxEaRlPVDRPKl5BcmPnprzkE4c=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44sc08XJf0UUjyoVEbb/YDVjLG6RYT9U4SrgA
 XdBo8IIjpuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l9UDD/0SCEVhz8Fj9Qig9GusFXVSeh65AbBSxVPaYRTHVHI71h4W3Vvi+lYbgf/a2/kalpzsGoz
 PhIKUWzSVvKBVWAtbAnZ5KUHWBXygY+7tgddSnfYx/zlOLxwftyM29kyxBMfCaNBH94obG0UD7x
 2hYSFctY/TtmvgCdOFkyQ6EwsOBbEP4MHlF4EZgEVDSTf3rVgji/2VArRBUW7UnIyu2f8PpPnBK
 17elz0OlfjNE2p/sc3QqimqtgIeiQier9gyNQeD4Sk2SPz+e79Dvs+Q8t1pts32exgMr97e8QJE
 4L7TN0AJD/zCFEVv1PFmZ9GmQXsdMGmC8p+jdtYcpwWnMKWknHJp5BGzioo2/qAtx+PSgl4bg59
 pRzuJ/Bawj8V6A7eKkfINkikC3R9ro6lCqHtam+D5zAiHNFBIhVaz+yUe9i31a63u2A79O8Z2z2
 zaadsid6ecWi6huTOk2w7hq/LHSb5xzP7Yz9GgXL6+bFNg0BLFzi/MbExV3BAAJImBzuo3nkGf4
 5SeiFSeOHxyVsGMvCmH9xi6S+TvKNRD9SyhwR0No4v3pALlQHhEvRGvZZewhC4VRQSEC5dKvWb7
 OuS11YRAgJyFwjhWhZKPw9Pm/W13dPAb3cktYluJ2vKn+QX1yH246ERCMy2KkE8CUVkObatViNI
 vwS92djg/sH5H/Q==
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
host's memory. Below the limit, the shrinker frees only entries
older than RC_EXPIRE, so the unexpired entries are not reclaimable,
and each net namespace sizes its own cache.

Assisted-by: LLM
Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-2-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index b43b276a92b3..391cbca74836 100644
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
+ * linearly with the number of namespaces. Below the limit, the
+ * shrinker frees only entries older than RC_EXPIRE, so unexpired
+ * entries are not reclaimable under memory pressure.
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
2.56.0


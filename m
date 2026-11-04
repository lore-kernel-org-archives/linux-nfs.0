Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801479;
	b=P5Dt+ssWFjYsPGtf9nPWUHVqqhjWSTRSOo8JYHBElYrexUrCVhGFvUmABWmLn7H2dAGr
	 9g41RbNEhRT/3tYI1FMeEr/rqeg2lkDSbMn1bbTmLojF56CItv8PgkLuZ7jtw4RzUg9XC
	 suEBDMnaS39lmuJxGs0cJhEHv4rR5u4nwyHrCwhLnlzY6ljWPmnutGE4Kz6oYccdpSm5E
	 FOx49irP3GDcBi077DDJRp8P5hxibRFe8UTuHQARePDulqyOuadk6gUA/0X40kRCqSEcQ
	 EJieIkD/6kfKDR+y764KYnGonA79dXg5k0hFkFQpBAhFo4TUNAkBa/RFd32GrvWWj7w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801479;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=GO4d/CrsOhR28HwuMbAhECKWLHdlnGgz4E2dZWaYK7w=;
	b=PyTO47Ig0oAPwMM8BSmfNWEAHTmd2d1zhIEGWGVau9lUonmRapmDQzSosQMc5obEdIwD
	 SvF8jyB9oSfwIsvn8mVvUEZAXtF0N/Uf7f3NmKLyKzDAlrx1rt+CR4r7eBFfJahKhz5G1
	 sqhHJbg9J8XrgmBVYltfUnPE6QrE7020lBb9Gp7JaYs/NWvLzgiz9TXDbW/xd6oWLFEk4
	 urWf86oPccUr9/Q1hurmQfga7suSqXePjGmgQfMC4eIlgxAyr6zXS/a7aiobPl4FFxcfH
	 kBcXulhN58Kk6+phKi5pynzx3Hm1zyxZkF83kSOW6mansAJx+piiEJWA6P+CiQL2eDw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eoTtJ16b;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D57DC606A335;
	Wed,  4 Nov 2026 14:11:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eoTtJ16b
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AE00B1F00A1E;
	Wed,  4 Nov 2026 14:11:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801478;
	bh=GO4d/CrsOhR28HwuMbAhECKWLHdlnGgz4E2dZWaYK7w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eoTtJ16b5OVuG8Z/3xCsRprYPgoCFtmEo8ZRJzesgsszch1uXNYuVbgykP1S9dtsp
	 pfSMP8s0yss7/THdWEbzZpb0kIOMfk0gTeXfzZJVrgnLvKa51YsSaFMq5ETv+rRj9/
	 PKgXrmEOYjy5a3m1Rajhh3BNpUsXUxCANRvI891zdGJa02CBM6cnC4PkPrgMyrGlp7
	 n0nU/7XfVCtbABxa4H63eG61JwHyxokQjvYxCfmAHd0qJ93/DcYAvqu4V0MN9r6T5k
	 YpY2nc+MfRUVtahsAh7t42xruGz26rhC4159yeQB1kU1wZhGiRY3sS6maKg2k0uhTZ
	 ZZ615naAnBRSw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:03 -0500
Subject: [PATCH v8 03/14] NFSD: Remove hard cap on duplicate reply cache
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
Message-Id: <20261104-duplicate-reply-cache-v8-3-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3485; i=cel@kernel.org;
 h=from:subject:message-id; bh=t8G27LUDpaP09iMOryqKHDtv2R52uxZaNtibo2VdTLo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0AQIzCdV24UEV/tlPNaOG/uTubNeg1rHirH
 yelAqZNJsCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AAAKCRAzarMzb2Z/
 lxuTEACeueXAx9an6eg3FjPo5jPRAfGWc8oqY1yb9sYjFzp8arbuC375RgoBvtM8CmnSEG4aMRa
 acUDZBSOyTkoPZmRBssCjYk0MMk7ihPd4KCez+k6x+4nrxmSEPebJBkGhH3uuKl2M6Dp9EYi65u
 jbj96AjpzWZlu5XcpByWGsCeCY5W97OByxxuk3OwWBYwwlnZZsW7/qbm1E+t+7Kv3g4OHYbK9Vn
 YBFFLDVpA07261g6qPQIODkWNbzxdC256ZN0vgWBb0mOarEfy/slCJWZNh0FR1G4UTjLIHxqds3
 WXt5X49CwvHbHKsbvDso8R7aB6YchK7jRcD47TxCWwhcUGXRSv2skd8vziSfRl0gOb+T0KBoBCi
 HJgF50RA5xrCmX5yIdkh5G3FL0OsyXgWuLV4h6kAXPzQwrN4TgB4poZpsNeZiJn9q7Yt3/wRUH7
 1I4x3XexuCsHjNBQm3UNpTQHCDa8JpDszEXUc14Njc+23SaSZhtj82uXwbLm8Um3LWZ/Wfbxxzo
 KSCZ8alTZicAh6PhaKmylOrmOSE4zkti56ZBtcu9TjFVpZT6jEfbThftNeA71CS2U0J4R21j8oZ
 J8yMkCzyL6C9nbNXWHVpkxELqSkxicRyTWft4PuENqyWnNBaLjqauxo5fWc949fGRJ/oLMpM15Z
 NZA5JziNNikg/Vw==
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


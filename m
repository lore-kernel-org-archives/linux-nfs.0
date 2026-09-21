Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B44D54DBD73;
	Mon, 21 Sep 2026 16:32:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790008324; cv=none; b=lnixAq0tmiwnkXEXkdAolc/8oR70hsOVEvjxGUxvjlkxaj5GPAPTEiNFI8+R9plQTnJ5U6oJ8hvi99nhWY2TKvCjxvbpQITfvlwuuMJ2hxsiYb2CD9YE+4p63yHUoVPGeXLftxb2C1wrB7u78PiTzcowKuoK2Jd0IcmLSPhPW14=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790008324; c=relaxed/simple;
	bh=2oZ0C4rrZdQq8YXBTdLHuj86FMjG5SxOrZXM7KteSNI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Ii2wOLWvUpA5bC9GF+TOUda8LqM2eT7ngBtYgF8eI5LSMwGkrZ2Bm/URge58AgIcUZxewjjmH6sz5lItT3UFF4CTw5O/ZmerZt9PcDnHVGeTX/ENbfx2Dp0lSjPGgIbQATRxVdppgm4leQT6KCb5RV2GqBTNvoUUCwseqIZSle8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E7N1mQ6V; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E7N1mQ6V"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8A6931F00899;
	Mon, 21 Sep 2026 16:32:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790008322;
	bh=Fymo/hKbtpEhdg3Ssl8vrlmMoFXN8ntE3Z1H/UUKI0M=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E7N1mQ6VzXPVoh8p3OvjVIeQobW82XBmHf3nZtoXfizfhEPada26yFNe6cg6/ipSt
	 cf9KBjbXzAlE9Rh08m1PSs4fbgrxxXpwX5K6DZCnNADnAhSOGtSAjkBNIvESXWhWe5
	 yQ2qdNsrcW8WK0VsY8lhZ72xyo/JKtDcvhipC55lYQcuKsFNX+bDfNJ3nwGUBLuGZV
	 iRMfRlm8q1sjIL4+mU2m5isojsP5I/tek6thtLs2ZDVwHben+Pl8uQwUv0UHrOUYYW
	 bn3cWuSzVyf38euBtYvCk+50P7lqwawE5jSX3LLMAH6E9ICAY7HJeRyDaMnx5KglUC
	 aLZaWhtwCPGug==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 21 Sep 2026 12:31:44 -0400
Subject: [PATCH 5/8] nfsd: give the open file cache its own mutex
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-nfsd-per-net-mutex-v1-5-4a7287f6504c@kernel.org>
References: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
In-Reply-To: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6212; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=2oZ0C4rrZdQq8YXBTdLHuj86FMjG5SxOrZXM7KteSNI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsVv7YTvq8av8IafnTAKNHlGFvqZrI6HYjYLBN
 Dp+mhC8pHWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarFb+wAKCRAADmhBGVaC
 FTSYEADNDFqB3d9jeSpXcwcWeuoq2yuu8FRUpqbIFQmQt6uOf+1uTamG9xsn8w2uO0De8oiCDys
 PTvGZAx+/mM9JF9yyd3xrpevVNaVhWeCm77b4YWap0z0dnxz91qnT2sQE7qtgNKoeV/iwUiHlLH
 Jj3wh0Y58kL+XYfCFGcTTKshZZ3U3fvKPZNd2sMRRG6K8xDw9V4uCXxHjNc4BZhG6CuF8brA1TK
 XkRiU5ZpqqnEBMZP77aXkY5FzzwuAOd15xXl0eGH7XQAM2AkvpfZarHyYhavPELZIBYGwZnRQIO
 A7EutZhTsxiTwmsxGA1Uv4Lt9Y9pCwV6gRFS4iQdAIbaza/BXLx/j0cTQk5FesswrueEu0Vibx6
 rdzPT/ViJ8OERRy/iJN1h0MIWToe5U8FZVRjg4RpPaJ3kFWxECx+h7X02RV0/oQo9PBKtCj/rEU
 4mSk4niWh2iFEu+oMGEQ+M8VejvL0KEWeHSmjznavx6as+Ux+gq3LrmzDlTPxHgA+i91u2L9IsU
 yZDj7v9aSjshOh/hjSAhPnZ+XwQVygh452z8b08jjitPVO0NH1RuvUjWVKbIrOio9t7lF5+rVlo
 9mt2Kb/YQy/fwrS4C6HcTlZ/iz1Dg2uZnUv4Q0IBQHJKFUdzzbCwYUiKdMyfR871Yif+CbVJPmZ
 NyQrlsy279MKpqw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_global_mutex still serializes file cache flushes against server
start/stop in unrelated namespaces. nfsd_file_cache_purge() is reached from
expkey_flush() on every "exportfs -f", which makes it the only frequent
taker of the global lock -- and it has nothing to do with nfsd_users or the
NFSv4 global tables it would be waiting on.

Move NFSD_FILE_CACHE_UP and the objects it covers (rhltable, LRU, slabs,
shrinker, fsnotify groups) onto a nfsd_file_cache_mutex private to
filecache.c. nfsd_file_cache_init() and nfsd_file_cache_shutdown() take it
themselves rather than asserting the caller holds the global one, so
nfssvc.c no longer needs to know how the cache locks itself.

nfsd_global_mutex is left holding only nfsd_users, the notifier count and
user_recovery_dirname, all of which are touched solely on server
start/stop.

Ordering is nn->nfsd_mutex outside nfsd_global_mutex outside
nfsd_file_cache_mutex. The cache mutex is reached three ways, all
consistent with that: from nfsd_startup_generic()/nfsd_shutdown_generic()
under the global mutex, from nfsd_shutdown_net() under nn->nfsd_mutex, and
bare from expkey_flush() and the filecache stats file. Nothing called with
the cache mutex held takes either of the others.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/filecache.c | 39 ++++++++++++++++++++++++++++-----------
 fs/nfsd/nfssvc.c    |  9 +++++----
 2 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 501772bc8f8d..179362e5394b 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -67,6 +67,17 @@
  */
 static DEFINE_SPINLOCK(nfsd_gc_lock);
 
+/*
+ * Guards NFSD_FILE_CACHE_UP and the host-wide objects it covers: the
+ * rhltable, the LRU, the slabs, the shrinker and the fsnotify groups.
+ * Held across cache bring-up and teardown, and by readers and walkers
+ * that need the cache to stay up for the duration (->cache_purge, the
+ * stats file).
+ *
+ * Nests inside nfsd_global_mutex and inside nn->nfsd_mutex.
+ */
+static DEFINE_MUTEX(nfsd_file_cache_mutex);
+
 static DEFINE_PER_CPU(unsigned long, nfsd_file_cache_hits);
 static DEFINE_PER_CPU(unsigned long, nfsd_file_acquisitions);
 static DEFINE_PER_CPU(unsigned long, nfsd_file_allocations);
@@ -869,9 +880,11 @@ nfsd_file_cache_init(void)
 {
 	int ret;
 
-	lockdep_assert_held(&nfsd_global_mutex);
-	if (test_and_set_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1)
+	mutex_lock(&nfsd_file_cache_mutex);
+	if (test_and_set_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1) {
+		mutex_unlock(&nfsd_file_cache_mutex);
 		return 0;
+	}
 
 	ret = rhltable_init(&nfsd_file_rhltable, &nfsd_file_rhash_params);
 	if (ret)
@@ -937,6 +950,7 @@ nfsd_file_cache_init(void)
 out:
 	if (ret)
 		clear_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags);
+	mutex_unlock(&nfsd_file_cache_mutex);
 	return ret;
 out_notify_group:
 	fsnotify_put_group(nfsd_file_fsnotify_group);
@@ -1011,16 +1025,16 @@ nfsd_file_cache_start_net(struct net *net)
  * nfsd_file_cache_purge - Remove all cache items associated with @net
  * @net: target net namespace
  *
- * Takes nfsd_global_mutex so the cache cannot be torn down underneath the
- * walk.  Callers must not already hold it.
+ * Takes nfsd_file_cache_mutex so the cache cannot be torn down underneath
+ * the walk.  Callers must not already hold it.
  */
 void
 nfsd_file_cache_purge(struct net *net)
 {
-	mutex_lock(&nfsd_global_mutex);
+	mutex_lock(&nfsd_file_cache_mutex);
 	if (test_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1)
 		__nfsd_file_cache_purge(net);
-	mutex_unlock(&nfsd_global_mutex);
+	mutex_unlock(&nfsd_file_cache_mutex);
 }
 
 void
@@ -1045,9 +1059,11 @@ nfsd_file_cache_shutdown(void)
 {
 	int i;
 
-	lockdep_assert_held(&nfsd_global_mutex);
-	if (test_and_clear_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 0)
+	mutex_lock(&nfsd_file_cache_mutex);
+	if (test_and_clear_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 0) {
+		mutex_unlock(&nfsd_file_cache_mutex);
 		return;
+	}
 
 	lease_unregister_notifier(&nfsd_file_lease_notifier);
 	shrinker_free(nfsd_file_shrinker);
@@ -1078,6 +1094,7 @@ nfsd_file_cache_shutdown(void)
 		per_cpu(nfsd_file_total_age, i) = 0;
 		per_cpu(nfsd_file_evictions, i) = 0;
 	}
+	mutex_unlock(&nfsd_file_cache_mutex);
 }
 
 static struct nfsd_file *
@@ -1476,8 +1493,8 @@ int nfsd_file_cache_stats_show(struct seq_file *m, void *v)
 	unsigned int i, count = 0, buckets = 0;
 	unsigned long lru = 0, total_age = 0;
 
-	/* Serialize with server shutdown */
-	mutex_lock(&nfsd_global_mutex);
+	/* Serialize with cache teardown */
+	mutex_lock(&nfsd_file_cache_mutex);
 	if (test_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1) {
 		struct bucket_table *tbl;
 		struct rhashtable *ht;
@@ -1491,7 +1508,7 @@ int nfsd_file_cache_stats_show(struct seq_file *m, void *v)
 		buckets = tbl->size;
 		rcu_read_unlock();
 	}
-	mutex_unlock(&nfsd_global_mutex);
+	mutex_unlock(&nfsd_file_cache_mutex);
 
 	for_each_possible_cpu(i) {
 		hits += per_cpu(nfsd_file_cache_hits, i);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 5cb92c3829f9..b2c215775e08 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -66,11 +66,12 @@ static __be32			nfsd_init_request(struct svc_rqst *,
  *
  * nfsd_global_mutex covers only what is genuinely shared between
  * namespaces: the nfsd_users refcount and the host-wide resources it
- * brings up and tears down (the open file cache and the NFSv4 global
- * tables), the address-notifier registration, and user_recovery_dirname.
+ * brings up and tears down (the NFSv4 global tables, and the open file
+ * cache -- which guards its own internals with nfsd_file_cache_mutex),
+ * the address-notifier registration, and user_recovery_dirname.
  *
- * Lock ordering is nn->nfsd_mutex outside nfsd_global_mutex.  Nothing takes
- * two namespaces' nfsd_mutexes.
+ * Lock ordering is nn->nfsd_mutex outside nfsd_global_mutex outside
+ * nfsd_file_cache_mutex.  Nothing takes two namespaces' nfsd_mutexes.
  */
 DEFINE_MUTEX(nfsd_global_mutex);
 

-- 
2.55.0


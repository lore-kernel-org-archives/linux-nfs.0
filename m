Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2A25538D91;
	Tue, 22 Sep 2026 11:34:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790076866; cv=none; b=n9Dzu/T654eiekOKKb0gBHztQw2NLwn0kMyvNetKRVJyIii9NbhgYo/pla2OtshZivOwOZZzoXNU28G7SfwLN+rCc4lmTLQDEv66LT8HLMobxbwcOuA8R99J0V5bx/vgLBrRzP8vRA7Ufrvk0YFSGxsH+6AVxwrOryCXi6ZN2J0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790076866; c=relaxed/simple;
	bh=9yOyKfLbgAQCiwsB8y/tXz9WKfPm1n0GduTeDPF6LG0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LJZlV6loADL6TShly9oWpg+vvZXZxodXpzLS4Qe+bRHUfcamqk869OlbHoggNkDAx/dJ++4zEX08sULz9qO98M/BHvDSLCjZPrcMb9/1NePAyNL3lPr6p4M1SvJ5T8OLTiTVA8I/bQl225CL5NMhfIP2gwrrQlF0RBqT4s83GVQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TSkWoyIo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TSkWoyIo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A47491F00893;
	Tue, 22 Sep 2026 11:34:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790076864;
	bh=mBQU3uBQGhPYntNb5Yath9p2lTfYe1lGY1j/HkI3Jx4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TSkWoyIoeaOFX4inbfUq+MSUMJMNoSxanTrG2qvnlhjwVu254+C9Ub0My0gjMyodg
	 cBHEb/MZhjumgEKSpbIz/gocwjGtEpjbfYfhXBM6m6z4bSJUZg1aqWAEp5WsBXn3u9
	 cAGaVomkenskgsb8Bk9LpJI9TrdCnVMDSnIt3uT7sg16rkA2KBPfjQnptMKDQe5Ib1
	 CkzH3k20l/RXfpOGfVW0PJvFpmsJ4SEPiBGcULJ7y6Ka2dJsHjbtd5qr1tXOOUHjCI
	 hptjl7mswpVPaTdIUP3jb3FxRmOrbE5ZKh/qf4qLAnJzk4rRTwPWBoI6E6riAMq/QW
	 THczv4NfLfwlw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 22 Sep 2026 07:34:06 -0400
Subject: [PATCH v2 5/8] nfsd: give the open file cache its own mutex
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260922-nfsd-per-net-mutex-v2-5-4a5da8243a73@kernel.org>
References: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
In-Reply-To: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5329; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=9yOyKfLbgAQCiwsB8y/tXz9WKfPm1n0GduTeDPF6LG0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsme50sVKamje/qJ8dxUQVn0zulVB498ElBMWG
 N/v0VwQd6yJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarJnuQAKCRAADmhBGVaC
 FetOEACnEZVW4f7WSCmBfIH82E1Km7q41BDWEbBNMvaGUMFxV5qrXG38gEi5NlnccncMa1TVo5f
 rMurSuL/r+rCCHUharONw8+KlTTTJ1oqy323NvrrGNTd/4RxfH2VD+ey5Jz/wJXdADNIUH1FUyI
 Jcq9Q7YCTS4qFfjwN2y/10YNSHptVkMFbvss7HkE28BmthI1uBQ4X6AWnewGj4vn7ZQ7WhVqVq2
 ScbHDmvF8R2ReddIPD4YgsB4mfrWCq0QddFPEDb8akOulzzIRDt0p3aUwU+Dqqh+frYsqEElo1Y
 8QbmpFGY2hdRkU1PY55kvjJPi7cbPXKT4TLC95o3fvucIINmYoCT+WTmRdAH8iAKm0uoPPksPhz
 kSyrEy+3/4+2pAKIb2ZyNDhCeEpQ45RkqbX1bqB0sEgcoMdVskL3mCLE603LcS0amfg8oKNUczj
 u89oG05TebWKTh9b22MpvrWKEuwag54XMf8qu8h4xR7Up+K6C9tGWfCqT2QbjFSW2JbX4/FEns1
 5ZodEBzQCegml2IKh0W6U+By8mJaP1HDFuFQd3lAiIHvAFgW2CAz1dp8gQa0FcpEUD3uW0DgZDx
 kMyzJsYT4crJAxPEm1j5bXHQY4NrybKgh+LsoBCuvXa7wjQJ7hlZy6Ggb4o7PdwoSUTsklm/8kD
 NQUZ29Yp30Fb1Iw==
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
 fs/nfsd/filecache.c | 29 ++++++++++++++++++++---------
 fs/nfsd/nfssvc.c    |  9 +++++----
 2 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 501772bc8f8d..42bd8c7859cf 100644
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
@@ -869,7 +880,7 @@ nfsd_file_cache_init(void)
 {
 	int ret;
 
-	lockdep_assert_held(&nfsd_global_mutex);
+	guard(mutex)(&nfsd_file_cache_mutex);
 	if (test_and_set_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1)
 		return 0;
 
@@ -1011,16 +1022,16 @@ nfsd_file_cache_start_net(struct net *net)
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
@@ -1045,7 +1056,7 @@ nfsd_file_cache_shutdown(void)
 {
 	int i;
 
-	lockdep_assert_held(&nfsd_global_mutex);
+	guard(mutex)(&nfsd_file_cache_mutex);
 	if (test_and_clear_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 0)
 		return;
 
@@ -1476,8 +1487,8 @@ int nfsd_file_cache_stats_show(struct seq_file *m, void *v)
 	unsigned int i, count = 0, buckets = 0;
 	unsigned long lru = 0, total_age = 0;
 
-	/* Serialize with server shutdown */
-	mutex_lock(&nfsd_global_mutex);
+	/* Serialize with cache teardown */
+	mutex_lock(&nfsd_file_cache_mutex);
 	if (test_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) == 1) {
 		struct bucket_table *tbl;
 		struct rhashtable *ht;
@@ -1491,7 +1502,7 @@ int nfsd_file_cache_stats_show(struct seq_file *m, void *v)
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


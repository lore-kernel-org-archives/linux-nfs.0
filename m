Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB61C175A6C
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 00:12:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784247158; cv=none; b=IinpLWIl6rjRkLxBOunmTOlX59onq/4RbwRq37eors86JzHCYbLRJLFJH8r45lYukasjwwPAKJmONara7t4ucwb+H1vtTG5jHDarxi/BvgWP+g8a2vcbWkS6pc/htrkkttvPwAFoaWiGeHBenClngi2xzHe2e/K5BM9AJdkYzbo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784247158; c=relaxed/simple;
	bh=6k0L7mW0CqpAw8y4CwORCKYaFsbofLWUJlagYbmXBSs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kkbyPsb35wVuLs/Vr2nv1vjN18YRlc8i7dV+NVXyg8ou9evgtZd3deyjNa6d4F2oCUOAEac+bcL+I2zPXNa48AV+niZeKBOQgXrsslmlErQHGokx/3Wrosb8LzNE6jpCTDr2RBkXHry3n+EFmXKD+RKjXD6+/ctq0miwqiCa6m8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jv2pclMK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jv2pclMK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 47D571F00A3A;
	Fri, 17 Jul 2026 00:12:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784247156;
	bh=0DmK2k0R5TbjJIDSEnycdHL1QjG+d39c8QA9TiWPMmo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jv2pclMKKlAS4WMlAEuvkucC+qBYrJJLaIt9LQNoBpG0cCqhYFzucHX6JVGmReFBJ
	 sd8st3V+/UNXT8im7YaYwMZGPrEMgHCaY89/IARWEoOrt0JhPW2ri5Mjw6nEH7xpiw
	 IyqUa/0E3P3WtxMBVLZGpIZOp+fB3DAGuyb2d82eSrJHzgwUWBd6SxsZHkZLA6Yu3G
	 AKUdUSbQCYmsi4Fn9vFNEemjvSRW5yiycP9dERrKGQ9/uZfPWHWKkfbPe3uyoHqJ9F
	 MJmteFO7I3eGmA1n/RiVFxoGZAERXzg6hMoRtCBFiwRckqjSat+AA8K8ISTKDssoLI
	 IGbzqYSe+yETw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/5] NFSD: Eliminate percpu counter contention in reply cache statistics
Date: Thu, 16 Jul 2026 20:12:30 -0400
Message-ID: <20260717001232.438792-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717001232.438792-1-cel@kernel.org>
References: <20260717001232.438792-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Each RPC passes through nfsd_cache_lookup(), which increments one
of nfsd_stats_rc_hits_inc(), nfsd_stats_rc_misses_inc(), or
nfsd_stats_rc_nocache_inc(). These helpers update
per-net-namespace percpu_counters with percpu_counter_inc(),
which applies the default batch threshold of max(32, 2*nr_cpus).

Once a CPU's local delta reaches that threshold, the update folds
into the shared counter under its global spinlock. On a busy
multi-CPU server this produces lock traffic on a counter cacheline
shared across all CPUs, growing with the request rate.

Switch to percpu_counter_add_local(fbc, 1), which batches with
INT_MAX so that increments always remain on the per-CPU fast path.
This matches the treatment already applied to the IO byte and DRC
memory counters. All readers of these counters use
percpu_counter_sum_positive(), which sums the per-CPU deltas under
the global lock, so read accuracy is unaffected.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/stats.h | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
index 15d30c045dc3..598ea45d1722 100644
--- a/fs/nfsd/stats.h
+++ b/fs/nfsd/stats.h
@@ -16,19 +16,39 @@
 struct proc_dir_entry *nfsd_proc_stat_init(struct net *net);
 void nfsd_proc_stat_shutdown(struct net *net);
 
+/**
+ * nfsd_stats_rc_hits_inc - Count a duplicate reply cache hit
+ * @nn: target network namespace
+ *
+ * These reply cache counters are updated once per RPC. Readers use
+ * percpu_counter_sum_positive(), so local batching does not affect
+ * read accuracy.
+ */
 static inline void nfsd_stats_rc_hits_inc(struct nfsd_net *nn)
 {
-	percpu_counter_inc(&nn->counter[NFSD_STATS_RC_HITS]);
+	percpu_counter_add_local(&nn->counter[NFSD_STATS_RC_HITS], 1);
 }
 
+/**
+ * nfsd_stats_rc_misses_inc - Count a duplicate reply cache miss
+ * @nn: target network namespace
+ *
+ * See nfsd_stats_rc_hits_inc() for batching rationale.
+ */
 static inline void nfsd_stats_rc_misses_inc(struct nfsd_net *nn)
 {
-	percpu_counter_inc(&nn->counter[NFSD_STATS_RC_MISSES]);
+	percpu_counter_add_local(&nn->counter[NFSD_STATS_RC_MISSES], 1);
 }
 
+/**
+ * nfsd_stats_rc_nocache_inc - Count a request not cached in the reply cache
+ * @nn: target network namespace
+ *
+ * See nfsd_stats_rc_hits_inc() for batching rationale.
+ */
 static inline void nfsd_stats_rc_nocache_inc(struct nfsd_net *nn)
 {
-	percpu_counter_inc(&nn->counter[NFSD_STATS_RC_NOCACHE]);
+	percpu_counter_add_local(&nn->counter[NFSD_STATS_RC_NOCACHE], 1);
 }
 
 static inline void nfsd_stats_fh_stale_inc(struct nfsd_net *nn,
-- 
2.54.0


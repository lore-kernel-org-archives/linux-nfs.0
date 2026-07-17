Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66D7A175A69
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 00:12:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784247157; cv=none; b=IHcjVBOEMzdv9Mlhk8+Wqq1jfyIwp/1mXRD8zxNvZ4m5t7AbsFYtrbT6Zj/1jXRY2MwjlOHM+qooBfCDwmUDCTo5AaZEwKXwaxK4olKJnJU5HNEsDgqwqen2lRwzYL9bFNXbNyrs010n7snThAPIdY0OrXcGHt85um+bC1//+mM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784247157; c=relaxed/simple;
	bh=A1Ik+sBy1Bpu6f5lA5Qsz4tYKvOoHFMR0Ma4yRwXIkE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lQUCI/rhyeV91Om8nTP3zE9Lk+3KHx3gg+psJ/S1Dp3hH7H7EBsx0hOfnd7Om9DKvd/kTRZB+3Jt9Y3s6HYclc9cFKz3VvfOh3TTa8LkMM90anUSM5V8cUSEZPHB1F6rvMrgkMTjEA60YTCtN1iJTCb0C/iYA9Xzbz/BDr5RZx8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aVUWm+HR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aVUWm+HR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8C9751F00A3E;
	Fri, 17 Jul 2026 00:12:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784247156;
	bh=2+WyYAiaHRwAPwQDUXg5jQl2HWbEUAFRonONPNcah+U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aVUWm+HRuAG5xJzCxQUB7FP33VkGkvBpZloohCD6F5gAIBZVdILfrY6yN3YdJwLa3
	 1mecPnw6ubftmWQXyP5df5RaKh30dV/EAYdqDGF/VojKv8aaJYZAlA3UVbkhiittaI
	 F6CPyBKN5Jh5Hn8hj3u69iQ9z4GmauJed12uye9b2Gsxqha38A2xyk7fDbCun6YwUa
	 17wbGWiJIgO5UYTthZuMrIfXm5Q++okwYdMQ2Yxy7c3eHPmVvqKq139snE1nRfCQG+
	 v1YwIO+32XI+2cdu1WwVSgt+h8zxrs1X8bXVs1dI2QWx76jSxilxxYUA781dzVIfxn
	 /IC4BpdjVEBwg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/5] NFSD: Eliminate percpu counter contention in DRC memory accounting
Date: Thu, 16 Jul 2026 20:12:29 -0400
Message-ID: <20260717001232.438792-3-cel@kernel.org>
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

The DRC memory usage counter (NFSD_STATS_DRC_MEM_USAGE) tracks
bytes, but percpu_counter_add() uses the global percpu_counter_batch
threshold of max(32, 2*nr_cpus). Each DRC entry add or removal
updates the counter by sizeof(struct nfsd_cacherep) (~144 bytes),
which always exceeds the batch threshold. percpu_counter_add()
then acquires the counter's global spinlock on every update,
serializing all nfsd threads.

On a 10-CPU NFS server handling a high rate of non-idempotent
NFSv3 operations, this lock accounts for a measurable fraction
of total spin lock overhead because nfsd_cache_lookup() both
inserts a new entry and prunes up to three old entries per RPC,
producing 4-7 global lock acquisitions per operation.

Switch to percpu_counter_add_local() and percpu_counter_sub_local(),
which batch with INT_MAX so that updates always remain on the per-CPU
fast path regardless of the amount. The only reader of this counter uses
percpu_counter_sum_positive(), which sums the per-CPU deltas under the
global lock, so read accuracy is unaffected.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/stats.h | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
index 87736b7fbf28..15d30c045dc3 100644
--- a/fs/nfsd/stats.h
+++ b/fs/nfsd/stats.h
@@ -60,14 +60,32 @@ static inline void nfsd_stats_payload_misses_inc(struct nfsd_net *nn)
 	percpu_counter_inc(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]);
 }
 
+/**
+ * nfsd_stats_drc_mem_usage_add - Add memory used by a cache item
+ * @nn: target network namespace
+ * @amount: byte count
+ *
+ * percpu_counter_add_local() keeps updates on the per-CPU fast
+ * path. The sole reader, percpu_counter_sum_positive(), sums the
+ * per-CPU deltas, so batching locally does not lose accuracy.
+ */
 static inline void nfsd_stats_drc_mem_usage_add(struct nfsd_net *nn, s64 amount)
 {
-	percpu_counter_add(&nn->counter[NFSD_STATS_DRC_MEM_USAGE], amount);
+	percpu_counter_add_local(&nn->counter[NFSD_STATS_DRC_MEM_USAGE],
+				 amount);
 }
 
+/**
+ * nfsd_stats_drc_mem_usage_sub - Subtract memory used by a cache item
+ * @nn: target network namespace
+ * @amount: byte count
+ *
+ * See nfsd_stats_drc_mem_usage_add() for batching rationale.
+ */
 static inline void nfsd_stats_drc_mem_usage_sub(struct nfsd_net *nn, s64 amount)
 {
-	percpu_counter_sub(&nn->counter[NFSD_STATS_DRC_MEM_USAGE], amount);
+	percpu_counter_sub_local(&nn->counter[NFSD_STATS_DRC_MEM_USAGE],
+				 amount);
 }
 
 #ifdef CONFIG_NFSD_V4
-- 
2.54.0


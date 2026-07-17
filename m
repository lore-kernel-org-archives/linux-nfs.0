Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 948967081F
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 00:12:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784247158; cv=none; b=fEKvlGqDcCvThZaftiyo0nzfqowdNWg/ywU0/9WYqAVeHNbvpJvJTkk1uasIpIas5i3jZhyF+JnM3gQJvOtdJm9MJ+rW/1UXWWDHR8gHZUKsk5OP0Y6vBhUZTRo7fSGxYiNKqvUL4XbgRj3dsQf8Wgbp6QTgCULqixXAAVvi59M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784247158; c=relaxed/simple;
	bh=ZTe6JkD/1CwGwBKSai7Eo+z9IbvALEniurTgLrnT48g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jCEmhVL9ynJvjDdaKyK9csjdcPSJSae3y1SR9RWoD+H8BcbE63COf1Pm7YMFEah9kd9K4qEjUb4Os7duqFHqLALLWpD2VhXFYFjHfhU9xbwkhIUB6e2AvomwNJcMYepg8PEkJGqAWJ9g0ZaDRM4IMzJ+O0OauNG4zCcoFmYOy7U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PJD+W8gM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PJD+W8gM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 04B781F000E9;
	Fri, 17 Jul 2026 00:12:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784247157;
	bh=KlmmrxcyUrET9sM3c5u9dkYzykOjsiN5/91VZyhfGls=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=PJD+W8gMN4etIyAIO7SprPY6KfviIrcuNWrqDGl9Fx4MeLYQt4j5TVR0Fb+RpSETF
	 2fvEUB3am5wz+KM9fgqOTY2LVztiWG3ZlsX3Sqo4p8HoD79JgY4a8E0y5kOW/+Raq6
	 3QiqD3WQ/vpYk+NZEJSlyJzhU3dKEKoyh0TCTd9gfc8DPP99ST67875ZWoaU/Q9HR8
	 Qp82hxpgkYaZye9vj/VpCxbmV0SDs7ANs8K9Mvm/DvTMxME9zkzz+Nh4r+rxZMoPGb
	 jkBhy5/SaUFVa64Y2Vl0TNbsH0KtMrq0A1UQ63CoZ+jE6ArFFtQ/7VvOcMh3HxZQ3+
	 xTuKw+WumZTnQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/5] NFSD: Eliminate percpu counter contention in IO byte accounting
Date: Thu, 16 Jul 2026 20:12:31 -0400
Message-ID: <20260717001232.438792-5-cel@kernel.org>
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

nfsd_stats_io_write_add() and nfsd_stats_io_read_add() accumulate
byte counts in per-net-namespace and per-export percpu_counters
using percpu_counter_add(), which applies the default batch
threshold of max(32, 2*nr_cpus).

For a 4 KB NFS WRITE, the amount (4096) always exceeds this
threshold, so percpu_counter_add_batch() acquires the counter's
global spinlock on every update. Each WRITE RPC updates two
counters (per-net and per-export), producing two global lock
acquisitions per operation. Profiling on a 10-CPU RDMA NFS
server shows 0.44% of total CPU cycles spent contending on
these locks during a small random write workload.

Switch to percpu_counter_add_local(), which batches with
INT_MAX so that updates always remain on the per-CPU fast
path regardless of the amount. All readers of these counters
already use percpu_counter_sum_positive(), which sums the
per-CPU deltas under the global lock, so read accuracy is
unaffected.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/stats.h | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
index 598ea45d1722..c8d7e3934c33 100644
--- a/fs/nfsd/stats.h
+++ b/fs/nfsd/stats.h
@@ -59,20 +59,42 @@ static inline void nfsd_stats_fh_stale_inc(struct nfsd_net *nn,
 		percpu_counter_inc(&exp->ex_stats->counter[EXP_STATS_FH_STALE]);
 }
 
+/**
+ * nfsd_stats_io_read_add - Count number of bytes for an NFS READ
+ * @nn: target network namespace
+ * @exp: target export
+ * @amount: byte count
+ *
+ * These counters are updated on every READ request. Readers use
+ * percpu_counter_sum_positive(), so local batching does not affect
+ * read accuracy.
+ */
 static inline void nfsd_stats_io_read_add(struct nfsd_net *nn,
 					  struct svc_export *exp, s64 amount)
 {
-	percpu_counter_add(&nn->counter[NFSD_STATS_IO_READ], amount);
+	percpu_counter_add_local(&nn->counter[NFSD_STATS_IO_READ], amount);
 	if (exp && exp->ex_stats)
-		percpu_counter_add(&exp->ex_stats->counter[EXP_STATS_IO_READ], amount);
+		percpu_counter_add_local(&exp->ex_stats->counter[EXP_STATS_IO_READ],
+					 amount);
 }
 
+/**
+ * nfsd_stats_io_write_add - Count number of bytes for an NFS WRITE
+ * @nn: target network namespace
+ * @exp: target export
+ * @amount: byte count
+ *
+ * These counters are updated on every WRITE request. Readers use
+ * percpu_counter_sum_positive(), so local batching does not affect
+ * read accuracy.
+ */
 static inline void nfsd_stats_io_write_add(struct nfsd_net *nn,
 					   struct svc_export *exp, s64 amount)
 {
-	percpu_counter_add(&nn->counter[NFSD_STATS_IO_WRITE], amount);
+	percpu_counter_add_local(&nn->counter[NFSD_STATS_IO_WRITE], amount);
 	if (exp && exp->ex_stats)
-		percpu_counter_add(&exp->ex_stats->counter[EXP_STATS_IO_WRITE], amount);
+		percpu_counter_add_local(&exp->ex_stats->counter[EXP_STATS_IO_WRITE],
+					 amount);
 }
 
 static inline void nfsd_stats_payload_misses_inc(struct nfsd_net *nn)
-- 
2.54.0


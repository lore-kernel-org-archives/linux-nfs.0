Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 327684457C0;
	Mon, 31 Aug 2026 18:22:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200534; cv=none; b=ZEPG1tuxZk2SwLPnGYzeygWQ1WTM4PQLn8aqiKxbamjN1WtlGJA5NpNxI2xKYsu5kRXUkSubfdUB+D8iToAATahz7/2ewHIomwrw0cuzofj6w+IcTknL4YyVzdFwLDDb/qoBzW0XlxPbWz2zV4wLzbE1UB6tb51ryBexySgk0+s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200534; c=relaxed/simple;
	bh=dq1K12sW81ZZDaOE6GK1QC+Xtcdmi0Mgy2uQbeewkGg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Y61vTZCL1L/iT7b/nJUsAAk0gHqKn1v2xqcL0taGtsr6x0Jp2E43rw5V1pXn/q9Lzbs4v25AjZSYCqCW1O2LtGmxOvUpd9RgI48kUYJi/iifU40DYlS3AWf52PnFE6X9U8kLqwOEuAJh3La1yum4RA4KpZGbkYcZiaMGwYe9Yu4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ddnYDz7q; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ddnYDz7q"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 827D21F00ADB;
	Mon, 31 Aug 2026 18:22:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200533;
	bh=1KLBJGuRObI2XbOROtGtBccuic6ok9txtKzBKn2YGZ0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ddnYDz7qG/marazDz04oMr/aLqcrhTwgJyqoBlNXis64Zo4xr0LaIC6wVKd4mbWod
	 2W4YCX6F3MS1EoCV97Q+12jRm+rLlbcUnYYUlfMlGNKWkUG+T7KJKkEgkBgBXn/OGp
	 lMZQWSNwPVJAVbyPna61O9QYMgl0Wz7tMa98R6VIgSIJlEe+afV+jMZGurjSY6qcA5
	 oACS2rExNX1rjQv/zKgs/m4R/q+FMb9ppatTCEhqPwd+rvwiwG6q8Hxedfk2CbtWIG
	 lKXnsA3x1UM80Xchn9cDn6KltNXrssIm2n2R8C5/whTbZlpR7vh6DcTwqRwAuAKRvO
	 OWCglpyKCld+w==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 31 Aug 2026 14:22:02 -0400
Subject: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-performance-v1-6-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
In-Reply-To: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2114; i=cel@kernel.org;
 h=from:subject:message-id; bh=dq1K12sW81ZZDaOE6GK1QC+Xtcdmi0Mgy2uQbeewkGg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZPSA8/uSXNJdaVPVpYuQocZE7GZh9gifGsf
 Mvw5RPDVXOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGTwAKCRAzarMzb2Z/
 l14BD/wP3+aKMjx5r9lfpl81bv5C5oYEMBB9TWhRPFsnUFCuuFZQjjYnirV2OsuQQQd4nLLixxi
 +Lbqg3lisU2EnOrhVaAAHNs+DrZgmHONXhiowvVin2wuvxWxSHFDNV14ZP91Lx7v+35TrpZ6XzG
 8bTpbmibC6dH1gRKWFR0vzJyu0eI580tilzjqe0fQv6yoE4DDry018GyR6wNA2ZsAlZ0Ft6dcU6
 ote7XlXHixlqZX+T/q7UB88q1SsjrmhBJVd17XIF5cQuHY95B72bcfMWEHif0oy3oWPWbw59VKe
 aA5S68YGNiQq8Z3ZlRTxa+oMdwiN/0iCh/Ylzv8ov8b24otMWQ3aJ1sYyYFyjIYlGsD2PJL/1fP
 WXzlt9L05auTYBRztHL5tyb5RkG7MXMauxYP/XvFKhOnNjixiuqXjsGWtEUiTdt9wkq0iScKfRX
 ZbbypAEaHBvicsv3k1+9DusVZik7SIBEt+Ao+kCM/Np9dyeojk56Ch0sSg8xAH6BgdtNyuVZMhE
 t7MjCtCdaOTsBJoLIQ4Ez6wQENQPzT3Od1j40Bjo/gH9IlVVLe5VOvacublLS+QSVSOC0T00c1J
 KXPfDZuFGF9TpD8dc4YzjZ1eU0V45kXyQeWDaC7j2ZJ0WwXuu6rQWXvdTe3bvVjuBBESnYZiXUg
 DBdlBD+u2kTYefA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

rpciod drives the RPC client state machine. Under heavy NFS
workloads, multiple CPUs queue RPC task completions concurrently and
contend on the UNBOUND worker pool lock. perf profiles on a 12-core
system show 30-40% of cycles lost to
native_queued_spin_lock_slowpath in the rpciod pool at the
WQ_AFFN_CACHE scope (one pool per LLC). The WQ_AFFN_CACHE_SHARD
default helps little here, because its 8-core shards split this
system into just two pools of six cores each.

Set WQ_AFFN_SMT on rpciod so each SMT group gets its own pool and
lock. Most UNBOUND workqueues never contend on the pool lock and
profit from a coarser scope's cache locality. rpciod's sustained
completion traffic makes the lock a first-order bottleneck, so the
override belongs on this workqueue rather than in the system-wide
default. Idle kworkers are culled, so the extra pools cost little on
large systems.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/sched.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index c31cf55b933f..b84af2c0b104 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1266,6 +1266,25 @@ void rpciod_down(void)
 	module_put(THIS_MODULE);
 }
 
+static void rpc_set_wq_smt_affinity(struct workqueue_struct *wq,
+				    const char *name)
+{
+	struct workqueue_attrs *attrs;
+	int err;
+
+	attrs = alloc_workqueue_attrs();
+	if (!attrs) {
+		pr_warn("%s: failed to allocate workqueue attrs\n", name);
+		return;
+	}
+	attrs->affn_scope = WQ_AFFN_SMT;
+	err = apply_workqueue_attrs(wq, attrs);
+	free_workqueue_attrs(attrs);
+	if (err)
+		pr_warn("%s: failed to set SMT affinity scope: %d\n",
+			name, err);
+}
+
 /*
  * Start up the rpciod workqueue.
  */
@@ -1280,6 +1299,7 @@ static int rpciod_start(void)
 	wq = alloc_workqueue("rpciod", wq_flags, 0);
 	if (!wq)
 		goto out_failed;
+	rpc_set_wq_smt_affinity(wq, "rpciod");
 	rpciod_workqueue = wq;
 	wq = alloc_workqueue("xprtiod", wq_flags, 0);
 	if (!wq)

-- 
2.55.0


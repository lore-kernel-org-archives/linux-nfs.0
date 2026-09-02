Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6D113A5430;
	Wed,  2 Sep 2026 19:29:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377364; cv=none; b=HoLkreqe2Nr2TanDme5PO8yoyjPxe/zVGBPdPPvIMkb/BgNZlIkWqvKv6vep9UzbYJ6f+YMQF640SetZOq0x8/AJKw+jHnwPwUo1tkr58WIj/2OzOGLqOQdyFe2N8nzObK51D2c/3AQaeNjrIoEIJZmXLF4TGTOdNqo86V53yf4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377364; c=relaxed/simple;
	bh=l59kSsqmbSZKGr3a44xK8gQJ6X/HbwJ7DhjoK/lpYxk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Dd6Qw5WMDclUTGMnJZ3xSDleUs8AQ0ylcdHxf3WDjz/ehfhS0VwRCVKoiZI4NesNtLUy7Fguys46rOORJbh53tLZHj++vJwmQ3ExBshNjmWbPA1nqY+BMiSHbieh5vHW6XNXkTVmX6yzfbj7dgLU/l8efLFy4p8CeqvMmbF7Gbk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GvMZDG49; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GvMZDG49"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A9BE61F00AC4;
	Wed,  2 Sep 2026 19:29:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377350;
	bh=F+29SWxzE93hqeHEyD2uBD9Y99JfUFtqyMqz2TIF/bU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GvMZDG49+gshP3N0gr7l7iWiIo8xAaIMSQhpHGdi1w7jJKn0oVfkTxdGUbqbHU2bt
	 7XSiBPAn0cPs3FOknNGg9EL/RCikuJV+C6xwB5IXnR8qv6o3/e0Akhlb2Of+RMcnea
	 w5vqyT8YuvWPREY/spKtvFiHVqPq7yUu6ZSs5WnPioq6MGUkXjkmuMUruB7HKCwIkl
	 Xxjw9GXmatyPR0+Ht6HYcnDZI82bUU91C5GVYf0jWvwNMniOeU1PA1GokwGiskw5ut
	 Jh90el0iyOI0MmGBxWZYo4mS5nTfEbsW3qf71/OOmFdtsVVfIE/BhNzmpJLzkBrwz/
	 I0nz6NxgnmipQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 02 Sep 2026 15:28:51 -0400
Subject: [PATCH RFC v2 6/8] SUNRPC: Reduce rpciod workqueue contention
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-performance-v2-6-b71c0c082f9d@kernel.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
In-Reply-To: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1957; i=cel@kernel.org;
 h=from:subject:message-id; bh=l59kSsqmbSZKGr3a44xK8gQJ6X/HbwJ7DhjoK/lpYxk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHkA4sLiyTjxed1Izc24igQEahb7QkOSFINBz
 +X/iqeEX2CJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph5AAAKCRAzarMzb2Z/
 lybuD/9tp8KGHNRFVt/2vYUlP6AunckvY/o4VXVQ3KXIiJL1RLPhi/Ly9jmyYrYRlM63Dn0d8vx
 VcVFVc+bkXIIv/1mLdecdpf7yAxVY9MCQc8z9fcwXAlkzuV8/onpWskafje89nekFATmVWSZKKN
 ynNMG40WEtKVfjUd3e0hunstTScjpYnTm3FKDEgGSbKzrGUbJtWTKeTV839PVTmKmsE8OGX/dSW
 w9NQcirpwpHC+5dzaC0y8TsU0Ii7U2TY/gCLuf4JlOmxEUs8bmmFN0LVIUwE3pkQ481bis0S7bI
 f8TNtLB11M/Hw1eVKVxgWJkTDjb4xLOZXFSFUyPN2L1ykwJeSB9a/SZkFPtgv6STf7ZJnmOuLQV
 y2qmYbNOt8TOKc3n7sJg3M+A6F1LrE3wV0k06XEE69nUGfCzFWYJ3281ji0WUYBw/3ag0Nz2WbS
 r6HNW8q4ZjIyw2U1KAxqiGacA2rOkHxev57RyBzZjuT9f10dXp9unPxpQMzgtgZj+HLDca4gyw3
 Bb/hssu88VSex6mc0L4Us2LE1QfDFkof8ddVUsgKki1ZFpLNTxi8ap+i+OMzgUBcfRAPbpArH73
 5pM5dO2w7xNMcc1dce6levRe0SPsZrXfF11wm2BTt0xN9hnsnBus4dPTwD9d32Q8UGS6ozQPrE0
 v+19BAI7gTYebQA==
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
default. The cost is one pool per SMT group, or per CPU on a system
without SMT, and each pool keeps up to two idle kworkers rather than
culling its last ones.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/sched.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index e81419aa553c..2a1938b9e41e 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1268,6 +1268,17 @@ void rpciod_down(void)
 	module_put(THIS_MODULE);
 }
 
+static void rpc_set_wq_smt_affinity(struct workqueue_struct *wq,
+				    const char *name)
+{
+	int err;
+
+	err = workqueue_set_affn_scope(wq, WQ_AFFN_SMT);
+	if (err)
+		pr_warn("%s: failed to set SMT affinity scope: %d\n",
+			name, err);
+}
+
 /*
  * Start up the rpciod workqueue.
  */
@@ -1282,6 +1293,7 @@ static int rpciod_start(void)
 	wq = alloc_workqueue("rpciod", wq_flags, 0);
 	if (!wq)
 		goto out_failed;
+	rpc_set_wq_smt_affinity(wq, "rpciod");
 	rpciod_workqueue = wq;
 	wq = alloc_workqueue("xprtiod", wq_flags, 0);
 	if (!wq)

-- 
2.55.0


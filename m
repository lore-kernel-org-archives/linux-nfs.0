Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E752A3A2540;
	Mon,  6 Jul 2026 13:29:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783344575; cv=none; b=L05uerQ9V58WhyCBidfs4r2YoMVtuUCri2KD9mQdIwDw5nlm+I+dh114X2Rr80LtdiWcfAh5ZQk8oNni2hsHhuilw+CKZLd7unAyXMNXTtz+gdih6JbUW03WllSN1K+49Ea5dtxdNb47WKy/civTWqoq/zKOKQdo5E3UzEJA5pE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783344575; c=relaxed/simple;
	bh=OjRCDaP0crKo4Q3h/rZzIsdP+YJdjSxja76A7wiJ3dg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=C83suXQ1l1nsKJ6dvOCwZCigApEcHEckvP8OVULZhj+o+NP6Ju6CbA5YQIZYU7kqV1Q1I349Aa0oDbGC+c6CtQNv8sj5iPnvRs4ow0lzHI8mNRd8mgVPI+j/erzdaxkeYlSc4mIHtuS13TxhKmRftpElG1qLR7CHmGfQzWibnpc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=C4ra4jd4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="C4ra4jd4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D7B001F00A3A;
	Mon,  6 Jul 2026 13:29:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783344569;
	bh=XJ0UxmnZfTpc1zuIbl4X7PuBWJwf584NlFDez9+is7c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=C4ra4jd47OBDnJbWhJni6bb54OfLFQ/X5ZPrNGZLUw4LTQ0G8GMQSwImy6G+vJLnW
	 eraSQb4UR0olOdom8hGQja2rcX7wHk8hA6dQ5Izfl1sv2Ylw4ToTeEdGJ4UgqvC+5v
	 Uqy5W9QmtDjCB/V+NUhFSXLUR8VEj0zC5RPqPgYNlYhP2VH/NshawKdwFbiIp3Vyz+
	 WBZTtFf/24qDoNsSYvxrFNQ1jVMurru0eO2Juy8Y+YIDjAHYphmpPdRqmx+kkN7p7E
	 gFss6zIB3NanJKZ9qHX3U/y6jQc/VEGKzmeGS5lujs35pgfK9ElrjaWmpmtT6eyfbu
	 MZ3aMwLW6PVRA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 06 Jul 2026 09:29:21 -0400
Subject: [PATCH v5 1/5] sunrpc: route to a populated pool in
 svc_pool_for_cpu()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260706-sunrpc-pool-mode-v5-1-6c4ee7cd89aa@kernel.org>
References: <20260706-sunrpc-pool-mode-v5-0-6c4ee7cd89aa@kernel.org>
In-Reply-To: <20260706-sunrpc-pool-mode-v5-0-6c4ee7cd89aa@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2947; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=OjRCDaP0crKo4Q3h/rZzIsdP+YJdjSxja76A7wiJ3dg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqS622rRC9uH5ZK0isxItmhTSsISBizO9WJlo0l
 Odblf07JS+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCakuttgAKCRAADmhBGVaC
 FTLUEAC27yrX+R0YfLzabML/H1LnKM8wfMKzMsV4IpPSiU3w4pJMDfpSdRWr3LZw/irKzThMNPF
 50ZHIrresxOkrqr84UJ8ddOl/XDRQq+KfghoDKIfN4KFzh4jSO08QA/ve635gCkpqNB50a2SyMq
 wvY24osgSQ5EipuFxa2gMjsDaeQtp3Kff2kC1c7dbzvDDeUjRttEcEpjIdLq8LhYi3MObTqu88I
 ab2FBh9gMAeWJEfAxgBxDodtW8ZVs7mY9GLNOBf5YSKGPoTGhfCey+hqMywfSyz2wqunNZKdmzl
 UyiPKY7HUFvURXOCutLX/tqxYFMCNspYAo8dmOjNonDOX950a624PT8I3dYssBFQDtWD5hdbT25
 +pCRIjrJYCJIrFUOzDyYJcRhF/ul5vKPvH6U4t69XSnIsO2wRK3GOYlUpS+WoiJzUVXqi1+dqaL
 FuMpn5H+6ZDCd+CAOcDdzPmqjX1431+6vaLl3OmGRu6xaym8fPVTa8wcoVqysIYxYMm8u+nVpX8
 FgjHIedC5c0hWNA23ZHSF4eFPcHXsdhkDA/sXM/0XuQgv040nZZiadNlqHmRFLn6b1us6o1m+B3
 ONJSozvz41iVm6rJsWKUhOPp5b4m7OfiaXgwPwiPgKnH8uZvAAMzTqFanHCNQ0yHn72pftrX5qh
 Zhad0FXN9CaHUKQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_set_num_threads() spreads the requested threads evenly across the
service's pools (base = nrservs / sv_nrpools).  When a service runs
fewer threads than it has pools -- e.g. an nfsd configured with fewer
threads than the host has NUMA nodes while running in "pernode" or
"percpu" mode -- the trailing pools are left with no threads at all.

svc_xprt_enqueue() selects a pool from the CPU servicing the transport,
queues the transport on that pool's sp_xprts, and only wakes a thread
from the same pool.  Each thread services exclusively its own pool, so a
transport that lands on a threadless pool is enqueued on sp_xprts and
never picked up: the connection hangs indefinitely.

Have svc_pool_for_cpu() skip pools that currently have no threads,
falling back to the next populated pool.  This trades NUMA locality for
a guarantee that the work is actually serviced.  sp_nrthreads is only
updated under the service mutex; the lockless read here is a best-effort
routing hint, so annotate it with data_race().

Fixes: bfd241600a3b ("[PATCH] knfsd: make rpc threads pools numa aware")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 29 ++++++++++++++++++++++++++++-
 1 file changed, 28 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dd80a2eaaa74..fa8056fb0b4d 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -402,6 +402,7 @@ struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv)
 	struct svc_pool_map *m = &svc_pool_map;
 	int cpu = raw_smp_processor_id();
 	unsigned int pidx = 0;
+	unsigned int i;
 
 	if (serv->sv_nrpools <= 1)
 		return serv->sv_pools;
@@ -414,8 +415,34 @@ struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv)
 		pidx = m->to_pool[cpu_to_node(cpu)];
 		break;
 	}
+	pidx %= serv->sv_nrpools;
+
+	/*
+	 * It's possible to have a pool with no threads. Userland can just set
+	 * things up this way directly. Also, when threads are autodistributed
+	 * they are spread evenly across the pools, but when there are fewer
+	 * threads than pools some pools can end up with none.
+	 *
+	 * A transport enqueued on a threadless pool would never be picked up,
+	 * since each thread only services its own pool. Fall back to the next
+	 * populated pool, trading NUMA locality for a guarantee that the
+	 * transport is serviced.
+	 */
+	for (i = 0; i < serv->sv_nrpools; i++) {
+		struct svc_pool *pool = &serv->sv_pools[pidx];
+
+		/* This is set under the sp_mutex and rarely ever changes. A
+		 * data race here is harmless.
+		 */
+		if (data_race(pool->sp_nrthreads))
+			return pool;
+
+		if (++pidx >= serv->sv_nrpools)
+			pidx = 0;
+	}
 
-	return &serv->sv_pools[pidx % serv->sv_nrpools];
+	/* No pool has any threads; nothing can service the transport. */
+	return &serv->sv_pools[pidx];
 }
 
 static int svc_rpcb_setup(struct svc_serv *serv, struct net *net)

-- 
2.55.0


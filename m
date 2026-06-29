Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7FF17E792;
	Mon, 29 Jun 2026 17:48:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782755306; cv=none; b=el7elCdrfL7CzdJLrNohqkr1VP00rBxEfessfnAP33qKTQqWUSngjToheAMBOhfDFWjGutm5yFqeab8EDmHYn5r0RD2BAkSV4GVNIdFzYjIruTM1ZlH1lwhLQ5MY6GUthK7EeonAOzCnrOq3UTwFSRXlKREdqciPVox7er5egS8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782755306; c=relaxed/simple;
	bh=mDDQQFYiSv11Qo1XF/EgiJgTEdlvx/mVT1MBEhwz92I=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Ug2KfcXaKbQbhFhXy7nGupO+eKqz4eW4iImsfunXUkK2aGFJ7+SOTNRWooQ/2CW0cgsxFU4Y3BZhhaXqKo1oxdblDfSwjgV6Quw+YnWs6Ms1XhNRC7mf6gVzlu1S9LRqflVOX419anYcZxB43B0hgVXhuSsnGGEk5kxRChbmqeQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LZq3yRBh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LZq3yRBh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B618B1F00A3F;
	Mon, 29 Jun 2026 17:48:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782755305;
	bh=ulF3Qt5D45+POJ71NlJ2SkChEKGLmNvr8KisLQGGIoY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LZq3yRBhXqTMD8bHBGf+n6DMfmaYk/DE/l/Zjbvk9R1e9MwIVeFRB91BjRRPTGe2e
	 9cLQLfNvquFGCDR2mOJqXNPvabeZdXh4OwqVEcK0HW63ufEexSa/6ecAXt01sh37Mg
	 4X4oLj8J0MxABXhEH3tPwE89ODe9C3Y0DDonCxGIAlyCZAywoOb+RWFVpkBNzlq4cK
	 vimF8hJcV4VooX/fHBm/FxG94ZG0QUrWpTjd5F0AsLJxxyA0LTGh946za6oq8Ksnmp
	 bF4ZELOHDoOS5lC3IDwXj/LdsCRXhfEUMfpvPh5SedLF0B+qrnJwizuhaxbbfkatXZ
	 GoXNgmxPWnWGw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 29 Jun 2026 13:48:05 -0400
Subject: [PATCH v3 1/4] sunrpc: route to a populated pool in
 svc_pool_for_cpu()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260629-sunrpc-pool-mode-v3-1-d92676606dfd@kernel.org>
References: <20260629-sunrpc-pool-mode-v3-0-d92676606dfd@kernel.org>
In-Reply-To: <20260629-sunrpc-pool-mode-v3-0-d92676606dfd@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2803; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=mDDQQFYiSv11Qo1XF/EgiJgTEdlvx/mVT1MBEhwz92I=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqQq/mZwBDl87wDYDKSmO+U/8dIVx3yw7neIzsd
 4vdSZbsg1SJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCakKv5gAKCRAADmhBGVaC
 FXPFEACR2fGfHCyoFdTH77O5RAZGfXq5ZOMYgYs1QLgXs5HVpFELvQyKJ2GskgEOIJHtGfaPrE+
 6xgN5SZoacdF/PIod5u69ek4oG5feqYQVJy1n1BlwPAF9ZtyVxlgBBG0d0IUw/qMyKO/qqo0Oco
 GnHsCspznS25fCJGp0W+LqVW5QvN68gOh+VbS3ZaHUMMAmKBMTpPX6aX9swpPcYTn+lXTuCv4VH
 ROtDHfhy3vWYD++Uih/RdRj3csTB6Dww4/iFzT95H+qyxnyaoYvD/d/Er5g1eQ46qsX3IBzIGpK
 xuMyj9am6SOYMloPM5I9Uwp+GzFo1un/j3twmH2iIUb7Wt2IxAQqX+QmkYSrJVaamSJTrLDaWtb
 htrDpQ65KLYYq/zL2I+DPOdVDs4o58QJ588vx9MJzRkvgb6TVjvf2LdYuDPM4EbVcnWLs9B3P7/
 SHxhQpXpotFA/0Lyvb7xMGYwJxx4FazVk40XhUsbpSmQZRd9f+7pNGTxbY+c9I+8kuPb+UHdZnT
 hAoc3KUwGCrSrinY5A4TjobB4L8jGkf0ABb16zGXqKmUqzERcscoYkyUo3+Wd85j49UXKC8fR1/
 DDtM0/fKfZcdFFz9gJEKAxdEepjEwUWMrNMgsQv5ZVHDdpwwAyBq1F/xe8qE6GzjKjbJ2LvRVD1
 jj+rwjoi4G1Wg/g==
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

Fixes: 0f0257eaa5d2 ("svc: Move the xprt independent code to the svc_xprt.c file")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dd80a2eaaa74..82fb7faf563f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -402,6 +402,7 @@ struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv)
 	struct svc_pool_map *m = &svc_pool_map;
 	int cpu = raw_smp_processor_id();
 	unsigned int pidx = 0;
+	unsigned int i;
 
 	if (serv->sv_nrpools <= 1)
 		return serv->sv_pools;
@@ -414,8 +415,31 @@ struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv)
 		pidx = m->to_pool[cpu_to_node(cpu)];
 		break;
 	}
+	pidx %= serv->sv_nrpools;
+
+	/*
+	 * Threads are spread evenly across the pools, but when there are
+	 * fewer threads than pools some pools can end up with none. A
+	 * transport enqueued on a threadless pool would never be picked
+	 * up, since each thread only services its own pool. Fall back to
+	 * the next populated pool, trading NUMA locality for a guarantee
+	 * that the transport is serviced.
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
2.54.0


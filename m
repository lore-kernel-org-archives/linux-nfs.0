Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BA5A39A4D6;
	Mon, 31 Aug 2026 18:22:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200535; cv=none; b=cQpbl/Q27gxdbN4oT0pS/RIuqT55LAFDqyhRafHOH/G2cNiZhj9tIvAZ1SZ+99X/UaZXPjg7kIrbt5kbwC2sFdQoz9dMwrpkoiraYvaCQXUuk4nbbNi6hIu/RMZKVlaATLXgU/2XmvRT+Re7hQAZeWx26uFrXdqlRt4kwFYaMl0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200535; c=relaxed/simple;
	bh=RW896w+ixR26FNVdNSEmTu+JhQhaAIq+agG+jv57MiU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Yj1iIZ410s/NVHKJ/+XtrDKWlB6ieiFKHU1KNXCFwVZKsb43g5i44Ow4atPqn7AGQn3i18otGlxwLJ1N+CHqTaZsNcxt6bO4Ue+dxIH4we22z0FlVsQk8BFMADRUA3AZPuuVPNB4e2XxPJV7oiubC0tgVET8HypIbDuiQHsD4zU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bIm6lb0u; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bIm6lb0u"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 49DB91F00A3E;
	Mon, 31 Aug 2026 18:22:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200533;
	bh=z0MZq52InHRy26UM/UyBfExpVeGJ7udY3VsN7YkGOTw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bIm6lb0uG2DwtXmqYa6N48hHhpyGyafsTOEc3SMc/VvQDTbKDw1N6z2LKz/nuyEKm
	 IrM3uaq0r38CfGzoFXyqKoLFRgcyqsOVOty29ty3vr7OYcWQr9p6MtdxYN6YhLJ39P
	 3SFJEmGrot8HYITgPU8eQP6ZedfgpLt2Ss7QO2jSSsnJI0G3EFkJjeBxuzkY29LigY
	 Y23/L8p8GxvbCbE5wttLxvCR5/wJiTN9rVPbkutqWZbk7LJnShiKWS1VNqCHWwh0NZ
	 iDbla5tJw3hr1IECTYZMfLvSBG9MLSObpt2naKmj0EWfVVe6k+VIHrymjvYwXYI47+
	 QJAWmGvO4dwtA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 31 Aug 2026 14:22:03 -0400
Subject: [PATCH RFC 7/8] NFS: Reduce nfsiod workqueue contention
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-performance-v1-7-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
In-Reply-To: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1997; i=cel@kernel.org;
 h=from:subject:message-id; bh=RW896w+ixR26FNVdNSEmTu+JhQhaAIq+agG+jv57MiU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZPU7rmo/CML+GJu7O7UTT3DDB2RMhyHHtT9
 cAtrKRxFAaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGTwAKCRAzarMzb2Z/
 lyOFD/0coyl6dcjFgytEgMk1+jFynDB4V8LSGVhIS9lvrBfdv0sMq2z4j92yOdiwIui674JtqHJ
 wVoFA9feekH9nEOgOZMwfgtHUeu6vLHl0jHDcxPSrtMXpipqjqdycUgtfrcXaNTUoYNPoHJGdPT
 80TCvrszhxjtEjfKjG+LPda4cgDwitmfxfOyQr0u3/x96Cb3yYuM7sQgA2qHyz7GD8sKp4zlmob
 dG5Ezm5L7RQB8tBaRigWrEtjhfUxhU6V0IhD97lyXemmIVisF6MXqTPsUsS51DzHbhHGbh+HazB
 shZ/8WqCzHf52dR6bYmnI+I6LAJGyimuuRMyR1y3B68sqCCX2To2x8kWx94QIJCr36k8fyA7P5S
 RyaxUYYKtYv1i3PXA6TA7+7y4R7JrRhlqkaH9hQ45E7swJ/y1Jw55T0vHBjH8g2qkty0i0K/0LN
 k10SznHsmacFLdOPQXrEeWdcr5r6zQuuN5zm9exKEpGCuxbYTGSPpiuNbacwIz13QxpLYKh7B7s
 BR4jN3Dw5+w0mEmttx6rZTgBgySeVAtuWka/RhsVyRokO3QmE5uVv9RGLzUXa/XQQS0lUYkCZ/U
 34SUClCqTwpX/FxCKPlLFGxWNp7jSwkYK0RA8pavH+xBg9O6z58t55UrUyl6NerGv5gzYkDeVcZ
 XImN5UVNtx93aNQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The default affinity scope for unbound workqueues is now
WQ_AFFN_CACHE_SHARD, which splits each LLC into shards of about
eight cores. On a single-socket system whose LLC fits in one
shard, every NFS I/O completion serializes on one nfsiod pool
lock. Profiling 4KB random writes over NFSv3/RDMA with nconnect=3
shows that lock consuming 17% of CPU cycles: 8% dequeuing work and
9% enqueuing follow-on work from rpciod and nfsiod workers.

Set nfsiod's affinity scope to WQ_AFFN_SMT so each CPU gets its
own pool and queue_work_on() no longer takes a lock on another
CPU. Enqueue contention disappears and dequeue contention drops
to 1.4%. Throughput is unchanged because the workload is
transport-limited, but the freed cycles cut submission latency
variance by 67% (slat stdev 31.6 us to 10.5 us), IOPS stdev by
31%, and p99.9 completion latency by 11%.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/inode.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 107a2135029d..8e0d2bebba54 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2618,11 +2618,26 @@ static void nfsiod_stop(void)
  */
 static int nfsiod_start(void)
 {
+	struct workqueue_attrs *attrs;
+
 	dprintk("RPC:       creating workqueue nfsiod\n");
 	nfsiod_workqueue = alloc_workqueue("nfsiod",
 				WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS, 0);
 	if (nfsiod_workqueue == NULL)
 		return -ENOMEM;
+	attrs = alloc_workqueue_attrs();
+	if (attrs) {
+		int err;
+
+		attrs->affn_scope = WQ_AFFN_SMT;
+		err = apply_workqueue_attrs(nfsiod_workqueue, attrs);
+		free_workqueue_attrs(attrs);
+		if (err)
+			pr_warn("nfsiod: failed to set SMT affinity scope: %d\n",
+				err);
+	} else {
+		pr_warn("nfsiod: failed to allocate workqueue attrs\n");
+	}
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)
 	/*
 	 * localio writes need to use a normal (non-memreclaim) workqueue.

-- 
2.55.0


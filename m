Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA2A13939DA;
	Wed,  2 Sep 2026 19:29:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377374; cv=none; b=lMdRnjHYO7tIxNGovBmxnTLnWw7arh4RU1KRHVkhEkmxo9EmNpJBEBYrWKFbZPSWNkTt22b0JvULPWKr22QpyfN7FvVYca5Z/Ixph7mywKfoB5APMCRogHsF6J3WuEwR3g2Um2+VSA9C05fTfe61ge8h4PKhCFsbt3WOQTfgIBk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377374; c=relaxed/simple;
	bh=IteBc8RWWPlFxkX4q9XD157hPNKYOGmPLb5Z0/H5yeg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=lXrii2s0gSoMhh0xcYXukbwQttNMrLp9ppeYIR58D8fzQGe3Yc8LOf+mtpIESn4lV085RjXephjzLvqxvabO0qKL7DxPT3WwccXvUZrRLaAslAeTda6eeBBIZKbLqOqwFhUoG1hDNIZRODf4dAav7gMi2ovDtgTCCGKgaArIBrg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ARyYgqsv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ARyYgqsv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 727FD1F00ADE;
	Wed,  2 Sep 2026 19:29:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377351;
	bh=rfUk8VokEiAvKG3hrqEJQmi4sGGt5LkfdsOmziny2Zc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ARyYgqsvyefh6IA6+W8xki5v5AccHNaVjGT6LGh1f2YBMmyyiB6Rj2wKtTpBZBPNy
	 3FEswVoqaQwtBGtm/RJ9f6UCJiBDb1+SoVamWqmsJesx3th65wcxnImxbxS45CJhhi
	 20CGjrrmes5ZciaAeLsxpd/mEs5c6ufzhIKtYTUEls9GLX+iJPuoonmnZuFPN69C/1
	 KWahyhu65CgE+tRwBJXezBGYmR3O9pPzgma9yHDpVWwhEr/jPnDOm9TL1TFzQJ+er8
	 yez3+w0W8KKEVF/eGkP8qTeCXyMS2YDiPFPpGyGjiJ35YXJj8TMseFStnFYegI0eFq
	 Jl+48vEkywSqg==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 02 Sep 2026 15:28:52 -0400
Subject: [PATCH RFC v2 7/8] NFS: Reduce nfsiod workqueue contention
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-performance-v2-7-b71c0c082f9d@kernel.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
In-Reply-To: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1750; i=cel@kernel.org;
 h=from:subject:message-id; bh=IteBc8RWWPlFxkX4q9XD157hPNKYOGmPLb5Z0/H5yeg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHkA9qyELWPYcWMAO7bHXhZbE6fBpkgM4ochl
 njDI7anxP2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph5AAAKCRAzarMzb2Z/
 l/hHD/47yl8mayPhvFTdq6ccpyHXMrByHpditJiYadKrnGGb/Q7Dgg0vpVxf8JTy5H8NUufNCmy
 4ItHDDi+LSPdyBDa5l4U155/Ucz69soY75EI4jML85+GYDyiIWeu9BETnJkC/FyMKswQHxFOadY
 fIJeDcrSKt7D19K8KzaHOPsuzNHeB6B44MSVxzulKoixc4C6XjoRhulTb19eiUynq+Fia5XGbDi
 xwZX4dj5hiUiae/iY3tk3s/jFFN0ihZdzqCL26CbcYi76XIcYu+Ya2dNfsdHuOq3xWu/YF/gU2+
 6eNJgx6+lXwKkVbyA3Q0qszDbs2lIr2EG3DFQ2iLXPrJCMFg4OOCC0Zdl5I2N+rnmD/KMKniSEB
 2pPfQz/7fWDBVvUz/8BYId4hfk1Ut9/9mETpA1PD4q85DzH1td7Elj95GLyCK8sUGTTMB4gEnDX
 Ws4t4niROSdYRl8CZvpJZRgE1imk1+wK1axaqWFU0GbGeCFSd+7sofDChJRi5nyzYj3VThR18c7
 zoyfqYvGUrdCXjjH0fAhK7hbi9OC1nsk/czKwQwJdXIpC/cSQEn6TOe4+NagebQZup8JQCD/51j
 JROdsgf8Gxrq8STHlrDhHLDHnv2r7UwVnPPgMSgxbG7idUFA4R7XD3BySqabmyDPSmXF3EcheFo
 Fc20xSgOE4V0pgg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The default affinity scope for unbound workqueues is now
WQ_AFFN_CACHE_SHARD, which splits each LLC into shards of about
eight cores. On a single-socket system whose LLC fits in one
shard, every NFS I/O completion serializes on one nfsiod pool
lock. Profiling 4KB random writes over NFSv3/RDMA with nconnect=3
shows that lock consuming 17% of CPU cycles: 8% dequeuing work and
9% enqueuing follow-on work from rpciod and nfsiod workers.

Set nfsiod's affinity scope to WQ_AFFN_SMT so each SMT group gets
its own pool and queue_work_on() contends only with sibling
threads. Enqueue contention disappears and dequeue contention drops
to 1.4%. Throughput is unchanged because the workload is
transport-limited, but the freed cycles cut submission latency
variance by 67% (slat stdev 31.6 us to 10.5 us), IOPS stdev by
31%, and p99.9 completion latency by 11%.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/inode.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 107a2135029d..21c4560696bd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2618,11 +2618,16 @@ static void nfsiod_stop(void)
  */
 static int nfsiod_start(void)
 {
+	int err;
+
 	dprintk("RPC:       creating workqueue nfsiod\n");
 	nfsiod_workqueue = alloc_workqueue("nfsiod",
 				WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS, 0);
 	if (nfsiod_workqueue == NULL)
 		return -ENOMEM;
+	err = workqueue_set_affn_scope(nfsiod_workqueue, WQ_AFFN_SMT);
+	if (err)
+		pr_warn("nfsiod: failed to set SMT affinity scope: %d\n", err);
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)
 	/*
 	 * localio writes need to use a normal (non-memreclaim) workqueue.

-- 
2.55.0


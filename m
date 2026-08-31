Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F7F84A3F1F;
	Mon, 31 Aug 2026 18:22:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200533; cv=none; b=QVAHFyQNlVMjQuTeLQxI5CQZtukG/D978pimCGgaD5O55bEbhXOB372o+cLBM6GHj8Tn4T7i187FDhgr3jfZbvcNWvJz7c++iZlIqcQp9k9ZkvoNvBUgrssfKfBSKPDv9Ko+Kncny+V7sWm22ozcyFxtWdrdmsssxCy7puZyM2Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200533; c=relaxed/simple;
	bh=tSL0uX5WiMXqa9KcVZAW5G1vvE7oLcVy4eyodGJqHX8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=OAl+8HxQ9O91lySoFyVgSsMXYaohhb1VxCDeQqmYTGCAU7ZannmkcIv9MrxgjAzQ7qLxFUUq43R66r1Kmq4WyHdc4yfNCE7+spHUe8HVTOnCXMErjpx9fsz5Sa+d6LLVouS75cjl3BY7rWCmcqxN+eyHSCPlENaYhFisvhWyyO4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PDP0n0BO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PDP0n0BO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 00D841F00A3F;
	Mon, 31 Aug 2026 18:22:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200531;
	bh=/8h3ZyhxcBc9+MXGp+kCBkAD/N+CQiquY4vElNXs4Sg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PDP0n0BOsT6lp9ONvnDCVMuRExMSo0EBlKmp20JVBFHkv88FsWgYGbJKQxf7x9aFC
	 +kRlRxpSuTFoko0U8RdID4TPDQmWTA9HAl/F4/SipEKnwy0FEwrOwE6RuCjfzQtd0X
	 jLVFnaHrKOjuCtR3utQYUckZaq0Q6rBGuW2MfLji3Pu0GszXWXvvUO0fyemCZm5fsz
	 srumqCGSAqAq+ncYheOAg1G1TDA1FOR76phj9tLwOF9GQtniY9mRSaC4D4d4Cs5yVP
	 a58kdqXIoTB2AIRVAELuTbV5P5hvwZZ2pA+yqwdwGFS5Vc/oeUvTN8cdNeIu+Kypiz
	 ygCaKPW9CL+vg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 31 Aug 2026 14:22:00 -0400
Subject: [PATCH RFC 4/8] Set WQ_SYSFS on key NFS-related workqueues
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-performance-v1-4-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
In-Reply-To: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1677; i=cel@kernel.org;
 h=from:subject:message-id; bh=tSL0uX5WiMXqa9KcVZAW5G1vvE7oLcVy4eyodGJqHX8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZPUk2WAUnwrhHYs0lkjHwtVJSUin5p4QXyZ
 MaVjHYBURaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGTwAKCRAzarMzb2Z/
 lwvSD/43BvorEcNglmPSncbfa79si+LpJ1OF+6XfuUqJPkfMTRojinLnugM/ePaOe79BYOuFWxW
 lhkzXwT2ve74Geue08TTZzLrCUAv0tCFcTXkrhgeT4DlZ0PywZr5r9D2pwbf4aObU+pRi3n2GRa
 YBRfDGWYPYrlONUEawGaAV6/Yz245zfkJniSPpVhmxitM08hWptoPUjea6X7pjqa2XFzoCPSfOw
 5qY0lmVo7AApzNKNlJfK60vwML5bT8jQgVgBJCXuvNVsnVH+1Sv1lM9axjr2rKSTTWywyheQyeX
 cujnGIJKj0Me8ONzoX5OzPJyQB7JobD2/Y0cEAqIFgIOMljtu9WEbBHok2oT9v8kwUW/EXXFAX8
 6OSiS+WgyS+wtIaL308rchVKvS17Gyu/QGpTRYXsQnefJ++vUwWdBgL6zlLSYi/uIZckhtGzgga
 U3R1OMXfl0LR0jXUe+Zf8KEaHPBE2BM9VF8gq0PGZPHi1t+Q8tqp5WXMuLO8YMHJmNIomV1ZQ1F
 Mkn74NDi+2G2MWfAki3x1e85DzzT6UoLkFEhk5deXQmoSjjYSLW/5ZiBzBn9bC+v6p83Mob2YcI
 5AZBz1frnfU+5GJAUf0WzRcf/n5g+rL/2dAiu0d11t+rAVoIkv9Z5ZYHXY2dSXYYYQzRZ++H4dS
 6l4B9XBz3VrkKBw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

WQ_SYSFS exposes settable workqueue attributes under
/sys/devices/virtual/workqueue/. For NFS workloads, this is useful
for tuning affinity scope at runtime without reloading modules.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/inode.c     | 3 ++-
 net/sunrpc/sched.c | 5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3022454f7698..107a2135029d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2619,7 +2619,8 @@ static void nfsiod_stop(void)
 static int nfsiod_start(void)
 {
 	dprintk("RPC:       creating workqueue nfsiod\n");
-	nfsiod_workqueue = alloc_workqueue("nfsiod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
+	nfsiod_workqueue = alloc_workqueue("nfsiod",
+				WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS, 0);
 	if (nfsiod_workqueue == NULL)
 		return -ENOMEM;
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 9b2800f6bfc7..c31cf55b933f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1271,16 +1271,17 @@ void rpciod_down(void)
  */
 static int rpciod_start(void)
 {
+	const unsigned int wq_flags = WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS;
 	struct workqueue_struct *wq;
 
 	/*
 	 * Create the rpciod thread and wait for it to start.
 	 */
-	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
+	wq = alloc_workqueue("rpciod", wq_flags, 0);
 	if (!wq)
 		goto out_failed;
 	rpciod_workqueue = wq;
-	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM, 0);
+	wq = alloc_workqueue("xprtiod", wq_flags, 0);
 	if (!wq)
 		goto free_rpciod;
 	xprtiod_workqueue = wq;

-- 
2.55.0


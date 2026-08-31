Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 563F8471279;
	Mon, 31 Aug 2026 18:22:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200530; cv=none; b=msplIMFFnx6Ry/eobw70F5mSYEjO4MTGOMIHXLEQ2farzCLJQWdYV6UEaLV3ThpxZiiNvqKuEVBgSFtjR1gqfyG+sFj4dlmDhOqX/EeviIju66QG7sbMLeA7lnSpwDRiWVqEtfe7Svt9CP6Yr7MAOK9UWNneUXOr/UaZE84LT90=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200530; c=relaxed/simple;
	bh=ab7jO6lz+XT+Bcp3r5CMowTvoccAdGfKY8J7aGSj2o8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=u/x6K1trxHTigNS6sD9dAZ2zNg5BV+6i0627hR6reHT2BBgaqlasQU4rQsCx98w8POmIe6IlzHrBOYErG3307yJxHnshKsoTqqbM+FnbcdjhNNysQm8UfGr+EBFC47IAhd+dEMIr8Reo0dDjJpn1nuqQb1fi3/ol7Gi0YgKwiTc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bReXodlq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bReXodlq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A4BE21F00A3F;
	Mon, 31 Aug 2026 18:22:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200529;
	bh=UntNAVVE5PcFzEZfDLpbTIVU+V+Nb8NqweMsWPYgcwc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bReXodlq25mp/gElXliLrUsPb+wRRGhh1X8ya5lkUo418ChxWXgJJpQZVncJ5zMgm
	 8nHl5KFEmGFNtCzZy/UY3zllU7GSXfM95PljV/BOTo74uoe89qc8HMSISVJXb5QW7A
	 XhiqgU5yiSQ/N95QMeTObstW3SrFvtxiQyEPdHcUW/yaaSW2+RaYKN4NqCXl2i9Beo
	 heXnY+OHfFEUND2IJZw2ODK4h9UhYhhYCUgquDogys7NygoFdEiLOCbPS1S4BFIxYQ
	 id/VxzPV50wc4PUwMQzguIL0SFSc2oAfgrFw5vK2qpfy7Uek4g0c/lupZt5FpAv5fU
	 HPiQ3Gw0UkJlQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 31 Aug 2026 14:21:57 -0400
Subject: [PATCH RFC 1/8] SUNRPC: Use atomic_t for XID allocation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-performance-v1-1-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
In-Reply-To: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1882; i=cel@kernel.org;
 h=from:subject:message-id; bh=ab7jO6lz+XT+Bcp3r5CMowTvoccAdGfKY8J7aGSj2o8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZPctMWEWCC5MfvrJN8bSSrTeVCWbkEI1pj8
 OzYvj4qjb2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGTwAKCRAzarMzb2Z/
 lx+YD/kB6vVbL7dpS/6cajJoFDwTigMndT/3/XvsiUD4N1cCzPlDce1+UVpFaI9qKekfHVgJedc
 cAR9TEsl4VEpUQlH1skk1AXPtvS7wU5nUEMMKadZqewVOwQ9dlzLXKptkcPfq05avbjz/H6nqHQ
 3oDGpbzTj1opbVTF6+ShfVSI2w10hpoDub1WgL7VfsxNKVftKc3XVFab63L0bcYcUl1njjp6v1C
 jHO9wHwsY8AnMF2oN/W+fSimiEwvVWVFPo1ZCMgEKhw+0oceBTHfYHv/obiCcjPuY5A2OUsHqX5
 UlkquBq0JkXa2JIw49s1vKOVDqAEYcJw9Cb8ptb67I9zYI0a+6hFP6CiDNr4y4reAug0ZRjZ35o
 w3DJAN/2Skj1pkypq/6iF6rxZna8DxY5h3Mo2h7XxUTabVQaMwDj6hWAdDt00Qar1wE7QAJNle2
 581p+Vlvrn/anXX1/dEC4bSwta5VcqvuS+cam41yFwWNICCBJDDypkiiWNRslpBqsTqPjrWtBbv
 FU+rWzHscGdOsqzoCgK7oBwh08LTDj05NDBJPioPyb+7fio+aGKY6z5F1ZqlQQ8ZFwwwLCy4C28
 iiACbkU9D7+UF31nb1Rokd8IkgIN2yIM78IFS9d+EYJw7CcFmarcznAxgpFkNKEGoOVoOSTo/dC
 nHiQ41DwpyyRDlg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

xprt_alloc_xid() acquires reserve_lock to increment a simple
counter. Under a high-IOPS NFSv3 workload on 100GbE RDMA,
profiling shows 1.06% of system-wide CPU cycles contending on
this lock in xprt_request_init, as ~150 RPC worker threads
serialize on the counter.

reserve_lock protects the slot table and backlog queue, but
XID allocation is an independent operation that does not require
synchronization with either.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xprt.h | 2 +-
 net/sunrpc/xprt.c           | 9 ++-------
 2 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a82045804d34..0d6c3f6bf97e 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -273,7 +273,7 @@ struct rpc_xprt {
 	spinlock_t		transport_lock;	/* lock transport info */
 	spinlock_t		reserve_lock;	/* lock slot table */
 	spinlock_t		queue_lock;	/* send/receive queue lock */
-	u32			xid;		/* Next XID value to use */
+	atomic_t		xid;		/* Most recently issued XID */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
 
 	struct list_head	xmit_queue;	/* Send queue */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 48a3618cbb29..186c14f0f928 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1882,18 +1882,13 @@ xprt_init_connect_cookie(struct rpc_rqst *req, struct rpc_xprt *xprt)
 static __be32
 xprt_alloc_xid(struct rpc_xprt *xprt)
 {
-	__be32 xid;
-
-	spin_lock(&xprt->reserve_lock);
-	xid = (__force __be32)xprt->xid++;
-	spin_unlock(&xprt->reserve_lock);
-	return xid;
+	return (__force __be32)atomic_inc_return(&xprt->xid);
 }
 
 static void
 xprt_init_xid(struct rpc_xprt *xprt)
 {
-	xprt->xid = get_random_u32();
+	atomic_set(&xprt->xid, get_random_u32());
 }
 
 static void

-- 
2.55.0


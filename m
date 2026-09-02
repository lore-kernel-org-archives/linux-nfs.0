Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D23039D6DA;
	Wed,  2 Sep 2026 19:29:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377350; cv=none; b=WlKjtUay56pHInfGIfsIbSFkp7JNySMK7XuUuuQaIfWMH6uc0koVdXUlUU40SfNQz0t9wbDp+l0EU7guqOntIXaEXl6EO00E75RvHd2LuylaNJp+X4CqbULFW/UF4B+demxZBdiXX7LHjoMcxracxAyMTClMPKu2uJ2thGOfKPQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377350; c=relaxed/simple;
	bh=ab7jO6lz+XT+Bcp3r5CMowTvoccAdGfKY8J7aGSj2o8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FXXMZRyk3y6djMR0WeG5JLpwK97DqX6VZGwf/NXSHcQnlR+yYdiusA+oeJ21/w3TPqk7gxpYcmWfRNcfMIFdv+h6+m17WfsAHzqZoup3HlLRHdDtH6tfu3YGADgmo+WugDr2zhbHhV3R1zItp1skaVnCFpy3Y/Tel2V5JrfNhSI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iqCbQh3Y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iqCbQh3Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B86B91F00A3D;
	Wed,  2 Sep 2026 19:29:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377346;
	bh=UntNAVVE5PcFzEZfDLpbTIVU+V+Nb8NqweMsWPYgcwc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iqCbQh3YjeV03Yz/TvlFbHs49UF910IqRbRPZRsQsKtEl7FhXI0IP5JvGg6G/qWWc
	 8e4veG7Dv19TjHGCD1ZuCrTxSyLxLzy5NmttVTfS7DlE32P5mUycZOINui3yXvG3tS
	 MJqO9LJ3E1MT42sW0yyf1jWQWumK8HDFtLAPvurPO3uIiEZvgxqB4RBF4aSOsNVZqC
	 Zbk2hQmf2mFFt2ZZZEi6xelGiQZ9dOfpUiexH2Efn9fJ82aIhLiGaYkUByh0/Q1KEN
	 IEcr/Mbgh71DEBglJxu7djxZnj7I6qSUqonyTZyFTBilJ8YooK1RQWyaBPsj6d1+Ts
	 0ToZMDtb6Nf6Q==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 02 Sep 2026 15:28:46 -0400
Subject: [PATCH RFC v2 1/8] SUNRPC: Use atomic_t for XID allocation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-performance-v2-1-b71c0c082f9d@kernel.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
In-Reply-To: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1882; i=cel@kernel.org;
 h=from:subject:message-id; bh=ab7jO6lz+XT+Bcp3r5CMowTvoccAdGfKY8J7aGSj2o8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHkAeWFgSuvKZvq5qDSzHfsgKcZmKJvXvpJtC
 FQyW28h2mSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph5AAAKCRAzarMzb2Z/
 ly6PEACp7Jfnzys31rtXXC9B3r0tFm8EcwmzdWzDxB3Ge0+BO8hRkXWbXsJoTdkrtgIEePgLP7T
 FGkbihSCGtxXw1Mz7ZxtHFVCzjX4ouvqsSyS2AQab1ZnACs0EiR/tjjWU6OjUJSyFZiPyW6yl72
 XrJUcG8jQVzL40Fx4wePFwVNpv5ibCifEsy8bAaKyj3oTvOYRx/NHS9pI0ucgcwkcsqL/D2xCAK
 HIBfJz4hWlUyEscTR5nkPuRSdbQtaD+1fUr5MlUZNJjvxi4GC0v8LyG4vAT/RhG/yShbVmwIVaj
 OKPioU7V8Dnhtw7lexX344sINP0RJrNHfMD1xLkuclj7xq+tOCqqyKIyT3HTo1T9OfEulv8hzq5
 gW8Q63OcqCBaC8gQgUVqxUQ/8TFmrkgminNNyQQN+lSMUMdWjd5vQyRoYV8dDV/TGWg6vQGCYVY
 ibeOovAjx9zCu1dZD/ihRtgujzx9bbx7qFO90/crUI4Xwsq5Ajy5YIAAAqRgorQq90F0oi9Ni0Z
 TtZT1HcIphr//YWWIi/MRtc8bJ282hl2kxRP5hOLpNSmyC49zLPKj7rczF5VRejhesBXk3wEg+9
 hv9+aBl+GnhrextchaCF0s5iQtJ6EzR2olua7Aa00DSbags4NsipuT7P/xBXPCec/yTNpczc8jZ
 wSYgqB9b3B2IYew==
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


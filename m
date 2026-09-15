Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 698BE34250E;
	Tue, 15 Sep 2026 14:20:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789482057; cv=none; b=s0mZYxczutSB4lQ2CJXte+ES4MzFbMvQHKQl8uQ/gsP7ukfza/EbLPt52sVb4aAEJ0IGGMgzHusSFfB4nq7AfVRVqRoIGKY6pWWpIff/X4hm55zFPwYczzmCnG1nbsLW6SLsy3yoIxGocnaixbdxaopQyveRyNrbRLXhtIFecXI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789482057; c=relaxed/simple;
	bh=Awy5+gwh0rQDeMWDu61RRk6Jl4HDmD2yiFuj1eEImRg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=UFQYVj2CCat831Lwhflv0zC8Hovvv/4UyM/D/yEj7eFjO2HX6weRHjMZcoB6oe7zWFdM8tKLW9GvzJQoJ53UeX3HCzSj6sPwao9/8b4TzGuHAej1wbNyFCqV1m/qkmNyFwM9DLMDuT8WP9i0N5Z/zzNIqdVdViTXA5ciLUAamxg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JToynxhs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JToynxhs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 85FC41F00893;
	Tue, 15 Sep 2026 14:20:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789482056;
	bh=dpB20xJYi1VEUnx78YqG5jvGGAspVyU+zm/IYjxVoDM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JToynxhsk0wiy6MNWt06/gALfuescFnCBodQJUxPWaeiH8W1k1JvI+L9RvRSsHHyO
	 jziWReuLKh2QdmHzF1RUK2UKzuRW6BOlcsBPSBDr2o/mGR5ZoWU/wlEMCtqsrunYkn
	 9N3HXVIw+Zj6mCdrsvwbwGuB+da5e1Nx9X0gwEmdHZ9FcKXwoxh8rqsX1jdD77yXt0
	 wxz62q9B7w4eYBG2vjutWBtXd1yDeuWwQZPS19AmiKHz0Zgjoc/0DXIyuWFzPJCKqD
	 fr5KmeVrMzAZ0qCIQ9GkoKLSJe7G4eH/BUfw7hig+qtABi/+J3F4KArjzOSP5I9hog
	 bvN7vRuY4o2hw==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 15 Sep 2026 10:20:41 -0400
Subject: [PATCH v3 1/4] SUNRPC: Use atomic_t for XID allocation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260915-performance-v3-1-ae26d460bfd3@kernel.org>
References: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
In-Reply-To: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Tim Menninger <tmenninger@purestorage.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1882; i=cel@kernel.org;
 h=from:subject:message-id; bh=Awy5+gwh0rQDeMWDu61RRk6Jl4HDmD2yiFuj1eEImRg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqVRGRSHTJe2CEwQscWK7NazXXz08S5bbw5HYa
 j+Bw83t+X2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqlURgAKCRAzarMzb2Z/
 l0VXD/9o7u7JdDxubha8wG867idoHbBqfv7fuHBmX5hTtPxBBE/T0jmCtfa1cAO/WuKGmK2VgEJ
 8XwENmryqcOz4T63ld8fEvRyt5Ayn0xlacQD0vZqrrds7MJ9BbKHKfpokGUupbu/CXAM9maYczW
 fWNQjyMKCUQD3DCQK7rfpK/VRpHBZKwtDndhRID96F3VAI+5lAEOOJls0yp8Pr7L2sFLcdve+nq
 Jx/mvGFrqhpl4hPhyvLgWpHxpnYpkcQODuuGtxwrw0LtLFtCUWvQwCSBGybUMsM1IP8L90C+kJ0
 wTPTt+hg6pi9iNN0RE8mZdyDJYDXgwzvxEB9sDQQZxvw2hydbwqoqJAx9u05VMT3a834ZK2EgJx
 O3HOcof/oiL8nl8mhPPRBInKr+ZJfleGAAoX6AJLYcU1rOGgJENrF4wiRWAREleT7URxe9lcREh
 nfl86bWRGLzQ7WSukeDFqH5l6w2DNFcXw1OxIpEDuSMEM7Dy7+Jb+s18CWiZYz4FcNP04bUE16I
 n7ZYxU0H8t1VlXByv9cjOtqIJRE3aYKPHbptm0TqX57Ajh4dAO9kfds2+gWv905yqtwwqoKSeXb
 OXpYmuDOZ4tg60eMj0Am+lsz9u00BVZYnpQ9YKwUYcdUMayoVCofmAkcLKGzivVj4kMC9qx+39Q
 IM+VkOTQZvEWsBw==
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
2.54.0


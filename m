Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9544C175A98;
	Sat, 23 May 2026 00:02:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779494578; cv=none; b=OHrbusd9mzcHBcbWTwHgQ7I97P812btSX5ZWTaaDILnnzt8K3tC/ZCGmkn/WQQ8awI9fApu9VloW2VCjzRFyLoOavM8Zli1A6tq0LVujgCOywSJchP4W5sCRpJXsiqewCkbKDF6+cUwnAtVfNDjo58a8fAUfTVOBO8PNbl9LFN8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779494578; c=relaxed/simple;
	bh=NTTYU3+hZH2StiUrM5NJawM8CAdD9jGwxPXOVSafbmc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=imroGsObQSf2a0dJJkPasQ+N8dQQ66tnepjYsBUEY8kEzsr+BF/UjPFEAo6czMCkWxTa5YZT8jh045Fhhx0d9lrfnjChyOM0wuEDAf9RcCovBpJhWuBqRhjoh5zQgMntPd2KRlVXKiCcK7cE2AzzqT2tgO2ud8f4K+WdUgYjHJE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JyeXOeNB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JyeXOeNB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 02DD51F00A3D;
	Sat, 23 May 2026 00:02:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779494577;
	bh=ZYy5IfQZrrDI+UiUQ+x9SMfRioNuxGslE2NO1VMNJJI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JyeXOeNBgypBZZfmCjSwuBKsieHQ0g+4jQvIarVg8WhiuqOlHVKkCJZvfc/FT39Dc
	 Nws8AL0Sa0zEmlyp926EsNLryrEgDCtS782wHbRMcb2fVWedMLt7zgMEdRompXRJBe
	 g4z+Qkfk04QphW9dc7nhjoQnyB3+ExHU0Obb44jfsIHf4Nhl6ELOVwh2r3Uq7/NvVV
	 k2QjGlYmS9iUn9O0LalybhAGlB20jcY8zM1wILKZ/E3u419MY63sn2Io03tllIwIFA
	 4/rBQRYEiAByp4Or2s41CtO7dMAHHsbk1tnOth8b3wFx7vRxtzRqSWXqc8db8ksMFT
	 RtIaI4bF5Y8Ng==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 3/3] xprtrdma: Add request-pool slack for delayed recycling
Date: Fri, 22 May 2026 20:02:52 -0400
Message-ID: <20260523000252.465074-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260523000252.465074-1-cel@kernel.org>
References: <20260523000252.465074-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

After the previous patch gates req recycling on Send completion,
a completed RPC's rpcrdma_req can remain pinned by the sendctx
ring until the next signaled Send completion releases it. The
transmitted-RPC ceiling is unchanged: xprt_request_get_cong()
gates Sends against xprt->cwnd, the RPC/RDMA credit window fed
by server-granted credits and capped at re_max_requests. The
req pool, however, must exceed max_reqs by enough that this
recycle delay does not stall a slot allocation that the credit
window would admit.

The headroom is bounded. rpcrdma_ep_create() sets re_send_batch
to re_max_requests >> 3 -- one in every eight Sends is signaled
-- so at most re_send_batch unsignaled Sends can be outstanding
before the next signaled completion releases them. That equals
max_reqs / 8 reqs in the worst case.

Allocate max_reqs + DIV_ROUND_UP(max_reqs, 8) request objects
and name the slack calculation at the allocation site so the
1/8 bound stays tied to the Send-signaling batch size.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 97b8b2376602..a83e51f7f15e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1080,6 +1080,18 @@ static void rpcrdma_reps_destroy(struct rpcrdma_buffer *buf)
 	spin_unlock(&buf->rb_lock);
 }
 
+static unsigned int rpcrdma_req_pool_slack(unsigned int max_reqs)
+{
+	/* The sendctx ring can hold up to one Send-signaling batch
+	 * (re_send_batch, set by rpcrdma_ep_create() to re_max_requests >> 3)
+	 * of unfinished Sends. Each pins its req until a signaled Send
+	 * completion releases the sendctx. Size the pool above max_reqs
+	 * by that batch so the recycle delay does not stall a slot
+	 * allocation that the RPC/RDMA credit window would admit.
+	 */
+	return DIV_ROUND_UP(max_reqs, 8);
+}
+
 /**
  * rpcrdma_buffer_create - Create initial set of req/rep objects
  * @r_xprt: transport instance to (re)initialize
@@ -1089,6 +1101,7 @@ static void rpcrdma_reps_destroy(struct rpcrdma_buffer *buf)
 int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	unsigned int max_reqs;
 	int i, rc;
 
 	buf->rb_bc_srv_max_requests = 0;
@@ -1102,7 +1115,9 @@ int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	INIT_LIST_HEAD(&buf->rb_all_reps);
 
 	rc = -ENOMEM;
-	for (i = 0; i < r_xprt->rx_xprt.max_reqs; i++) {
+	max_reqs = r_xprt->rx_xprt.max_reqs;
+	max_reqs += rpcrdma_req_pool_slack(max_reqs);
+	for (i = 0; i < max_reqs; i++) {
 		struct rpcrdma_req *req;
 
 		req = rpcrdma_req_create(r_xprt,
-- 
2.54.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EFE35908CC;
	Mon, 31 Aug 2026 13:50:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788184253; cv=none; b=dpyQk2PL/W+BXnuYskdDKWHdpwUkVJAV7Rz81ZvrhLiVrdid7MQdKqBbxroIhGKbTXDJtKdn/EvZc0WBvIvv6Wbzk2QUansKH2g5GlgoEBg73tZPq78UpVTMfGjRHlR9OFV894uF+Csf2TFESoHM514YP5Dqa8dYLm3X2XXonIg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788184253; c=relaxed/simple;
	bh=PkqGFDZvt+6xZYDQSUx2D60iODeeggFTAdrlvo3ZwCA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=N0gawGOtbkGCY8C1nS4AUgMweDzWyOa8IVzBwKGjoaW58Y9j5wXjOD4l7BrnR1VLwYktZVRMOyqFf6LWKuUQBZhimtFEqr0sAjzyohq+1macDLHz3/a/WbwCJuoA+KTqT40HTeNIzlXGJ47TrXZmo5x1/D6i2gmoTmbB4F5sWRA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nvpIikDj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nvpIikDj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D77201F00A3D;
	Mon, 31 Aug 2026 13:50:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788184252;
	bh=dBOtDHH7hlwTXkTD/XQmhI8sc8ZZt+wc+uJZsmVWgrE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nvpIikDjdwVYL/AGEZ7f94DqUITgqDNEC4pMM6nIKBLaTo6gyPenP69jZrrWEpNQh
	 Wyu7er5euskvO14wAFadQRABPHu9jKf65ylxQvR54etRPzsrdpVICMkUvsbo+3n4uw
	 wVAk3f3/tJiyoXSMgrTIFeUqeipcQgExR/HyFh/E5ujPeRJH1+6JAgzcyldD0wnvcR
	 hWCLyQJltfxZqeN+1dRuem6yGB1uLCesjEgBall3HK1tWr+qUL9e7R0TPnDkIvs1Pb
	 E2qyTY5watxVsDtauA7FN6g0OHtd+yoFx8aILuobWD/bPoDPsmXzQ+LXO06uiJdqU8
	 D+muzpe3GsE3A==
From: Sasha Levin <sashal@kernel.org>
To: patches@lists.linux.dev,
	stable@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Anna Schumaker <anna.schumaker@hammerspace.com>,
	Sasha Levin <sashal@kernel.org>,
	trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org,
	jlayton@kernel.org,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH AUTOSEL 6.18-5.10] xprtrdma: Add request-pool slack for delayed recycling
Date: Mon, 31 Aug 2026 09:30:10 -0400
Message-ID: <20260831133314.4125787-582-sashal@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260831133314.4125787-1-sashal@kernel.org>
References: <20260831133314.4125787-1-sashal@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
X-stable-base: Linux 6.18.48
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

[ Upstream commit 64bf6892057b746c55bcc045b9492741b72d8d27 ]

After the previous patch gates req recycling on Send completion,
a completed RPC's rpcrdma_req can remain pinned by the sendctx
ring until the next signaled Send completion releases it. The
transmitted-RPC ceiling is unchanged: xprt_request_get_cong()
gates Sends against xprt->cwnd, the RPC/RDMA credit window fed
by server-granted credits and capped at re_max_requests. The
req pool, however, must exceed max_reqs by enough that this
recycle delay does not stall a slot allocation that the credit
window would admit.

The headroom is bounded. frwr_open() sets re_send_batch to
re_max_requests >> 3 -- one in every eight Sends is signaled --
so at most re_send_batch unsignaled Sends can be outstanding
before the next signaled completion releases them. That equals
max_reqs / 8 reqs in the worst case, with a one-slot floor for
small max_reqs values where the right-shift rounds to zero.

The sendctx ring and the hardware Send Queue are not enlarged
to match. Both are sized in rpcrdma_sendctxs_create() and
frwr_query_device() for re_max_requests in-flight Sends, which
is the ceiling the credit window enforces. The pool slack does
not raise that ceiling -- it only lets allocation keep pace
with the credit window during the brief interval in which
earlier reqs are pinned waiting for the next signaled
completion. At any moment, at most re_send_batch sendctxes are
held by unswept unsignaled Sends, leaving the rest of the ring
available for newly admitted Sends.

Allocate max_reqs + DIV_ROUND_UP(max_reqs, 8) request objects
and name the slack calculation at the allocation site so the
1/8 bound stays tied to the Send-signaling batch size.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---

LLM Generated explanations, may be completely bogus:

Connection lost, reconnecting to https://agentn.us.api5.cursor.sh
(attempt 1)...
Retry attempt 1...
Connection lost, reconnecting to https://agentn.us.api5.cursor.sh
(attempt 2)...
Retry attempt 2...
The background git searches finished and match the earlier analysis:

- **No slack commit in this tree** — searches for `"request-pool
  slack"`, `req_pool_slack`, and `rpcrdma_req_pool_slack` all came back
  empty.
- **Prerequisite is present** — `53442c7d0c888` ("Decouple req recycling
  from RPC completion") is in v6.18.44; patches 1, 2, 4, and 5 of the
  series are there, but patch 3 (pool slack) is missing.
- **`verbs.c` still allocates exactly `max_reqs`** — the regression from
  the incomplete backport is real in this tree.

Verdict unchanged: **YES** for backport to v6.18.44.

 net/sunrpc/xprtrdma/verbs.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index e2d3cee825cd7..8449107b2a095 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1123,6 +1123,22 @@ static void rpcrdma_reps_destroy(struct rpcrdma_buffer *buf)
 	spin_unlock(&buf->rb_lock);
 }
 
+static unsigned int rpcrdma_req_pool_slack(unsigned int max_reqs)
+{
+	/* The sendctx ring can hold up to one Send-signaling batch
+	 * (re_send_batch, set by frwr_open() to re_max_requests >> 3)
+	 * of unfinished Sends. Each pins its req until a signaled Send
+	 * completion releases the sendctx. Size the pool above max_reqs
+	 * by that batch so the recycle delay does not stall a slot
+	 * allocation that the RPC/RDMA credit window would admit.
+	 *
+	 * Round up: re_max_requests >> 3 is zero when max_reqs < 8, but
+	 * a single unsignaled Send is still enough to pin one req. One
+	 * slack slot covers that case.
+	 */
+	return DIV_ROUND_UP(max_reqs, 8);
+}
+
 /**
  * rpcrdma_buffer_create - Create initial set of req/rep objects
  * @r_xprt: transport instance to (re)initialize
@@ -1132,6 +1148,7 @@ static void rpcrdma_reps_destroy(struct rpcrdma_buffer *buf)
 int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	unsigned int max_reqs;
 	int i, rc;
 
 	buf->rb_bc_srv_max_requests = 0;
@@ -1145,7 +1162,9 @@ int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	INIT_LIST_HEAD(&buf->rb_all_reps);
 
 	rc = -ENOMEM;
-	for (i = 0; i < r_xprt->rx_xprt.max_reqs; i++) {
+	max_reqs = r_xprt->rx_xprt.max_reqs;
+	max_reqs += rpcrdma_req_pool_slack(max_reqs);
+	for (i = 0; i < max_reqs; i++) {
 		struct rpcrdma_req *req;
 
 		req = rpcrdma_req_create(r_xprt,
-- 
2.53.0


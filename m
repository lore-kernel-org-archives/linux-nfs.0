Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CD0C3128A3;
	Tue, 10 Feb 2026 16:32:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770741159; cv=none; b=KefmoN9izFUkMumk+Wlcuwqj+IOKnFLYdYlFa1NDbsp/1g6H2cav7BrWCNDDazckk1+kvQKhChAwzevvFP4agUpcDXqVnBtg4tJgLmIUYfAjjgmQlh0LtMOeiynYs2gL6lH3PDuDEE51V29bjgFkVVJrpXkcOT7bG01R21uDIf8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770741159; c=relaxed/simple;
	bh=hR4VdN4VMCJY5NmLZ0h4LG/BIHWdKzeiN0apOJUlzRw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lI8Gu4GIhaK6LP85eiBiCRilkLAbvIy9U7Yvosx9DkZZx3eOcjVVywJ8UNBQkK+BgwozPN8tYN0HYD6S59LbLMNoR+qBvEaT19qbXQqQa7u2ZUVlPjjLUx2A3pIFW/pjz7FCnl/MLmCxy7zFfK4XHT4BQ7+hrUh3L8Stcgub+0s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RD8ybHmG; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RD8ybHmG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BAE4AC19421;
	Tue, 10 Feb 2026 16:32:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1770741159;
	bh=hR4VdN4VMCJY5NmLZ0h4LG/BIHWdKzeiN0apOJUlzRw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=RD8ybHmGC7cYumdG/mCLEmsZvJ4wsiczf4PvLeonyVPjc/xOCG3QP50NZFDlvTESz
	 oEjh+9WtZdrBlBA0E6m1SuEw/Jp0isQibRDe+2xY1z68aYJkG24yY4e9y7QW+wGODU
	 H/0gSPXP1BNMJDTxsRPwVjfXEeewBiXDIpY7/mzGPfGP+/Xqv0XmxwaszQm9RxgFns
	 7rDW++71fgSegAI8yow2Ipr6lQYPF7oTvoEbGLaMJYNL9xfBwjTLtUDbLH65f4wYY4
	 vKtElfU3yJ38oe7P1tJQHOkVG8yjRsQlerwQH7bWX1iyu9l8zvvMUZacRbUneN9NFQ
	 XgRE7N4wOTPBg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [RFC PATCH 15/15] svcrdma: clear XPT_DATA on sc_rq_dto_q consumption
Date: Tue, 10 Feb 2026 11:32:22 -0500
Message-ID: <20260210163222.2356793-16-cel@kernel.org>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260210163222.2356793-1-cel@kernel.org>
References: <20260210163222.2356793-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

svc_rdma_wc_receive() sets XPT_DATA when adding a
completed Receive to sc_rq_dto_q. When
svc_rdma_recvfrom() consumes the item from sc_rq_dto_q,
XPT_DATA is left set. The subsequent svc_xprt_received()
clears XPT_BUSY and re-enqueues the transport; because
stale XPT_DATA remains set, svc_xprt_enqueue() dispatches
a second thread. That thread finds both queues empty,
accomplishes nothing, and returns zero.

Trace data from a 256KB NFSv3 workload over RDMA shows
172,280 of 467,171 transport dequeues (36.9%) are these
spurious dispatches. The READ phase averages 1.99
dequeues per RPC (expected 1.0) and the WRITE phase
averages 2.77 (expected 2.0). Each wasted cycle traverses
svc_alloc_arg, svc_thread_wait_for_work,
svc_rdma_recvfrom, and svc_xprt_release before the
thread can accept new work.

Add svc_rdma_update_xpt_data() on the sc_rq_dto_q
success path, matching the existing call on the
sc_read_complete_q path added by commit 6807f36a39b7
("svcrdma: clear XPT_DATA on sc_read_complete_q
consumption"). The same barrier semantics apply: the
clear/recheck pattern in svc_rdma_update_xpt_data()
ensures a concurrent producer's llist_add + set_bit
is not lost.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index a124c6ed057a..c56d70658068 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -994,6 +994,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	node = llist_del_first(&rdma_xprt->sc_rq_dto_q);
 	if (node) {
 		ctxt = llist_entry(node, struct svc_rdma_recv_ctxt, rc_node);
+		svc_rdma_update_xpt_data(rdma_xprt);
 	} else {
 		ctxt = NULL;
 		svc_rdma_update_xpt_data(rdma_xprt);
-- 
2.52.0


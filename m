Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6E95377541;
	Fri, 28 Aug 2026 13:50:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787925041; cv=none; b=lmyRmWA6BmMt/mcZuhEEyaR5GeEmLolo1MvI15ouqYapLLFv3YdJSAwM+8AELhBkiwzDq8uNGGnrToabB5sK1M4ZmyowTGccw2WuMek1fnAtbpHoYViKO6ppKFDX8yp/bs2bxg8ueQaI1g4EUUvRYNKba+j/RZxohHxFJ1EixL8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787925041; c=relaxed/simple;
	bh=SsHDE/eEEe5tyULrz5DSpv1ogzyLODBLZZyFn//bQbU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=D2NIZTw4QkI7ceehztEH5nd/lH7SGes6I+PiiCL1RswhEKhGeBiiaUA0x2Vmd/Isgy6BRv4AuAwgwOtJn1/jsxlnfWRfVuHZJ5OaE8wwLTlUF8pLuPfI/x0vtHX9azayN5mrbwMYgT9BFKq6NJ6yJfOHFRV/aKQ9tnZHs8As83w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A9C0jb+N; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A9C0jb+N"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 333AA1F00A3A;
	Fri, 28 Aug 2026 13:50:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787925038;
	bh=jQ7QZi8FN8/A/wtgHnRKV7v2S/z4T+rjEeS0TO154gY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=A9C0jb+NeZ+nPNPmEcSglcwoZ06G1mPz4itoahqTIolLyM3VAnr1n45nzWQYnlAfI
	 Ahcp1njURdY+z7Wgr+5h7iFIGt4N93SqLW7HqoaQk+4LdGZjkj5VW/Uu2mljp6dnkH
	 ZJT9LOrGv9FJoBprZsKJmo7GwXAKkxWk/XPE966JTGAdyP5lZ4N2VTy54XmByn/Do0
	 hJzY34Z/81JilWRp+WHYSgRDTrLG3va5Z6HHzeh5O09yS8bJ2YJyYrgoVS8zfOBocC
	 /D698zgub58QceDFk7USx6R5c1fiOL4SN/5hD8puE378ALuhcTxnyczW7SQSOVWHuU
	 ZXjU8NFVy2sHQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH 1/3] svcrdma: Grant credits from the clamped sc_max_requests
Date: Fri, 28 Aug 2026 09:50:34 -0400
Message-ID: <20260828135036.796842-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260828135036.796842-1-cel@kernel.org>
References: <20260828135036.796842-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_rdma_accept() computes sc_fc_credits from sc_max_requests before
the Receive Queue depth is checked against the device's max_qp_wr.
When that check lowers sc_max_requests, the credit grant keeps the
original value, so the server advertises more credits than it has
Receives posted. A client that uses the full grant overruns the
Receive Queue, and the connection is lost with an RNR error.

Set sc_fc_credits after the clamp so the grant matches the number
of Receives the server posts.

Fixes: fc2e69db82c1 ("svcrdma: Clean up comment in svc_rdma_accept()")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 927269598ac2..f949601b2144 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -471,7 +471,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	newxprt->sc_max_requests = svcrdma_max_requests;
 	newxprt->sc_max_bc_requests = svcrdma_max_bc_requests;
 	newxprt->sc_recv_batch = RPCRDMA_MAX_RECV_BATCH;
-	newxprt->sc_fc_credits = cpu_to_be32(newxprt->sc_max_requests);
 
 	/* Qualify the transport's resource defaults with the
 	 * capabilities of this particular device.
@@ -492,6 +491,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		newxprt->sc_max_bc_requests = 2;
 	}
 
+	newxprt->sc_fc_credits = cpu_to_be32(newxprt->sc_max_requests);
+
 	/* Estimate the needed number of rdma_rw contexts. The maximum
 	 * Read and Write chunks have one segment each. Each request
 	 * can involve one Read chunk and either a Write chunk or Reply
-- 
2.54.0


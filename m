Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4047334C1D;
	Mon,  1 Jun 2026 17:54:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780336459; cv=none; b=NHn8PMeW5R8wS7kGBqmLwZhgYOF38OyG+gOxw4gXC+cM9Kh9JDq1fB2kTiGd8KhNlk8bG9kAg5/v8LAhSW7G1bZ5kZXNpGl97zKDtA3RDUcY/ST+IDbQxDXSYX1TeTBZ1ucOPkX/f+Yz/gm1mPo7NvV1bCYoNUtYhOut+kIFQBE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780336459; c=relaxed/simple;
	bh=A+iJVdyBVouJvvMqLfFzbsbjcD59NNtL8iLZVqVfBSY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Sg3injnWmY7x1wrrAb8lvPk6gALRoqxH2W6lyvhlIU6vrAYFhAype71ytBwGjPobgJ81AKMX2jFIEpHZakn6vGSh5k9xeuteRRRkLSDYhMXv6UI77dEL21Ugr0p5jlbtdSzx32+Px+q+/ev/kxd7qAI9ignuzmL/KCFyP3Htul0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hUCeixsN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hUCeixsN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E59831F00898;
	Mon,  1 Jun 2026 17:54:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780336458;
	bh=PnV4r/9POe7xnftfC6rg8TY7Mei2xAgFIN7H/7T/4u4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hUCeixsNGdc9oMudYeXMyBFgxNvL5B1mSerVvoahmg6ObjMovO+Q0ZIyXbm4H+1V8
	 puPhS35WwCeuVN8W/51iosIs+JPIu7u6d+D6/TAHd7R864p1Nr4i9bQ4VQmQIX5hxJ
	 b3jhTnpq3TIf9z2iNZ/Bcz3m//cdoaGjDMxCgd5ykI5eKXcCGnPdLaMcvRvZU8bMzC
	 GkFJLQxl98oRq7jJhlruNrEOImm0uWpP4ES2sUNKjxphPTSzaRvYW/qEgXT185XZ+i
	 bXQNlNVyRMhm6fNPqoWobtkME1YvUQUleDq/M+90PcU15j19SsXcr6cM20mwCfA986
	 u+ObdFW+C8yaQ==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] xprtrdma: Fix I3 invariant comment in rpcrdma_complete_rqst
Date: Mon,  1 Jun 2026 13:54:12 -0400
Message-ID: <20260601175413.29544-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260601175413.29544-1-cel@kernel.org>
References: <20260601175413.29544-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

frwr_unmap_sync() and frwr_unmap_async() drain rl_registered via
rpcrdma_mr_pop() before posting invalidation Work Requests to
hardware.  The WARN_ON_ONCE verifies that the list-drain step
has occurred, not that hardware unmapping has completed.

Reword the comment to match what the assertion actually checks.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 626cadec4555..f115baba6d56 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1336,8 +1336,8 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 	struct rpc_rqst *rqst = rep->rr_rqst;
 	int status;
 
-	/* I3: every registered MR has been invalidated and
-	 * ib_dma_unmap_sg()'d before complete_rqst runs.
+	/* I3: rl_registered has been drained by frwr_unmap before
+	 * complete_rqst runs.
 	 */
 	WARN_ON_ONCE(!list_empty(&rpcr_to_rdmar(rqst)->rl_registered));
 
-- 
2.54.0


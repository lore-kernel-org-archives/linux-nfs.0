Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1EBFD348889;
	Fri,  6 Mar 2026 21:56:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772834193; cv=none; b=BiSBUE5RaeePv0jI+lpUI3PidxaQ6c5jVUUJKOkzTVlrh3afBEQ7Xmb32K6/GvspDeHqdIbGoHCPi1bV7MvAPrz1gpFyEVwybgc+jZSLZ0sH0YQJLsI0ZgfRlSb+BnMK3jgRSdBXwU5wGWYIDQCbjPfH7ggq6eN1AaVF16P31dE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772834193; c=relaxed/simple;
	bh=wJ5dJGNgVGms8mpPkK4v5jyi9GxYpu5LwgYlCjrIUSA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=E7SltDf0Zvum/ksimbRCJqfFzWdKbRvsK1uLoTfCk8afQMoi+Ln+uZthpfyZ7h9mu64ydXA7oJhQXs9+O1p2L8EZ7436C65z6Ky1+c8CXfOSmtdIMxtoAZVxqOV2czzVDaIVPhcInoBqLZONgqSsScclLt6OONAD3YYhauYaggI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hmFFpKYy; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hmFFpKYy"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 43CF3C19425;
	Fri,  6 Mar 2026 21:56:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772834192;
	bh=wJ5dJGNgVGms8mpPkK4v5jyi9GxYpu5LwgYlCjrIUSA=;
	h=From:To:Cc:Subject:Date:From;
	b=hmFFpKYysdjoVzmRvq5WqtuWjJkzYwDGUBG/Gue133ZvBgjDjGfUNrdHtpS1VXhxT
	 lV1d9tmBGB9LzNLW/kcTzfvp/JOaifKBPD/7v+59SoxRDN73Z0/Qd1c4TyUOsTUQNR
	 oB1ERDRfJqavRtY16kqZfpdmY+igWQENCtuZtd0BODO7LPaePCt0JJWFfBJTf9WbqA
	 SudtZgorMtOf7o6t8KwhWYn8KMqEJF9AEVrDnVj4OD6mCjKB3Tg0Qd3ntqS9tM6mYg
	 qSj3z48NWlwaQ060GSlmHeEGBCs5CegsUPg3Y3Y1/qCHUwjEvj0hTPy43vkFp4bQsd
	 kWPklEGowVFeg==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>,
	<linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 0/7] Fix various races in xprtrdma
Date: Fri,  6 Mar 2026 16:56:21 -0500
Message-ID: <20260306215620.3668-9-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Developer-Signature: v=1; a=openpgp-sha256; l=1745; i=chuck.lever@oracle.com; h=from:subject; bh=5khROa3rZDOff7tZOqmx47arAT3kyxifOn9sI7Cu7iU=; b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBpq02FV/NedxCo99F9rvIswGV0xdXNj9bVCxHMT mGVUkd8UgmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaatNhQAKCRAzarMzb2Z/ l+YFD/47KlRg9VWz5Hh+Y7buA9tgh74+pkkwxHGLYB1WoprjgfB5BMY8ZCMrfZ26/UT2SNSLphD FY37prQL0utOki97/J/u0ZQNszdRoua/bKFLseeUEN0u+6eIbErQAzvwRa/ssDBZIImHxQklRFO nd0NvQesxRubYSwT5Ng0zYaG4Kg7YY+gBBXyG+UkwGE1FRDPX/U/gY8KQbhRTp5wF3zBdyHIU4i MANz6L8kcPfvsq5cx2qgJrn/19rQZr7qoEzAeyxYmZqK9Fjn3RG7bVI/f2YIkdO7LC6AyPl1dag 6sKFTpG1QVpDC9b8LhfBeueYb8MPDED5D00m1oNqhszSYmLQpNPLUM7zd8X+TUomsKDVAUBonIa t40/2bvuz/lBYVLB+9q69PciBQOgSUZfk72w+ZYRCjpSn3aEDtx+HiiM24TK2bNG2iTjOE6Gmif e7jGHz3hO66TLdElnjWAyOCSBm8upwAfWERuzLr2qa6gJs5YB3SNOFU2p9CizeXI/C2dI5LpNxk BVBvQTPQrtTlLa/oTAvpcgLewh7/+nETofdBSrvSJUeh7Pa6xA7C/loxUzNqbXW+a8yhrnmdr2F JtRK45S22qyJo1wMG8MVskbXE6ZDM41QwmJtnK1ehxg07wZCLb7/gIqAmfJPhgoVlwjMqF/KH/w 4OH8Emix1rldZXA==
X-Developer-Key: i=chuck.lever@oracle.com; a=openpgp; fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

Since commit b326df4a8ec6 ("NFS: enable nconnect for RDMA"), the
nconnect mount option has been enabled on proto=rdma NFS mount
points. Utilizing this option increases the IOPS throughput that
an NFS mount point is capable of.

To test some ongoing NFS server performance scalability work, I've
started to enable nconnect while testing. I've found that, as well
as enabling much better utilization of fast network fabrics, it
surfaces some subtle race conditions that are well-buried when there
is only a single QP.

This series addresses a few bugs and makes some performance
scalability enhancements to make nconnect with NFS/RDMA even better.

Base commit: 11439c4635edd669ae435eec308f4ab8a0804808
---

Changes since v2:
- Drop Eric's patch -- should already be applied
- Fix a bug with frwr_map's tail boundary check

Chuck Lever (7):
  xprtrdma: Close sendctx get/put race that can block a transport
  xprtrdma: Avoid 250 ms delay on backlog wakeup
  xprtrdma: Close lost-wakeup race in xprt_rdma_alloc_slot
  xprtrdma: Decouple frwr_wp_create from frwr_map
  xprtrdma: Replace rpcrdma_mr_seg with xdr_buf cursor
  xprtrdma: Scale receive batch size with credit window
  xprtrdma: Post receive buffers after RPC completion

 include/linux/sunrpc/xprt.h     |   2 +
 include/trace/events/rpcrdma.h  |  28 ++---
 net/sunrpc/xprt.c               |  16 +++
 net/sunrpc/xprtrdma/frwr_ops.c  | 177 ++++++++++++++++++++++++++------
 net/sunrpc/xprtrdma/rpc_rdma.c  | 177 ++++++++++++--------------------
 net/sunrpc/xprtrdma/transport.c |  17 ++-
 net/sunrpc/xprtrdma/verbs.c     |  19 +++-
 net/sunrpc/xprtrdma/xprt_rdma.h |  43 +++++---
 8 files changed, 305 insertions(+), 174 deletions(-)

-- 
2.53.0


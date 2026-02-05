Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B8E842DFE2
	for <linux-nfs@vger.kernel.org>; Thu,  5 Feb 2026 15:57:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770307053; cv=none; b=EDNYBV9oK0ktrH7jgwmoOR+TVrWvOlfF2nCl1UdsVABQLb/uQXsR45n0r2t5a2xArJddp2OCzGLD11q3rfpAii0np5GTyYcTVsV/G7cAsmI2VQC8FKJeVfgb3s5iO89ry/lZk/MMpyGferl3bAN/haQJdZDMfNmq8OOjc5Nz2Tg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770307053; c=relaxed/simple;
	bh=kcLsc7o1F0NQCc8Dmc+QOvt+qfkWaSnkseYiX1hALWw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=WpuhKVkGPAbFUuBZgFIqKgoePEgwuNLkCeLaYAq2AWuE1I3rdq5uaeUpvIr1kOvt8Q+L5Jo6Mm2UY8JP83nhTyI/0iuGCL4P/eMaYWf+pnSNIUGu4rnxnVEKdbDpVutNgXBBQIxOGx2D954dCyFDo1XyXsU/r1/iORyHdGiPjEk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bGiD6mKW; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bGiD6mKW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D56C2C4CEF7;
	Thu,  5 Feb 2026 15:57:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1770307052;
	bh=kcLsc7o1F0NQCc8Dmc+QOvt+qfkWaSnkseYiX1hALWw=;
	h=From:To:Cc:Subject:Date:From;
	b=bGiD6mKWA2LbsovsCyYMVQPfO4LEjRE3TCmCcTrxqDgqLHtqWV5YW/DzTAk4xfjDK
	 YCDymdoYOFkhatLtwnG9HEV9R/Wz63pw+Rl+dh+3F9WqynQWJDoPiB8c1ugbpz6cF8
	 C3jjrXohLR9GRvjpHWTsE6IxoiHiC8hB0ZskbDdhSvOWIpVbl937Zq+HQULcqFq0xP
	 +mQFLukX9ZgXwF3nJsqI+INs1HdwkSjVs2DuX/L8aTwIvXkmD++/JNc6pRS3aSkLSX
	 9z8T+h8UiMFj5YGAA1bZ5lB60nlI4vVuFaR/NtXjHpzaa6nNfNe45+PBcpTtW8bKG/
	 f7cTdoyR4DuWg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	daire@dneg.com,
	Mike Snitzer <snitzer@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [RFC PATCH 0/7] sunrpc: Reduce lock contention for NFSD TCP sockets
Date: Thu,  5 Feb 2026 10:57:22 -0500
Message-ID: <20260205155729.6841-1-cel@kernel.org>
X-Mailer: git-send-email 2.52.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

High-throughput NFSD workloads exhibit significant lock contention on
TCP connections. Worker threads compete for the socket lock during
receives and serialize on xpt_mutex during sends, limiting scalability.

This series addresses both paths:

 - Receive: A dedicated kernel thread per TCP connection owns all
   sock_recvmsg() calls and queues complete RPC messages for workers
   via lock-free llist. This eliminates socket lock contention among
   workers.

 - Transmit: Flat combining allows one thread to send on behalf of
   multiple waiters. Threads enqueue requests; the mutex holder
   ("combiner") processes the batch, amortizing lock acquisition and
   enabling TCP segment coalescing via MSG_MORE.

Supporting changes include a workqueue affinity fix for single-LLC
systems, a page recycling pool for receive buffers, and explicit TCP
buffer sizing for high bandwidth-delay product networks.

Base commit: v6.19-rc8

---

Chuck Lever (7):
  workqueue: Automatic affinity scope fallback for single-pod topologies
  sunrpc: split svc_data_ready into protocol-specific callbacks
  sunrpc: add per-transport page recycling pool
  sunrpc: add dedicated TCP receiver thread
  sunrpc: implement flat combining for TCP socket sends
  sunrpc: unify fore and backchannel server TCP send paths
  SUNRPC: Set explicit TCP socket buffer sizes for NFSD

 include/linux/sunrpc/svc.h      |   1 +
 include/linux/sunrpc/svc_xprt.h |  32 ++
 include/linux/sunrpc/svcsock.h  |  40 ++
 include/linux/workqueue.h       |   8 +-
 kernel/workqueue.c              |  68 ++-
 net/sunrpc/svc.c                |  13 +
 net/sunrpc/svc_xprt.c           | 151 ++++++
 net/sunrpc/svcsock.c            | 797 +++++++++++++++++++++++++++++---
 net/sunrpc/xprtsock.c           |  60 +--
 9 files changed, 1044 insertions(+), 126 deletions(-)

-- 
2.52.0


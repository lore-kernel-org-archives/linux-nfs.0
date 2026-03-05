Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAD793A9638;
	Thu,  5 Mar 2026 14:51:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772722267; cv=none; b=sIzVRLO951RY+cvdP7qDeyLplqZcJAGGXT53VG+BA2StUdfoVNRry2VaQJ4Zu9XLoB33TiHLHGUsfF9jg8rFBmQuXOWSpH2HyHKdNArD4A0HmzMtdpd84A25I1KXi4iE9gZcnOitW3x2WdGnGRP3W6cw+ZrFV71W5kjGAqr8PAc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772722267; c=relaxed/simple;
	bh=fPV5ZVhneR8ZJSE+10+wVcHcZK9+lbtLn7p4+H33Tzk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Vqj/GOUP/nfe0oqgWR/sEAhg9+HjCo5tRUX4rzJAySxZ5XVGzweoBfGOqffD7hiCX/eNp7tcsM0kCbO8baBafxcuvYC0ol9xA5lb4efZ36Oi3Es5cQ2JbFTZunMTQ2iyjDN8exZ7UAMcDtm8IFd2D9/yQVMqK2fKcmQgt6iKZ4w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bIUjFHFv; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bIUjFHFv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E6C7EC116C6;
	Thu,  5 Mar 2026 14:51:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772722267;
	bh=fPV5ZVhneR8ZJSE+10+wVcHcZK9+lbtLn7p4+H33Tzk=;
	h=From:To:Cc:Subject:Date:From;
	b=bIUjFHFvU9tZaVnhCYG1ELUQcnZd67ZwN6whypQYP0W6g8jvEVaVsYzAElOfYIWPS
	 4Zi6v7tl9aY4l+MV++Z2Mq7zyDEfssDgAqTXQe5LiH3jB9Mf5CZ5Z/+LrWNf6PVh7G
	 YxhhU+q0w8m0tTXiiKtZm70BOc3nOrJhevCbEVg2zp1fjZXsZsy8W7UT5XuhqDnBwG
	 PaNJ7NuLbkY/nNylhtXW1IyXk93gzGCnEjtqm+mROPrRV96ag5mr00XWo3CxvvaTAp
	 Od3RmDrFC3TBeo4Gwl4sods1BPaOIQwMj2PILzMn7mv+ZU7VunUHine3b2f3os9S0L
	 CsPhiCDE0/8xA==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>,
	<linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 0/8] Fix various races in xprtrdma
Date: Thu,  5 Mar 2026 09:50:55 -0500
Message-ID: <20260305145054.7096-10-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Developer-Signature: v=1; a=openpgp-sha256; l=1717; i=chuck.lever@oracle.com; h=from:subject; bh=eZ3hxbviwh21eOl3yeHsTTZ/XYkx1AAWgktHfHZB/YE=; b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBpqZhORTJbwmYnfGVmWH7E/xUJ2+Pt23WC3yG4b KE5VggLmmyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaamYTgAKCRAzarMzb2Z/ l9p5D/9w1sqXSNVGIqaNnqTE+iBZoerD90t1INA5iKAfmBC32pPFNb9LDOAqALcuVisYki4pU1V D8wwUpgMbhFZNQ8ttxGn4XxAYTGzDuuqG1FR2ueF8EfQfDyd+ayhS1rb3/Nc1i0uTXLBNm46IUL XCy89tnBJYrb1Xxabw9e3/PmTFzG2DRfumhKdvevoT22i8AjscL8HcSun8pNNsAXCOzIbihHlw4 UEJJLC9on768s47TkFvFLf9t4sEJ5XxNjkof3qeU6Crqbj9uC8XaUFVPN6t0XbFLuCN8WHo7dvH k6WuE3E/agJsQcoQCO6pHSF6qQEVV3yQNeNvpdGUKARC62+mIgLoLm4lNGt7R18Jtdim1rd3Hcb BV4f3STla5+5XmlnmToHiL8mZ3HgS8CP9mjByTfeKeDZ1h4AeXyqiG4lCVfvEqAACHhxFa/4UbG jyNpqJ48bE+3smABLUNO68pQcA0L0ERKSxdXQmmDiG76cfzDPSZNJQtrt8Fbxlcij0X2H9U3xU6 zlHdFQOf78tLED/DLfHU4iMa9r7PIHRI1SAR3y8CaCFV48QZwxiRqMlmO2iEIJUq5IWO9HDHhRt r66uvYDu3QqiSWDC4D9yieEwtV2h6YpmmUMnRgPKqvfEkHvm+mq/zugd3aP+PZdknLVOfxG9iGx NCDmDFV/6QfDclA==
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

---

Changes since v1:
- Expand single-patch series with more fixes

Chuck Lever (7):
  xprtrdma: Close sendctx get/put race that can block a transport
  xprtrdma: Avoid 250 ms delay on backlog wakeup
  xprtrdma: Close lost-wakeup race in xprt_rdma_alloc_slot
  xprtrdma: Decouple frwr_wp_create from frwr_map
  xprtrdma: Replace rpcrdma_mr_seg with xdr_buf cursor
  xprtrdma: Scale receive batch size with credit window
  xprtrdma: Post receive buffers after RPC completion

Eric Badger (1):
  xprtrdma: Decrement re_receiving on the early exit paths

 include/linux/sunrpc/xprt.h     |   2 +
 include/trace/events/rpcrdma.h  |  28 ++---
 net/sunrpc/xprt.c               |  16 +++
 net/sunrpc/xprtrdma/frwr_ops.c  | 176 ++++++++++++++++++++++++++------
 net/sunrpc/xprtrdma/rpc_rdma.c  | 174 ++++++++++++-------------------
 net/sunrpc/xprtrdma/transport.c |  17 ++-
 net/sunrpc/xprtrdma/verbs.c     |  26 ++++-
 net/sunrpc/xprtrdma/xprt_rdma.h |  43 +++++---
 8 files changed, 305 insertions(+), 177 deletions(-)

-- 
2.53.0


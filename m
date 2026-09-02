Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D72413537D0;
	Wed,  2 Sep 2026 19:29:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377351; cv=none; b=g8IfcXkeRSEl7gx6Anzuz94m/U87t5092qUL2NFDq+cbvY+8FcgkaVuw2BnsrnUkbzKTfktvgaRwf5c0shN3MSkoQqtTBXhZfkjIQrIiZ/0s3C+akKrqOWIO+27IV1Lcj9QKCMM0D97yGI7y3kQ5qaYu52k7pGOfo4C9I59q9to=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377351; c=relaxed/simple;
	bh=pFZpWrusDpYDrcKsHdu6jpnPsC/tyI6y8dfgGimyMPI=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=cBLedjNdx+YxOZ6nATYb60tkx/u+7GC7PpNzrpvSXm5fAyk4op1oU9rVEGN7gr+6mRLWpJFUq8qs+ho2WlhQ8a+2GS67i+tkJfjRAO/+zVN+7t7ECUz6a2X5xS0BYKW6uXdz6/cyrAEAn5Kh/zKLYLaI7kcj7sdy1zuJq8t8dmA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Wc0AsC7D; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Wc0AsC7D"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F04221F000E9;
	Wed,  2 Sep 2026 19:29:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377345;
	bh=elSgsOTp195q8ronk36PPD5eSCDF+HVBMa7O6tTWdE8=;
	h=From:Subject:Date:To:Cc;
	b=Wc0AsC7DGyv79BbCjoq/o1I1+X7s2QfdlCbYhEZrUA0jcO+0cKmZ+1ZfBLAxouuVP
	 Kwdn5aXq0daRrUpXTCAhmJ/Pw3mwIyAGzisOIcYEK43XbPb7pSLx6ALDMYTSsKmv9l
	 PQB6NGyy8umgETG30LY0JtQXWAvTp2B6l7hYQOO/A4nrE2BHiWH5UPD6hk8BS5BY7E
	 Whj18xfIyFNUzLvsTXMxBkx0v/KH6uONf0u5uNUm8fxjHHqzcG64VV1ux91Mp76fOk
	 chQmqJdiK8cjK/wQlgehUai8PFsY17Kc78ustVfQ8Ls5WfpxQXZjUUMwOQ2pbFBnyA
	 7PQBiVfKx6ETg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH RFC v2 0/8] Reduce lock contention in the NFS client
Date: Wed, 02 Sep 2026 15:28:45 -0400
Message-Id: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22OTQ6CMBCFr0JmbbVFreDKxMQDuDUsoExhVFoyR
 aIh3F3Arcv3M9+8AQIyYYBjNABjT4G8m0S8isDUuatQUDlpiGWsZbJVokW2npvcGRS403vUsTL
 KSJguWkZL74V2g+vlDNnPDK/ijqabOXOtyAOKgidEPVueqSK3afLQIc95TaHz/Fk29WqB/X3fK
 yFFUqa2TAt9sKk+PZAdPteeK8jGcfwCtyXzQt4AAAA=
X-Change-ID: 20260831-performance-e465e621c1c0
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3428; i=cel@kernel.org;
 h=from:subject:message-id; bh=pFZpWrusDpYDrcKsHdu6jpnPsC/tyI6y8dfgGimyMPI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHj267sbiI3Se3WDYaW6B5wgpaBCTOVawbmqa
 0b9J2H3xPaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph49gAKCRAzarMzb2Z/
 l9iyEACwyjh4UbAqveJJ5CY5IVz0OHkziVrMFqZKRUyx2n0bJtcGqEiWEGne9ExZw+rEf9muMsg
 6uMShCWlBvYxy7tBu6UQdwXVVGrOneVOhOP8z+S7HvuMVkkMtJ4R0goaCETM2QvhVrHCAg2aF3f
 b4eT1xRcpU0vPoktngrjQ1f+yoNS44CQzgspH4Sh5fcV9i/EOopITMhZCcMxTVrK0X++/XhU3tw
 bTRgAlCi9phxlio7UWJ2gOTl+rhK7j+xhD6vul6yZ/D15bsydqKWy+wTiTbUyUgK/SPs26XEjKA
 7MIHtW5qioohYr5wYomAqF2CHdoRZV3ya/CVm2Bs7VN2+wOevI4K+0v+ubXpHvacoB0cf/RyyUl
 v0Fa4xS3UQ5SB3567eDFuBNgBTMqN0sV62CdYJzTEP5hfFyvc2WAJVq7lrKRTZUAVeCaSs9PaO1
 Jr25zTvW1DN1/0ZoKZGzAsm015A5sX1OQathOWM21UH6s2Rx/3IHDmrlKXXeyd3Fdj7+ghcDgqG
 I+Idi0zpIj24FbDrAt1t7o0J3Y27OPr6YkxlmEOd2cfqVoCTXRsSx1oTKAx9cnR0xhaFfoXK+43
 D5KhXKMjnVd/M1nSEWjxmucykfU2A7EuuM5txyLSgNrvol/BEIyEWr1zRDqBQAutfs0WnDInSmV
 bEnddJBj/sTHXBg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Under a 4KB NFSv3 workload on 100GbE RDMA, roughly 150 RPC worker
threads drive the client, and lock contention dominates its CPU
profile: up to 53% of non-idle cycles are spent in
native_queued_spin_lock_slowpath.

Three locks account for that: reserve_lock on every XID
allocation, queue_lock on every submit and completion, and the
unbound worker pool lock on every enqueue and dequeue for rpciod,
nfsiod, and xprtiod.

An earlier RFC put this fix in the workqueue core, falling back
automatically to a finer scope when the configured scope
degenerates to a single pod. Tejun rejected a finer global default
for unbound workqueues and suggested two alternatives: a sharded
scope between CACHE and SMT, and a scope change on the NFS
workqueues themselves [1]. The first became the
WQ_AFFN_CACHE_SHARD default, whose 8-core shards still leave a
12-core single-LLC system with only two pools. This series does
the second.

Dispatching each new async task through rpciod costs one enqueue
and one dequeue per RPC, and this series leaves that hop in
place. Running an async task's first states in the submitter's
context lets its completion callbacks run there as well. A pNFS
read resent from rpc_release then waits for a layout segment that
its submitter still holds. That is the deadlock commit
54e4a0dfa25d ("pNFS: Fix a deadlock between read resends and
layoutreturn") fixed.

The scope change is applied after alloc_workqueue() has
registered the queue in sysfs, so an administrator's write that
lands in between is overwritten. Closing that window needs
workqueue_sysfs_register() exported and WQ_SYSFS dropped from the
alloc calls. This series leaves it open.

[1] https://lore.kernel.org/all/aYUVVuIidMpuYy3j@slm.duckdns.org/

---
Changes in v2:
- Fix send bvec use-after-free in xprt_request_dequeue_xprt() (sashiko)
- Replace the three workqueue exports with workqueue_set_affn_scope()
- Split the WQ_SYSFS patch into SUNRPC and NFS patches
- Drop v1 patch 2: async completions in the submitter can deadlock
- Correct the pool cost and SMT group wording in the scope patches
- Link to v1: https://patch.msgid.link/20260831-performance-v1-0-8d9fd9b67f96@kernel.org

---
Chuck Lever (8):
      SUNRPC: Use atomic_t for XID allocation
      SUNRPC: Split recv_lock out of xprt->queue_lock
      SUNRPC: Set WQ_SYSFS on rpciod and xprtiod
      NFS: Set WQ_SYSFS on nfsiod
      workqueue: add workqueue_set_affn_scope()
      SUNRPC: Reduce rpciod workqueue contention
      NFS: Reduce nfsiod workqueue contention
      SUNRPC: Reduce xprtiod workqueue contention

 fs/nfs/inode.c                             |  8 ++-
 include/linux/sunrpc/xprt.h                |  8 ++-
 include/linux/workqueue.h                  |  2 +
 kernel/workqueue.c                         | 37 +++++++++++++
 net/sunrpc/sched.c                         | 18 ++++++-
 net/sunrpc/svcsock.c                       |  6 +--
 net/sunrpc/xprt.c                          | 85 ++++++++++++++++++------------
 net/sunrpc/xprtrdma/rpc_rdma.c             | 14 ++---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  8 +--
 net/sunrpc/xprtsock.c                      | 18 +++----
 10 files changed, 142 insertions(+), 62 deletions(-)
---
base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
change-id: 20260831-performance-e465e621c1c0

Best regards,
--  
Chuck Lever <cel@kernel.org>


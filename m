Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD1AF47127D;
	Mon, 31 Aug 2026 18:22:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200530; cv=none; b=WI6Qzf+V0w7NiSVDGsDAf+P0risLHsUCakx2fl5h7IADykGUjfYJSad6nlI3V6oiC5QdjEVk/UVZP5XK75CZH+HB4zl65lvzt/9ARFmHb4+YJxV7q3UvsyTsCTM0+mdSQDuGgDAjHY0Fn/umSkdxGI+3SHOfcLwbWOMjZ7O3L80=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200530; c=relaxed/simple;
	bh=yj3EvYCLzjKFhv+Rquuc/IuVpIQmgnORf07dZ1mEddk=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=faJsnUihaBfMMJORsMVJqTVpfFeqhfXlCCkIA/RolEiYftE8MUJtODsumSLXsiCA8FZFPcfuashhTHy6eVa4hEEhB6CywljMZ2aCIUAeRS2RUtLvHVRrf77qNFpyX93XVIbN2MZGNbGJIAJjDPUEEy+mlJs5cdNGeTu91PW4t8Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IpmR2gMe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IpmR2gMe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E24BB1F000E9;
	Mon, 31 Aug 2026 18:22:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200528;
	bh=zdqiXvRTRVGzU0oGBApGif3Z6ViM1kOSdvfLnJu8eI4=;
	h=From:Subject:Date:To:Cc;
	b=IpmR2gMeJvzM2MxYBF13noOT3Ke4X3vXNGDtHuNxv5AJiMt9lGR8XrwGfQ2bzp6UH
	 Aa7s0jd4K5fWT+2kSnmjgY09CJsTuZVLHGJNVcJRby+rHOR5ls3AXxJQog+Qy6KP6a
	 cZkfxe5D2gCNm3DKSb+nQZ86g6iAi2Oxc9m9zif2xC6ymYiqFo9tBbkRMTZProbMMZ
	 b64XU9mpVFbDWebMMnCkTvOnGX303+Afui4FYZoMLIDHmxIWVbiSFq3Q3SKz/2NsLR
	 i/SRrBnURY4Q7blXrJGT9kC8z7deMXFzbGhtMgkbmHqIuBPAHxJdPbts0gnulEs3dm
	 E9dIW33nFK+mg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH RFC 0/8] Reduce lock contention in the NFS client
Date: Mon, 31 Aug 2026 14:21:56 -0400
Message-Id: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQrCMBREr1L+2mATNYhbwQO4FRdJnLZfaFJ+q
 gildzfR5XvMvIUyhJHp1CwkeHPmFAvoTUNhcLGH4kdhMq2x7XGn1QTpkowuBijs7QHW6KBDS+U
 xCTr+/Go3ul7OdP/L/PJPhLl26sy7DOWlJIaqknDPcTu6PENoXb/oQy/ilAAAAA==
X-Change-ID: 20260831-performance-e465e621c1c0
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2190; i=cel@kernel.org;
 h=from:subject:message-id; bh=yj3EvYCLzjKFhv+Rquuc/IuVpIQmgnORf07dZ1mEddk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZGbBbJadZ+pucCIr8Cp41aEhLVCUfC7wIuj
 CPMNEdeV42JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGRgAKCRAzarMzb2Z/
 lzo7EAC/CA4xxI4g+rXaULp8hb50Ku1/8ijKNmFJmnTHB0ngNgo4uiVTiBPpj1J+xXAahUn7hEr
 ckUWgq35eR8iBEu1HXvD4atjE9Xw7SbQQk7XHwGkyG9GKHHly47hN/nucZJBo2KWjeby4j1jvRO
 KaY3NI22F+jMSgWQUeXkUjdNKx4oAgJruIID9vEK1EhuKfVvCxdFdSiVZoXg/jPgnnAfrupyL/w
 E/kAOqua96DkPQ0hyCt6eS3RkAiit/EZ9HtvdRiQGpGb0blvWLdk2olm+j7Y2gZiFKQmtSUgLI5
 Eg5zg1I89Y1M6Ph87V0yh0TvGQ8KbXnhTiyUH5F9SuOML01yAEviQglALhW0UstxwBiKd+T/l8T
 t9mCu46AcrIMcincXCFd9c79j90S3JoA5MWfLiPtZJFG6taA7ycfV/r/gNWyK/AhtwgIpMNrdaG
 rhcpPDVqaoSE5UCVCM0SjENljiotEgm0HVCRI9UUqJgddokU9Wu8amasg+4AziVwXHF6uH/ABT7
 FZ27Ciiz6RvYqJAUfzi+00PyEdP4TqIANatFu7ma/xb250h5CpsXjrs+zxXbvNOg2fw4hO4Q94z
 subiwKXjfsrOGmFeOKqElT2mqalLHNL1dg3XLp7bM/3diqN3KtD3mpHK1oUBEUoF2mgpl2ob/4P
 A5YX0swC2hYv93A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Under a 4KB NFSv3 workload on 100GbE RDMA, roughly 150 RPC worker
threads drive the client, and lock contention dominates its CPU
profile: up to 53% of non-idle cycles are spent in
native_queued_spin_lock_slowpath.

An earlier RFC put this fix in the workqueue core, falling back
automatically to a finer scope when the configured scope
degenerates to a single pod. Tejun rejected a finer default for
unbound workqueues and suggested two alternatives: a sharded
scope between CACHE and SMT, and a scope change on the NFS
workqueues themselves [1]. The first became the
WQ_AFFN_CACHE_SHARD default, whose 8-core shards still leave a
12-core single-LLC system with only two pools. This series does
the second.

My test harness is transport-limited, so the freed cycles appear as
reduced submission latency variance and lower tail completion
latency rather than higher IOPS.

[1] https://lore.kernel.org/all/aYUVVuIidMpuYy3j@slm.duckdns.org/

---
Chuck Lever (8):
      SUNRPC: Use atomic_t for XID allocation
      SUNRPC: Execute initial async RPC states in caller's context
      SUNRPC: Split recv_lock out of xprt->queue_lock
      Set WQ_SYSFS on key NFS-related workqueues
      workqueue: Export the functions needed for WQ attribute modification
      SUNRPC: Reduce rpciod workqueue contention
      NFS: Reduce nfsiod workqueue contention
      SUNRPC: Reduce xprtiod workqueue contention

 fs/nfs/inode.c                             | 18 ++++++++-
 include/linux/sunrpc/xprt.h                |  8 +++-
 kernel/workqueue.c                         |  3 ++
 net/sunrpc/sched.c                         | 42 ++++++++++++++------
 net/sunrpc/svcsock.c                       |  6 +--
 net/sunrpc/xprt.c                          | 63 +++++++++++++++---------------
 net/sunrpc/xprtrdma/rpc_rdma.c             | 14 +++----
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  8 ++--
 net/sunrpc/xprtsock.c                      | 18 ++++-----
 9 files changed, 111 insertions(+), 69 deletions(-)
---
base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
change-id: 20260831-performance-e465e621c1c0

Best regards,
--  
Chuck Lever <cel@kernel.org>


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6161124A078
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 16:18:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787933885; cv=none; b=u6NnOkU9hcsWUBc3smDB8zN2u85HSaEMgWYoQ24TX6Pw937Fnp3/feZHAy1v/hsuofNz2pwrsqZ7MTX5Zwb8bGgXhv/KeFzrdVudXIWn35rx2MUx9q0JTytv/O+cp8ear17m57mPpIYNDqjdtnMmDoUi18QMa4m9Oei3HMVWfj8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787933885; c=relaxed/simple;
	bh=SNxt15gRPv7ozskJWXH8ENuaiAvDys5php6m9Fzd2jM=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=M+JUEGIM/YW7kZ++5KQHYmv0Q5+JuIh8uy0SK4DTSbDf+vLLS0sgyh5DKCPq3ch+9gj1947oYWWQ8zrE5FpD8DOttP5/OVHU5RMKyqAvPeNxSrMv3rOSKlzOOsxFCKC6GtSWwFp8lnifM2JtwCiFXxxwPR9GiWUHG+H3f/nk6Uo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BszAOJxx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BszAOJxx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 664421F000E9;
	Fri, 28 Aug 2026 16:18:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787933884;
	bh=5YNcc3ZA0uAY+7WSIhmKKL9lYz6tfsdqZNXtONS0Uj8=;
	h=From:Subject:Date:To:Cc;
	b=BszAOJxx4/+dHp1MMCOTyrPnnrOH7V7nWHQToYMMCEBadmbLlU27tqMOST4gaq9Bn
	 gz8dJ01Ob++atZbikUWQlPywGyyBr5m5Q/v335T+R3A0xo4Utn9MZkcYui/H9OjDf9
	 4AvHphl5w6cmdiWUN15lCGb/NLaLZUhudMt5TSTj8AnKgH/PdibNELXfCowxG+YbBF
	 CY3OdU1+nf02fYltnHG5qOuNKlIf7QnGKm9yj+saxsaWIyFN7cAA0pwuw2ZGxEb5z1
	 IlOK00QYFB+Ux17OKlJPLkCdz/Fq1cyWO7V38+YAzPSQq+yuUzRLp0EEqituuATbFp
	 RKuOP/VnyHf5g==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v2 0/7] Implied-ACK eviction for NFSD's duplicate reply
 cache
Date: Fri, 28 Aug 2026 12:17:52 -0400
Message-Id: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3WOQQ6CMBBFr0K6drStAsaV9zAs2mEKVVJIW4iEc
 HcprF2+yZ+Xt7BA3lJgj2xhniYbbO82kKeMYatcQ2DrjZnksuBXmUM9Dp1FFQk8Dd0MqLAlMNx
 QiaUubxzZ9jt4Mva7e1/VwWHUb8KYZGmhVSDQXjls0wmpuzgTaogUonVNmrQ2xN7Pe9skkurIu
 MviT8YkgIMWdS5IKJNj+fyQd9Sde9+wal3XH0rIIszwAAAA
X-Change-ID: 20260325-duplicate-reply-cache-f0fe7c7b740c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2535; i=cel@kernel.org;
 h=from:subject:message-id; bh=SNxt15gRPv7ozskJWXH8ENuaiAvDys5php6m9Fzd2jM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqkbSzxw8X7hXxZjI74HE+dvxXZIW7vZFtdY5p/
 dZIT3r1Sn+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapG0swAKCRAzarMzb2Z/
 lw2DEAC00252d6OY8anvvlsE4wt3WvLkFjhJkCTQ4qcWIh3qPpT6EXbthbsJ4/xYaV3TVZ/nbm7
 QU0Td80QXtX7ntqWipncGEb8X1zvX0IWwtfMN1nlsgrbwZ4KaM8uQMk2NqyhZf8C+Y2HC3Mcwsj
 s1tKjesC83oBKq8Xrl4jztXEC2A+ZYVGBbbmzxdKsOnACWnp2cJ0XVnVWCN+7jzVUe3dp1DRs9I
 wgpfSVnrdsX/BQ4Ahg+2nTsqQFVt5v+dkKHebpyrN7CxHJ0wgMTMHNg+Cysh6njhvecn9PMOKvo
 frQADQKq/U9zfxdOTCze7l1f3zW01Tnqbg5Q0TQSaks+aG7Mu8vCbmGe7h7ZWkHEs8D325mZ5o6
 6hBrHE35JdmQXNtxWSzVh4U4mva9I5Ld7CPaPEMDXqBjR/lgMB/4ag42h/5FyOJ1rOv88l/J/X+
 nFD/zOdPlfC9i8AU/ZtMIxdf5S15WqReAvPxYGZJVOk9wJ0JLQnc8VLquMq4nsD8zsBCU7GLmqK
 SeXM5K42WB7Ws7Jhm/UDj/utrr1MDeq4nA645e9RfZwIGK7tijKef3msBARjJ43RBs6nLdX30pR
 8eOHpYYb0lHOQFxsu650bO5Z20vh/Qhr5BdSLdoGAwuYni+Qu3Y/2TW9hZYxEKKFs4ubxrYh9B6
 6y+r4lA2XCmWavQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Connection-oriented transports (TCP, RDMA) guarantee in-order
delivery: arrival of a new request proves every prior reply on that
connection has been received. This series exploits that property to
evict completed DRC entries as soon as the next request arrives on
the same transport, rather than waiting out the 120-second
RC_EXPIRE timeout.

Each DRC entry records its originating transport. A new
xpt_last_recv timestamp on svc_xprt marks when the most recent
request arrived. During bucket pruning, nfsd_prune_bucket_locked()
compares the entry's timestamp against xpt_last_recv; a newer
value on the same transport means the reply was delivered, and the
entry is evicted immediately.

Profiled with "perf record -e cycles -e cpu-clock -e LLC-load-misses
-e branch-misses" during an NFSv3/RDMA 4KB random-write workload.
nfsd_cache_lookup overhead dropped from 1.53% to 0.76% of CPU
cycles. The rb-tree operations (rb_erase, rb_insert_color) that
dominated LLC cache misses fell from a combined 13.2% to 1.1% of all
LLC-load-misses, because shorter-lived entries keep the per-bucket
trees small.

---
Changes in v2:
- Print the DRC eviction tracepoints' age field as unsigned.
- Link to v1: https://patch.msgid.link/20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org

---
Chuck Lever (7):
      SUNRPC: Assign a unique identifier to each svc_xprt
      NFSD: Track transport in DRC entries
      SUNRPC: Record last-request timestamp on svc_xprt
      SUNRPC: Mark connection-oriented transports on svc_xprt
      NFSD: Evict completed DRC entries via implied ACK
      NFSD: Add tracepoints for DRC entry eviction
      NFSD: Record DRC population in lookup tracepoints

 fs/nfsd/cache.h                          |  1 +
 fs/nfsd/nfscache.c                       | 88 +++++++++++++++++++++++++++-----
 fs/nfsd/trace.h                          | 49 ++++++++++++++++--
 include/linux/sunrpc/svc_xprt.h          |  5 +-
 include/trace/events/sunrpc.h            |  9 +++-
 net/sunrpc/netns.h                       |  4 ++
 net/sunrpc/sunrpc_syms.c                 |  3 ++
 net/sunrpc/svc_xprt.c                    | 54 ++++++++++++++++++--
 net/sunrpc/svcsock.c                     | 41 ++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  6 ++-
 10 files changed, 222 insertions(+), 38 deletions(-)
---
base-commit: 3a4d7c7c9466a07fa4176ce35180149709d92c22
change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c

Best regards,
--  
Chuck Lever <cel@kernel.org>


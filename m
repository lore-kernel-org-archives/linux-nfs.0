Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C88BB30566A
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:54:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048499; cv=none; b=h6hQHmYlrv8Zcjwd2czcHYOHlVvGwH/DgCsW+e11Gi37wKVV+iojcYIY9aYkkVW2qjH3AdqmD7p0VeFSyV+tOBo+RGFYtyIdK00fjlcFVmfi4h3gNGKngt0lLxDwOX1HhEsKI2wiqhItJ0ONVMw8HxKU1LhsM9ynnihQqWJKZlA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048499; c=relaxed/simple;
	bh=Pev6O4e8kPQXwfiuRvBrnICQ6Z0IvNs7mhF25uS1rAE=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=iAd6G/fuEfsbRIIqz8F4x9Cn5WYNTO/1C1uSQ2UZtK2+YXJlaLdp84SB6JntstHIeLiKGRj7CFYuKTbcZSIuP1cjTkJrLyrGIJqfeEEWm0b6m5UPGc2vyg52P3IwcerbpPV8AaM+OyTPigglK4sTwItfq7YIgcNA6CmyCUlxk90=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dv+P3zSg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dv+P3zSg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D93221F000FF;
	Thu, 10 Sep 2026 13:54:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048497;
	bh=iacugWhfv1kci/EwQB2n/hGSl/jJ8pZ50KOSPr0KAeI=;
	h=From:Subject:Date:To:Cc;
	b=dv+P3zSgleVeYj6/arIUY9Ys1/jlj30wpz8T7Vcpc4kMsL+Sf/3Ehu3Yw29Jk6J2V
	 LSGbS1rEcm2ZTC3DVSWWqAJtDe5pNSrL5egpnGICHOgTxu7gEkNxZ7vwx7cCq5XQfO
	 e1uSYqMIMAgSTCRGsYSDZLzG6QJxmK033E8dU+Ge8gN3OUpzBR/2oHEMBGVy/dBG7H
	 LMkQmYj51UUqaX54vsg7ZNemw6xvaXKSJ7UY8jHP8ME/q+ZrbeSc5Q/uhmtL8dj07N
	 PTMfXQM58FSi182m2GLrxFclo1+0cz+jsKmnQ0ks0Ze3OgBDp8SgQ5xnJkRXQIVc2w
	 /MBG0vmMajM4A==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v3 00/12] Improve the scalability of NFSD's classic DRC
Date: Thu, 10 Sep 2026 09:54:40 -0400
Message-Id: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3WOQQ7CIBBFr2JYOwpoQV15D+MCpkOLNrQBbDSmd
 7foRhcu3+TPy3uyRNFTYofFk0UaffJ9mGGzXDBsTWgIfD0zk1wqvpEV1Leh82gyQaShewAabAk
 cd6RRW73lyObfIZLz97f3dP5wutkLYS6ysrAmEdhoArblhNStg0s1ZErZh6ZMWp9yHx/vtlEU1
 SdjJ9WfjFEAByvqSpAwrkJ9vFIM1K362LDSMcpvze6fRs4aWXG1J6W40fZHM03TCxLDono3AQA
 A
X-Change-ID: 20260325-duplicate-reply-cache-f0fe7c7b740c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=5291; i=cel@kernel.org;
 h=from:subject:message-id; bh=Pev6O4e8kPQXwfiuRvBrnICQ6Z0IvNs7mhF25uS1rAE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqoramgP2E8d2lD69hq1YoJ1KrsIX82f9qOZqp6
 KmJJ5P+zxyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2pgAKCRAzarMzb2Z/
 l25mD/9hUqe+oZskIkj+qV9zZUB+k7VPtGpNRNGeuZr/W+DLz7ZF6ESWgrXNhvc4trwLM7cCqXq
 BCoy4QCdXFkaef7a44lYudha93L2VdwH4ycjQ1DIusCMx5+xFzti2T99v3lup8UREtQsBexk5/G
 7ypq6MF5AQMG2dr4xWIzp38GoR9RBI9neCzcoqsaL2l5H4qlrSpA82uJnKsXZK4kUgxA73TfRjY
 zFYYQO14qMT94gVYXH2PRBUYfVbF/3/Xq8BoYKia/d68q1PLFIDWoqti3rSI36vMHXsyp+KIg59
 LeQAEZbsWc5/ermFVIGbs1sx2VKwIdzcJybgfoW+c8H+Jjk2bRdqtcRFWWnF7QOT3+HLCa3B1Jl
 /htW7h8AJoOvXFb5rvYfv5dYypthQBdQG62gMrfrLoDCA5mk/Tm5ImsalpWEGFtRsPwC3unm70N
 +5If9TeOtuZzedya+Ehn/dhJDxp39cYFVwZdmsgVqlH/BjaEYkYnlRkiESIXm0zldJJlStRVzK5
 m7PCZoTfSH8zO8AAfeb7wjioHcvTq2fvmj2+cUHnqKy7e8z4RtIEN9vt2TR5+8HlrvwH6FADJ2f
 J9AaCw+Pq+Sxv0KJ4nx4g+I8CHAYceSEPh4MyzgGYA10WHjr5hAokTKzeo2DJQfEZmgAd43Eg0R
 Z2MN7y4xjUpAOkg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A completed DRC entry currently stays in its bucket for 120 seconds
whether or not the client already holds the reply. On a busy server
those entries lengthen every bucket walk, and under pressure they
crowd out entries a retransmit could still hit.

This series modifies the DRC to retire an entry once there is reason
to believe its reply was delivered.

1. The transport reports delivery outright where it can. TCP now
   reports when snd_una passes the reply's sequence number, and RDMA
   reports on each Send completion.
2. Where no report will come, a later request on the same connection
   stands in as an implied ACK, since a client on a live TCP or RDMA
   connection does not retransmit within it (RFC 1813 Section 4.5).

UDP continues to use a traditional time-based eviction mechanism.

The first mechanism is the more reliable of the two, and the backup
mechanism is more of an informed guess. A pipelined client sends its
next request before the previous reply lands, and an entry evicted
in that window is lost if the connection then drops and the client
retransmits. In the current NFSD code, memory pressure and RC_EXPIRE
already open this same window. For instance, on a server with fast
networking and storage, pressure eviction already evicts entries far
younger than 120 seconds.

Two DRC capacity guards that were sized for a cache full of stale
replies can be removed, now that reply delivery reports keep the DRC
small. The commit messages for those patches explain the rationale
in detail.

v2 of this series (implied ACK only) was profiled with "perf record
-e cycles -e cpu-clock -e LLC-load-misses -e branch-misses" during
an NFSv3/RDMA 4KB random-write workload. v3 has not been re-profiled.
nfsd_cache_lookup overhead dropped from 1.53% to 0.76% of CPU
cycles during this test. The rb-tree operations (rb_erase,
rb_insert_color) that dominated LLC cache misses fell from a
combined 13.2% to 1.1% of all LLC-load-misses, because shorter-lived
entries keep the per-bucket trees small.

---
Changes in v3:
- Add the reply-acknowledged callback and its TCP and RDMA reporters
  ahead of implied ACK, which now defers to a pending report.
- Split the prune-loop restructure into its own patch.
- Move the eviction tracepoints ahead of the ack patches; the
  implied-ACK event now lands with implied ACK.
- Keep err local to the pmap_register block in svc_setup_socket()
  (per Jeff's review).
- Never move xpt_last_recv backwards when nfsd threads race.
- Fold the XPT_ORDERED patch into its consumer (per Jeff's review).
- State the re-execution exposure of implied-ACK eviction instead of
  calling the DRC advisory (per Jeff's review).
- New patch: remove the DRC request checksum and payload_misses stat.
- New patch: remove the 256k-entry cap on the DRC size.
- Link to v2: https://patch.msgid.link/20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org

Changes in v2:
- Print the DRC eviction tracepoints' age field as unsigned.
- Link to v1: https://patch.msgid.link/20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org

---
Chuck Lever (12):
      SUNRPC: Assign a unique identifier to each svc_xprt
      NFSD: Track transport in DRC entries
      NFSD: Prepare bucket pruning for out-of-order eviction
      NFSD: Add tracepoints for DRC entry eviction
      NFSD: Record DRC population in lookup tracepoints
      NFSD: Add reply-acknowledged callback infrastructure
      SUNRPC: Add TCP sequence-number ACK tracking for reply delivery
      svcrdma: Fire reply-acknowledged callback on Send completion
      SUNRPC: Record last-request timestamp on svc_xprt
      NFSD: Evict unacknowledged DRC entries via implied ACK
      NFSD: Remove DRC checksum and payload_misses stat
      NFSD: Remove hard cap on duplicate reply cache size

 .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +-
 fs/nfsd/cache.h                                    |  20 +-
 fs/nfsd/netns.h                                    |   2 -
 fs/nfsd/nfscache.c                                 | 310 +++++++++++++--------
 fs/nfsd/nfssvc.c                                   |  20 +-
 fs/nfsd/stats.h                                    |   5 -
 fs/nfsd/trace.h                                    |  81 +++++-
 include/linux/sunrpc/svc.h                         |  51 ++++
 include/linux/sunrpc/svc_rdma.h                    |   1 +
 include/linux/sunrpc/svc_xprt.h                    |   6 +-
 include/linux/sunrpc/svcsock.h                     |  10 +
 include/trace/events/sunrpc.h                      |  10 +-
 net/sunrpc/netns.h                                 |   4 +
 net/sunrpc/sunrpc_syms.c                           |   2 +
 net/sunrpc/svc.c                                   |   1 +
 net/sunrpc/svc_xprt.c                              |  53 +++-
 net/sunrpc/svcsock.c                               | 119 +++++++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  14 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |   7 +-
 19 files changed, 541 insertions(+), 186 deletions(-)
---
base-commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9
change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c

Best regards,
--  
Chuck Lever <cel@kernel.org>


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA38C51122F
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752096; cv=none; b=pyEypyvpCVwN6maKBgNfHwiwgL7Iy7fp6mZDgZU6y3q5RHf4XhyoccNFlw8AIh/cOGYzGMFK4xqfyQiOhk/Rojr4x39Nhp38E87sdBgnnHDwcB7tLTiDo5l1QhhzmaV0mR2MhWJ1dFewYN32HUZjHjj6ze5zohmguhIIX0U4/v0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752096; c=relaxed/simple;
	bh=tZCtXnvOdKnY2wkzjY8wQjxZ+M72kaA/dhOCiEsm1lE=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=DJePqG2Xlgq0lvTmMr7CacSHsS63iVDn4hu0oxNg3uoduBty6f/SZEgg6l6As44svtclggkOV4XVlh9vYvlErtztZDmjMyvbmTWp/mwFeA5U/1gKMxgDrJEEO5TVweODMJBWOXJoMruHoOJq7gUYVDLy7ZAA13F95Umwdj8O+Sw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZtOOylME; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZtOOylME"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2976E1F000FF;
	Fri, 18 Sep 2026 17:21:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752087;
	bh=nitkkylrn55NPZ55Z/Xbt3e6IvIU1b9SO12QPK1tgjo=;
	h=From:Subject:Date:To:Cc;
	b=ZtOOylMEZCZl6lVINHNazmvNP+WK/bcwVCpdaHU/Wajzd6RhmjIRJugTu7p8Ipnq+
	 z2VuA77fhvd2r7TO+hysiY+zx/xaIaZpA+NZNwiruItyrhfc+ogWch/IHYoNwqhdlL
	 zm+bD+WWJ8/d0cZv0XTKtzirjwaMykMWf+mltpxHXKtMrbUWgHw9nFy62ULbiShV1S
	 +BGbtb5wlIOroeFaNNiRXkIWTPLxPXFiORq2zG4aeOZrB+pbWILAwnzXCmRxU7O7u2
	 mAUTxWmYgVUqTm/evpOgc+jYveJrrxf8Q0ayx8aBGYjg6rMb+LXiWcO7t+Y2nVnyS1
	 ra2ZiC9ZGwK7w==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v5 00/11] Improve the scalability of NFSD's classic DRC
Date: Fri, 18 Sep 2026 13:21:12 -0400
Message-Id: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XPTW7DIBAF4KtErEsLmB87q96jygLGg01rYQscK
 1Hku9cki6aKvHyjmU9vbiRjCpjJ8XAjCZeQwxi3oN4OBHobO6Sh3TIRTGhWCUXb8zQEsDPShNN
 wpWChR+qZRwPGGcmAbLdTQh8ud/fr9Mj57L4R5oKVDWczUpdshL6MAIeP6HNLZ8xziF1Z6UOex
 3S9d1t4oR41aqF3aiycMup4qzhy6xWYzx9MEYf3MXWk9FjEM1PvMWJjhGK6Qa2ZNe6Fqf6YhrM
 9ptqYiqtKWAlGyuaFkc+M3GNkeQp80wotatvIf8y6rr+KA7bDxQEAAA==
X-Change-ID: 20260325-duplicate-reply-cache-f0fe7c7b740c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6027; i=cel@kernel.org;
 h=from:subject:message-id; bh=tZCtXnvOdKnY2wkzjY8wQjxZ+M72kaA/dhOCiEsm1lE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMNaD7k1bdfCGh8bTeF8TeUbRuX/dF7MjYPI
 ORlIySqkl2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zDQAKCRAzarMzb2Z/
 l9W6EACh6O8PgGsUvtYqRdMbfoINsT3x2tDR1QMkFfBH1QhqUSmYehjCvz2AGKddqFALuZVt9tM
 aF9Rvuqtgn9IDev1232WIqp4gSulVh6PdM3ZJrq7Bux0iZ4HcQW0RHB1F3H7ARmZPptQTuJIW8+
 4FEwLLCygcgz3xU/ZaoUTmAthTTaovALoA99R3qTOpgftt2Z1Yr1XwXz7pJ3Np6FouC9JN67MR7
 W/ZXyP4KVHr7z668rDJv+sfC1PaArwZoJcnIZauBu4GDnRyrtpsVOoZ8/GB1YyKutEMopACs9Ng
 bh7KYzZ6CwHunqei+QtgeUEqOKtA0LM10WEajml/FJwx2SsX/xLAtSNOvAw+9/HuY7mkjeY5QBE
 5Xo8xwtYCfZa7/A7TZo8mheP8BXAK6Os6Q9ariTXjR7+bMo7wPpmwUPDxsfNwLi419zXc2yZLdy
 05zoZxZNroleEiV/TyZ5vfMMIVBAC+A4Wgv6i6zj62z2m+NhvTiL1bbwmmZTTwLoTaTed9U+WQs
 Kh60F63Y865aBo6DXe7VpO06Cnxvxn6CDQ/SmNcjBlXlz9daEQwpFr5Oc04n3/H2hB0Hyv6z3fM
 AUL8FNmTQKaIevkhUoASUo0Pk/roUQFWZ5GEUjdOjOtQUaR5rbucosGugHNqOZmqDzI2Juk774+
 cKEOJ4XqxxJJ5yQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A completed DRC entry currently stays in its bucket for at most 120
seconds, whether or not the client already holds the reply. On a
busy server those entries lengthen every bucket walk, and under
pressure they crowd out entries a retransmit could still hit.

On a host with more than 64 GB of low memory the cap, not RC_EXPIRE,
governs retention, so entries are evicted before a retransmit can
hit them. Since 120 seconds is shorter than the default retransmit
timeout for connected transport, entries are frequently dropped from
the DRC before a client might retransmit.

After this series, the DRC retires an entry once the server transport
has seen the client peer acknowledge its reply. Each transport
publishes two positions, the reply it has just sent and the point up
to which the peer has acknowledged, and the DRC compares only the
two. Nothing else about transport state is exposed to fs/nfsd.

UDP entries and replies sent over a TLS session keep the current
time-based eviction. RC_EXPIRE itself is unchanged for every
transport. A longer lifetime for connected transports is follow-on
work. The bucket walk still stops at the first entry that has
neither expired nor been acknowledged, so an acknowledged entry
behind one from another transport stays until it expires. A later
series moves the cache to the connection and removes that limit.

Retention now ends at delivery rather than at consumption. A client
whose RPC timer fires after the reply was acknowledged but before
its RPC layer read it retransmits, and NFSD executes the call again.
The client completes with the first reply and discards the second.
Patch 10 works through the cases.

The XID checksum was sized for a cache full of stale replies. With
acknowledged entries retired, it guards only entries that wait out
RC_EXPIRE (patch 11).

---
Changes in v5:
- Actually make xpt_id 64 bits wide (per Neil's review).
- Move the DRC cap removal first (per Neil's review).
- Rewrite the cap removal's description to stand on its own.
- Drop the 4x visit bound from the prune walk (per Neil's review).
- Evict acknowledged entries only where the prune walk reaches them.
- Restore the shrinker's unlimited per-bucket scan.
- Link to v4: https://patch.msgid.link/20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org

Changes in v4:
- Track reply positions instead of ack cookies (per Neil's review).
- Make xpt_id a 64-bit counter and drop the xarray (per Neil's review).
- Drop implied ACK and the last-request timestamp (per Neil's review).
- Keep an unsent reply until RC_EXPIRE (per Neil's review).
- Pin a DRC entry against eviction until its reply has been sent.
- svcrdma: Serialize Send posting so positions match completion order.
- Drop the nfsd_drc_reply_acked tracepoint.
- Link to v3: https://patch.msgid.link/20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org

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
Chuck Lever (11):
      NFSD: Remove hard cap on duplicate reply cache size
      SUNRPC: Assign a unique identifier to each svc_xprt
      NFSD: Track transport in DRC entries
      NFSD: Prepare bucket pruning for additional eviction reasons
      NFSD: Add tracepoints for DRC entry eviction
      NFSD: Record DRC population in lookup tracepoints
      SUNRPC: Publish reply positions for upper-layer consumers
      SUNRPC: Publish TCP reply positions
      svcrdma: Publish RDMA reply positions
      NFSD: Evict acknowledged DRC entries
      NFSD: Remove DRC checksum and payload_misses stat

 .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +-
 fs/nfsd/cache.h                                    |  16 +-
 fs/nfsd/netns.h                                    |   2 -
 fs/nfsd/nfscache.c                                 | 222 +++++++++++----------
 fs/nfsd/nfsd.h                                     |   3 +
 fs/nfsd/nfssvc.c                                   |  11 +-
 fs/nfsd/stats.h                                    |   5 -
 fs/nfsd/trace.h                                    |  47 +++--
 include/linux/sunrpc/svc.h                         |  16 ++
 include/linux/sunrpc/svc_rdma.h                    |   5 +-
 include/linux/sunrpc/svc_xprt.h                    |   3 +
 include/linux/sunrpc/svcsock.h                     |   3 +
 include/trace/events/sunrpc.h                      |   8 +-
 net/sunrpc/svc.c                                   |   3 +
 net/sunrpc/svc_xprt.c                              |  19 +-
 net/sunrpc/svcsock.c                               |  29 +++
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c         |   2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  27 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |   1 +
 19 files changed, 273 insertions(+), 160 deletions(-)
---
base-commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9
change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c

Best regards,
--  
Chuck Lever <cel@kernel.org>


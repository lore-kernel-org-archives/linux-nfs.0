Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B719449DBA3
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996961; cv=none; b=Iqel+cwllqmKmpPaCa8O22J9qVdDr/tcvwTzDKTn/ePv2oda2lwLNlJsbBxYBAkT1KNuwZ7KH5ih8evKF7CKuQT10tu7I9Mqcz7Ntb0RnOs/tK6o1O7d9GmTHunG5JbxGWp7iXMaFfA3U/183n4q/0JbNBqQebNOQqmtTtVOc80=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996961; c=relaxed/simple;
	bh=tBOYyDRh08bLln9rT9quzCNsR9cAqYJFbBrtunn3fWk=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=s8WJ1QRXmMXj+/ymU9nNntGukXPuvXjn6FAXMgetUHwXVSEkGRay/U9is0i1swpvhGdeKX0oI+gRw0CRHPdv+CoBNTCcHKJXdaT31g6DOpF3DqbAQTXDnHDqwpctV7kHBO0IcCPweCiPFEnU2Pdn59pDWmvyMWpwaTQIzRnfmkU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VM9EkO2m; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VM9EkO2m"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 94A2F1F000FF;
	Mon, 21 Sep 2026 13:22:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996959;
	bh=sAkJFYjvzzI4GxDIvOmGEAgd5r2A48uvGB02ET1BhzA=;
	h=From:Subject:Date:To:Cc;
	b=VM9EkO2mk/sEWiJ6wZ9lVstDDk8jFa/42OiyMCWuiC7b+8x3tTv1IWIdi8QuhOWxX
	 8yJg6S9B93fCRz+tawFOY2Cw0GwONn/jzZY/2YXrZqe05aeS3qgdeodOIkXjOwMpQF
	 PoU0m7deMSSrGOjYZ85XyqNAIMXUR2R8RVxBaiSXa0fMaLi+lRcmHH7HYs+OnmpysA
	 RyImZponiYJblBbKMbj9ACenR5khaH+WsKxSbsSWY19tEbEeVTlytJ0YhbXDbJUKpy
	 9O9r/C/uCT/F9WjI/8lktPc9kvYCz5/HrxUZR4YCbpgCjX9ZogTuv0GF0FzADkyf+g
	 Ck+N/Xcr+in8Q==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v6 00/12] Improve the scalability of NFSD's classic DRC
Date: Mon, 21 Sep 2026 09:22:26 -0400
Message-Id: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XPwW6EIBAG4FfZcC4tIOCyp75H0wOMg9IaNOCab
 ja+e2X3UBvj8Z/MfPnnTjKmgJlcTneScA45DHEN+uVEoLOxRRqaNRPBhGaVULS5jn0AOyFNOPY
 3ChY6pJ55rKF2tWRA1tsxoQ8/D/fj85nz1X0hTAUrG85mpC7ZCF0ZAfZv0eeGTpinENuy0oU8D
 en26DbzQj1rnIU+qDFzyqjjjeLIrVdQv39jiti/Dqklpccstsz5iBErIxTTBrVmtnY7pvpjDGd
 HTLUyFVeVsBJqKc2OkVtGHjGyPAXeNEKLszVyx6gtc/iUKoy2zhp0Xvj/zLIsv50b0IUMAgAA
X-Change-ID: 20260325-duplicate-reply-cache-f0fe7c7b740c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=5556; i=cel@kernel.org;
 h=from:subject:message-id; bh=tBOYyDRh08bLln9rT9quzCNsR9cAqYJFbBrtunn3fWk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+VP3m/ChF00YSberJHPQiz86GP25WkbMxdR
 dRjKIjYQKqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvlQAKCRAzarMzb2Z/
 l5kxD/oDpGt9tc9bW58A9cGcBGF6tHjvdfcjtwqZO3+cS2PrApfVIPt6yev7oCj8jA2HEpSoyED
 4qTvD54SEXr/L1LU0tABu5v97jHq78IHCSi4hX9xinMlN0JIU8F6okbON72hTB3a3lUzMiqKAJe
 YiXGhWlH1exsL9TwwWCEOQOK1mYfYkWcecoo1z+0H3oZOrOmhEo2vaiiv8MYOeW/X/xBMAiRSGe
 CZVS5CH8V33ISKu3UgIeQnelBUZJ2nBXyHu8sYUYc647+sp6ae+yRHcG8ki/Z/Lkr0/WaX59VgK
 KJaOWNA5ohVohvCeZjgOTeQIs6YuhzoqFHv6NmH9FYSjo1djNSbalATlLCJ4Ug3alfzpsv3pIvn
 lDqrIgNMtpk61WP6MFKkXjkF762tOqWw+YXDHx9RONqDOqivgvEMFNpseMVb3/Tlw1JuOQDMjoM
 +26VhQZ+4Ww5iLywWdblne+Ouc1Z2MCQ6x4hCwuF/kxqParjuBZ7ciYJENRf/kUsfzQNfQr9Rg0
 v3Uc9INCxFBY59YBAkSfyzqig5/Ynu0xDzEUUQc8rI0tB+b8dWLjLqZyEcD9D+LrzIiup6qtVii
 vfSaF94f9p3CY7HN0OFuOOHt6+8eyusFWw290UUSTZTkiWbw9illZOQwwEEWHZnJrOsB3gKNYJD
 wCTCMGzvAAqsotQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

On a server with more than 64 GB of low memory, the cap, and not
RC_EXPIRE, governs retention of DRC entries, so entries are evicted
before a retransmit can hit them. RC_EXPIRE is 120 seconds, shorter
than the default retransmit timeout for connected transport. This
means entries are frequently dropped from the DRC before a client
might retransmit.

After this series, the DRC retires an entry once the server transport
has seen the client peer acknowledge its reply.

Each network connection publishes two positions: the reply it has
just sent and the point up to which the peer has acknowledged, and
the DRC compares only the two. Nothing else about transport state is
exposed to fs/nfsd. UDP entries and replies sent over a TLS session
keep the current time-based eviction.

RC_EXPIRE itself is unchanged for every transport. A longer lifetime
for connected transports is follow-on work.

The hash bucket walk still stops at the first entry that has neither
expired nor been acknowledged, so an acknowledged entry behind one
from another transport stays until it expires.

---
Changes in v6:
- Make the DRC size limit independent of page size (Neil)
- Drop same-connection retransmits (Neil)
- Link to v5: https://patch.msgid.link/20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org

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
Chuck Lever (12):
      NFSD: Make the DRC size limit independent of page size
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
 fs/nfsd/nfscache.c                                 | 206 +++++++++++----------
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
 19 files changed, 263 insertions(+), 154 deletions(-)
---
base-commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9
change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c

Best regards,
--  
Chuck Lever <cel@kernel.org>


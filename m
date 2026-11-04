Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801475;
	b=gwDaGshFoylPyI5dmOKo6a2aI5NFcBEqijb1SjozOOIyrSKI1LgjZ2JcIVXaNBaWC4Fb
	 /yMtYLzl/ueVMJzUrhdsDTrH2oq7hbkR4V4ut+RYlPUDNnLUQ4VCLyg5nC1drePO8ZKUL
	 q4wRka1J+lN4LpprMQDboxGtFcSeJFZ1/Af/A/5it+w9r1HudQ+znZ3DVzeTF8Zy7LrR8
	 nOjqfzv6tjqNpZ+RDZRqMjqui3Ea6ZiQik0Fro+IEmG4xXC44pjQ83BFGv4AGzsxtGe94
	 BfHPYhl2SRZ0LgSMf3a8niTCvmof/4rchs2933DPbxZKmtUTLngWkWM9LCVLUr793Dw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801475;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=7yPliVTlL9I117Syk/sHIJ4deRyfsE7CLJT2w2bbfyE=;
	b=CCg91s1oCHAC7D6UcVMa2fuPfNkkOBFmAFL3hd+LMq663Y8C1kiJm6ICnekFC2jDSI3E
	 3UFGAVdyxFT5oRgWDlUUl+cgq0aNTxf+TiYb9BDf/nY47TWNQkkmjp7Tkxk81hVb82bUj
	 QT/UlqxS7IuYkRei4z4tdkreBb2e4H/ojRIsrWoZ7g5qoj0aeWMOH/JsdMRBePWoPFV8D
	 QQvN0jaoY//IdsV6IwXmjv7I3pFMkAgj3kygtpS8B2sPeAmgWaWDcFg+WAXBhdEBBxmEX
	 /WuJds59yzFRhk7ebDluxDBVGbx9CaE0QsXLHxb+nrf8SV8u2D6sRIYcrjDzt5U1UlQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OJNUMeai;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 636DF606A32F;
	Wed,  4 Nov 2026 14:11:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OJNUMeai
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 489BF1F00A16;
	Wed,  4 Nov 2026 14:11:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801475;
	bh=7yPliVTlL9I117Syk/sHIJ4deRyfsE7CLJT2w2bbfyE=;
	h=From:Subject:Date:To:Cc;
	b=OJNUMeai5z4F+tz9xI2sK/giaLlFfen8cuid2IuhF85aWz6OZ0gNnic1D7QaaUpzy
	 zLS+NhVz7fyEUfseCwiAOr/S4zO/O0UY0jsvKXghptVQOAa86twI1pX7G7EiBYXIAb
	 J37h0obs1ScI7k3WsTeV1Zcgg5TzPWYI+kfSy+JY9iqOhyQ0UbdhmS7SPt/656pkOR
	 SsV2tGz2e00xIZZDn2bSWKZQ8Carxxa/yhHUEKYLGZDg0n2mbkBthFAE7C/a2K2ObC
	 QgcLzj0vwL1dunxbKH5ge3pAxMxR/fkoozGb4hTsTkvd88Nk/ARMOm6oOePAh2qfHN
	 mLIVKnzmwyDvA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v8 00/14] Improve the scalability of NFSD's classic DRC
Date: Wed, 04 Nov 2026 09:11:00 -0500
Message-Id: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XRy2rDMBAF0F8JWlet3rK66n+ULvQYxWqNHSTHN
 IT8e6UEWlPj5RWjwx3migrkBAW9Hq4ow5JKmsYauqcD8r0dj4BTqBkxwhThTOJwPg3J2xlwhtN
 wwd76HnAkEbTXTgviUf17yhDT9919/3jkcnaf4OeGtQlnC2CX7ej79uRheBljCXiGMqfx2Eb6V
 OYpX+7dFtqoR42OqZ0aC8UEOxokBWqj9PrtC/IIw/OUj6j1WNia6fYYVhkmiTKgFLHabRj+xxh
 K9hheGU4lZ1Z4LYTZMGLNiD1GtKV8NIEp1lkjNoxcM7tLycYo66wBF1ncMmrFMLrHqMoEJ4HyG
 IwRW0b/MpQws8foykTuSOQ+SvfvUrfb7QfBNdQdmgIAAA==
X-Change-ID: 20260325-duplicate-reply-cache-f0fe7c7b740c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=7538; i=cel@kernel.org;
 h=from:subject:message-id; bh=PQW/loGHulbDVpTg8OJ6IqzmoyJ2x2WEJoBYP/YZbjY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6zz4URC3kwsjnzgy5qrfjhm3fAqXYBtNcfWN1
 6TaWntJ5DyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus8+AAKCRAzarMzb2Z/
 l+ekD/4/4+LXyvycTW4ZAjoOzDBAUuY8gqUWiMm110uAKveE7jJe8xzWgIadRAJhHsO85VDEcbq
 og6f3bqRJov9Cqqo4WQqe0AqU8WJBmiSQAKI+kihYqiMrXJ2adnDPWUIHJCb91TP0i1qzw5rUa4
 0IspyJIZHNXVzRw3bvwrD/Y9i8QJPQD7328hNQPWf9u1vIHA9xuSjCcMsGzIjKBXQwA8/NTm/QB
 nkOcW3uiAVi5v3nKNOixeJk4C8nHoXE2TcJpuY2JkDvlrch+Jw+daMxJ/N944CYD9Son/pc1s7F
 sFbL2ztLNx2j7G0A+607zGqG+cFgKxqKWQZWyHju45QP3D/Donk5wipzg1wgXEOBNqpGlg6Ab2P
 nlMZaDd2UnYxwLn76Cfte4Nv/rKHY8u/zTUj4igbcT1L2eevf5+zgJB7hGl21RKOgzKXrUlvCVl
 O638/Jt7SJsWRGBPL3X++KWtR3MwXWS5d9DCTs2sdVn3/Z/WcJPpJ+7mFu0ViyKNafoB3kCyLb4
 SBuQVXUNFT3QD2P/Eb62IqviYgwmitQa4x8lg198WWLsUkyeJ/jIFOTQzXJfFSlsvGDUePA4pPP
 PbM4FuR4UuANn8AmJD9Biuk5Q026gR/EmllMhIjxmVneFfsLimZcdngAbFrON/l4rQ+FZ8llZm8
 xeH61nVg4IBUBSA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The NFSD Duplicate Reply Cache evicts cache entries older than 120
seconds (RC_EXPIRE). On an NFS server with more than 64 GB of
physical memory, during a steady-state workload the 256k-entry limit
on DRC size, and not RC_EXPIRE, governs retention of DRC entries.
Cache entries are thus evicted before a retransmit on a connected
transport can hit them, since the the default retransmit timeout for
such transports is 3 x 60 seconds.

To remedy this situation, this series modifies the DRC eviction
algorithm to make an entry eligible for eviction once the RPC
transport has seen the client peer acknowledge that entry's reply.
This approach is used in several other common NFS server
implementations today.

Each network connection publishes two positions: the reply it has
just sent and the point up to which the peer has acknowledged. The
DRC then compares only those two values to decide on eviction. UDP
entries keep the current time-based eviction.

TCP and RDMA transports provide acknowledgement semantics that are
precise to the byte. On a TCP-with-TLS connection, byte-level
acknowledgement is not available to consumers. Therefore the ACK
position advances only while no TLS record is open or parked on a
short send, and is withheld while decrypted data waits in the
receive path.

---
Changes in v8:
- Reject an AUTH_TLS probe sent inside a TLS session. (sashiko)
- Count a request again when a procedure defers it after its lookup. (sashiko)
- TLS: withhold the position while the strparser copies a record in. (sashiko)
- TCP: take the mark from the out-of-order queue when it is not empty.
- TCP: raise the mark to snd_wl1 to cover a wholly lost retransmit.
- TCP: move svc_tcp_acked_pos()'s kernel-doc block onto that function.
- svcrdma: correct the comment on why the position is not gated.
- TCP: test the request count before taking the socket lock.
- TCP: skip the position refresh for a service with no reply hook.
- Scan the whole bucket for acknowledged entries, not just the oldest.
- Link to v7: https://patch.msgid.link/20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org

Changes in v7:
- Count requests in flight per transport, from first read to lookup.
- Withhold the acked position while another request is in flight.
- TCP: hold the position until copied_seq passes the rcv_nxt mark.
- TCP: read snd_una and rcv_nxt under the socket lock.
- Add the svcsock_tcp_acked tracepoint.
- Drop a call whose transport closed before its DRC lookup.
- Explain why svcrdma publishes its position without a receive gate.
- Narrow the reclaimability claim in the cap removal.
- Correct the collision-window claim in the checksum removal.
- New patch: advance the acked position on TLS connections.
- Link to v6: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org

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
Chuck Lever (14):
      SUNRPC: Reject an AUTH_TLS probe inside a TLS session
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
      SUNRPC: Advance the acked position on TLS connections

 .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +-
 fs/nfsd/cache.h                                    |  16 +-
 fs/nfsd/netns.h                                    |   2 -
 fs/nfsd/nfscache.c                                 | 238 ++++++++++++---------
 fs/nfsd/nfsd.h                                     |   3 +
 fs/nfsd/nfssvc.c                                   |  11 +-
 fs/nfsd/stats.h                                    |   5 -
 fs/nfsd/trace.h                                    |  47 ++--
 include/linux/sunrpc/svc.h                         |  18 ++
 include/linux/sunrpc/svc_rdma.h                    |   5 +-
 include/linux/sunrpc/svc_xprt.h                    |  26 +++
 include/linux/sunrpc/svcsock.h                     |  16 ++
 include/trace/events/sunrpc.h                      |  62 +++++-
 net/sunrpc/svc.c                                   |   3 +
 net/sunrpc/svc_xprt.c                              |  73 ++++++-
 net/sunrpc/svcauth_unix.c                          |   6 +
 net/sunrpc/svcsock.c                               | 209 +++++++++++++++++-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c         |   2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  26 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |  15 ++
 20 files changed, 639 insertions(+), 155 deletions(-)
---
base-commit: 7931bbfa2e56dc27ddd7f1ef46f90fa0194a2868
change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c

Best regards,
--  
Chuck Lever <cel@kernel.org>


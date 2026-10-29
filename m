Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297182;
	b=3s/BPk+JHfaPnVIxGR2zUYXRKeOdF1rPj9X190UMVdaVeBVxVxOPZ4NXGTxbaNbAAlUG
	 VD6VMqhs4Iaod3tsCtLk754S/ACKoBhzKWyWEE9pe940k0/OPx/tEk78F+G0kjST5F1Ww
	 sD4csvLDjMtseald14D5o9l6Uyr+xjAP+b5gcsciyzxKmEK5S+iUbDUI3n7WCmO4IxOd5
	 prNPTTLzEKIFVA36+cAaibuYTfAPNo/1FNrorw+etFbuakdBSAr8DQR4xzX6Hzrtvgc28
	 hLbr8kG4Rf1tbwxXpmaNukrBZrmn+nksFGPQc4/KUdmoHqN7vDykRUzwKNeKckeBadg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297182;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=sprV3KYnQU8/Jg3mJ/T8yb8bOB2WYzF1czqgpM2TrfY=;
	b=2u0GdfzaT/JjwCL45nRyO+fDW6HY2PVmr+ag1hc2v5lPI0s4faNUfveMYOeYmpVjKbwA
	 2/zRD6+HF1vAtUWiU5MJxopNrPlKFsYmr91Ewl1vOOkGSWV24JZN2vAQNeBDOkx2tFVwL
	 2GO7UjivNmk/87qcaRQbrSwTM5bcgrjBDj0uP5w3b9IawWF2kZdcO2yK3Khx9HnwClNRw
	 scdGu8U59p4vizD9iS/G/yF5ljMJz5Obp0lxJAHKfIqQ5dg0YGbVsM6WoDbgQw+stCBnq
	 UGv6UkamvumfdZVqsraTjfadqVNB0CyrSHv2Nf8+Jtiuw/xSpT2+a3hdk+tJS1/npYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LFZujVOx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9882F606A31C
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LFZujVOx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 914C31F01816;
	Thu, 29 Oct 2026 18:06:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297182;
	bh=sprV3KYnQU8/Jg3mJ/T8yb8bOB2WYzF1czqgpM2TrfY=;
	h=From:Subject:Date:To:Cc;
	b=LFZujVOxbp0f7+jnhGSSShzOl/0fT8Hgxfk12j1+LQaE6vGtea20ZzI/61+g+GB6R
	 jpyj5K0hwI2O0YRinWSKv91xSMU6FLYuJ2dwouY7vWFgEk/bAi9mH0DJr7ShTHv9vz
	 L6LvfCN10YaqUh8UW1kKUR+u+ACEuGfeaTzsiEF4Kxyy2htfZmk2Qruzf3+PcrD/2T
	 l/ggsJrQL35cz7LqUF8OE3t5e5rL89Rviqvp3Z0XUGeX6KdRcdBpUDJNQ0TS9Xgngh
	 BN5hnCBl8WRSlxXewo9BJsoolcK+KWqfilwG437l6kNIr6Uy6YrfL18Dn7JYTzteil
	 MDhzteRdPUnsw==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v7 00/13] Improve the scalability of NFSD's classic DRC
Date: Thu, 29 Oct 2026 14:06:06 -0400
Message-Id: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XPy27DIBAF0F+JWJcWMI+QVf+j6oLHYNNa2ALHa
 hT532uSRV1ZXt7RzNGdOyqQIxR0Od1RhjmWOKQ1qJcTcp1JLeDo14wYYZI0TGB/HfvozAQ4w9j
 fsDOuAxxIAOWUVZw4tN6OGUL8ebgfn89crvYL3FSxumFNAWyzSa6rIwf9WwrF4wnKFFNbV7pYp
 iHfHt1mWqlnjTOTBzVmigm21AsK1ATh1Ps35AT965BbVHvMbMucjxi2MkwQqUFKYpTdMc0foyk
 5YpqVaahomOFOca53DN8y/Ijh9SkXtGeSnY3mO0ZsmcOnRGWksUaDDSzsGblhGD1i5Mp4K4A2w
 WvN/zPLsvwCtCt6+FMCAAA=
X-Change-ID: 20260325-duplicate-reply-cache-f0fe7c7b740c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=6589; i=cel@kernel.org;
 h=from:subject:message-id; bh=J9mr5NyOQxKllT9Bu8MQ70JbtDY/F4vQ5e4tmqAyelE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44sUsNrh5kVxo+wUfCW1SN+C3F5gh/nbaWPWk
 sMPfexpgY2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLFAAKCRAzarMzb2Z/
 lwDgD/9oVdg9FvkcqvFxcxrCDtdg/KTTGdUKAqeJg+zME0uXi8LWOkwqrV4jI/xgB9Vh7e74GJ+
 HhNn8zjUD91glN0k8XN4w3y5hwAACHn2Gmdn63WNweGxgBP4t55Kd9HEKXBoYv9+U2zKbZxyJWR
 6E1mpM5l8UVhhsGtkr29XiQRdjbH2chuYVV9C/lLlakv8fwPkTqysPjjcOKS/OVAsw2GcilNBNH
 EjtZDO77GqXSiSJnALARzwO1Tz0rEY8i1hv7X0Bcfbd1N3NU7G86tMCsQUvX7jw6cNS8zhRaTaZ
 slgRY03DZeD9u1Y1aPBKS+VLXcs19Zz+4pFHFV/TbGS2eivDGxkbWW/AqZ+ITd0QSuKXZWc1AP7
 vrkZ6nApQoDiiwy1YVyI/2j+Ounxoagl+3J3uNZgnQZQd2sMgR5+E2NsIUWkHEw+5zqg3Mp07p5
 n7x1AogNtTE+iueJnOQ0HK7lz9gRm8bljBStPPttbPkQz2ouZi/TVlNeMULW5eLpSiZv7szWaIR
 EoBNsXuKz8eof/A2aRbbTwcgxo5J5KPEDvk2iyJd/l2ZZoE5BVuZwVh7V8Ij+MEVVTgiDyxoz8D
 Kp2rQefBnrKZpONbvmBPKr6De//oqgdEXO8TZxl3wB4IcQodW6Ncu+Gf6c8FMU0h9TZamI+dag4
 ACZVk6yoLl+2pVQ==
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
Chuck Lever (13):
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
 fs/nfsd/nfscache.c                                 | 234 ++++++++++++---------
 fs/nfsd/nfsd.h                                     |   3 +
 fs/nfsd/nfssvc.c                                   |  11 +-
 fs/nfsd/stats.h                                    |   5 -
 fs/nfsd/trace.h                                    |  47 +++--
 include/linux/sunrpc/svc.h                         |  18 ++
 include/linux/sunrpc/svc_rdma.h                    |   5 +-
 include/linux/sunrpc/svc_xprt.h                    |  26 +++
 include/linux/sunrpc/svcsock.h                     |  16 ++
 include/trace/events/sunrpc.h                      |  62 +++++-
 net/sunrpc/svc.c                                   |   3 +
 net/sunrpc/svc_xprt.c                              |  69 +++++-
 net/sunrpc/svcsock.c                               | 175 ++++++++++++++-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c         |   2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  26 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |  12 ++
 19 files changed, 587 insertions(+), 156 deletions(-)
---
base-commit: f8e6c07aa05170165c4fefdf044310d4d48cc1bf
change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c

Best regards,
--  
Chuck Lever <cel@kernel.org>


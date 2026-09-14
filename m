Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F25547FAFF
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397146; cv=none; b=MYBvwxtBEsnyJFkyPFi0qsZKnkjRW2tSVWxLdEEWuPID8+4P9aeu1ajNToMF3t4V/2MV3HjCpHxNd0UFAZH9x6l0FiBQS58/PVpcsbH5eijoQwirtT+k+iraFceiBrM1g9eGSTtYhM4UN5lGg65Y+7Bymksp1KSUrua2ohoVqs0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397146; c=relaxed/simple;
	bh=AV9i1d3TG/Y+cQhz4rwYNpnsjiHWa52/eOaE6K4Hxwo=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=rPKnU67Xxzn5/ePrwecprSCLwXNTY9pQoPmnOKynCcpHSltwzyihoJBMWrqwfmO9L8z8ioAM8rlc2JA1df7ZCcoIdVR+HPOZCVoGlbmUUYnC4r2FhzVQb1iy1WbDAReHXRL+BkYYSdevSAu7d0H/uscFNJiiR9/5TuOKH1/1sek=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IvRNcQZ2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IvRNcQZ2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B0A71F000FF;
	Mon, 14 Sep 2026 14:45:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397144;
	bh=7EJNf+dKyJ7bIGIKWbZsH+/LbHPllgnADRccvEfOmEs=;
	h=From:Subject:Date:To:Cc;
	b=IvRNcQZ2qyOLAQScD1x9Jy1ND9ijai3kk7kmPgsvUIAMES/xJkPw0IgQZj1a1mv9J
	 EtpNsECfvCH5s9AOEaiD2698WiR3oCP6SFu8qiCOx7vww+aDZ10PwKh9/QWigeTtu2
	 5TQyEykMJ+mbjwuLxkfYAYtnSSvnT7+tvKCN/OUHb1VG6LCq95yDdccZ0EPhn/8jcb
	 9ctS9bHbNMWeH0ybpEg7PGu0b0hcojMD6LooOeLLVPCjBgVJDksR8jiFdeRxoV3fYm
	 K/yQ6yweasaYUVSFtVrVmsNlg+Voi7wURRIGF4T35AR9ETpAZUSkg9z1xy5svpM1wo
	 GSGlTruHZMijQ==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v4 00/11] Improve the scalability of NFSD's classic DRC
Date: Mon, 14 Sep 2026 10:45:30 -0400
Message-Id: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XOTU7DMBAF4KtUXmPwv5uuuAfqwp5MEkPkRLYbt
 apyd+J2AQhl+UZvPr07yZgCZnI63EnCJeQwxS2olwOBwcUeaWi3TAQThkmhaXuZxwCuIE04jzc
 KDgakHevQgvVWMSDb75ywC9eH+3F+5nzxnwilYrXhXUbqk4sw1BPg+Ba73NKCuYTY18oQcpnS7
 bFt4ZV6zjgKszNj4ZRRz1vNkbtOg33/whRxfJ1ST+qORfxmjnuM2BihmWnQGOas/8fIH6bhbI+
 RGyO5lsIpsEo1f5h1Xb8BeHQy1H4BAAA=
X-Change-ID: 20260325-duplicate-reply-cache-f0fe7c7b740c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=5007; i=cel@kernel.org;
 h=from:subject:message-id; bh=AV9i1d3TG/Y+cQhz4rwYNpnsjiHWa52/eOaE6K4Hxwo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiOx2IIcYkM2EenVUfic/R5RZXTtiijX5I7Z
 QC9G4nv+6SJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIjgAKCRAzarMzb2Z/
 lxZCEAC9aHo7yBCibPykaZU51PmoQV+oCkVR/3MXPJ08q26A0MNlcU4/c13riqUXsuckaZgTEKN
 VJYE8MCMEPDlgOCb6e/9Tp0+I60BifNTW47gVQx78dZmkna9IE0tZmDxGxdlHaVo1hFPdBeU4aU
 tUSLGXJn6EnwDDF4SQReRyDAa62G+lDOa7gv4/P84UG2WTYUmdU2/BWZ/AhgpXGXQrcMVMhJdtK
 wTOg2tEhkBdTXlPfAmyPAVcuEC9HPBweAJd9rOg6bu+9a7k5OXiQnhUcwyVo9xCfo+4iNDndZ7D
 o15PxjQlWudHQvHYIsTC49eK3VcArlDZ1psHtanV2sgXgz5KEj9vox8WEBEE1nrp/Vhce5xjomB
 w9FtTI5B45QTPsxOout1LCl9ueZkGZcgtW4XMezXwt6xpymP4SzoERQUMvjgVFsyYSZ9VwntrsM
 YCNgS8wOYbjkQ6fP/oBAGjSqYGXQjJjCXQB7lgdbOSXDGy/cVSGojcI0NFkRLm0QwsXpVTtEzxr
 gSy03a15Uz5xRh7dKiYrC3rVE3ktHRQA1W7dIokYN+BA4H/scpfavcETG60/Knuk2M63x0hWMH1
 OJbqSEIlBGGPL0oVuxMpvYHmIDoNGF+fyZoMmovRMTBhK8qj01kmy37wyby0cttBBv1Usce/k+M
 pmMsaZcXqBZPCdg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A completed DRC entry currently stays in its bucket for 120 seconds
whether or not the client already holds the reply. On a busy server
those entries lengthen every bucket walk, and under pressure they
crowd out entries a retransmit could still hit.

After this series, the DRC retires an entry once the server transport
has seen the client peer acknowledge its reply. Each transport
publishes two positions, the reply it has just sent and the point up
to which the peer has acknowledged, and the DRC compares only the
two (patch 6). Nothing else about transport state is exposed to
fs/nfsd. UDP entries and replies sent over a TLS session keep the
time-based eviction.

Retention now ends at delivery rather than at consumption. A client
whose RPC timer fires after the reply was acknowledged but before
its RPC layer read it retransmits, and NFSD executes the call again.
The client completes with the first reply and discards the second.
Patch 9 works through the cases.

The XID checksum and the 256k entry cap were both sized for a cache
full of stale replies. With acknowledged entries retired, the
checksum guards only entries that wait out RC_EXPIRE, and the cap
starves the partition case it was never meant for (patches 10-11).
The "payload misses" line disappears from reply_cache_stats.

---
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
      SUNRPC: Assign a unique identifier to each svc_xprt
      NFSD: Track transport in DRC entries
      NFSD: Prepare bucket pruning for out-of-order eviction
      NFSD: Add tracepoints for DRC entry eviction
      NFSD: Record DRC population in lookup tracepoints
      SUNRPC: Publish reply positions for upper-layer consumers
      SUNRPC: Publish TCP reply positions
      svcrdma: Publish RDMA reply positions
      NFSD: Evict acknowledged DRC entries
      NFSD: Remove DRC checksum and payload_misses stat
      NFSD: Remove hard cap on duplicate reply cache size

 .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +-
 fs/nfsd/cache.h                                    |  16 +-
 fs/nfsd/netns.h                                    |   2 -
 fs/nfsd/nfscache.c                                 | 243 +++++++++++----------
 fs/nfsd/nfsd.h                                     |   3 +
 fs/nfsd/nfssvc.c                                   |  11 +-
 fs/nfsd/stats.h                                    |   5 -
 fs/nfsd/trace.h                                    |  47 ++--
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
 19 files changed, 286 insertions(+), 168 deletions(-)
---
base-commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9
change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c

Best regards,
--  
Chuck Lever <cel@kernel.org>


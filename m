Received: from mail-yw1-f169.google.com (mail-yw1-f169.google.com [209.85.128.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C338A3BFAEB
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 21:10:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787001009; cv=none; b=JQiGy1v8ExI/5OgGS3o7pko64IObnWfqAnLy65mksnUG7gt2YUPtikCqycKrHlMpO8xReCjWFHXXNazW2lRaK7/5CY7liuaLgRDWRf1G2kL6r3y4bOkHbhuYeooolB3/Ffoas859t3NlEXffH24RVGooGcwkIFhUZRO20FxsEZc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787001009; c=relaxed/simple;
	bh=0wieJskIyM+BlIxVdb53fTjVxJUSZM5MJP5sY3w8fDs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qkJthPQA+vVRZ268Wc2xJSVhdVSmCuv9B3IZvivXvJoeAzQ0sZUVnB9WPzlQE7++N/xf0Sufrha1D7KZUZnhKmKIn5f2C42xVgflJMpOdWu8Z5yh8kkEQp194nxijN5ndPo8+PZ99Q2A2tmUOKexWVAC1peEpHkVQE22vYlv6ps=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=aJ+K6KNq; arc=none smtp.client-ip=209.85.128.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="aJ+K6KNq"
Received: by mail-yw1-f169.google.com with SMTP id 00721157ae682-836cb2fa1bcso56334857b3.1
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 14:10:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787001005; x=1787605805; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=iSHxKLLNlRXf2Is3sXlD0N0WMToVUJbjSLkiqwrplNE=;
        b=aJ+K6KNqj+ECqsbWTAlHXoLzewXf86kBj7Yb38+dClpHdJqBxvIbBzg4r76ieyDgC9
         rrpxZaf3wr8j1vwlNebg5bdzr3a1FPXE427u8eTpaqxBXXJHQXJoJp6w+EBr6g4UJ0cm
         jjFUA24todHE8LjZs6lkmdRYMusLUT4+dNIb5oMfZxWJElKAvufbUMvdJYm6qaf0Lfdq
         ETMeZD+vSfsLuwZpqaGCVKGoCGrdMFGV8e2Uc8/U/EPQ72fh4sz07fQIgeCbxaCO6kay
         9GJgGwRRtC5dPWb1dMeiBJ86dv3BwbK+SDfJypbkvNS74CIPqScKN7/RXOJy4Q0xP3Eb
         wM6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787001005; x=1787605805;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iSHxKLLNlRXf2Is3sXlD0N0WMToVUJbjSLkiqwrplNE=;
        b=mijCDa5wYIddHWQpUTqDQOJZ5JlI0UkbXvpjTD5uMsd36AUhnObkxzMUhvbCsgPdG2
         DJodpwdUqa5dPUGiEQlK8oPROBkxAlX/IuO9VkIdZkqRLRXRL6LQwNVszJtSg1rWZwh3
         Wxv6eGOXuxehwaEn7F7Qm6gO2+4Sja04RJrff5mNAh1avmoJiVKFcr4M2zf810vzjomT
         Tvg3zQbnQrxTDW496wcl6f2kiplY2Y6MDGgQfB4ienQXQNEGPLeH1+0lGELzh0/Gj28y
         JqBPTsllZ7AE79M1WZ+LNVAKamSSeSmMuN0V6cFlLxpifBWS4biiiiKyK6rlhgsWtJL6
         wLHg==
X-Forwarded-Encrypted: i=1; AHgh+Rry2NaiEafSm/IG6UHOiXYfEaSf2BXAfiXAEiqZO79cXGtT2qq0ocLOWSM3BNm+IQeQKNvh2n0ocYA=@vger.kernel.org
X-Gm-Message-State: AOJu0YxnBkKbboEBim8b6NzKDlChiwlOmwO0Kbr62SjqJqtPS5i2Jc/e
	nOuqgf/cNMPGL+h4agIgmf2gvDVNKqDiDZ1JH2dOPpuySjtadS9TM187LSKmP262ZA==
X-Gm-Gg: AR+sD11eXet7nEzdULWgogTRmD8wWOsmCudCTtghhVCB+39zc4vD1EPQYMd53QWkpDd
	B/u7Hr95I3i06brOMhiWzw0H0CEpNLT6/D6rklVYxQKAX1ehUOFVRA/FtvoDnlDmODw+FrVP839
	PF2uuOLPo4uy3boVyG5DyKfzTsJwyO5u9i7n8oneUFyRvMdWpd14nuxfUNXbquWLyqJGkASaDfX
	oStWU9q7OO7Ps3BtLeB7Uv7GPFgv2ZSsPmuS+0Vvqn5wDReLitydFST11SRsEqIggT9+OM+3dh7
	JXLRSvys7sujG0m/m5tL1TSsEsUCUxz7CgHqsiPY3lv7aYJ2QZ6iQ7NWs/feqevLsHn9FHzhYdr
	ib71UL8qHo0N+WpdUaYBs3IiwIm/1Gat9wgLUerJ0OZbkP3XrvPfLehaiwiEAHjdPz+WZ6wQ55Z
	+pLApzV/bto1eoJflBJzzI1i2D6XYePiDKO1iz5lCkPdCdWAx8JVE=
X-Received: by 2002:a05:690c:c511:b0:81e:6cdf:b2f5 with SMTP id 00721157ae682-837077121e3mr106852047b3.0.1787001005073;
        Mon, 17 Aug 2026 14:10:05 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-840f25bed4csm9533557b3.29.2026.08.17.14.10.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 Aug 2026 14:10:04 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com
Subject: [PATCH 0/2] SUNRPC: Recycle sent Reply pages instead of freeing them
Date: Tue, 18 Aug 2026 02:08:09 +0500
Message-ID: <20260817210811.3984663-1-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

An NFS READ Reply built in pages the nfsd thread allocated has
those pages freed from softirq, when the peer's ACK arrives. Since
commit 574907741599 ("mm/page_alloc: leave IRQs enabled for per-cpu
page allocations") such frees collide with alloc_pages_bulk()'s
IRQs-on pcp window and fall back to free_one_page() under
zone->lock; on a single memory node every thread contends for the
same zone->lock and the collisions compound. Replies spliced from
page-cache folios are immune, since the page cache still holds a
reference and the ACK-time put never reaches the allocator. The
rest are not. On gfs2, kernfs, cifs direct I/O and DAX files
splicing runs copy_splice_read(), which allocates a fresh page for
every page of payload, and nfsd allocates them too when it does not
splice at all: under nfsd_disable_splice_read, and for sec=krb5i
and sec=krb5p.

Patch 1 removes a redundant allocation: on those files nfsd builds
the Reply out of pages copy_splice_read() allocated for that one
Reply and discards the pages it was already holding, so it
allocates twice for every page of payload. Reading through
nfsd_iter_read() does the same single copy straight into the pages
nfsd already owns. Patch 2 removes the free: nfsd drops its own
reference as soon as the Reply is sent, leaving the network with
the last one. Keeping that reference instead and reusing the page
once folio_ref_count() reads 1 keeps it out of the allocator. A
thread holds at most 4 MiB of pages, trimmed as its own demand
falls and freed when it exits.

How much this is worth depends on contention: on the server below
the ACK-time frees reach 43% of cycles, while on an uncontended
machine the same change removes the allocations and leaves total
CPU where it was.

The measurements below use ext4 with DAX and tmpfs so they
reproduce on a stock tree with a pmem device; ZFS is affected the
same way, its ->splice_read being copy_splice_read() as well, but
nothing here depends on it. Single-node server, 64 threads, one
nfsd thread per CPU, eight clients, 1 MiB sequential cached reads
over NFSv4.0, 60s a run, clients in network namespaces on the same
box, so vmstat counts their allocations too.

                              cycles in       pages allocated
                            free_one_page    per payload page
  ext4 dax  NFSv4            43%  ->   0%        2.97 -> 0.05
  ext4 dax  NFSv4, knob      32%  ->   0%        1.99 -> 0.05
  tmpfs     NFSv4, knob      33%  ->   0%        1.98 -> 0.05

The knob rows have nfsd_disable_splice_read set, so they reach the
same path without patch 1 and measure patch 2 alone. The first
column is free_one_page()'s share of all CPU cycles on the box, the
second is vmstat page allocations divided by the READ payload
delivered, Call buffers included.

The table is from the series backported to 6.18.38, where the
release path is adapted to that tree's combined rq_pages array.
The posted code was run only in a 20-CPU VM, not on that server.
free_one_page() falls from 24628 calls per million pages served
to 5990 and softirq time per page from 0.836 to 0.528 us, while
total CPU per page does not move: svc_reuse_scan()'s 2.5% of
cycles is paid back by the allocator work it removes. The
scan's share falls to 0.7% when late ACKs leave little to
reuse, since it stops after a pass in which no page is ready.

Both read paths pass over NFSv3 and NFSv4.2 under KASAN, lockdep
and DEBUG_VM, with xfstests -g quick and pynfs 4.0/4.1 matching
the unpatched baseline, cthon04 passing, and byte-identical
checksums over NFS/RDMA and NFSv3/UDP. All of that runs on a fast
link, where a build with the folio_ref_count() gate deliberately
removed also passes the checksum runs. Under a 40 ms ACK delay
that build corrupts data and the series stays byte-identical.

Ameer Hamza (2):
  NFSD: Use nfsd_iter_read() when ->splice_read is not zero-copy
  SUNRPC: Recycle sent Reply pages instead of freeing them

 fs/nfsd/nfs4xdr.c               |   4 +-
 fs/nfsd/vfs.c                   |   5 +-
 fs/nfsd/vfs.h                   |  29 ++++
 include/linux/sunrpc/svc.h      |  14 ++
 include/linux/sunrpc/svc_xprt.h |  14 ++
 include/trace/events/sunrpc.h   |  32 ++++-
 net/sunrpc/svc.c                | 235 +++++++++++++++++++++++++++++++-
 net/sunrpc/svc_xprt.c           |   7 +
 net/sunrpc/svcsock.c            |   2 +
 9 files changed, 335 insertions(+), 7 deletions(-)


base-commit: 76427d869120552a1a82e1f1488d9f8311827d84
-- 
2.53.0


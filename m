Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923983;
	b=3S237bxCfkTZccyZ+LPH9MBhRuT8qDZ8nDevidRG1ywWu1TBCks+j97JAq9Im4fxO5cJ
	 877HAVYvIzRyIYW9heuQiq7Raw+nZ+SXxQM+IGd8UwOcvrLIFN4pxoWacBV1fQyEonqzN
	 46HtTo680UzcikZ3kfx8KDHVwGZwiYaY25Rk/ag8MYu4ekbxIKsVnEBt+gv89WefUSzdj
	 VHCafqbXDFy5nK8FJ449K7Ohl2dbIRTJ23Ftc10x0E8qiApnwb05ULO4u7G1dMFogYHx8
	 qn72WwPqyKjN8PRqT8Py9zGHSML5NsD3j0OqzrCGkG+A/4FTWTmJD3Tt6QWBGwiYIJQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923983;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=dfu/vSR8ASAnogI/MQXLw3nN3ozhcoS/89AEzqWBp40=;
	b=K/Z5EE5S+DJeENY7a07XkDlQNmycR5vjiH0OQcjkJsisCG4EYhyCawQkBMgbnuNF/4yE
	 jmmAjxcwyJDWOOxQNDobSZ4FaoerLoVj2aZDp+qST1RAzXfFbqNJwtt6ds1xVtugANJmK
	 HGjm/LrlSLOUdP+y9vZBC663n5EM2GS6q+92IU0HbXJtAr4g+XQnTN98YfXAz0QPJUVpW
	 szJnnTb3/CBG/tsI70nV8qAcw6kpT8+5tocMB43O8G9rmqjbjfv/wfZO6b38zom68TQ00
	 fdYXPekIjWlauJHj7ape8UKyhbqnykOcJ2/5M/kvSytR2qCIWdTOqp+Bcd1sGIb49ww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cEWEOdxw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D23CD606A31B
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cEWEOdxw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 375891F008A2;
	Fri,  6 Nov 2026 00:13:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923982;
	bh=dfu/vSR8ASAnogI/MQXLw3nN3ozhcoS/89AEzqWBp40=;
	h=From:To:Cc:Subject:Date;
	b=cEWEOdxw7QFziLjhnF6HOmBNgneTvySthBrqVKVM+3f0T6TDf3UO0GlBN/ZuP/2CB
	 Ob4UJiZrrtMDRsD+XFdaVgkn4ZB3HKf5mNLvcMm2UcnM80laACpKmWhncQe0p+iTxd
	 U9Wu6/G9j1Y8yfFvFvuJ1mgrr7ua3KRqMH3q1JWpPoRJ7fD9IoWvg0zYgGecmFQVYa
	 oH1AIFTS9AqZLFaFhGCpIW9AHUSIcmwg0dMmUySjuNj3+AvlQt+hS5+ziYp8h4L/7f
	 YJpBggHHVa7ZsZlZu7aGA1GweXXv7VZ6v41xOl0x1neKIycuHDGC+qdUNfxvWnZAv7
	 RBxLcUbmDqNMQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@kernel.org>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 00/12] NFSv4/flexfiles: scale layoutstats for striped layouts
Date: Thu,  5 Nov 2026 19:12:37 -0500
Message-ID: <20261106001251.73472-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

Each stripe of a flexfiles mirror has its own read_stat and write_stat,
but the lock that protects them is in the mirror.  For a RAID0-style
layout (one mirror, many stripes) that lock is per file, and every DS
RPC takes it twice.

A 64-core client reads one file from a 32-stripe layout with a 128KiB
stripe unit (~36.7 GB/s, ~275k NFSv3 READ RPCs/s).  perf puts 45% of
its CPU in native_queued_spin_lock_slowpath, and 73% of the lock
contention events in the two layoutstats paths.

This series removes that bottleneck.  It also fixes which stripes a
LAYOUTSTATS report contains for a striped mirror.

Patches 1-2 (Jonathan) move the lock into the stripe and remove the
mirror lock.

Patches 3-8 keep the per-stripe hot path in the stripe's own
cachelines.  After patch 8, an I/O dirties one cacheline, and reads and
writes to one stripe share no lock.

Patches 9-10 fix LAYOUTSTATS for striped mirrors.  A report contained
only the lowest usable stripe of each mirror.  It now contains each
stripe with new completions, and rotates through the stripes when there
are more than four.

Patch 11 moves the report decision out of the critical section.

Patch 12 (new in v2) combines the read and write start helpers.

The wire encoding does not change.

Changes since v1, from Anna's review:
- Shorter commit messages throughout.  Removed the paragraphs and the
  "what the server sees" passages that Anna named.
- Code comments: the cacheline explanations are now only in the commit
  messages.  Patch 3 keeps the original lock comment.  Patch 7 cuts the
  ops_requested comment to its locking note.  Patch 9 cuts the
  last_reported_ops comment to its first sentence.  Patch 10 removes the
  scan comment.
- Patch 10: renamed dss_report_start to dss_report_index and removed its
  comment.
- New patch 12: one start helper for reads and writes.
- American spelling throughout.
- try_cmpxchg64() stays: last_report_time and start_time are ktime_t,
  not atomic64_t.

v1: https://lore.kernel.org/linux-nfs/20261102191109.13470-1-snitzer@kernel.org/

The series is based on Anna's linux-next (nfs-for-7.4-1).

Thanks,
Mike

Jonathan Flynn (2):
  NFSv4/flexfiles: move layoutstats accounting to a per-stripe lock
  NFSv4/flexfiles: drop the now-unused per-mirror lock

Mike Snitzer (10):
  NFSv4/flexfiles: cacheline align the per-stripe layoutstats
  NFSv4/flexfiles: make dss_info->start_time write-once
  NFSv4/flexfiles: drop the redundant atomic from the busy timer
  NFSv4/flexfiles: pair the in-flight count with the layoutstats updates
  NFSv4/flexfiles: derive ffil_ops_requested rather than storing it
  NFSv4/flexfiles: give each direction its own lock and cacheline
  NFSv4/flexfiles: drop NFS4_FF_MIRROR_STAT_AVAIL
  NFSv4/flexfiles: rotate LAYOUTSTATS reporting across a mirror's stripes
  NFSv4/flexfiles: take the report decision out of the critical section
  NFSv4/flexfiles: share one helper for the start of a read and a write

 fs/nfs/flexfilelayout/flexfilelayout.c | 257 +++++++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h |  35 ++--
 2 files changed, 151 insertions(+), 141 deletions(-)


base-commit: 8cdff0c1549d3fce6bb652e6bc5dd7546e1cd1e3
-- 
2.52.0


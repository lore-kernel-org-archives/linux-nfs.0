Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989268;
	b=2UsTQW7hUKmiKbade4/qqgsnb0rlrReNRZHL2ilCZsI7MJCAz5XzkdCnXLmYPQh7S9Zh
	 6u6ECo2cg5B3ozbw0OyL+Is1QmINZv98GigiBPekxT8R+Xr6uswr6Ow75eVDj+XecMESl
	 c9+PfAcDT+loH1zO79JKjwfDWa8BayBlipP9fhpDk5dGiLEemseNY9bOE0nfvrsZgjxsJ
	 jZB4SHhw4n78JSTPQCFxja1LmlCQuuEbrg9+NoFoJj4NlI9t4HgxqCKauoBtOEFfo8Abo
	 d9WOIoluOmjKeAUWn1LifLgoXK3ZSK8I57L/eDwlTSHsuSyd0/y0buJ4VrzgZBWyLfg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989268;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=Fsz4NVXC3YJRuBsZB+eilfkhOdLTj21QbunfZaaAIBY=;
	b=ZrXhMeyQQlXMDGckKTfY+jeGvcRLJU/o3453uxApY3AqrbC+uQmqVLaQE1ZnX511K6r7
	 o+SaNB4yHLgGLoy6ZuKYx9PMB+WO3LhlTESwR6NUrFy3YKuQiOyyjf2PaWOM+nwUgPGuz
	 dnCVN795sTVzpMNMY7ysZG1ecl1KmNGlxALawnwO3Z0WNBpei5nJcC7VxkYJWHNyO/+yf
	 MRK7yb0UiExU8UkS3QcTKg8F+be2j3MxuDJFDiffsxb8Eat2D03ePcHPr2yCCWtOg2dDN
	 NS5COLPSLD2qTEhiNpCMSm6d5qQ7iE/7PmkVtpIXA43E7RS43atwdfslBCuDUef3JzQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ehCibUNA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66446606A32D
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ehCibUNA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE3AE1F008A1;
	Fri,  6 Nov 2026 18:21:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989268;
	bh=Fsz4NVXC3YJRuBsZB+eilfkhOdLTj21QbunfZaaAIBY=;
	h=From:To:Cc:Subject:Date;
	b=ehCibUNAoSqhKn3i+86l/pLtFvLBQa8/RZfNmiNEza3avcvlRHbfSePvnTGR3pjps
	 U9Cvmxos4Dor6EM59nto+y8sP5ux/3HLibgrZOKlG441y/h+kYI/MXJDuppb2kRL84
	 pkuc5rpES/Y8kLfBS50GaKrKpAUg073tw3WeaiiDKg5SS8cLjUyOFWZAXnVWXIF2yN
	 k4ONFHt4A2OROBclpU/FHLFVaMPM8nSkLZ439Qu5rUlJdMst2t7xs8mit6JJfgjl5u
	 KNLXnixui4u39PIpn04ApQ2EIvJn+6LL9D3tPiN8IIhgOoMLy7dkMo7WfxectyJSXT
	 hnV+uejxVrSAQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@kernel.org>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 00/12] NFSv4/flexfiles: scale layoutstats for striped layouts
Date: Fri,  6 Nov 2026 13:20:48 -0500
Message-ID: <20261106182105.78611-1-snitzer@kernel.org>
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

Patch 12 combines the read and write start helpers.

The wire encoding does not change.

Changes since v2:
- last_report_time (patch 1) and start_time (patch 4) are now
  atomic64_t, updated with atomic64_try_cmpxchg().  try_cmpxchg64() on a
  plain 64-bit field does not build where the CPU has no 64-bit
  cmpxchg: the kernel test robot reported it for ARMv7-M.  This is what
  Anna asked about on v1.  Checked with an ARMv7-M build of each patch.

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

v2: https://lore.kernel.org/linux-nfs/20261106001251.73472-1-snitzer@kernel.org/
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

 fs/nfs/flexfilelayout/flexfilelayout.c | 259 +++++++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h |  37 ++--
 2 files changed, 153 insertions(+), 143 deletions(-)


base-commit: 8cdff0c1549d3fce6bb652e6bc5dd7546e1cd1e3
-- 
2.52.0


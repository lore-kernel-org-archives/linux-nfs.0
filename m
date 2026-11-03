Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793740676;
	b=hyj2CGNg/EHnneBAhrwMJAx8M/1q8TriOc1CDHRDn6BrMn4bYivNiT/Cx1p7MZlPWdjQ
	 0f30qauba+QEIw8/udDF+HE3qtxCBA2zphd5sq95hSC1LT6u3CRc6I0HuhUWz4WuIpMDm
	 RC70D66E2hGIOqrlGgHBYCzr0jVh8k/Er7cHnvwvQxdrwvJpSo4bwR2F/r2OD6K2QuQKs
	 +RiD90LQ0vHOtRB+dBA5p9BqfVjPCX/8Dh9++hCd4BfAkoaKfZfZKhY6eVCFyIYOytyP1
	 d+0H432pn1dY9M0c9/hUW3VV+FgsMBfJqVbGSVW2V7BjGQFX9FrEVY2BEt0E7Y59ffA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793740676;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=XeXrDOc+70voGjQbABG90HUQoTF6Ii93pHEf5zCSnPs=;
	b=uj/7b9NOWaPUtcVKmwNrrsUw2Dl6Kv9qZxN5KGvyter0MdgUYktxlb8zd40Vo85KQzO3
	 bC/fCvbCFcUcMLUa16KnPBOq8af/9GI5Ap0wuaPNFKrUm+O6iAXWnEmm2dfnqI2ZGkxEL
	 gtcbFjX7co0dYaC+j6We/eNuyrwi55ODgtHScie5l300DEDapuyjJmpsy1WQDR9rMPD0e
	 rP1sCT8FLE9gNrrIPRPEQ9AoNUmUScjYjC+DE61v6NbS1wbcXd7YC3MrvreXShCiaw1B9
	 B2HQKkdSvNuCOCA2lEPGg1dzajB4jQvPH533uf8OWoFukQ4bach8ZZMUit7BZnj7nbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XXFrdsRK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0513E606A31B;
	Tue,  3 Nov 2026 21:17:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XXFrdsRK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 531DE1F000C1;
	Tue,  3 Nov 2026 21:17:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793740675;
	bh=XeXrDOc+70voGjQbABG90HUQoTF6Ii93pHEf5zCSnPs=;
	h=From:To:Cc:Subject:Date;
	b=XXFrdsRKSt+h1JHwiQ58mFXZpgsRd5fjML9ABRZ3ZDvlov2nYhH+d9yRcQbYq8Mh1
	 B0eXvnBz0TGAuvfmLFnB5ubvdu9sVxe0kL4KuIJwRSdC+Qg9BG4GrxqHmjbB7JJR1Z
	 6fBRlJCtkMWVBGwdomZFzqj0i05MPp2t7Ubi3tgDHtEXP7fa8CdTQIbHRLTEWyzwLH
	 iZ8iVR1XD7BkVFYgqr3boVCL6pzMKEU3PIM8UNzczi2qiJz6TdAeR3J7RPWe/jZ4DE
	 /jTxiS5uT5fHqmtSTd3JrAzIfbkqHnPvvbcICJzm/+9uD/KM755SSvo4FU/va6W3tz
	 raykJvyMoID3Q==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>
Subject: [PATCH v10 0/7] mm, iomap, NFSD: stop uncached writes reading back shared pages
Date: Tue,  3 Nov 2026 16:17:47 -0500
Message-ID: <20261103211754.35352-1-snitzer@kernel.org>
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

An uncached (RWF_DONTCACHE) buffered write drops each folio it writes
once the folio is written back.  A folio that the write covers only
partly is shared with the neighbouring write.  If it is dropped before
the neighbour writes its part, the neighbour reads it back from disk
first.  32 threads writing interleaved records to one XFS file, 4 KiB
pages, before and after 5/7:

  record  pwritev2() flags          4 KiB device       MiB/s
  bytes                             reads per write
                                    before   after     before  after
  47008   RWF_DONTCACHE             0.97     0.0005    831     2281
  47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
  6000    RWF_DONTCACHE             0.97     0.0001    121      488
  6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206

The test program and script: https://lore.kernel.org/linux-nfs/atqJBS8MlYfeUU-t@kernel.org/

- 1/7 moves code into a helper, with no functional change.
- 2/7 fixes 88d6f128d06d ("mm: track DONTCACHE dirty pages per
  bdi_writeback"), in v7.3: WB_DONTCACHE_DIRTY could drift.
- 3/7 reports WB_DONTCACHE_DIRTY in the bdi debugfs stats.
- 4/7 adds folio_mark_dropbehind() for a folio that is already dirty.
- 5/7 keeps a partly covered folio until the write that completes it.
- 6/7 lets a writer that syncs its own write complete those folios
  itself, after the sync.
- 7/7 makes NFSD do that for the misaligned ends of a direct-mode WRITE.

Merging: Chuck suggested taking the series through the mm tree.  1/7 to
6/7 apply cleanly to each of these mm branches:

  mm-unstable  0ea6dc8c4a21 ("fs/proc/task_mmu: fix lost maps entries above 2^63")
  mm-new       74d73ffcffe0 ("riscv: mm: fix concurrency in mark_new_valid_map()")
  mm-stable    6628e7d4c6b2 ("Linux 7.4-rc1")

7/7 needs the NFSD direct-mode changes that are in cel/nfsd-testing.
The whole series applies to cel/nfsd-testing at 693afd3ce9ae ("NFSD:
Defer the PUTFH export security flavor check"), where each patch builds
with W=1 with no warnings.  So 7/7 could follow in the nfsd tree once
the mm part is merged.

Changes since v9, from Christoph's review:
- v9 1/6 is now two patches: 1/7 only moves the code, and 2/7 changes
  it.
- Every commit message is rewritten to state the problem, the fix and
  the result, without the earlier detail.
- The long code comments are shorter.
- Rebased on the current cel/nfsd-testing, which now has b16607436d31
  ("NFSD: cut a misaligned direct-mode WRITE at folio boundaries").
- Jeff's Reviewed-by of v9 is carried on every patch but 1/7, which is
  new, because the code changed only in comments and in the split of v9
  1/6.

The code is the same as in v9 apart from the comments, so the v9
results hold.  Patches 2, 4, 5, 6 and 7 carry notes below the ---
line: questions from earlier reviews, and the code that answers each.

v9: https://lore.kernel.org/linux-nfs/20261024221152.6965-1-snitzer@kernel.org/
v8: https://lore.kernel.org/linux-nfs/20261023024548.71123-1-snitzer@kernel.org/
v7: https://lore.kernel.org/linux-nfs/20261020220346.28020-1-snitzer@kernel.org/
v6: https://lore.kernel.org/linux-nfs/atbfEbgMU6UGkn2X@kernel.org/
v5: https://lore.kernel.org/linux-nfs/20261019150725.1507-1-snitzer@kernel.org/
v4: https://lore.kernel.org/linux-nfs/20261015233309.42999-1-snitzer@kernel.org/
v3: https://lore.kernel.org/linux-nfs/20261001045502.48381-1-snitzer@kernel.org/
v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kernel.org/
v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kernel.org/

Thanks,
Mike

Mike Snitzer (7):
  mm: move clearing the uncached flag of a found folio into a helper
  mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
  mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
  mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
  mm, iomap: keep a partly covered page until an uncached write completes it
  mm, iomap: let an uncached writer complete its shared pages itself
  NFSD: drop a shared boundary page only once both WRITEs have written it

 .../filesystems/nfs/nfsd-io-modes.rst         |  17 ++
 fs/iomap/buffered-io.c                        |  30 ++-
 fs/iomap/trace.h                              |   3 +-
 fs/nfsd/vfs.c                                 | 106 ++++++++-
 include/linux/fs.h                            |   5 +-
 include/linux/iomap.h                         |   1 +
 include/linux/pagemap.h                       |  11 +
 mm/backing-dev.c                              |   6 +
 mm/filemap.c                                  | 208 ++++++++++++++++--
 9 files changed, 356 insertions(+), 31 deletions(-)


base-commit: 693afd3ce9ae5cddb7225ec87975e6ef1443e502
-- 
2.52.0


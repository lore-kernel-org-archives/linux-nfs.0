Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794510556;
	b=rpfs/62xevVg2AJZnLooeskOyTeNWnve4LDPH4ZUB8WggGQTQxJ79F3jHiHuPyLrMaAh
	 GS1/IU4tWVC4FM4YRZbsxXmbo+bN6Z30wrqjMyDWI7fQ6fT0ykd0RIvqytMZfV5YV1HDt
	 cwz78CnpFRLZVfhd7WegLwFhIeSOtNBvSmlQxTkXXFCoK98SA1DEfUCj69WaVoySj0HB6
	 CN2cjKjRbkPyaUCmmC/4S3JZBrnr62lVGZPRL1pEfx+l0A7F6eyt1e/xkg7KEeXy+E7zO
	 L1d52gtpNmIBstCf9XDur1nE74427zJQsgDgXHdlxJ0pXzG2Sq/m/AAcy+JsZ8ZjhXg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794510556;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=TKTNybLPBpEKnh04NOPCEWrNKO9zmS2QEgLPE1Lm2uY=;
	b=cwivzqp1EEgjCRtkMHt3zfCzuO4xnfBaouwE+9FgutHbIZgqBNt7pt9dBG16zeeTox9w
	 Wci8AaLMA+gHBD5nujHo7XVgKqa0vgq5WJxQcyANEByk3iMCvPBJ/rH9At2vJJPlG/iob
	 SiWt9l/Cbt7WbHER9zGm4uv6Mw3mFFkc4ooxRSxBDZ7oBO3OzmK08/rmS2XWRciqDq+lv
	 Ajdv1Vcr0hrUT5Ikt4bXlYNDnr+QPy+PFSnjIm0Y3coVvOjASsGuX93KCpOjd6hiJz6O+
	 Jb6g3VIOl7iYwnrOkxR0CboLcbr4dimjjaOrfYv6yl9rFz0GQd1G6X5vAar/3+fADOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fcwaHLt9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52116606A321;
	Thu, 12 Nov 2026 19:09:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fcwaHLt9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D8B141F000C4;
	Thu, 12 Nov 2026 19:09:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794510556;
	bh=TKTNybLPBpEKnh04NOPCEWrNKO9zmS2QEgLPE1Lm2uY=;
	h=From:To:Cc:Subject:Date;
	b=fcwaHLt9OLtAIv0M4S2AUBsOQIcbp9263PKjlr224XFzng76KDKM3LigOhaPzGO0p
	 fUIrqF/myv9wkGoKF0KhVsF4dsg5ZxCXXEYPUKomb8iqWY/G8DBr8MQc3GZwuZ/IYI
	 dRwPIIC9cn0tpk8OIBNeI80ps8Edp+i/K0UvW+SzjhKGUiXgJ9uRY7adChF912Q+gA
	 mpZkb3KYONh3HzaTdgZVW/8cc7Yl75350p8fKz8NSyH4ZytbvC+DXM54ODpM1uWvmA
	 mysYSu1xEbNwZncea8iACe//OPE+LBnvJjkfwiitt7lW0xVIuUzcScz0+G3wpI2ZbU
	 lqTm2SB6e3r0g==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Mike Snitzer <snitzer@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v12 0/7] mm, iomap, NFSD: stop DONTCACHE writes reading back shared pages
Date: Thu, 12 Nov 2026 14:09:03 -0500
Message-ID: <20261112190911.84702-1-snitzer@kernel.org>
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

An RWF_DONTCACHE write is buffered IO: its data goes through the page
cache, and writeback drops each folio once the folio is written back.
A write that starts or ends inside a folio covers that folio only
partially.  Usually another write covers the rest of the folio.  If
writeback drops the folio before the other write writes its part, the
other write must first read the folio back from disk.  32 threads
writing interleaved records to one XFS file, 4 KiB pages, before and
after 5/7:

  record  pwritev2() flags          4 KiB device       MiB/s
  bytes                             reads per write
                                    before   after     before  after
  47008   RWF_DONTCACHE             0.97     0.0005    831     2281
  47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
  6000    RWF_DONTCACHE             0.97     0.0001    121      488
  6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206

47008 bytes is the transfer size of IO500's ior-hard, in which each
rank writes interleaved records to one shared file.  Any record size
that is not a multiple of the page size has the same problem.  6000
bytes is a second example.

The test program and script: https://lore.kernel.org/linux-nfs/atqJBS8MlYfeUU-t@kernel.org/

- 1/7 moves code into a helper, with no functional change.
- 2/7 fixes 88d6f128d06d ("mm: track DONTCACHE dirty pages per
  bdi_writeback"), in v7.3: WB_DONTCACHE_DIRTY could drift.
- 3/7 reports WB_DONTCACHE_DIRTY in the bdi debugfs stats.
- 4/7 adds folio_mark_dropbehind() for a folio that is already dirty.
- 5/7 keeps a partially covered folio until the write that completes it.
- 6/7 lets a writer that syncs its own write complete those folios
  itself, after the sync.
- 7/7 makes NFSD do that for the misaligned ends of a direct-mode WRITE.

Merging: Chuck suggested taking the series through the mm tree.  1/7 to
6/7 apply cleanly to each of these mm branches:

  mm-unstable  4318887a3efa ("fs/proc/task_mmu: fix lost maps entries above 2^63")
  mm-new       daed51c91051 ("riscv: mm: fix concurrency in mark_new_valid_map()")
  mm-stable    fa4ad798f6f6 ("Merge tag 'for-7.4-rc1-tag' of git://git.kernel.org/pub/scm/linux/kernel/git/kdave/linux")

7/7 needs the NFSD direct-mode changes that are in cel/nfsd-testing.
The whole series applies to cel/nfsd-testing at ab036e3a0dd4 ("NFSD:
Refuse a direct READ whose aligned range exceeds the reply pages"),
where each patch builds with W=1 with no warnings.  So 7/7 could follow
in the nfsd tree once the mm part is merged.

Changes since v11:
- 4/7: folio_mark_dropbehind() leaves a mapped folio unmarked.  Through
  its page table, a mapped folio can be dirtied without the folio lock,
  and PG_dirty set before the folio is counted.  With a stale dirty tag,
  folio_mark_dropbehind() then counted the folio in WB_DONTCACHE_DIRTY,
  and the dirtier counted it again.  sashiko found this in its review of
  v11 4/7 (https://lore.kernel.org/r/sashiko-outbox-210121@kernel.org).
  The folio lock keeps an unmapped folio unmapped, so the window is
  closed for every dirtier that does not use buffer heads.
  filemap_end_dropbehind() does not drop a mapped folio either.
- 6/7: filemap_dontcache_edge_complete() leaves a mapped folio alone,
  dirty or clean, to match.
- Jeff's Reviewed-by is dropped from 4/7, which now has a code change.
- Testing: a KUnit test (not in this series) runs the interleaving from
  sashiko's review step by step.  On an unmapped folio, the folio is
  counted twice.  On a mapped folio, v12 leaves it unmarked and the
  count is correct.  The v11 tests through NFSD and with RWF_DONTCACHE
  give the same results with v12.
- Rebased on the current cel/nfsd-testing.

v11: https://lore.kernel.org/linux-nfs/20261111015607.46338-1-snitzer@kernel.org/
v10: https://lore.kernel.org/linux-nfs/20261103211754.35352-1-snitzer@kernel.org/
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
  mm: move clearing the dropbehind flag of a found folio into a helper
  mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
  mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
  mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
  mm, iomap: keep a partially covered page until a DONTCACHE write completes it
  mm, iomap: let a DONTCACHE writer complete its shared pages itself
  NFSD: drop a shared boundary page only once both WRITEs have written it

 .../filesystems/nfs/nfsd-io-modes.rst         |  18 ++
 fs/iomap/buffered-io.c                        |  30 ++-
 fs/iomap/trace.h                              |   3 +-
 fs/nfsd/vfs.c                                 | 107 ++++++++-
 include/linux/fs.h                            |   5 +-
 include/linux/iomap.h                         |   1 +
 include/linux/pagemap.h                       |  12 +
 mm/backing-dev.c                              |   6 +
 mm/filemap.c                                  | 219 ++++++++++++++++--
 9 files changed, 370 insertions(+), 31 deletions(-)


base-commit: ab036e3a0dd410f762192f33d6244e7993b36f8d
-- 
2.52.0


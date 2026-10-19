Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792422448;
	b=g3GC6pBWDfO8mASEmxKI189whr00O/BRjQWhwc0vn6UTxy0N0UJLT3CCmSqpvtq0dbqI
	 u36ZcVEIux8+xhtVdSRC3FBlcwTezqNYwoDdzmS2alx2Z6qo8R8noUWRR9oh90XGLU5iQ
	 +dpns1LoeTBKkwxPIhWYIAOtFDqz9eFja5VXpn1A2uoW7OXOcwALpuHn2yhl+eCGd9Pkv
	 idASpgiq6TAro6KkBkZADqpkFAuezu7Wzef2TY0yXnGbn502EQ68VCljkSluCAu91/OHQ
	 iWiF7DCTAd1tTY7BuSyosdlgsfaRyoKZrBoUoDzBOSZv0CmL0GWOPLrHJES/ZhP0ixg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792422448;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=fwOiNhCTnZrqfGqH9TnldJ5DIHOFF0sKxmDqg1xr2P0=;
	b=ov8FPioJ8gNg7nKmjVRoamedSSpXbe3xba8c/JMQVfYgQbM0SRpgwwpsEalMSiP8BUX2
	 gMlox2iKXR9fnmppSTPy0qvHJYi0K7lUMXnzbCIL1edZsGRneZLMCNOfJR232cYkuS12X
	 CNKuwT0o+vNMkzd1aMf/N2at0/8ian8y3rI2i7VF5YofmzReCE1Hygnnf4F+icuHRTwpA
	 ZWpd1Eup2a6gQbBaw0ac6oYtLFw3U3oT+4EOWiM3dopgiMB6yhwez6XQbryK57AzXCgWR
	 +FETcFeu0EdGVq+UXhXWvKiV3Dkxr4j09sb8fBLN2Fb7Ble15dwyAT5zERpuLP9lqKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SeaWtDs9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 678FB6083431;
	Mon, 19 Oct 2026 15:07:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SeaWtDs9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D579D1F000C4;
	Mon, 19 Oct 2026 15:07:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792422447;
	bh=fwOiNhCTnZrqfGqH9TnldJ5DIHOFF0sKxmDqg1xr2P0=;
	h=From:To:Cc:Subject:Date;
	b=SeaWtDs9gxmhFp+vIt4L84AgDz6rjq+MyRqzdqZNSFtglItNvDMdmTgbJcGcsq8Xz
	 Eye5aGoYQSrPh9EciHAWvyhlyAejXwTOOnsf3OonSv3DFoNVKAssZCYUFjLsQ+SybF
	 gDqesw6cIzdFPdL6GiGjKFkZuzccLI6N2Wj6XoW5T0FsT/AMV0zpkG0GGvMYMnwENH
	 wFCV0+LjkEPju3OuVrWndS6+fDWD3bMsUHIo1+g9qmV07mun11mmigFrQnIspe8AWV
	 7m4hSeJaRBnACejNXCm/7SrfHTrlhY68oChuZ1jtoGJpHS38IQulRnQnj+j5ZTVJ1p
	 md8SIrkVZesfQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 0/6] mm, iomap, NFSD: stop uncached writes reading back shared pages
Date: Mon, 19 Oct 2026 11:07:19 -0400
Message-ID: <20261019150725.1507-1-snitzer@kernel.org>
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

Chuck asked, of v4 7-9, whether those changes belong in NFSD or in mm:
"Seems like you've identified an issue with DONTCACHE itself that
shouldn't be limited to an NFSD-only fix."  He was right, and v5 moves
the fix into the page cache.

An uncached (RWF_DONTCACHE) buffered write drops each page it writes
once that page is written back.  A page the write covers only partly is
shared with the neighbouring write, and once the first of the two has
been written back the second has to read it back from disk before it
can write its part.  This shows without NFS.  32 threads writing
interleaved records to one file on XFS (emulated 4Kn NVMe, 4 KiB pages),
before and after 4/6:

  record  pwritev2() flags          4 KiB device       MiB/s
  bytes                             reads per write
                                    before   after     before  after
  47008   RWF_DONTCACHE             0.97     0.000     831     2281
  47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.000     601     1227
  6000    RWF_DONTCACHE             0.97     0.000     121      488
  6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.000      90      206

4/6 has the page cache keep such a page for the write that completes
it, and drop it after that.  5/6 lets a writer that syncs its own write,
as NFSD does for a stable WRITE, mark those pages itself once the sync
is done, so they are dropped without extra writeback.  6/6 is what is
left of v4's 9/10: NFSD uses 5/6 and no longer manages any page cache
state of its own.

For NFSD DIRECT, 32 interleaved writers of 47008-byte records, against
v4:

                             device reads per WRITE   MiB/s
  each record sent as        v4       v5              v4      v5
  1 FILE_SYNC WRITE          0.0102   0.0002          379     402
  2, one after the other     0.0021   0.0001          217     237
  2 at the same time         0.0401   0.0001          212     234
  2 UNSTABLE, then COMMIT    0.0944   0.0001          219     248

and a FILE_SYNC WRITE no longer wakes the DONTCACHE writeback kick at
all.  The patches' own descriptions carry the details.

How this might land:

- 1/6, tracepoints for how each direct-mode READ and WRITE is serviced,
  is NFSD only and does not depend on the rest.  Chuck, it can go into
  nfsd-testing on its own.

- 2/6 to 5/6 are mm, with small iomap changes and an IOCB flag in 4/6
  and 5/6; 6/6 is the NFSD change that uses them.  They are Cc'd to
  linux-mm and linux-fsdevel.  It would help if the mm and iomap
  maintainers could review them and, if they are agreeable, ack them for
  Chuck to take 2/6 to 6/6 through nfsd-testing, so that further NFSD
  direct-mode changes can build on them there.

The series applies to cel/nfsd-testing (b4e06bef3884) and each patch
builds with W=1 with no warnings.

Changes since v4:
- v4 1/10 to 6/10 dropped: Chuck applied them to nfsd-testing.
- v4 10/10, the tracepoints, moved first, as 1/6.
- v4 7/10 and 8/10 swapped, as 3/6 and 2/6.
- New 4/6 and 5/6: the page cache, not NFSD, keeps the shared page.
- 6/6 (was 9/10) retitled "NFSD: drop a shared boundary page only once
  both WRITEs have written it" and reduced to calling 5/6's functions.
  It folds in "NFSD: mark a shared boundary page only once the other
  WRITE has written it", posted in reply to v4 9/10.
- nfsd-io-modes.rst describes the page cache keeping the shared page.

v4: https://lore.kernel.org/linux-nfs/20261015233309.42999-1-snitzer@kernel.org/
v3: https://lore.kernel.org/linux-nfs/20261001045502.48381-1-snitzer@kernel.org/
v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kernel.org/
v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kernel.org/

Thanks,
Mike

Mike Snitzer (6):
  NFSD: add tracing for how direct-mode READ and WRITE are serviced
  mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
  mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
  mm, iomap: keep a partly covered page until an uncached write completes it
  mm, iomap: let an uncached writer complete its shared pages itself
  NFSD: drop a shared boundary page only once both WRITEs have written it

 .../filesystems/nfs/nfsd-io-modes.rst         |  55 ++++++-
 fs/iomap/buffered-io.c                        |  16 +-
 fs/iomap/trace.h                              |   3 +-
 fs/nfsd/trace.h                               |  77 +++++++++
 fs/nfsd/vfs.c                                 | 146 +++++++++++++++---
 fs/nfsd/vfs.h                                 |   9 ++
 include/linux/fs.h                            |   8 +-
 include/linux/iomap.h                         |   1 +
 include/linux/pagemap.h                       |  12 ++
 mm/backing-dev.c                              |  11 ++
 mm/filemap.c                                  | 106 ++++++++++++-
 11 files changed, 413 insertions(+), 31 deletions(-)

-- 
2.52.0

